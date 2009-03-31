From: Becky Bruce <beckyb@kernel.crashing.org>
Subject: Re: [PATCH] net/fec_mpc52xx: fix BUG on missing dma_ops
Date: Tue, 31 Mar 2009 13:58:58 -0500
Message-ID: <0947433F-BDDA-48D8-A59C-BCF321EE465C@kernel.crashing.org>
References: <20090331022428.26151.55232.stgit@localhost.localdomain>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	David Miller <davem@davemloft.net>, galak@kernel.crashing.net
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:50861 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757213AbZCaS7N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Mar 2009 14:59:13 -0400
In-Reply-To: <20090331022428.26151.55232.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mar 30, 2009, at 9:25 PM, Grant Likely wrote:

> From: Grant Likely <grant.likely@secretlab.ca>
>
> The driver triggers a BUG_ON() when allocating DMA buffers if the
> arch/powerpc dma_ops from the of_platform device are not copied
> into net_device structure.
>
> Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
> ---
>
> Becky, does this look better to you?

Reviewed-by: Becky Bruce <beckyb@kernel.crashing.org>

I think this is OK now, and Kumar agrees....

Thanks!
B

>
>
> g.
>
> drivers/net/fec_mpc52xx.c |   19 ++++++++++++-------
> 1 files changed, 12 insertions(+), 7 deletions(-)
>
>
> diff --git a/drivers/net/fec_mpc52xx.c b/drivers/net/fec_mpc52xx.c
> index 049b0a7..f99463f 100644
> --- a/drivers/net/fec_mpc52xx.c
> +++ b/drivers/net/fec_mpc52xx.c
> @@ -129,7 +129,8 @@ static void mpc52xx_fec_free_rx_buffers(struct  
> net_device *dev, struct bcom_task
> 		struct sk_buff *skb;
>
> 		skb = bcom_retrieve_buffer(s, NULL, (struct bcom_bd **)&bd);
> -		dma_unmap_single(&dev->dev, bd->skb_pa, skb->len, DMA_FROM_DEVICE);
> +		dma_unmap_single(dev->dev.parent, bd->skb_pa, skb->len,
> +				 DMA_FROM_DEVICE);
> 		kfree_skb(skb);
> 	}
> }
> @@ -150,7 +151,7 @@ static int mpc52xx_fec_alloc_rx_buffers(struct  
> net_device *dev, struct bcom_task
> 		bd = (struct bcom_fec_bd *)bcom_prepare_next_buffer(rxtsk);
>
> 		bd->status = FEC_RX_BUFFER_SIZE;
> -		bd->skb_pa = dma_map_single(&dev->dev, skb->data,
> +		bd->skb_pa = dma_map_single(dev->dev.parent, skb->data,
> 				FEC_RX_BUFFER_SIZE, DMA_FROM_DEVICE);
>
> 		bcom_submit_next_buffer(rxtsk, skb);
> @@ -388,7 +389,8 @@ static int mpc52xx_fec_hard_start_xmit(struct  
> sk_buff *skb, struct net_device *d
> 		bcom_prepare_next_buffer(priv->tx_dmatsk);
>
> 	bd->status = skb->len | BCOM_FEC_TX_BD_TFD | BCOM_FEC_TX_BD_TC;
> -	bd->skb_pa = dma_map_single(&dev->dev, skb->data, skb->len,  
> DMA_TO_DEVICE);
> +	bd->skb_pa = dma_map_single(dev->dev.parent, skb->data, skb->len,
> +				    DMA_TO_DEVICE);
>
> 	bcom_submit_next_buffer(priv->tx_dmatsk, skb);
>
> @@ -430,7 +432,8 @@ static irqreturn_t mpc52xx_fec_tx_interrupt(int  
> irq, void *dev_id)
> 		struct bcom_fec_bd *bd;
> 		skb = bcom_retrieve_buffer(priv->tx_dmatsk, NULL,
> 				(struct bcom_bd **)&bd);
> -		dma_unmap_single(&dev->dev, bd->skb_pa, skb->len, DMA_TO_DEVICE);
> +		dma_unmap_single(dev->dev.parent, bd->skb_pa, skb->len,
> +				 DMA_TO_DEVICE);
>
> 		dev_kfree_skb_irq(skb);
> 	}
> @@ -455,7 +458,8 @@ static irqreturn_t mpc52xx_fec_rx_interrupt(int  
> irq, void *dev_id)
>
> 		rskb = bcom_retrieve_buffer(priv->rx_dmatsk, &status,
> 				(struct bcom_bd **)&bd);
> -		dma_unmap_single(&dev->dev, bd->skb_pa, rskb->len,  
> DMA_FROM_DEVICE);
> +		dma_unmap_single(dev->dev.parent, bd->skb_pa, rskb->len,
> +				 DMA_FROM_DEVICE);
>
> 		/* Test for errors in received frame */
> 		if (status & BCOM_FEC_RX_BD_ERRORS) {
> @@ -464,7 +468,8 @@ static irqreturn_t mpc52xx_fec_rx_interrupt(int  
> irq, void *dev_id)
> 				bcom_prepare_next_buffer(priv->rx_dmatsk);
>
> 			bd->status = FEC_RX_BUFFER_SIZE;
> -			bd->skb_pa = dma_map_single(&dev->dev, rskb->data,
> +			bd->skb_pa = dma_map_single(dev->dev.parent,
> +					rskb->data,
> 					FEC_RX_BUFFER_SIZE, DMA_FROM_DEVICE);
>
> 			bcom_submit_next_buffer(priv->rx_dmatsk, rskb);
> @@ -499,7 +504,7 @@ static irqreturn_t mpc52xx_fec_rx_interrupt(int  
> irq, void *dev_id)
> 			bcom_prepare_next_buffer(priv->rx_dmatsk);
>
> 		bd->status = FEC_RX_BUFFER_SIZE;
> -		bd->skb_pa = dma_map_single(&dev->dev, skb->data,
> +		bd->skb_pa = dma_map_single(dev->dev.parent, skb->data,
> 				FEC_RX_BUFFER_SIZE, DMA_FROM_DEVICE);
>
> 		bcom_submit_next_buffer(priv->rx_dmatsk, skb);

