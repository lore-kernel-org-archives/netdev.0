From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ARC VMAC driver.
Date: Mon, 05 Mar 2012 15:30:04 -0500 (EST)
Message-ID: <20120305.153004.120141018357651846.davem@davemloft.net>
References: <1330941585-7404-1-git-send-email-afenkart@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: afenkart@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:55931 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964885Ab2CEUaH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Mar 2012 15:30:07 -0500
In-Reply-To: <1330941585-7404-1-git-send-email-afenkart@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andreas Fenkart <afenkart@gmail.com>
Date: Mon,  5 Mar 2012 10:59:45 +0100

> +	unsigned mac_lo, mac_hi;

Please never say just "unsigned" but instead use "unsigned int"
But in this case you're dealing with a fixed sized value so
"u32" is most appropriate.

> +	unsigned mac_lo, mac_hi;

Same here.

> +static void vmac_mdio_xmit(struct vmac_priv *ap, unsigned val)

Again.  So please fix this up in the entire driver.

> +	int report_change = 0;

Please use 'bool' as the type and 'true' and 'false' as the values.

> +	ap->mii_bus = mdiobus_alloc();
> +	if (ap->mii_bus == NULL)
> +		return -ENOMEM;

Use "if (!ap->mii_bus)" for null pointer checks.

> +	ap->mii_bus->irq = kmalloc(sizeof(int) * PHY_MAX_ADDR, GFP_KERNEL);
> +	if (!ap->mii_bus->irq)

Which inconsistently you do correctly here.

> +	struct vmac_priv *ap = netdev_priv(dev);
> +	dev_dbg(&ap->pdev->dev, "rx error counter overrun. status = 0x%x\n",
> +			status);

Please add an empty line between the function variable declarations and
the first actual code statement.

> +	if (!fifo_empty(&ap->rx_ring)) {
> +		dev_err(&ap->pdev->dev, "failed to reclaim %d rx sk_buff\n",
> +				fifo_used(&ap->rx_ring));
> +	}

You don't need openning and closing braces for a single line basic
block.  It just takes up an unnecessary extra line in the source.

> +	/* locking: fct owns rx_ring tail to current DMA read position, alias
> +	 * 'received packets'. rx_refill owns area outside rx_ring, doesn't
> +	 * modify tail */

Code comments:

	/* Like
	 * this.
	 */

	 /* Or like this. */

	 /* But not
	  * like this. */


There are other instances of this issue in the driver, please fix those
too.

> +	unsigned long tmp;

This is a 32-bit value not a long which is a non-fixed-sized type
and might be 64-bit.  You definitely want to use "u32" for these.

> +static void vmac_toggle_rxint_unlocked(struct net_device *dev, int enable)

Use 'bool' for all the places where you do this "enable" argument in
functions.

