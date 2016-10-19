From: Zach Brown <zach.brown@ni.com>
Subject: [PATCH 1/2] net: macb: Use variables with defaults for tx/rx ring sizes instead of hardcoded values
Date: Wed, 19 Oct 2016 09:56:57 -0500
Message-ID: <1476889018-8357-2-git-send-email-zach.brown@ni.com>
References: <1476889018-8357-1-git-send-email-zach.brown@ni.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <linux-kernel@vger.kernel.org>,
        <netdev@vger.kernel.org>
To: <nicolas.ferre@atmel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1476889018-8357-1-git-send-email-zach.brown@ni.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The macb driver hardcoded the tx/rx ring sizes. This made it
impossible to change the sizes at run time.

Add tx_ring_size, and rx_ring_size variables to macb object, which
are initilized with default vales during macb_init. Change all
references to RX_RING_SIZE and TX_RING_SIZE to their respective
replacements.

Signed-off-by: Zach Brown <zach.brown@ni.com>
---
 drivers/net/ethernet/cadence/macb.c | 114 ++++++++++++++++++++----------------
 drivers/net/ethernet/cadence/macb.h |   3 +
 2 files changed, 65 insertions(+), 52 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index e83781a..644975d 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -37,14 +37,16 @@
 
 #define MACB_RX_BUFFER_SIZE	128
 #define RX_BUFFER_MULTIPLE	64  /* bytes */
-#define RX_RING_SIZE		512 /* must be power of 2 */
-#define RX_RING_BYTES		(sizeof(struct macb_dma_desc) * RX_RING_SIZE)
+#define DEFAULT_RX_RING_SIZE	512 /* must be power of 2 */
+#define RX_RING_BYTES(bp)	(sizeof(struct macb_dma_desc)	\
+				 * (bp)->rx_ring_size)
 
-#define TX_RING_SIZE		128 /* must be power of 2 */
-#define TX_RING_BYTES		(sizeof(struct macb_dma_desc) * TX_RING_SIZE)
+#define DEFAULT_TX_RING_SIZE	512 /* must be power of 2 */
+#define TX_RING_BYTES(bp)	(sizeof(struct macb_dma_desc)	\
+				 * (bp)->tx_ring_size)
 
 /* level of occupied TX descriptors under which we wake up TX process */
-#define MACB_TX_WAKEUP_THRESH	(3 * TX_RING_SIZE / 4)
+#define MACB_TX_WAKEUP_THRESH(bp)	(3 * (bp)->tx_ring_size / 4)
 
 #define MACB_RX_INT_FLAGS	(MACB_BIT(RCOMP) | MACB_BIT(RXUBR)	\
 				 | MACB_BIT(ISR_ROVR))
@@ -67,45 +69,47 @@
 #define MACB_HALT_TIMEOUT	1230
 
 /* Ring buffer accessors */
-static unsigned int macb_tx_ring_wrap(unsigned int index)
+static unsigned int macb_tx_ring_wrap(struct macb *bp, unsigned int index)
 {
-	return index & (TX_RING_SIZE - 1);
+	return index & (bp->tx_ring_size - 1);
 }
 
 static struct macb_dma_desc *macb_tx_desc(struct macb_queue *queue,
 					  unsigned int index)
 {
-	return &queue->tx_ring[macb_tx_ring_wrap(index)];
+	return &queue->tx_ring[macb_tx_ring_wrap(queue->bp, index)];
 }
 
 static struct macb_tx_skb *macb_tx_skb(struct macb_queue *queue,
 				       unsigned int index)
 {
-	return &queue->tx_skb[macb_tx_ring_wrap(index)];
+	return &queue->tx_skb[macb_tx_ring_wrap(queue->bp, index)];
 }
 
 static dma_addr_t macb_tx_dma(struct macb_queue *queue, unsigned int index)
 {
 	dma_addr_t offset;
 
-	offset = macb_tx_ring_wrap(index) * sizeof(struct macb_dma_desc);
+	offset = macb_tx_ring_wrap(queue->bp, index) *
+		 sizeof(struct macb_dma_desc);
 
 	return queue->tx_ring_dma + offset;
 }
 
