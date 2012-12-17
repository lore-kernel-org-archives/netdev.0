From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: Re: [PATCH 4/4] FEC: Add time stamping code and a PTP hardware clock
Date: Mon, 17 Dec 2012 10:13:45 +0100
Message-ID: <20121217091345.GA753@pengutronix.de>
References: <1351657531-25989-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lznua@gmail.com, richardcochran@gmail.com, shawn.guo@linaro.org,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	davem@davemloft.net
To: Frank Li <Frank.Li@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:35456 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750813Ab2LQJNx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Dec 2012 04:13:53 -0500
Content-Disposition: inline
In-Reply-To: <1351657531-25989-1-git-send-email-Frank.Li@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 31, 2012 at 12:25:31PM +0800, Frank Li wrote:
> This patch adds a driver for the FEC(MX6) that offers time
> stamping and a PTP haderware clock. Because FEC\ENET(MX6)
> hardware frequency adjustment is complex, we have implemented
> this in software by changing the multiplication factor of the
> timecounter.
> 
> Signed-off-by: Frank Li <Frank.Li@freescale.com>
> ---
>  drivers/net/ethernet/freescale/Kconfig   |    9 +
>  drivers/net/ethernet/freescale/Makefile  |    1 +
>  drivers/net/ethernet/freescale/fec.c     |   88 +++++++-
>  drivers/net/ethernet/freescale/fec.h     |   38 +++
>  drivers/net/ethernet/freescale/fec_ptp.c |  386 ++++++++++++++++++++++++++++++
>  5 files changed, 521 insertions(+), 1 deletions(-)
>  create mode 100644 drivers/net/ethernet/freescale/fec_ptp.c
> 
> diff --git a/drivers/net/ethernet/freescale/Kconfig b/drivers/net/ethernet/freescale/Kconfig
> index feff516..ff3be53 100644
> --- a/drivers/net/ethernet/freescale/Kconfig
> +++ b/drivers/net/ethernet/freescale/Kconfig
> @@ -92,4 +92,13 @@ config GIANFAR
>  	  This driver supports the Gigabit TSEC on the MPC83xx, MPC85xx,
>  	  and MPC86xx family of chips, and the FEC on the 8540.
>  
> +config FEC_PTP
> +	bool "PTP Hardware Clock (PHC)"
> +	depends on FEC
> +	select PPS
> +	select PTP_1588_CLOCK
> +	--help---
> +	  Say Y here if you want to use PTP Hardware Clock (PHC) in the
> +	  driver.  Only the basic clock operations have been implemented.
> +
>  endif # NET_VENDOR_FREESCALE
> diff --git a/drivers/net/ethernet/freescale/Makefile b/drivers/net/ethernet/freescale/Makefile
> index 3d1839a..d4d19b3 100644
> --- a/drivers/net/ethernet/freescale/Makefile
> +++ b/drivers/net/ethernet/freescale/Makefile
> @@ -3,6 +3,7 @@
>  #
>  
>  obj-$(CONFIG_FEC) += fec.o
> +obj-$(CONFIG_FEC_PTP) += fec_ptp.o
>  obj-$(CONFIG_FEC_MPC52xx) += fec_mpc52xx.o
>  ifeq ($(CONFIG_FEC_MPC52xx_MDIO),y)
>  	obj-$(CONFIG_FEC_MPC52xx) += fec_mpc52xx_phy.o
> diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
> index d0e1b33..2665162 100644
> --- a/drivers/net/ethernet/freescale/fec.c
> +++ b/drivers/net/ethernet/freescale/fec.c
> @@ -280,6 +280,17 @@ fec_enet_start_xmit(struct sk_buff *skb, struct net_device *ndev)
>  			| BD_ENET_TX_LAST | BD_ENET_TX_TC);
>  	bdp->cbd_sc = status;
>  
> +#ifdef CONFIG_FEC_PTP

This ifdef desert in the fec driver currently breaks all SoCs except
i.MX6 in the imx_v6_v7_defconfig.

Most of these could be fixed with something like if (fec_use_ptp(fep)),


>  #if defined(CONFIG_M523x) || defined(CONFIG_M527x) || defined(CONFIG_M528x) || \
>      defined(CONFIG_M520x) || defined(CONFIG_M532x) || \
>      defined(CONFIG_ARCH_MXC) || defined(CONFIG_SOC_IMX28)
> @@ -88,6 +94,13 @@ struct bufdesc {
>  	unsigned short cbd_datlen;	/* Data length */
>  	unsigned short cbd_sc;	/* Control and status info */
>  	unsigned long cbd_bufaddr;	/* Buffer address */
> +#ifdef CONFIG_FEC_PTP
> +	unsigned long cbd_esc;
> +	unsigned long cbd_prot;
> +	unsigned long cbd_bdu;
> +	unsigned long ts;
> +	unsigned short res0[4];
> +#endif
>  };

This one changes the layout of the hardware buffer description which is
not so easy to fix.

I don't know how to continue from here. Since the whole patch doesn't
seem to reviewed very much I tend to say we should revert it for now and
let Frank redo it for the next merge window.

Other opinions?

Sascha

-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
