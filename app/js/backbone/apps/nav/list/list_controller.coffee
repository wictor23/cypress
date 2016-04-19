@App.module "NavApp.List", (List, App, Backbone, Marionette, $, _) ->

  chat = new window.gitter.Chat({
    room: "cypress-io/cypress"
    activationElement: false
  })

  class List.Controller extends App.Controllers.Application

    initialize: (options) ->
      { navs } = options

      config   = App.request "app:config:entity"

      @listenTo config, "change:gitter", (model, value, options) ->
        chat.toggleChat(value)
        navs.toggleChat()

      ## make sure we empty this region since we're
      ## in control of it
      @listenTo config, "close:test:panels", ->
        @layout.panelsRegion.empty()

      @listenTo config, "remove:nav", ->
        @layout.satelliteMode()
        @layout.destroy()

      @listenTo config, "change:ui", (model, value, options) ->
        ## if we're entering satellite mode then hide our layout
        ## and update some DOM classes for display purposes
        return @layout.satelliteMode() if value is "satellite"

        ## else if our previous ui attribute was satellite then
        ## we need to show our layout and re-render our navs region
        if model.previous("ui") is "satellite"
          @navsRegion(navs, config, chat)
          @layout.satelliteMode(false)

      @layout = @getLayoutView()

      @listenTo @layout, "gitter:toggled", (bool) ->
        config.set "gitter", bool

      @listenTo @layout, "show", ->
        @navsRegion(navs, config, chat)

      @show @layout

    navsRegion: (navs, config, chat) ->
      navView = @getNavView(navs, config)

      @listenTo navView, "childview:gitter:toggle:clicked", ->
        config.toggleGitter()

      @show navView, region: @layout.navRegion

    getNavView: (navs, config) ->
      new List.Navs
        collection: navs
        model: config

    getLayoutView: ->
      new List.Layout
