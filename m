From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH,RFC] Marvell Orion SoC ethernet driver
Date: Tue, 16 Oct 2007 13:22:03 -0700
Message-ID: <20071016132203.623f8ef9@freepuppy.rosehill>
References: <20071016192806.GD19618@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tzachi@marvell.com, nico@cam.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:55496 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760411AbXJPUWx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2007 16:22:53 -0400
In-Reply-To: <20071016192806.GD19618@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 16 Oct 2007 21:28:06 +0200
Lennert Buytenhek <buytenh@wantstofly.org> wrote:

> Attached is a driver for the built-in 10/100/1000 ethernet MAC in
> the Marvell Orion series of ARM SoCs.
>  
> This ethernet MAC supports the MII/GMII/RGMII PCS interface types,
> and offers a pretty standard set of MAC features, such as RX/TX
> checksum offload, scatter-gather, interrupt coalescing, PAUSE,
> jumbo frames, etc.
>  
> This patch is against 2.6.22.1, and the driver has not yet been
> adapted to the recent NAPI changes.  Nevertheless, we wanted to
> get this out there for feedback/review.
> 
> Comments appreciated!
> 
> Signed-off-by: Tzachi Perelstein <tzachi@marvell.com>
> Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
> Signed-off-by: Nicolas Pitre <nico@marvell.com>
> 

> +static u8 orion_mcast_hash(u8 *addr)
> +{
> +	/*
> +	 * CRC-8 x^8+x^2+x^1+1
> +	 */
>
Why not add a crc-8 set of generic code?

> +static void orion_rx_fill(struct orion_priv *op)
> +{
> +	struct sk_buff *skb;
> +	struct rx_desc *rxd;
> +	int alloc_skb_failed = 0;
> +	u32 unaligned;
> +
> +	spin_lock_bh(&op->rx_lock);
> +
> +	while (op->rxd_count < RX_DESC_NR) {
> +
> +		rxd = &op->rxd_base[op->rxd_used];
> +
> +		if (rxd->cmd_sts & RXD_DMA) {
> +			printk(KERN_ERR "orion_rx_fill error, desc owned by DMA\n");
> +			break;
> +		}
> +
> +		skb = dev_alloc_skb(MAX_PKT_SIZE + dma_get_cache_alignment());
> +		if (!skb) {
> +			alloc_skb_failed = 1;
> +			break;
> +		}

Use netdev_alloc_skb in new drivers.
If you define SLAB DEBUGGING skb->data won't be aligned??

> +		unaligned = (u32)skb->data & (dma_get_cache_alignment() - 1);
> +		if (unaligned)
> +			skb_reserve(skb, dma_get_cache_alignment() - unaligned);
> +
> +		/*
> +		 * HW skips on first 2B to align the IP header
> +		 */
> +		skb_reserve(skb, 2);


Use NET_IP_ALIGN instead of 2. That way platforms that don't like unaligned
dma's can override it.

> +
> +		op->rx_skb[op->rxd_used] = skb;
> +
> +		rxd->buf = dma_map_single(NULL, skb->data, MAX_PKT_SIZE - 2,
> +						DMA_FROM_DEVICE);
> +		rxd->size = MAX_PKT_SIZE & RXD_SIZE_MASK;
> +		rxd->count = 0;
> +		wmb();
> +		rxd->cmd_sts = RXD_DMA | RXD_INT;
> +
> +		op->rxd_count++;
> +		op->rxd_used = (op->rxd_used + 1) % RX_DESC_NR;
> +	}
> +
> +	/*
> +	 * If skb_alloc failed and the number of rx buffers in the ring is
> +	 * less than half of the ring size, then set a timer to try again
> +	 * later (100ms).
> +	 */
> +	if (alloc_skb_failed && op->rxd_count < RX_DESC_NR / 2) {
> +		printk(KERN_INFO "orion_rx_fill set timer to alloc bufs\n");
> +		if (!timer_pending(&op->rx_fill_timer))
> +			mod_timer(&op->rx_fill_timer, jiffies + (HZ / 10));
> +	}
> +
> +	spin_unlock_bh(&op->rx_lock);
> +}

> +static u32 orion_get_rx_csum(struct net_device *netdev)
> +{
> +#ifdef ORION_RX_CSUM_OFFLOAD
> +	return 1;
> +#else
> +	return 0;
> +#endif
> +}

Please allow real disabling of rx checksum.

> +static u32 orion_get_tx_csum(struct net_device *netdev)
> +{
> +#ifdef ORION_TX_CSUM_OFFLOAD
> +	return 1;
> +#else
> +	return 0;
> +#endif
> +}

Please allow control of tx checksum via ethtool_op_get_tx_sum()??

> +static struct ethtool_ops orion_ethtool_ops = {
> +	.get_drvinfo		= orion_get_drvinfo,
> +	.get_settings		= orion_get_settings,
> +	.set_settings		= orion_set_settings,
> +	.nway_reset		= orion_nway_reset,
> +	.get_link		= orion_get_link,
> +	.get_ringparam		= orion_get_ringparam,
> +	.get_rx_csum		= orion_get_rx_csum,
> +	.get_tx_csum		= orion_get_tx_csum,
> +};
> +
> +static int orion_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
> +{
> +	struct orion_priv *op = netdev_priv(dev);
> +	struct mii_ioctl_data *data = if_mii(ifr);
> +
> +	return generic_mii_ioctl(&op->mii, data, cmd, NULL);
> +}
> 
-- 
Stephen Hemminger <shemminger@linux-foundation.org>
