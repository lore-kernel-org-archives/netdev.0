From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCH v2 05/10] net/fec: add dual fec support for mx28
Date: Wed, 5 Jan 2011 10:03:12 +0100
Message-ID: <20110105090312.GO25121@pengutronix.de>
References: <1294133056-21195-1-git-send-email-shawn.guo@freescale.com> <1294133056-21195-6-git-send-email-shawn.guo@freescale.com> <20110104095916.GE2987@jasper.tkos.co.il> <20110104141259.GA21274@freescale.com> <20110105084513.GA26617@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sascha Hauer <s.hauer@pengutronix.de>,
	Baruch Siach <baruch@tkos.co.il>, B32542@freescale.com,
	netdev@vger.kernel.org, bryan.wu@canonical.com, gerg@snapgear.com,
	w.sang@pengutronix.de, r64343@freescale.com, eric@eukrea.com,
	davem@davemloft.net, linux-arm-kernel@lists.infradead.org,
	lw@karo-electronics.de
To: Shawn Guo <shawn.guo@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:53688 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751163Ab1AEJDO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jan 2011 04:03:14 -0500
Content-Disposition: inline
In-Reply-To: <20110105084513.GA26617@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Shawn,

On Wed, Jan 05, 2011 at 09:45:13AM +0100, Sascha Hauer wrote:
> On Tue, Jan 04, 2011 at 10:13:09PM +0800, Shawn Guo wrote:
> > Hi Baruch,
> >=20
> > On Tue, Jan 04, 2011 at 11:59:16AM +0200, Baruch Siach wrote:
> > > Hi Shawn,
> > >=20
> > > On Tue, Jan 04, 2011 at 05:24:11PM +0800, Shawn Guo wrote:
> > > > This patch is to add mx28 dual fec support. Here are some key n=
otes
> > > > for mx28 fec controller.
> > > >=20
> > > >  - mx28 fec design made an assumption that it runs on a
> > > >    big-endian system, which is incorrect. As the result, the
> > > >    driver has to swap every frame going to and coming from
> > > >    the controller.
> > > >  - external phys can only be configured by fec0, which means
> > > >    fec1 can not work independently and both phys need to be
> > > >    configured by mii_bus attached on fec0.
> > > >  - mx28 fec reset will get mac address registers reset too.
> > > >  - MII/RMII mode and 10M/100M speed are configured differently
> > > >    from i.mx/mxs fec controller.
> > > >  - ETHER_EN bit must be set to get interrupt work.
> > > >=20
> > > > Signed-off-by: Shawn Guo <shawn.guo@freescale.com>
> > > > ---
> > > > Changes for v2:
> > > >  - Use module parameter fec.macaddr over new kernel command lin=
e
> > > >    fec_mac to pass mac address
> > >=20
> > > Since you introduce this new kernel command line parameter in pat=
ch #3 of this=20
> > > series, why not just make it right in the first place? This shoul=
d make both=20
> > > patches smaller and easier for review.
> > >=20
> > > >  - Update comment in fec_get_mac() to stop using confusing word
> > > >    "default"
> > > >  - Fix copyright breakage in fec.h
> > >=20
> > > Ditto.
> > >=20
> > Sorry for rushing to send the patch set out. All these updates
> > should happen on patch #3 than #5.  This is a serious problem,
> > and I will fix it soon and resend as v3.
> >=20
> > > >  drivers/net/Kconfig |    7 ++-
> > > >  drivers/net/fec.c   |  139 +++++++++++++++++++++++++++++++++++=
+++++----------
> > > >  drivers/net/fec.h   |    5 +-
> > > >  include/linux/fec.h |    3 +-
> > > >  4 files changed, 120 insertions(+), 34 deletions(-)
> > >=20
> > > [snip]
> > >=20
> > > > diff --git a/drivers/net/fec.c b/drivers/net/fec.c
> > > > index f147508..b2b3e37 100644
> > > > --- a/drivers/net/fec.c
> > > > +++ b/drivers/net/fec.c
> > > > @@ -17,6 +17,8 @@
> > > >   *
> > > >   * Bug fixes and cleanup by Philippe De Muyter (phdm@macqel.be=
)
> > > >   * Copyright (c) 2004-2006 Macq Electronique SA.
> > > > + *
> > > > + * Copyright (C) 2010 Freescale Semiconductor, Inc.
> > > >   */
> > > > =20
> > > >  #include <linux/module.h>
> > > > @@ -45,21 +47,34 @@
> > > > =20
> > > >  #include <asm/cacheflush.h>
> > > > =20
> > > > -#ifndef CONFIG_ARCH_MXC
> > > > +#if !defined(CONFIG_ARCH_MXC) && !defined(CONFIG_SOC_IMX28)
> > > >  #include <asm/coldfire.h>
> > > >  #include <asm/mcfsim.h>
> > > >  #endif
> > > > =20
> > > >  #include "fec.h"
> > > > =20
> > > > -#ifdef CONFIG_ARCH_MXC
> > > > -#include <mach/hardware.h>
> > >=20
> > > Since you now remove mach/hardware.h for ARCH_MXC, does this buil=
d for all=20
> > > i.MX variants?
> > >=20
> > Did the test build for mx25, mx27, mx3 and mx51.
> >=20
> > > > +#ifdef CONFIG_SOC_IMX28
> > > > +/*
> > > > + * mx28 does not have MIIGSK registers
> > > > + */
> > > > +#undef FEC_MIIGSK_ENR
> > > > +#include <mach/mxs.h>
> > > > +#else
> > > > +#define cpu_is_mx28()	(0)
> > > > +#endif
> > >=20
> > > This breaks kernels for multiple archs (e.g. i.MX28 and i.MX25). =
Please use=20
> > > run-time detection of CPU type, and do the MII/RMII etc. configur=
ation=20
> > > accordingly.
> > >=20
> > I do not find a good way to detect cpu type.  Neither adding a new
> > platform data field nor using __machine_arch_type to enumerate all
> > mx28 based machine (though there is only one currently) seems to be
> > good for me.
> >=20
> > I will try to manipulate some mx28 unique register to identify mx28
> > from other i.mx variants.  Hopefully, it will work.
>=20
> There won't be a register which you can safely read on all i.MX
> variants.
> Why don't you implement it the same way the other i.MX do? They do no=
t
> need SoC detection and the macro expands to 0 at compile time when th=
e
> cpu is not enabled.
Alternatively you can use the approach I used for spi-imx and identify
the device by name.

Best regards
Uwe

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
