From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next V5 6/9] Altera TSE: Add main and header file for
 Altera Ethernet Driver
Date: Fri, 14 Mar 2014 15:39:18 +0100
Message-ID: <20140314143918.GA2253@netboy>
References: <1394805887-22030-1-git-send-email-vbridgers2013@gmail.com>
 <1394805887-22030-7-git-send-email-vbridgers2013@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: devicetree@vger.kernel.org, netdev@vger.kernel.org,
	linux-doc@vger.kernel.org, robh+dt@kernel.org, pawel.moll@arm.com,
	mark.rutland@arm.com, ijc+devicetree@hellion.org.uk,
	galak@codeaurora.org, rob@landley.net
To: Vince Bridgers <vbridgers2013@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f42.google.com ([74.125.83.42]:47891 "EHLO
	mail-ee0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754393AbaCNOjZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Mar 2014 10:39:25 -0400
Content-Disposition: inline
In-Reply-To: <1394805887-22030-7-git-send-email-vbridgers2013@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 14, 2014 at 09:04:44AM -0500, Vince Bridgers wrote:
> +static int tse_start_xmit(struct sk_buff *skb, struct net_device *dev)
> +{
> +	struct altera_tse_private *priv = netdev_priv(dev);
> +	unsigned int txsize = priv->tx_ring_size;
> +	unsigned int entry;
> +	struct tse_buffer *buffer = NULL;
> +	int nfrags = skb_shinfo(skb)->nr_frags;
> +	unsigned int nopaged_len = skb_headlen(skb);
> +	enum netdev_tx ret = NETDEV_TX_OK;
> +	dma_addr_t dma_addr;
> +	int txcomplete = 0;
> +
> +	spin_lock_bh(&priv->tx_lock);
> +
> +	if (unlikely(tse_tx_avail(priv) < nfrags + 1)) {
> +		if (!netif_queue_stopped(dev)) {
> +			netif_stop_queue(dev);
> +			/* This is a hard error, log it. */
> +			netdev_err(priv->dev,
> +				   "%s: Tx list full when queue awake\n",
> +				   __func__);
> +		}
> +		ret = NETDEV_TX_BUSY;
> +		goto out;
> +	}
> +
> +	/* Map the first skb fragment */
> +	entry = priv->tx_prod % txsize;
> +	buffer = &priv->tx_ring[entry];
> +
> +	dma_addr = dma_map_single(priv->device, skb->data, nopaged_len,
> +				  DMA_TO_DEVICE);
> +	if (dma_mapping_error(priv->device, dma_addr)) {
> +		netdev_err(priv->dev, "%s: DMA mapping error\n", __func__);
> +		ret = NETDEV_TX_OK;
> +		goto out;
> +	}
> +
> +	buffer->skb = skb;
> +	buffer->dma_addr = dma_addr;
> +	buffer->len = nopaged_len;
> +
> +	/* Push data out of the cache hierarchy into main memory */
> +	dma_sync_single_for_device(priv->device, buffer->dma_addr,
> +				   buffer->len, DMA_TO_DEVICE);
> +
> +	txcomplete = priv->dmaops->tx_buffer(priv, buffer);
> +
> +	priv->tx_prod++;
> +	dev->stats.tx_bytes += skb->len;

This could use a call to skb_tx_timestamp() somewhere around here.

> +
> +	if (unlikely(tse_tx_avail(priv) <= TXQUEUESTOP_THRESHHOLD)) {
> +		if (netif_msg_hw(priv))
> +			netdev_dbg(priv->dev, "%s: stop transmitted packets\n",
> +				   __func__);
> +		netif_stop_queue(dev);
> +	}
> +
> +out:
> +	spin_unlock_bh(&priv->tx_lock);
> +
> +	return ret;
> +}

Thanks,
Richard
