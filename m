From: PERIER Romain <romain.perier@gmail.com>
Subject: Re: [PATCH v2] ethernet: arc: Add support for specific SoC glue layer
 device tree bindings
Date: Wed, 20 Aug 2014 08:39:22 +0200
Message-ID: <CABgxDoK2_EYhhGm2XWAAO-nOQZa4Om-b0fMm5ezRdWrse7owrg@mail.gmail.com>
References: <1408286882-10186-1-git-send-email-romain.perier@gmail.com>
	<CABgxDoL5WZ_r6hDuWF2=LJA6wFB4h6voqXdOEHG1jAbpdPN9ZQ@mail.gmail.com>
	<201408191413.12337.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: davem <davem@davemloft.net>,
	=?UTF-8?Q?Heiko_St=C3=BCbner?= <heiko@sntech.de>,
	Tobias Klauser <tklauser@distanz.ch>,
	Beniamino Galvani <b.galvani@gmail.com>,
	"eric.dumazet" <eric.dumazet@gmail.com>,
	yongjun_wei@trendmicro.com.cn,
	Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f46.google.com ([209.85.192.46]:45915 "EHLO
	mail-qg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751208AbaHTGjX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Aug 2014 02:39:23 -0400
Received: by mail-qg0-f46.google.com with SMTP id z60so3444498qgd.19
        for <netdev@vger.kernel.org>; Tue, 19 Aug 2014 23:39:22 -0700 (PDT)
In-Reply-To: <201408191413.12337.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-08-19 14:13 GMT+02:00 Arnd Bergmann <arnd@arndb.de>:
> On Monday 18 August 2014, PERIER Romain wrote:
>> Adding Arnd to the loop, as he was interested by these changes.
>>
>> 2014-08-17 16:48 GMT+02:00 Romain Perier <romain.perier@gmail.com>:
>> > Some platforms have special bank registers which might be used to select
>> > the correct clock or the right mode for Media Indepent Interface controllers.
>> > Sometimes, it is also required to activate vcc regulators in the right order to supply
>> > the ethernet controller at the right time. This patch is a refactoring of the arc-emac
>> > device driver, it adds a new software architecture design which allows to add specific
>> > platform glue layer. Each platform has now its own module which performs custom initialization
>> > and remove for the target and then calls to the core driver.
>
> Looks quite good to me overall, I only have minor stylistic comments
>
>> > +/* Platform data for SoC glue layer device tree bindings */
>> > +struct arc_emac_platform_data
>> > +{
>> > +       const char *name;
>> > +       const char *version;
>> > +       int interface;
>> > +       struct clk *clk;
>> > +       void (*set_mac_speed)(void *priv, unsigned int speed);
>> > +       void *priv;
>> > +};
>> > +
>> >  /**
>> >   * struct arc_emac_priv - Storage of EMAC's private information.
>> >   * @dev:       Pointer to the current device.
>> >   * @phy_dev:   Pointer to attached PHY device.
>> >   * @bus:       Pointer to the current MII bus.
>> > + * @plat_data: Pointer to SoC specific data.
>> >   * @regs:      Base address of EMAC memory-mapped control registers.
>> >   * @napi:      Structure for NAPI.
>> >   * @rxbd:      Pointer to Rx BD ring.
>
> Any reason why these are separate structures? It seems to me you could
> just move everything into arc_emac_priv.

The idea is that arc_emac_priv is the private data structure for the
core driver, it should not be used outside of the core (emac_main.c,
emac_mdio.c).
arc_emac_platform_data contains all the variant data exported by the
platform driver. That's a logical seperation, nothing more.
The priv data structure should not go outside of the component for
which it was designed, imho (at least with the current design, see
below).

>
> While it can make sense to pass a structure containting constant data
> (e.g. callback pointers and the name field) as a pointer, for the
> rest I don't see an advantage.

* interface is required when the core driver connects to the phy for
the first time (of_phy_connect). It could be passed as parameter of
arc_emac_probe directly.
* clk is the host clock for emac, it might change according to the
platform and needs to be shared with probe and remove.
* priv is the private data structure of the platform (arc or rockchip for now)

>
> The new fields in arc_emac_platform_data should be documented the same
> way the fields in arc_emac_priv are.

Good point.

>
> You could solve both issues if you move the alloc_etherdev() call into the
> front-end, and pass that to both probe() and remove() callbacks.
> That way you could also avoid the additional priv pointer if you just
> embed the arc_emac_priv structure into the per-frontend structure.

Moving alloc_etherdev() to the front-end is a good idea, indeed.
What I could do is the following :

- Move alloc_etherdev to the front-end
- Move arc_emac_platform_data into arc_emac_priv (except the field
interface which is a parameter of probe)
- I would keep the priv field, i.e, the private data structure for the
platform driver. In this way if we need to add modifications to this
private data structure, we don't need to modify arc_emac_priv. Also,
some platform drivers might have special dependencies like regulator
or syscon. It avoids to move these dependencies to the core.
- arc_emac_probe would be :    int arc_emac_probe(struct net_device
*netdev, int interface);
- arc_emac_remove would be: int arc_emac_remove(struct net_device *netdev);

>
>> > +
>> > +#define DRV_NAME "emac_arc"
>> > +#define DRV_VERSION "1.0"
>> > +
>> > +static int emac_arc_probe(struct platform_device *pdev)
>> > +{
>> > +       struct arc_emac_platform_data *plat_data = NULL;
>> > +       struct device *dev = &pdev->dev;
>> > +
>> > +       plat_data = devm_kzalloc(dev, sizeof(*plat_data), GFP_KERNEL);
>
> Remove the "= NULL" above, it is pointless here.

ack

>
>> > +       if (!plat_data)
>> > +               return -ENOMEM;
>> > +       plat_data->name = DRV_NAME;
>> > +       plat_data->version = DRV_VERSION;
>
> I don't see much use in having a per-frontend DRV_NAME/DRV_VERSION pased
> here and would just leave those as part of the backend library.

the platform driver might contain code which might change the behavior
of the ethernet driver, according to the selected platform , this is
not exactly the same driver. That's why I did this change.

>
>> > +       plat_data->interface = of_get_phy_mode(dev->of_node);
>> > +       if (plat_data->interface < 0)
>> > +               plat_data->interface = PHY_INTERFACE_MODE_MII;
>> > +
>> > +       plat_data->clk = devm_clk_get(dev, "hclk");
>> > +        if (IS_ERR(plat_data->clk)) {
>> > +               dev_err(dev, "failed to retrieve host clock from device tree\n");
>> > +               return PTR_ERR_OR_ZERO(plat_data->clk);
>> > +       }
>
> devm_clk_get() might return -EPROBE_DEFER, in and in that case you should silently
> return that to the caller as well.

ack

>
>> > -static int arc_emac_probe(struct platform_device *pdev)
>> > +int arc_emac_probe(struct device *dev, const struct arc_emac_platform_data *plat_data)
>> >  {
>> >         struct resource res_regs;
>> >         struct device_node *phy_node;
>
> I would keep passing a platform_device pointer rather than device. If you think
> it's a worthwhile simplification to pass just the device, that could be a separate
> patch.

platform_device should not be in the core driver, this is platform
dependent, so it should not be outside of the platform drivers
(emac_arc.c, emac_rockchip.c). Imho. (

I will probably re-send two commits for all these changes :
* 1st commit:
   - int arc_emac_probe(struct platform_device *, int interface);
   - int arc_emac_remove(struct platform_device *);
   - alloc_etherdev in the front-end
* 2nd commit:
   - int arc_emac_probe(struct net_device *, int interface);
   - int arc_emac_remove(struct net_device *);

What do you think about the above proposals ?
Thanks

Romain
