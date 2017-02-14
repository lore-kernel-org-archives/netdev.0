From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: [PATCH 2/3] net: stmicro: prepare dwmac4 dma for mtl
Date: Tue, 14 Feb 2017 18:00:42 +0000
Message-ID: <63f614c63a054b37cdf8cd3b4b7d285d8d33a139.1487089769.git.jpinto@synopsys.com>
References: <cover.1487089769.git.jpinto@synopsys.com>
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org, Joao Pinto <Joao.Pinto@synopsys.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay2.synopsys.com ([198.182.60.111]:42476 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754957AbdBNSAx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2017 13:00:53 -0500
In-Reply-To: <cover.1487089769.git.jpinto@synopsys.com>
In-Reply-To: <cover.1487089769.git.jpinto@synopsys.com>
References: <cover.1487089769.git.jpinto@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the following features:

a) RX and TX DMA Operation Mode now setting FIFO size
b) FIFO size is obtained from the FEATURES register or can be set in
the Device Tree (fifo depth)
c) Common DMA operations initialization by channel
d) RX DMA initialization by channel
e) TX DMA initialization by channel
f) Debug enhancements (added debug registers to see RX/TX channel State
Machine status)
g) DMA IRQ configuration per channel
h) DMA RX/TX start/stop per channel
i) Number of queues / channels set to 1 in dwmac100 and dwmac1000 to ensure
compatibility

With this patch we get the dma related operations ready for multiple
queue/channel.

Signed-off-by: Joao Pinto <jpinto@synopsys.com>
---
 drivers/net/ethernet/stmicro/stmmac/common.h       |  60 ++-
 .../net/ethernet/stmicro/stmmac/dwmac1000_dma.c    |  16 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c |  19 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac4.h       |  10 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c   | 297 +++++++++-----
 drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.h   |  25 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac4_lib.c   |  58 +--
 drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h    |  15 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c    |  14 +-
 .../net/ethernet/stmicro/stmmac/stmmac_ethtool.c   |   4 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  | 450 +++++++++++++++++----
 11 files changed, 700 insertions(+), 268 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index 8b55747..1c586ee 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -322,6 +322,9 @@ struct dma_features {
 	/* TX and RX number of queues */
 	unsigned int number_rx_queues;
 	unsigned int number_tx_queues;
+	/* TX and RX fifo sizes */
+	unsigned int rx_fifosz;
+	unsigned int tx_fifosz;
 	/* Alternate (enhanced) DESC mode */
 	unsigned int enh_desc;
 };
