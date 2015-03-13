From: Jaedon Shin <jaedon.shin@gmail.com>
Subject: Re: [PATCH net-next] net: bcmgenet: rewrite bcmgenet_rx_refill()
Date: Fri, 13 Mar 2015 23:42:50 +0900
Message-ID: <49D39015-73C2-4983-837A-D749EFAC60ED@gmail.com>
References: <20150312224800.AE7A7220365@puck.mtv.corp.google.com>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2089\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, davem@davemloft.net, f.fainelli@gmail.com
To: Petri Gynther <pgynther@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:45107 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751056AbbCMOm4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 10:42:56 -0400
Received: by padbj1 with SMTP id bj1so29956983pad.12
        for <netdev@vger.kernel.org>; Fri, 13 Mar 2015 07:42:55 -0700 (PDT)
In-Reply-To: <20150312224800.AE7A7220365@puck.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Mar 13, 2015, at 7:48 AM, Petri Gynther <pgynther@google.com> wrote:
> 
> Currently, bcmgenet_desc_rx() calls bcmgenet_rx_refill() at the end of
> Rx packet processing loop, after the current Rx packet has already been
> passed to napi_gro_receive(). However, bcmgenet_rx_refill() might fail
> to allocate a new Rx skb, thus leaving a hole on the Rx queue where no
> valid Rx buffer exists.
> 
> To eliminate this situation:
> 1. Rewrite bcmgenet_rx_refill() to retain the current Rx skb on the Rx
>   queue if a new replacement Rx skb can't be allocated and DMA-mapped.
>   In this case, the data on the current Rx skb is effectively dropped.
> 2. Modify bcmgenet_desc_rx() to call bcmgenet_rx_refill() at the top of
>   Rx packet processing loop, so that the new replacement Rx skb is
>   already in place before the current Rx skb is processed.
> 
> Signed-off-by: Petri Gynther <pgynther@google.com>
> ---
> drivers/net/ethernet/broadcom/genet/bcmgenet.c | 99 +++++++++++---------------
> 1 file changed, 43 insertions(+), 56 deletions(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> index d3be1aeb..875967e 100644
> --- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> +++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> @@ -1336,36 +1336,47 @@ out:
> 	return ret;
> }
> 
> -
> -static int bcmgenet_rx_refill(struct bcmgenet_priv *priv, struct enet_cb *cb)
> +static struct sk_buff *bcmgenet_rx_refill(struct bcmgenet_priv *priv,
> +					  struct enet_cb *cb)
> {
> 	struct device *kdev = &priv->pdev->dev;
> 	struct sk_buff *skb;
> +	struct sk_buff *rx_skb;
> 	dma_addr_t mapping;
> -	int ret;
> 
> +	/* Allocate a new Rx skb */
> 	skb = netdev_alloc_skb(priv->dev, priv->rx_buf_len + SKB_ALIGNMENT);
> -	if (!skb)
> -		return -ENOMEM;
> +	if (!skb) {
> +		priv->mib.alloc_rx_buff_failed++;
> +		netif_err(priv, rx_err, priv->dev,
> +			  "%s: Rx skb allocation failed\n", __func__);
> +		return NULL;
> +	}
> 
> -	/* a caller did not release this control block */
> -	WARN_ON(cb->skb != NULL);
> -	cb->skb = skb;
> -	mapping = dma_map_single(kdev, skb->data,
> -				 priv->rx_buf_len, DMA_FROM_DEVICE);
> -	ret = dma_mapping_error(kdev, mapping);
> -	if (ret) {
> +	/* DMA-map the new Rx skb */
> +	mapping = dma_map_single(kdev, skb->data, priv->rx_buf_len,
> +				 DMA_FROM_DEVICE);
> +	if (dma_mapping_error(kdev, mapping)) {
> 		priv->mib.rx_dma_failed++;
> -		bcmgenet_free_cb(cb);
> +		dev_kfree_skb_any(skb);
> 		netif_err(priv, rx_err, priv->dev,
> -			  "%s DMA map failed\n", __func__);
> -		return ret;
> +			  "%s: Rx skb DMA mapping failed\n", __func__);
> +		return NULL;
> 	}
> 
> +	/* Grab the current Rx skb from the ring and DMA-unmap it */
> +	rx_skb = cb->skb;
> +	if (likely(rx_skb))
> +		dma_unmap_single(kdev, dma_unmap_addr(cb, dma_addr),
> +				 priv->rx_buf_len, DMA_FROM_DEVICE);
> +
> +	/* Put the new Rx skb on the ring */
> +	cb->skb = skb;
> 	dma_unmap_addr_set(cb, dma_addr, mapping);
> 	dmadesc_set_addr(priv, cb->bd_addr, mapping);
> 
> -	return 0;
> +	/* Return the current Rx skb to caller */
> +	return rx_skb;
> }
> 
> /* bcmgenet_desc_rx - descriptor based rx process.
> @@ -1381,7 +1392,7 @@ static unsigned int bcmgenet_desc_rx(struct bcmgenet_priv *priv,
> 	struct sk_buff *skb;
> 	u32 dma_length_status;
> 	unsigned long dma_flag;
> -	int len, err;
> +	int len;
> 	unsigned int rxpktprocessed = 0, rxpkttoprocess;
> 	unsigned int p_index;
> 	unsigned int discards;
> @@ -1419,26 +1430,14 @@ static unsigned int bcmgenet_desc_rx(struct bcmgenet_priv *priv,
> 	while ((rxpktprocessed < rxpkttoprocess) &&
> 	       (rxpktprocessed < budget)) {
> 		cb = &priv->rx_cbs[ring->read_ptr];
> -		skb = cb->skb;
> +		skb = bcmgenet_rx_refill(priv, cb);
> 
> -		/* We do not have a backing SKB, so we do not have a
> -		 * corresponding DMA mapping for this incoming packet since
> -		 * bcmgenet_rx_refill always either has both skb and mapping or
> -		 * none.
> -		 */
> 		if (unlikely(!skb)) {
> 			dev->stats.rx_dropped++;
> 			dev->stats.rx_errors++;
> -			goto refill;
> +			goto next;
> 		}
> 
> -		/* Unmap the packet contents such that we can use the
> -		 * RSV from the 64 bytes descriptor when enabled and save
> -		 * a 32-bits register read
> -		 */
> -		dma_unmap_single(&dev->dev, dma_unmap_addr(cb, dma_addr),
> -				 priv->rx_buf_len, DMA_FROM_DEVICE);
> -
> 		if (!priv->desc_64b_en) {
> 			dma_length_status =
> 				dmadesc_get_length_status(priv, cb->bd_addr);
> @@ -1465,10 +1464,10 @@ static unsigned int bcmgenet_desc_rx(struct bcmgenet_priv *priv,
> 				  "dropping fragmented packet!\n");
> 			dev->stats.rx_dropped++;
> 			dev->stats.rx_errors++;
> -			dev_kfree_skb_any(cb->skb);
> -			cb->skb = NULL;
> -			goto refill;
> +			dev_kfree_skb_any(skb);
> +			goto next;
> 		}
> +
> 		/* report errors */
> 		if (unlikely(dma_flag & (DMA_RX_CRC_ERROR |
> 						DMA_RX_OV |
> @@ -1487,11 +1486,8 @@ static unsigned int bcmgenet_desc_rx(struct bcmgenet_priv *priv,
> 				dev->stats.rx_length_errors++;
> 			dev->stats.rx_dropped++;
> 			dev->stats.rx_errors++;
> -
> -			/* discard the packet and advance consumer index.*/
> -			dev_kfree_skb_any(cb->skb);
> -			cb->skb = NULL;
> -			goto refill;
> +			dev_kfree_skb_any(skb);
> +			goto next;
> 		} /* error packet */
> 
> 		chksum_ok = (dma_flag & priv->dma_rx_chk_bit) &&
> @@ -1524,17 +1520,9 @@ static unsigned int bcmgenet_desc_rx(struct bcmgenet_priv *priv,
> 
> 		/* Notify kernel */
> 		napi_gro_receive(&priv->napi, skb);
> -		cb->skb = NULL;
> 		netif_dbg(priv, rx_status, dev, "pushed up to kernel\n");
> 
> -		/* refill RX path on the current control block */
> -refill:
> -		err = bcmgenet_rx_refill(priv, cb);
> -		if (err) {
> -			priv->mib.alloc_rx_buff_failed++;
> -			netif_err(priv, rx_err, dev, "Rx refill failed\n");
> -		}
> -
> +next:
> 		rxpktprocessed++;
> 		if (likely(ring->read_ptr < ring->end_ptr))
> 			ring->read_ptr++;
> @@ -1553,7 +1541,7 @@ static int bcmgenet_alloc_rx_buffers(struct bcmgenet_priv *priv,
> 				     struct bcmgenet_rx_ring *ring)
> {
> 	struct enet_cb *cb;
> -	int ret = 0;
> +	struct sk_buff *skb;
> 	int i;
> 
> 	netif_dbg(priv, hw, priv->dev, "%s\n", __func__);
> @@ -1561,15 +1549,14 @@ static int bcmgenet_alloc_rx_buffers(struct bcmgenet_priv *priv,
> 	/* loop here for each buffer needing assign */
> 	for (i = 0; i < ring->size; i++) {
> 		cb = ring->cbs + i;
> -		if (cb->skb)
> -			continue;
> -
> -		ret = bcmgenet_rx_refill(priv, cb);
> -		if (ret)
> -			break;
> +		skb = bcmgenet_rx_refill(priv, cb);
> +		if (skb)
> +			dev_kfree_skb_any(skb);
> +		if (!cb->skb)
> +			return -ENOMEM;
> 	}
> 
> -	return ret;
> +	return 0;
> }
> 
> static void bcmgenet_free_rx_buffers(struct bcmgenet_priv *priv)
> -- 
> 2.2.0.rc0.207.ga3a616c
> 

Tested-by: Jaedon Shin <jaedon.shin@gmail.com>