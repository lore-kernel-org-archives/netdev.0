From: Rafal Ozieblo <rafalo@cadence.com>
Subject: [PATCH v2] net: macb: Fix 64 bit addressing support for GEM
Date: Fri, 27 Jan 2017 15:08:20 +0000
Message-ID: <1485529700-26171-1-git-send-email-rafalo@cadence.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Rafal Ozieblo <rafalo@cadence.com>
To: Nicolas Ferre <nicolas.ferre@atmel.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>,
        Harini Katakam <harinikatakamlinux@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds support for 32 bit GEM in
64 bit system. It checks capability at runtime
and uses appropriate buffer descriptor.

Signed-off-by: Rafal Ozieblo <rafalo@cadence.com>
---
Changed in v2:
Added upper_32_bits() and lower_32_bits() instead of shifting.
---
 drivers/net/ethernet/cadence/macb.c | 188 +++++++++++++++++++++++++-----------
 drivers/net/ethernet/cadence/macb.h |  20 +++-
 2 files changed, 147 insertions(+), 61 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index c0fb80a..baba2db 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -43,13 +43,13 @@
 #define DEFAULT_RX_RING_SIZE	512 /* must be power of 2 */
 #define MIN_RX_RING_SIZE	64
 #define MAX_RX_RING_SIZE	8192
-#define RX_RING_BYTES(bp)	(sizeof(struct macb_dma_desc)	\
+#define RX_RING_BYTES(bp)	(macb_dma_desc_get_size(bp)	\
 				 * (bp)->rx_ring_size)
 
 #define DEFAULT_TX_RING_SIZE	512 /* must be power of 2 */
 #define MIN_TX_RING_SIZE	64
 #define MAX_TX_RING_SIZE	4096
-#define TX_RING_BYTES(bp)	(sizeof(struct macb_dma_desc)	\
+#define TX_RING_BYTES(bp)	(macb_dma_desc_get_size(bp)	\
 				 * (bp)->tx_ring_size)
 
 /* level of occupied TX descriptors under which we wake up TX process */
@@ -78,6 +78,37 @@
  */
 #define MACB_HALT_TIMEOUT	1230
 
+/* DMA buffer descriptor might be different size
+ * depends on hardware configuration.
+ */
+static unsigned int macb_dma_desc_get_size(struct macb *bp)
+{
+#ifdef CONFIG_ARCH_DMA_ADDR_T_64BIT
+	if (bp->hw_dma_cap == HW_DMA_CAP_64B)
+		return sizeof(struct macb_dma_desc) + sizeof(struct macb_dma_desc_64);
+#endif
+	return sizeof(struct macb_dma_desc);
+}
+
+static unsigned int macb_adj_dma_desc_idx(struct macb *bp, unsigned int idx)
+{
+#ifdef CONFIG_ARCH_DMA_ADDR_T_64BIT
+	/* Dma buffer descriptor is 4 words length (instead of 2 words)
+	 * for 64b GEM.
+	 */
+	if (bp->hw_dma_cap == HW_DMA_CAP_64B)
+		idx <<= 1;
+#endif
+	return idx;
+}
+
+#ifdef CONFIG_ARCH_DMA_ADDR_T_64BIT
+static struct macb_dma_desc_64 *macb_64b_desc(struct macb *bp, struct macb_dma_desc *desc)
+{
+	return (struct macb_dma_desc_64 *)((void *)desc + sizeof(struct macb_dma_desc));
+}
+#endif
+
 /* Ring buffer accessors */
 static unsigned int macb_tx_ring_wrap(struct macb *bp, unsigned int index)
 {
@@ -87,7 +118,9 @@ static unsigned int macb_tx_ring_wrap(struct macb *bp, unsigned int index)
 static struct macb_dma_desc *macb_tx_desc(struct macb_queue *queue,
 					  unsigned int index)
 {
-	return &queue->tx_ring[macb_tx_ring_wrap(queue->bp, index)];
+	index = macb_tx_ring_wrap(queue->bp, index);
+	index = macb_adj_dma_desc_idx(queue->bp, index);
+	return &queue->tx_ring[index];
 }
 
 static struct macb_tx_skb *macb_tx_skb(struct macb_queue *queue,
@@ -101,7 +134,7 @@ static dma_addr_t macb_tx_dma(struct macb_queue *queue, unsigned int index)
 	dma_addr_t offset;
 
 	offset = macb_tx_ring_wrap(queue->bp, index) *
-		 sizeof(struct macb_dma_desc);
+			macb_dma_desc_get_size(queue->bp);
 
 	return queue->tx_ring_dma + offset;
 }
@@ -113,7 +146,9 @@ static unsigned int macb_rx_ring_wrap(struct macb *bp, unsigned int index)
 
 static struct macb_dma_desc *macb_rx_desc(struct macb *bp, unsigned int index)
 {
-	return &bp->rx_ring[macb_rx_ring_wrap(bp, index)];
+	index = macb_rx_ring_wrap(bp, index);
+	index = macb_adj_dma_desc_idx(bp, index);
+	return &bp->rx_ring[index];
 }
 
 static void *macb_rx_buffer(struct macb *bp, unsigned int index)
@@ -560,12 +595,32 @@ static void macb_tx_unmap(struct macb *bp, struct macb_tx_skb *tx_skb)
 	}
 }
 
