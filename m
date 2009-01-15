From: Greg Ungerer <gerg@snapgear.com>
Subject: Re: [PATCH] fec: use dma_alloc_coherent for descriptor ring
Date: Thu, 15 Jan 2009 15:20:17 +1000
Message-ID: <496EC791.10209@snapgear.com>
References: <1231949353-29630-1-git-send-email-s.hauer@pengutronix.de> <1231949353-29630-2-git-send-email-s.hauer@pengutronix.de> <1231949353-29630-3-git-send-email-s.hauer@pengutronix.de> <1231949353-29630-4-git-send-email-s.hauer@pengutronix.de> <1231949353-29630-5-git-send-email-s.hauer@pengutronix.de> <1231949353-29630-6-git-send-email-s.hauer@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Sebastian Siewior <bigeasy@linutronix.de>
To: Sascha Hauer <s.hauer@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rex.securecomputing.com ([203.24.151.4]:52003 "EHLO
	cyberguard.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750892AbZAOFUU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2009 00:20:20 -0500
In-Reply-To: <1231949353-29630-6-git-send-email-s.hauer@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sascha,

Sascha Hauer wrote:
> Signed-off-by: Sascha Hauer <s.hauer@pengutronix.de>
> ---

I found a problem in the ColdFire ZONE_DMA setup that was
causing this patch to break. Fixed that now, and it is
working fine.

Acked-by:  Greg Ungerer <gerg@uclinux.org>

Regards
Greg


>  drivers/net/fec.c |   11 ++++++-----
>  1 files changed, 6 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/net/fec.c b/drivers/net/fec.c
> index 29df0df..81c8e11 100644
> --- a/drivers/net/fec.c
> +++ b/drivers/net/fec.c
> @@ -184,6 +184,7 @@ struct fec_enet_private {
>  
>  	/* CPM dual port RAM relative addresses.
>  	*/
> +	dma_addr_t	bd_dma;
>  	cbd_t	*rx_bd_base;		/* Address of Rx and Tx buffers. */
>  	cbd_t	*tx_bd_base;
>  	cbd_t	*cur_rx, *cur_tx;		/* The next free ring entry */
> @@ -2105,7 +2106,7 @@ int __init fec_enet_init(struct net_device *dev)
>  
>  	/* Allocate memory for buffer descriptors.
>  	*/
> -	mem_addr = __get_free_page(GFP_KERNEL);
> +	mem_addr = (unsigned long)dma_alloc_coherent(NULL, PAGE_SIZE, &fep->bd_dma, GFP_KERNEL);
>  	if (mem_addr == 0) {
>  		printk("FEC: allocate descriptor memory failed?\n");
>  		return -ENOMEM;
> @@ -2200,8 +2201,8 @@ int __init fec_enet_init(struct net_device *dev)
>  
>  	/* Set receive and transmit descriptor base.
>  	*/
> -	fecp->fec_r_des_start = __pa((uint)(fep->rx_bd_base));
> -	fecp->fec_x_des_start = __pa((uint)(fep->tx_bd_base));
> +	fecp->fec_r_des_start = fep->bd_dma;
> +	fecp->fec_x_des_start = (unsigned long)fep->bd_dma + sizeof(cbd_t) * RX_RING_SIZE;
>  
>  	/* Install our interrupt handlers. This varies depending on
>  	 * the architecture.
> @@ -2289,8 +2290,8 @@ fec_restart(struct net_device *dev, int duplex)
>  
>  	/* Set receive and transmit descriptor base.
>  	*/
> -	fecp->fec_r_des_start = __pa((uint)(fep->rx_bd_base));
> -	fecp->fec_x_des_start = __pa((uint)(fep->tx_bd_base));
> +	fecp->fec_r_des_start = fep->bd_dma;
> +	fecp->fec_x_des_start = (unsigned long)fep->bd_dma + sizeof(cbd_t) * RX_RING_SIZE;
>  
>  	fep->dirty_tx = fep->cur_tx = fep->tx_bd_base;
>  	fep->cur_rx = fep->rx_bd_base;

-- 
------------------------------------------------------------------------
Greg Ungerer  --  Principal Engineer        EMAIL:     gerg@snapgear.com
SnapGear, a McAfee Company                  PHONE:       +61 7 3435 2888
825 Stanley St,                             FAX:         +61 7 3891 3630
Woolloongabba, QLD, 4102, Australia         WEB: http://www.SnapGear.com
