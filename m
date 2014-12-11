From: Cyrille Pitchen <cyrille.pitchen@atmel.com>
Subject: [PATCH v2 1/1] net/macb: add TX multiqueue support for gem
Date: Thu, 11 Dec 2014 11:16:51 +0100
Message-ID: <87a3098203ee6eaa7a60607713a293d3258e2b58.1418291637.git.cyrille.pitchen@atmel.com>
References: <cover.1418291637.git.cyrille.pitchen@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>,
	Cyrille Pitchen <cyrille.pitchen@atmel.com>
To: <nicolas.ferre@atmel.com>, <davem@davemloft.net>,
	<linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
	<soren.brinkmann@xilinx.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1418291637.git.cyrille.pitchen@atmel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

gem devices designed with multiqueue CANNOT work without this patch.

When probing a gem device, the driver must first prepare and enable the
peripheral clock before accessing I/O registers. The second step is to read the
MID register to find whether the device is a gem or an old macb IP.
For gem devices, it reads the Design Configuration Register 6 (DCFG6) to
compute to total number of queues, whereas macb devices always have a single
queue.
Only then it can call alloc_etherdev_mq() with the correct number of queues.
This is the reason why the order of some initializations has been changed in
macb_probe().
Eventually, the dedicated IRQ and TX ring buffer descriptors are initialized
for each queue.

For backward compatibility reasons, queue0 uses the legacy registers ISR, IER,
IDR, IMR, TBQP and RBQP. On the other hand, the other queues use new registers
ISR[1..7], IER[1..7], IDR[1..7], IMR[1..7], TBQP[1..7] and RBQP[1..7].
Except this hardware detail there is no real difference between queue0 and the
others. The driver hides that thanks to the struct macb_queue.
This structure allows us to share a common set of functions for all the queues.

Besides when a TX error occurs, the gem MUST be halted before writing any of
the TBQP registers to reset the relevant queue. An immediate side effect is
that the other queues too aren't processed anymore by the gem.
So macb_tx_error_task() calls netif_tx_stop_all_queues() to notify the Linux
network engine that all transmissions are stopped.

Also macb_tx_error_task() now calls spin_lock_irqsave() to prevent the
interrupt handlers of the other queues from running as each of them may wake
its associated queue up (please refer to macb_tx_interrupt()).

Finally, as all queues have previously been stopped, they should be restarted
calling netif_tx_start_all_queues() and setting the TSTART bit into the Network
Control Register. Before this patch, when dealing with a single queue, the
driver used to defer the reset of the faulting queue and the write of the
TSTART bit until the next call of macb_start_xmit().
As explained before, this bit is now set by macb_tx_error_task() too. That's
why the faulting queue MUST be reset by setting the TX_USED bit in its first
buffer descriptor before writing the TSTART bit.

Queue 0 always exits and is the lowest priority when other queues are available.
The higher the index of the queue is, the higher its priority is.

When transmitting frames, the TX queue is selected by the skb->queue_mapping
value. So queue discipline can be used to define the queue priority policy.

Signed-off-by: Cyrille Pitchen <cyrille.pitchen@atmel.com>
---
 drivers/net/ethernet/cadence/macb.c | 451 +++++++++++++++++++++++-------------
 drivers/net/ethernet/cadence/macb.h |  71 +++++-
 2 files changed, 358 insertions(+), 164 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 41113e5..ab8116f 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -66,23 +66,25 @@ static unsigned int macb_tx_ring_wrap(unsigned int index)
 	return index & (TX_RING_SIZE - 1);
 }
 
-static struct macb_dma_desc *macb_tx_desc(struct macb *bp, unsigned int index)
+static struct macb_dma_desc *macb_tx_desc(struct macb_queue *queue,
+					  unsigned int index)
 {
-	return &bp->tx_ring[macb_tx_ring_wrap(index)];
+	return &queue->tx_ring[macb_tx_ring_wrap(index)];
 }
 
-static struct macb_tx_skb *macb_tx_skb(struct macb *bp, unsigned int index)
+static struct macb_tx_skb *macb_tx_skb(struct macb_queue *queue,
+				       unsigned int index)
 {
-	return &bp->tx_skb[macb_tx_ring_wrap(index)];
+	return &queue->tx_skb[macb_tx_ring_wrap(index)];
 }
 
-static dma_addr_t macb_tx_dma(struct macb *bp, unsigned int index)
+static dma_addr_t macb_tx_dma(struct macb_queue *queue, unsigned int index)
 {
 	dma_addr_t offset;
 
 	offset = macb_tx_ring_wrap(index) * sizeof(struct macb_dma_desc);
 
-	return bp->tx_ring_dma + offset;
+	return queue->tx_ring_dma + offset;
 }
 
 static unsigned int macb_rx_ring_wrap(unsigned int index)
