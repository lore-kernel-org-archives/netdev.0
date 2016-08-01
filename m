From: Harini Katakam <harini.katakam@xilinx.com>
Subject: [RFC PATCH 2/2] net: macb: Add 64 bit addressing support for GEM
Date: Mon, 1 Aug 2016 12:50:23 +0530
Message-ID: <1470036023-22368-2-git-send-email-harinik@xilinx.com>
References: <1470036023-22368-1-git-send-email-harinik@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<harinik@xilinx.com>, <punnaia@xilinx.com>, <michals@xilinx.com>
To: <nicolas.ferre@atmel.com>, <davem@davemloft.net>,
	<harinikatakamlinux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0060.outbound.protection.outlook.com ([104.47.37.60]:30528
	"EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751875AbcHAHiS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Aug 2016 03:38:18 -0400
In-Reply-To: <1470036023-22368-1-git-send-email-harinik@xilinx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for 64 bit addressing and BDs.
-> Enable 64 bit addressing in DMACFG register.
-> Set DMA mask when design config register shows support for 64 bit addr.
-> Add new BD words for higher address when 64 bit DMA support is present.
-> Add and update TBQPH and RBQPH for MSB of BD pointers.
-> Change extraction and updation of buffer addresses to use
64 bit address.
-> In gem_rx extract address in one place insted of two and use a
separate flag for RXUSED.

Signed-off-by: Harini Katakam <harinik@xilinx.com>
---
 drivers/net/ethernet/cadence/macb.c | 62 ++++++++++++++++++++++++++++++-------
 drivers/net/ethernet/cadence/macb.h | 10 ++++++
 2 files changed, 61 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 89c0cfa..6b797e3 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -541,6 +541,14 @@ static void macb_tx_unmap(struct macb *bp, struct macb_tx_skb *tx_skb)
 	}
 }
 
