From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH] Update ucc_geth.c for new workqueue structure
Date: Mon, 18 Dec 2006 10:23:30 -0600
Message-ID: <95B08418-3C70-4985-B26C-DDE1400ABADA@kernel.crashing.org>
References: <11660513361799-git-send-email-timur@freescale.com> <11660513372040-git-send-email-timur@freescale.com> <11660513393811-git-send-email-timur@freescale.com>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>, Timur Tabi <timur@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nommos.sslcatacombnetworking.com ([67.18.224.114]:41818 "EHLO
	nommos.sslcatacombnetworking.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754221AbWLRQX3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Dec 2006 11:23:29 -0500
In-Reply-To: <11660513393811-git-send-email-timur@freescale.com>
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff,

Can you pickup this patch for 2.6.20 as it fixes a compile issue due  
to the workqueue changes.

- kumar

On Dec 13, 2006, at 5:08 PM, timur@freescale.com wrote:

> From: Timur Tabi <timur@freescale.com>
>
> The workqueue interface changed with David Howell's patch on  
> 11/22/2006
> (SHA 65f27f38446e1976cc98fd3004b110fedcddd189).  Several drivers were
> updated with that patch to handle the new interface, but ucc_geth.c
> was not one of them.  This patch updates ucc_geth.c to support the new
> model.
>
> A compiler warning in set_mac_addr() was also fixed.
>
> Signed-off-by: Timur Tabi <timur@freescale.com>
> Signed-off-by: Kumar Gala <galak@kernel.crashing.org>
>
> ---
>  drivers/net/ucc_geth.c |   12 +++++++-----
>  1 files changed, 7 insertions(+), 5 deletions(-)
>
> diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
> index 1f05511..d33bb0c 100644
> --- a/drivers/net/ucc_geth.c
> +++ b/drivers/net/ucc_geth.c
> @@ -29,6 +29,7 @@
>  #include <linux/fsl_devices.h>
>  #include <linux/ethtool.h>
>  #include <linux/mii.h>
> +#include <linux/workqueue.h>
>
>  #include <asm/of_platform.h>
>  #include <asm/uaccess.h>
> @@ -472,7 +473,7 @@ static void put_enet_addr_container(stru
>  	kfree(enet_addr_cont);
>  }
>
> -static int set_mac_addr(__be16 __iomem *reg, u8 *mac)
> +static void set_mac_addr(__be16 __iomem *reg, u8 *mac)
>  {
>  	out_be16(&reg[0], ((u16)mac[5] << 8) | mac[4]);
>  	out_be16(&reg[1], ((u16)mac[3] << 8) | mac[2]);
> @@ -3918,10 +3919,11 @@ static irqreturn_t phy_interrupt(int irq
>  }
>
>  /* Scheduled by the phy_interrupt/timer to handle PHY changes */
> -static void ugeth_phy_change(void *data)
> +static void ugeth_phy_change(struct work_struct *work)
>  {
> -	struct net_device *dev = (struct net_device *)data;
> -	struct ucc_geth_private *ugeth = netdev_priv(dev);
> +	struct ucc_geth_private *ugeth =
> +		container_of(work, struct ucc_geth_private, tq);
> +	struct net_device *dev = ugeth->dev;
>  	struct ucc_geth *ug_regs;
>  	int result = 0;
>
> @@ -4078,7 +4080,7 @@ static int ucc_geth_open(struct net_devi
>  #endif				/* CONFIG_UGETH_NAPI */
>
>  	/* Set up the PHY change work queue */
> -	INIT_WORK(&ugeth->tq, ugeth_phy_change, dev);
> +	INIT_WORK(&ugeth->tq, ugeth_phy_change);
>
>  	init_timer(&ugeth->phy_info_timer);
>  	ugeth->phy_info_timer.function = &ugeth_phy_startup_timer;
> -- 
> 1.4.4
>
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