@@ -490,38 +492,50 @@ static void macb_tx_unmap(struct macb *bp, struct macb_tx_skb *tx_skb)
 
 static void macb_tx_error_task(struct work_struct *work)
 {
-	struct macb	*bp = container_of(work, struct macb, tx_error_task);
+	struct macb_queue	*queue = container_of(work, struct macb_queue,
+						      tx_error_task);
+	struct macb		*bp = queue->bp;
 	struct macb_tx_skb	*tx_skb;
+	struct macb_dma_desc	*desc;
 	struct sk_buff		*skb;
 	unsigned int		tail;
+	unsigned long		flags;
+
+	netdev_vdbg(bp->dev, "macb_tx_error_task: q = %u, t = %u, h = %u\n",
+		    (unsigned int)(queue - bp->queues),
+		    queue->tx_tail, queue->tx_head);
 
-	netdev_vdbg(bp->dev, "macb_tx_error_task: t = %u, h = %u\n",
-		    bp->tx_tail, bp->tx_head);
+	/*
+	 * Prevent the queue IRQ handlers from running: each of them may call
+	 * macb_tx_interrupt(), which in turn may call netif_wake_subqueue().
+	 * As explained below, we have to halt the transmission before updating
+	 * TBQP registers so we call netif_tx_stop_all_queues() to notify the
+	 * network engine about the macb/gem being halted.
+	 */
+	spin_lock_irqsave(&bp->lock, flags);
 
 	/* Make sure nobody is trying to queue up new packets */
-	netif_stop_queue(bp->dev);
+	netif_tx_stop_all_queues(bp->dev);
 
 	/*
 	 * Stop transmission now
 	 * (in case we have just queued new packets)
+	 * macb/gem must be halted to write TBQP register
 	 */
 	if (macb_halt_tx(bp))
 		/* Just complain for now, reinitializing TX path can be good */
 		netdev_err(bp->dev, "BUG: halt tx timed out\n");
 
-	/* No need for the lock here as nobody will interrupt us anymore */
-
 	/*
 	 * Treat frames in TX queue including the ones that caused the error.
 	 * Free transmit buffers in upper layer.
 	 */
-	for (tail = bp->tx_tail; tail != bp->tx_head; tail++) {
-		struct macb_dma_desc	*desc;
-		u32			ctrl;
+	for (tail = queue->tx_tail; tail != queue->tx_head; tail++) {
+		u32	ctrl;
 
-		desc = macb_tx_desc(bp, tail);
+		desc = macb_tx_desc(queue, tail);
 		ctrl = desc->ctrl;
-		tx_skb = macb_tx_skb(bp, tail);
+		tx_skb = macb_tx_skb(queue, tail);
 		skb = tx_skb->skb;
 
 		if (ctrl & MACB_BIT(TX_USED)) {
@@ -529,7 +543,7 @@ static void macb_tx_error_task(struct work_struct *work)
 			while (!skb) {
 				macb_tx_unmap(bp, tx_skb);
 				tail++;
-				tx_skb = macb_tx_skb(bp, tail);
+				tx_skb = macb_tx_skb(queue, tail);
 				skb = tx_skb->skb;
 			}
 
@@ -558,45 +572,56 @@ static void macb_tx_error_task(struct work_struct *work)
 		macb_tx_unmap(bp, tx_skb);
 	}
 
+	/* Set end of TX queue */
+	desc = macb_tx_desc(queue, 0);
+	desc->addr = 0;
+	desc->ctrl = MACB_BIT(TX_USED);
+
 	/* Make descriptor updates visible to hardware */
 	wmb();
 
 	/* Reinitialize the TX desc queue */
-	macb_writel(bp, TBQP, bp->tx_ring_dma);
+	queue_writel(queue, TBQP, queue->tx_ring_dma);
 	/* Make TX ring reflect state of hardware */
-	bp->tx_head = bp->tx_tail = 0;
-
-	/* Now we are ready to start transmission again */
-	netif_wake_queue(bp->dev);
+	queue->tx_head = 0;
+	queue->tx_tail = 0;
 
 	/* Housework before enabling TX IRQ */
 	macb_writel(bp, TSR, macb_readl(bp, TSR));
-	macb_writel(bp, IER, MACB_TX_INT_FLAGS);
+	queue_writel(queue, IER, MACB_TX_INT_FLAGS);
+
+	/* Now we are ready to start transmission again */
+	netif_tx_start_all_queues(bp->dev);
+	macb_writel(bp, NCR, macb_readl(bp, NCR) | MACB_BIT(TSTART));
+
+	spin_unlock_irqrestore(&bp->lock, flags);
 }
 
-static void macb_tx_interrupt(struct macb *bp)
+static void macb_tx_interrupt(struct macb_queue *queue)
 {
 	unsigned int tail;
 	unsigned int head;
 	u32 status;
+	struct macb *bp = queue->bp;
+	u16 queue_index = queue - bp->queues;
 
 	status = macb_readl(bp, TSR);
 	macb_writel(bp, TSR, status);
 
 	if (bp->caps & MACB_CAPS_ISR_CLEAR_ON_WRITE)
-		macb_writel(bp, ISR, MACB_BIT(TCOMP));
+		queue_writel(queue, ISR, MACB_BIT(TCOMP));
 
 	netdev_vdbg(bp->dev, "macb_tx_interrupt status = 0x%03lx\n",
 		(unsigned long)status);
 
-	head = bp->tx_head;
-	for (tail = bp->tx_tail; tail != head; tail++) {
+	head = queue->tx_head;
+	for (tail = queue->tx_tail; tail != head; tail++) {
 		struct macb_tx_skb	*tx_skb;
 		struct sk_buff		*skb;
 		struct macb_dma_desc	*desc;
 		u32			ctrl;
 
-		desc = macb_tx_desc(bp, tail);
+		desc = macb_tx_desc(queue, tail);
 
 		/* Make hw descriptor updates visible to CPU */
 		rmb();
@@ -611,7 +636,7 @@ static void macb_tx_interrupt(struct macb *bp)
 
 		/* Process all buffers of the current transmitted frame */
 		for (;; tail++) {
-			tx_skb = macb_tx_skb(bp, tail);
+			tx_skb = macb_tx_skb(queue, tail);
 			skb = tx_skb->skb;
 
 			/* First, update TX stats if needed */
@@ -634,11 +659,11 @@ static void macb_tx_interrupt(struct macb *bp)
 		}
 	}
 
-	bp->tx_tail = tail;
-	if (netif_queue_stopped(bp->dev)
-			&& CIRC_CNT(bp->tx_head, bp->tx_tail,
-				    TX_RING_SIZE) <= MACB_TX_WAKEUP_THRESH)
-		netif_wake_queue(bp->dev);
+	queue->tx_tail = tail;
+	if (__netif_subqueue_stopped(bp->dev, queue_index) &&
+	    CIRC_CNT(queue->tx_head, queue->tx_tail,
+		     TX_RING_SIZE) <= MACB_TX_WAKEUP_THRESH)
+		netif_wake_subqueue(bp->dev, queue_index);
 }
 
 static void gem_rx_refill(struct macb *bp)
@@ -949,11 +974,12 @@ static int macb_poll(struct napi_struct *napi, int budget)
 
 static irqreturn_t macb_interrupt(int irq, void *dev_id)
 {
-	struct net_device *dev = dev_id;
-	struct macb *bp = netdev_priv(dev);
+	struct macb_queue *queue = dev_id;
+	struct macb *bp = queue->bp;
+	struct net_device *dev = bp->dev;
 	u32 status;
 
-	status = macb_readl(bp, ISR);
+	status = queue_readl(queue, ISR);
 
 	if (unlikely(!status))
 		return IRQ_NONE;
@@ -963,11 +989,13 @@ static irqreturn_t macb_interrupt(int irq, void *dev_id)
 	while (status) {
 		/* close possible race with dev_close */
 		if (unlikely(!netif_running(dev))) {
-			macb_writel(bp, IDR, -1);
+			queue_writel(queue, IDR, -1);
 			break;
 		}
 
-		netdev_vdbg(bp->dev, "isr = 0x%08lx\n", (unsigned long)status);
+		netdev_vdbg(bp->dev, "queue = %u, isr = 0x%08lx\n",
+			    (unsigned int)(queue - bp->queues),
+			    (unsigned long)status);
 
 		if (status & MACB_RX_INT_FLAGS) {
 			/*
@@ -977,9 +1005,9 @@ static irqreturn_t macb_interrupt(int irq, void *dev_id)
 			 * is already scheduled, so disable interrupts
 			 * now.
 			 */
-			macb_writel(bp, IDR, MACB_RX_INT_FLAGS);
+			queue_writel(queue, IDR, MACB_RX_INT_FLAGS);
 			if (bp->caps & MACB_CAPS_ISR_CLEAR_ON_WRITE)
-				macb_writel(bp, ISR, MACB_BIT(RCOMP));
+				queue_writel(queue, ISR, MACB_BIT(RCOMP));
 
 			if (napi_schedule_prep(&bp->napi)) {
 				netdev_vdbg(bp->dev, "scheduling RX softirq\n");
@@ -988,17 +1016,17 @@ static irqreturn_t macb_interrupt(int irq, void *dev_id)
 		}
 
 		if (unlikely(status & (MACB_TX_ERR_FLAGS))) {
-			macb_writel(bp, IDR, MACB_TX_INT_FLAGS);
-			schedule_work(&bp->tx_error_task);
+			queue_writel(queue, IDR, MACB_TX_INT_FLAGS);
+			schedule_work(&queue->tx_error_task);
 
 			if (bp->caps & MACB_CAPS_ISR_CLEAR_ON_WRITE)
-				macb_writel(bp, ISR, MACB_TX_ERR_FLAGS);
+				queue_writel(queue, ISR, MACB_TX_ERR_FLAGS);
 
 			break;
 		}
 
 		if (status & MACB_BIT(TCOMP))
-			macb_tx_interrupt(bp);
+			macb_tx_interrupt(queue);
 
 		/*
 		 * Link change detection isn't possible with RMII, so we'll
@@ -1013,7 +1041,7 @@ static irqreturn_t macb_interrupt(int irq, void *dev_id)
 				bp->hw_stats.macb.rx_overruns++;
 
 			if (bp->caps & MACB_CAPS_ISR_CLEAR_ON_WRITE)
-				macb_writel(bp, ISR, MACB_BIT(ISR_ROVR));
+				queue_writel(queue, ISR, MACB_BIT(ISR_ROVR));
 		}
 
 		if (status & MACB_BIT(HRESP)) {
@@ -1025,10 +1053,10 @@ static irqreturn_t macb_interrupt(int irq, void *dev_id)
 			netdev_err(dev, "DMA bus error: HRESP not OK\n");
 
 			if (bp->caps & MACB_CAPS_ISR_CLEAR_ON_WRITE)
-				macb_writel(bp, ISR, MACB_BIT(HRESP));
+				queue_writel(queue, ISR, MACB_BIT(HRESP));
 		}
 
-		status = macb_readl(bp, ISR);
+		status = queue_readl(queue, ISR);
 	}
 
 	spin_unlock(&bp->lock);
@@ -1043,10 +1071,14 @@ static irqreturn_t macb_interrupt(int irq, void *dev_id)
  */
 static void macb_poll_controller(struct net_device *dev)
 {
+	struct macb *bp = netdev_priv(dev);
+	struct macb_queue *queue;
 	unsigned long flags;
+	unsigned int q;
 
 	local_irq_save(flags);
-	macb_interrupt(dev->irq, dev);
+	for (q = 0, queue = bp->queues; q < bp->num_queues; ++q, ++queue)
+		macb_interrupt(dev->irq, queue);
 	local_irq_restore(flags);
 }
 #endif
@@ -1058,10 +1090,11 @@ static inline unsigned int macb_count_tx_descriptors(struct macb *bp,
 }
 
 static unsigned int macb_tx_map(struct macb *bp,
+				struct macb_queue *queue,
 				struct sk_buff *skb)
 {
 	dma_addr_t mapping;
-	unsigned int len, entry, i, tx_head = bp->tx_head;
+	unsigned int len, entry, i, tx_head = queue->tx_head;
 	struct macb_tx_skb *tx_skb = NULL;
 	struct macb_dma_desc *desc;
 	unsigned int offset, size, count = 0;
@@ -1075,7 +1108,7 @@ static unsigned int macb_tx_map(struct macb *bp,
 	while (len) {
 		size = min(len, bp->max_tx_length);
 		entry = macb_tx_ring_wrap(tx_head);
-		tx_skb = &bp->tx_skb[entry];
+		tx_skb = &queue->tx_skb[entry];
 
 		mapping = dma_map_single(&bp->pdev->dev,
 					 skb->data + offset,
@@ -1104,7 +1137,7 @@ static unsigned int macb_tx_map(struct macb *bp,
 		while (len) {
 			size = min(len, bp->max_tx_length);
 			entry = macb_tx_ring_wrap(tx_head);
-			tx_skb = &bp->tx_skb[entry];
+			tx_skb = &queue->tx_skb[entry];
 
 			mapping = skb_frag_dma_map(&bp->pdev->dev, frag,
 						   offset, size, DMA_TO_DEVICE);
@@ -1143,14 +1176,14 @@ static unsigned int macb_tx_map(struct macb *bp,
 	i = tx_head;
 	entry = macb_tx_ring_wrap(i);
 	ctrl = MACB_BIT(TX_USED);
-	desc = &bp->tx_ring[entry];
+	desc = &queue->tx_ring[entry];
 	desc->ctrl = ctrl;
 
 	do {
 		i--;
 		entry = macb_tx_ring_wrap(i);
-		tx_skb = &bp->tx_skb[entry];
-		desc = &bp->tx_ring[entry];
+		tx_skb = &queue->tx_skb[entry];
+		desc = &queue->tx_ring[entry];
 
 		ctrl = (u32)tx_skb->size;
 		if (eof) {
@@ -1167,17 +1200,17 @@ static unsigned int macb_tx_map(struct macb *bp,
 		 */
 		wmb();
 		desc->ctrl = ctrl;
-	} while (i != bp->tx_head);
+	} while (i != queue->tx_head);
 
-	bp->tx_head = tx_head;
+	queue->tx_head = tx_head;
 
 	return count;
 
 dma_error:
 	netdev_err(bp->dev, "TX DMA map failed\n");
 
-	for (i = bp->tx_head; i != tx_head; i++) {
-		tx_skb = macb_tx_skb(bp, i);
+	for (i = queue->tx_head; i != tx_head; i++) {
+		tx_skb = macb_tx_skb(queue, i);
 
 		macb_tx_unmap(bp, tx_skb);
 	}
@@ -1187,14 +1220,16 @@ dma_error:
 
 static int macb_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
+	u16 queue_index = skb_get_queue_mapping(skb);
 	struct macb *bp = netdev_priv(dev);
+	struct macb_queue *queue = &bp->queues[queue_index];
 	unsigned long flags;
 	unsigned int count, nr_frags, frag_size, f;
 
 #if defined(DEBUG) && defined(VERBOSE_DEBUG)
 	netdev_vdbg(bp->dev,
-		   "start_xmit: len %u head %p data %p tail %p end %p\n",
-		   skb->len, skb->head, skb->data,
+		   "start_xmit: queue %hu len %u head %p data %p tail %p end %p\n",
+		   queue_index, skb->len, skb->head, skb->data,
 		   skb_tail_pointer(skb), skb_end_pointer(skb));
 	print_hex_dump(KERN_DEBUG, "data: ", DUMP_PREFIX_OFFSET, 16, 1,
 		       skb->data, 16, true);
@@ -1214,16 +1249,16 @@ static int macb_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	spin_lock_irqsave(&bp->lock, flags);
 
 	/* This is a hard error, log it. */
-	if (CIRC_SPACE(bp->tx_head, bp->tx_tail, TX_RING_SIZE) < count) {
-		netif_stop_queue(dev);
+	if (CIRC_SPACE(queue->tx_head, queue->tx_tail, TX_RING_SIZE) < count) {
+		netif_stop_subqueue(dev, queue_index);
 		spin_unlock_irqrestore(&bp->lock, flags);
 		netdev_dbg(bp->dev, "tx_head = %u, tx_tail = %u\n",
-			   bp->tx_head, bp->tx_tail);
+			   queue->tx_head, queue->tx_tail);
 		return NETDEV_TX_BUSY;
 	}
 
 	/* Map socket buffer for DMA transfer */
-	if (!macb_tx_map(bp, skb)) {
+	if (!macb_tx_map(bp, queue, skb)) {
 		dev_kfree_skb_any(skb);
 		goto unlock;
 	}
@@ -1235,8 +1270,8 @@ static int macb_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	macb_writel(bp, NCR, macb_readl(bp, NCR) | MACB_BIT(TSTART));
 
-	if (CIRC_SPACE(bp->tx_head, bp->tx_tail, TX_RING_SIZE) < 1)
-		netif_stop_queue(dev);
+	if (CIRC_SPACE(queue->tx_head, queue->tx_tail, TX_RING_SIZE) < 1)
+		netif_stop_subqueue(dev, queue_index);
 
 unlock:
 	spin_unlock_irqrestore(&bp->lock, flags);
@@ -1304,20 +1339,24 @@ static void macb_free_rx_buffers(struct macb *bp)
 
 static void macb_free_consistent(struct macb *bp)
 {
-	if (bp->tx_skb) {
-		kfree(bp->tx_skb);
-		bp->tx_skb = NULL;
-	}
+	struct macb_queue *queue;
+	unsigned int q;
+
 	bp->macbgem_ops.mog_free_rx_buffers(bp);
 	if (bp->rx_ring) {
 		dma_free_coherent(&bp->pdev->dev, RX_RING_BYTES,
 				  bp->rx_ring, bp->rx_ring_dma);
 		bp->rx_ring = NULL;
 	}
-	if (bp->tx_ring) {
-		dma_free_coherent(&bp->pdev->dev, TX_RING_BYTES,
-				  bp->tx_ring, bp->tx_ring_dma);
-		bp->tx_ring = NULL;
+
+	for (q = 0, queue = bp->queues; q < bp->num_queues; ++q, ++queue) {
+		kfree(queue->tx_skb);
+		queue->tx_skb = NULL;
+		if (queue->tx_ring) {
+			dma_free_coherent(&bp->pdev->dev, TX_RING_BYTES,
+					  queue->tx_ring, queue->tx_ring_dma);
+			queue->tx_ring = NULL;
+		}
 	}
 }
 
@@ -1354,12 +1393,27 @@ static int macb_alloc_rx_buffers(struct macb *bp)
 
 static int macb_alloc_consistent(struct macb *bp)
 {
+	struct macb_queue *queue;
+	unsigned int q;
 	int size;
 
-	size = TX_RING_SIZE * sizeof(struct macb_tx_skb);
-	bp->tx_skb = kmalloc(size, GFP_KERNEL);
-	if (!bp->tx_skb)
-		goto out_err;
+	for (q = 0, queue = bp->queues; q < bp->num_queues; ++q, ++queue) {
+		size = TX_RING_BYTES;
+		queue->tx_ring = dma_alloc_coherent(&bp->pdev->dev, size,
+						    &queue->tx_ring_dma,
+						    GFP_KERNEL);
+		if (!queue->tx_ring)
+			goto out_err;
+		netdev_dbg(bp->dev,
+			   "Allocated TX ring for queue %u of %d bytes at %08lx (mapped %p)\n",
+			   q, size, (unsigned long)queue->tx_ring_dma,
+			   queue->tx_ring);
+
+		size = TX_RING_SIZE * sizeof(struct macb_tx_skb);
+		queue->tx_skb = kmalloc(size, GFP_KERNEL);
+		if (!queue->tx_skb)
+			goto out_err;
+	}
 
 	size = RX_RING_BYTES;
 	bp->rx_ring = dma_alloc_coherent(&bp->pdev->dev, size,
@@ -1370,15 +1424,6 @@ static int macb_alloc_consistent(struct macb *bp)
 		   "Allocated RX ring of %d bytes at %08lx (mapped %p)\n",
 		   size, (unsigned long)bp->rx_ring_dma, bp->rx_ring);
 
-	size = TX_RING_BYTES;
-	bp->tx_ring = dma_alloc_coherent(&bp->pdev->dev, size,
-					 &bp->tx_ring_dma, GFP_KERNEL);
-	if (!bp->tx_ring)
-		goto out_err;
-	netdev_dbg(bp->dev,
-		   "Allocated TX ring of %d bytes at %08lx (mapped %p)\n",
-		   size, (unsigned long)bp->tx_ring_dma, bp->tx_ring);
-
 	if (bp->macbgem_ops.mog_alloc_rx_buffers(bp))
 		goto out_err;
 
@@ -1391,15 +1436,22 @@ out_err:
 
 static void gem_init_rings(struct macb *bp)
 {
+	struct macb_queue *queue;
+	unsigned int q;
 	int i;
 
-	for (i = 0; i < TX_RING_SIZE; i++) {
-		bp->tx_ring[i].addr = 0;
-		bp->tx_ring[i].ctrl = MACB_BIT(TX_USED);
+	for (q = 0, queue = bp->queues; q < bp->num_queues; ++q, ++queue) {
+		for (i = 0; i < TX_RING_SIZE; i++) {
+			queue->tx_ring[i].addr = 0;
+			queue->tx_ring[i].ctrl = MACB_BIT(TX_USED);
+		}
+		queue->tx_ring[TX_RING_SIZE - 1].ctrl |= MACB_BIT(TX_WRAP);
+		queue->tx_head = 0;
+		queue->tx_tail = 0;
 	}
-	bp->tx_ring[TX_RING_SIZE - 1].ctrl |= MACB_BIT(TX_WRAP);
 
-	bp->rx_tail = bp->rx_prepared_head = bp->tx_head = bp->tx_tail = 0;
+	bp->rx_tail = 0;
+	bp->rx_prepared_head = 0;
 
 	gem_rx_refill(bp);
 }
@@ -1418,16 +1470,21 @@ static void macb_init_rings(struct macb *bp)
 	bp->rx_ring[RX_RING_SIZE - 1].addr |= MACB_BIT(RX_WRAP);
 
 	for (i = 0; i < TX_RING_SIZE; i++) {
-		bp->tx_ring[i].addr = 0;
-		bp->tx_ring[i].ctrl = MACB_BIT(TX_USED);
+		bp->queues[0].tx_ring[i].addr = 0;
+		bp->queues[0].tx_ring[i].ctrl = MACB_BIT(TX_USED);
+		bp->queues[0].tx_head = 0;
+		bp->queues[0].tx_tail = 0;
 	}
-	bp->tx_ring[TX_RING_SIZE - 1].ctrl |= MACB_BIT(TX_WRAP);
+	bp->queues[0].tx_ring[TX_RING_SIZE - 1].ctrl |= MACB_BIT(TX_WRAP);
 
-	bp->rx_tail = bp->tx_head = bp->tx_tail = 0;
+	bp->rx_tail = 0;
 }
 
 static void macb_reset_hw(struct macb *bp)
 {
+	struct macb_queue *queue;
+	unsigned int q;
+
 	/*
 	 * Disable RX and TX (XXX: Should we halt the transmission
 	 * more gracefully?)
@@ -1442,8 +1499,10 @@ static void macb_reset_hw(struct macb *bp)
 	macb_writel(bp, RSR, -1);
 
 	/* Disable all interrupts */
-	macb_writel(bp, IDR, -1);
-	macb_readl(bp, ISR);
+	for (q = 0, queue = bp->queues; q < bp->num_queues; ++q, ++queue) {
+		queue_writel(queue, IDR, -1);
+		queue_readl(queue, ISR);
+	}
 }
 
 static u32 gem_mdc_clk_div(struct macb *bp)
@@ -1540,6 +1599,9 @@ static void macb_configure_dma(struct macb *bp)
 
 static void macb_init_hw(struct macb *bp)
 {
+	struct macb_queue *queue;
+	unsigned int q;
+
 	u32 config;
 
 	macb_reset_hw(bp);
@@ -1565,16 +1627,18 @@ static void macb_init_hw(struct macb *bp)
 
 	/* Initialize TX and RX buffers */
 	macb_writel(bp, RBQP, bp->rx_ring_dma);
-	macb_writel(bp, TBQP, bp->tx_ring_dma);
+	for (q = 0, queue = bp->queues; q < bp->num_queues; ++q, ++queue) {
+		queue_writel(queue, TBQP, queue->tx_ring_dma);
+
+		/* Enable interrupts */
+		queue_writel(queue, IER,
+			     MACB_RX_INT_FLAGS |
+			     MACB_TX_INT_FLAGS |
+			     MACB_BIT(HRESP));
+	}
 
 	/* Enable TX and RX */
 	macb_writel(bp, NCR, MACB_BIT(RE) | MACB_BIT(TE) | MACB_BIT(MPE));
-
-	/* Enable interrupts */
-	macb_writel(bp, IER, (MACB_RX_INT_FLAGS
-			      | MACB_TX_INT_FLAGS
-			      | MACB_BIT(HRESP)));
-
 }
 
 /*
@@ -1736,7 +1800,7 @@ static int macb_open(struct net_device *dev)
 	/* schedule a link state check */
 	phy_start(bp->phy_dev);
 
-	netif_start_queue(dev);
+	netif_tx_start_all_queues(dev);
 
 	return 0;
 }
@@ -1746,7 +1810,7 @@ static int macb_close(struct net_device *dev)
 	struct macb *bp = netdev_priv(dev);
 	unsigned long flags;
 
-	netif_stop_queue(dev);
+	netif_tx_stop_all_queues(dev);
 	napi_disable(&bp->napi);
 
 	if (bp->phy_dev)
@@ -1895,8 +1959,8 @@ static void macb_get_regs(struct net_device *dev, struct ethtool_regs *regs,
 	regs->version = (macb_readl(bp, MID) & ((1 << MACB_REV_SIZE) - 1))
 			| MACB_GREGS_VERSION;
 
-	tail = macb_tx_ring_wrap(bp->tx_tail);
-	head = macb_tx_ring_wrap(bp->tx_head);
+	tail = macb_tx_ring_wrap(bp->queues[0].tx_tail);
+	head = macb_tx_ring_wrap(bp->queues[0].tx_head);
 
 	regs_buff[0]  = macb_readl(bp, NCR);
 	regs_buff[1]  = macb_or_gem_readl(bp, NCFGR);
@@ -1909,8 +1973,8 @@ static void macb_get_regs(struct net_device *dev, struct ethtool_regs *regs,
 
 	regs_buff[8]  = tail;
 	regs_buff[9]  = head;
-	regs_buff[10] = macb_tx_dma(bp, tail);
-	regs_buff[11] = macb_tx_dma(bp, head);
+	regs_buff[10] = macb_tx_dma(&bp->queues[0], tail);
+	regs_buff[11] = macb_tx_dma(&bp->queues[0], head);
 
 	if (macb_is_gem(bp)) {
 		regs_buff[12] = gem_readl(bp, USRIO);
@@ -2061,16 +2125,44 @@ static void macb_configure_caps(struct macb *bp)
 	netdev_dbg(bp->dev, "Cadence caps 0x%08x\n", bp->caps);
 }
 
+static void macb_probe_queues(void __iomem *mem,
+			      unsigned int *queue_mask,
+			      unsigned int *num_queues)
+{
+	unsigned int q;
+	u32 mid;
+
+	*queue_mask = 0x1;
+	*num_queues = 1;
+
+	/* is it macb or gem ? */
+	mid = __raw_readl(mem + MACB_MID);
+	if (MACB_BFEXT(IDNUM, mid) != 0x2)
+		return;
+
+	/* bit 0 is never set but queue 0 always exists */
+	*queue_mask = __raw_readl(mem + GEM_DCFG6) & 0xff;
+	*queue_mask |= 0x1;
+
+	for (q = 1; q < MACB_MAX_QUEUES; ++q)
+		if (*queue_mask & (1 << q))
+			(*num_queues)++;
+}
+
 static int __init macb_probe(struct platform_device *pdev)
 {
 	struct macb_platform_data *pdata;
 	struct resource *regs;
 	struct net_device *dev;
 	struct macb *bp;
+	struct macb_queue *queue;
 	struct phy_device *phydev;
 	u32 config;
 	int err = -ENXIO;
 	const char *mac;
+	void __iomem *mem;
+	unsigned int q, queue_mask, num_queues, q_irq = 0;
+	struct clk *pclk, *hclk, *tx_clk;
 
 	regs = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	if (!regs) {
@@ -2078,72 +2170,106 @@ static int __init macb_probe(struct platform_device *pdev)
 		goto err_out;
 	}
 
-	err = -ENOMEM;
-	dev = alloc_etherdev(sizeof(*bp));
-	if (!dev)
-		goto err_out;
-
-	SET_NETDEV_DEV(dev, &pdev->dev);
-
-	bp = netdev_priv(dev);
-	bp->pdev = pdev;
-	bp->dev = dev;
-
-	spin_lock_init(&bp->lock);
-	INIT_WORK(&bp->tx_error_task, macb_tx_error_task);
-
-	bp->pclk = devm_clk_get(&pdev->dev, "pclk");
-	if (IS_ERR(bp->pclk)) {
-		err = PTR_ERR(bp->pclk);
+	pclk = devm_clk_get(&pdev->dev, "pclk");
+	if (IS_ERR(pclk)) {
+		err = PTR_ERR(pclk);
 		dev_err(&pdev->dev, "failed to get macb_clk (%u)\n", err);
-		goto err_out_free_dev;
+		goto err_out;
 	}
 
-	bp->hclk = devm_clk_get(&pdev->dev, "hclk");
-	if (IS_ERR(bp->hclk)) {
-		err = PTR_ERR(bp->hclk);
+	hclk = devm_clk_get(&pdev->dev, "hclk");
+	if (IS_ERR(hclk)) {
+		err = PTR_ERR(hclk);
 		dev_err(&pdev->dev, "failed to get hclk (%u)\n", err);
-		goto err_out_free_dev;
+		goto err_out;
 	}
 
-	bp->tx_clk = devm_clk_get(&pdev->dev, "tx_clk");
+	tx_clk = devm_clk_get(&pdev->dev, "tx_clk");
 
-	err = clk_prepare_enable(bp->pclk);
+	err = clk_prepare_enable(pclk);
 	if (err) {
 		dev_err(&pdev->dev, "failed to enable pclk (%u)\n", err);
-		goto err_out_free_dev;
+		goto err_out;
 	}
 
-	err = clk_prepare_enable(bp->hclk);
+	err = clk_prepare_enable(hclk);
 	if (err) {
 		dev_err(&pdev->dev, "failed to enable hclk (%u)\n", err);
 		goto err_out_disable_pclk;
 	}
 
-	if (!IS_ERR(bp->tx_clk)) {
-		err = clk_prepare_enable(bp->tx_clk);
+	if (!IS_ERR(tx_clk)) {
+		err = clk_prepare_enable(tx_clk);
 		if (err) {
 			dev_err(&pdev->dev, "failed to enable tx_clk (%u)\n",
-					err);
+				err);
 			goto err_out_disable_hclk;
 		}
 	}
 
-	bp->regs = devm_ioremap(&pdev->dev, regs->start, resource_size(regs));
-	if (!bp->regs) {
+	err = -ENOMEM;
+	mem = devm_ioremap(&pdev->dev, regs->start, resource_size(regs));
+	if (!mem) {
 		dev_err(&pdev->dev, "failed to map registers, aborting.\n");
-		err = -ENOMEM;
 		goto err_out_disable_clocks;
 	}
 
-	dev->irq = platform_get_irq(pdev, 0);
-	err = devm_request_irq(&pdev->dev, dev->irq, macb_interrupt, 0,
-			dev->name, dev);
-	if (err) {
-		dev_err(&pdev->dev, "Unable to request IRQ %d (error %d)\n",
-			dev->irq, err);
+	macb_probe_queues(mem, &queue_mask, &num_queues);
+	dev = alloc_etherdev_mq(sizeof(*bp), num_queues);
+	if (!dev)
 		goto err_out_disable_clocks;
+
+	SET_NETDEV_DEV(dev, &pdev->dev);
+
+	bp = netdev_priv(dev);
+	bp->pdev = pdev;
+	bp->dev = dev;
+	bp->regs = mem;
+	bp->num_queues = num_queues;
+	bp->pclk = pclk;
+	bp->hclk = hclk;
+	bp->tx_clk = tx_clk;
+
+	bp->queues[0].bp = bp;
+	bp->queues[0].ISR  = MACB_ISR;
+	bp->queues[0].IER  = MACB_IER;
+	bp->queues[0].IDR  = MACB_IDR;
+	bp->queues[0].IMR  = MACB_IMR;
+	bp->queues[0].TBQP = MACB_TBQP;
+	for (q = 1, queue = &bp->queues[1]; q < MACB_MAX_QUEUES; ++q) {
+		if (!(queue_mask & (1 << q)))
+			continue;
+
+		queue->bp = bp;
+		queue->ISR  = (q-1) * sizeof(u32) + GEM_ISR1;
+		queue->IER  = (q-1) * sizeof(u32) + GEM_IER1;
+		queue->IDR  = (q-1) * sizeof(u32) + GEM_IDR1;
+		queue->IMR  = (q-1) * sizeof(u32) + GEM_IMR1;
+		queue->TBQP = (q-1) * sizeof(u32) + GEM_TBQP1;
+		queue++;
+	}
+
+	spin_lock_init(&bp->lock);
+
+	for (q = 0, queue = bp->queues; q < MACB_MAX_QUEUES; ++q) {
+		if (!(queue_mask & (1 << q)))
+			continue;
+
+		queue->irq = platform_get_irq(pdev, q);
+		err = devm_request_irq(&pdev->dev, queue->irq, macb_interrupt,
+				       0, dev->name, queue);
+		if (err) {
+			dev_err(&pdev->dev,
+				"Unable to request IRQ %d (error %d)\n",
+				queue->irq, err);
+			goto err_out_free_irq;
+		}
+
+		INIT_WORK(&queue->tx_error_task, macb_tx_error_task);
+		queue++;
+		q_irq++;
 	}
+	dev->irq = bp->queues[0].irq;
 
 	dev->netdev_ops = &macb_netdev_ops;
 	netif_napi_add(dev, &bp->napi, macb_poll, 64);
@@ -2219,7 +2345,7 @@ static int __init macb_probe(struct platform_device *pdev)
 	err = register_netdev(dev);
 	if (err) {
 		dev_err(&pdev->dev, "Cannot register net device, aborting.\n");
-		goto err_out_disable_clocks;
+		goto err_out_free_irq;
 	}
 
 	err = macb_mii_init(bp);
@@ -2242,15 +2368,17 @@ static int __init macb_probe(struct platform_device *pdev)
 
 err_out_unregister_netdev:
 	unregister_netdev(dev);
+err_out_free_irq:
+	for (q = 0, queue = bp->queues; q < q_irq; ++q, ++queue)
+		devm_free_irq(&pdev->dev, queue->irq, queue);
+	free_netdev(dev);
 err_out_disable_clocks:
-	if (!IS_ERR(bp->tx_clk))
-		clk_disable_unprepare(bp->tx_clk);
+	if (!IS_ERR(tx_clk))
+		clk_disable_unprepare(tx_clk);
 err_out_disable_hclk:
-	clk_disable_unprepare(bp->hclk);
+	clk_disable_unprepare(hclk);
 err_out_disable_pclk:
-	clk_disable_unprepare(bp->pclk);
-err_out_free_dev:
-	free_netdev(dev);
+	clk_disable_unprepare(pclk);
 err_out:
 	return err;
 }
@@ -2259,6 +2387,8 @@ static int __exit macb_remove(struct platform_device *pdev)
 {
 	struct net_device *dev;
 	struct macb *bp;
+	struct macb_queue *queue;
+	unsigned int q;
 
 	dev = platform_get_drvdata(pdev);
 
@@ -2270,11 +2400,14 @@ static int __exit macb_remove(struct platform_device *pdev)
 		kfree(bp->mii_bus->irq);
 		mdiobus_free(bp->mii_bus);
 		unregister_netdev(dev);
+		queue = bp->queues;
+		for (q = 0; q < bp->num_queues; ++q, ++queue)
+			devm_free_irq(&pdev->dev, queue->irq, queue);
+		free_netdev(dev);
 		if (!IS_ERR(bp->tx_clk))
 			clk_disable_unprepare(bp->tx_clk);
 		clk_disable_unprepare(bp->hclk);
 		clk_disable_unprepare(bp->pclk);
-		free_netdev(dev);
 	}
 
 	return 0;
diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
index 517c09d..28d4e23 100644
--- a/drivers/net/ethernet/cadence/macb.h
+++ b/drivers/net/ethernet/cadence/macb.h
@@ -12,6 +12,7 @@
 
 #define MACB_GREGS_NBR 16
 #define MACB_GREGS_VERSION 1
+#define MACB_MAX_QUEUES 8
 
 /* MACB register offsets */
 #define MACB_NCR				0x0000
@@ -88,6 +89,48 @@
 #define GEM_DCFG5				0x0290
 #define GEM_DCFG6				0x0294
 #define GEM_DCFG7				0x0298
+#define GEM_ISR1				0x0400
+#define GEM_ISR2				0x0404
+#define GEM_ISR3				0x0408
+#define GEM_ISR4				0x040c
+#define GEM_ISR5				0x0410
+#define GEM_ISR6				0x0414
+#define GEM_ISR7				0x0418
+#define GEM_TBQP1				0x0440
+#define GEM_TBQP2				0x0444
+#define GEM_TBQP3				0x0448
+#define GEM_TBQP4				0x044c
+#define GEM_TBQP5				0x0450
+#define GEM_TBQP6				0x0454
+#define GEM_TBQP7				0x0458
+#define GEM_RBQP1				0x0480
+#define GEM_RBQP2				0x0484
+#define GEM_RBQP3				0x0488
+#define GEM_RBQP4				0x048c
+#define GEM_RBQP5				0x0490
+#define GEM_RBQP6				0x0494
+#define GEM_RBQP7				0x0498
+#define GEM_IER1				0x0600
+#define GEM_IER2				0x0604
+#define GEM_IER3				0x0608
+#define GEM_IER4				0x060c
+#define GEM_IER5				0x0610
+#define GEM_IER6				0x0614
+#define GEM_IER7				0x0618
+#define GEM_IDR1				0x0620
+#define GEM_IDR2				0x0624
+#define GEM_IDR3				0x0628
+#define GEM_IDR4				0x062c
+#define GEM_IDR5				0x0630
+#define GEM_IDR6				0x0634
+#define GEM_IDR7				0x0638
+#define GEM_IMR1				0x0640
+#define GEM_IMR2				0x0644
+#define GEM_IMR3				0x0648
+#define GEM_IMR4				0x064c
+#define GEM_IMR5				0x0650
+#define GEM_IMR6				0x0654
+#define GEM_IMR7				0x0658
 
 /* Bitfields in NCR */
 #define MACB_LB_OFFSET				0
@@ -376,6 +419,10 @@
 	__raw_readl((port)->regs + GEM_##reg)
 #define gem_writel(port, reg, value)			\
 	__raw_writel((value), (port)->regs + GEM_##reg)
+#define queue_readl(queue, reg)				\
+	__raw_readl((queue)->bp->regs + queue->reg)
+#define queue_writel(queue, reg, value)			\
+	__raw_writel((value), (queue)->bp->regs + queue->reg)
 
 /*
  * Conditional GEM/MACB macros.  These perform the operation to the correct
@@ -597,6 +644,23 @@ struct macb_config {
 	unsigned int		dma_burst_length;
 };
 
+struct macb_queue {
+	struct macb		*bp;
+	int			irq;
+
+	unsigned int		ISR;
+	unsigned int		IER;
+	unsigned int		IDR;
+	unsigned int		IMR;
+	unsigned int		TBQP;
+
+	unsigned int		tx_head, tx_tail;
+	struct macb_dma_desc	*tx_ring;
+	struct macb_tx_skb	*tx_skb;
+	dma_addr_t		tx_ring_dma;
+	struct work_struct	tx_error_task;
+};
+
 struct macb {
 	void __iomem		*regs;
 
@@ -607,9 +671,8 @@ struct macb {
 	void			*rx_buffers;
 	size_t			rx_buffer_size;
 
-	unsigned int		tx_head, tx_tail;
-	struct macb_dma_desc	*tx_ring;
-	struct macb_tx_skb	*tx_skb;
+	unsigned int		num_queues;
+	struct macb_queue	queues[MACB_MAX_QUEUES];
 
 	spinlock_t		lock;
 	struct platform_device	*pdev;
@@ -618,7 +681,6 @@ struct macb {
 	struct clk		*tx_clk;
 	struct net_device	*dev;
 	struct napi_struct	napi;
-	struct work_struct	tx_error_task;
 	struct net_device_stats	stats;
 	union {
 		struct macb_stats	macb;
@@ -626,7 +688,6 @@ struct macb {
 	}			hw_stats;
 
 	dma_addr_t		rx_ring_dma;
-	dma_addr_t		tx_ring_dma;
 	dma_addr_t		rx_buffers_dma;
 
 	struct macb_or_gem_ops	macbgem_ops;
-- 
1.8.2.2
