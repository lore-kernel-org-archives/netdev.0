From: Cyrille Pitchen <cyrille.pitchen@atmel.com>
Subject: [PATCH 1/6] net/macb: configure for FIFO mode and non-gigabit
Date: Fri, 18 Jul 2014 16:21:13 +0200
Message-ID: <34adf38d52eb31e3ffd36149d320eb0872452bb1.1405689937.git.cyrille.pitchen@atmel.com>
References: <cover.1405689937.git.cyrille.pitchen@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>
To: <nicolas.ferre@atmel.com>, <davem@davemloft.net>,
	<linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
	<soren.brinkmann@xilinx.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1405689937.git.cyrille.pitchen@atmel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nicolas Ferre <nicolas.ferre@atmel.com>

This addition will also allow to configure DMA burst length.

Signed-off-by: Nicolas Ferre <nicolas.ferre@atmel.com>
Acked-by: Cyrille Pitchen <cyrille.pitchen@atmel.com>
---
 drivers/net/ethernet/cadence/macb.c | 72 +++++++++++++++++++++++++++----------
 drivers/net/ethernet/cadence/macb.h | 19 ++++++++--
 2 files changed, 71 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index e9daa07..0896d88 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -264,7 +264,8 @@ static void macb_handle_link_change(struct net_device *dev)
 				reg |= MACB_BIT(FD);
 			if (phydev->speed == SPEED_100)
 				reg |= MACB_BIT(SPD);
-			if (phydev->speed == SPEED_1000)
+			if (phydev->speed == SPEED_1000
+			 && bp->caps & MACB_CAPS_GIGABIT_MODE_AVAILABLE)
 				reg |= GEM_BIT(GBE);
 
 			macb_or_gem_writel(bp, NCFGR, reg);
@@ -337,7 +338,7 @@ static int macb_mii_probe(struct net_device *dev)
 	}
 
 	/* mask with MAC supported features */
-	if (macb_is_gem(bp))
+	if (macb_is_gem(bp) && bp->caps & MACB_CAPS_GIGABIT_MODE_AVAILABLE)
 		phydev->supported &= PHY_GBIT_FEATURES;
 	else
 		phydev->supported &= PHY_BASIC_FEATURES;