+static inline void macb_set_addr(struct macb_dma_desc *desc, dma_addr_t addr)
+{
+	desc->addr = (u32)addr;
+#ifdef CONFIG_ARCH_DMA_ADDR_T_64BIT
+	desc->addrh = (u32)(addr >> 32);
+#endif
+}
+
 static void macb_tx_error_task(struct work_struct *work)
 {
 	struct macb_queue	*queue = container_of(work, struct macb_queue,
@@ -621,14 +629,17 @@ static void macb_tx_error_task(struct work_struct *work)
 
 	/* Set end of TX queue */
 	desc = macb_tx_desc(queue, 0);
-	desc->addr = 0;
+	macb_set_addr(desc, 0);
 	desc->ctrl = MACB_BIT(TX_USED);
 
 	/* Make descriptor updates visible to hardware */
 	wmb();
 
 	/* Reinitialize the TX desc queue */
-	queue_writel(queue, TBQP, queue->tx_ring_dma);
+	queue_writel(queue, TBQP, (u32)(queue->tx_ring_dma));
+#ifdef CONFIG_ARCH_DMA_ADDR_T_64BIT
+	queue_writel(queue, TBQPH, (u32)(queue->tx_ring_dma >> 32));
+#endif
 	/* Make TX ring reflect state of hardware */
 	queue->tx_head = 0;
 	queue->tx_tail = 0;
@@ -750,7 +761,7 @@ static void gem_rx_refill(struct macb *bp)
 
 			if (entry == RX_RING_SIZE - 1)
 				paddr |= MACB_BIT(RX_WRAP);
-			bp->rx_ring[entry].addr = paddr;
+			macb_set_addr(&(bp->rx_ring[entry]), paddr);
 			bp->rx_ring[entry].ctrl = 0;
 
 			/* properly align Ethernet header */
@@ -798,7 +809,9 @@ static int gem_rx(struct macb *bp, int budget)
 	int			count = 0;
 
 	while (count < budget) {
-		u32 addr, ctrl;
+		u32 ctrl;
+		dma_addr_t addr;
+		bool rxused;
 
 		entry = macb_rx_ring_wrap(bp->rx_tail);
 		desc = &bp->rx_ring[entry];
@@ -806,10 +819,14 @@ static int gem_rx(struct macb *bp, int budget)
 		/* Make hw descriptor updates visible to CPU */
 		rmb();
 
-		addr = desc->addr;
+		rxused = (desc->addr & MACB_BIT(RX_USED)) ? true : false;
+		addr = MACB_BF(RX_WADDR, MACB_BFEXT(RX_WADDR, desc->addr));
+#ifdef CONFIG_ARCH_DMA_ADDR_T_64BIT
+		addr |= ((u64)(desc->addrh) << 32);
+#endif
 		ctrl = desc->ctrl;
 
-		if (!(addr & MACB_BIT(RX_USED)))
+		if (!rxused)
 			break;
 
 		bp->rx_tail++;
@@ -835,7 +852,6 @@ static int gem_rx(struct macb *bp, int budget)
 		netdev_vdbg(bp->dev, "gem_rx %u (len %u)\n", entry, len);
 
 		skb_put(skb, len);
-		addr = MACB_BF(RX_WADDR, MACB_BFEXT(RX_WADDR, addr));
 		dma_unmap_single(&bp->pdev->dev, addr,
 				 bp->rx_buffer_size, DMA_FROM_DEVICE);
 
@@ -1299,7 +1315,7 @@ static unsigned int macb_tx_map(struct macb *bp,
 			ctrl |= MACB_BIT(TX_WRAP);
 
 		/* Set TX buffer descriptor */
-		desc->addr = tx_skb->mapping;
+		macb_set_addr(desc, tx_skb->mapping);
 		/* desc->addr must be visible to hardware before clearing
 		 * 'TX_USED' bit in desc->ctrl.
 		 */
@@ -1422,6 +1438,9 @@ static void gem_free_rx_buffers(struct macb *bp)
 
 		desc = &bp->rx_ring[i];
 		addr = MACB_BF(RX_WADDR, MACB_BFEXT(RX_WADDR, desc->addr));
+#ifdef CONFIG_ARCH_DMA_ADDR_T_64BIT
+		addr |= ((u64)(desc->addrh) << 32);
+#endif
 		dma_unmap_single(&bp->pdev->dev, addr, bp->rx_buffer_size,
 				 DMA_FROM_DEVICE);
 		dev_kfree_skb_any(skb);
@@ -1547,7 +1566,7 @@ static void gem_init_rings(struct macb *bp)
 
 	for (q = 0, queue = bp->queues; q < bp->num_queues; ++q, ++queue) {
 		for (i = 0; i < TX_RING_SIZE; i++) {
-			queue->tx_ring[i].addr = 0;
+			macb_set_addr(&(queue->tx_ring[i]), 0);
 			queue->tx_ring[i].ctrl = MACB_BIT(TX_USED);
 		}
 		queue->tx_ring[TX_RING_SIZE - 1].ctrl |= MACB_BIT(TX_WRAP);
@@ -1694,6 +1713,10 @@ static void macb_configure_dma(struct macb *bp)
 			dmacfg |= GEM_BIT(TXCOEN);
 		else
 			dmacfg &= ~GEM_BIT(TXCOEN);
+
+#ifdef CONFIG_ARCH_DMA_ADDR_T_64BIT
+		dmacfg |= GEM_BIT(ADDR64);
+#endif
 		netdev_dbg(bp->dev, "Cadence configure DMA with 0x%08x\n",
 			   dmacfg);
 		gem_writel(bp, DMACFG, dmacfg);
@@ -1739,9 +1762,15 @@ static void macb_init_hw(struct macb *bp)
 	macb_configure_dma(bp);
 
 	/* Initialize TX and RX buffers */
-	macb_writel(bp, RBQP, bp->rx_ring_dma);
+	macb_writel(bp, RBQP, (u32)(bp->rx_ring_dma));
+#ifdef CONFIG_ARCH_DMA_ADDR_T_64BIT
+	macb_writel(bp, RBQPH, (u32)(bp->rx_ring_dma >> 32));
+#endif
 	for (q = 0, queue = bp->queues; q < bp->num_queues; ++q, ++queue) {
-		queue_writel(queue, TBQP, queue->tx_ring_dma);
+		queue_writel(queue, TBQP, (u32)(queue->tx_ring_dma));
+#ifdef CONFIG_ARCH_DMA_ADDR_T_64BIT
+		queue_writel(queue, TBQPH, (u32)(queue->tx_ring_dma >> 32));
+#endif
 
 		/* Enable interrupts */
 		queue_writel(queue, IER,
@@ -2379,6 +2408,9 @@ static int macb_init(struct platform_device *pdev)
 			queue->IDR  = GEM_IDR(hw_q - 1);
 			queue->IMR  = GEM_IMR(hw_q - 1);
 			queue->TBQP = GEM_TBQP(hw_q - 1);
+#ifdef CONFIG_ARCH_DMA_ADDR_T_64BIT
+			queue->TBQPH = GEM_TBQPH(hw_q -1);
+#endif
 		} else {
 			/* queue0 uses legacy registers */
 			queue->ISR  = MACB_ISR;
@@ -2386,6 +2418,9 @@ static int macb_init(struct platform_device *pdev)
 			queue->IDR  = MACB_IDR;
 			queue->IMR  = MACB_IMR;
 			queue->TBQP = MACB_TBQP;
+#ifdef CONFIG_ARCH_DMA_ADDR_T_64BIT
+			queue->TBQPH = MACB_TBQPH;
+#endif
 		}
 
 		/* get irq: here we use the linux queue index, not the hardware
@@ -2935,6 +2970,11 @@ static int macb_probe(struct platform_device *pdev)
 		bp->wol |= MACB_WOL_HAS_MAGIC_PACKET;
 	device_init_wakeup(&pdev->dev, bp->wol & MACB_WOL_HAS_MAGIC_PACKET);
 
+#ifdef CONFIG_ARCH_DMA_ADDR_T_64BIT
+	if (GEM_BFEXT(DBWDEF, gem_readl(bp, DCFG1)) > GEM_DBW32)
+		dma_set_mask(&pdev->dev, DMA_BIT_MASK(44));
+#endif
+
 	spin_lock_init(&bp->lock);
 
 	/* setup capabilities */
diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
index b6fcf10..aa3aeec 100644
--- a/drivers/net/ethernet/cadence/macb.h
+++ b/drivers/net/ethernet/cadence/macb.h
@@ -66,6 +66,8 @@
 #define MACB_USRIO		0x00c0
 #define MACB_WOL		0x00c4
 #define MACB_MID		0x00fc
+#define MACB_TBQPH		0x04C8
+#define MACB_RBQPH		0x04D4
 
 /* GEM register offsets. */
 #define GEM_NCFGR		0x0004 /* Network Config */
@@ -139,6 +141,7 @@
 
 #define GEM_ISR(hw_q)		(0x0400 + ((hw_q) << 2))
 #define GEM_TBQP(hw_q)		(0x0440 + ((hw_q) << 2))
+#define GEM_TBQPH(hw_q)		(0x04C8)
 #define GEM_RBQP(hw_q)		(0x0480 + ((hw_q) << 2))
 #define GEM_IER(hw_q)		(0x0600 + ((hw_q) << 2))
 #define GEM_IDR(hw_q)		(0x0620 + ((hw_q) << 2))
@@ -249,6 +252,8 @@
 #define GEM_RXBS_SIZE		8
 #define GEM_DDRP_OFFSET		24 /* disc_when_no_ahb */
 #define GEM_DDRP_SIZE		1
+#define GEM_ADDR64_OFFSET	30 /* Address bus width - 64b or 32b */
+#define GEM_ADDR64_SIZE		1
 
 
 /* Bitfields in NSR */
@@ -474,6 +479,10 @@
 struct macb_dma_desc {
 	u32	addr;
 	u32	ctrl;
+#ifdef CONFIG_ARCH_DMA_ADDR_T_64BIT
+	u32     addrh;
+	u32     resvd;
+#endif
 };
 
 /* DMA descriptor bitfields */
@@ -777,6 +786,7 @@ struct macb_queue {
 	unsigned int		IDR;
 	unsigned int		IMR;
 	unsigned int		TBQP;
+	unsigned int		TBQPH;
 
 	unsigned int		tx_head, tx_tail;
 	struct macb_dma_desc	*tx_ring;
-- 
2.7.4
