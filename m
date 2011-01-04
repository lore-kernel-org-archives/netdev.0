From: Shawn Guo <shawn.guo@freescale.com>
Subject: Re: [PATCH v2 05/10] net/fec: add dual fec support for mx28
Date: Tue, 4 Jan 2011 22:13:09 +0800
Message-ID: <20110104141259.GA21274@freescale.com>
References: <1294133056-21195-1-git-send-email-shawn.guo@freescale.com>
 <1294133056-21195-6-git-send-email-shawn.guo@freescale.com>
 <20110104095916.GE2987@jasper.tkos.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <davem@davemloft.net>, <gerg@snapgear.com>, <eric@eukrea.com>,
	<bryan.wu@canonical.com>, <r64343@freescale.com>,
	<B32542@freescale.com>, <u.kleine-koenig@pengutronix.de>,
	<lw@karo-electronics.de>, <w.sang@pengutronix.de>,
	<s.hauer@pengutronix.de>, <netdev@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>
To: Baruch Siach <baruch@tkos.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe004.messaging.microsoft.com ([65.55.88.14]:40385 "EHLO
	TX2EHSOBE008.bigfish.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751547Ab1ADOLI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jan 2011 09:11:08 -0500
Received: from mail71-tx2 (localhost.localdomain [127.0.0.1])	by
 mail71-tx2-R.bigfish.com (Postfix) with ESMTP id 35DAC5E8411	for
 <netdev@vger.kernel.org>; Tue,  4 Jan 2011 14:11:07 +0000 (UTC)
Received: from TX2EHSMHS047.bigfish.com (unknown [10.9.14.247])	by
 mail71-tx2.bigfish.com (Postfix) with ESMTP id B39E216F8059	for
 <netdev@vger.kernel.org>; Tue,  4 Jan 2011 14:11:06 +0000 (UTC)
Received: from az33smr01.freescale.net (az33smr01.freescale.net
 [10.64.34.199])	by de01egw02.freescale.net (8.14.3/8.14.3) with ESMTP id
 p04EB4mc017167	for <netdev@vger.kernel.org>; Tue, 4 Jan 2011 07:11:05 -0700
 (MST)
Received: from ubuntu.localdomain (ubuntu-010192242196.ap.freescale.net
 [10.192.242.196])	by az33smr01.freescale.net (8.13.1/8.13.0) with ESMTP id
 p04EB3rj011789	for <netdev@vger.kernel.org>; Tue, 4 Jan 2011 08:11:03 -0600
 (CST)
Content-Disposition: inline
In-Reply-To: <20110104095916.GE2987@jasper.tkos.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Baruch,

On Tue, Jan 04, 2011 at 11:59:16AM +0200, Baruch Siach wrote:
> Hi Shawn,
> 
> On Tue, Jan 04, 2011 at 05:24:11PM +0800, Shawn Guo wrote:
> > This patch is to add mx28 dual fec support. Here are some key notes
> > for mx28 fec controller.
> > 
> >  - mx28 fec design made an assumption that it runs on a
> >    big-endian system, which is incorrect. As the result, the
> >    driver has to swap every frame going to and coming from
> >    the controller.
> >  - external phys can only be configured by fec0, which means
> >    fec1 can not work independently and both phys need to be
> >    configured by mii_bus attached on fec0.
> >  - mx28 fec reset will get mac address registers reset too.
> >  - MII/RMII mode and 10M/100M speed are configured differently
> >    from i.mx/mxs fec controller.
> >  - ETHER_EN bit must be set to get interrupt work.
> > 
> > Signed-off-by: Shawn Guo <shawn.guo@freescale.com>
> > ---
> > Changes for v2:
> >  - Use module parameter fec.macaddr over new kernel command line
> >    fec_mac to pass mac address
> 
> Since you introduce this new kernel command line parameter in patch #3 of this 
> series, why not just make it right in the first place? This should make both 
> patches smaller and easier for review.
> 
> >  - Update comment in fec_get_mac() to stop using confusing word
> >    "default"
> >  - Fix copyright breakage in fec.h
> 
> Ditto.
> 
Sorry for rushing to send the patch set out. All these updates
should happen on patch #3 than #5.  This is a serious problem,
and I will fix it soon and resend as v3.

> >  drivers/net/Kconfig |    7 ++-
> >  drivers/net/fec.c   |  139 ++++++++++++++++++++++++++++++++++++++++----------
> >  drivers/net/fec.h   |    5 +-
> >  include/linux/fec.h |    3 +-
> >  4 files changed, 120 insertions(+), 34 deletions(-)
> 
> [snip]
> 
> > diff --git a/drivers/net/fec.c b/drivers/net/fec.c
> > index f147508..b2b3e37 100644
> > --- a/drivers/net/fec.c
> > +++ b/drivers/net/fec.c
> > @@ -17,6 +17,8 @@
> >   *
> >   * Bug fixes and cleanup by Philippe De Muyter (phdm@macqel.be)
> >   * Copyright (c) 2004-2006 Macq Electronique SA.
> > + *
> > + * Copyright (C) 2010 Freescale Semiconductor, Inc.
> >   */
> >  
> >  #include <linux/module.h>
> > @@ -45,21 +47,34 @@
> >  
> >  #include <asm/cacheflush.h>
> >  
> > -#ifndef CONFIG_ARCH_MXC
> > +#if !defined(CONFIG_ARCH_MXC) && !defined(CONFIG_SOC_IMX28)
> >  #include <asm/coldfire.h>
> >  #include <asm/mcfsim.h>
> >  #endif
> >  
> >  #include "fec.h"
> >  
> > -#ifdef CONFIG_ARCH_MXC
> > -#include <mach/hardware.h>
> 
> Since you now remove mach/hardware.h for ARCH_MXC, does this build for all 
> i.MX variants?
> 
Did the test build for mx25, mx27, mx3 and mx51.

> > +#ifdef CONFIG_SOC_IMX28
> > +/*
> > + * mx28 does not have MIIGSK registers
> > + */
> > +#undef FEC_MIIGSK_ENR
> > +#include <mach/mxs.h>
> > +#else
> > +#define cpu_is_mx28()	(0)
> > +#endif
> 
> This breaks kernels for multiple archs (e.g. i.MX28 and i.MX25). Please use 
> run-time detection of CPU type, and do the MII/RMII etc. configuration 
> accordingly.
> 
I do not find a good way to detect cpu type.  Neither adding a new
platform data field nor using __machine_arch_type to enumerate all
mx28 based machine (though there is only one currently) seems to be
good for me.

I will try to manipulate some mx28 unique register to identify mx28
from other i.mx variants.  Hopefully, it will work.

Thanks for the comments.

-- 
Regards,
Shawn

