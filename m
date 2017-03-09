From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: [PATCH v3 net-next 9/9] net: stmicro: configuration of CBS in case of a TX AVB queue
Date: Thu,  9 Mar 2017 11:03:17 +0000
Message-ID: <b7d48575ca80c48a6b56e4d4a85d4215f11d2276.1489055407.git.jpinto@synopsys.com>
References: <cover.1489055407.git.jpinto@synopsys.com>
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        niklas.cassel@axis.com, netdev@vger.kernel.org,
        Joao Pinto <Joao.Pinto@synopsys.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay4.synopsys.com ([198.182.47.9]:56844 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932098AbdCILMC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Mar 2017 06:12:02 -0500
In-Reply-To: <cover.1489055407.git.jpinto@synopsys.com>
In-Reply-To: <cover.1489055407.git.jpinto@synopsys.com>
References: <cover.1489055407.git.jpinto@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the configuration of the AVB Credit-Based Shaper.

Signed-off-by: Joao Pinto <jpinto@synopsys.com>
---
changes v1->v3:
- Added in v3

 Documentation/devicetree/bindings/net/stmmac.txt   | 22 +++++++++--
 drivers/net/ethernet/stmicro/stmmac/common.h       |  4 ++
 drivers/net/ethernet/stmicro/stmmac/dwmac4.h       | 33 ++++++++++++++++
 drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c  | 46 +++++++++++++++++++++-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  | 29 ++++++++++++++
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  | 29 ++++++++++++--
 include/linux/stmmac.h                             | 12 ++++--
 7 files changed, 164 insertions(+), 11 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/stmmac.txt b/Documentation/devicetree/bindings/net/stmmac.txt
index 4107e67..9b4d5dd 100644
--- a/Documentation/devicetree/bindings/net/stmmac.txt
+++ b/Documentation/devicetree/bindings/net/stmmac.txt
@@ -92,8 +92,15 @@ Optional properties:
 		- snps,tx-sched-dwrr: Deficit Weighted Round Robin
 		- snps,tx-sched-sp: Strict priority
 	- For each TX queue
-		- snps,weight: TX queue weight (if using a weighted algorithm)
-
+		- snps,weight: TX queue weight (if using a DCB weight algorithm)
+		- Choose one of these modes:
+			- snps,dcb-algorithm: TX queue will be working in DCB
+			- snps,avb-algorithm: TX queue will be working in AVB
+		- Configure Credit Base Shaper (if AVB Mode selected):
+			- snps,send_slope: enable Low Power Interface
+			- snps,idle_slope: unlock on WoL
+			- snps,high_credit: max write outstanding req. limit
+			- snps,low_credit: max read outstanding req. limit
 Examples:
 
 	stmmac_axi_setup: stmmac-axi-config {
@@ -112,10 +119,19 @@ Examples:
 	};
 
 	mtl_tx_setup: tx-queues-config {
-		snps,tx-queues-to-use = <1>;
+		snps,tx-queues-to-use = <2>;
 		snps,tx-sched-wrr;
 		queue0 {
 			snps,weight = <0x10>;
+			snps,dcb-algorithm;
+		};
+
+		queue1 {
+			snps,avb-algorithm;
+			snps,send_slope = <0x1000>;
+			snps,idle_slope = <0x1000>;
+			snps,high_credit = <0x3E800>;
+			snps,low_credit = <0xFFC18000>;
 		};
 	};
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index d7bb498..62449b0 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -464,6 +464,10 @@ struct stmmac_ops {
 					u32 weight, u32 queue);
 	/* RX MTL queue to RX dma mapping */
 	void (*map_mtl_to_dma)(struct mac_device_info *hw, u32 queue, u32 chan);
+	/* Configure AV Algorithm */
+	void (*config_cbs)(struct mac_device_info *hw, u32 send_slope,
+			   u32 idle_slope, u32 high_credit, u32 low_credit,
+			   u32 queue);
 	/* Dump MAC registers */
 	void (*dump_regs)(struct mac_device_info *hw, u32 *reg_space);
 	/* Handle extra events on specific interrupts hw dependent */
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4.h b/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
index 5ca4d64..cf0e602 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
@@ -218,6 +218,15 @@ enum power_event {
 #define MTL_OP_MODE_RTC_96		(2 << MTL_OP_MODE_RTC_SHIFT)
 #define MTL_OP_MODE_RTC_128		(3 << MTL_OP_MODE_RTC_SHIFT)
 
+/* MTL ETS Control register */
+#define MTL_ETS_CTRL_BASE_ADDR		0x00000d10
+#define MTL_ETS_CTRL_BASE_OFFSET	0x40
+#define MTL_ETSX_CTRL_BASE_ADDR(x)	(MTL_ETS_CTRL_BASE_ADDR + \
+					((x) * MTL_ETS_CTRL_BASE_OFFSET))
+
+#define MTL_ETS_CTRL_CC			BIT(3)
+#define MTL_ETS_CTRL_AVALG		BIT(2)
+
 /* MTL Queue Quantum Weight */
 #define MTL_TXQ_WEIGHT_BASE_ADDR	0x00000d18
 #define MTL_TXQ_WEIGHT_BASE_OFFSET	0x40
@@ -225,6 +234,30 @@ enum power_event {
 					((x) * MTL_TXQ_WEIGHT_BASE_OFFSET))
 #define MTL_TXQ_WEIGHT_ISCQW_MASK	GENMASK(20, 0)
 
+/* MTL sendSlopeCredit register */
+#define MTL_SEND_SLP_CRED_BASE_ADDR	0x00000d1c
+#define MTL_SEND_SLP_CRED_OFFSET	0x40
+#define MTL_SEND_SLP_CREDX_BASE_ADDR(x)	(MTL_SEND_SLP_CRED_BASE_ADDR + \
+					((x) * MTL_SEND_SLP_CRED_OFFSET))
+
+#define MTL_SEND_SLP_CRED_SSC_MASK	GENMASK(13, 0)
+
+/* MTL hiCredit register */
+#define MTL_HIGH_CRED_BASE_ADDR		0x00000d20
+#define MTL_HIGH_CRED_OFFSET		0x40
+#define MTL_HIGH_CREDX_BASE_ADDR(x)	(MTL_HIGH_CRED_BASE_ADDR + \
+					((x) * MTL_HIGH_CRED_OFFSET))
+
+#define MTL_HIGH_CRED_HC_MASK		GENMASK(28, 0)
+
+/* MTL loCredit register */
+#define MTL_LOW_CRED_BASE_ADDR		0x00000d24
+#define MTL_LOW_CRED_OFFSET		0x40
+#define MTL_LOW_CREDX_BASE_ADDR(x)	(MTL_LOW_CRED_BASE_ADDR + \
+					((x) * MTL_LOW_CRED_OFFSET))
+
+#define MTL_HIGH_CRED_LC_MASK		GENMASK(28, 0)
+
 /*  MTL debug */
 #define MTL_DEBUG_TXSTSFSTS		BIT(5)
 #define MTL_DEBUG_TXFSTS		BIT(4)
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
index 7f0631c..992698d 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
@@ -66,9 +66,9 @@ static void dwmac4_rx_queue_enable(struct mac_device_info *hw,
 	u32 value = readl(ioaddr + GMAC_RXQ_CTRL0);
 
 	value &= GMAC_RX_QUEUE_CLEAR(queue);
-	if (mode == MTL_RX_AVB)
+	if (mode == MTL_QUEUE_AVB)
 		value |= GMAC_RX_AV_QUEUE_ENABLE(queue);
-	else if (mode == MTL_RX_DCB)
+	else if (mode == MTL_QUEUE_DCB)
 		value |= GMAC_RX_DCB_QUEUE_ENABLE(queue);
 
 	writel(value, ioaddr + GMAC_RXQ_CTRL0);
@@ -156,6 +156,47 @@ static void dwmac4_map_mtl_dma(struct mac_device_info *hw, u32 queue, u32 chan)
 		writel(value, ioaddr + MTL_RXQ_DMA_MAP1);
 }
 
