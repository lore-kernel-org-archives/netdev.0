From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 3/3] net: hisilicon: new hip04 ethernet driver
Date: Mon, 24 Mar 2014 11:02:28 +0100
Message-ID: <5755212.stImUCLDZi@wuerfel>
References: <1395132017-15928-1-git-send-email-zhangfei.gao@linaro.org> <201403201531.20416.arnd@arndb.de> <CAMj5Bkgc2ChK48QmqEEMEmxdF6iGZxMX0kVUqGFd8jYhEWCvOA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Zhangfei Gao <zhangfei.gao@gmail.com>,
	Zhangfei Gao <zhangfei.gao@linaro.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.24]:52496 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752088AbaCXKCy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2014 06:02:54 -0400
In-Reply-To: <CAMj5Bkgc2ChK48QmqEEMEmxdF6iGZxMX0kVUqGFd8jYhEWCvOA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 24 March 2014 16:17:42 Zhangfei Gao wrote:
> On Thu, Mar 20, 2014 at 10:31 PM, Arnd Bergmann <arnd@arndb.de> wrote:
> >> >
> >> >> +     if (!ppebase) {
> >> >> +             struct device_node *n;
> >> >> +
> >> >> +             n = of_find_compatible_node(NULL, NULL, "hisilicon,hip04-ppebase");
> >> >> +             if (!n) {
> >> >> +                     ret = -EINVAL;
> >> >> +                     netdev_err(ndev, "not find hisilicon,ppebase\n");
> >> >> +                     goto init_fail;
> >> >> +             }
> >> >> +             ppebase = of_iomap(n, 0);
> >> >> +     }
> >> >
> >> > How about using syscon_regmap_lookup_by_phandle() here? That way, you can have
> >> > a more generic abstraction of the ppe, and stick the port and id in there as
> >> > well, e.g.
> >> >
> >> >         ppe-syscon = <&hip04ppe 1 4>; // ppe, port, id
> 
> Even if using syscon_regmap_lookup_by_phandle, there still have static
> struct regmap, since three controllers
> share one regmap.

The regmap is then owned by the syscon driver, while each controller takes
a reference to the regmap that it can store in its own private data
structure. However, as we discussed using a ppe driver sounds nicer than
regmap.

> > It's probably a little simpler to avoid the sub-nodes and instead do
> >
> >>               ppe: ppe@28c0000 {
> >>                         compatible = "hisilicon,hip04-ppe";
> >>                         reg = <0x28c0000 0x10000>;
> >>                         #address-cells = <1>;
> >>                         #size-cells = <0>;
> >>                 };
> >>                 fe: ethernet@28b0000 {
> >>                         compatible = "hisilicon,hip04-mac";
> >>                         reg = <0x28b0000 0x10000>;
> >>                         interrupts = <0 413 4>;
> >>                         phy-mode = "mii";
> >>                         port-handle = <&ppe 31>;
> >>                 };
> >
> > In the code, I would create a simple ppe driver that exports
> > a few functions. you need. In the ethernet driver probe() function,
> > you should get a handle to the ppe using
> >
> >         /* look up "port-handle" property of the current device, find ppe and port */
> >         struct hip04_ppe *ppe = hip04_ppe_get(dev->of_node);
> >         if (IS_ERR(ppe))
> >                 return PTR_ERR(ptr); /* this handles -EPROBE_DEFER */
> >
> > and then in other code you can just do
> >
> >         hip04_ppe_set_foo(priv->ppe, foo_config);
> >
> > This is a somewhat more high-level abstraction that syscon, which
> > just gives you a 'struct regmap' structure for doing register-level
> > configuration like you have today.
> >
> 
> Do you mean create one additional file like ppe.c with some exported
> function to remove the static ppebase?

It doesn't have to be a separate file, as long as you register a
separate platform_driver for the ppe.

> Since the ppe is specifically bounded with ethernet, and does not used
> anywhere else,
> the exported function may not be used anywhere else.
> Is it make it more complicated since there are probe, remove etc.
> 
> So I may still prefer using "static void __iomem *ppebase", as it is simpler.

The trouble is that the driver should not rely on being only there
for a single instance, that's not how we write drivers.

I'm fine with either a syscon instance (which would be simpler) or a
separate ppe driver as part of the hip04-mac driver (which would be
a nicer abstraction).

	Arnd
