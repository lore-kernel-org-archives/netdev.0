From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v2] ethernet: arc: Add support for specific SoC glue layer device tree bindings
Date: Tue, 19 Aug 2014 14:13:12 +0200
Message-ID: <201408191413.12337.arnd@arndb.de>
References: <1408286882-10186-1-git-send-email-romain.perier@gmail.com> <CABgxDoL5WZ_r6hDuWF2=LJA6wFB4h6voqXdOEHG1jAbpdPN9ZQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem <davem@davemloft.net>,
	Heiko =?utf-8?q?St=C3=BCbner?= <heiko@sntech.de>,
	Tobias Klauser <tklauser@distanz.ch>,
	Beniamino Galvani <b.galvani@gmail.com>,
	"eric.dumazet" <eric.dumazet@gmail.com>,
	yongjun_wei@trendmicro.com.cn,
	Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: PERIER Romain <romain.perier@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.130]:54949 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751837AbaHSMev (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2014 08:34:51 -0400
In-Reply-To: <CABgxDoL5WZ_r6hDuWF2=LJA6wFB4h6voqXdOEHG1jAbpdPN9ZQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 18 August 2014, PERIER Romain wrote:
> Adding Arnd to the loop, as he was interested by these changes.
> 
> 2014-08-17 16:48 GMT+02:00 Romain Perier <romain.perier@gmail.com>:
> > Some platforms have special bank registers which might be used to select
> > the correct clock or the right mode for Media Indepent Interface controllers.
> > Sometimes, it is also required to activate vcc regulators in the right order to supply
> > the ethernet controller at the right time. This patch is a refactoring of the arc-emac
> > device driver, it adds a new software architecture design which allows to add specific
> > platform glue layer. Each platform has now its own module which performs custom initialization
> > and remove for the target and then calls to the core driver.

Looks quite good to me overall, I only have minor stylistic comments

> > +/* Platform data for SoC glue layer device tree bindings */
> > +struct arc_emac_platform_data
> > +{
> > +       const char *name;
> > +       const char *version;
> > +       int interface;
> > +       struct clk *clk;
> > +       void (*set_mac_speed)(void *priv, unsigned int speed);
> > +       void *priv;
> > +};
> > +
> >  /**
> >   * struct arc_emac_priv - Storage of EMAC's private information.
> >   * @dev:       Pointer to the current device.
> >   * @phy_dev:   Pointer to attached PHY device.
> >   * @bus:       Pointer to the current MII bus.
> > + * @plat_data: Pointer to SoC specific data.
> >   * @regs:      Base address of EMAC memory-mapped control registers.
> >   * @napi:      Structure for NAPI.
> >   * @rxbd:      Pointer to Rx BD ring.

Any reason why these are separate structures? It seems to me you could
just move everything into arc_emac_priv.

While it can make sense to pass a structure containting constant data
(e.g. callback pointers and the name field) as a pointer, for the
rest I don't see an advantage. 

The new fields in arc_emac_platform_data should be documented the same
way the fields in arc_emac_priv are.

> > -int arc_mdio_probe(struct platform_device *pdev, struct arc_emac_priv *priv);
> > +int arc_emac_probe(struct device *dev, const struct arc_emac_platform_data *plat_data);
> > +int arc_emac_remove(struct net_device *ndev);

This seems strangely asymmetric: the probe function neither returns a
net_device nor does it get passed one.

You could solve both issues if you move the alloc_etherdev() call into the
front-end, and pass that to both probe() and remove() callbacks.
That way you could also avoid the additional priv pointer if you just
embed the arc_emac_priv structure into the per-frontend structure.

> > +
> > +#define DRV_NAME "emac_arc"
> > +#define DRV_VERSION "1.0"
> > +
> > +static int emac_arc_probe(struct platform_device *pdev)
> > +{
> > +       struct arc_emac_platform_data *plat_data = NULL;
> > +       struct device *dev = &pdev->dev;
> > +
> > +       plat_data = devm_kzalloc(dev, sizeof(*plat_data), GFP_KERNEL);

Remove the "= NULL" above, it is pointless here.

> > +       if (!plat_data)
> > +               return -ENOMEM;
> > +       plat_data->name = DRV_NAME;
> > +       plat_data->version = DRV_VERSION;

I don't see much use in having a per-frontend DRV_NAME/DRV_VERSION pased
here and would just leave those as part of the backend library.

> > +       plat_data->interface = of_get_phy_mode(dev->of_node);
> > +       if (plat_data->interface < 0)
> > +               plat_data->interface = PHY_INTERFACE_MODE_MII;
> > +
> > +       plat_data->clk = devm_clk_get(dev, "hclk");
> > +        if (IS_ERR(plat_data->clk)) {
> > +               dev_err(dev, "failed to retrieve host clock from device tree\n");
> > +               return PTR_ERR_OR_ZERO(plat_data->clk);
> > +       }

devm_clk_get() might return -EPROBE_DEFER, in and in that case you should silently
return that to the caller as well.

> > -static int arc_emac_probe(struct platform_device *pdev)
> > +int arc_emac_probe(struct device *dev, const struct arc_emac_platform_data *plat_data)
> >  {
> >         struct resource res_regs;
> >         struct device_node *phy_node;

I would keep passing a platform_device pointer rather than device. If you think
it's a worthwhile simplification to pass just the device, that could be a separate
patch.

	Arnd
