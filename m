From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCH v4 08/10] ARM: mxs: add ocotp read function
Date: Wed, 12 Jan 2011 17:01:06 +0100
Message-ID: <20110112160106.GI24920@pengutronix.de>
References: <1294297998-26930-1-git-send-email-shawn.guo@freescale.com>
 <1294297998-26930-9-git-send-email-shawn.guo@freescale.com>
 <20110111133137.GS12078@pengutronix.de>
 <20110112064711.GG2888@freescale.com>
 <20110112145036.GY12078@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Shawn Guo <shawn.guo@freescale.com>, davem@davemloft.net,
	gerg@snapgear.com, baruch@tkos.co.il, eric@eukrea.com,
	bryan.wu@canonical.com, r64343@freescale.com, B32542@freescale.com,
	lw@karo-electronics.de, w.sang@pengutronix.de, jamie@jamieiles.com,
	jamie@shareable.org, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Sascha Hauer <s.hauer@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:37355 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754487Ab1ALQB2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jan 2011 11:01:28 -0500
Content-Disposition: inline
In-Reply-To: <20110112145036.GY12078@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Sascha,

On Wed, Jan 12, 2011 at 03:50:36PM +0100, Sascha Hauer wrote:
> On Wed, Jan 12, 2011 at 02:47:12PM +0800, Shawn Guo wrote:
> > On Tue, Jan 11, 2011 at 02:31:37PM +0100, Sascha Hauer wrote:
> > > On Thu, Jan 06, 2011 at 03:13:16PM +0800, Shawn Guo wrote:
> > > > Signed-off-by: Shawn Guo <shawn.guo@freescale.com>
> > > > ---
> > > > Changes for v4:
> > > >  - Call cpu_relax() during polling
> > > >=20
> > > > Changes for v2:
> > > >  - Add mutex locking for mxs_read_ocotp()
> > > >  - Use type size_t for count and i
> > > >  - Add comment for clk_enable/disable skipping
> > > >  - Add ERROR bit clearing and polling step
> > > >=20
> > > >  arch/arm/mach-mxs/Makefile              |    2 +-
> > > >  arch/arm/mach-mxs/include/mach/common.h |    1 +
> > > >  arch/arm/mach-mxs/ocotp.c               |   79 +++++++++++++++=
++++++++++++++++
> > > >  3 files changed, 81 insertions(+), 1 deletions(-)
> > > >  create mode 100644 arch/arm/mach-mxs/ocotp.c
> > > >=20
> > > > diff --git a/arch/arm/mach-mxs/Makefile b/arch/arm/mach-mxs/Mak=
efile
> > > > index 39d3f9c..f23ebbd 100644
> > > > --- a/arch/arm/mach-mxs/Makefile
> > > > +++ b/arch/arm/mach-mxs/Makefile
> > > > @@ -1,5 +1,5 @@
> > > >  # Common support
> > > > -obj-y :=3D clock.o devices.o gpio.o icoll.o iomux.o system.o t=
imer.o
> > > > +obj-y :=3D clock.o devices.o gpio.o icoll.o iomux.o ocotp.o sy=
stem.o timer.o
> > > > =20
> > > >  obj-$(CONFIG_SOC_IMX23) +=3D clock-mx23.o mm-mx23.o
> > > >  obj-$(CONFIG_SOC_IMX28) +=3D clock-mx28.o mm-mx28.o
> > > > diff --git a/arch/arm/mach-mxs/include/mach/common.h b/arch/arm=
/mach-mxs/include/mach/common.h
> > > > index 59133eb..cf02552 100644
> > > > --- a/arch/arm/mach-mxs/include/mach/common.h
> > > > +++ b/arch/arm/mach-mxs/include/mach/common.h
> > > > @@ -13,6 +13,7 @@
> > > > =20
> > > >  struct clk;
> > > > =20
> > > > +extern int mxs_read_ocotp(int offset, int count, u32 *values);
> > > >  extern int mxs_reset_block(void __iomem *);
> > > >  extern void mxs_timer_init(struct clk *, int);
> > > > =20
> > > > diff --git a/arch/arm/mach-mxs/ocotp.c b/arch/arm/mach-mxs/ocot=
p.c
> > > > new file mode 100644
> > > > index 0000000..e2d39aa
> > > > --- /dev/null
> > > > +++ b/arch/arm/mach-mxs/ocotp.c
> > > > @@ -0,0 +1,79 @@
> > > > +/*
> > > > + * Copyright 2010 Freescale Semiconductor, Inc. All Rights Res=
erved.
> > > > + *
> > > > + * This program is free software; you can redistribute it and/=
or modify
> > > > + * it under the terms of the GNU General Public License as pub=
lished by
> > > > + * the Free Software Foundation; either version 2 of the Licen=
se, or
> > > > + * (at your option) any later version.
> > > > + *
> > > > + * This program is distributed in the hope that it will be use=
ful,
> > > > + * but WITHOUT ANY WARRANTY; without even the implied warranty=
 of
> > > > + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See t=
he
> > > > + * GNU General Public License for more details.
> > > > + */
> > > > +
> > > > +#include <linux/delay.h>
> > > > +#include <linux/err.h>
> > > > +#include <linux/mutex.h>
> > > > +
> > > > +#include <mach/mxs.h>
> > > > +
> > > > +#define BM_OCOTP_CTRL_BUSY		(1 << 8)
> > > > +#define BM_OCOTP_CTRL_ERROR		(1 << 9)
> > > > +#define BM_OCOTP_CTRL_RD_BANK_OPEN	(1 << 12)
> > > > +
> > > > +static DEFINE_MUTEX(ocotp_mutex);
> > > > +
> > > > +int mxs_read_ocotp(unsigned offset, size_t count, u32 *values)
> > > > +{
> > > > +	void __iomem *ocotp_base =3D MXS_IO_ADDRESS(MXS_OCOTP_BASE_AD=
DR);
> > > > +	int timeout =3D 0x400;
> > > > +	size_t i;
> > > > +
> > > > +	mutex_lock(&ocotp_mutex);
> > > > +
> > > > +	/*
> > > > +	 * clk_enable(hbus_clk) for ocotp can be skipped
> > > > +	 * as it must be on when system is running.
> > > > +	 */
> > > > +
> > > > +	/* try to clear ERROR bit */
> > > > +	__mxs_clrl(BM_OCOTP_CTRL_ERROR, ocotp_base);
> > >=20
> > > This operation does not try to clear the error bit but actually c=
lears
> > > it...
> > >=20
> > > > +
> > > > +	/* check both BUSY and ERROR cleared */
> > > > +	while ((__raw_readl(ocotp_base) &
> > > > +		(BM_OCOTP_CTRL_BUSY | BM_OCOTP_CTRL_ERROR)) && --timeout)
> > > > +		cpu_relax();
> > >=20
> > > ...which means you do not have to poll the error bit here...
> > >=20
> > > > +
> > > > +	if (unlikely(!timeout))
> > > > +		goto error_unlock;
> > > > +
> > > > +	/* open OCOTP banks for read */
> > > > +	__mxs_setl(BM_OCOTP_CTRL_RD_BANK_OPEN, ocotp_base);
> > > > +
> > > > +	/* approximately wait 32 hclk cycles */
> > > > +	udelay(1);
> > > > +
> > > > +	/* poll BUSY bit becoming cleared */
> > > > +	timeout =3D 0x400;
> > > > +	while ((__raw_readl(ocotp_base) & BM_OCOTP_CTRL_BUSY) && --ti=
meout)
> > > > +		cpu_relax();
> > >=20
> > > ...which means you can factor out a ocotp_wait_busy function and =
let the
> > > code speak instead of the comments.
> > >=20
> > > > +
> > > > +	if (unlikely(!timeout))
> > > > +		goto error_unlock;
> > > > +
> > > > +	for (i =3D 0; i < count; i++, offset +=3D 4)
> > > > +		*values++ =3D __raw_readl(ocotp_base + offset);
> > >=20
> > > The registers in the ocotp are 16 byte aligned. Does it really ma=
ke
> > > sense to provide a function allowing to read the gaps between the
> > > registers?
> > >=20
> > Good catch.  The count was added to ease the consecutive otp word
> > reading, as there is bank open/close cost for otp read.  What about
> > the following changes?
> >=20
> > int mxs_read_ocotp(unsigned offset, size_t otp_word_cnt, u32 *value=
s)
> > {
> > 	......
> >=20
> > 	for (i =3D 0; i < otp_word_cnt; i++, offset +=3D 0x10)
> > 		*values++ =3D __raw_readl(ocotp_base + offset);
> >=20
> > 	......
> > }
>=20
> I would rather make a function like this:
>=20
> static u32 ocotp[0x27];
>=20
> const u32 *mxs_get_ocotp(void)
> {
> 	static int once =3D 0;
>=20
> 	if (once)
> 		return ocotp
>=20
> 	/* bank open */
>=20
> 	for (i =3D 0; i < 0x27; i++)
> 		ocotp[i] =3D readl(ocotp_base + 0x20 + i * 0x10)
>=20
> 	/* bank_close */
>=20
> 	once =3D 1;
>=20
> 	return ocotp;
which is save on UP when it's not called from irq context.

Additionally I suggest a #define for 0x27 and 0x20.

Uwe

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