-static inline void macb_set_addr(struct macb_dma_desc *desc, dma_addr_t addr)
+static void macb_set_addr(struct macb *bp, struct macb_dma_desc *desc, dma_addr_t addr)
 {
-	desc->addr = (u32)addr;
 #ifdef CONFIG_ARCH_DMA_ADDR_T_64BIT
-	desc->addrh = (u32)(addr >> 32);
+	struct macb_dma_desc_64 *desc_64;
+
+	if (bp->hw_dma_cap == HW_DMA_CAP_64B) {
+		desc_64 = macb_64b_desc(bp, desc);
+		desc_64->addrh = upper_32_bits(addr);
+	}
 #endif
+	desc->addr = lower_32_bits(addr);
+}
+
+static dma_addr_t macb_get_addr(struct macb *bp, struct macb_dma_desc *desc)
+{
+	dma_addr_t addr = 0;
+#ifdef CONFIG_ARCH_DMA_ADDR_T_64BIT
+	struct macb_dma_desc_64 *desc_64;
+
+	if (bp->hw_dma_cap == HW_DMA_CAP_64B) {
+		desc_64 = macb_64b_desc(bp, desc);
+		addr = ((u64)(desc_64->addrh) << 32);
+	}
+#endif
+	addr |= MACB_BF(RX_WADDR, MACB_BFEXT(RX_WADDR, desc->addr));
+	return addr;
 }
 
 static void macb_tx_error_task(struct work_struct *work)
@@ -649,16 +704,17 @@ static void macb_tx_error_task(struct work_struct *work)
 
 	/* Set end of TX queue */
 	desc = macb_tx_desc(queue, 0);
-	macb_set_addr(desc, 0);
+	macb_set_addr(bp, desc, 0);
 	desc->ctrl = MACB_BIT(TX_USED);
 
 	/* Make descriptor updates visible to hardware */
 	wmb();
 
 	/* Reinitialize the TX desc queue */
-	queue_writel(queue, TBQP, (u32)(queue->tx_ring_dma));
+	queue_writel(queue, TBQP, lower_32_bits(queue->tx_ring_dma));
 #ifdef CONFIG_ARCH_DMA_ADDR_T_64BIT
-	queue_writel(queue, TBQPH, (u32)(queue->tx_ring_dma >> 32));
+	if (bp->hw_dma_cap == HW_DMA_CAP_64B)
+		queue_writel(queue, TBQPH, upper_32_bits(queue->tx_ring_dma));
 #endif
 	/* Make TX ring reflect state of hardware */
 	queue->tx_head = 0;
@@ -750,6 +806,7 @@ static void gem_rx_refill(struct macb *bp)
 	unsigned int		entry;
 	struct sk_buff		*skb;
 	dma_addr_t		paddr;
