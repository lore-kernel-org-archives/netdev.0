From: Cyrille Pitchen <cyrille.pitchen@atmel.com>
Subject: [PATCH 2/6] net/macb: add scatter-gather hw feature
Date: Fri, 18 Jul 2014 16:21:14 +0200
Message-ID: <fda3a504240e1f6863107ef6bf1e78586671a030.1405689937.git.cyrille.pitchen@atmel.com>
References: <cover.1405689937.git.cyrille.pitchen@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Cyrille Pitchen <cyrille.pitchen@atmel.com>, linux-kernel@vger.kernel.org
To: <nicolas.ferre@atmel.com>, <davem@davemloft.net>,
 <linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
 <soren.brinkmann@xilinx.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <cover.1405689937.git.cyrille.pitchen@atmel.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

The scatter-gather feature will allow to enable the Generic Segmentation Offload.
Generic Segmentation Offload can be enabled/disabled using ethtool -K DEVNAME gso on|off.

e.g:
ethtool -K eth0 gso off

When enabled, the driver may be provided with socket buffers splitted into many fragments.
These fragments need to be queued into the TX ring in reverse order, starting from to the
last one down to the first one, to avoid a race condition with the MAC.
Especially the 'TX_USED' bit in word 1 of the transmit buffer descriptor of the
first fragment should be cleared at the very final step of the queueing algorithm.
This will tell the hardware that fragments are ready to be sent.

Also since the MAC only update the status word of the first buffer descriptor of the
ethernet frame, the queueing algorithm can no longer expect a 'TX_USED' bit to be set by
the MAC into the buffer descriptor following the one for last fragment of the skb.
This is why the driver sets the 'TX_USED' bit before queueing any fragment, so the end of
queue position is well defined for the MAC.

Signed-off-by: Cyrille Pitchen <cyrille.pitchen@atmel.com>
---
 drivers/net/ethernet/cadence/macb.c | 276 +++++++++++++++++++++++++++++-------
 drivers/net/ethernet/cadence/macb.h |  15 +-
 2 files changed, 239 insertions(+), 52 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 0896d88..06e9934 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -52,6 +52,9 @@
 					| MACB_BIT(TXERR))
 #define MACB_TX_INT_FLAGS	(MACB_TX_ERR_FLAGS | MACB_BIT(TCOMP))
 
