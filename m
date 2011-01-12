From: Shawn Guo <shawn.guo@freescale.com>
Subject: Re: [PATCH v4 08/10] ARM: mxs: add ocotp read function
Date: Wed, 12 Jan 2011 14:47:12 +0800
Message-ID: <20110112064711.GG2888@freescale.com>
References: <1294297998-26930-1-git-send-email-shawn.guo@freescale.com>
 <1294297998-26930-9-git-send-email-shawn.guo@freescale.com>
 <20110111133137.GS12078@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <davem@davemloft.net>, <gerg@snapgear.com>, <baruch@tkos.co.il>,
	<eric@eukrea.com>, <bryan.wu@canonical.com>,
	<r64343@freescale.com>, <B32542@freescale.com>,
	<u.kleine-koenig@pengutronix.de>, <lw@karo-electronics.de>,
	<w.sang@pengutronix.de>, <jamie@jamieiles.com>,
	<jamie@shareable.org>, <netdev@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>
To: Sascha Hauer <s.hauer@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from am1ehsobe001.messaging.microsoft.com ([213.199.154.204]:6254
	"EHLO AM1EHSOBE001.bigfish.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750836Ab1ALGog (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jan 2011 01:44:36 -0500
Received: from mail77-am1 (localhost.localdomain [127.0.0.1])	by
 mail77-am1-R.bigfish.com (Postfix) with ESMTP id C2D681770566	for
 <netdev@vger.kernel.org>; Wed, 12 Jan 2011 06:44:34 +0000 (UTC)
Received: from AM1EHSMHS012.bigfish.com (unknown [10.3.201.247])	by
 mail77-am1.bigfish.com (Postfix) with ESMTP id 4D0B28A804E	for
 <netdev@vger.kernel.org>; Wed, 12 Jan 2011 06:44:34 +0000 (UTC)
Received: from de01smr02.am.mot.com (de01smr02.freescale.net [10.208.0.151])
	by az33egw02.freescale.net (8.14.3/8.14.3) with ESMTP id p0C6iOI8010825	for
 <netdev@vger.kernel.org>; Tue, 11 Jan 2011 23:44:24 -0700 (MST)
Received: from ubuntu.localdomain (ubuntu-010192242196.ap.freescale.net
 [10.192.242.196])	by de01smr02.am.mot.com (8.13.1/8.13.0) with ESMTP id
 p0C6iMbN016765	for <netdev@vger.kernel.org>; Wed, 12 Jan 2011 00:44:22 -0600
 (CST)
Content-Disposition: inline
In-Reply-To: <20110111133137.GS12078@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sascha,

On Tue, Jan 11, 2011 at 02:31:37PM +0100, Sascha Hauer wrote:
> On Thu, Jan 06, 2011 at 03:13:16PM +0800, Shawn Guo wrote:
> > Signed-off-by: Shawn Guo <shawn.guo@freescale.com>
> > ---
> > Changes for v4:
> >  - Call cpu_relax() during polling
> > 
> > Changes for v2:
> >  - Add mutex locking for mxs_read_ocotp()
> >  - Use type size_t for count and i
> >  - Add comment for clk_enable/disable skipping
> >  - Add ERROR bit clearing and polling step
> > 
> >  arch/arm/mach-mxs/Makefile              |    2 +-
> >  arch/arm/mach-mxs/include/mach/common.h |    1 +
> >  arch/arm/mach-mxs/ocotp.c               |   79 +++++++++++++++++++++++++++++++
> >  3 files changed, 81 insertions(+), 1 deletions(-)
> >  create mode 100644 arch/arm/mach-mxs/ocotp.c
> > 
> > diff --git a/arch/arm/mach-mxs/Makefile b/arch/arm/mach-mxs/Makefile
> > index 39d3f9c..f23ebbd 100644
> > --- a/arch/arm/mach-mxs/Makefile
> > +++ b/arch/arm/mach-mxs/Makefile
> > @@ -1,5 +1,5 @@
> >  # Common support
> > -obj-y := clock.o devices.o gpio.o icoll.o iomux.o system.o timer.o
> > +obj-y := clock.o devices.o gpio.o icoll.o iomux.o ocotp.o system.o timer.o
> >  
> >  obj-$(CONFIG_SOC_IMX23) += clock-mx23.o mm-mx23.o
> >  obj-$(CONFIG_SOC_IMX28) += clock-mx28.o mm-mx28.o
> > diff --git a/arch/arm/mach-mxs/include/mach/common.h b/arch/arm/mach-mxs/include/mach/common.h
> > index 59133eb..cf02552 100644
> > --- a/arch/arm/mach-mxs/include/mach/common.h
> > +++ b/arch/arm/mach-mxs/include/mach/common.h
> > @@ -13,6 +13,7 @@
> >  
> >  struct clk;
> >  
> > +extern int mxs_read_ocotp(int offset, int count, u32 *values);
> >  extern int mxs_reset_block(void __iomem *);
> >  extern void mxs_timer_init(struct clk *, int);
> >  
> > diff --git a/arch/arm/mach-mxs/ocotp.c b/arch/arm/mach-mxs/ocotp.c
> > new file mode 100644
> > index 0000000..e2d39aa
> > --- /dev/null
> > +++ b/arch/arm/mach-mxs/ocotp.c
> > @@ -0,0 +1,79 @@
> > +/*
> > + * Copyright 2010 Freescale Semiconductor, Inc. All Rights Reserved.
> > + *
> > + * This program is free software; you can redistribute it and/or modify
> > + * it under the terms of the GNU General Public License as published by
> > + * the Free Software Foundation; either version 2 of the License, or
> > + * (at your option) any later version.
> > + *
> > + * This program is distributed in the hope that it will be useful,
> > + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> > + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> > + * GNU General Public License for more details.
> > + */
> > +
> > +#include <linux/delay.h>
> > +#include <linux/err.h>
> > +#include <linux/mutex.h>
> > +
> > +#include <mach/mxs.h>
> > +
> > +#define BM_OCOTP_CTRL_BUSY		(1 << 8)
> > +#define BM_OCOTP_CTRL_ERROR		(1 << 9)
> > +#define BM_OCOTP_CTRL_RD_BANK_OPEN	(1 << 12)
> > +
> > +static DEFINE_MUTEX(ocotp_mutex);
> > +
> > +int mxs_read_ocotp(unsigned offset, size_t count, u32 *values)
> > +{
> > +	void __iomem *ocotp_base = MXS_IO_ADDRESS(MXS_OCOTP_BASE_ADDR);
> > +	int timeout = 0x400;
> > +	size_t i;
> > +
> > +	mutex_lock(&ocotp_mutex);
> > +
> > +	/*
> > +	 * clk_enable(hbus_clk) for ocotp can be skipped
> > +	 * as it must be on when system is running.
> > +	 */
> > +
> > +	/* try to clear ERROR bit */
> > +	__mxs_clrl(BM_OCOTP_CTRL_ERROR, ocotp_base);
> 
> This operation does not try to clear the error bit but actually clears
> it...
> 
> > +
> > +	/* check both BUSY and ERROR cleared */
> > +	while ((__raw_readl(ocotp_base) &
> > +		(BM_OCOTP_CTRL_BUSY | BM_OCOTP_CTRL_ERROR)) && --timeout)
> > +		cpu_relax();
> 
> ...which means you do not have to poll the error bit here...
> 
> > +
> > +	if (unlikely(!timeout))
> > +		goto error_unlock;
> > +
> > +	/* open OCOTP banks for read */
> > +	__mxs_setl(BM_OCOTP_CTRL_RD_BANK_OPEN, ocotp_base);
> > +
> > +	/* approximately wait 32 hclk cycles */
> > +	udelay(1);
> > +
> > +	/* poll BUSY bit becoming cleared */
> > +	timeout = 0x400;
> > +	while ((__raw_readl(ocotp_base) & BM_OCOTP_CTRL_BUSY) && --timeout)
> > +		cpu_relax();
> 
> ...which means you can factor out a ocotp_wait_busy function and let the
> code speak instead of the comments.
> 
> > +
> > +	if (unlikely(!timeout))
> > +		goto error_unlock;
> > +
> > +	for (i = 0; i < count; i++, offset += 4)
> > +		*values++ = __raw_readl(ocotp_base + offset);
> 
> The registers in the ocotp are 16 byte aligned. Does it really make
> sense to provide a function allowing to read the gaps between the
> registers?
> 
Good catch.  The count was added to ease the consecutive otp word
reading, as there is bank open/close cost for otp read.  What about
the following changes?

int mxs_read_ocotp(unsigned offset, size_t otp_word_cnt, u32 *values)
{
	......

	for (i = 0; i < otp_word_cnt; i++, offset += 0x10)
		*values++ = __raw_readl(ocotp_base + offset);

	......
}


-- 
Regards,
Shawn

