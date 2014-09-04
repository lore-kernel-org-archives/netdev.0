From: Beniamino Galvani <b.galvani@gmail.com>
Subject: Re: [PATCH v5 1/4] ethernet: arc: Add support for Rockchip SoC layer
 device tree bindings
Date: Thu, 4 Sep 2014 21:30:33 +0200
Message-ID: <20140904192934.GB14583@gmail.com>
References: <1409763165-16461-1-git-send-email-romain.perier@gmail.com>
 <20140903211220.GA16962@gmail.com>
 <CABgxDoLWqqwGUUt9hWuJdHT_VF0c6-7xeAwgfeH7TwJmu1BN9w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Heiko =?iso-8859-1?Q?St=FCbner?= <heiko@sntech.de>,
	linux-rockchip@lists.infradead.org,
	linux-arm-kernel@lists.infradead.org,
	netdev <netdev@vger.kernel.org>,
	devicetree <devicetree@vger.kernel.org>,
	Arnd Bergmann <arnd@arndb.de>
To: PERIER Romain <romain.perier@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f45.google.com ([74.125.82.45]:56392 "EHLO
	mail-wg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751797AbaIDTbS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Sep 2014 15:31:18 -0400
Content-Disposition: inline
In-Reply-To: <CABgxDoLWqqwGUUt9hWuJdHT_VF0c6-7xeAwgfeH7TwJmu1BN9w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 04, 2014 at 10:45:35AM +0200, PERIER Romain wrote:
> Hi Beniamino,
> 
> I will investigate. Could you please :
> 
> - Load the module
> - Show me the output of lsmod
> - Use your ethernet a bit
> - Try to unload the module
> - If your board did not freeze or if your kernel did not panic , show
> me your dmesg (if it is impossible show me the dmesg before unloading
> the module)
> 
> Perhaps, we could continue this discussion in private (by email or
> IRC). What do you think ?
> 
> I will investigate this evening and tomorrow. Thanks for your feedbacks .

Hi Romain,

the freeze happens in clk_disable_unprepare(), which disables the
macref clock parents up to the dpll, needed by the DDR.

As suggested by Heiko on IRC, the patch "clk: rockchip: protect
critical clocks from getting disabled" [1], modified to include ddrphy
in the list of critical clocks, solves the problem.

During the module unload, if you move the call to arc_emac_remove()
before clk_disable_unprepare() you can avoid a delay of 4-5 seconds
caused by the timeout of the function phy_disconnect(). In any case:

Tested-by: Beniamino Galvani <b.galvani@gmail.com>

[1] https://git.linaro.org/people/mike.turquette/linux.git/commit/fe94f974e9c8b820640a5873d81589ab67380516

> 
> 
> 2014-09-03 23:12 GMT+02:00 Beniamino Galvani <b.galvani@gmail.com>:
> > On Wed, Sep 03, 2014 at 04:52:42PM +0000, Romain Perier wrote:
> >> This patch defines a platform glue layer for Rockchip SoCs which
> >> support arc-emac driver. It ensures that regulator for the rmii is on
> >> before trying to connect to the ethernet controller. It applies right
> >> speed and mode changes to the grf when ethernet settings change.
> >
> > Hi Romain,
> >
> > on a Radxa Rock when I try to remove the emac_rockchip module the
> > board locks up when calling clk_disable_unprepare(priv->refclk). The
> > tree is a net-next + your series, I don't know if I need some other
> > patches.
> >
> > There is also the following build warning due to the emac dependency
> > on REGULATOR which in principle seems correct, but looking at other
> > drivers I wonder why they use the regulator APIs but don't have the
> > same dependency.
> >
> > drivers/regulator/Kconfig:1:error: recursive dependency detected!
> > drivers/regulator/Kconfig:1:       symbol REGULATOR is selected by MDIO_SUN4I
> > drivers/net/phy/Kconfig:159:       symbol MDIO_SUN4I depends on PHYLIB
> > drivers/net/phy/Kconfig:5:         symbol PHYLIB is selected by ARC_EMAC_CORE
> > drivers/net/ethernet/arc/Kconfig:20:      symbol ARC_EMAC_CORE is selected by EMAC_ROCKCHIP
> > drivers/net/ethernet/arc/Kconfig:35:      symbol EMAC_ROCKCHIP depends on REGULATOR
> >
> > Regards,
> > Beniamino