+	struct macb_dma_desc *desc;
 
 	while (CIRC_SPACE(bp->rx_prepared_head, bp->rx_tail,
 			  bp->rx_ring_size) > 0) {
@@ -759,6 +816,7 @@ static void gem_rx_refill(struct macb *bp)
 		rmb();
 
 		bp->rx_prepared_head++;
+		desc = macb_rx_desc(bp, entry);
 
 		if (!bp->rx_skbuff[entry]) {
 			/* allocate sk_buff for this free entry in ring */
@@ -782,14 +840,14 @@ static void gem_rx_refill(struct macb *bp)
 
 			if (entry == bp->rx_ring_size - 1)
 				paddr |= MACB_BIT(RX_WRAP);
-			macb_set_addr(&(bp->rx_ring[entry]), paddr);
-			bp->rx_ring[entry].ctrl = 0;
+			macb_set_addr(bp, desc, paddr);
+			desc->ctrl = 0;
 
 			/* properly align Ethernet header */
 			skb_reserve(skb, NET_IP_ALIGN);
 		} else {
-			bp->rx_ring[entry].addr &= ~MACB_BIT(RX_USED);
-			bp->rx_ring[entry].ctrl = 0;
+			desc->addr &= ~MACB_BIT(RX_USED);
+			desc->ctrl = 0;
 		}
 	}
 
@@ -835,16 +893,13 @@ static int gem_rx(struct macb *bp, int budget)
 		bool rxused;
 
 		entry = macb_rx_ring_wrap(bp, bp->rx_tail);
-		desc = &bp->rx_ring[entry];
+		desc = macb_rx_desc(bp, entry);
 
 		/* Make hw descriptor updates visible to CPU */
 		rmb();
 
 		rxused = (desc->addr & MACB_BIT(RX_USED)) ? true : false;
-		addr = MACB_BF(RX_WADDR, MACB_BFEXT(RX_WADDR, desc->addr));
-#ifdef CONFIG_ARCH_DMA_ADDR_T_64BIT
-		addr |= ((u64)(desc->addrh) << 32);
-#endif
+		addr = macb_get_addr(bp, desc);
 		ctrl = desc->ctrl;
 
 		if (!rxused)