-static unsigned int macb_rx_ring_wrap(unsigned int index)
+static unsigned int macb_rx_ring_wrap(struct macb *bp, unsigned int index)
 {
-	return index & (RX_RING_SIZE - 1);
+	return index & (bp->rx_ring_size - 1);
 }
 
 static struct macb_dma_desc *macb_rx_desc(struct macb *bp, unsigned int index)
 {
-	return &bp->rx_ring[macb_rx_ring_wrap(index)];
+	return &bp->rx_ring[macb_rx_ring_wrap(bp, index)];
 }
 
 static void *macb_rx_buffer(struct macb *bp, unsigned int index)
 {
-	return bp->rx_buffers + bp->rx_buffer_size * macb_rx_ring_wrap(index);
+	return bp->rx_buffers + bp->rx_buffer_size *
+	       macb_rx_ring_wrap(bp, index);
 }
 
 /* I/O accessors */
@@ -608,7 +612,8 @@ static void macb_tx_error_task(struct work_struct *work)
 			 */
 			if (!(ctrl & MACB_BIT(TX_BUF_EXHAUSTED))) {
 				netdev_vdbg(bp->dev, "txerr skb %u (data %p) TX complete\n",
-					    macb_tx_ring_wrap(tail), skb->data);
+					    macb_tx_ring_wrap(bp, tail),
+					    skb->data);
 				bp->stats.tx_packets++;
 				bp->stats.tx_bytes += skb->len;
 			}
@@ -700,7 +705,8 @@ static void macb_tx_interrupt(struct macb_queue *queue)
 			/* First, update TX stats if needed */
 			if (skb) {
 				netdev_vdbg(bp->dev, "skb %u (data %p) TX complete\n",
-					    macb_tx_ring_wrap(tail), skb->data);
+					    macb_tx_ring_wrap(bp, tail),
+					    skb->data);
 				bp->stats.tx_packets++;
 				bp->stats.tx_bytes += skb->len;
 			}
@@ -720,7 +726,7 @@ static void macb_tx_interrupt(struct macb_queue *queue)
 	queue->tx_tail = tail;
 	if (__netif_subqueue_stopped(bp->dev, queue_index) &&
 	    CIRC_CNT(queue->tx_head, queue->tx_tail,
-		     TX_RING_SIZE) <= MACB_TX_WAKEUP_THRESH)
+		     bp->tx_ring_size) <= MACB_TX_WAKEUP_THRESH(bp))
 		netif_wake_subqueue(bp->dev, queue_index);
 }
 
