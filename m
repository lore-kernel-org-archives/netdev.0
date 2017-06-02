From: Rafal Ozieblo <rafalo@cadence.com>
Subject: [PATCH v2 1/4] net: macb: Add support for PTP timestamps in DMA descriptors
Date: Fri, 2 Jun 2017 15:26:23 +0100
Message-ID: <1496413583-17212-1-git-send-email-rafalo@cadence.com>
References: <1496413439-12900-1-git-send-email-rafalo@cadence.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Rafal Ozieblo <rafalo@cadence.com>
To: David Miller <davem@davemloft.net>, <nicolas.ferre@atmel.com>,
        Richard Cochran <richardcochran@gmail.com>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <devicetree@vger.kernel.org>,
        <linux-arm-kernel@lists.infradead.org>,
        <harini.katakam@xilinx.com>, <andrei.pistirica@microchip.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1496413439-12900-1-git-send-email-rafalo@cadence.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds support for PTP timestamps in
DMA buffer descriptors. It checks capability at runtime
and uses appropriate buffer descriptor.

Signed-off-by: Rafal Ozieblo <rafalo@cadence.com>
---
 drivers/net/ethernet/cadence/Kconfig |  10 ++-
 drivers/net/ethernet/cadence/macb.c  | 117 ++++++++++++++++++++++++++---------
 drivers/net/ethernet/cadence/macb.h  |  32 +++++++---
 3 files changed, 122 insertions(+), 37 deletions(-)

diff --git a/drivers/net/ethernet/cadence/Kconfig b/drivers/net/ethernet/cadence/Kconfig
index 608bea1..427d65a 100644
--- a/drivers/net/ethernet/cadence/Kconfig
+++ b/drivers/net/ethernet/cadence/Kconfig
@@ -29,7 +29,15 @@ config MACB
 	  support for the MACB/GEM chip.
 
 	  To compile this driver as a module, choose M here: the module
-	  will be called macb.
+	  will be macb.
+
+config MACB_USE_HWSTAMP
+	bool "Use IEEE 1588 hwstamp"
+	depends on MACB
+	default y
+	imply PTP_1588_CLOCK
+	---help---
+	  Enable IEEE 1588 Precision Time Protocol (PTP) support for MACB.
 
 config MACB_PCI
 	tristate "Cadence PCI MACB/GEM support"
diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 91f7492..3151429 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -79,33 +79,84 @@
 #define MACB_HALT_TIMEOUT	1230
 
 /* DMA buffer descriptor might be different size
- * depends on hardware configuration.
+ * depends on hardware configuration:
+ *
+ * 1. dma address width 32 bits:
+ *    word 1: 32 bit address of Data Buffer
+ *    word 2: control
+ *
+ * 2. dma address width 64 bits:
+ *    word 1: 32 bit address of Data Buffer
+ *    word 2: control
+ *    word 3: upper 32 bit address of Data Buffer
+ *    word 4: unused
+ *
+ * 3. dma address width 32 bits with hardware timestamping:
+ *    word 1: 32 bit address of Data Buffer
+ *    word 2: control
+ *    word 3: timestamp word 1
+ *    word 4: timestamp word 2
+ *
+ * 4. dma address width 64 bits with hardware timestamping:
+ *    word 1: 32 bit address of Data Buffer
+ *    word 2: control
+ *    word 3: upper 32 bit address of Data Buffer
+ *    word 4: unused
+ *    word 5: timestamp word 1
+ *    word 6: timestamp word 2
  */
 static unsigned int macb_dma_desc_get_size(struct macb *bp)
 {
-#ifdef CONFIG_ARCH_DMA_ADDR_T_64BIT
-	if (bp->hw_dma_cap == HW_DMA_CAP_64B)
-		return sizeof(struct macb_dma_desc) + sizeof(struct macb_dma_desc_64);
+#ifdef MACB_EXT_DESC
+	unsigned int desc_size;
+
+	switch (bp->hw_dma_cap) {
+	case HW_DMA_CAP_64B:
+		desc_size = sizeof(struct macb_dma_desc)
+			+ sizeof(struct macb_dma_desc_64);
+		break;
+	case HW_DMA_CAP_PTP:
+		desc_size = sizeof(struct macb_dma_desc)
+			+ sizeof(struct macb_dma_desc_ptp);
+		break;
+	case HW_DMA_CAP_64B_PTP:
+		desc_size = sizeof(struct macb_dma_desc)
+			+ sizeof(struct macb_dma_desc_64)
+			+ sizeof(struct macb_dma_desc_ptp);
+		break;
+	default:
+		desc_size = sizeof(struct macb_dma_desc);
+	}
+	return desc_size;
 #endif
 	return sizeof(struct macb_dma_desc);
 }
 