> +	if ((status & RXINT_MASK) && (vmac_readl(ap, ENABLE) && RXINT_MASK) &&

All of these register bit tests are wrong, you're using "&&
RXINT_MASK" instead of "& RXINT_MASK".

> +	if ((status & TXINT_MASK) && (vmac_readl(ap, ENABLE) && TXINT_MASK)) {

Same bug.

> +static int vmac_tx_reclaim_unlocked(struct net_device *dev, int force)
> +{
> +	struct vmac_priv *ap = netdev_priv(dev);
> +	int released = 0;

Use 'bool' and true/false for 'force' and 'released'.

> +		dev_kfree_skb_any(skb);

You only need to use the significantly more expensive dev_kfree_skb_any() if this
code can run in a hardware interrupt handler.

This is a NAPI driver and therefore it should only do reclaim from
NAPI poll and thus software interrupt context.  Therefore you can use
dev_kfree_skb() which is 10 times faster than dev_kfree_skb_any()
which results in a new software interrupt getting queued up.

> +	if (unlikely(skb->len < ETH_ZLEN)) {
> +		struct sk_buff *short_skb;
> +		short_skb = netdev_alloc_skb(dev, ETH_ZLEN);
> +		if (!short_skb)
> +			return NETDEV_TX_LOCKED;
> +
> +		memset(short_skb->data, 0, ETH_ZLEN);
> +		memcpy(skb_put(short_skb, ETH_ZLEN), skb->data, skb->len);
> +		dev_kfree_skb(skb);
> +		skb = short_skb;
> +	}

Don't reinvent the wheel, use skb_pad() or similar, which is much more efficient
than this open-coded version.

> +	desc->data = dma_map_single(&ap->pdev->dev, skb->data, skb->len,
> +			DMA_TO_DEVICE);

Align the argument up to the openning parenthesis on the previous line:

	desc->data = dma_map_single(&ap->pdev->dev, skb->data, skb->len,
				    DMA_TO_DEVICE);

> +	ap->rxbd = dma_alloc_coherent(&ap->pdev->dev, size,
> +			&ap->rxbd_dma,
> +			GFP_KERNEL);

Same problem.

> +	if (ap->rxbd == NULL)

Test with "if (!ptr)" not "if (ptr == NULL)"

> +	ap->txbd = dma_alloc_coherent(&ap->pdev->dev, size,
> +			&ap->txbd_dma,
> +			GFP_KERNEL);

Argument alignment.

> +	dma_free_coherent(&ap->pdev->dev, sizeof(*ap->txbd) * ap->tx_ring.size,
> +			ap->txbd, ap->txbd_dma);
 ...
> +	dma_free_coherent(&ap->pdev->dev, sizeof(*ap->rxbd) * ap->rx_ring.size,
> +			ap->rxbd, ap->rxbd_dma);

Again and again.

> +	dma_free_coherent(&ap->pdev->dev, sizeof(ap->txbd) * ap->tx_ring.size,
> +			ap->txbd, ap->txbd_dma);
> +	dma_free_coherent(&ap->pdev->dev, sizeof(ap->rxbd) * ap->rx_ring.size,
> +			ap->rxbd, ap->rxbd_dma);

More of the same.

> +	if (ap == NULL)

Test "if (!ap)" instad.

> +		dev_err(&ap->pdev->dev, "Unable to request IRQ %d (error %d)\n",
> +				dev->irq, err);

Argument alignment.

> +	temp |= ERR_MASK | TXCH_MASK | MSER_MASK | RXCR_MASK | RXFR_MASK | \
> +					RXFL_MASK;

There is no reason to escape the newline with a "\" here, get rid of that.

> +	dev_info(&ap->pdev->dev, "PHY driver [%s] (mii_bus:phy_addr=%s, irq=%d)\n",
> +	       phydev->drv->name, dev_name(&phydev->dev), phydev->irq);

Argument alignment.

> +	unsigned int temp;

Use "u32" for the type.

> +static void create_multicast_filter(struct net_device *dev,
> +	int32_t *bitmask)

Argument alignment.

> +	int promisc, reg;

Use 'bool' for 'promisc', use 'u32' for 'reg'.

> +	int32_t bitmask[2];

Don't use int32_t in the kernel, use 'u32' instead.

> +	if (dma_get_mask(&pdev->dev) > DMA_BIT_MASK(32) ||
> +			pdev->dev.coherent_dma_mask > DMA_BIT_MASK(32)) {

Align things properly:

	if (dma_get_mask(&pdev->dev) > DMA_BIT_MASK(32) ||
	    pdev->dev.coherent_dma_mask > DMA_BIT_MASK(32)) {

> +	dev->flags |= IFF_MULTICAST;

Why in the world do you need to do this?  The ethernet generic setup takes
care of this for you.

> +	if (!is_valid_ether_addr(dev->dev_addr))
> +		random_ether_addr(dev->dev_addr);

Use dev_hw_addr_random() which will properly set the NET_ADDR_RANDOM attribute
properly too.

> +	dev_info(&pdev->dev, "ARC VMAC at 0x%pP irq %d %pM\n", &mem->start,
> +	    dev->irq, dev->dev_addr);

Align the arguments properly.

> +struct	vmac_priv {

Get rid of that ugly tab, use a single space instead.

> +static inline int fifo_empty(struct dma_fifo *f)

Return 'bool'.

> +static inline int fifo_full(struct dma_fifo *f)

Return 'bool'.
> +	pr_info("fifo: head %d, tail %d, size %d\n", fifo->head,
> +			fifo->tail,
> +			fifo->size);

Align arguments properly.