@@ -731,8 +737,8 @@ static void gem_rx_refill(struct macb *bp)
 	dma_addr_t		paddr;
 
 	while (CIRC_SPACE(bp->rx_prepared_head, bp->rx_tail,
-			  RX_RING_SIZE) > 0) {
-		entry = macb_rx_ring_wrap(bp->rx_prepared_head);
+			  bp->rx_ring_size) > 0) {
+		entry = macb_rx_ring_wrap(bp, bp->rx_prepared_head);
 
 		/* Make hw descriptor updates visible to CPU */
 		rmb();
@@ -759,7 +765,7 @@ static void gem_rx_refill(struct macb *bp)
 
 			bp->rx_skbuff[entry] = skb;
 
-			if (entry == RX_RING_SIZE - 1)
+			if (entry == bp->rx_ring_size - 1)
 				paddr |= MACB_BIT(RX_WRAP);
 			macb_set_addr(&(bp->rx_ring[entry]), paddr);
 			bp->rx_ring[entry].ctrl = 0;
@@ -813,7 +819,7 @@ static int gem_rx(struct macb *bp, int budget)
 		dma_addr_t addr;
 		bool rxused;
 
-		entry = macb_rx_ring_wrap(bp->rx_tail);
+		entry = macb_rx_ring_wrap(bp, bp->rx_tail);
 		desc = &bp->rx_ring[entry];
 
 		/* Make hw descriptor updates visible to CPU */
@@ -895,8 +901,8 @@ static int macb_rx_frame(struct macb *bp, unsigned int first_frag,
 	len = desc->ctrl & bp->rx_frm_len_mask;
 
 	netdev_vdbg(bp->dev, "macb_rx_frame frags %u - %u (len %u)\n",
-		    macb_rx_ring_wrap(first_frag),
-		    macb_rx_ring_wrap(last_frag), len);
+		macb_rx_ring_wrap(bp, first_frag),
+		macb_rx_ring_wrap(bp, last_frag), len);
 
 	/* The ethernet header starts NET_IP_ALIGN bytes into the
 	 * first buffer. Since the header is 14 bytes, this makes the
@@ -969,12 +975,12 @@ static inline void macb_init_rx_ring(struct macb *bp)
 	int i;
 
 	addr = bp->rx_buffers_dma;
-	for (i = 0; i < RX_RING_SIZE; i++) {
+	for (i = 0; i < bp->rx_ring_size; i++) {
 		bp->rx_ring[i].addr = addr;
 		bp->rx_ring[i].ctrl = 0;
 		addr += bp->rx_buffer_size;
 	}
-	bp->rx_ring[RX_RING_SIZE - 1].addr |= MACB_BIT(RX_WRAP);
+	bp->rx_ring[bp->rx_ring_size - 1].addr |= MACB_BIT(RX_WRAP);
 }
 
 static int macb_rx(struct macb *bp, int budget)
@@ -1228,7 +1234,7 @@ static unsigned int macb_tx_map(struct macb *bp,
 	offset = 0;
 	while (len) {
 		size = min(len, bp->max_tx_length);
-		entry = macb_tx_ring_wrap(tx_head);
+		entry = macb_tx_ring_wrap(bp, tx_head);
 		tx_skb = &queue->tx_skb[entry];
 
 		mapping = dma_map_single(&bp->pdev->dev,
@@ -1257,7 +1263,7 @@ static unsigned int macb_tx_map(struct macb *bp,
 		offset = 0;
 		while (len) {
 			size = min(len, bp->max_tx_length);
-			entry = macb_tx_ring_wrap(tx_head);
+			entry = macb_tx_ring_wrap(bp, tx_head);
 			tx_skb = &queue->tx_skb[entry];
 
 			mapping = skb_frag_dma_map(&bp->pdev->dev, frag,
@@ -1295,14 +1301,14 @@ static unsigned int macb_tx_map(struct macb *bp,
 	 * to set the end of TX queue
 	 */
 	i = tx_head;
-	entry = macb_tx_ring_wrap(i);
+	entry = macb_tx_ring_wrap(bp, i);
 	ctrl = MACB_BIT(TX_USED);
 	desc = &queue->tx_ring[entry];
 	desc->ctrl = ctrl;
 
 	do {
 		i--;
-		entry = macb_tx_ring_wrap(i);
+		entry = macb_tx_ring_wrap(bp, i);
 		tx_skb = &queue->tx_skb[entry];
 		desc = &queue->tx_ring[entry];
 
@@ -1311,7 +1317,7 @@ static unsigned int macb_tx_map(struct macb *bp,
 			ctrl |= MACB_BIT(TX_LAST);
 			eof = 0;
 		}
-		if (unlikely(entry == (TX_RING_SIZE - 1)))
+		if (unlikely(entry == (bp->tx_ring_size - 1)))
 			ctrl |= MACB_BIT(TX_WRAP);
 
 		/* Set TX buffer descriptor */
@@ -1388,7 +1394,8 @@ static int macb_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	spin_lock_irqsave(&bp->lock, flags);
 
 	/* This is a hard error, log it. */
-	if (CIRC_SPACE(queue->tx_head, queue->tx_tail, TX_RING_SIZE) < count) {
+	if (CIRC_SPACE(queue->tx_head, queue->tx_tail,
+		       bp->tx_ring_size) < count) {
 		netif_stop_subqueue(dev, queue_index);
 		spin_unlock_irqrestore(&bp->lock, flags);
 		netdev_dbg(bp->dev, "tx_head = %u, tx_tail = %u\n",
@@ -1414,7 +1421,7 @@ static int macb_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	macb_writel(bp, NCR, macb_readl(bp, NCR) | MACB_BIT(TSTART));
 
-	if (CIRC_SPACE(queue->tx_head, queue->tx_tail, TX_RING_SIZE) < 1)
+	if (CIRC_SPACE(queue->tx_head, queue->tx_tail, bp->tx_ring_size) < 1)
 		netif_stop_subqueue(dev, queue_index);
 
 unlock:
@@ -1453,7 +1460,7 @@ static void gem_free_rx_buffers(struct macb *bp)
 	if (!bp->rx_skbuff)
 		return;
 
-	for (i = 0; i < RX_RING_SIZE; i++) {
+	for (i = 0; i < bp->rx_ring_size; i++) {
 		skb = bp->rx_skbuff[i];
 
 		if (!skb)
@@ -1478,7 +1485,7 @@ static void macb_free_rx_buffers(struct macb *bp)
 {
 	if (bp->rx_buffers) {
 		dma_free_coherent(&bp->pdev->dev,
-				  RX_RING_SIZE * bp->rx_buffer_size,
+				  bp->rx_ring_size * bp->rx_buffer_size,
 				  bp->rx_buffers, bp->rx_buffers_dma);
 		bp->rx_buffers = NULL;
 	}
@@ -1491,7 +1498,7 @@ static void macb_free_consistent(struct macb *bp)
 
 	bp->macbgem_ops.mog_free_rx_buffers(bp);
 	if (bp->rx_ring) {
-		dma_free_coherent(&bp->pdev->dev, RX_RING_BYTES,
+		dma_free_coherent(&bp->pdev->dev, RX_RING_BYTES(bp),
 				  bp->rx_ring, bp->rx_ring_dma);
 		bp->rx_ring = NULL;
 	}
@@ -1500,7 +1507,7 @@ static void macb_free_consistent(struct macb *bp)
 		kfree(queue->tx_skb);
 		queue->tx_skb = NULL;
 		if (queue->tx_ring) {
-			dma_free_coherent(&bp->pdev->dev, TX_RING_BYTES,
+			dma_free_coherent(&bp->pdev->dev, TX_RING_BYTES(bp),
 					  queue->tx_ring, queue->tx_ring_dma);
 			queue->tx_ring = NULL;
 		}
@@ -1511,14 +1518,14 @@ static int gem_alloc_rx_buffers(struct macb *bp)
 {
 	int size;
 
-	size = RX_RING_SIZE * sizeof(struct sk_buff *);
+	size = bp->rx_ring_size * sizeof(struct sk_buff *);
 	bp->rx_skbuff = kzalloc(size, GFP_KERNEL);
 	if (!bp->rx_skbuff)
 		return -ENOMEM;
-
-	netdev_dbg(bp->dev,
-		   "Allocated %d RX struct sk_buff entries at %p\n",
-		   RX_RING_SIZE, bp->rx_skbuff);
+	else
+		netdev_dbg(bp->dev,
+			   "Allocated %d RX struct sk_buff entries at %p\n",
+			   bp->rx_ring_size, bp->rx_skbuff);
 	return 0;
 }
 
@@ -1526,7 +1533,7 @@ static int macb_alloc_rx_buffers(struct macb *bp)
 {
 	int size;
 
-	size = RX_RING_SIZE * bp->rx_buffer_size;
+	size = bp->rx_ring_size * bp->rx_buffer_size;
 	bp->rx_buffers = dma_alloc_coherent(&bp->pdev->dev, size,
 					    &bp->rx_buffers_dma, GFP_KERNEL);
 	if (!bp->rx_buffers)
@@ -1545,7 +1552,7 @@ static int macb_alloc_consistent(struct macb *bp)
 	int size;
 
 	for (q = 0, queue = bp->queues; q < bp->num_queues; ++q, ++queue) {
-		size = TX_RING_BYTES;
+		size = TX_RING_BYTES(bp);
 		queue->tx_ring = dma_alloc_coherent(&bp->pdev->dev, size,
 						    &queue->tx_ring_dma,
 						    GFP_KERNEL);
@@ -1556,13 +1563,13 @@ static int macb_alloc_consistent(struct macb *bp)
 			   q, size, (unsigned long)queue->tx_ring_dma,
 			   queue->tx_ring);
 
-		size = TX_RING_SIZE * sizeof(struct macb_tx_skb);
+		size = bp->tx_ring_size * sizeof(struct macb_tx_skb);
 		queue->tx_skb = kmalloc(size, GFP_KERNEL);
 		if (!queue->tx_skb)
 			goto out_err;
 	}
 
-	size = RX_RING_BYTES;
+	size = RX_RING_BYTES(bp);
 	bp->rx_ring = dma_alloc_coherent(&bp->pdev->dev, size,
 					 &bp->rx_ring_dma, GFP_KERNEL);
 	if (!bp->rx_ring)
@@ -1588,11 +1595,11 @@ static void gem_init_rings(struct macb *bp)
 	int i;
 
 	for (q = 0, queue = bp->queues; q < bp->num_queues; ++q, ++queue) {
-		for (i = 0; i < TX_RING_SIZE; i++) {
-			macb_set_addr(&(queue->tx_ring[i]), 0);
+		for (i = 0; i < bp->tx_ring_size; i++) {
+			queue->tx_ring[i].addr = 0;
 			queue->tx_ring[i].ctrl = MACB_BIT(TX_USED);
 		}
-		queue->tx_ring[TX_RING_SIZE - 1].ctrl |= MACB_BIT(TX_WRAP);
+		queue->tx_ring[bp->tx_ring_size - 1].ctrl |= MACB_BIT(TX_WRAP);
 		queue->tx_head = 0;
 		queue->tx_tail = 0;
 	}
@@ -1609,13 +1616,13 @@ static void macb_init_rings(struct macb *bp)
 
 	macb_init_rx_ring(bp);
 
-	for (i = 0; i < TX_RING_SIZE; i++) {
+	for (i = 0; i < bp->tx_ring_size; i++) {
 		bp->queues[0].tx_ring[i].addr = 0;
 		bp->queues[0].tx_ring[i].ctrl = MACB_BIT(TX_USED);
 	}
 	bp->queues[0].tx_head = 0;
 	bp->queues[0].tx_tail = 0;
-	bp->queues[0].tx_ring[TX_RING_SIZE - 1].ctrl |= MACB_BIT(TX_WRAP);
+	bp->queues[0].tx_ring[bp->tx_ring_size - 1].ctrl |= MACB_BIT(TX_WRAP);
 
 	bp->rx_tail = 0;
 }
@@ -2148,8 +2155,8 @@ static void macb_get_regs(struct net_device *dev, struct ethtool_regs *regs,
 	regs->version = (macb_readl(bp, MID) & ((1 << MACB_REV_SIZE) - 1))
 			| MACB_GREGS_VERSION;
 
-	tail = macb_tx_ring_wrap(bp->queues[0].tx_tail);
-	head = macb_tx_ring_wrap(bp->queues[0].tx_head);
+	tail = macb_tx_ring_wrap(bp, bp->queues[0].tx_tail);
+	head = macb_tx_ring_wrap(bp, bp->queues[0].tx_head);
 
 	regs_buff[0]  = macb_readl(bp, NCR);
 	regs_buff[1]  = macb_or_gem_readl(bp, NCFGR);
@@ -2419,6 +2426,9 @@ static int macb_init(struct platform_device *pdev)
 	int err;
 	u32 val;
 
+	bp->tx_ring_size = DEFAULT_TX_RING_SIZE;
+	bp->rx_ring_size = DEFAULT_RX_RING_SIZE;
+
 	/* set the queue register mapping once for all: queue0 has a special
 	 * register mapping but we don't want to test the queue index then
 	 * compute the corresponding register offset at run time.
diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
index 8bed4b5..1216950 100644
--- a/drivers/net/ethernet/cadence/macb.h
+++ b/drivers/net/ethernet/cadence/macb.h
@@ -811,6 +811,9 @@ struct macb {
 	void			*rx_buffers;
 	size_t			rx_buffer_size;
 
+	unsigned int		rx_ring_size;
+	unsigned int		tx_ring_size;
+
 	unsigned int		num_queues;
 	unsigned int		queue_mask;
 	struct macb_queue	queues[MACB_MAX_QUEUES];
-- 
2.7.4