-static unsigned int macb_adj_dma_desc_idx(struct macb *bp, unsigned int idx)
+static unsigned int macb_adj_dma_desc_idx(struct macb *bp, unsigned int desc_idx)
 {
-#ifdef CONFIG_ARCH_DMA_ADDR_T_64BIT
-	/* Dma buffer descriptor is 4 words length (instead of 2 words)
-	 * for 64b GEM.
-	 */
-	if (bp->hw_dma_cap == HW_DMA_CAP_64B)
-		idx <<= 1;
+#ifdef MACB_EXT_DESC
+	switch (bp->hw_dma_cap) {
+	case HW_DMA_CAP_64B:
+	case HW_DMA_CAP_PTP:
+		desc_idx <<= 1;
+		break;
+	case HW_DMA_CAP_64B_PTP:
+		desc_idx *= 3;
+		break;
+	default:
+		break;
+	}
+	return desc_idx;
 #endif
-	return idx;
+	return desc_idx;
 }
 
 #ifdef CONFIG_ARCH_DMA_ADDR_T_64BIT
 static struct macb_dma_desc_64 *macb_64b_desc(struct macb *bp, struct macb_dma_desc *desc)
 {
-	return (struct macb_dma_desc_64 *)((void *)desc + sizeof(struct macb_dma_desc));
+	if (bp->hw_dma_cap & HW_DMA_CAP_64B)
+		return (struct macb_dma_desc_64 *)((void *)desc + sizeof(struct macb_dma_desc));
+	return NULL;
 }
 #endif
 