@@ -358,6 +361,20 @@ struct dma_features {
 #define MTL_RX_ALGORITHM_SP	0x4
 #define MTL_RX_ALGORITHM_WSP	0x5
 
+enum mtl_fifo_size {
+	FIFO_256 = 0x0,
+	FIFO_512 = 0x1,
+	FIFO_1k = 0x3,
+	FIFO_2k = 0x7,
+	FIFO_4k = 0xf,
+	FIFO_8k = 0x1f,
+	FIFO_16k = 0x3f,
+	FIFO_32k = 0x7f
+};
+
+#define FIFO_SIZE_B(x)		(x)
+#define FIFO_SIZE_KB(x)		((x) * 1024)
+
 /* Descriptors helpers */
 struct stmmac_desc_ops {
 	/* DMA RX descriptor ring initialization */
@@ -421,33 +438,44 @@ struct stmmac_dma_ops {
 	int (*reset)(void __iomem *ioaddr);
 	void (*init)(void __iomem *ioaddr, struct stmmac_dma_cfg *dma_cfg,
 		     u32 dma_tx, u32 dma_rx, int atds);
+	void (*init_chan)(void __iomem *ioaddr,
+			  struct stmmac_dma_cfg *dma_cfg, u32 chan);
+	void (*init_rx_chan)(void __iomem *ioaddr,
+			     struct stmmac_dma_cfg *dma_cfg,
+			     u32 dma_rx_phy, u32 chan);
+	void (*init_tx_chan)(void __iomem *ioaddr,
+			     struct stmmac_dma_cfg *dma_cfg,
+			     u32 dma_tx_phy, u32 chan);
 	/* Configure the AXI Bus Mode Register */
 	void (*axi)(void __iomem *ioaddr, struct stmmac_axi *axi);
 	/* Dump DMA registers */
-	void (*dump_regs) (void __iomem *ioaddr);
-	/* Set tx/rx threshold in the csr6 register
-	 * An invalid value enables the store-and-forward mode */
-	void (*dma_mode)(void __iomem *ioaddr, int txmode, int rxmode,
-			 int rxfifosz);
+	void (*dump_regs)(void __iomem *ioaddr, u32 number_channels);
+	/* Configure DMA Operation Mode */
+	void (*dma_mode)(void __iomem *ioaddr, u32 txfifosz, u32 rxfifosz,
+			 u32 txmode, u32 rxmode);
+	void (*dma_rx_mode)(void __iomem *ioaddr, u32 mode, u32 queue_fifo,
+			    u32 chan);
+	void (*dma_tx_mode)(void __iomem *ioaddr, u32 mode, u32 queue_fifo,
+			    u32 chan);
 	/* To track extra statistic (if supported) */
 	void (*dma_diagnostic_fr) (void *data, struct stmmac_extra_stats *x,
 				   void __iomem *ioaddr);
 	void (*enable_dma_transmission) (void __iomem *ioaddr);
-	void (*enable_dma_irq) (void __iomem *ioaddr);
-	void (*disable_dma_irq) (void __iomem *ioaddr);
-	void (*start_tx) (void __iomem *ioaddr);
-	void (*stop_tx) (void __iomem *ioaddr);
-	void (*start_rx) (void __iomem *ioaddr);
-	void (*stop_rx) (void __iomem *ioaddr);
-	int (*dma_interrupt) (void __iomem *ioaddr,
-			      struct stmmac_extra_stats *x);
+	void (*enable_dma_irq)(void __iomem *ioaddr, u32 chan);
+	void (*disable_dma_irq)(void __iomem *ioaddr, u32 chan);
+	void (*start_tx)(void __iomem *ioaddr, u32 chan);
+	void (*stop_tx)(void __iomem *ioaddr, u32 chan);
+	void (*start_rx)(void __iomem *ioaddr, u32 chan);
+	void (*stop_rx)(void __iomem *ioaddr, u32 chan);
+	int (*dma_interrupt)(void __iomem *ioaddr,
+			     struct stmmac_extra_stats *x, u32 chan);
 	/* If supported then get the optional core features */
 	void (*get_hw_feature)(void __iomem *ioaddr,
 			       struct dma_features *dma_cap);
 	/* Program the HW RX Watchdog */
-	void (*rx_watchdog) (void __iomem *ioaddr, u32 riwt);
-	void (*set_tx_ring_len)(void __iomem *ioaddr, u32 len);
-	void (*set_rx_ring_len)(void __iomem *ioaddr, u32 len);
+	void (*rx_watchdog)(void __iomem *ioaddr, u32 num_channels, u32 riwt);
+	void (*set_tx_ring_len)(void __iomem *ioaddr, u32 len, u32 chan);
+	void (*set_rx_ring_len)(void __iomem *ioaddr, u32 len, u32 chan);
 	void (*set_rx_tail_ptr)(void __iomem *ioaddr, u32 tail_ptr, u32 chan);
 	void (*set_tx_tail_ptr)(void __iomem *ioaddr, u32 tail_ptr, u32 chan);
 	void (*enable_tso)(void __iomem *ioaddr, bool en, u32 chan);
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c
index fbaec0f..9d0a283 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c
@@ -148,8 +148,9 @@ static u32 dwmac1000_configure_fc(u32 csr6, int rxfifosz)
 	return csr6;
 }
 
-static void dwmac1000_dma_operation_mode(void __iomem *ioaddr, int txmode,
-					 int rxmode, int rxfifosz)
+static void dwmac1000_dma_operation_mode(void __iomem *ioaddr,
+					 u32 txfifosz, u32 rxfifosz,
+					 u32 txmode, u32 rxmode)
 {
 	u32 csr6 = readl(ioaddr + DMA_CONTROL);
 
@@ -201,7 +202,7 @@ static void dwmac1000_dma_operation_mode(void __iomem *ioaddr, int txmode,
 	writel(csr6, ioaddr + DMA_CONTROL);
 }
 
-static void dwmac1000_dump_dma_regs(void __iomem *ioaddr)
+static void dwmac1000_dump_dma_regs(void __iomem *ioaddr, u32 number_channels)
 {
 	int i;
 	pr_info(" DMA registers\n");
@@ -249,9 +250,16 @@ static void dwmac1000_get_hw_feature(void __iomem *ioaddr,
 	dma_cap->number_tx_channel = (hw_cap & DMA_HW_FEAT_TXCHCNT) >> 22;
 	/* Alternate (enhanced) DESC mode */
 	dma_cap->enh_desc = (hw_cap & DMA_HW_FEAT_ENHDESSEL) >> 24;
+	/* TX and RX number of channels */
+	dma_cap->number_rx_channel = 1;
+	dma_cap->number_tx_channel = 1;
+	/* TX and RX number of queues */
+	dma_cap->number_rx_queues = 1;
+	dma_cap->number_tx_queues = 1;
 }
 
-static void dwmac1000_rx_watchdog(void __iomem *ioaddr, u32 riwt)
+static void dwmac1000_rx_watchdog(void __iomem *ioaddr, u32 number_channels,
+				  u32 riwt)
 {
 	writel(riwt, ioaddr + DMA_RX_WATCHDOG);
 }
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c b/drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c
index d40e91e8..accec0e 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c
@@ -51,8 +51,9 @@ static void dwmac100_dma_init(void __iomem *ioaddr,
  * The transmit threshold can be programmed by setting the TTC bits in the DMA
  * control register.
  */
-static void dwmac100_dma_operation_mode(void __iomem *ioaddr, int txmode,
-					int rxmode, int rxfifosz)
+static void dwmac100_dma_operation_mode(void __iomem *ioaddr,
+					u32 txfifosz, u32 rxfifosz,
+					u32 txmode, u32 rxmode)
 {
 	u32 csr6 = readl(ioaddr + DMA_CONTROL);
 
@@ -66,7 +67,7 @@ static void dwmac100_dma_operation_mode(void __iomem *ioaddr, int txmode,
 	writel(csr6, ioaddr + DMA_CONTROL);
 }
 
-static void dwmac100_dump_dma_regs(void __iomem *ioaddr)
+static void dwmac100_dump_dma_regs(void __iomem *ioaddr, u32 number_channels)
 {
 	int i;
 
@@ -110,6 +111,17 @@ static void dwmac100_dma_diagnostic_fr(void *data, struct stmmac_extra_stats *x,
 	}
 }
 
+static void dwmac100_get_hw_feature(void __iomem *ioaddr,
+				    struct dma_features *dma_cap)
+{
+	/* TX and RX number of channels */
+	dma_cap->number_rx_channel = 1;
+	dma_cap->number_tx_channel = 1;
+	/* TX and RX number of queues */
+	dma_cap->number_rx_queues = 1;
+	dma_cap->number_tx_queues = 1;
+}
+
 const struct stmmac_dma_ops dwmac100_dma_ops = {
 	.reset = dwmac_dma_reset,
 	.init = dwmac100_dma_init,
@@ -124,4 +136,5 @@ const struct stmmac_dma_ops dwmac100_dma_ops = {
 	.start_rx = dwmac_dma_start_rx,
 	.stop_rx = dwmac_dma_stop_rx,
 	.dma_interrupt = dwmac_dma_interrupt,
+	.get_hw_feature = dwmac100_get_hw_feature,
 };
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4.h b/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
index 414070c..671ee9f 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
@@ -161,6 +161,8 @@ enum power_event {
 /* MAC HW features1 bitmap */
 #define GMAC_HW_FEAT_AVSEL		BIT(20)
 #define GMAC_HW_TSOEN			BIT(18)
+#define GMAC_HW_TXFIFOSIZE		GENMASK(10, 6)
+#define GMAC_HW_RXFIFOSIZE		GENMASK(4, 0)
 
 /* MAC HW features2 bitmap */
 #define GMAC_HW_FEAT_TXCHCNT		GENMASK(21, 18)
@@ -205,11 +207,17 @@ enum power_event {
 #define MTL_CHAN_RX_OP_MODE(x)		(MTL_CHANX_BASE_ADDR(x) + 0x30)
 #define MTL_CHAN_RX_DEBUG(x)		(MTL_CHANX_BASE_ADDR(x) + 0x38)
 
+#define MTL_RX_OP_MODE_RQS_MASK		GENMASK(31, 20)
+#define MTL_RX_OP_MODE_RQS_SHIFT	20
+#define MTL_RX_OP_MODE_RQS(x)		((x) << MTL_RX_OP_MODE_RQS_SHIFT)
+
 #define MTL_OP_MODE_RSF			BIT(5)
 #define MTL_OP_MODE_TXQEN		BIT(3)
 #define MTL_OP_MODE_TSF			BIT(1)
 
-#define MTL_OP_MODE_TQS_MASK		GENMASK(24, 16)
+#define MTL_TX_OP_MODE_TQS_MASK		GENMASK(24, 16)
+#define MTL_TX_OP_MODE_TQS_SHIFT	16
+#define MTL_TX_OP_MODE_TQS(x)		((x) << MTL_TX_OP_MODE_TQS_SHIFT)
 
 #define MTL_OP_MODE_TTC_MASK		0x70
 #define MTL_OP_MODE_TTC_SHIFT		4
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c b/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c
index 377d1b4..0c771ff 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c
@@ -71,36 +71,48 @@ static void dwmac4_dma_axi(void __iomem *ioaddr, struct stmmac_axi *axi)
 	writel(value, ioaddr + DMA_SYS_BUS_MODE);
 }
 
-static void dwmac4_dma_init_channel(void __iomem *ioaddr,
-				    struct stmmac_dma_cfg *dma_cfg,
-				    u32 dma_tx_phy, u32 dma_rx_phy,
-				    u32 channel)
+void dwmac4_dma_init_tx_chan(void __iomem *ioaddr,
+			     struct stmmac_dma_cfg *dma_cfg,
+			     u32 dma_tx_phy, u32 chan)
 {
 	u32 value;
-	int txpbl = dma_cfg->txpbl ?: dma_cfg->pbl;
-	int rxpbl = dma_cfg->rxpbl ?: dma_cfg->pbl;
+	u32 txpbl = dma_cfg->txpbl ?: dma_cfg->pbl;
 
-	/* set PBL for each channels. Currently we affect same configuration
-	 * on each channel
-	 */
-	value = readl(ioaddr + DMA_CHAN_CONTROL(channel));
-	if (dma_cfg->pblx8)
-		value = value | DMA_BUS_MODE_PBL;
-	writel(value, ioaddr + DMA_CHAN_CONTROL(channel));
-
-	value = readl(ioaddr + DMA_CHAN_TX_CONTROL(channel));
+	value = readl(ioaddr + DMA_CHAN_TX_CONTROL(chan));
 	value = value | (txpbl << DMA_BUS_MODE_PBL_SHIFT);
-	writel(value, ioaddr + DMA_CHAN_TX_CONTROL(channel));
+	writel(value, ioaddr + DMA_CHAN_TX_CONTROL(chan));
 
-	value = readl(ioaddr + DMA_CHAN_RX_CONTROL(channel));
+	writel(dma_tx_phy, ioaddr + DMA_CHAN_TX_BASE_ADDR(chan));
+}
+
+void dwmac4_dma_init_rx_chan(void __iomem *ioaddr,
+			     struct stmmac_dma_cfg *dma_cfg,
+			     u32 dma_rx_phy, u32 chan)
+{
+	u32 value;
+	u32 rxpbl = dma_cfg->rxpbl ?: dma_cfg->pbl;
+
+	value = readl(ioaddr + DMA_CHAN_RX_CONTROL(chan));
 	value = value | (rxpbl << DMA_BUS_MODE_RPBL_SHIFT);
-	writel(value, ioaddr + DMA_CHAN_RX_CONTROL(channel));
+	writel(value, ioaddr + DMA_CHAN_RX_CONTROL(chan));
 
-	/* Mask interrupts by writing to CSR7 */
-	writel(DMA_CHAN_INTR_DEFAULT_MASK, ioaddr + DMA_CHAN_INTR_ENA(channel));
+	writel(dma_rx_phy, ioaddr + DMA_CHAN_RX_BASE_ADDR(chan));
+}
+
+void dwmac4_dma_init_chan(void __iomem *ioaddr,
+			  struct stmmac_dma_cfg *dma_cfg, u32 chan)
+{
+	u32 value;
+
+	/* common channel control register config */
+	value = readl(ioaddr + DMA_CHAN_CONTROL(chan));
+	if (dma_cfg->pblx8)
+		value = value | DMA_BUS_MODE_PBL;
+	writel(value, ioaddr + DMA_CHAN_CONTROL(chan));
 
-	writel(dma_tx_phy, ioaddr + DMA_CHAN_TX_BASE_ADDR(channel));
-	writel(dma_rx_phy, ioaddr + DMA_CHAN_RX_BASE_ADDR(channel));
+	/* Mask interrupts by writing to CSR7 */
+	writel(DMA_CHAN_INTR_DEFAULT_MASK,
+	       ioaddr + DMA_CHAN_INTR_ENA(chan));
 }
 
 static void dwmac4_dma_init(void __iomem *ioaddr,
@@ -108,7 +120,6 @@ static void dwmac4_dma_init(void __iomem *ioaddr,
 			    u32 dma_tx, u32 dma_rx, int atds)
 {
 	u32 value = readl(ioaddr + DMA_SYS_BUS_MODE);
-	int i;
 
 	/* Set the Fixed burst mode */
 	if (dma_cfg->fixed_burst)
@@ -122,100 +133,163 @@ static void dwmac4_dma_init(void __iomem *ioaddr,
 		value |= DMA_SYS_BUS_AAL;
 
 	writel(value, ioaddr + DMA_SYS_BUS_MODE);
-
-	for (i = 0; i < DMA_CHANNEL_NB_MAX; i++)
-		dwmac4_dma_init_channel(ioaddr, dma_cfg, dma_tx, dma_rx, i);
 }
 
 static void _dwmac4_dump_dma_regs(void __iomem *ioaddr, u32 channel)
 {
 	pr_debug(" Channel %d\n", channel);
-	pr_debug("\tDMA_CHAN_CONTROL, offset: 0x%x, val: 0x%x\n", 0,
+	pr_debug("\tDMA_CHAN_CONTROL, offset: 0x%x, val: 0x%x\n",
+		 DMA_CHAN_CONTROL(channel),
 		 readl(ioaddr + DMA_CHAN_CONTROL(channel)));
-	pr_debug("\tDMA_CHAN_TX_CONTROL, offset: 0x%x, val: 0x%x\n", 0x4,
+	pr_debug("\tDMA_CHAN_TX_CONTROL, offset: 0x%x, val: 0x%x\n",
+		 DMA_CHAN_TX_CONTROL(channel),
 		 readl(ioaddr + DMA_CHAN_TX_CONTROL(channel)));
-	pr_debug("\tDMA_CHAN_RX_CONTROL, offset: 0x%x, val: 0x%x\n", 0x8,
+	pr_debug("\tDMA_CHAN_RX_CONTROL, offset: 0x%x, val: 0x%x\n",
+		 DMA_CHAN_RX_CONTROL(channel),
 		 readl(ioaddr + DMA_CHAN_RX_CONTROL(channel)));
-	pr_debug("\tDMA_CHAN_TX_BASE_ADDR, offset: 0x%x, val: 0x%x\n", 0x14,
+	pr_debug("\tDMA_CHAN_TX_BASE_ADDR, offset: 0x%x, val: 0x%x\n",
+		 DMA_CHAN_TX_BASE_ADDR(channel),
 		 readl(ioaddr + DMA_CHAN_TX_BASE_ADDR(channel)));
-	pr_debug("\tDMA_CHAN_RX_BASE_ADDR, offset: 0x%x, val: 0x%x\n", 0x1c,
+	pr_debug("\tDMA_CHAN_RX_BASE_ADDR, offset: 0x%x, val: 0x%x\n",
+		 DMA_CHAN_RX_BASE_ADDR(channel),
 		 readl(ioaddr + DMA_CHAN_RX_BASE_ADDR(channel)));
-	pr_debug("\tDMA_CHAN_TX_END_ADDR, offset: 0x%x, val: 0x%x\n", 0x20,
+	pr_debug("\tDMA_CHAN_TX_END_ADDR, offset: 0x%x, val: 0x%x\n",
+		 DMA_CHAN_TX_END_ADDR(channel),
 		 readl(ioaddr + DMA_CHAN_TX_END_ADDR(channel)));
-	pr_debug("\tDMA_CHAN_RX_END_ADDR, offset: 0x%x, val: 0x%x\n", 0x28,
+	pr_debug("\tDMA_CHAN_RX_END_ADDR, offset: 0x%x, val: 0x%x\n",
+		 DMA_CHAN_RX_END_ADDR(channel),
 		 readl(ioaddr + DMA_CHAN_RX_END_ADDR(channel)));
-	pr_debug("\tDMA_CHAN_TX_RING_LEN, offset: 0x%x, val: 0x%x\n", 0x2c,
+	pr_debug("\tDMA_CHAN_TX_RING_LEN, offset: 0x%x, val: 0x%x\n",
+		 DMA_CHAN_TX_RING_LEN(channel),
 		 readl(ioaddr + DMA_CHAN_TX_RING_LEN(channel)));
-	pr_debug("\tDMA_CHAN_RX_RING_LEN, offset: 0x%x, val: 0x%x\n", 0x30,
+	pr_debug("\tDMA_CHAN_RX_RING_LEN, offset: 0x%x, val: 0x%x\n",
+		 DMA_CHAN_RX_RING_LEN(channel),
 		 readl(ioaddr + DMA_CHAN_RX_RING_LEN(channel)));
-	pr_debug("\tDMA_CHAN_INTR_ENA, offset: 0x%x, val: 0x%x\n", 0x34,
+	pr_debug("\tDMA_CHAN_INTR_ENA, offset: 0x%x, val: 0x%x\n",
+		 DMA_CHAN_INTR_ENA(channel),
 		 readl(ioaddr + DMA_CHAN_INTR_ENA(channel)));
-	pr_debug("\tDMA_CHAN_RX_WATCHDOG, offset: 0x%x, val: 0x%x\n", 0x38,
+	pr_debug("\tDMA_CHAN_RX_WATCHDOG, offset: 0x%x, val: 0x%x\n",
+		 DMA_CHAN_RX_WATCHDOG(channel),
 		 readl(ioaddr + DMA_CHAN_RX_WATCHDOG(channel)));
-	pr_debug("\tDMA_CHAN_SLOT_CTRL_STATUS, offset: 0x%x, val: 0x%x\n", 0x3c,
+	pr_debug("\tDMA_CHAN_SLOT_CTRL_STATUS, offset: 0x%x, val: 0x%x\n",
+		 DMA_CHAN_SLOT_CTRL_STATUS(channel),
 		 readl(ioaddr + DMA_CHAN_SLOT_CTRL_STATUS(channel)));
-	pr_debug("\tDMA_CHAN_CUR_TX_DESC, offset: 0x%x, val: 0x%x\n", 0x44,
+	pr_debug("\tDMA_CHAN_CUR_TX_DESC, offset: 0x%x, val: 0x%x\n",
+		 DMA_CHAN_CUR_TX_DESC(channel),
 		 readl(ioaddr + DMA_CHAN_CUR_TX_DESC(channel)));
-	pr_debug("\tDMA_CHAN_CUR_RX_DESC, offset: 0x%x, val: 0x%x\n", 0x4c,
+	pr_debug("\tDMA_CHAN_CUR_RX_DESC, offset: 0x%x, val: 0x%x\n",
+		 DMA_CHAN_CUR_RX_DESC(channel),
 		 readl(ioaddr + DMA_CHAN_CUR_RX_DESC(channel)));
-	pr_debug("\tDMA_CHAN_CUR_TX_BUF_ADDR, offset: 0x%x, val: 0x%x\n", 0x54,
+	pr_debug("\tDMA_CHAN_CUR_TX_BUF_ADDR, offset: 0x%x, val: 0x%x\n",
+		 DMA_CHAN_CUR_TX_BUF_ADDR(channel),
 		 readl(ioaddr + DMA_CHAN_CUR_TX_BUF_ADDR(channel)));
-	pr_debug("\tDMA_CHAN_CUR_RX_BUF_ADDR, offset: 0x%x, val: 0x%x\n", 0x5c,
+	pr_debug("\tDMA_CHAN_CUR_RX_BUF_ADDR, offset: 0x%x, val: 0x%x\n",
+		 DMA_CHAN_CUR_RX_BUF_ADDR(channel),
 		 readl(ioaddr + DMA_CHAN_CUR_RX_BUF_ADDR(channel)));
-	pr_debug("\tDMA_CHAN_STATUS, offset: 0x%x, val: 0x%x\n", 0x60,
+	pr_debug("\tDMA_CHAN_STATUS, offset: 0x%x, val: 0x%x\n",
+		 DMA_CHAN_STATUS(channel),
 		 readl(ioaddr + DMA_CHAN_STATUS(channel)));
+	pr_debug("\tMTL_CHAN_RX_OP_MODE, offset: 0x%x, val: 0x%x\n",
+		 MTL_CHAN_RX_OP_MODE(channel),
+		 readl(ioaddr + MTL_CHAN_RX_OP_MODE(channel)));
+	pr_debug("\tMTL_CHAN_TX_OP_MODE, offset: 0x%x, val: 0x%x\n",
+		 MTL_CHAN_TX_OP_MODE(channel),
+		 readl(ioaddr + MTL_CHAN_TX_OP_MODE(channel)));
 }
 
-static void dwmac4_dump_dma_regs(void __iomem *ioaddr)
+static void dwmac4_dump_dma_regs(void __iomem *ioaddr, u32 number_channels)
 {
-	int i;
+	int chan;
 
 	pr_debug(" GMAC4 DMA registers\n");
 
-	for (i = 0; i < DMA_CHANNEL_NB_MAX; i++)
-		_dwmac4_dump_dma_regs(ioaddr, i);
+	pr_debug("\nDMA Debug Registers:\n");
+	pr_debug("\tDMA DEBUG 1, offset: 0x%x, val: 0x%x\n",
+		 DMA_DEBUG_STATUS_0, readl(ioaddr + DMA_DEBUG_STATUS_0));
+	pr_debug("\tDMA DEBUG 2, offset: 0x%x, val: 0x%x\n",
+		 DMA_DEBUG_STATUS_1, readl(ioaddr + DMA_DEBUG_STATUS_1));
+	pr_debug("\tDMA DEBUG 3, offset: 0x%x, val: 0x%x\n",
+		 DMA_DEBUG_STATUS_2, readl(ioaddr + DMA_DEBUG_STATUS_2));
+
+	for (chan = 0; chan < number_channels; chan++)
+		_dwmac4_dump_dma_regs(ioaddr, chan);
 }
 
-static void dwmac4_rx_watchdog(void __iomem *ioaddr, u32 riwt)
+static void dwmac4_rx_watchdog(void __iomem *ioaddr, u32 number_channels,
+			       u32 riwt)
 {
-	int i;
+	int chan;
+
+	for (chan = 0; chan < number_channels; chan++)
+		writel(riwt, ioaddr + DMA_CHAN_RX_WATCHDOG(chan));
+}
+
+static void dwmac4_dma_rx_chan_op_mode(void __iomem *ioaddr, u32 mode,
+				       u32 queue_fifo, u32 chan)
+{
+	u32 mtl_rx_op, mtl_rx_int;
+
+	mtl_rx_op = readl(ioaddr + MTL_CHAN_RX_OP_MODE(chan));
+
+	if (mode == SF_DMA_MODE) {
+		pr_debug("GMAC4: enable RX store and forward mode\n");
+		mtl_rx_op |= MTL_OP_MODE_RSF;
+	} else {
+		pr_debug("GMAC4: disable RX SF mode (threshold %d)\n", mode);
+		mtl_rx_op &= ~MTL_OP_MODE_RSF;
+		mtl_rx_op &= MTL_OP_MODE_RTC_MASK;
+		if (mode <= 32)
+			mtl_rx_op |= MTL_OP_MODE_RTC_32;
+		else if (mode <= 64)
+			mtl_rx_op |= MTL_OP_MODE_RTC_64;
+		else if (mode <= 96)
+			mtl_rx_op |= MTL_OP_MODE_RTC_96;
+		else
+			mtl_rx_op |= MTL_OP_MODE_RTC_128;
+	}
+
+	mtl_rx_op |= MTL_RX_OP_MODE_RQS(queue_fifo) & MTL_RX_OP_MODE_RQS_MASK;
 
-	for (i = 0; i < DMA_CHANNEL_NB_MAX; i++)
-		writel(riwt, ioaddr + DMA_CHAN_RX_WATCHDOG(i));
+	writel(mtl_rx_op, ioaddr + MTL_CHAN_RX_OP_MODE(chan));
+
+	/* Enable MTL RX overflow */
+	mtl_rx_int = readl(ioaddr + MTL_CHAN_INT_CTRL(chan));
+	writel(mtl_rx_int | MTL_RX_OVERFLOW_INT_EN,
+	       ioaddr + MTL_CHAN_INT_CTRL(chan));
 }
 
-static void dwmac4_dma_chan_op_mode(void __iomem *ioaddr, int txmode,
-				    int rxmode, u32 channel)
+static void dwmac4_dma_tx_chan_op_mode(void __iomem *ioaddr, u32 mode,
+				       u32 queue_fifo, u32 chan)
 {
-	u32 mtl_tx_op, mtl_rx_op, mtl_rx_int;
+	u32 mtl_tx_op;
 
 	/* Following code only done for channel 0, other channels not yet
 	 * supported.
 	 */
-	mtl_tx_op = readl(ioaddr + MTL_CHAN_TX_OP_MODE(channel));
+	mtl_tx_op = readl(ioaddr + MTL_CHAN_TX_OP_MODE(chan));
 
-	if (txmode == SF_DMA_MODE) {
-		pr_debug("GMAC: enable TX store and forward mode\n");
+	if (mode == SF_DMA_MODE) {
+		pr_debug("EQOS: enable TX store and forward mode\n");
 		/* Transmit COE type 2 cannot be done in cut-through mode. */
 		mtl_tx_op |= MTL_OP_MODE_TSF;
 	} else {
-		pr_debug("GMAC: disabling TX SF (threshold %d)\n", txmode);
+		pr_debug("EQOS: disabling TX SF (threshold %d)\n", mode);
 		mtl_tx_op &= ~MTL_OP_MODE_TSF;
 		mtl_tx_op &= MTL_OP_MODE_TTC_MASK;
 		/* Set the transmit threshold */
-		if (txmode <= 32)
+		if (mode <= 32)
 			mtl_tx_op |= MTL_OP_MODE_TTC_32;
-		else if (txmode <= 64)
+		else if (mode <= 64)
 			mtl_tx_op |= MTL_OP_MODE_TTC_64;
-		else if (txmode <= 96)
+		else if (mode <= 96)
 			mtl_tx_op |= MTL_OP_MODE_TTC_96;
-		else if (txmode <= 128)
+		else if (mode <= 128)
 			mtl_tx_op |= MTL_OP_MODE_TTC_128;
-		else if (txmode <= 192)
+		else if (mode <= 192)
 			mtl_tx_op |= MTL_OP_MODE_TTC_192;
-		else if (txmode <= 256)
+		else if (mode <= 256)
 			mtl_tx_op |= MTL_OP_MODE_TTC_256;
-		else if (txmode <= 384)
+		else if (mode <= 384)
 			mtl_tx_op |= MTL_OP_MODE_TTC_384;
 		else
 			mtl_tx_op |= MTL_OP_MODE_TTC_512;
@@ -230,47 +304,65 @@ static void dwmac4_dma_chan_op_mode(void __iomem *ioaddr, int txmode,
 	 * be RO, however, writing the whole TQS field will result in a value
 	 * equal to DWC_EQOS_TXFIFO_SIZE, just like for DWC_EQOS_NUM_TXQ == 1.
 	 */
-	mtl_tx_op |= MTL_OP_MODE_TXQEN | MTL_OP_MODE_TQS_MASK;
-	writel(mtl_tx_op, ioaddr +  MTL_CHAN_TX_OP_MODE(channel));
-
-	mtl_rx_op = readl(ioaddr + MTL_CHAN_RX_OP_MODE(channel));
-
-	if (rxmode == SF_DMA_MODE) {
-		pr_debug("GMAC: enable RX store and forward mode\n");
-		mtl_rx_op |= MTL_OP_MODE_RSF;
-	} else {
-		pr_debug("GMAC: disable RX SF mode (threshold %d)\n", rxmode);
-		mtl_rx_op &= ~MTL_OP_MODE_RSF;
-		mtl_rx_op &= MTL_OP_MODE_RTC_MASK;
-		if (rxmode <= 32)
-			mtl_rx_op |= MTL_OP_MODE_RTC_32;
-		else if (rxmode <= 64)
-			mtl_rx_op |= MTL_OP_MODE_RTC_64;
-		else if (rxmode <= 96)
-			mtl_rx_op |= MTL_OP_MODE_RTC_96;
-		else
-			mtl_rx_op |= MTL_OP_MODE_RTC_128;
-	}
 
-	writel(mtl_rx_op, ioaddr + MTL_CHAN_RX_OP_MODE(channel));
+	mtl_tx_op |= MTL_OP_MODE_TXQEN | (MTL_TX_OP_MODE_TQS(queue_fifo)
+						& MTL_TX_OP_MODE_TQS_MASK);
 
-	/* Enable MTL RX overflow */
-	mtl_rx_int = readl(ioaddr + MTL_CHAN_INT_CTRL(channel));
-	writel(mtl_rx_int | MTL_RX_OVERFLOW_INT_EN,
-	       ioaddr + MTL_CHAN_INT_CTRL(channel));
+	writel(mtl_tx_op, ioaddr +  MTL_CHAN_TX_OP_MODE(chan));
 }
 
-static void dwmac4_dma_operation_mode(void __iomem *ioaddr, int txmode,
-				      int rxmode, int rxfifosz)
+static u32 dwmac4_get_real_fifo_sz(u32 fifosz)
 {
-	/* Only Channel 0 is actually configured and used */
-	dwmac4_dma_chan_op_mode(ioaddr, txmode, rxmode, 0);
+	u32 f_fifo_size = 0;
+
+	switch (fifosz) {
+	case 0:
+	f_fifo_size = FIFO_SIZE_B(128);
+	break;
+	case 1:
+	f_fifo_size = FIFO_SIZE_B(256);
+	break;
+	case 2:
+	f_fifo_size = FIFO_SIZE_B(512);
+	break;
+	case 3:
+	f_fifo_size = FIFO_SIZE_KB(1);
+	break;
+	case 4:
+	f_fifo_size = FIFO_SIZE_KB(2);
+	break;
+	case 5:
+	f_fifo_size = FIFO_SIZE_KB(4);
+	break;
+	case 6:
+	f_fifo_size = FIFO_SIZE_KB(8);
+	break;
+	case 7:
+	f_fifo_size = FIFO_SIZE_KB(16);
+	break;
+	case 8:
+	f_fifo_size = FIFO_SIZE_KB(32);
+	break;
+	case 9:
+	f_fifo_size = FIFO_SIZE_KB(64);
+	break;
+	case 10:
+	f_fifo_size = FIFO_SIZE_KB(128);
+	break;
+	case 11:
+	f_fifo_size = FIFO_SIZE_KB(256);
+	break;
+	}
+
+	return f_fifo_size;
 }
 
 static void dwmac4_get_hw_feature(void __iomem *ioaddr,
 				  struct dma_features *dma_cap)
 {
 	u32 hw_cap = readl(ioaddr + GMAC_HW_FEATURE0);
+	u32 rx_fifosz = 0;
+	u32 tx_fifosz = 0;
 
 	/*  MAC HW feature0 */
 	dma_cap->mbps_10_100 = (hw_cap & GMAC_HW_FEAT_MIISEL);
@@ -296,6 +388,12 @@ static void dwmac4_get_hw_feature(void __iomem *ioaddr,
 	hw_cap = readl(ioaddr + GMAC_HW_FEATURE1);
 	dma_cap->av = (hw_cap & GMAC_HW_FEAT_AVSEL) >> 20;
 	dma_cap->tsoen = (hw_cap & GMAC_HW_TSOEN) >> 18;
+	/* TX and RX fifo sizes */
+	rx_fifosz = (hw_cap & GMAC_HW_RXFIFOSIZE) >> 0;
+	tx_fifosz = (hw_cap & GMAC_HW_TXFIFOSIZE) >> 6;
+	dma_cap->rx_fifosz = dwmac4_get_real_fifo_sz(rx_fifosz);
+	dma_cap->tx_fifosz = dwmac4_get_real_fifo_sz(tx_fifosz);
+
 	/* MAC HW feature2 */
 	hw_cap = readl(ioaddr + GMAC_HW_FEATURE2);
 	/* TX and RX number of channels */
@@ -336,7 +434,8 @@ const struct stmmac_dma_ops dwmac4_dma_ops = {
 	.init = dwmac4_dma_init,
 	.axi = dwmac4_dma_axi,
 	.dump_regs = dwmac4_dump_dma_regs,
-	.dma_mode = dwmac4_dma_operation_mode,
+	.dma_rx_mode = dwmac4_dma_rx_chan_op_mode,
+	.dma_tx_mode = dwmac4_dma_tx_chan_op_mode,
 	.enable_dma_irq = dwmac4_enable_dma_irq,
 	.disable_dma_irq = dwmac4_disable_dma_irq,
 	.start_tx = dwmac4_dma_start_tx,
@@ -356,9 +455,13 @@ const struct stmmac_dma_ops dwmac4_dma_ops = {
 const struct stmmac_dma_ops dwmac410_dma_ops = {
 	.reset = dwmac4_dma_reset,
 	.init = dwmac4_dma_init,
+	.init_chan = dwmac4_dma_init_chan,
+	.init_rx_chan = dwmac4_dma_init_rx_chan,
+	.init_tx_chan = dwmac4_dma_init_tx_chan,
 	.axi = dwmac4_dma_axi,
 	.dump_regs = dwmac4_dump_dma_regs,
-	.dma_mode = dwmac4_dma_operation_mode,
+	.dma_rx_mode = dwmac4_dma_rx_chan_op_mode,
+	.dma_tx_mode = dwmac4_dma_tx_chan_op_mode,
 	.enable_dma_irq = dwmac410_enable_dma_irq,
 	.disable_dma_irq = dwmac4_disable_dma_irq,
 	.start_tx = dwmac4_dma_start_tx,
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.h b/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.h
index 1b06df7..a485201 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.h
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.h
@@ -14,11 +14,6 @@
 #ifndef __DWMAC4_DMA_H__
 #define __DWMAC4_DMA_H__
 
-/* Define the max channel number used for tx (also rx).
- * dwmac4 accepts up to 8 channels for TX (and also 8 channels for RX
- */
-#define DMA_CHANNEL_NB_MAX		1
-
 #define DMA_BUS_MODE			0x00001000
 #define DMA_SYS_BUS_MODE		0x00001004
 #define DMA_STATUS			0x00001008
@@ -185,17 +180,17 @@
 
 int dwmac4_dma_reset(void __iomem *ioaddr);
 void dwmac4_enable_dma_transmission(void __iomem *ioaddr, u32 tail_ptr);
-void dwmac4_enable_dma_irq(void __iomem *ioaddr);
-void dwmac410_enable_dma_irq(void __iomem *ioaddr);
-void dwmac4_disable_dma_irq(void __iomem *ioaddr);
-void dwmac4_dma_start_tx(void __iomem *ioaddr);
-void dwmac4_dma_stop_tx(void __iomem *ioaddr);
-void dwmac4_dma_start_rx(void __iomem *ioaddr);
-void dwmac4_dma_stop_rx(void __iomem *ioaddr);
+void dwmac4_enable_dma_irq(void __iomem *ioaddr, u32 chan);
+void dwmac410_enable_dma_irq(void __iomem *ioaddr, u32 chan);
+void dwmac4_disable_dma_irq(void __iomem *ioaddr, u32 chan);
+void dwmac4_dma_start_tx(void __iomem *ioaddr, u32 chan);
+void dwmac4_dma_stop_tx(void __iomem *ioaddr, u32 chan);
+void dwmac4_dma_start_rx(void __iomem *ioaddr, u32 chan);
+void dwmac4_dma_stop_rx(void __iomem *ioaddr, u32 chan);
 int dwmac4_dma_interrupt(void __iomem *ioaddr,
-			 struct stmmac_extra_stats *x);
-void dwmac4_set_rx_ring_len(void __iomem *ioaddr, u32 len);
-void dwmac4_set_tx_ring_len(void __iomem *ioaddr, u32 len);
+			struct stmmac_extra_stats *x, u32 chan);
+void dwmac4_set_rx_ring_len(void __iomem *ioaddr, u32 len, u32 chan);
+void dwmac4_set_tx_ring_len(void __iomem *ioaddr, u32 len, u32 chan);
 void dwmac4_set_rx_tail_ptr(void __iomem *ioaddr, u32 tail_ptr, u32 chan);
 void dwmac4_set_tx_tail_ptr(void __iomem *ioaddr, u32 tail_ptr, u32 chan);
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_lib.c b/drivers/net/ethernet/stmicro/stmmac/dwmac4_lib.c
index c7326d5..1363b72 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_lib.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_lib.c
@@ -37,96 +37,96 @@ int dwmac4_dma_reset(void __iomem *ioaddr)
 
 void dwmac4_set_rx_tail_ptr(void __iomem *ioaddr, u32 tail_ptr, u32 chan)
 {
-	writel(tail_ptr, ioaddr + DMA_CHAN_RX_END_ADDR(0));
+	writel(tail_ptr, ioaddr + DMA_CHAN_RX_END_ADDR(chan));
 }
 
 void dwmac4_set_tx_tail_ptr(void __iomem *ioaddr, u32 tail_ptr, u32 chan)
 {
-	writel(tail_ptr, ioaddr + DMA_CHAN_TX_END_ADDR(0));
+	writel(tail_ptr, ioaddr + DMA_CHAN_TX_END_ADDR(chan));
 }
 
-void dwmac4_dma_start_tx(void __iomem *ioaddr)
+void dwmac4_dma_start_tx(void __iomem *ioaddr, u32 chan)
 {
-	u32 value = readl(ioaddr + DMA_CHAN_TX_CONTROL(STMMAC_CHAN0));
+	u32 value = readl(ioaddr + DMA_CHAN_TX_CONTROL(chan));
 
 	value |= DMA_CONTROL_ST;
-	writel(value, ioaddr + DMA_CHAN_TX_CONTROL(STMMAC_CHAN0));
+	writel(value, ioaddr + DMA_CHAN_TX_CONTROL(chan));
 
 	value = readl(ioaddr + GMAC_CONFIG);
 	value |= GMAC_CONFIG_TE;
 	writel(value, ioaddr + GMAC_CONFIG);
 }
 
-void dwmac4_dma_stop_tx(void __iomem *ioaddr)
+void dwmac4_dma_stop_tx(void __iomem *ioaddr, u32 chan)
 {
-	u32 value = readl(ioaddr + DMA_CHAN_TX_CONTROL(STMMAC_CHAN0));
+	u32 value = readl(ioaddr + DMA_CHAN_TX_CONTROL(chan));
 
 	value &= ~DMA_CONTROL_ST;
-	writel(value, ioaddr + DMA_CHAN_TX_CONTROL(STMMAC_CHAN0));
+	writel(value, ioaddr + DMA_CHAN_TX_CONTROL(chan));
 
 	value = readl(ioaddr + GMAC_CONFIG);
 	value &= ~GMAC_CONFIG_TE;
 	writel(value, ioaddr + GMAC_CONFIG);
 }
 
-void dwmac4_dma_start_rx(void __iomem *ioaddr)
+void dwmac4_dma_start_rx(void __iomem *ioaddr, u32 chan)
 {
-	u32 value = readl(ioaddr + DMA_CHAN_RX_CONTROL(STMMAC_CHAN0));
+	u32 value = readl(ioaddr + DMA_CHAN_RX_CONTROL(chan));
 
 	value |= DMA_CONTROL_SR;
 
-	writel(value, ioaddr + DMA_CHAN_RX_CONTROL(STMMAC_CHAN0));
+	writel(value, ioaddr + DMA_CHAN_RX_CONTROL(chan));
 
 	value = readl(ioaddr + GMAC_CONFIG);
 	value |= GMAC_CONFIG_RE;
 	writel(value, ioaddr + GMAC_CONFIG);
 }
 
-void dwmac4_dma_stop_rx(void __iomem *ioaddr)
+void dwmac4_dma_stop_rx(void __iomem *ioaddr, u32 chan)
 {
-	u32 value = readl(ioaddr + DMA_CHAN_RX_CONTROL(STMMAC_CHAN0));
+	u32 value = readl(ioaddr + DMA_CHAN_RX_CONTROL(chan));
 
 	value &= ~DMA_CONTROL_SR;
-	writel(value, ioaddr + DMA_CHAN_RX_CONTROL(STMMAC_CHAN0));
+	writel(value, ioaddr + DMA_CHAN_RX_CONTROL(chan));
 
 	value = readl(ioaddr + GMAC_CONFIG);
 	value &= ~GMAC_CONFIG_RE;
 	writel(value, ioaddr + GMAC_CONFIG);
 }
 
-void dwmac4_set_tx_ring_len(void __iomem *ioaddr, u32 len)
+void dwmac4_set_tx_ring_len(void __iomem *ioaddr, u32 len, u32 chan)
 {
-	writel(len, ioaddr + DMA_CHAN_TX_RING_LEN(STMMAC_CHAN0));
+	writel(len, ioaddr + DMA_CHAN_TX_RING_LEN(chan));
 }
 
-void dwmac4_set_rx_ring_len(void __iomem *ioaddr, u32 len)
+void dwmac4_set_rx_ring_len(void __iomem *ioaddr, u32 len, u32 chan)
 {
-	writel(len, ioaddr + DMA_CHAN_RX_RING_LEN(STMMAC_CHAN0));
+	writel(len, ioaddr + DMA_CHAN_RX_RING_LEN(chan));
 }
 
-void dwmac4_enable_dma_irq(void __iomem *ioaddr)
+void dwmac4_enable_dma_irq(void __iomem *ioaddr, u32 chan)
 {
 	writel(DMA_CHAN_INTR_DEFAULT_MASK, ioaddr +
-	       DMA_CHAN_INTR_ENA(STMMAC_CHAN0));
+	       DMA_CHAN_INTR_ENA(chan));
 }
 
-void dwmac410_enable_dma_irq(void __iomem *ioaddr)
+void dwmac410_enable_dma_irq(void __iomem *ioaddr, u32 chan)
 {
 	writel(DMA_CHAN_INTR_DEFAULT_MASK_4_10,
-	       ioaddr + DMA_CHAN_INTR_ENA(STMMAC_CHAN0));
+	       ioaddr + DMA_CHAN_INTR_ENA(chan));
 }
 
-void dwmac4_disable_dma_irq(void __iomem *ioaddr)
+void dwmac4_disable_dma_irq(void __iomem *ioaddr, u32 chan)
 {
-	writel(0, ioaddr + DMA_CHAN_INTR_ENA(STMMAC_CHAN0));
+	writel(0, ioaddr + DMA_CHAN_INTR_ENA(chan));
 }
 
 int dwmac4_dma_interrupt(void __iomem *ioaddr,
-			 struct stmmac_extra_stats *x)
+			 struct stmmac_extra_stats *x, u32 chan)
 {
 	int ret = 0;
 
-	u32 intr_status = readl(ioaddr + DMA_CHAN_STATUS(0));
+	u32 intr_status = readl(ioaddr + DMA_CHAN_STATUS(chan));
 
 	/* ABNORMAL interrupts */
 	if (unlikely(intr_status & DMA_CHAN_STATUS_AIS)) {
@@ -153,7 +153,7 @@ int dwmac4_dma_interrupt(void __iomem *ioaddr,
 		if (likely(intr_status & DMA_CHAN_STATUS_RI)) {
 			u32 value;
 
-			value = readl(ioaddr + DMA_CHAN_INTR_ENA(STMMAC_CHAN0));
+			value = readl(ioaddr + DMA_CHAN_INTR_ENA(chan));
 			/* to schedule NAPI on real RIE event. */
 			if (likely(value & DMA_CHAN_INTR_ENA_RIE)) {
 				x->rx_normal_irq_n++;
@@ -172,7 +172,7 @@ int dwmac4_dma_interrupt(void __iomem *ioaddr,
 	 * status [21-0] expect reserved bits [5-3]
 	 */
 	writel((intr_status & 0x3fffc7),
-	       ioaddr + DMA_CHAN_STATUS(STMMAC_CHAN0));
+	       ioaddr + DMA_CHAN_STATUS(chan));
 
 	return ret;
 }
@@ -187,7 +187,7 @@ void stmmac_dwmac4_set_mac_addr(void __iomem *ioaddr, u8 addr[6],
 	 * bit that has no effect on the High Reg 0 where the bit 31 (MO)
 	 * is RO.
 	 */
-	data |= (STMMAC_CHAN0 << GMAC_HI_DCS_SHIFT);
+	data |= (STMMAC_CHAN0 << GMAC_HI_DCS_SHIFT); /* routes to channel 0 */
 	writel(data | GMAC_HI_REG_AE, ioaddr + high);
 	data = (addr[3] << 24) | (addr[2] << 16) | (addr[1] << 8) | addr[0];
 	writel(data, ioaddr + low);
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h b/drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h
index 56e485f..612720a 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h
@@ -137,13 +137,14 @@
 #define DMA_CONTROL_FTF		0x00100000	/* Flush transmit FIFO */
 
 void dwmac_enable_dma_transmission(void __iomem *ioaddr);
-void dwmac_enable_dma_irq(void __iomem *ioaddr);
-void dwmac_disable_dma_irq(void __iomem *ioaddr);
-void dwmac_dma_start_tx(void __iomem *ioaddr);
-void dwmac_dma_stop_tx(void __iomem *ioaddr);
-void dwmac_dma_start_rx(void __iomem *ioaddr);
-void dwmac_dma_stop_rx(void __iomem *ioaddr);
-int dwmac_dma_interrupt(void __iomem *ioaddr, struct stmmac_extra_stats *x);
+void dwmac_enable_dma_irq(void __iomem *ioaddr, u32 chan);
+void dwmac_disable_dma_irq(void __iomem *ioaddr, u32 chan);
+void dwmac_dma_start_tx(void __iomem *ioaddr, u32 chan);
+void dwmac_dma_stop_tx(void __iomem *ioaddr, u32 chan);
+void dwmac_dma_start_rx(void __iomem *ioaddr, u32 chan);
+void dwmac_dma_stop_rx(void __iomem *ioaddr, u32 chan);
+int dwmac_dma_interrupt(void __iomem *ioaddr,
+			struct stmmac_extra_stats *x, u32 chan);
 int dwmac_dma_reset(void __iomem *ioaddr);
 
 #endif /* __DWMAC_DMA_H__ */
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c b/drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c
index e60bfca..38f9430 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c
@@ -47,38 +47,38 @@ void dwmac_enable_dma_transmission(void __iomem *ioaddr)
 	writel(1, ioaddr + DMA_XMT_POLL_DEMAND);
 }
 
-void dwmac_enable_dma_irq(void __iomem *ioaddr)
+void dwmac_enable_dma_irq(void __iomem *ioaddr, u32 chan)
 {
 	writel(DMA_INTR_DEFAULT_MASK, ioaddr + DMA_INTR_ENA);
 }
 
-void dwmac_disable_dma_irq(void __iomem *ioaddr)
+void dwmac_disable_dma_irq(void __iomem *ioaddr, u32 chan)
 {
 	writel(0, ioaddr + DMA_INTR_ENA);
 }
 
-void dwmac_dma_start_tx(void __iomem *ioaddr)
+void dwmac_dma_start_tx(void __iomem *ioaddr, u32 chan)
 {
 	u32 value = readl(ioaddr + DMA_CONTROL);
 	value |= DMA_CONTROL_ST;
 	writel(value, ioaddr + DMA_CONTROL);
 }
 
-void dwmac_dma_stop_tx(void __iomem *ioaddr)
+void dwmac_dma_stop_tx(void __iomem *ioaddr, u32 chan)
 {
 	u32 value = readl(ioaddr + DMA_CONTROL);
 	value &= ~DMA_CONTROL_ST;
 	writel(value, ioaddr + DMA_CONTROL);
 }
 
-void dwmac_dma_start_rx(void __iomem *ioaddr)
+void dwmac_dma_start_rx(void __iomem *ioaddr, u32 chan)
 {
 	u32 value = readl(ioaddr + DMA_CONTROL);
 	value |= DMA_CONTROL_SR;
 	writel(value, ioaddr + DMA_CONTROL);
 }
 
-void dwmac_dma_stop_rx(void __iomem *ioaddr)
+void dwmac_dma_stop_rx(void __iomem *ioaddr, u32 chan)
 {
 	u32 value = readl(ioaddr + DMA_CONTROL);
 	value &= ~DMA_CONTROL_SR;
@@ -156,7 +156,7 @@ static void show_rx_process_state(unsigned int status)
 #endif
 
 int dwmac_dma_interrupt(void __iomem *ioaddr,
-			struct stmmac_extra_stats *x)
+			struct stmmac_extra_stats *x, u32 chan)
 {
 	int ret = 0;
 	/* read the status register (CSR5) */
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
index a010fce..b7a587c 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
@@ -794,8 +794,10 @@ static int stmmac_set_coalesce(struct net_device *dev,
 	priv->tx_coal_frames = ec->tx_max_coalesced_frames;
 	priv->tx_coal_timer = ec->tx_coalesce_usecs;
 	priv->rx_riwt = rx_riwt;
-	priv->hw->dma->rx_watchdog(priv->ioaddr, priv->rx_riwt);
 
+	priv->hw->dma->rx_watchdog(priv->ioaddr,
+				   priv->dma_cap.number_rx_channel,
+				   priv->rx_riwt);
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index a6f0b49..dfa1b62 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1356,31 +1356,230 @@ static void stmmac_mac_enable_rx_queues(struct stmmac_priv *priv)
 }
 
 /**
+ *  stmmac_calc_per_queue_fifo_sz - Calculate fifo size
+ *  @fifo_size: Numeric fifo size
+ *  @queue_count: Number of queues
+ *  Description: It is used for converting numeric fifo sz to one usable
+ */
+static int stmmac_calc_per_queue_fifo_sz(int fifo_size, int queue_count)
+{
+	int per_queue_fifo = 0;
+
+	per_queue_fifo = fifo_size / queue_count;
+
+	if (per_queue_fifo >= FIFO_SIZE_KB(32))
+		per_queue_fifo = FIFO_32k;
+	else if (per_queue_fifo >= FIFO_SIZE_KB(16))
+		per_queue_fifo = FIFO_16k;
+	else if (per_queue_fifo >= FIFO_SIZE_KB(8))
+		per_queue_fifo = FIFO_8k;
+	else if (per_queue_fifo >= FIFO_SIZE_KB(4))
+		per_queue_fifo = FIFO_4k;
+	else if (per_queue_fifo >= FIFO_SIZE_KB(2))
+		per_queue_fifo = FIFO_2k;
+	else if (per_queue_fifo >= FIFO_SIZE_KB(1))
+		per_queue_fifo = FIFO_1k;
+	else if (per_queue_fifo >= FIFO_SIZE_B(512))
+		per_queue_fifo = FIFO_512;
+	else if (per_queue_fifo >= FIFO_SIZE_B(256))
+		per_queue_fifo = FIFO_256;
+
+	return per_queue_fifo;
+}
+
+/**
+ *  stmmac_get_rx_tx_fifo_sz - Get fifo sizes for RX and TX
+ *  @priv: driver private structure
+ *  @rxfifosz: rx fifo size result
+ *  @txfifosz: rx fifo size result
+ *  Description: This function will pick plat defined buffer sizes and
+ *  convert them
+ */
+static void stmmac_get_rx_tx_fifo_sz(struct stmmac_priv *priv, u32 *q_rxfifosz,
+				     u32 *q_txfifosz)
+{
+	u32 rx_queue_cnt = priv->dma_cap.number_rx_queues;
+	u32 tx_queue_cnt = priv->dma_cap.number_tx_queues;
+	u32 rxfifosz = 0;
+	u32 txfifosz = 0;
+
+	/* If RX fifo size specified in platform we should use it */
+	rxfifosz = (priv->plat->rx_fifo_size > 0) ? (priv->plat->rx_fifo_size)
+						  : (priv->dma_cap.rx_fifosz);
+
+	/* If TX fifo size specified in platform we should use it */
+	txfifosz = (priv->plat->tx_fifo_size > 0) ? (priv->plat->tx_fifo_size)
+						  : (priv->dma_cap.tx_fifosz);
+
+	netdev_dbg(priv->dev, "RX fifo size = %d, TX fifo size = %d\n",
+		   rxfifosz, txfifosz);
+
+	/* Calculate the fifo size per RX and TX queues */
+	*q_rxfifosz = stmmac_calc_per_queue_fifo_sz(rxfifosz, rx_queue_cnt);
+
+	*q_txfifosz = stmmac_calc_per_queue_fifo_sz(txfifosz, tx_queue_cnt);
+}
+
+/**
+ *  stmmac_set_dma_operation_mode - Set HW DMA operation mode
+ *  @priv: driver private structure
+ *  @txmode: TX operating mode
+ *  @rxmode: RX operating mode
+ *  @chan: channel index
+ *  Description: it is used for configuring of the DMA operation mode in
+ *  runtime in order to program the tx/rx DMA thresholds or Store-And-Forward
+ *  mode.
+ */
+static void stmmac_set_dma_operation_mode(struct stmmac_priv *priv, u32 txmode,
+					  u32 rxmode, u32 chan)
+{
+	u32 q_rxfifosz = 0;
+	u32 q_txfifosz = 0;
+
+	stmmac_get_rx_tx_fifo_sz(priv, &q_rxfifosz, &q_txfifosz);
+
+	if (priv->synopsys_id >= DWMAC_CORE_4_00) {
+		priv->hw->dma->dma_rx_mode(priv->ioaddr, rxmode, q_rxfifosz,
+					   chan);
+		priv->hw->dma->dma_tx_mode(priv->ioaddr, txmode, q_txfifosz,
+					   chan);
+	} else
+		priv->hw->dma->dma_mode(priv->ioaddr, q_txfifosz, q_rxfifosz,
+					txmode, rxmode);
+}
+
+/**
  *  stmmac_dma_operation_mode - HW DMA operation mode
  *  @priv: driver private structure
- *  Description: it is used for configuring the DMA operation mode register in
- *  order to program the tx/rx DMA thresholds or Store-And-Forward mode.
+ *  Description: it is used for initial configuration of the DMA operation mode
+ *  register in order to program the tx/rx DMA thresholds or Store-And-Forward
+ *  mode.
  */
 static void stmmac_dma_operation_mode(struct stmmac_priv *priv)
 {
-	int rxfifosz = priv->plat->rx_fifo_size;
-
-	if (priv->plat->force_thresh_dma_mode)
-		priv->hw->dma->dma_mode(priv->ioaddr, tc, tc, rxfifosz);
-	else if (priv->plat->force_sf_dma_mode || priv->plat->tx_coe) {
-		/*
-		 * In case of GMAC, SF mode can be enabled
-		 * to perform the TX COE in HW. This depends on:
-		 * 1) TX COE if actually supported
-		 * 2) There is no bugged Jumbo frame support
-		 *    that needs to not insert csum in the TDES.
-		 */
-		priv->hw->dma->dma_mode(priv->ioaddr, SF_DMA_MODE, SF_DMA_MODE,
-					rxfifosz);
+	u32 rx_channels_count = priv->dma_cap.number_rx_channel;
+	u32 tx_channels_count = priv->dma_cap.number_tx_channel;
+	u32 q_rxfifosz = 0;
+	u32 q_txfifosz = 0;
+	u32 txmode = 0;
+	u32 rxmode = 0;
+	u32 chan = 0;
+
+	if (priv->plat->force_thresh_dma_mode) {
+		txmode = tc;
+		rxmode = tc;
+	} else if (priv->plat->force_sf_dma_mode || priv->plat->tx_coe) {
+		txmode = SF_DMA_MODE;
+		rxmode = SF_DMA_MODE;
 		priv->xstats.threshold = SF_DMA_MODE;
+	} else {
+		txmode = tc;
+		rxmode = SF_DMA_MODE;
+	}
+
+	stmmac_get_rx_tx_fifo_sz(priv, &q_rxfifosz, &q_txfifosz);
+
+	if (priv->synopsys_id >= DWMAC_CORE_4_00) {
+		for (chan = 0; chan < rx_channels_count; chan++)
+			priv->hw->dma->dma_rx_mode(priv->ioaddr, rxmode,
+						   q_rxfifosz, chan);
+
+		for (chan = 0; chan < tx_channels_count; chan++)
+			priv->hw->dma->dma_tx_mode(priv->ioaddr, txmode,
+						   q_txfifosz, chan);
 	} else
-		priv->hw->dma->dma_mode(priv->ioaddr, tc, SF_DMA_MODE,
-					rxfifosz);
+		priv->hw->dma->dma_mode(priv->ioaddr, q_txfifosz, q_rxfifosz,
+					txmode, rxmode);
+}
+
+/**
+ * stmmac_start_rx_dma - start RX DMA channel
+ * @priv: driver private structure
+ * @chan: RX channel index
+ * Description:
+ * This starts a RX DMA channel
+ */
+static void stmmac_start_rx_dma(struct stmmac_priv *priv, u32 chan)
+{
+	netdev_dbg(priv->dev, "DMA RX processes started in channel %d\n", chan);
+	priv->hw->dma->start_rx(priv->ioaddr, chan);
+}
+
+/**
+ * stmmac_start_tx_dma - start TX DMA channel
+ * @priv: driver private structure
+ * @chan: TX channel index
+ * Description:
+ * This starts a TX DMA channel
+ */
+static void stmmac_start_tx_dma(struct stmmac_priv *priv, u32 chan)
+{
+	netdev_dbg(priv->dev, "DMA TX processes started in channel %d\n", chan);
+	priv->hw->dma->start_tx(priv->ioaddr, chan);
+}
+
+/**
+ * stmmac_start_all_dma - start all RX and TX DMA channels
+ * @priv: driver private structure
+ * Description:
+ * This starts all the RX and TX DMA channels
+ */
+static void stmmac_start_all_dma(struct stmmac_priv *priv)
+{
+	u32 rx_channels_count = priv->dma_cap.number_rx_channel;
+	u32 tx_channels_count = priv->dma_cap.number_tx_channel;
+	u32 chan = 0;
+
+	for (chan = 0; chan < rx_channels_count; chan++)
+		stmmac_start_rx_dma(priv, chan);
+
+	for (chan = 0; chan < tx_channels_count; chan++)
+		stmmac_start_tx_dma(priv, chan);
+}
+
+/**
+ * stmmac_stop_rx_dma - stop RX DMA channel
+ * @priv: driver private structure
+ * @chan: RX channel index
+ * Description:
+ * This stops a RX DMA channel
+ */
+static void stmmac_stop_rx_dma(struct stmmac_priv *priv, u32 chan)
+{
+	netdev_dbg(priv->dev, "DMA RX processes stopped in channel %d\n", chan);
+	priv->hw->dma->stop_rx(priv->ioaddr, chan);
+}
+
+/**
+ * stmmac_stop_tx_dma - stop TX DMA channel
+ * @priv: driver private structure
+ * @chan: TX channel index
+ * Description:
+ * This stops a TX DMA channel
+ */
+static void stmmac_stop_tx_dma(struct stmmac_priv *priv, u32 chan)
+{
+	netdev_dbg(priv->dev, "DMA TX processes stopped in channel %d\n", chan);
+	priv->hw->dma->stop_tx(priv->ioaddr, chan);
+}
+
+/**
+ * stmmac_stop_all_dma - stop all RX and TX DMA channels
+ * @priv: driver private structure
+ * Description:
+ * This stops the RX and TX DMA channels
+ */
+static void stmmac_stop_all_dma(struct stmmac_priv *priv)
+{
+	u32 rx_channels_count = priv->dma_cap.number_rx_channel;
+	u32 tx_channels_count = priv->dma_cap.number_tx_channel;
+	u32 chan = 0;
+
+	for (chan = 0; chan < rx_channels_count; chan++)
+		stmmac_stop_rx_dma(priv, chan);
+
+	for (chan = 0; chan < tx_channels_count; chan++)
+		stmmac_stop_tx_dma(priv, chan);
 }
 
 /**
@@ -1477,28 +1676,32 @@ static void stmmac_tx_clean(struct stmmac_priv *priv)
 	netif_tx_unlock(priv->dev);
 }
 
-static inline void stmmac_enable_dma_irq(struct stmmac_priv *priv)
+static inline void stmmac_enable_dma_irq(struct stmmac_priv *priv, u32 chan)
 {
-	priv->hw->dma->enable_dma_irq(priv->ioaddr);
+	priv->hw->dma->enable_dma_irq(priv->ioaddr, chan);
 }
 
-static inline void stmmac_disable_dma_irq(struct stmmac_priv *priv)
+static inline void stmmac_disable_dma_irq(struct stmmac_priv *priv, u32 chan)
 {
-	priv->hw->dma->disable_dma_irq(priv->ioaddr);
+	priv->hw->dma->disable_dma_irq(priv->ioaddr, chan);
 }
 
 /**
  * stmmac_tx_err - to manage the tx error
  * @priv: driver private structure
+ * @queue: queue index
  * Description: it cleans the descriptors and restarts the transmission
  * in case of transmission errors.
  */
-static void stmmac_tx_err(struct stmmac_priv *priv)
+static void stmmac_tx_err(struct stmmac_priv *priv, u32 queue)
 {
 	int i;
+	/* chan <-> queue mapping assures this */
+	u32 chan = queue;
 	netif_stop_queue(priv->dev);
 
-	priv->hw->dma->stop_tx(priv->ioaddr);
+	stmmac_stop_tx_dma(priv, chan);
+
 	dma_free_tx_skbufs(priv);
 	for (i = 0; i < DMA_TX_SIZE; i++)
 		if (priv->extend_desc)
@@ -1512,7 +1715,7 @@ static void stmmac_tx_err(struct stmmac_priv *priv)
 	priv->dirty_tx = 0;
 	priv->cur_tx = 0;
 	netdev_reset_queue(priv->dev);
-	priv->hw->dma->start_tx(priv->ioaddr);
+	stmmac_start_tx_dma(priv, chan);
 
 	priv->dev->stats.tx_errors++;
 	netif_wake_queue(priv->dev);
@@ -1563,31 +1766,40 @@ static void stmmac_mtl_configuration(struct stmmac_priv *priv)
  */
 static void stmmac_dma_interrupt(struct stmmac_priv *priv)
 {
-	int status;
-	int rxfifosz = priv->plat->rx_fifo_size;
-
-	status = priv->hw->dma->dma_interrupt(priv->ioaddr, &priv->xstats);
-	if (likely((status & handle_rx)) || (status & handle_tx)) {
-		if (likely(napi_schedule_prep(&priv->napi))) {
-			stmmac_disable_dma_irq(priv);
-			__napi_schedule(&priv->napi);
+	u32 tx_channels_count = priv->dma_cap.number_tx_channel;
+	u32 status = 0;
+	u32 chan = 0;
+
+	for (chan = 0; chan < tx_channels_count; chan++) {
+		status = priv->hw->dma->dma_interrupt(priv->ioaddr,
+						      &priv->xstats, chan);
+		if (likely((status & handle_rx)) || (status & handle_tx)) {
+			if (likely(napi_schedule_prep(&priv->napi))) {
+				stmmac_disable_dma_irq(priv, chan);
+				__napi_schedule(&priv->napi);
+			}
 		}
-	}
-	if (unlikely(status & tx_hard_error_bump_tc)) {
-		/* Try to bump up the dma threshold on this failure */
-		if (unlikely(priv->xstats.threshold != SF_DMA_MODE) &&
-		    (tc <= 256)) {
-			tc += 64;
-			if (priv->plat->force_thresh_dma_mode)
-				priv->hw->dma->dma_mode(priv->ioaddr, tc, tc,
-							rxfifosz);
-			else
-				priv->hw->dma->dma_mode(priv->ioaddr, tc,
-							SF_DMA_MODE, rxfifosz);
-			priv->xstats.threshold = tc;
+		if (unlikely(status & tx_hard_error_bump_tc)) {
+			/* Try to bump up the dma threshold on this failure */
+			if (unlikely(priv->xstats.threshold != SF_DMA_MODE) &&
+			    (tc <= 256)) {
+				tc += 64;
+				if (priv->plat->force_thresh_dma_mode)
+					stmmac_set_dma_operation_mode(priv,
+								      tc,
+								      tc,
+								      chan);
+				else
+					stmmac_set_dma_operation_mode(priv,
+								      tc,
+								      SF_DMA_MODE,
+								      chan);
+				priv->xstats.threshold = tc;
+			}
+		} else if (unlikely(status == tx_hard_error)) {
+			stmmac_tx_err(priv, chan);
 		}
-	} else if (unlikely(status == tx_hard_error))
-		stmmac_tx_err(priv);
+	}
 }
 
 /**
@@ -1694,6 +1906,10 @@ static void stmmac_check_ether_addr(struct stmmac_priv *priv)
  */
 static int stmmac_init_dma_engine(struct stmmac_priv *priv)
 {
+	u32 dummy_dma_rx_phy, dummy_dma_tx_phy = 0;
+	u32 rx_channels_count = priv->dma_cap.number_rx_channel;
+	u32 tx_channels_count = priv->dma_cap.number_tx_channel;
+	u32 chan = 0;
 	int atds = 0;
 	int ret = 0;
 
@@ -1711,19 +1927,44 @@ static int stmmac_init_dma_engine(struct stmmac_priv *priv)
 		return ret;
 	}
 
-	priv->hw->dma->init(priv->ioaddr, priv->plat->dma_cfg,
-			    priv->dma_tx_phy, priv->dma_rx_phy, atds);
-
 	if (priv->synopsys_id >= DWMAC_CORE_4_00) {
-		priv->rx_tail_addr = priv->dma_rx_phy +
-			    (DMA_RX_SIZE * sizeof(struct dma_desc));
-		priv->hw->dma->set_rx_tail_ptr(priv->ioaddr, priv->rx_tail_addr,
-					       STMMAC_CHAN0);
+		/* DMA Configuration */
+		priv->hw->dma->init(priv->ioaddr, priv->plat->dma_cfg,
+				    dummy_dma_tx_phy, dummy_dma_rx_phy, atds);
+
+		/* DMA RX Channel Configuration */
+		for (chan = 0; chan < rx_channels_count; chan++) {
+			priv->hw->dma->init_rx_chan(priv->ioaddr,
+						    priv->plat->dma_cfg,
+						    priv->dma_rx_phy, chan);
+
+			priv->rx_tail_addr = priv->dma_rx_phy +
+				    (DMA_RX_SIZE * sizeof(struct dma_desc));
+			priv->hw->dma->set_rx_tail_ptr(priv->ioaddr,
+						       priv->rx_tail_addr,
+						       chan);
+		}
 
-		priv->tx_tail_addr = priv->dma_tx_phy +
-			    (DMA_TX_SIZE * sizeof(struct dma_desc));
-		priv->hw->dma->set_tx_tail_ptr(priv->ioaddr, priv->tx_tail_addr,
-					       STMMAC_CHAN0);
+		/* DMA TX Channel Configuration */
+		for (chan = 0; chan < tx_channels_count; chan++) {
+			priv->hw->dma->init_chan(priv->ioaddr,
+							priv->plat->dma_cfg,
+							chan);
+
+			priv->hw->dma->init_tx_chan(priv->ioaddr,
+						    priv->plat->dma_cfg,
+						    priv->dma_tx_phy, chan);
+
+			priv->tx_tail_addr = priv->dma_tx_phy +
+				    (DMA_TX_SIZE * sizeof(struct dma_desc));
+			priv->hw->dma->set_tx_tail_ptr(priv->ioaddr,
+						       priv->tx_tail_addr,
+						       chan);
+		}
+
+	} else {
+		priv->hw->dma->init(priv->ioaddr, priv->plat->dma_cfg,
+				    priv->dma_tx_phy, priv->dma_rx_phy, atds);
 	}
 
 	if (priv->plat->axi && priv->hw->dma->axi)
@@ -1764,6 +2005,27 @@ static void stmmac_init_tx_coalesce(struct stmmac_priv *priv)
 	add_timer(&priv->txtimer);
 }
 
+static void stmmac_set_rings_length(struct stmmac_priv *priv)
+{
+	u32 rx_channels_count = priv->dma_cap.number_rx_channel;
+	u32 tx_channels_count = priv->dma_cap.number_tx_channel;
+	u32 chan = 0;
+
+	/*  set TX ring length */
+	if (priv->hw->dma->set_tx_ring_len) {
+		for (chan = 0; chan < tx_channels_count; chan++)
+			priv->hw->dma->set_tx_ring_len(priv->ioaddr,
+						       (DMA_TX_SIZE - 1), chan);
+	}
+
+	/*  set RX ring length */
+	if (priv->hw->dma->set_rx_ring_len) {
+		for (chan = 0; chan < rx_channels_count; chan++)
+			priv->hw->dma->set_rx_ring_len(priv->ioaddr,
+						       (DMA_RX_SIZE - 1), chan);
+	}
+}
+
 /**
  * stmmac_hw_setup - setup mac in a usable state.
  *  @dev : pointer to the device structure.
@@ -1779,6 +2041,8 @@ static void stmmac_init_tx_coalesce(struct stmmac_priv *priv)
 static int stmmac_hw_setup(struct net_device *dev, bool init_ptp)
 {
 	struct stmmac_priv *priv = netdev_priv(dev);
+	u32 tx_channels_cnt = priv->dma_cap.number_tx_channel;
+	u32 chan = 0;
 	int ret;
 
 	/* DMA initialization and SW reset */
@@ -1848,36 +2112,34 @@ static int stmmac_hw_setup(struct net_device *dev, bool init_ptp)
 			    __func__);
 #endif
 	/* Start the ball rolling... */
-	netdev_dbg(priv->dev, "DMA RX/TX processes started...\n");
-	priv->hw->dma->start_tx(priv->ioaddr);
-	priv->hw->dma->start_rx(priv->ioaddr);
+	stmmac_start_all_dma(priv);
 
 	/* Dump DMA/MAC registers */
 	if (netif_msg_hw(priv)) {
 		priv->hw->mac->dump_regs(priv->hw);
-		priv->hw->dma->dump_regs(priv->ioaddr);
+		priv->hw->dma->dump_regs(priv->ioaddr,
+					 priv->dma_cap.number_rx_channel);
 	}
 	priv->tx_lpi_timer = STMMAC_DEFAULT_TWT_LS;
 
 	if ((priv->use_riwt) && (priv->hw->dma->rx_watchdog)) {
 		priv->rx_riwt = MAX_DMA_RIWT;
-		priv->hw->dma->rx_watchdog(priv->ioaddr, MAX_DMA_RIWT);
+		priv->hw->dma->rx_watchdog(priv->ioaddr,
+					   priv->dma_cap.number_rx_channel,
+					   MAX_DMA_RIWT);
 	}
 
 	if (priv->hw->pcs && priv->hw->mac->pcs_ctrl_ane)
 		priv->hw->mac->pcs_ctrl_ane(priv->hw, 1, priv->hw->ps, 0);
 
-	/*  set TX ring length */
-	if (priv->hw->dma->set_tx_ring_len)
-		priv->hw->dma->set_tx_ring_len(priv->ioaddr,
-					       (DMA_TX_SIZE - 1));
-	/*  set RX ring length */
-	if (priv->hw->dma->set_rx_ring_len)
-		priv->hw->dma->set_rx_ring_len(priv->ioaddr,
-					       (DMA_RX_SIZE - 1));
+	/*  set TX and rings length */
+	stmmac_set_rings_length(priv);
+
 	/* Enable TSO */
-	if (priv->tso)
-		priv->hw->dma->enable_tso(priv->ioaddr, 1, STMMAC_CHAN0);
+	if (priv->tso) {
+		for (chan = 0; chan < tx_channels_cnt; chan++)
+			priv->hw->dma->enable_tso(priv->ioaddr, 1, chan);
+	}
 
 	return 0;
 }
@@ -2029,8 +2291,7 @@ static int stmmac_release(struct net_device *dev)
 		free_irq(priv->lpi_irq, dev);
 
 	/* Stop TX/RX DMA and clear the descriptors */
-	priv->hw->dma->stop_tx(priv->ioaddr);
-	priv->hw->dma->stop_rx(priv->ioaddr);
+	stmmac_stop_all_dma(priv);
 
 	/* Release and free the Rx/Tx resources */
 	free_dma_desc_resources(priv);
@@ -2789,6 +3050,7 @@ static int stmmac_poll(struct napi_struct *napi, int budget)
 {
 	struct stmmac_priv *priv = container_of(napi, struct stmmac_priv, napi);
 	int work_done = 0;
+	u32 chan = 0; /* FIXME */
 
 	priv->xstats.napi_poll++;
 	stmmac_tx_clean(priv);
@@ -2796,7 +3058,7 @@ static int stmmac_poll(struct napi_struct *napi, int budget)
 	work_done = stmmac_rx(priv, budget);
 	if (work_done < budget) {
 		napi_complete_done(napi, work_done);
-		stmmac_enable_dma_irq(priv);
+		stmmac_enable_dma_irq(priv, chan);
 	}
 	return work_done;
 }
@@ -2812,9 +3074,10 @@ static int stmmac_poll(struct napi_struct *napi, int budget)
 static void stmmac_tx_timeout(struct net_device *dev)
 {
 	struct stmmac_priv *priv = netdev_priv(dev);
+	u32 queue = 0;
 
 	/* Clear Tx resources and restart transmitting again */
-	stmmac_tx_err(priv);
+	stmmac_tx_err(priv, queue);
 }
 
 /**
@@ -2923,6 +3186,13 @@ static irqreturn_t stmmac_interrupt(int irq, void *dev_id)
 {
 	struct net_device *dev = (struct net_device *)dev_id;
 	struct stmmac_priv *priv = netdev_priv(dev);
+	u32 rx_channels_count = priv->dma_cap.number_rx_channel;
+	u32 tx_channels_count = priv->dma_cap.number_tx_channel;
+	u32 channels_count = 0;
+	u32 chan = 0;
+
+	channels_count = (rx_channels_count > tx_channels_count) ?
+			 rx_channels_count : tx_channels_count;
 
 	if (priv->irq_wake)
 		pm_wakeup_event(priv->device, 0);
@@ -2936,19 +3206,25 @@ static irqreturn_t stmmac_interrupt(int irq, void *dev_id)
 	if ((priv->plat->has_gmac) || (priv->plat->has_gmac4)) {
 		int status = priv->hw->mac->host_irq_status(priv->hw,
 							    &priv->xstats);
-		if (priv->synopsys_id >= DWMAC_CORE_4_00)
-			status |= priv->hw->mac->host_mtl_irq_status(priv->hw,
-								STMMAC_CHAN0);
 		if (unlikely(status)) {
 			/* For LPI we need to save the tx status */
 			if (status & CORE_IRQ_TX_PATH_IN_LPI_MODE)
 				priv->tx_path_in_lpi_mode = true;
 			if (status & CORE_IRQ_TX_PATH_EXIT_LPI_MODE)
 				priv->tx_path_in_lpi_mode = false;
-			if (status & CORE_IRQ_MTL_RX_OVERFLOW && priv->hw->dma->set_rx_tail_ptr)
-				priv->hw->dma->set_rx_tail_ptr(priv->ioaddr,
+		}
+
+		for (chan = 0; chan < channels_count; chan++) {
+			status = priv->hw->mac->host_mtl_irq_status(priv->hw,
+								    chan);
+
+			if (unlikely(status)) {
+				if (status & CORE_IRQ_MTL_RX_OVERFLOW &&
+				    priv->hw->dma->set_rx_tail_ptr)
+					priv->hw->dma->set_rx_tail_ptr(priv->ioaddr,
 							priv->rx_tail_addr,
-							STMMAC_CHAN0);
+							chan);
+			}
 		}
 
 		/* PCS link status */
@@ -3500,8 +3776,7 @@ int stmmac_dvr_remove(struct device *dev)
 
 	netdev_info(priv->dev, "%s: removing driver", __func__);
 
-	priv->hw->dma->stop_rx(priv->ioaddr);
-	priv->hw->dma->stop_tx(priv->ioaddr);
+	stmmac_stop_all_dma(priv);
 
 	stmmac_set_mac(priv->ioaddr, false);
 	netif_carrier_off(ndev);
@@ -3547,8 +3822,7 @@ int stmmac_suspend(struct device *dev)
 	napi_disable(&priv->napi);
 
 	/* Stop TX/RX DMA */
-	priv->hw->dma->stop_tx(priv->ioaddr);
-	priv->hw->dma->stop_rx(priv->ioaddr);
+	stmmac_stop_all_dma(priv);
 
 	/* Enable Power down mode by programming the PMT regs */
 	if (device_may_wakeup(priv->device)) {
-- 
2.9.3