+#define MACB_MAX_TX_LEN		((unsigned int)((1 << MACB_TX_FRMLEN_SIZE) - 1))
+#define GEM_MAX_TX_LEN		((unsigned int)((1 << GEM_TX_FRMLEN_SIZE) - 1))
+
 /*
  * Graceful stop timeouts in us. We should allow up to
  * 1 frame time (10 Mbits/s, full-duplex, ignoring collisions)
@@ -468,6 +471,25 @@ static int macb_halt_tx(struct macb *bp)
 	return -ETIMEDOUT;
 }
 
+static void macb_tx_unmap(struct macb *bp, struct macb_tx_skb *tx_skb)
+{
+	if (tx_skb->mapping) {
+		if (tx_skb->mapped_as_page) {
+			dma_unmap_page(&bp->pdev->dev, tx_skb->mapping,
+				       tx_skb->size, DMA_TO_DEVICE);
+		} else {
+			dma_unmap_single(&bp->pdev->dev, tx_skb->mapping,
+					 tx_skb->size, DMA_TO_DEVICE);
+		}
+		tx_skb->mapping = 0;
+	}
+
+	if (tx_skb->skb) {
+		dev_kfree_skb_any(tx_skb->skb);
+		tx_skb->skb = NULL;
+	}
+}
+
 static void macb_tx_error_task(struct work_struct *work)
 {
 	struct macb	*bp = container_of(work, struct macb, tx_error_task);
@@ -505,10 +527,23 @@ static void macb_tx_error_task(struct work_struct *work)
 		skb = tx_skb->skb;
 
 		if (ctrl & MACB_BIT(TX_USED)) {
-			netdev_vdbg(bp->dev, "txerr skb %u (data %p) TX complete\n",
-				    macb_tx_ring_wrap(tail), skb->data);
-			bp->stats.tx_packets++;
-			bp->stats.tx_bytes += skb->len;
+			/* skb is set for the last buffer of the frame */
+			while (!skb) {
+				macb_tx_unmap(bp, tx_skb);
+				tail++;
+				tx_skb = macb_tx_skb(bp, tail);
+				skb = tx_skb->skb;
+			}
+
+			/* ctrl still refers to the first buffer descriptor
+			 * since it's the only one written back by the hardware
+			 */
+			if (!(ctrl & MACB_BIT(TX_BUF_EXHAUSTED))) {
+				netdev_vdbg(bp->dev, "txerr skb %u (data %p) TX complete\n",
+					    macb_tx_ring_wrap(tail), skb->data);
+				bp->stats.tx_packets++;
+				bp->stats.tx_bytes += skb->len;
+			}
 		} else {
 			/*
 			 * "Buffers exhausted mid-frame" errors may only happen
@@ -522,10 +557,7 @@ static void macb_tx_error_task(struct work_struct *work)
 			desc->ctrl = ctrl | MACB_BIT(TX_USED);
 		}
 
-		dma_unmap_single(&bp->pdev->dev, tx_skb->mapping, skb->len,
-				 DMA_TO_DEVICE);
-		tx_skb->skb = NULL;
-		dev_kfree_skb(skb);
+		macb_tx_unmap(bp, tx_skb);
 	}
 
 	/* Make descriptor updates visible to hardware */
@@ -573,20 +605,35 @@ static void macb_tx_interrupt(struct macb *bp)
 
 		ctrl = desc->ctrl;
 
+		/* TX_USED bit is only set by hardware on the very first buffer
+		 * descriptor of the transmitted frame.
+		 */
 		if (!(ctrl & MACB_BIT(TX_USED)))
 			break;
 
-		tx_skb = macb_tx_skb(bp, tail);
-		skb = tx_skb->skb;
+		/* Process all buffers of the current transmitted frame */
+		for (;; tail++) {
+			tx_skb = macb_tx_skb(bp, tail);
+			skb = tx_skb->skb;
+
+			/* First, update TX stats if needed */
+			if (skb) {
+				netdev_vdbg(bp->dev, "skb %u (data %p) TX complete\n",
+					macb_tx_ring_wrap(tail), skb->data);
+				bp->stats.tx_packets++;
+				bp->stats.tx_bytes += skb->len;
+			}
 
-		netdev_vdbg(bp->dev, "skb %u (data %p) TX complete\n",
-			macb_tx_ring_wrap(tail), skb->data);
-		dma_unmap_single(&bp->pdev->dev, tx_skb->mapping, skb->len,
-				 DMA_TO_DEVICE);
-		bp->stats.tx_packets++;
-		bp->stats.tx_bytes += skb->len;
-		tx_skb->skb = NULL;
-		dev_kfree_skb_irq(skb);
+			/* Now we can safely release resources */
+			macb_tx_unmap(bp, tx_skb);
+
+			/* skb is set only for the last buffer of the frame.
+			 * WARNING: at this point skb has been freed by
+			 * macb_tx_unmap().
+			 */
+			if (skb)
+				break;
+		}
 	}
 
 	bp->tx_tail = tail;
@@ -1002,15 +1049,142 @@ static void macb_poll_controller(struct net_device *dev)
 }
 #endif
 