@@ -602,7 +653,7 @@ static void macb_set_addr(struct macb *bp, struct macb_dma_desc *desc, dma_addr_
 #ifdef CONFIG_ARCH_DMA_ADDR_T_64BIT
 	struct macb_dma_desc_64 *desc_64;
 
-	if (bp->hw_dma_cap == HW_DMA_CAP_64B) {
+	if (bp->hw_dma_cap & HW_DMA_CAP_64B) {
 		desc_64 = macb_64b_desc(bp, desc);
 		desc_64->addrh = upper_32_bits(addr);
 	}
@@ -616,7 +667,7 @@ static dma_addr_t macb_get_addr(struct macb *bp, struct macb_dma_desc *desc)
 #ifdef CONFIG_ARCH_DMA_ADDR_T_64BIT
 	struct macb_dma_desc_64 *desc_64;
 
-	if (bp->hw_dma_cap == HW_DMA_CAP_64B) {
+	if (bp->hw_dma_cap & HW_DMA_CAP_64B) {
 		desc_64 = macb_64b_desc(bp, desc);
 		addr = ((u64)(desc_64->addrh) << 32);
 	}
@@ -715,7 +766,7 @@ static void macb_tx_error_task(struct work_struct *work)
 	/* Reinitialize the TX desc queue */
 	queue_writel(queue, TBQP, lower_32_bits(queue->tx_ring_dma));
 #ifdef CONFIG_ARCH_DMA_ADDR_T_64BIT
-	if (bp->hw_dma_cap == HW_DMA_CAP_64B)
+	if (bp->hw_dma_cap & HW_DMA_CAP_64B)
 		queue_writel(queue, TBQPH, upper_32_bits(queue->tx_ring_dma));
 #endif
 	/* Make TX ring reflect state of hardware */
@@ -1923,9 +1974,13 @@ static void macb_configure_dma(struct macb *bp)
 			dmacfg &= ~GEM_BIT(TXCOEN);
 
 #ifdef CONFIG_ARCH_DMA_ADDR_T_64BIT
-		if (bp->hw_dma_cap == HW_DMA_CAP_64B)
+		if (bp->hw_dma_cap & HW_DMA_CAP_64B)
 			dmacfg |= GEM_BIT(ADDR64);
 #endif
+#ifdef CONFIG_MACB_USE_HWSTAMP
+		if (bp->hw_dma_cap & HW_DMA_CAP_PTP)
+			dmacfg |= GEM_BIT(RXEXT) | GEM_BIT(TXEXT);
+#endif
 		netdev_dbg(bp->dev, "Cadence configure DMA with 0x%08x\n",
 			   dmacfg);
 		gem_writel(bp, DMACFG, dmacfg);
@@ -1973,13 +2028,13 @@ static void macb_init_hw(struct macb *bp)
 	/* Initialize TX and RX buffers */
 	macb_writel(bp, RBQP, lower_32_bits(bp->rx_ring_dma));
 #ifdef CONFIG_ARCH_DMA_ADDR_T_64BIT
-	if (bp->hw_dma_cap == HW_DMA_CAP_64B)
+	if (bp->hw_dma_cap & HW_DMA_CAP_64B)
 		macb_writel(bp, RBQPH, upper_32_bits(bp->rx_ring_dma));
 #endif
 	for (q = 0, queue = bp->queues; q < bp->num_queues; ++q, ++queue) {
 		queue_writel(queue, TBQP, lower_32_bits(queue->tx_ring_dma));
 #ifdef CONFIG_ARCH_DMA_ADDR_T_64BIT
-		if (bp->hw_dma_cap == HW_DMA_CAP_64B)
+		if (bp->hw_dma_cap & HW_DMA_CAP_64B)
 			queue_writel(queue, TBQPH, upper_32_bits(queue->tx_ring_dma));
 #endif
 
@@ -2581,6 +2636,12 @@ static void macb_configure_caps(struct macb *bp,
 		dcfg = gem_readl(bp, DCFG2);
 		if ((dcfg & (GEM_BIT(RX_PKT_BUFF) | GEM_BIT(TX_PKT_BUFF))) == 0)
 			bp->caps |= MACB_CAPS_FIFO_MODE;
+		if (IS_ENABLED(CONFIG_MACB_USE_HWSTAMP) && gem_has_ptp(bp)) {
+			if (!GEM_BFEXT(TSU, gem_readl(bp, DCFG5)))
+				pr_err("GEM doesn't support hardware ptp.\n");
+			else
+				bp->hw_dma_cap |= HW_DMA_CAP_PTP;
+		}
 	}
 
 	dev_dbg(&bp->pdev->dev, "Cadence caps 0x%08x\n", bp->caps);
@@ -2718,7 +2779,7 @@ static int macb_init(struct platform_device *pdev)
 			queue->IMR  = GEM_IMR(hw_q - 1);
 			queue->TBQP = GEM_TBQP(hw_q - 1);
 #ifdef CONFIG_ARCH_DMA_ADDR_T_64BIT
-			if (bp->hw_dma_cap == HW_DMA_CAP_64B)
+			if (bp->hw_dma_cap & HW_DMA_CAP_64B)
 				queue->TBQPH = GEM_TBQPH(hw_q - 1);
 #endif
 		} else {
@@ -2729,7 +2790,7 @@ static int macb_init(struct platform_device *pdev)
 			queue->IMR  = MACB_IMR;
 			queue->TBQP = MACB_TBQP;
 #ifdef CONFIG_ARCH_DMA_ADDR_T_64BIT
-			if (bp->hw_dma_cap == HW_DMA_CAP_64B)
+			if (bp->hw_dma_cap & HW_DMA_CAP_64B)
 				queue->TBQPH = MACB_TBQPH;
 #endif
 		}
@@ -3309,19 +3370,17 @@ static int macb_probe(struct platform_device *pdev)
 		bp->wol |= MACB_WOL_HAS_MAGIC_PACKET;
 	device_init_wakeup(&pdev->dev, bp->wol & MACB_WOL_HAS_MAGIC_PACKET);
 
-#ifdef CONFIG_ARCH_DMA_ADDR_T_64BIT
-	if (GEM_BFEXT(DAW64, gem_readl(bp, DCFG6))) {
-		dma_set_mask(&pdev->dev, DMA_BIT_MASK(44));
-		bp->hw_dma_cap = HW_DMA_CAP_64B;
-	} else
-		bp->hw_dma_cap = HW_DMA_CAP_32B;
-#endif
-
 	spin_lock_init(&bp->lock);
 
 	/* setup capabilities */
 	macb_configure_caps(bp, macb_config);
 
+#ifdef CONFIG_ARCH_DMA_ADDR_T_64BIT
+	if (GEM_BFEXT(DAW64, gem_readl(bp, DCFG6))) {
+		dma_set_mask(&pdev->dev, DMA_BIT_MASK(44));
+		bp->hw_dma_cap |= HW_DMA_CAP_64B;
+	}
+#endif
 	platform_set_drvdata(pdev, dev);
 
 	dev->irq = platform_get_irq(pdev, 0);
diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
index ec037b0..4359b08 100644
--- a/drivers/net/ethernet/cadence/macb.h
+++ b/drivers/net/ethernet/cadence/macb.h
@@ -12,6 +12,10 @@
 
 #include <linux/phy.h>
 
+#if defined(CONFIG_ARCH_DMA_ADDR_T_64BIT) || defined(CONFIG_MACB_USE_HWSTAMP)
+#define MACB_EXT_DESC
+#endif
+
 #define MACB_GREGS_NBR 16
 #define MACB_GREGS_VERSION 2
 #define MACB_MAX_QUEUES 8
@@ -269,6 +273,10 @@
 #define GEM_RXBS_SIZE		8
 #define GEM_DDRP_OFFSET		24 /* disc_when_no_ahb */
 #define GEM_DDRP_SIZE		1
+#define GEM_RXEXT_OFFSET	28 /* RX extended Buffer Descriptor mode */
+#define GEM_RXEXT_SIZE		1
+#define GEM_TXEXT_OFFSET	29 /* TX extended Buffer Descriptor mode */
+#define GEM_TXEXT_SIZE		1
 #define GEM_ADDR64_OFFSET	30 /* Address bus width - 64b or 32b */
 #define GEM_ADDR64_SIZE		1
 
@@ -425,6 +433,11 @@
 #define GEM_TX_PKT_BUFF_OFFSET			21
 #define GEM_TX_PKT_BUFF_SIZE			1
 
+
+/* Bitfields in DCFG5. */
+#define GEM_TSU_OFFSET				8
+#define GEM_TSU_SIZE				1
+
 /* Bitfields in DCFG6. */
 #define GEM_PBUF_LSO_OFFSET			27
 #define GEM_PBUF_LSO_SIZE			1
@@ -546,16 +559,21 @@ struct macb_dma_desc {
 	u32	ctrl;
 };
 
-#ifdef CONFIG_ARCH_DMA_ADDR_T_64BIT
-enum macb_hw_dma_cap {
-	HW_DMA_CAP_32B,
-	HW_DMA_CAP_64B,
-};
+#ifdef MACB_EXT_DESC
+#define HW_DMA_CAP_32B		0
+#define HW_DMA_CAP_64B		(1 << 0)
+#define HW_DMA_CAP_PTP		(1 << 1)
+#define HW_DMA_CAP_64B_PTP	(HW_DMA_CAP_64B | HW_DMA_CAP_PTP)
 
 struct macb_dma_desc_64 {
 	u32 addrh;
 	u32 resvd;
 };
+
+struct macb_dma_desc_ptp {
+	u32	ts_1;
+	u32	ts_2;
+};
 #endif
 
 /* DMA descriptor bitfields */
@@ -954,8 +972,8 @@ struct macb {
 	u32			wol;
 
 	struct macb_ptp_info	*ptp_info;	/* macb-ptp interface */
-#ifdef CONFIG_ARCH_DMA_ADDR_T_64BIT
-	enum macb_hw_dma_cap hw_dma_cap;
+#ifdef MACB_EXT_DESC
+	uint8_t hw_dma_cap;
 #endif
 };
 
-- 
2.4.5
