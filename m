From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: Re: [PATCH 1/1 net-next] NET: FEC: dynamtic check DMA desc buff type
Date: Thu, 27 Dec 2012 11:35:00 +0100
Message-ID: <20121227103500.GU26326@pengutronix.de>
References: <1356599447-5698-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lznuaa@gmail.com, davem@davemloft.net,
	linux-arm-kernel@lists.infradead.org, shawn.guo@linaro.org,
	netdev@vger.kernel.org
To: Frank Li <Frank.Li@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:46981 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751673Ab2L0KfL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Dec 2012 05:35:11 -0500
Content-Disposition: inline
In-Reply-To: <1356599447-5698-1-git-send-email-Frank.Li@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 27, 2012 at 05:10:47PM +0800, Frank Li wrote:
> MX6 and mx28 support enhanced DMA descript buff to support 1588
> ptp. But MX25, MX3x, MX5x can't support enhanced DMA descript buff.
> Check fec type and choose correct DAM descript buff type.
> 
> Signed-off-by: Frank Li <Frank.Li@freescale.com>

Please provide a series that gets rid of CONFIG_FEC_PTP. This patch here
might be a first step to it, but until it's complete and we can have a
look at the end result: No.

> ---
>  drivers/net/ethernet/freescale/Kconfig |    2 +-
>  drivers/net/ethernet/freescale/fec.c   |  155 ++++++++++++++++++++++++--------
>  drivers/net/ethernet/freescale/fec.h   |    8 ++-
>  3 files changed, 126 insertions(+), 39 deletions(-)
> 
> diff --git a/drivers/net/ethernet/freescale/Kconfig b/drivers/net/ethernet/freescale/Kconfig
> index ec490d7..d1edb2e 100644
> --- a/drivers/net/ethernet/freescale/Kconfig
> +++ b/drivers/net/ethernet/freescale/Kconfig
> @@ -94,7 +94,7 @@ config GIANFAR
>  
>  config FEC_PTP
>  	bool "PTP Hardware Clock (PHC)"
> -	depends on FEC && ARCH_MXC && !SOC_IMX25 && !SOC_IMX27 && !SOC_IMX35 && !SOC_IMX5
> +	depends on FEC && ARCH_MXC
>  	select PTP_1588_CLOCK
>  	--help---
>  	  Say Y here if you want to use PTP Hardware Clock (PHC) in the
> diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
> index 0704bca..21f385d 100644
> --- a/drivers/net/ethernet/freescale/fec.c
> +++ b/drivers/net/ethernet/freescale/fec.c
> @@ -76,6 +76,8 @@
>  #define FEC_QUIRK_USE_GASKET		(1 << 2)
>  /* Controller has GBIT support */
>  #define FEC_QUIRK_HAS_GBIT		(1 << 3)
> +/* Controller has extend desc buffer */
> +#define FEC_QUICK_HAS_BUFDESC_EX	(1 << 4)

It's 'quirk', not 'quick'

>  
>  static struct platform_device_id fec_devtype[] = {
>  	{
> @@ -93,7 +95,8 @@ static struct platform_device_id fec_devtype[] = {
>  		.driver_data = FEC_QUIRK_ENET_MAC | FEC_QUIRK_SWAP_FRAME,
>  	}, {
>  		.name = "imx6q-fec",
> -		.driver_data = FEC_QUIRK_ENET_MAC | FEC_QUIRK_HAS_GBIT,
> +		.driver_data = FEC_QUIRK_ENET_MAC | FEC_QUIRK_HAS_GBIT |
> +				FEC_QUICK_HAS_BUFDESC_EX,
>  	}, {
>  		/* sentinel */
>  	}
> @@ -117,7 +120,9 @@ static const struct of_device_id fec_dt_ids[] = {
>  MODULE_DEVICE_TABLE(of, fec_dt_ids);
>  
>  static unsigned char macaddr[ETH_ALEN];
> +static int fec_ptp_enable = 1;
>  module_param_array(macaddr, byte, NULL, 0);
> +module_param(fec_ptp_enable, int, 1);
>  MODULE_PARM_DESC(macaddr, "FEC Ethernet MAC address");

The 'fec_ptp_enable' shouldn't be weaved into the mac address. Use a
separate block of code for this.
Also, this shouldn't be here at all. If you want to make this
configurable via kernel commandline, then this should be a separate
patch so that it can be discussed separately. Also you should provide a
description *why* you think this is necessary.

>  
>  #if defined(CONFIG_M5272)
> @@ -144,6 +149,12 @@ MODULE_PARM_DESC(macaddr, "FEC Ethernet MAC address");
>  #error "FEC: descriptor ring size constants too large"
>  #endif
>  
> +#ifdef CONFIG_FEC_PTP
> +#if (((RX_RING_SIZE + TX_RING_SIZE) * 32) > PAGE_SIZE)
> +#error "FEC: descriptor ring size constants too large"
> +#endif
> +#endif
> +
>  /* Interrupt events/masks. */
>  #define FEC_ENET_HBERR	((uint)0x80000000)	/* Heartbeat error */
>  #define FEC_ENET_BABR	((uint)0x40000000)	/* Babbling receiver */
> @@ -192,6 +203,36 @@ MODULE_PARM_DESC(macaddr, "FEC Ethernet MAC address");
>  
>  static int mii_cnt;
>  
> +#ifdef CONFIG_FEC_PTP
> +static struct bufdesc * get_nextdesc(struct bufdesc * bdp, int is_ex)

driver specific functions should always have a driver specific prefix.


This patch has coding style issues. Please run through checkpatch.

Sascha


-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
