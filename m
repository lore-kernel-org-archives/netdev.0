From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [RFC net-next 3/4] gianfar: Separate out the Rx and Tx
 coalescing functions
Date: Wed, 8 Aug 2012 11:44:55 -0400
Message-ID: <20120808154454.GA11043@windriver.com>
References: <1344428810-29923-1-git-send-email-claudiu.manoil@freescale.com>
 <1344428810-29923-2-git-send-email-claudiu.manoil@freescale.com>
 <1344428810-29923-3-git-send-email-claudiu.manoil@freescale.com>
 <1344428810-29923-4-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>
To: Claudiu Manoil <claudiu.manoil@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:48015 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932345Ab2HHPpA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Aug 2012 11:45:00 -0400
Content-Disposition: inline
In-Reply-To: <1344428810-29923-4-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[[RFC net-next 3/4] gianfar: Separate out the Rx and Tx coalescing functions] On 08/08/2012 (Wed 15:26) Claudiu Manoil wrote:

> Split the coalescing programming support by Rx and Tx h/w queues, in order to
> introduce a separate NAPI for the Tx confirmation path (next patch). This way,
> the Rx processing path will handle the coalescing settings for the Rx queues
> only, resp. the Tx confirmation processing path will handle the Tx queues.
> 
> Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
> ---
>  drivers/net/ethernet/freescale/gianfar.c |   36 +++++++++++++++++++++++------
>  1 files changed, 28 insertions(+), 8 deletions(-)
> 
> diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
> index ddd350a..919acb3 100644
> --- a/drivers/net/ethernet/freescale/gianfar.c
> +++ b/drivers/net/ethernet/freescale/gianfar.c
> @@ -1794,8 +1794,8 @@ void gfar_start(struct net_device *dev)
>  	dev->trans_start = jiffies; /* prevent tx timeout */
>  }
>  
> -void gfar_configure_coalescing(struct gfar_private *priv,
> -			       unsigned long tx_mask, unsigned long rx_mask)
> +static inline void gfar_configure_tx_coalescing(struct gfar_private *priv,

I believe the preference is to not specify inline when all the chunks in
play are present in the one C file -- i.e. let gcc figure it out.  Same
for the Rx instance below.

P.
--

> +						unsigned long mask)
>  {
>  	struct gfar __iomem *regs = priv->gfargrp[0].regs;
>  	u32 __iomem *baddr;
> @@ -1803,14 +1803,31 @@ void gfar_configure_coalescing(struct gfar_private *priv,
>  	if (priv->mode == MQ_MG_MODE) {
>  		int i;
>  		baddr = &regs->txic0;
> -		for_each_set_bit(i, &tx_mask, priv->num_tx_queues) {
> +		for_each_set_bit(i, &mask, priv->num_tx_queues) {
>  			gfar_write(baddr + i, 0);
>  			if (likely(priv->tx_queue[i]->txcoalescing))
>  				gfar_write(baddr + i, priv->tx_queue[i]->txic);
>  		}
> +	} else {
> +		/* Backward compatible case ---- even if we enable
> +		 * multiple queues, there's only single reg to program
> +		 */
> +		gfar_write(&regs->txic, 0);
> +		if (likely(priv->tx_queue[0]->txcoalescing))
> +			gfar_write(&regs->txic, priv->tx_queue[0]->txic);
> +	}
> +}
> +
> +static inline void gfar_configure_rx_coalescing(struct gfar_private *priv,
> +						unsigned long mask)
> +{
> +	struct gfar __iomem *regs = priv->gfargrp[0].regs;
> +	u32 __iomem *baddr;
>  
> +	if (priv->mode == MQ_MG_MODE) {
> +		int i;
>  		baddr = &regs->rxic0;
> -		for_each_set_bit(i, &rx_mask, priv->num_rx_queues) {
> +		for_each_set_bit(i, &mask, priv->num_rx_queues) {
>  			gfar_write(baddr + i, 0);
>  			if (likely(priv->rx_queue[i]->rxcoalescing))
>  				gfar_write(baddr + i, priv->rx_queue[i]->rxic);
> @@ -1819,16 +1836,19 @@ void gfar_configure_coalescing(struct gfar_private *priv,
>  		/* Backward compatible case ---- even if we enable
>  		 * multiple queues, there's only single reg to program
>  		 */
> -		gfar_write(&regs->txic, 0);
> -		if (likely(priv->tx_queue[0]->txcoalescing))
> -			gfar_write(&regs->txic, priv->tx_queue[0]->txic);
> -
>  		gfar_write(&regs->rxic, 0);
>  		if (likely(priv->rx_queue[0]->rxcoalescing))
>  			gfar_write(&regs->rxic, priv->rx_queue[0]->rxic);
>  	}
>  }
>  
> +void gfar_configure_coalescing(struct gfar_private *priv,
> +			       unsigned long tx_mask, unsigned long rx_mask)
> +{
> +	gfar_configure_tx_coalescing(priv, tx_mask);
> +	gfar_configure_rx_coalescing(priv, rx_mask);
> +}
> +
>  static int register_grp_irqs(struct gfar_priv_grp *grp)
>  {
>  	struct gfar_private *priv = grp->priv;
> -- 
> 1.6.6
> 
> 
