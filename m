From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v2] ethernet: arc: Add support for specific SoC glue layer device tree bindings
Date: Wed, 20 Aug 2014 18:43:57 +0200
Message-ID: <201408201843.58139.arnd@arndb.de>
References: <1408286882-10186-1-git-send-email-romain.perier@gmail.com> <201408191413.12337.arnd@arndb.de> <CABgxDoK2_EYhhGm2XWAAO-nOQZa4Om-b0fMm5ezRdWrse7owrg@mail.gmail.com>
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
Received: from mout.kundenserver.de ([212.227.17.10]:53466 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751419AbaHTQpS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Aug 2014 12:45:18 -0400
In-Reply-To: <CABgxDoK2_EYhhGm2XWAAO-nOQZa4Om-b0fMm5ezRdWrse7owrg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 20 August 2014, PERIER Romain wrote:
> 2014-08-19 14:13 GMT+02:00 Arnd Bergmann <arnd@arndb.de>:
> > On Monday 18 August 2014, PERIER Romain wrote:
> >> > +/* Platform data for SoC glue layer device tree bindings */
> >> > +struct arc_emac_platform_data
> >> > +{
> >> > +       const char *name;
> >> > +       const char *version;
> >> > +       int interface;
> >> > +       struct clk *clk;
> >> > +       void (*set_mac_speed)(void *priv, unsigned int speed);
> >> > +       void *priv;
> >> > +};
> >> > +
> >> >  /**
> >> >   * struct arc_emac_priv - Storage of EMAC's private information.
> >> >   * @dev:       Pointer to the current device.
> >> >   * @phy_dev:   Pointer to attached PHY device.
> >> >   * @bus:       Pointer to the current MII bus.
> >> > + * @plat_data: Pointer to SoC specific data.
> >> >   * @regs:      Base address of EMAC memory-mapped control registers.
> >> >   * @napi:      Structure for NAPI.
> >> >   * @rxbd:      Pointer to Rx BD ring.
> >
> > Any reason why these are separate structures? It seems to me you could
> > just move everything into arc_emac_priv.
> 
> The idea is that arc_emac_priv is the private data structure for the
> core driver, it should not be used outside of the core (emac_main.c,
> emac_mdio.c).
> arc_emac_platform_data contains all the variant data exported by the
> platform driver. That's a logical seperation, nothing more.
> The priv data structure should not go outside of the component for
> which it was designed, imho (at least with the current design, see
> below).

The common pattern we have in other places is that a more specific
driver knows everything about the more generic driver. In this
case, the arc_emac_priv is a specialization of net_device, while
the arc and rockchips frontends to that would be a further
specialization

> > While it can make sense to pass a structure containting constant data
> > (e.g. callback pointers and the name field) as a pointer, for the
> > rest I don't see an advantage.
> 
> * interface is required when the core driver connects to the phy for
> the first time (of_phy_connect). It could be passed as parameter of
> arc_emac_probe directly.
> * clk is the host clock for emac, it might change according to the
> platform and needs to be shared with probe and remove.

I wasn't questioning the use of the new members, just how they
get passed.

> * priv is the private data structure of the platform (arc or rockchip for now)

This one doesn't have to be a member though, as the common way to
do this in network devices is to append it behind the more
generic data and having an inline function to do the pointer math.

> > You could solve both issues if you move the alloc_etherdev() call into the
> > front-end, and pass that to both probe() and remove() callbacks.
> > That way you could also avoid the additional priv pointer if you just
> > embed the arc_emac_priv structure into the per-frontend structure.
> 
> Moving alloc_etherdev() to the front-end is a good idea, indeed.
> What I could do is the following :
> 
> - Move alloc_etherdev to the front-end
> - Move arc_emac_platform_data into arc_emac_priv (except the field
> interface which is a parameter of probe)

yes

> - I would keep the priv field, i.e, the private data structure for the
> platform driver. In this way if we need to add modifications to this
> private data structure, we don't need to modify arc_emac_priv. Also,
> some platform drivers might have special dependencies like regulator
> or syscon. It avoids to move these dependencies to the core.

Moving the private data /into/ arc_emac_priv would be wrong indeed,
I meant doing the equivalent of netdev_priv() instead.

> - arc_emac_probe would be :    int arc_emac_probe(struct net_device
> *netdev, int interface);
> - arc_emac_remove would be: int arc_emac_remove(struct net_device *netdev);

Right.

> >> > +       if (!plat_data)
> >> > +               return -ENOMEM;
> >> > +       plat_data->name = DRV_NAME;
> >> > +       plat_data->version = DRV_VERSION;
> >
> > I don't see much use in having a per-frontend DRV_NAME/DRV_VERSION pased
> > here and would just leave those as part of the backend library.
> 
> the platform driver might contain code which might change the behavior
> of the ethernet driver, according to the selected platform , this is
> not exactly the same driver. That's why I did this change.

Ok.

> >> > -static int arc_emac_probe(struct platform_device *pdev)
> >> > +int arc_emac_probe(struct device *dev, const struct arc_emac_platform_data *plat_data)
> >> >  {
> >> >         struct resource res_regs;
> >> >         struct device_node *phy_node;
> >
> > I would keep passing a platform_device pointer rather than device. If you think
> > it's a worthwhile simplification to pass just the device, that could be a separate
> > patch.
> 
> platform_device should not be in the core driver, this is platform
> dependent, so it should not be outside of the platform drivers
> (emac_arc.c, emac_rockchip.c). Imho. (

In general it makes sense, but I don't see any frontend coming up that
would be something other than a platform_device. The only possible
one that could appear would be a PCI device, but if that ever happened,
you would likely need more changes to the common module.

It's not that important though, if you feel strongly about it, just
keep using a 'device' here rather than platform_device.

> I will probably re-send two commits for all these changes :
> * 1st commit:
>    - int arc_emac_probe(struct platform_device *, int interface);
>    - int arc_emac_remove(struct platform_device *);
>    - alloc_etherdev in the front-end
> * 2nd commit:
>    - int arc_emac_probe(struct net_device *, int interface);
>    - int arc_emac_remove(struct net_device *);
> 
> What do you think about the above proposals ?

I think it would be easier to do it the other way round and first convert
the function to operate on a 'struct device' without any functional changes,
and then have the separation into a modular driver as a second patch on top.

I usually prefer having cleanup patches done before functional changes.

	Arnd
