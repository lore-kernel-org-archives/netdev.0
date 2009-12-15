From: Greg Ungerer <gerg@snapgear.com>
Subject: Re: [PATCH 3/4] fec: add support for Freescale i.MX25 PDK (3DS)
Date: Tue, 15 Dec 2009 11:27:59 +1000
Message-ID: <4B26E61F.7030709@snapgear.com>
References: <cover.1260785451.git.baruch@tkos.co.il> <fb518184b206ec2727deda111cc5364134ace69a.1260785451.git.baruch@tkos.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Sascha Hauer <kernel@pengutronix.de>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Baruch Siach <baruch@tkos.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rex.securecomputing.com ([203.24.151.4]:39106 "EHLO
	cyberguard.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758413AbZLOB3L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Dec 2009 20:29:11 -0500
In-Reply-To: <fb518184b206ec2727deda111cc5364134ace69a.1260785451.git.baruch@tkos.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Baruch,

Baruch Siach wrote:
> The i.MX25 PDK uses RMII to communicate with its PHY. This patch adds the
> necessary bits to make the i.MX25 talk RMII.
> 
> Signed-off-by: Baruch Siach <baruch@tkos.co.il>
> ---
>  drivers/net/fec.c |   22 ++++++++++++++++++++++
>  drivers/net/fec.h |    2 ++
>  2 files changed, 24 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/fec.c b/drivers/net/fec.c
> index 16a1d58..65c43d3 100644
> --- a/drivers/net/fec.c
> +++ b/drivers/net/fec.c
> @@ -51,6 +51,7 @@
>  #include "fec.h"
>  
>  #ifdef CONFIG_ARCH_MXC
> +#include <asm/mach-types.h>
>  #include <mach/hardware.h>
>  #define FEC_ALIGNMENT	0xf
>  #else
> @@ -1722,6 +1723,25 @@ static int fec_enet_init(struct net_device *dev, int index)
>  	return 0;
>  }
>  
> +static void fec_localhw_setup(struct net_device *dev)
> +{
> +	struct fec_enet_private *fep = netdev_priv(dev);
> +
> +	if (!machine_is_mx25_3ds())
> +		return;
> +
> +	/* disable the gasket and wait */
> +	writel(0, fep->hwp + FEC_MIIGSK_ENR);
> +	while (readl(fep->hwp + FEC_MIIGSK_ENR) & 4)
> +		udelay(1);
> +
> +	/* configure the gasket for RMII, 50 MHz, no loopback, no echo */
> +	writel(1, fep->hwp + FEC_MIIGSK_CFGR);
> +
> +	/* re-enable the gasket */
> +	writel(2, fep->hwp + FEC_MIIGSK_ENR);
                              ^^^^^^^^^^^^^^

> +}

This will not compile for some CPU types that use this driver.


> +
>  /* This function is called to start or restart the FEC during a link
>   * change.  This only happens when switching between half and full
>   * duplex.
> @@ -1810,6 +1830,8 @@ fec_restart(struct net_device *dev, int duplex)
>  	/* Set MII speed */
>  	writel(fep->phy_speed, fep->hwp + FEC_MII_SPEED);
>  
> +	fec_localhw_setup(dev);
> +
>  	/* And last, enable the transmit and receive processing */
>  	writel(2, fep->hwp + FEC_ECNTRL);
>  	writel(0, fep->hwp + FEC_R_DES_ACTIVE);
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

These are defined in a conditional section for certain CPU types.
There is no definitions for the other "#else" section here.

Regards
Greg


-- 
------------------------------------------------------------------------
Greg Ungerer  --  Principal Engineer        EMAIL:     gerg@snapgear.com
SnapGear Group, McAfee                      PHONE:       +61 7 3435 2888
8 Gardner Close                             FAX:         +61 7 3217 5323
Milton, QLD, 4064, Australia                WEB: http://www.SnapGear.com