-static int macb_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static inline unsigned int macb_count_tx_descriptors(struct macb *bp,
+						     unsigned int len)
+{
+	return (len + bp->max_tx_length - 1) / bp->max_tx_length;
+}
+
+static unsigned int macb_tx_map(struct macb *bp,
+				struct sk_buff *skb)
 {
-	struct macb *bp = netdev_priv(dev);
 	dma_addr_t mapping;
-	unsigned int len, entry;
+	unsigned int len, entry, i, tx_head = bp->tx_head;
+	struct macb_tx_skb *tx_skb = NULL;
 	struct macb_dma_desc *desc;
-	struct macb_tx_skb *tx_skb;
+	unsigned int offset, size, count = 0;
+	unsigned int f, nr_frags = skb_shinfo(skb)->nr_frags;
+	unsigned int eof = 1;
 	u32 ctrl;
+
+	/* First, map non-paged data */
+	len = skb_headlen(skb);
+	offset = 0;
+	while (len) {
+		size = min(len, bp->max_tx_length);
+		entry = macb_tx_ring_wrap(tx_head);
+		tx_skb = &bp->tx_skb[entry];
+
+		mapping = dma_map_single(&bp->pdev->dev,
+					 skb->data + offset,
+					 size, DMA_TO_DEVICE);
+		if (dma_mapping_error(&bp->pdev->dev, mapping))
+			goto dma_error;
+
+		/* Save info to properly release resources */
+		tx_skb->skb = NULL;
+		tx_skb->mapping = mapping;
+		tx_skb->size = size;
+		tx_skb->mapped_as_page = false;
+
+		len -= size;
+		offset += size;
+		count++;
+		tx_head++;
+	}
+
+	/* Then, map paged data from fragments */
+	for (f = 0; f < nr_frags; f++) {
+		const skb_frag_t *frag = &skb_shinfo(skb)->frags[f];
+
+		len = skb_frag_size(frag);
+		offset = 0;
+		while (len) {
+			size = min(len, bp->max_tx_length);
+			entry = macb_tx_ring_wrap(tx_head);
+			tx_skb = &bp->tx_skb[entry];
+
+			mapping = skb_frag_dma_map(&bp->pdev->dev, frag,
+						   offset, size, DMA_TO_DEVICE);
+			if (dma_mapping_error(&bp->pdev->dev, mapping))
+				goto dma_error;
+
+			/* Save info to properly release resources */
+			tx_skb->skb = NULL;
+			tx_skb->mapping = mapping;
+			tx_skb->size = size;
+			tx_skb->mapped_as_page = true;
+
+			len -= size;
+			offset += size;
+			count++;
+			tx_head++;
+		}
+	}
+
+	/* Should never happen */
+	if (unlikely(tx_skb == NULL)) {
+		netdev_err(bp->dev, "BUG! empty skb!\n");
+		return 0;
+	}
+
+	/* This is the last buffer of the frame: save socket buffer */
+	tx_skb->skb = skb;
+
+	/* Update TX ring: update buffer descriptors in reverse order
+	 * to avoid race condition
+	 */
+
+	/* Set 'TX_USED' bit in buffer descriptor at tx_head position
+	 * to set the end of TX queue
+	 */
+	i = tx_head;
+	entry = macb_tx_ring_wrap(i);
+	ctrl = MACB_BIT(TX_USED);
+	desc = &bp->tx_ring[entry];
+	desc->ctrl = ctrl;
+
+	do {
+		i--;
+		entry = macb_tx_ring_wrap(i);
+		tx_skb = &bp->tx_skb[entry];
+		desc = &bp->tx_ring[entry];
+
+		ctrl = (u32)tx_skb->size;
+		if (eof) {
+			ctrl |= MACB_BIT(TX_LAST);
+			eof = 0;
+		}
+		if (unlikely(entry == (TX_RING_SIZE - 1)))
+			ctrl |= MACB_BIT(TX_WRAP);
+
+		/* Set TX buffer descriptor */
+		desc->addr = tx_skb->mapping;
+		wmb();
+		desc->ctrl = ctrl;
+	} while (i != bp->tx_head);
+
+	bp->tx_head = tx_head;
+
+	return count;
+
+dma_error:
+	netdev_err(bp->dev, "TX DMA map failed\n");
+
+	for (i = bp->tx_head; i != tx_head; i++) {
+		tx_skb = macb_tx_skb(bp, i);
+
+		macb_tx_unmap(bp, tx_skb);
+	}
+
+	return 0;
+}
+
+static int macb_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct macb *bp = netdev_priv(dev);
 	unsigned long flags;
