From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v3 06/11] net: calxedaxgmac: fix race with tx queue
 stop/wake
Date: Fri, 30 Aug 2013 23:57:42 +0100
Message-ID: <1377903462.2552.43.camel@deadeye.wl.decadent.org.uk>
References: <1377899369-23252-1-git-send-email-robherring2@gmail.com>
	 <1377899369-23252-6-git-send-email-robherring2@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	"Rob Herring" <rob.herring@calxeda.com>
To: Rob Herring <robherring2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:22073 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754071Ab3H3W5r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Aug 2013 18:57:47 -0400
In-Reply-To: <1377899369-23252-6-git-send-email-robherring2@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-08-30 at 16:49 -0500, Rob Herring wrote:
> From: Rob Herring <rob.herring@calxeda.com>
> 
> Since the xgmac transmit start and completion work locklessly, it is
> possible for xgmac_xmit to stop the tx queue after the xgmac_tx_complete
> has run resulting in the tx queue never being woken up. Fix this by
> ensuring that ring buffer index updates are visible and recheck the ring
> space after stopping the queue. Also fix an off-by-one bug where we need
> to stop the queue when the ring buffer space is equal to MAX_SKB_FRAGS.
> 
> The implementation used here was copied from
> drivers/net/ethernet/broadcom/tg3.c.
> 
> Signed-off-by: Rob Herring <rob.herring@calxeda.com>

Reviewed-by: Ben Hutchings <bhutchings@solarflare.com>

> ---
> v3:
> - Fix off-by-one bug in queue stopping
> 
> v2:
> - drop netif_tx_lock
> - use netif_start_queue instead of netif_wake_queue
> 
>  drivers/net/ethernet/calxeda/xgmac.c | 20 +++++++++++++++-----
>  1 file changed, 15 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/net/ethernet/calxeda/xgmac.c b/drivers/net/ethernet/calxeda/xgmac.c
> index f630855..5d0b61a 100644
> --- a/drivers/net/ethernet/calxeda/xgmac.c
> +++ b/drivers/net/ethernet/calxeda/xgmac.c
> @@ -410,6 +410,9 @@ struct xgmac_priv {
>  #define dma_ring_space(h, t, s)	CIRC_SPACE(h, t, s)
>  #define dma_ring_cnt(h, t, s)	CIRC_CNT(h, t, s)
>  
> +#define tx_dma_ring_space(p) \
> +	dma_ring_space((p)->tx_head, (p)->tx_tail, DMA_TX_RING_SZ)
> +
>  /* XGMAC Descriptor Access Helpers */
>  static inline void desc_set_buf_len(struct xgmac_dma_desc *p, u32 buf_sz)
>  {
> @@ -886,8 +889,10 @@ static void xgmac_tx_complete(struct xgmac_priv *priv)
>  		priv->tx_tail = dma_ring_incr(entry, DMA_TX_RING_SZ);
>  	}
>  
> -	if (dma_ring_space(priv->tx_head, priv->tx_tail, DMA_TX_RING_SZ) >
> -	    MAX_SKB_FRAGS)
> +	/* Ensure tx_tail is visible to xgmac_xmit */
> +	smp_mb();
> +	if (unlikely(netif_queue_stopped(priv->dev) &&
> +	    (tx_dma_ring_space(priv) > MAX_SKB_FRAGS)))
>  		netif_wake_queue(priv->dev);
>  }
>  
> @@ -1125,10 +1130,15 @@ static netdev_tx_t xgmac_xmit(struct sk_buff *skb, struct net_device *dev)
>  
>  	priv->tx_head = dma_ring_incr(entry, DMA_TX_RING_SZ);
>  
> -	if (dma_ring_space(priv->tx_head, priv->tx_tail, DMA_TX_RING_SZ) <
> -	    MAX_SKB_FRAGS)
> +	/* Ensure tx_head update is visible to tx completion */
> +	smp_mb();
> +	if (unlikely(tx_dma_ring_space(priv) <= MAX_SKB_FRAGS)) {
>  		netif_stop_queue(dev);
> -
> +		/* Ensure netif_stop_queue is visible to tx completion */
> +		smp_mb();
> +		if (tx_dma_ring_space(priv) > MAX_SKB_FRAGS)
> +			netif_start_queue(dev);
> +	}
>  	return NETDEV_TX_OK;
>  }
>  

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
