From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v5] net: ethernet: add driver for Aurora VLSI NB8800
 Ethernet controller
Date: Tue, 10 Nov 2015 09:58:07 -0800
Message-ID: <1447178287.17135.77.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1447172063-27234-1-git-send-email-mans@mansr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	slash.tmp@free.fr
To: Mans Rullgard <mans@mansr.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:34237 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754400AbbKJR6J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2015 12:58:09 -0500
In-Reply-To: <1447172063-27234-1-git-send-email-mans@mansr.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-11-10 at 16:14 +0000, Mans Rullgard wrote:
> This adds a driver for the Aurora VLSI NB8800 Ethernet controller.
> It is an almost complete rewrite of a driver originally found in
> a Sigma Designs 2.6.22 tree.

...

> +
> +static int nb8800_xmit(struct sk_buff *skb, struct net_device *dev)
> +{
> +	struct nb8800_priv *priv = netdev_priv(dev);
> +	struct nb8800_tx_desc *txd;
> +	struct nb8800_tx_buf *txb;
> +	struct nb8800_dma_desc *dma;
> +	dma_addr_t dma_addr;
> +	unsigned int dma_len;
> +	unsigned long flags;
> +	int align;
> +	int next;
> +
> +	if (atomic_read(&priv->tx_free) <= NB8800_DESC_LOW) {
> +		netif_stop_queue(dev);
> +		return NETDEV_TX_BUSY;
> +	}
> +
> +	align = (8 - (uintptr_t)skb->data) & 7;
> +
> +	dma_len = skb->len - align;
> +	dma_addr = dma_map_single(&dev->dev, skb->data + align,
> +				  dma_len, DMA_TO_DEVICE);
> +
> +	if (dma_mapping_error(&dev->dev, dma_addr)) {
> +		netdev_err(dev, "tx dma mapping error\n");
> +		kfree_skb(skb);
> +		dev->stats.tx_dropped++;
> +		return NETDEV_TX_OK;
> +	}
> +
> +	if (atomic_dec_return(&priv->tx_free) <= NB8800_DESC_LOW)
> +		netif_stop_queue(dev);


You probably also want to clear skb->xmit_more or risk a stall

xmit_more is tricky ;)

> +
> +	next = priv->tx_next;
> +	txb = &priv->tx_bufs[next];
> +	txd = &priv->tx_descs[next];
> +	dma = &txd->desc[0];
> +
> +	next = (next + 1) % TX_DESC_COUNT;
> +
> +	if (align) {
> +		memcpy(txd->buf, skb->data, align);
> +
> +		dma->s_addr =
> +			txb->dma_desc + offsetof(struct nb8800_tx_desc, buf);
> +		dma->n_addr = txb->dma_desc + sizeof(txd->desc[0]);
> +		dma->config = DESC_BTS(2) | DESC_DS | align;
> +
> +		dma++;
> +	}
> +
> +	dma->s_addr = dma_addr;
> +	dma->n_addr = priv->tx_bufs[next].dma_desc;
> +	dma->config = DESC_BTS(2) | DESC_DS | DESC_EOF | dma_len;
> +
> +	if (!skb->xmit_more)
> +		dma->config |= DESC_EOC;
> +
> +	txb->skb = skb;
> +	txb->dma_addr = dma_addr;
> +	txb->dma_len = dma_len;
> +
> +	if (!priv->tx_chain) {
> +		txb->chain_len = 1;
> +		priv->tx_chain = txb;
> +	} else {
> +		priv->tx_chain->chain_len++;
> +	}
> +
> +	netdev_sent_queue(dev, skb->len);
> +
> +	smp_mb__before_spinlock();
> +	spin_lock_irqsave(&priv->tx_lock, flags);
> +
> +	if (!skb->xmit_more) {
> +		priv->tx_chain->ready = true;
> +		priv->tx_chain = NULL;
> +		nb8800_tx_dma_start(dev);
> +	}
> +
> +	spin_unlock_irqrestore(&priv->tx_lock, flags);
> +
> +	priv->tx_next = next;
> +
> +	return NETDEV_TX_OK;
> +}
> +