+	unsigned int count, nr_frags, frag_size, f;
 
 #if defined(DEBUG) && defined(VERBOSE_DEBUG)
 	netdev_vdbg(bp->dev,
@@ -1021,44 +1195,35 @@ static int macb_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		       skb->data, 16, true);
 #endif
 
-	len = skb->len;
+	/*
+	 * Count how many TX buffer descriptors are needed to send this
+	 * socket buffer: skb fragments of jumbo frames may need to be
+	 * splitted into many buffer descriptors.
+	 */
+	count = macb_count_tx_descriptors(bp, skb_headlen(skb));
+	nr_frags = skb_shinfo(skb)->nr_frags;
+	for (f = 0; f < nr_frags; f++) {
+		frag_size = skb_frag_size(&skb_shinfo(skb)->frags[f]);
+		count += macb_count_tx_descriptors(bp, frag_size);
+	}
+
 	spin_lock_irqsave(&bp->lock, flags);
 
 	/* This is a hard error, log it. */
-	if (CIRC_SPACE(bp->tx_head, bp->tx_tail, TX_RING_SIZE) < 1) {
+	if (CIRC_SPACE(bp->tx_head, bp->tx_tail, TX_RING_SIZE) < count) {
 		netif_stop_queue(dev);
 		spin_unlock_irqrestore(&bp->lock, flags);
-		netdev_err(bp->dev, "BUG! Tx Ring full when queue awake!\n");
 		netdev_dbg(bp->dev, "tx_head = %u, tx_tail = %u\n",
 			   bp->tx_head, bp->tx_tail);
 		return NETDEV_TX_BUSY;
 	}
 
-	entry = macb_tx_ring_wrap(bp->tx_head);
-	netdev_vdbg(bp->dev, "Allocated ring entry %u\n", entry);
-	mapping = dma_map_single(&bp->pdev->dev, skb->data,
-				 len, DMA_TO_DEVICE);
-	if (dma_mapping_error(&bp->pdev->dev, mapping)) {
+	/* Map socket buffer for DMA transfer */
+	if (!macb_tx_map(bp, skb)) {
 		dev_kfree_skb_any(skb);
 		goto unlock;
 	}
 
-	bp->tx_head++;
-	tx_skb = &bp->tx_skb[entry];
-	tx_skb->skb = skb;
-	tx_skb->mapping = mapping;
-	netdev_vdbg(bp->dev, "Mapped skb data %p to DMA addr %08lx\n",
-		   skb->data, (unsigned long)mapping);
-
-	ctrl = MACB_BF(TX_FRMLEN, len);
-	ctrl |= MACB_BIT(TX_LAST);
-	if (entry == (TX_RING_SIZE - 1))
-		ctrl |= MACB_BIT(TX_WRAP);
-
-	desc = &bp->tx_ring[entry];
-	desc->addr = mapping;
-	desc->ctrl = ctrl;
-
 	/* Make newly initialized descriptor visible to hardware */
 	wmb();
 
@@ -1775,7 +1940,12 @@ static const struct net_device_ops macb_netdev_ops = {
 
 #if defined(CONFIG_OF)
 static struct macb_config pc302gem_config = {
-	.caps = MACB_CAPS_GIGABIT_MODE_AVAILABLE,
+	.caps = MACB_CAPS_SG_DISABLED | MACB_CAPS_GIGABIT_MODE_AVAILABLE,
+	.dma_burst_length = 16,
+};
+
+static struct macb_config sama5d3_config = {
+	.caps = MACB_CAPS_SG_DISABLED | MACB_CAPS_GIGABIT_MODE_AVAILABLE,
 	.dma_burst_length = 16,
 };
 
@@ -1785,6 +1955,7 @@ static const struct of_device_id macb_dt_ids[] = {
 	{ .compatible = "cdns,macb" },
 	{ .compatible = "cdns,pc302-gem", .data = &pc302gem_config },
 	{ .compatible = "cdns,gem", .data = &pc302gem_config },
+	{ .compatible = "atmel,sama5d3-gem", .data = &sama5d3_config },
 	{ /* sentinel */ }
 };
 MODULE_DEVICE_TABLE(of, macb_dt_ids);
@@ -1861,9 +2032,6 @@ static int __init macb_probe(struct platform_device *pdev)
 
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
-	/* TODO: Actually, we have some interesting features... */
-	dev->features |= 0;
-
 	bp = netdev_priv(dev);
 	bp->pdev = pdev;
 	bp->dev = dev;
@@ -1935,17 +2103,25 @@ static int __init macb_probe(struct platform_device *pdev)
 
 	/* setup appropriated routines according to adapter type */
 	if (macb_is_gem(bp)) {
+		bp->max_tx_length = GEM_MAX_TX_LEN;
 		bp->macbgem_ops.mog_alloc_rx_buffers = gem_alloc_rx_buffers;
 		bp->macbgem_ops.mog_free_rx_buffers = gem_free_rx_buffers;
 		bp->macbgem_ops.mog_init_rings = gem_init_rings;
 		bp->macbgem_ops.mog_rx = gem_rx;
 	} else {
+		bp->max_tx_length = MACB_MAX_TX_LEN;
 		bp->macbgem_ops.mog_alloc_rx_buffers = macb_alloc_rx_buffers;
 		bp->macbgem_ops.mog_free_rx_buffers = macb_free_rx_buffers;
 		bp->macbgem_ops.mog_init_rings = macb_init_rings;
 		bp->macbgem_ops.mog_rx = macb_rx;
 	}
 
+	/* Set features */
+	dev->hw_features = NETIF_F_SG;
+	if (bp->caps & MACB_CAPS_SG_DISABLED)
+		dev->hw_features &= ~NETIF_F_SG;
+	dev->features = dev->hw_features;
+
 	/* Set MII management clock divider */
 	config = macb_mdc_clk_div(bp);
 	config |= macb_dbw(bp);
diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
index 7ce751b..7bf8285 100644
--- a/drivers/net/ethernet/cadence/macb.h
+++ b/drivers/net/ethernet/cadence/macb.h
@@ -335,6 +335,7 @@
 #define MACB_CAPS_ISR_CLEAR_ON_WRITE		0x00000001
 #define MACB_CAPS_FIFO_MODE			0x10000000
 #define MACB_CAPS_GIGABIT_MODE_AVAILABLE	0x20000000
+#define MACB_CAPS_SG_DISABLED			0x40000000
 #define MACB_CAPS_MACB_IS_GEM			0x80000000
 
 /* Bit manipulation macros */
@@ -468,14 +469,23 @@ struct macb_dma_desc {
 #define MACB_TX_USED_OFFSET			31
 #define MACB_TX_USED_SIZE			1
 
+#define GEM_TX_FRMLEN_OFFSET			0
+#define GEM_TX_FRMLEN_SIZE			14
+
 /**
  * struct macb_tx_skb - data about an skb which is being transmitted
- * @skb: skb currently being transmitted
- * @mapping: DMA address of the skb's data buffer
+ * @skb: skb currently being transmitted, only set for the last buffer
+ *       of the frame
+ * @mapping: DMA address of the skb's fragment buffer
+ * @size: size of the DMA mapped buffer
+ * @mapped_as_page: true when buffer was mapped with skb_frag_dma_map(),
+ *                  false when buffer was mapped with dma_map_single()
  */
 struct macb_tx_skb {
 	struct sk_buff		*skb;
 	dma_addr_t		mapping;
+	size_t			size;
+	bool			mapped_as_page;
 };
 
 /*
@@ -617,6 +627,7 @@ struct macb {
 	struct sk_buff *skb;			/* holds skb until xmit interrupt completes */
 	dma_addr_t skb_physaddr;		/* phys addr from pci_map_single */
 	int skb_length;				/* saved skb length for pci_unmap_single */
+	unsigned int		max_tx_length;
 };
 
 extern const struct ethtool_ops macb_ethtool_ops;
-- 
1.8.2.2