@@ -987,15 +1042,17 @@ static int macb_rx_frame(struct macb *bp, unsigned int first_frag,
 static inline void macb_init_rx_ring(struct macb *bp)
 {
 	dma_addr_t addr;
+	struct macb_dma_desc *desc = NULL;
 	int i;
 
 	addr = bp->rx_buffers_dma;
 	for (i = 0; i < bp->rx_ring_size; i++) {
-		bp->rx_ring[i].addr = addr;
-		bp->rx_ring[i].ctrl = 0;
+		desc = macb_rx_desc(bp, i);
+		macb_set_addr(bp, desc, addr);
+		desc->ctrl = 0;
 		addr += bp->rx_buffer_size;
 	}
-	bp->rx_ring[bp->rx_ring_size - 1].addr |= MACB_BIT(RX_WRAP);
+	desc->addr |= MACB_BIT(RX_WRAP);
 	bp->rx_tail = 0;
 }
 
@@ -1008,15 +1065,14 @@ static int macb_rx(struct macb *bp, int budget)
 
 	for (tail = bp->rx_tail; budget > 0; tail++) {
 		struct macb_dma_desc *desc = macb_rx_desc(bp, tail);
-		u32 addr, ctrl;
+		u32 ctrl;
 
 		/* Make hw descriptor updates visible to CPU */
 		rmb();
 
-		addr = desc->addr;
 		ctrl = desc->ctrl;
 
-		if (!(addr & MACB_BIT(RX_USED)))
+		if (!(desc->addr & MACB_BIT(RX_USED)))
 			break;
 
 		if (ctrl & MACB_BIT(RX_SOF)) {
@@ -1336,7 +1392,7 @@ static unsigned int macb_tx_map(struct macb *bp,
 	i = tx_head;
 	entry = macb_tx_ring_wrap(bp, i);
 	ctrl = MACB_BIT(TX_USED);
-	desc = &queue->tx_ring[entry];
+	desc = macb_tx_desc(queue, entry);
 	desc->ctrl = ctrl;
 
 	if (lso_ctrl) {
@@ -1358,7 +1414,7 @@ static unsigned int macb_tx_map(struct macb *bp,
 		i--;
 		entry = macb_tx_ring_wrap(bp, i);
 		tx_skb = &queue->tx_skb[entry];
-		desc = &queue->tx_ring[entry];
+		desc = macb_tx_desc(queue, entry);
 
 		ctrl = (u32)tx_skb->size;
 		if (eof) {
@@ -1379,7 +1435,7 @@ static unsigned int macb_tx_map(struct macb *bp,
 			ctrl |= MACB_BF(MSS_MFS, mss_mfs);
 
 		/* Set TX buffer descriptor */
-		macb_set_addr(desc, tx_skb->mapping);
+		macb_set_addr(bp, desc, tx_skb->mapping);
 		/* desc->addr must be visible to hardware before clearing
 		 * 'TX_USED' bit in desc->ctrl.
 		 */
@@ -1586,11 +1642,9 @@ static void gem_free_rx_buffers(struct macb *bp)
 		if (!skb)
 			continue;
 
-		desc = &bp->rx_ring[i];
-		addr = MACB_BF(RX_WADDR, MACB_BFEXT(RX_WADDR, desc->addr));
-#ifdef CONFIG_ARCH_DMA_ADDR_T_64BIT
-		addr |= ((u64)(desc->addrh) << 32);
-#endif
+		desc = macb_rx_desc(bp, i);
+		addr = macb_get_addr(bp, desc);
+
 		dma_unmap_single(&bp->pdev->dev, addr, bp->rx_buffer_size,
 				 DMA_FROM_DEVICE);
 		dev_kfree_skb_any(skb);
@@ -1711,15 +1765,17 @@ static int macb_alloc_consistent(struct macb *bp)
 static void gem_init_rings(struct macb *bp)
 {
 	struct macb_queue *queue;
+	struct macb_dma_desc *desc = NULL;
 	unsigned int q;
 	int i;
 
 	for (q = 0, queue = bp->queues; q < bp->num_queues; ++q, ++queue) {
 		for (i = 0; i < bp->tx_ring_size; i++) {
-			queue->tx_ring[i].addr = 0;
-			queue->tx_ring[i].ctrl = MACB_BIT(TX_USED);
+			desc = macb_tx_desc(queue, i);
+			macb_set_addr(bp, desc, 0);
+			desc->ctrl = MACB_BIT(TX_USED);
 		}
-		queue->tx_ring[bp->tx_ring_size - 1].ctrl |= MACB_BIT(TX_WRAP);
+		desc->ctrl |= MACB_BIT(TX_WRAP);
 		queue->tx_head = 0;
 		queue->tx_tail = 0;
 	}
@@ -1733,16 +1789,18 @@ static void gem_init_rings(struct macb *bp)
 static void macb_init_rings(struct macb *bp)
 {
 	int i;
+	struct macb_dma_desc *desc = NULL;
 
 	macb_init_rx_ring(bp);
 
 	for (i = 0; i < bp->tx_ring_size; i++) {
-		bp->queues[0].tx_ring[i].addr = 0;
-		bp->queues[0].tx_ring[i].ctrl = MACB_BIT(TX_USED);
+		desc = macb_tx_desc(&bp->queues[0], i);
+		macb_set_addr(bp, desc, 0);
+		desc->ctrl = MACB_BIT(TX_USED);
 	}
 	bp->queues[0].tx_head = 0;
 	bp->queues[0].tx_tail = 0;
-	bp->queues[0].tx_ring[bp->tx_ring_size - 1].ctrl |= MACB_BIT(TX_WRAP);
+	desc->ctrl |= MACB_BIT(TX_WRAP);
 }
 
 static void macb_reset_hw(struct macb *bp)
@@ -1863,7 +1921,8 @@ static void macb_configure_dma(struct macb *bp)
 			dmacfg &= ~GEM_BIT(TXCOEN);
 
 #ifdef CONFIG_ARCH_DMA_ADDR_T_64BIT
-		dmacfg |= GEM_BIT(ADDR64);
+		if (bp->hw_dma_cap == HW_DMA_CAP_64B)
+			dmacfg |= GEM_BIT(ADDR64);
 #endif
 		netdev_dbg(bp->dev, "Cadence configure DMA with 0x%08x\n",
 			   dmacfg);
@@ -1910,14 +1969,16 @@ static void macb_init_hw(struct macb *bp)
 	macb_configure_dma(bp);
 
 	/* Initialize TX and RX buffers */
-	macb_writel(bp, RBQP, (u32)(bp->rx_ring_dma));
+	macb_writel(bp, RBQP, lower_32_bits(bp->rx_ring_dma));
 #ifdef CONFIG_ARCH_DMA_ADDR_T_64BIT
-	macb_writel(bp, RBQPH, (u32)(bp->rx_ring_dma >> 32));
+	if (bp->hw_dma_cap == HW_DMA_CAP_64B)
+		macb_writel(bp, RBQPH, upper_32_bits(bp->rx_ring_dma));
 #endif
 	for (q = 0, queue = bp->queues; q < bp->num_queues; ++q, ++queue) {
-		queue_writel(queue, TBQP, (u32)(queue->tx_ring_dma));
+		queue_writel(queue, TBQP, lower_32_bits(queue->tx_ring_dma));
 #ifdef CONFIG_ARCH_DMA_ADDR_T_64BIT
-		queue_writel(queue, TBQPH, (u32)(queue->tx_ring_dma >> 32));
+		if (bp->hw_dma_cap == HW_DMA_CAP_64B)
+			queue_writel(queue, TBQPH, upper_32_bits(queue->tx_ring_dma));
 #endif
 
 		/* Enable interrupts */
@@ -2627,7 +2688,8 @@ static int macb_init(struct platform_device *pdev)
 			queue->IMR  = GEM_IMR(hw_q - 1);
 			queue->TBQP = GEM_TBQP(hw_q - 1);
 #ifdef CONFIG_ARCH_DMA_ADDR_T_64BIT
-			queue->TBQPH = GEM_TBQPH(hw_q -1);
+			if (bp->hw_dma_cap == HW_DMA_CAP_64B)
+				queue->TBQPH = GEM_TBQPH(hw_q - 1);
 #endif
 		} else {
 			/* queue0 uses legacy registers */
@@ -2637,7 +2699,8 @@ static int macb_init(struct platform_device *pdev)
 			queue->IMR  = MACB_IMR;
 			queue->TBQP = MACB_TBQP;
 #ifdef CONFIG_ARCH_DMA_ADDR_T_64BIT
-			queue->TBQPH = MACB_TBQPH;
+			if (bp->hw_dma_cap == HW_DMA_CAP_64B)
+				queue->TBQPH = MACB_TBQPH;
 #endif
 		}
 
@@ -2730,13 +2793,14 @@ static int macb_init(struct platform_device *pdev)
 static int at91ether_start(struct net_device *dev)
 {
 	struct macb *lp = netdev_priv(dev);
+	struct macb_dma_desc *desc;
 	dma_addr_t addr;
 	u32 ctl;
 	int i;
 
 	lp->rx_ring = dma_alloc_coherent(&lp->pdev->dev,
 					 (AT91ETHER_MAX_RX_DESCR *
-					  sizeof(struct macb_dma_desc)),
+					  macb_dma_desc_get_size(lp)),
 					 &lp->rx_ring_dma, GFP_KERNEL);
 	if (!lp->rx_ring)
 		return -ENOMEM;
@@ -2748,7 +2812,7 @@ static int at91ether_start(struct net_device *dev)
 	if (!lp->rx_buffers) {
 		dma_free_coherent(&lp->pdev->dev,
 				  AT91ETHER_MAX_RX_DESCR *
-				  sizeof(struct macb_dma_desc),
+				  macb_dma_desc_get_size(lp),
 				  lp->rx_ring, lp->rx_ring_dma);
 		lp->rx_ring = NULL;
 		return -ENOMEM;
@@ -2756,13 +2820,14 @@ static int at91ether_start(struct net_device *dev)
 
 	addr = lp->rx_buffers_dma;
 	for (i = 0; i < AT91ETHER_MAX_RX_DESCR; i++) {
-		lp->rx_ring[i].addr = addr;
-		lp->rx_ring[i].ctrl = 0;
+		desc = macb_rx_desc(lp, i);
+		macb_set_addr(lp, desc, addr);
+		desc->ctrl = 0;
 		addr += AT91ETHER_MAX_RBUFF_SZ;
 	}
 
 	/* Set the Wrap bit on the last descriptor */
-	lp->rx_ring[AT91ETHER_MAX_RX_DESCR - 1].addr |= MACB_BIT(RX_WRAP);
+	desc->addr |= MACB_BIT(RX_WRAP);
 
 	/* Reset buffer index */
 	lp->rx_tail = 0;
@@ -2834,7 +2899,7 @@ static int at91ether_close(struct net_device *dev)
 
 	dma_free_coherent(&lp->pdev->dev,
 			  AT91ETHER_MAX_RX_DESCR *
-			  sizeof(struct macb_dma_desc),
+			  macb_dma_desc_get_size(lp),
 			  lp->rx_ring, lp->rx_ring_dma);
 	lp->rx_ring = NULL;
 
@@ -2885,13 +2950,15 @@ static int at91ether_start_xmit(struct sk_buff *skb, struct net_device *dev)
 static void at91ether_rx(struct net_device *dev)
 {
 	struct macb *lp = netdev_priv(dev);
+	struct macb_dma_desc *desc;
 	unsigned char *p_recv;
 	struct sk_buff *skb;
 	unsigned int pktlen;
 
-	while (lp->rx_ring[lp->rx_tail].addr & MACB_BIT(RX_USED)) {
+	desc = macb_rx_desc(lp, lp->rx_tail);
+	while (desc->addr & MACB_BIT(RX_USED)) {
 		p_recv = lp->rx_buffers + lp->rx_tail * AT91ETHER_MAX_RBUFF_SZ;
-		pktlen = MACB_BF(RX_FRMLEN, lp->rx_ring[lp->rx_tail].ctrl);
+		pktlen = MACB_BF(RX_FRMLEN, desc->ctrl);
 		skb = netdev_alloc_skb(dev, pktlen + 2);
 		if (skb) {
 			skb_reserve(skb, 2);
@@ -2905,17 +2972,19 @@ static void at91ether_rx(struct net_device *dev)
 			lp->stats.rx_dropped++;
 		}
 
-		if (lp->rx_ring[lp->rx_tail].ctrl & MACB_BIT(RX_MHASH_MATCH))
+		if (desc->ctrl & MACB_BIT(RX_MHASH_MATCH))
 			lp->stats.multicast++;
 
 		/* reset ownership bit */
-		lp->rx_ring[lp->rx_tail].addr &= ~MACB_BIT(RX_USED);
+		desc->addr &= ~MACB_BIT(RX_USED);
 
 		/* wrap after last buffer */
 		if (lp->rx_tail == AT91ETHER_MAX_RX_DESCR - 1)
 			lp->rx_tail = 0;
 		else
 			lp->rx_tail++;
+
+		desc = macb_rx_desc(lp, lp->rx_tail);
 	}
 }
 
@@ -3211,8 +3280,11 @@ static int macb_probe(struct platform_device *pdev)
 	device_init_wakeup(&pdev->dev, bp->wol & MACB_WOL_HAS_MAGIC_PACKET);
 
 #ifdef CONFIG_ARCH_DMA_ADDR_T_64BIT
-	if (GEM_BFEXT(DBWDEF, gem_readl(bp, DCFG1)) > GEM_DBW32)
+	if (GEM_BFEXT(DAW64, gem_readl(bp, DCFG6))) {
 		dma_set_mask(&pdev->dev, DMA_BIT_MASK(44));
+		bp->hw_dma_cap = HW_DMA_CAP_64B;
+	} else
+		bp->hw_dma_cap = HW_DMA_CAP_32B;
 #endif
 
 	spin_lock_init(&bp->lock);
diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
index d67adad..fc8550a 100644
--- a/drivers/net/ethernet/cadence/macb.h
+++ b/drivers/net/ethernet/cadence/macb.h
@@ -385,6 +385,8 @@
 /* Bitfields in DCFG6. */
 #define GEM_PBUF_LSO_OFFSET			27
 #define GEM_PBUF_LSO_SIZE			1
+#define GEM_DAW64_OFFSET			23
+#define GEM_DAW64_SIZE				1
 
 /* Constants for CLK */
 #define MACB_CLK_DIV8				0
@@ -487,12 +489,20 @@
 struct macb_dma_desc {
 	u32	addr;
 	u32	ctrl;
+};
+
 #ifdef CONFIG_ARCH_DMA_ADDR_T_64BIT
-	u32     addrh;
-	u32     resvd;
-#endif
+enum macb_hw_dma_cap {
+	HW_DMA_CAP_32B,
+	HW_DMA_CAP_64B,
 };
 
+struct macb_dma_desc_64 {
+	u32 addrh;
+	u32 resvd;
+};
+#endif
+
 /* DMA descriptor bitfields */
 #define MACB_RX_USED_OFFSET			0
 #define MACB_RX_USED_SIZE			1
@@ -874,6 +884,10 @@ struct macb {
 	unsigned int		jumbo_max_len;
 
 	u32			wol;
+
+#ifdef CONFIG_ARCH_DMA_ADDR_T_64BIT
+	enum macb_hw_dma_cap hw_dma_cap;
+#endif
 };
 
 static inline bool macb_is_gem(struct macb *bp)
-- 
2.4.5