@@ -1342,7 +1343,7 @@ static u32 macb_dbw(struct macb *bp)
 /*
  * Configure the receive DMA engine
  * - use the correct receive buffer size
- * - set the possibility to use INCR16 bursts
+ * - set best burst length for DMA operations
  *   (if not supported by FIFO, it will fallback to default)
  * - set both rx/tx packet buffers to full memory size
  * These are configurable parameters for GEM.
@@ -1354,24 +1355,15 @@ static void macb_configure_dma(struct macb *bp)
 	if (macb_is_gem(bp)) {
 		dmacfg = gem_readl(bp, DMACFG) & ~GEM_BF(RXBS, -1L);
 		dmacfg |= GEM_BF(RXBS, bp->rx_buffer_size / RX_BUFFER_MULTIPLE);
-		dmacfg |= GEM_BF(FBLDO, 16);
+		if (bp->dma_burst_length)
+			dmacfg = GEM_BFINS(FBLDO, bp->dma_burst_length, dmacfg);
 		dmacfg |= GEM_BIT(TXPBMS) | GEM_BF(RXBMS, -1L);
 		dmacfg &= ~GEM_BIT(ENDIA);
+		netdev_dbg(bp->dev, "Cadence configure DMA with 0x%08x\n", dmacfg);
 		gem_writel(bp, DMACFG, dmacfg);
 	}
 }
 
-/*
- * Configure peripheral capacities according to integration options used
- */
-static void macb_configure_caps(struct macb *bp)
-{
-	if (macb_is_gem(bp)) {
-		if (GEM_BFEXT(IRQCOR, gem_readl(bp, DCFG1)) == 0)
-			bp->caps |= MACB_CAPS_ISR_CLEAR_ON_WRITE;
-	}
-}
-
 static void macb_init_hw(struct macb *bp)
 {
 	u32 config;
@@ -1394,7 +1386,6 @@ static void macb_init_hw(struct macb *bp)
 	bp->duplex = DUPLEX_HALF;
 
 	macb_configure_dma(bp);
-	macb_configure_caps(bp);
 
 	/* Initialize TX and RX buffers */
 	macb_writel(bp, RBQP, bp->rx_ring_dma);
@@ -1783,17 +1774,59 @@ static const struct net_device_ops macb_netdev_ops = {
 };
 
 #if defined(CONFIG_OF)
+static struct macb_config pc302gem_config = {
+	.caps = MACB_CAPS_GIGABIT_MODE_AVAILABLE,
+	.dma_burst_length = 16,
+};
+
 static const struct of_device_id macb_dt_ids[] = {
 	{ .compatible = "cdns,at32ap7000-macb" },
 	{ .compatible = "cdns,at91sam9260-macb" },
 	{ .compatible = "cdns,macb" },
-	{ .compatible = "cdns,pc302-gem" },
-	{ .compatible = "cdns,gem" },
+	{ .compatible = "cdns,pc302-gem", .data = &pc302gem_config },
+	{ .compatible = "cdns,gem", .data = &pc302gem_config },
 	{ /* sentinel */ }
 };
 MODULE_DEVICE_TABLE(of, macb_dt_ids);
 #endif
 
+/*
+ * Configure peripheral capacities according to device tree
+ * and integration options used
+ */
+static void macb_configure_caps(struct macb *bp)
+{
+	u32 dcfg;
+	const struct of_device_id *match;
+
+	if (bp->pdev->dev.of_node) {
+		match = of_match_node(macb_dt_ids, bp->pdev->dev.of_node);
+		if (match && match->data) {
+			bp->caps = ((struct macb_config *)match->data)->caps;
+			/*
+			 * As we have access to the matching node, configure
+			 * DMA burst length as well
+			 */
+			bp->dma_burst_length =
+				((struct macb_config *)match->data)->dma_burst_length;
+		}
+	}
+
+	if (MACB_BFEXT(IDNUM, macb_readl(bp, MID)) == 0x2)
+		bp->caps |= MACB_CAPS_MACB_IS_GEM;
+
+	if (macb_is_gem(bp)) {
+		dcfg = gem_readl(bp, DCFG1);
+		if (GEM_BFEXT(IRQCOR, dcfg) == 0)
+			bp->caps |= MACB_CAPS_ISR_CLEAR_ON_WRITE;
+		dcfg = gem_readl(bp, DCFG2);
+		if ((dcfg & (GEM_BIT(RX_PKT_BUFF) | GEM_BIT(TX_PKT_BUFF))) == 0)
+			bp->caps |= MACB_CAPS_FIFO_MODE;
+	}
+
+	netdev_dbg(bp->dev, "Cadence caps 0x%08x\n", bp->caps);
+}
+
 static int __init macb_probe(struct platform_device *pdev)
 {
 	struct macb_platform_data *pdata;
@@ -1897,6 +1930,9 @@ static int __init macb_probe(struct platform_device *pdev)
 
 	dev->base_addr = regs->start;
 
+	/* setup capacities */
+	macb_configure_caps(bp);
+
 	/* setup appropriated routines according to adapter type */
 	if (macb_is_gem(bp)) {
 		bp->macbgem_ops.mog_alloc_rx_buffers = gem_alloc_rx_buffers;
diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
index 51c0244..7ce751b 100644
--- a/drivers/net/ethernet/cadence/macb.h
+++ b/drivers/net/ethernet/cadence/macb.h
@@ -305,6 +305,12 @@
 #define GEM_DBWDEF_OFFSET			25
 #define GEM_DBWDEF_SIZE				3
 
+/* Bitfields in DCFG2. */
+#define GEM_RX_PKT_BUFF_OFFSET			20
+#define GEM_RX_PKT_BUFF_SIZE			1
+#define GEM_TX_PKT_BUFF_OFFSET			21
+#define GEM_TX_PKT_BUFF_SIZE			1
+
 /* Constants for CLK */
 #define MACB_CLK_DIV8				0
 #define MACB_CLK_DIV16				1
@@ -326,7 +332,10 @@
 #define MACB_MAN_CODE				2
 
 /* Capability mask bits */
-#define MACB_CAPS_ISR_CLEAR_ON_WRITE		0x1
+#define MACB_CAPS_ISR_CLEAR_ON_WRITE		0x00000001
+#define MACB_CAPS_FIFO_MODE			0x10000000
+#define MACB_CAPS_GIGABIT_MODE_AVAILABLE	0x20000000
+#define MACB_CAPS_MACB_IS_GEM			0x80000000
 
 /* Bit manipulation macros */
 #define MACB_BIT(name)					\
@@ -554,6 +563,11 @@ struct macb_or_gem_ops {
 	int	(*mog_rx)(struct macb *bp, int budget);
 };
 
+struct macb_config {
+	u32			caps;
+	unsigned int		dma_burst_length;
+};
+
 struct macb {
 	void __iomem		*regs;
 
@@ -595,6 +609,7 @@ struct macb {
 	unsigned int 		duplex;
 
 	u32			caps;
+	unsigned int		dma_burst_length;
 
 	phy_interface_t		phy_interface;
 
@@ -615,7 +630,7 @@ void macb_get_hwaddr(struct macb *bp);
 
 static inline bool macb_is_gem(struct macb *bp)
 {
-	return MACB_BFEXT(IDNUM, macb_readl(bp, MID)) == 0x2;
+	return !!(bp->caps & MACB_CAPS_MACB_IS_GEM);
 }
 
 #endif /* _MACB_H */
-- 
1.8.2.2
