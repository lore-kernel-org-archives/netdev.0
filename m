From: "Dale Farnsworth" <dale@farnsworth.org>
Subject: Re: [PATCH v4] FEC - fast ethernet controller for mpc52xx
Date: 25 Oct 2007 11:57:06 -0700
Message-ID: <20071025185706.29496.qmail@farnsworth.org>
References: <20071014075511.GC3000@nd47.coderock.org> <4713BA1C.2050604@pobox.com> <fa686aa40710180715u23d81adfy83ff65837725fb80@mail.gmail.com> <4717B09B.3060800@pobox.com> <20071019112700.GD27403@nd47.coderock.org> <47206209.8080109@pobox.com>
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: domen.puncer@telargo.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from xyzzy.farnsworth.org ([65.39.95.219]:43157 "HELO farnsworth.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753325AbXJYS5I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Oct 2007 14:57:08 -0400
In-Reply-To: <20071025141035.GG3369@nd47.coderock.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Domen wrote:
> > use your platform's dma mapping functions, rather than virt_to_phys()
> > 
> > it might be the exact same implementation, inside the platform 
> > internals, but drivers should not be using this directly.
> 
> I've replaced this with dma_map_single(), unmatched with
> dma_unmap_single(), since bestcomm doesn't have a way to do that
> and it's blank on ppc32 anyway.
> 
> Is this OK? PPC guys?

Even though dma_unmap_single() may be a no-op, calls to
dma_map_single() must be matched with calls to dma_unmap_single().

Perhaps with the additions below:

> +static void mpc52xx_fec_free_rx_buffers(struct bcom_task *s)
> +{
> +	struct sk_buff *skb;
> +
> +	while (!bcom_queue_empty(s)) {
> +		skb = bcom_retrieve_buffer(s, NULL, NULL);

		dma_unmap_single(&skb->dev->dev, skb-data,
				 FEC_RX_BUFFER_SIZE, DMA_FROM_DEVICE);

> +		kfree_skb(skb);
> +	}
> +}
> +
> +static int mpc52xx_fec_alloc_rx_buffers(struct net_device *dev, struct
> bcom_task *rxtsk)
> +{
> +	while (!bcom_queue_full(rxtsk)) {
> +		struct sk_buff *skb;
> +		struct bcom_fec_bd *bd;
> +
> +		skb = dev_alloc_skb(FEC_RX_BUFFER_SIZE);
> +		if (skb == NULL)
> +			return -EAGAIN;

		skb->dev = dev;

> +
> +		/* zero out the initial receive buffers to aid debugging */
> +		memset(skb->data, 0, FEC_RX_BUFFER_SIZE);
> +
> +		bd = (struct bcom_fec_bd *)bcom_prepare_next_buffer(rxtsk);
> +
> +		bd->status = FEC_RX_BUFFER_SIZE;
> +		bd->skb_pa = dma_map_single(&dev->dev, skb->data,
> +				FEC_RX_BUFFER_SIZE, DMA_FROM_DEVICE);
> +
> +		bcom_submit_next_buffer(rxtsk, skb);
> +	}
> +
> +	return 0;
> +}

[...]

> +static int mpc52xx_fec_hard_start_xmit(struct sk_buff *skb, struct
> net_device *dev)
> +{
> +	struct mpc52xx_fec_priv *priv = netdev_priv(dev);
> +	struct bcom_fec_bd *bd;
> +
> +	if (bcom_queue_full(priv->tx_dmatsk)) {
> +		if (net_ratelimit())
> +			dev_err(&dev->dev, "transmit queue overrun\n");
> +		return 1;
> +	}
> +
> +	spin_lock_irq(&priv->lock);
> +	dev->trans_start = jiffies;
> +
> +	bd = (struct bcom_fec_bd *)
> +		bcom_prepare_next_buffer(priv->tx_dmatsk);
> +
> +	bd->status = skb->len | BCOM_FEC_TX_BD_TFD | BCOM_FEC_TX_BD_TC;
> +	bd->skb_pa = dma_map_single(&dev->dev, skb->data, skb->len, DMA_TO_DEVICE);
> +
> +	bcom_submit_next_buffer(priv->tx_dmatsk, skb);
> +
> +	if (bcom_queue_full(priv->tx_dmatsk)) {
> +		netif_stop_queue(dev);
> +	}
> +
> +	spin_unlock_irq(&priv->lock);
> +
> +	return 0;
> +}
> +
> +/* This handles BestComm transmit task interrupts
> + */
> +static irqreturn_t mpc52xx_fec_tx_interrupt(int irq, void *dev_id)
> +{
> +	struct net_device *dev = dev_id;
> +	struct mpc52xx_fec_priv *priv = netdev_priv(dev);
> +
> +	spin_lock(&priv->lock);
> +
> +	while (bcom_buffer_done(priv->tx_dmatsk)) {
> +		struct sk_buff *skb;
> +		skb = bcom_retrieve_buffer(priv->tx_dmatsk, NULL, NULL);
> +		/* Here (and in rx routines) would be a good place for
> +		 * dma_unmap_single(), but bcom doesn't return bcom_bd of the
> +		 * finished transfer, and _unmap is empty on this platfrom.
> +		 */

Replace the above comment with:

		dma_unmap_single(&dev->dev, skb->data,
				 skb->len, DMA_TO_DEVICE);

> +
> +		dev_kfree_skb_irq(skb);
> +	}
> +
> +	netif_wake_queue(dev);
> +
> +	spin_unlock(&priv->lock);
> +
> +	return IRQ_HANDLED;
> +}
> +
> +static irqreturn_t mpc52xx_fec_rx_interrupt(int irq, void *dev_id)
> +{
> +	struct net_device *dev = dev_id;
> +	struct mpc52xx_fec_priv *priv = netdev_priv(dev);
> +
> +	while (bcom_buffer_done(priv->rx_dmatsk)) {
> +		struct sk_buff *skb;
> +		struct sk_buff *rskb;
> +		struct bcom_fec_bd *bd;
> +		u32 status;
> +
> +		rskb = bcom_retrieve_buffer(priv->rx_dmatsk, &status, NULL);

		dma_unmap_single(&dev->dev, rskb->data,
				 FEC_RX_BUFFER_SIZE, DMA_FROM_DEVICE);

> +
> +		/* Test for errors in received frame */
> +		if (status & BCOM_FEC_RX_BD_ERRORS) {
> +			/* Drop packet and reuse the buffer */
> +			bd = (struct bcom_fec_bd *)
> +				bcom_prepare_next_buffer(priv->rx_dmatsk);
> +
> +			bd->status = FEC_RX_BUFFER_SIZE;
> +			bd->skb_pa = dma_map_single(&dev->dev, rskb->data,
> +					FEC_RX_BUFFER_SIZE, DMA_FROM_DEVICE);
> +
> +			bcom_submit_next_buffer(priv->rx_dmatsk, rskb);
> +
> +			dev->stats.rx_dropped++;
> +
> +			continue;
> +		}
> +
> +		/* skbs are allocated on open, so now we allocate a new one,
> +		 * and remove the old (with the packet) */
> +		skb = dev_alloc_skb(FEC_RX_BUFFER_SIZE);
> +		if (skb) {
> +			/* Process the received skb */
> +			int length = status & BCOM_FEC_RX_BD_LEN_MASK;

			skb->dev = dev;

> +
> +			skb_put(rskb, length - 4);	/* length without CRC32 */
> +
> +			rskb->dev = dev;

Above line is no longer needed since we set rskb->dev on skb allocation.

> +			rskb->protocol = eth_type_trans(rskb, dev);
> +
> +			netif_rx(rskb);
> +			dev->last_rx = jiffies;
> +		} else {
> +			/* Can't get a new one : reuse the same & drop pkt */
> +			dev_notice(&dev->dev, "Memory squeeze, dropping packet.\n");
> +			dev->stats.rx_dropped++;
> +
> +			skb = rskb;
> +		}
> +
> +		bd = (struct bcom_fec_bd *)
> +			bcom_prepare_next_buffer(priv->rx_dmatsk);
> +
> +		bd->status = FEC_RX_BUFFER_SIZE;
> +		bd->skb_pa = dma_map_single(&dev->dev, rskb->data,
> +				FEC_RX_BUFFER_SIZE, DMA_FROM_DEVICE);
> +
> +		bcom_submit_next_buffer(priv->rx_dmatsk, skb);
> +	}
> +
> +	return IRQ_HANDLED;
> +}

-Dale Farnsworth