+static void dwmac4_config_cbs(struct mac_device_info *hw,
+			      u32 send_slope, u32 idle_slope,
+			      u32 high_credit, u32 low_credit, u32 queue)
+{
+	void __iomem *ioaddr = hw->pcsr;
+	u32 value = 0;
+
+	pr_debug("Queue %d configured as AVB. Parameters:\n", queue);
+	pr_debug("\tsend_slope: 0x%08x\n", send_slope);
+	pr_debug("\tidle_slope: 0x%08x\n", idle_slope);
+	pr_debug("\thigh_credit: 0x%08x\n", high_credit);
+	pr_debug("\tlow_credit: 0x%08x\n", low_credit);
+
+	/* enable AV algorithm */
+	value = readl(ioaddr + MTL_ETSX_CTRL_BASE_ADDR(queue));
+	value |= MTL_ETS_CTRL_AVALG;
+	value |= MTL_ETS_CTRL_CC;
+	writel(value, ioaddr + MTL_ETSX_CTRL_BASE_ADDR(queue));
+
+	/* configure send slope */
+	value = readl(ioaddr + MTL_SEND_SLP_CREDX_BASE_ADDR(queue));
+	value &= ~MTL_SEND_SLP_CRED_SSC_MASK;
+	value |= send_slope & MTL_SEND_SLP_CRED_SSC_MASK;
+	writel(value, ioaddr + MTL_SEND_SLP_CREDX_BASE_ADDR(queue));
+
+	/* configure idle slope (same register as tx weight) */
+	dwmac4_set_mtl_tx_queue_weight(hw, idle_slope, queue);
+
+	/* configure high credit */
+	value = readl(ioaddr + MTL_HIGH_CREDX_BASE_ADDR(queue));
+	value &= ~MTL_HIGH_CRED_HC_MASK;
+	value |= high_credit & MTL_HIGH_CRED_HC_MASK;
+	writel(value, ioaddr + MTL_HIGH_CREDX_BASE_ADDR(queue));
+
+	/* configure high credit */
+	value = readl(ioaddr + MTL_LOW_CREDX_BASE_ADDR(queue));
+	value &= ~MTL_HIGH_CRED_LC_MASK;
+	value |= low_credit & MTL_HIGH_CRED_LC_MASK;
+	writel(value, ioaddr + MTL_LOW_CREDX_BASE_ADDR(queue));
+}
+
 static void dwmac4_dump_regs(struct mac_device_info *hw, u32 *reg_space)
 {
 	void __iomem *ioaddr = hw->pcsr;
@@ -558,6 +599,7 @@ static const struct stmmac_ops dwmac4_ops = {
 	.prog_mtl_tx_algorithms = dwmac4_prog_mtl_tx_algorithms,
 	.set_mtl_tx_queue_weight = dwmac4_set_mtl_tx_queue_weight,
 	.map_mtl_to_dma = dwmac4_map_mtl_dma,
+	.config_cbs = dwmac4_config_cbs,
 	.dump_regs = dwmac4_dump_regs,
 	.host_irq_status = dwmac4_irq_status,
 	.host_mtl_irq_status = dwmac4_irq_mtl_status,
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 09380a2..e3a2787 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1668,6 +1668,31 @@ static void stmmac_set_tx_queue_weight(struct stmmac_priv *priv)
 }
 
 /**
+ *  stmmac_configure_cbs - Configure CBS in TX queue
+ *  @priv: driver private structure
+ *  Description: It is used for configuring CBS in AVB TX queues
+ */
+static void stmmac_configure_cbs(struct stmmac_priv *priv)
+{
+	u32 tx_queues_count = priv->plat->tx_queues_to_use;
+	u32 mode_to_use = 0;
+	u32 queue = 0;
+
+	for (queue = 0; queue < tx_queues_count; queue++) {
+		mode_to_use = priv->plat->tx_queues_cfg[queue].mode_to_use;
+		if (mode_to_use == MTL_QUEUE_DCB)
+			continue;
+
+		priv->hw->mac->config_cbs(priv->hw,
+				priv->plat->tx_queues_cfg[queue].send_slope,
+				priv->plat->tx_queues_cfg[queue].idle_slope,
+				priv->plat->tx_queues_cfg[queue].high_credit,
+				priv->plat->tx_queues_cfg[queue].low_credit,
+				queue);
+	}
+}
+
+/**
  *  stmmac_rx_queue_dma_chan_map - Map RX queue to RX dma channel
  *  @priv: driver private structure
  *  Description: It is used for mapping RX queues to RX dma channels
@@ -1707,6 +1732,10 @@ static void stmmac_mtl_configuration(struct stmmac_priv *priv)
 		priv->hw->mac->prog_mtl_tx_algorithms(priv->hw,
 						priv->plat->tx_sched_algorithm);
 
+	/* Configure CBS in AVB TX queues */
+	if (tx_queues_count > 1 && priv->hw->mac->config_cbs)
+		stmmac_configure_cbs(priv);
+
 	/* Map RX MTL to DMA channels */
 	if (rx_queues_count > 1 && priv->hw->mac->map_mtl_to_dma)
 		stmmac_rx_queue_dma_chan_map(priv);
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index ff6af8d..fc339bf 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -171,11 +171,11 @@ static void stmmac_mtl_setup(struct platform_device *pdev,
 			break;
 
 		if (of_property_read_bool(q_node, "snps,dcb-algorithm"))
-			plat->rx_queues_cfg[queue].mode_to_use = MTL_RX_DCB;
+			plat->rx_queues_cfg[queue].mode_to_use = MTL_QUEUE_DCB;
 		else if (of_property_read_bool(q_node, "snps,avb-algorithm"))
-			plat->rx_queues_cfg[queue].mode_to_use = MTL_RX_AVB;
+			plat->rx_queues_cfg[queue].mode_to_use = MTL_QUEUE_AVB;
 		else
-			plat->rx_queues_cfg[queue].mode_to_use = MTL_RX_DCB;
+			plat->rx_queues_cfg[queue].mode_to_use = MTL_QUEUE_DCB;
 
 		if (of_property_read_u8(q_node, "snps,map-to-dma-channel",
 					&plat->rx_queues_cfg[queue].chan))
@@ -212,6 +212,29 @@ static void stmmac_mtl_setup(struct platform_device *pdev,
 					&plat->tx_queues_cfg[queue].weight))
 			plat->tx_queues_cfg[queue].weight = 0x10 + queue;
 
+		if (of_property_read_bool(q_node, "snps,dcb-algorithm")) {
+			plat->tx_queues_cfg[queue].mode_to_use = MTL_QUEUE_DCB;
+		} else if (of_property_read_bool(q_node,
+						 "snps,avb-algorithm")) {
+			plat->tx_queues_cfg[queue].mode_to_use = MTL_QUEUE_AVB;
+
+			/* Credit Base Shaper parameters used by AVB */
+			if (of_property_read_u32(q_node, "snps,send_slope",
+				&plat->tx_queues_cfg[queue].send_slope))
+				plat->tx_queues_cfg[queue].send_slope = 0x0;
+			if (of_property_read_u32(q_node, "snps,idle_slope",
+				&plat->tx_queues_cfg[queue].idle_slope))
+				plat->tx_queues_cfg[queue].idle_slope = 0x0;
+			if (of_property_read_u32(q_node, "snps,high_credit",
+				&plat->tx_queues_cfg[queue].high_credit))
+				plat->tx_queues_cfg[queue].high_credit = 0x0;
+			if (of_property_read_u32(q_node, "snps,low_credit",
+				&plat->tx_queues_cfg[queue].low_credit))
+				plat->tx_queues_cfg[queue].low_credit = 0x0;
+		} else {
+			plat->tx_queues_cfg[queue].mode_to_use = MTL_QUEUE_DCB;
+		}
+
 		queue++;
 	}
 
diff --git a/include/linux/stmmac.h b/include/linux/stmmac.h
index 266ff2a..be47b85 100644
--- a/include/linux/stmmac.h
+++ b/include/linux/stmmac.h
@@ -55,9 +55,9 @@
 #define MTL_RX_ALGORITHM_SP	0x4
 #define MTL_RX_ALGORITHM_WSP	0x5
 
-/* RX Queue Mode */
-#define MTL_RX_DCB		0x0
-#define MTL_RX_AVB		0x1
+/* RX/TX Queue Mode */
+#define MTL_QUEUE_DCB		0x0
+#define MTL_QUEUE_AVB		0x1
 
 /* The MDC clock could be set higher than the IEEE 802.3
  * specified frequency limit 0f 2.5 MHz, by programming a clock divider
@@ -131,6 +131,12 @@ struct stmmac_rxq_cfg {
 
 struct stmmac_txq_cfg {
 	u8 weight;
+	u8 mode_to_use;
+	/* Credit Base Shaper parameters */
+	u32 send_slope;
+	u32 idle_slope;
+	u32 high_credit;
+	u32 low_credit;
 };
 
 struct plat_stmmacenet_data {
-- 
2.9.3
