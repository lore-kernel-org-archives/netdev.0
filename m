From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH net-next 1/5] gianfar: Cleanup device refs in gfar_private
Date: Tue, 12 Feb 2013 09:54:34 -0500
Message-ID: <511A57AA.8070004@windriver.com>
References: <1360673237-349-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>
To: Claudiu Manoil <claudiu.manoil@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:56644 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933190Ab3BLOyF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2013 09:54:05 -0500
In-Reply-To: <1360673237-349-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13-02-12 07:47 AM, Claudiu Manoil wrote:
> * remove unused device_node pointer
> * remove duplicate SET_NETDEV_DEV()
> * use device pointer (dev) to simplify the code and to
>   avoid double indirections (esp. on the "fast path")

Ideally, when you find yourself making a list within the longlog,
that is a hint that you might want to start making it into
multiple commits, for ease of review.  Granted #1 and #2 are
trivial, but #3 probably could be a separate commit.  Did you
see any change in the object size or the disassembly when
making change #3?

P.
--

> 
> Cc: Paul Gortmaker <paul.gortmaker@windriver.com>
> Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
> ---
>  drivers/net/ethernet/freescale/gianfar.c |   29 +++++++++++++----------------
>  drivers/net/ethernet/freescale/gianfar.h |    2 +-
>  2 files changed, 14 insertions(+), 17 deletions(-)
> 
> diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
> index 75734bf..096fb5f 100644
> --- a/drivers/net/ethernet/freescale/gianfar.c
> +++ b/drivers/net/ethernet/freescale/gianfar.c
> @@ -231,7 +231,7 @@ static int gfar_alloc_skb_resources(struct net_device *ndev)
>  	dma_addr_t addr;
>  	int i, j, k;
>  	struct gfar_private *priv = netdev_priv(ndev);
> -	struct device *dev = &priv->ofdev->dev;
> +	struct device *dev = priv->dev;
>  	struct gfar_priv_tx_q *tx_queue = NULL;
>  	struct gfar_priv_rx_q *rx_queue = NULL;
>  
> @@ -668,7 +668,6 @@ static int gfar_of_init(struct platform_device *ofdev, struct net_device **pdev)
>  		return -ENOMEM;
>  
>  	priv = netdev_priv(dev);
> -	priv->node = ofdev->dev.of_node;
>  	priv->ndev = dev;
>  
>  	priv->num_tx_queues = num_tx_qs;
> @@ -1006,7 +1005,7 @@ static int gfar_probe(struct platform_device *ofdev)
>  	priv = netdev_priv(dev);
>  	priv->ndev = dev;
>  	priv->ofdev = ofdev;
> -	priv->node = ofdev->dev.of_node;
> +	priv->dev = &ofdev->dev;
>  	SET_NETDEV_DEV(dev, &ofdev->dev);
>  
>  	spin_lock_init(&priv->bflock);
> @@ -1043,8 +1042,6 @@ static int gfar_probe(struct platform_device *ofdev)
>  	/* Set the dev->base_addr to the gfar reg region */
>  	dev->base_addr = (unsigned long) regs;
>  
> -	SET_NETDEV_DEV(dev, &ofdev->dev);
> -
>  	/* Fill in the dev structure */
>  	dev->watchdog_timeo = TX_TIMEOUT;
>  	dev->mtu = 1500;
> @@ -1722,13 +1719,13 @@ static void free_skb_tx_queue(struct gfar_priv_tx_q *tx_queue)
>  		if (!tx_queue->tx_skbuff[i])
>  			continue;
>  
> -		dma_unmap_single(&priv->ofdev->dev, txbdp->bufPtr,
> +		dma_unmap_single(priv->dev, txbdp->bufPtr,
>  				 txbdp->length, DMA_TO_DEVICE);
>  		txbdp->lstatus = 0;
>  		for (j = 0; j < skb_shinfo(tx_queue->tx_skbuff[i])->nr_frags;
>  		     j++) {
>  			txbdp++;
> -			dma_unmap_page(&priv->ofdev->dev, txbdp->bufPtr,
> +			dma_unmap_page(priv->dev, txbdp->bufPtr,
>  				       txbdp->length, DMA_TO_DEVICE);
>  		}
>  		txbdp++;
> @@ -1749,8 +1746,8 @@ static void free_skb_rx_queue(struct gfar_priv_rx_q *rx_queue)
>  
>  	for (i = 0; i < rx_queue->rx_ring_size; i++) {
>  		if (rx_queue->rx_skbuff[i]) {
> -			dma_unmap_single(&priv->ofdev->dev,
> -					 rxbdp->bufPtr, priv->rx_buffer_size,
> +			dma_unmap_single(priv->dev, rxbdp->bufPtr,
> +					 priv->rx_buffer_size,
>  					 DMA_FROM_DEVICE);
>  			dev_kfree_skb_any(rx_queue->rx_skbuff[i]);
>  			rx_queue->rx_skbuff[i] = NULL;
> @@ -1789,7 +1786,7 @@ static void free_skb_resources(struct gfar_private *priv)
>  			free_skb_rx_queue(rx_queue);
>  	}
>  
> -	dma_free_coherent(&priv->ofdev->dev,
> +	dma_free_coherent(priv->dev,
>  			  sizeof(struct txbd8) * priv->total_tx_ring_size +
>  			  sizeof(struct rxbd8) * priv->total_rx_ring_size,
>  			  priv->tx_queue[0]->tx_bd_base,
> @@ -2169,7 +2166,7 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  			if (i == nr_frags - 1)
>  				lstatus |= BD_LFLAG(TXBD_LAST | TXBD_INTERRUPT);
>  
> -			bufaddr = skb_frag_dma_map(&priv->ofdev->dev,
> +			bufaddr = skb_frag_dma_map(priv->dev,
>  						   &skb_shinfo(skb)->frags[i],
>  						   0,
>  						   length,
> @@ -2221,7 +2218,7 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  		lstatus |= BD_LFLAG(TXBD_TOE);
>  	}
>  
> -	txbdp_start->bufPtr = dma_map_single(&priv->ofdev->dev, skb->data,
> +	txbdp_start->bufPtr = dma_map_single(priv->dev, skb->data,
>  					     skb_headlen(skb), DMA_TO_DEVICE);
>  
>  	/* If time stamping is requested one additional TxBD must be set up. The
> @@ -2534,7 +2531,7 @@ static int gfar_clean_tx_ring(struct gfar_priv_tx_q *tx_queue)
>  		} else
>  			buflen = bdp->length;
>  
> -		dma_unmap_single(&priv->ofdev->dev, bdp->bufPtr,
> +		dma_unmap_single(priv->dev, bdp->bufPtr,
>  				 buflen, DMA_TO_DEVICE);
>  
>  		if (unlikely(skb_shinfo(skb)->tx_flags & SKBTX_IN_PROGRESS)) {
> @@ -2553,7 +2550,7 @@ static int gfar_clean_tx_ring(struct gfar_priv_tx_q *tx_queue)
>  		bdp = next_txbd(bdp, base, tx_ring_size);
>  
>  		for (i = 0; i < frags; i++) {
> -			dma_unmap_page(&priv->ofdev->dev, bdp->bufPtr,
> +			dma_unmap_page(priv->dev, bdp->bufPtr,
>  				       bdp->length, DMA_TO_DEVICE);
>  			bdp->lstatus &= BD_LFLAG(TXBD_WRAP);
>  			bdp = next_txbd(bdp, base, tx_ring_size);
> @@ -2619,7 +2616,7 @@ static void gfar_new_rxbdp(struct gfar_priv_rx_q *rx_queue, struct rxbd8 *bdp,
>  	struct gfar_private *priv = netdev_priv(dev);
>  	dma_addr_t buf;
>  
> -	buf = dma_map_single(&priv->ofdev->dev, skb->data,
> +	buf = dma_map_single(priv->dev, skb->data,
>  			     priv->rx_buffer_size, DMA_FROM_DEVICE);
>  	gfar_init_rxbdp(rx_queue, bdp, buf);
>  }
> @@ -2784,7 +2781,7 @@ int gfar_clean_rx_ring(struct gfar_priv_rx_q *rx_queue, int rx_work_limit)
>  
>  		skb = rx_queue->rx_skbuff[rx_queue->skb_currx];
>  
> -		dma_unmap_single(&priv->ofdev->dev, bdp->bufPtr,
> +		dma_unmap_single(priv->dev, bdp->bufPtr,
>  				 priv->rx_buffer_size, DMA_FROM_DEVICE);
>  
>  		if (unlikely(!(bdp->status & RXBD_ERR) &&
> diff --git a/drivers/net/ethernet/freescale/gianfar.h b/drivers/net/ethernet/freescale/gianfar.h
> index 71793f4..22c2f7a 100644
> --- a/drivers/net/ethernet/freescale/gianfar.h
> +++ b/drivers/net/ethernet/freescale/gianfar.h
> @@ -1065,7 +1065,7 @@ struct gfar_private {
>  	unsigned int total_tx_ring_size;
>  	unsigned int total_rx_ring_size;
>  
> -	struct device_node *node;
> +	struct device *dev;
>  	struct net_device *ndev;
>  	struct platform_device *ofdev;
>  	enum gfar_errata errata;
> 
