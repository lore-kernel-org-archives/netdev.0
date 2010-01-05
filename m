From: Baruch Siach <baruch@tkos.co.il>
Subject: Re: [PATCH 3/4] fec: add support for Freescale i.MX25 PDK (3DS)
Date: Tue, 5 Jan 2010 10:24:29 +0200
Message-ID: <20100105082429.GB25571@tarshish>
References: <cover.1260785451.git.baruch@tkos.co.il>
 <fb518184b206ec2727deda111cc5364134ace69a.1260785451.git.baruch@tkos.co.il>
 <20091214103348.GV15126@pengutronix.de>
 <20091215083142.GB18290@jasper.tkos.co.il>
 <4B277878.1050804@snapgear.com>
 <20091215201109.GA2621@tarshish>
 <4B282644.8030104@snapgear.com>
 <20091216063402.GA13160@jasper.tkos.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Sascha Hauer <s.hauer@pengutronix.de>,
	linux-arm-kernel@lists.infradead.org
To: Greg Ungerer <gerg@snapgear.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tango.tkos.co.il ([62.219.50.35]:36947 "EHLO tango.tkos.co.il"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753157Ab0AEI0N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jan 2010 03:26:13 -0500
Content-Disposition: inline
In-Reply-To: <20091216063402.GA13160@jasper.tkos.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 16, 2009 at 08:34:06AM +0200, Baruch Siach wrote:
> Hi Greg,

[snip]

> Thanks. The updated patch below.

Ping?

How should take care of this?

The platform code for i.MX25 PDK is going via Sascha's tree, and it depends on 
this patch to compile.

baruch

> From 2d0751f868519978603b16baa197bfb9f9ec9e2e Mon Sep 17 00:00:00 2001
> Message-Id: <2d0751f868519978603b16baa197bfb9f9ec9e2e.1260945080.git.baruch@tkos.co.il>
> From: Baruch Siach <baruch@tkos.co.il>
> Date: Mon, 14 Dec 2009 10:36:50 +0200
> Subject: [PATCH] fec: add support for PHY interface platform data
> 
> The i.MX25 PDK uses RMII to communicate with its PHY. This patch adds the
> ability to configure RMII, based on platform data.
> 
> Signed-off-by: Baruch Siach <baruch@tkos.co.il>
> Acked-by:  Greg Ungerer <gerg@uclinux.org>
> ---
>  drivers/net/fec.c   |   22 ++++++++++++++++++++++
>  drivers/net/fec.h   |    2 ++
>  include/linux/fec.h |   21 +++++++++++++++++++++
>  3 files changed, 45 insertions(+), 0 deletions(-)
>  create mode 100644 include/linux/fec.h
> 
> diff --git a/drivers/net/fec.c b/drivers/net/fec.c
> index 16a1d58..a7cfe0d 100644
> --- a/drivers/net/fec.c
> +++ b/drivers/net/fec.c
> @@ -40,6 +40,7 @@
>  #include <linux/irq.h>
>  #include <linux/clk.h>
>  #include <linux/platform_device.h>
> +#include <linux/fec.h>
>  
>  #include <asm/cacheflush.h>
>  
> @@ -198,6 +199,7 @@ struct fec_enet_private {
>  	uint	phy_speed;
>  	phy_info_t const	*phy;
>  	struct work_struct phy_task;
> +	phy_interface_t	phy_interface;
>  
>  	uint	sequence_done;
>  	uint	mii_phy_task_queued;
> @@ -1810,6 +1812,21 @@ fec_restart(struct net_device *dev, int duplex)
>  	/* Set MII speed */
>  	writel(fep->phy_speed, fep->hwp + FEC_MII_SPEED);
>  
> +#ifdef FEC_MIIGSK_ENR
> +	if (fep->phy_interface == PHY_INTERFACE_MODE_RMII) {
> +		/* disable the gasket and wait */
> +		writel(0, fep->hwp + FEC_MIIGSK_ENR);
> +		while (readl(fep->hwp + FEC_MIIGSK_ENR) & 4)
> +			udelay(1);
> +
> +		/* configure the gasket: RMII, 50 MHz, no loopback, no echo */
> +		writel(1, fep->hwp + FEC_MIIGSK_CFGR);
> +
> +		/* re-enable the gasket */
> +		writel(2, fep->hwp + FEC_MIIGSK_ENR);
> +	}
> +#endif
> +
>  	/* And last, enable the transmit and receive processing */
>  	writel(2, fep->hwp + FEC_ECNTRL);
>  	writel(0, fep->hwp + FEC_R_DES_ACTIVE);
> @@ -1847,6 +1864,7 @@ static int __devinit
>  fec_probe(struct platform_device *pdev)
>  {
>  	struct fec_enet_private *fep;
> +	struct fec_platform_data *pdata;
>  	struct net_device *ndev;
>  	int i, irq, ret = 0;
>  	struct resource *r;
> @@ -1879,6 +1897,10 @@ fec_probe(struct platform_device *pdev)
>  
>  	platform_set_drvdata(pdev, ndev);
>  
> +	pdata = pdev->dev.platform_data;
> +	if (pdata)
> +		fep->phy_interface = pdata->phy;
> +
>  	/* This device has up to three irqs on some platforms */
>  	for (i = 0; i < 3; i++) {
>  		irq = platform_get_irq(pdev, i);
> diff --git a/drivers/net/fec.h b/drivers/net/fec.h
> index cc47f3f..2c48b25 100644
> --- a/drivers/net/fec.h
> +++ b/drivers/net/fec.h
> @@ -43,6 +43,8 @@
>  #define FEC_R_DES_START		0x180 /* Receive descriptor ring */
>  #define FEC_X_DES_START		0x184 /* Transmit descriptor ring */
>  #define FEC_R_BUFF_SIZE		0x188 /* Maximum receive buff size */
> +#define FEC_MIIGSK_CFGR		0x300 /* MIIGSK Configuration reg */
> +#define FEC_MIIGSK_ENR		0x308 /* MIIGSK Enable reg */
>  
>  #else
>  
> diff --git a/include/linux/fec.h b/include/linux/fec.h
> new file mode 100644
> index 0000000..5d3523d
> --- /dev/null
> +++ b/include/linux/fec.h
> @@ -0,0 +1,21 @@
> +/* include/linux/fec.h
> + *
> + * Copyright (c) 2009 Orex Computed Radiography
> + *   Baruch Siach <baruch@tkos.co.il>
> + *
> + * Header file for the FEC platform data
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License version 2 as
> + * published by the Free Software Foundation.
> + */
> +#ifndef __LINUX_FEC_H__
> +#define __LINUX_FEC_H__
> +
> +#include <linux/phy.h>
> +
> +struct fec_platform_data {
> +	phy_interface_t phy;
> +};
> +
> +#endif
> -- 
> 1.6.5
> 
> 
> -- 
>                                                      ~. .~   Tk Open Systems
> =}------------------------------------------------ooO--U--Ooo------------{=
>    - baruch@tkos.co.il - tel: +972.2.679.5364, http://www.tkos.co.il -
> 
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel

-- 
                                                     ~. .~   Tk Open Systems
=}------------------------------------------------ooO--U--Ooo------------{=
   - baruch@tkos.co.il - tel: +972.2.679.5364, http://www.tkos.co.il -
