From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: [PATCH 1/3] net: stmicro: prepare dwmac4 core for mtl
Date: Tue, 14 Feb 2017 18:00:41 +0000
Message-ID: <c1c9c141e4e9277f716816b84464c984fbf76fdc.1487089769.git.jpinto@synopsys.com>
References: <cover.1487089769.git.jpinto@synopsys.com>
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org, Joao Pinto <Joao.Pinto@synopsys.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay4.synopsys.com ([198.182.47.9]:50292 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754880AbdBNSAv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2017 13:00:51 -0500
In-Reply-To: <cover.1487089769.git.jpinto@synopsys.com>
In-Reply-To: <cover.1487089769.git.jpinto@synopsys.com>
References: <cover.1487089769.git.jpinto@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the following features:

a) RX and TX scheduling algorithm configuration (can be configured in the
Device Tree)
b) TX VLAN tag priority configuration (can be configured in the Device Tree)
c) RX VLAN tag priority routing configuration (can be configured in the
Device Tree)
d) TX weight configuration (can be configured in the Device Tree)
e) RX queue to RX DMA channel mapping
f) RX queue enabling
g) MAC and individual queue related interrupt analysis
h) Flow Control configuration by queue

The number of RX and TX queues to use comes from the FEATURES register.

With this patch we get the core related operations ready for multiple
queue/channel.

Signed-off-by: Joao Pinto <jpinto@synopsys.com>
---
 Documentation/devicetree/bindings/net/stmmac.txt   |  11 ++
 drivers/net/ethernet/stmicro/stmmac/common.h       |  29 ++-
 .../net/ethernet/stmicro/stmmac/dwmac1000_core.c   |   6 +-
 .../net/ethernet/stmicro/stmmac/dwmac100_core.c    |   3 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac4.h       |  39 ++++-
 drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c  | 194 ++++++++++++++++++---
 .../net/ethernet/stmicro/stmmac/stmmac_ethtool.c   |  22 ++-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  | 152 ++++++++++++++--
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |  33 ++++
 include/linux/stmmac.h                             |   8 +
 10 files changed, 446 insertions(+), 51 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/stmmac.txt b/Documentation/devicetree/bindings/net/stmmac.txt
index d3bfc2b..9c5c135 100644
--- a/Documentation/devicetree/bindings/net/stmmac.txt
+++ b/Documentation/devicetree/bindings/net/stmmac.txt
@@ -60,6 +60,17 @@ Optional properties:
 		 and MAC2MAC connection.
 - snps,tso: this enables the TSO feature otherwise it will be managed by
 		 MAC HW capability register. Only for GMAC4 and newer.
+- Tx MTL algorithm configuration: below the list of the available Tx algorithms:
+	- snps,tx-sched-wrr: WRR algorithm
+	- snps,tx-sched-wfq: WFQ algorithm (when DCB feature is selected)
+	- snps,tx-sched-dwrr: DWRR algorithm (when DCB feature is selected)
+	- snps,tx-sched-prio: Strict priority algorithm
+- Rx MTL algorithm configuration: below the list of the available Rx algorithms:
+	- snps,rx-sched-sp: Strict priority algorithm
+	- snps,rx-sched-wsp: Weighted strict priority algorithm
+- snps,tx-queue-weight: this is a vector to configure the TX queue weights
+- snps,rx-queue-prio: this is a vector to configure the RX queue priorities
+- snps,tx-queue-prio: this is a vector to configure the TX queue priorities
 - AXI BUS Mode parameters: below the list of all the parameters to program the
 			   AXI register inside the DMA module:
 	- snps,lpi_en: enable Low Power Interface
diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index 144fe84..8b55747 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -350,6 +350,14 @@ struct dma_features {
 
 #define JUMBO_LEN		9000
 
+/* MTL algorithms identifiers */
+#define MTL_TX_ALGORITHM_WRR	0x0
+#define MTL_TX_ALGORITHM_WFQ	0x1
+#define MTL_TX_ALGORITHM_DWRR	0x2
+#define MTL_TX_ALGORITHM_PRIO	0x3
+#define MTL_RX_ALGORITHM_SP	0x4
+#define MTL_RX_ALGORITHM_WSP	0x5
+
 /* Descriptors helpers */
 struct stmmac_desc_ops {
 	/* DMA RX descriptor ring initialization */
@@ -455,16 +463,32 @@ struct stmmac_ops {
 	int (*rx_ipc)(struct mac_device_info *hw);
 	/* Enable RX Queues */
 	void (*rx_queue_enable)(struct mac_device_info *hw, u32 queue);
+	/* RX Queues Priority */
+	void (*rx_queue_prio)(struct mac_device_info *hw, u32 prio, u32 queue);
+	/* TX Queues Priority */
+	void (*tx_queue_prio)(struct mac_device_info *hw, u32 prio, u32 queue);
+	/* Program RX Algorithms */
+	void (*prog_mtl_rx_algorithms)(struct mac_device_info *hw, u32 rx_alg);
+	/* Program TX Algorithms */
+	void (*prog_mtl_tx_algorithms)(struct mac_device_info *hw, u32 tx_alg);
+	/* RX MTL queue to RX dma mapping */
+	void (*map_mtl_to_dma)(struct mac_device_info *hw, u32 queue, u32 chan);
+	/* Set MTL TX queues weight */
+	void (*set_mtl_tx_queue_weight)(struct mac_device_info *hw,
+					u32 weight, u32 queue);
 	/* Dump MAC registers */
 	void (*dump_regs)(struct mac_device_info *hw);
 	/* Handle extra events on specific interrupts hw dependent */
 	int (*host_irq_status)(struct mac_device_info *hw,
 			       struct stmmac_extra_stats *x);
+	/* Handle MTL interrupts */
+	int (*host_mtl_irq_status)(struct mac_device_info *hw, u32 chan);
 	/* Multicast filter setting */
 	void (*set_filter)(struct mac_device_info *hw, struct net_device *dev);
 	/* Flow control setting */
 	void (*flow_ctrl)(struct mac_device_info *hw, unsigned int duplex,
-			  unsigned int fc, unsigned int pause_time);
+			  unsigned int fc, unsigned int pause_time,
+			  u32 tx_queues_cnt);
 	/* Set power management mode (e.g. magic frame) */
 	void (*pmt)(struct mac_device_info *hw, unsigned long mode);
 	/* Set/Get Unicast MAC addresses */
@@ -477,7 +501,8 @@ struct stmmac_ops {
 	void (*reset_eee_mode)(struct mac_device_info *hw);
 	void (*set_eee_timer)(struct mac_device_info *hw, int ls, int tw);
 	void (*set_eee_pls)(struct mac_device_info *hw, int link);
-	void (*debug)(void __iomem *ioaddr, struct stmmac_extra_stats *x);
+	void (*debug)(void __iomem *ioaddr, struct stmmac_extra_stats *x,
+		      u32 queue);
 	/* PCS calls */
 	void (*pcs_ctrl_ane)(void __iomem *ioaddr, bool ane, bool srgmi_ral,
 			     bool loopback);
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
index 91c8926..327dfa5 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
@@ -220,7 +220,8 @@ static void dwmac1000_set_filter(struct mac_device_info *hw,
 
 
 static void dwmac1000_flow_ctrl(struct mac_device_info *hw, unsigned int duplex,
-				unsigned int fc, unsigned int pause_time)
+				unsigned int fc, unsigned int pause_time,
+				u32 tx_queues_cnt)
 {
 	void __iomem *ioaddr = hw->pcsr;
 	/* Set flow such that DZPQ in Mac Register 6 is 0,
@@ -416,7 +417,8 @@ static void dwmac1000_get_adv_lp(void __iomem *ioaddr, struct rgmii_adv *adv)
 	dwmac_get_adv_lp(ioaddr, GMAC_PCS_BASE, adv);
 }
 
-static void dwmac1000_debug(void __iomem *ioaddr, struct stmmac_extra_stats *x)
+static void dwmac1000_debug(void __iomem *ioaddr, struct stmmac_extra_stats *x,
+			    u32 queue)
 {
 	u32 value = readl(ioaddr + GMAC_DEBUG);
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac100_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac100_core.c
index 8ab5189..c6faa1e 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac100_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac100_core.c
@@ -141,7 +141,8 @@ static void dwmac100_set_filter(struct mac_device_info *hw,
 }
 
 static void dwmac100_flow_ctrl(struct mac_device_info *hw, unsigned int duplex,
-			       unsigned int fc, unsigned int pause_time)
+			       unsigned int fc, unsigned int pause_time,
+			       u32 tx_queues_cnt)
 {
 	void __iomem *ioaddr = hw->pcsr;
 	unsigned int flow = MAC_FLOW_CTRL_ENABLE;
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4.h b/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
index db45134..414070c 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
@@ -22,7 +22,12 @@
 #define GMAC_HASH_TAB_32_63		0x00000014
 #define GMAC_RX_FLOW_CTRL		0x00000090
 #define GMAC_QX_TX_FLOW_CTRL(x)		(0x70 + x * 4)
+#define GMAC_TXQ_PRTY_MAP0		0x98
+#define GMAC_TXQ_PRTY_MAP1		0x9C
 #define GMAC_RXQ_CTRL0			0x000000a0
+#define GMAC_RXQ_CTRL1			0x000000a4
+#define GMAC_RXQ_CTRL2			0x000000a8
+#define GMAC_RXQ_CTRL3			0x000000ac
 #define GMAC_INT_STATUS			0x000000b0
 #define GMAC_INT_EN			0x000000b4
 #define GMAC_PCS_BASE			0x000000e0
@@ -53,6 +58,14 @@
 /* MAC Flow Control RX */
 #define GMAC_RX_FLOW_CTRL_RFE		BIT(0)
 
+/* RX Queues Priorities */
+#define GMAC_RXQCTRL_PSRQX_MASK(x)	GENMASK(7 + ((x) * 8), 0 + ((x) * 8))
+#define GMAC_RXQCTRL_PSRQX_SHIFT(x)	((x) * 8)
+
+/* TX Queues Priorities */
+#define GMAC_TXQCTRL_PSTQX_MASK(x)	GENMASK(7 + ((x) * 8), 0 + ((x) * 8))
+#define GMAC_TXQCTRL_PSTQX_SHIFT(x)	((x) * 8)
+
 /* MAC Flow Control TX */
 #define GMAC_TX_FLOW_CTRL_TFE		BIT(1)
 #define GMAC_TX_FLOW_CTRL_PT_SHIFT	16
@@ -161,8 +174,25 @@ enum power_event {
 #define GMAC_HI_REG_AE			BIT(31)
 
 /*  MTL registers */
+#define MTL_OPERATION_MODE		0x00000c00
+#define MTL_OPERATION_SCHALG_MASK	GENMASK(6, 5)
+#define MTL_OPERATION_SCHALG_WRR	(0x0 << 5)
+#define MTL_OPERATION_SCHALG_WFQ	(0x1 << 5)
+#define MTL_OPERATION_SCHALG_DWRR	(0x2 << 5)
+#define MTL_OPERATION_SCHALG_PRIO	(0x3 << 5)
+#define MTL_OPERATION_RAA		BIT(2)
+#define MTL_OPERATION_RAA_SP		(0x0 << 2)
+#define MTL_OPERATION_RAA_WSP		(0x1 << 2)
+
 #define MTL_INT_STATUS			0x00000c20
-#define MTL_INT_Q0			BIT(0)
+#define MTL_INT_QX(q)			BIT(q)
+
+#define MTL_RXQ_DMA_MAP0		0x00000c30 /* queue 0 to 3 */
+#define MTL_RXQ_DMA_MAP1		0x00000c34 /* queue 4 to 7 */
+#define MTL_RXQ_DMA_Q04MDMACH_MASK	GENMASK(3, 0)
+#define MTL_RXQ_DMA_Q04MDMACH(x)	((x) << 0)
+#define MTL_RXQ_DMA_QXMDMACH_MASK(x)	GENMASK(11 + (8 * ((x) - 1)), 8 * (x))
+#define MTL_RXQ_DMA_QXMDMACH(chan, q)	((chan) << (8 * (q)))
 
 #define MTL_CHAN_BASE_ADDR		0x00000d00
 #define MTL_CHAN_BASE_OFFSET		0x40
@@ -201,6 +231,13 @@ enum power_event {
 #define MTL_OP_MODE_RTC_96		(2 << MTL_OP_MODE_RTC_SHIFT)
 #define MTL_OP_MODE_RTC_128		(3 << MTL_OP_MODE_RTC_SHIFT)
 
+/* MTL Queue Quantum Weight */
+#define MTL_TXQ_WEIGHT_BASE_ADDR	0x00000d18
+#define MTL_TXQ_WEIGHT_BASE_OFFSET	0x40
+#define MTL_TXQX_WEIGHT_BASE_ADDR(x)	(MTL_TXQ_WEIGHT_BASE_ADDR + \
+					((x) * MTL_TXQ_WEIGHT_BASE_OFFSET))
+#define MTL_TXQ_WEIGHT_ISCQW_MASK	GENMASK(20, 0)
+
 /*  MTL debug */
 #define MTL_DEBUG_TXSTSFSTS		BIT(5)
 #define MTL_DEBUG_TXFSTS		BIT(4)
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
index 202216c..26acd07 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
@@ -70,6 +70,125 @@ static void dwmac4_rx_queue_enable(struct mac_device_info *hw, u32 queue)
 	writel(value, ioaddr + GMAC_RXQ_CTRL0);
 }
 
+static void dwmac4_rx_queue_priority(struct mac_device_info *hw,
+				     u32 prio, u32 queue)
+{
+	void __iomem *ioaddr = hw->pcsr;
+	u32 base_register = 0;
+	u32 value = 0;
+
+	base_register = (queue < 4) ? GMAC_RXQ_CTRL2 : GMAC_RXQ_CTRL3;
+
+	value = readl(ioaddr + base_register);
+
+	value &= ~GMAC_RXQCTRL_PSRQX_MASK(queue);
+	value |= (prio << GMAC_RXQCTRL_PSRQX_SHIFT(queue)) &
+						GMAC_RXQCTRL_PSRQX_MASK(queue);
+	writel(value, ioaddr + base_register);
+}
+
+static void dwmac4_tx_queue_priority(struct mac_device_info *hw,
+				     u32 prio, u32 queue)
+{
+	void __iomem *ioaddr = hw->pcsr;
+	u32 base_register = 0;
+	u32 value = 0;
+
+	base_register = (queue < 4) ? GMAC_TXQ_PRTY_MAP0 : GMAC_TXQ_PRTY_MAP1;
+
+	value = readl(ioaddr + base_register);
+
+	value &= ~GMAC_TXQCTRL_PSTQX_MASK(queue);
+	value |= (prio << GMAC_TXQCTRL_PSTQX_SHIFT(queue)) &
+						GMAC_TXQCTRL_PSTQX_MASK(queue);
+
+	writel(value, ioaddr + base_register);
+}
+
+static void dwmac4_prog_mtl_rx_algorithms(struct mac_device_info *hw,
+					  u32 rx_alg)
+{
+	void __iomem *ioaddr = hw->pcsr;
+	u32 value = readl(ioaddr + MTL_OPERATION_MODE);
+
+	value &= ~MTL_OPERATION_RAA;
+	switch (rx_alg) {
+	case MTL_RX_ALGORITHM_SP:
+	value |= MTL_OPERATION_RAA_SP;
+	break;
+	case MTL_RX_ALGORITHM_WSP:
+	value |= MTL_OPERATION_RAA_WSP;
+	break;
+	default:
+	break;
+	}
+
+	writel(value, ioaddr + MTL_OPERATION_MODE);
+}
+
+static void dwmac4_prog_mtl_tx_algorithms(struct mac_device_info *hw,
+					  u32 tx_alg)
+{
+	void __iomem *ioaddr = hw->pcsr;
+	u32 value = readl(ioaddr + MTL_OPERATION_MODE);
+
+	value &= ~MTL_OPERATION_SCHALG_MASK;
+	switch (tx_alg) {
+	case MTL_TX_ALGORITHM_WRR:
+	value |= MTL_OPERATION_SCHALG_WRR;
+	break;
+	case MTL_TX_ALGORITHM_WFQ:
+	value |= MTL_OPERATION_SCHALG_WFQ;
+	break;
+	case MTL_TX_ALGORITHM_DWRR:
+	value |= MTL_OPERATION_SCHALG_DWRR;
+	break;
+	case MTL_TX_ALGORITHM_PRIO:
+	value |= MTL_OPERATION_SCHALG_PRIO;
+	break;
+	default:
+	break;
+	}
+
+	writel(value, ioaddr + MTL_OPERATION_MODE);
+}
+
+static void dwmac4_map_mtl_dma(struct mac_device_info *hw, u32 queue, u32 chan)
+{
+	void __iomem *ioaddr = hw->pcsr;
+	u32 value = 0;
+
+	if (queue < 4)
+		value = readl(ioaddr + MTL_RXQ_DMA_MAP0);
+	else
+		value = readl(ioaddr + MTL_RXQ_DMA_MAP1);
+
+	if (queue == 0 || queue == 4) {
+		value &= ~MTL_RXQ_DMA_Q04MDMACH_MASK;
+		value |= MTL_RXQ_DMA_Q04MDMACH(chan);
+	} else {
+		value &= ~MTL_RXQ_DMA_QXMDMACH_MASK(queue);
+		value |= MTL_RXQ_DMA_QXMDMACH(chan, queue);
+	}
+
+	if (queue < 4)
+		writel(value, ioaddr + MTL_RXQ_DMA_MAP0);
+	else
+		writel(value, ioaddr + MTL_RXQ_DMA_MAP1);
+}
+
+static void dwmac4_set_mtl_tx_queue_weight(struct mac_device_info *hw,
+					   u32 weight, u32 queue)
+{
+	void __iomem *ioaddr = hw->pcsr;
+	u32 value = 0;
+
+	value = readl(ioaddr + MTL_TXQX_WEIGHT_BASE_ADDR(queue));
+	value &= ~MTL_TXQ_WEIGHT_ISCQW_MASK;
+	value |= weight & MTL_TXQ_WEIGHT_ISCQW_MASK;
+	writel(value, ioaddr + MTL_TXQX_WEIGHT_BASE_ADDR(queue));
+}
+
 static void dwmac4_dump_regs(struct mac_device_info *hw)
 {
 	void __iomem *ioaddr = hw->pcsr;
@@ -257,11 +376,12 @@ static void dwmac4_set_filter(struct mac_device_info *hw,
 }
 
 static void dwmac4_flow_ctrl(struct mac_device_info *hw, unsigned int duplex,
-			     unsigned int fc, unsigned int pause_time)
+			     unsigned int fc, unsigned int pause_time,
+			     u32 tx_queues_cnt)
 {
 	void __iomem *ioaddr = hw->pcsr;
-	u32 channel = STMMAC_CHAN0;	/* FIXME */
 	unsigned int flow = 0;
+	u32 queue = 0;
 
 	pr_debug("GMAC Flow-Control:\n");
 	if (fc & FLOW_RX) {
@@ -271,13 +391,17 @@ static void dwmac4_flow_ctrl(struct mac_device_info *hw, unsigned int duplex,
 	}
 	if (fc & FLOW_TX) {
 		pr_debug("\tTransmit Flow-Control ON\n");
-		flow |= GMAC_TX_FLOW_CTRL_TFE;
-		writel(flow, ioaddr + GMAC_QX_TX_FLOW_CTRL(channel));
-
-		if (duplex) {
+		if (duplex)
 			pr_debug("\tduplex mode: PAUSE %d\n", pause_time);
-			flow |= (pause_time << GMAC_TX_FLOW_CTRL_PT_SHIFT);
-			writel(flow, ioaddr + GMAC_QX_TX_FLOW_CTRL(channel));
+
+		for (queue = 0; queue < tx_queues_cnt; queue++) {
+			flow |= GMAC_TX_FLOW_CTRL_TFE;
+
+			if (duplex)
+				flow |=
+				(pause_time << GMAC_TX_FLOW_CTRL_PT_SHIFT);
+
+			writel(flow, ioaddr + GMAC_QX_TX_FLOW_CTRL(queue));
 		}
 	}
 }
@@ -331,11 +455,32 @@ static void dwmac4_phystatus(void __iomem *ioaddr, struct stmmac_extra_stats *x)
 	}
 }
 
+static int dwmac4_irq_mtl_status(struct mac_device_info *hw, u32 chan)
+{
+	void __iomem *ioaddr = hw->pcsr;
+	u32 mtl_int_qx_status = readl(ioaddr + MTL_INT_STATUS);
+	int ret = 0;
+
+	/* Check MTL Interrupt */
+	if (mtl_int_qx_status & MTL_INT_QX(chan)) {
+		/* read Queue x Interrupt status */
+		u32 status = readl(ioaddr + MTL_CHAN_INT_CTRL(chan));
+
+		if (status & MTL_RX_OVERFLOW_INT) {
+			/*  clear Interrupt */
+			writel(status | MTL_RX_OVERFLOW_INT,
+			       ioaddr + MTL_CHAN_INT_CTRL(chan));
+			ret = CORE_IRQ_MTL_RX_OVERFLOW;
+		}
+	}
+
+	return ret;
+}
+
 static int dwmac4_irq_status(struct mac_device_info *hw,
 			     struct stmmac_extra_stats *x)
 {
 	void __iomem *ioaddr = hw->pcsr;
-	u32 mtl_int_qx_status;
 	u32 intr_status;
 	int ret = 0;
 
@@ -354,20 +499,6 @@ static int dwmac4_irq_status(struct mac_device_info *hw,
 		x->irq_receive_pmt_irq_n++;
 	}
 
-	mtl_int_qx_status = readl(ioaddr + MTL_INT_STATUS);
-	/* Check MTL Interrupt: Currently only one queue is used: Q0. */
-	if (mtl_int_qx_status & MTL_INT_Q0) {
-		/* read Queue 0 Interrupt status */
-		u32 status = readl(ioaddr + MTL_CHAN_INT_CTRL(STMMAC_CHAN0));
-
-		if (status & MTL_RX_OVERFLOW_INT) {
-			/*  clear Interrupt */
-			writel(status | MTL_RX_OVERFLOW_INT,
-			       ioaddr + MTL_CHAN_INT_CTRL(STMMAC_CHAN0));
-			ret = CORE_IRQ_MTL_RX_OVERFLOW;
-		}
-	}
-
 	dwmac_pcs_isr(ioaddr, GMAC_PCS_BASE, intr_status, x);
 	if (intr_status & PCS_RGSMIIIS_IRQ)
 		dwmac4_phystatus(ioaddr, x);
@@ -375,12 +506,10 @@ static int dwmac4_irq_status(struct mac_device_info *hw,
 	return ret;
 }
 
-static void dwmac4_debug(void __iomem *ioaddr, struct stmmac_extra_stats *x)
+static void dwmac4_debug(void __iomem *ioaddr, struct stmmac_extra_stats *x,
+			 u32 queue)
 {
-	u32 value;
-
-	/*  Currently only channel 0 is supported */
-	value = readl(ioaddr + MTL_CHAN_TX_DEBUG(STMMAC_CHAN0));
+	u32 value = readl(ioaddr + MTL_CHAN_TX_DEBUG(queue));
 
 	if (value & MTL_DEBUG_TXSTSFSTS)
 		x->mtl_tx_status_fifo_full++;
@@ -403,7 +532,7 @@ static void dwmac4_debug(void __iomem *ioaddr, struct stmmac_extra_stats *x)
 	if (value & MTL_DEBUG_TXPAUSED)
 		x->mac_tx_in_pause++;
 
-	value = readl(ioaddr + MTL_CHAN_RX_DEBUG(STMMAC_CHAN0));
+	value = readl(ioaddr + MTL_CHAN_RX_DEBUG(queue));
 
 	if (value & MTL_DEBUG_RXFSTS_MASK) {
 		u32 rxfsts = (value & MTL_DEBUG_RXFSTS_MASK)
@@ -463,8 +592,15 @@ static const struct stmmac_ops dwmac4_ops = {
 	.core_init = dwmac4_core_init,
 	.rx_ipc = dwmac4_rx_ipc_enable,
 	.rx_queue_enable = dwmac4_rx_queue_enable,
+	.rx_queue_prio = dwmac4_rx_queue_priority,
+	.tx_queue_prio = dwmac4_tx_queue_priority,
+	.prog_mtl_rx_algorithms = dwmac4_prog_mtl_rx_algorithms,
+	.prog_mtl_tx_algorithms = dwmac4_prog_mtl_tx_algorithms,
+	.map_mtl_to_dma = dwmac4_map_mtl_dma,
+	.set_mtl_tx_queue_weight = dwmac4_set_mtl_tx_queue_weight,
 	.dump_regs = dwmac4_dump_regs,
 	.host_irq_status = dwmac4_irq_status,
+	.host_mtl_irq_status = dwmac4_irq_mtl_status,
 	.flow_ctrl = dwmac4_flow_ctrl,
 	.pmt = dwmac4_pmt,
 	.set_umac_addr = dwmac4_set_umac_addr,
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
index aab895d..a010fce 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
@@ -499,8 +499,10 @@ stmmac_set_pauseparam(struct net_device *netdev,
 		      struct ethtool_pauseparam *pause)
 {
 	struct stmmac_priv *priv = netdev_priv(netdev);
+	u32 tx_queues_count = priv->dma_cap.number_tx_queues;
 	struct phy_device *phy = netdev->phydev;
 	int new_pause = FLOW_OFF;
+	u32 queue = 0;
 
 	if (priv->hw->pcs && priv->hw->mac->pcs_get_adv_lp) {
 		struct rgmii_adv adv_lp;
@@ -529,7 +531,8 @@ stmmac_set_pauseparam(struct net_device *netdev,
 	}
 
 	priv->hw->mac->flow_ctrl(priv->hw, phy->duplex, priv->flow_ctrl,
-				 priv->pause);
+				 priv->pause, tx_queues_count);
+
 	return 0;
 }
 
@@ -537,7 +540,13 @@ static void stmmac_get_ethtool_stats(struct net_device *dev,
 				 struct ethtool_stats *dummy, u64 *data)
 {
 	struct stmmac_priv *priv = netdev_priv(dev);
-	int i, j = 0;
+	u32 rx_queues_count = priv->dma_cap.number_rx_queues;
+	u32 tx_queues_count = priv->dma_cap.number_tx_queues;
+	u32 queue_count = 0;
+	int i, j, queue = 0;
+
+	queue_count = (tx_queues_count > rx_queues_count) ?
+		      tx_queues_count : rx_queues_count;
 
 	/* Update the DMA HW counters for dwmac10/100 */
 	if (priv->hw->dma->dma_diagnostic_fr)
@@ -565,9 +574,12 @@ static void stmmac_get_ethtool_stats(struct net_device *dev,
 		}
 
 		if ((priv->hw->mac->debug) &&
-		    (priv->synopsys_id >= DWMAC_CORE_3_50))
-			priv->hw->mac->debug(priv->ioaddr,
-					     (void *)&priv->xstats);
+		    (priv->synopsys_id >= DWMAC_CORE_3_50)) {
+			for (queue = 0; queue < queue_count; queue++)
+				priv->hw->mac->debug(priv->ioaddr,
+						     (void *)&priv->xstats,
+						     queue);
+		}
 	}
 	for (i = 0; i < STMMAC_STATS_LEN; i++) {
 		char *p = (char *)priv + stmmac_gstrings_stats[i].stat_offset;
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 7251871..a6f0b49 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -673,6 +673,19 @@ static void stmmac_release_ptp(struct stmmac_priv *priv)
 }
 
 /**
+ *  stmmac_mac_flow_ctrl - Configure flow control in all queues
+ *  @priv: driver private structure
+ *  Description: It is used for configuring the flow control in all queues
+ */
+static void stmmac_mac_flow_ctrl(struct stmmac_priv *priv, u32 duplex)
+{
+	u32 tx_queues_count = priv->dma_cap.number_tx_queues;
+
+	priv->hw->mac->flow_ctrl(priv->hw, duplex, priv->flow_ctrl,
+				 priv->pause, tx_queues_count);
+}
+
+/**
  * stmmac_adjust_link - adjusts the link parameters
  * @dev: net device structure
  * Description: this is the helper called by the physical abstraction layer
@@ -687,7 +700,6 @@ static void stmmac_adjust_link(struct net_device *dev)
 	struct phy_device *phydev = dev->phydev;
 	unsigned long flags;
 	int new_state = 0;
-	unsigned int fc = priv->flow_ctrl, pause_time = priv->pause;
 
 	if (!phydev)
 		return;
@@ -709,8 +721,7 @@ static void stmmac_adjust_link(struct net_device *dev)
 		}
 		/* Flow Control operation */
 		if (phydev->pause)
-			priv->hw->mac->flow_ctrl(priv->hw, phydev->duplex,
-						 fc, pause_time);
+			stmmac_mac_flow_ctrl(priv, phydev->duplex);
 
 		if (phydev->speed != priv->speed) {
 			new_state = 1;
@@ -1246,6 +1257,83 @@ static void free_dma_desc_resources(struct stmmac_priv *priv)
 }
 
 /**
+ *  stmmac_rx_queue_dma_chan_map - Map RX queue to RX dma channel
+ *  @priv: driver private structure
+ *  Description: It is used for mapping RX queues to RX dma channels
+ */
+static void stmmac_rx_queue_dma_chan_map(struct stmmac_priv *priv)
+{
+	u32 rx_queues_count = priv->dma_cap.number_rx_queues;
+	u32 queue = 0;
+
+	/* If does not have multiple queues, then this is not necessary */
+	if (rx_queues_count == 1)
+		return;
+
+	for (queue = 0; queue < rx_queues_count; queue++)
+		priv->hw->mac->map_mtl_to_dma(priv->hw, queue, queue);
+}
+
+/**
+ *  stmmac_set_tx_queue_weight - Set TX queue weight
+ *  @priv: driver private structure
+ *  Description: It is used for setting TX queues weight
+ */
+static void stmmac_set_tx_queue_weight(struct stmmac_priv *priv)
+{
+	u32 tx_queues_count = priv->dma_cap.number_tx_queues;
+	u32 weight = 0;
+	u32 queue = 0;
+
+	for (queue = 0; queue < tx_queues_count; queue++) {
+		weight = priv->plat->tx_queues_weight[queue];
+		priv->hw->mac->set_mtl_tx_queue_weight(priv->hw, weight, queue);
+	}
+}
+
+/**
+ *  stmmac_mac_config_rx_queues_prio - Configure RX Queue priority
+ *  @priv: driver private structure
+ *  Description: It is used for configuring the RX Queue Priority
+ */
+static void stmmac_mac_config_rx_queues_prio(struct stmmac_priv *priv)
+{
+	u32 rx_count = priv->dma_cap.number_rx_queues;
+	u32 queue = 0;
+	u32 prio = 0;
+
+	/* If does not have multiple queues, then this is not necessary*/
+	if (rx_count == 1)
+		return;
+
+	for (queue = 0; queue < rx_count; queue++) {
+		prio = priv->plat->rx_queues_prio[queue];
+		priv->hw->mac->rx_queue_prio(priv->hw, prio, queue);
+	}
+}
+
+/**
+ *  stmmac_mac_config_tx_queues_prio - Configure TX Queue priority
+ *  @priv: driver private structure
+ *  Description: It is used for configuring the TX Queue Priority
+ */
+static void stmmac_mac_config_tx_queues_prio(struct stmmac_priv *priv)
+{
+	u32 tx_count = priv->dma_cap.number_tx_queues;
+	u32 queue = 0;
+	u32 prio = 0;
+
+	/* If does not have multiple queues, then this is not necessary*/
+	if (tx_count == 1)
+		return;
+
+	for (queue = 0; queue < tx_count; queue++) {
+		prio = priv->plat->tx_queues_prio[queue];
+		priv->hw->mac->tx_queue_prio(priv->hw, prio, queue);
+	}
+}
+
+/**
  *  stmmac_mac_enable_rx_queues - Enable MAC rx queues
  *  @priv: driver private structure
  *  Description: It is used for enabling the rx queues in the MAC
@@ -1255,16 +1343,16 @@ static void stmmac_mac_enable_rx_queues(struct stmmac_priv *priv)
 	int rx_count = priv->dma_cap.number_rx_queues;
 	int queue = 0;
 
-	/* If GMAC does not have multiple queues, then this is not necessary*/
+	/* If does not have multiple queues, then this is not necessary*/
 	if (rx_count == 1)
 		return;
 
 	/**
-	 *  If the core is synthesized with multiple rx queues / multiple
-	 *  dma channels, then rx queues will be disabled by default.
-	 *  For now only rx queue 0 is enabled.
+	 *  If the core is synthesized with multiple rx/tx queues
+	 *  then rx queues will be disabled by default.
 	 */
-	priv->hw->mac->rx_queue_enable(priv->hw, queue);
+	for (queue = 0; queue < rx_count; queue++)
+		priv->hw->mac->rx_queue_enable(priv->hw, queue);
 }
 
 /**
@@ -1431,6 +1519,42 @@ static void stmmac_tx_err(struct stmmac_priv *priv)
 }
 
 /**
+ *  stmmac_mtl_configuration - Configure MTL
+ *  @priv: driver private structure
+ *  Description: It is used for configurring MTL
+ */
+static void stmmac_mtl_configuration(struct stmmac_priv *priv)
+{
+	u32 rx_queues_count = priv->dma_cap.number_rx_queues;
+	u32 tx_queues_count = priv->dma_cap.number_tx_queues;
+
+	if (tx_queues_count > 1 && priv->hw->mac->set_mtl_tx_queue_weight)
+		stmmac_set_tx_queue_weight(priv);
+
+	/* Configure MTL RX algorithms */
+	if (rx_queues_count > 1 && priv->hw->mac->prog_mtl_rx_algorithms)
+		priv->hw->mac->prog_mtl_rx_algorithms(priv->hw,
+						priv->plat->mtl_rx_algorithm);
+
+	/* Configure MTL TX algorithms */
+	if (tx_queues_count > 1 && priv->hw->mac->prog_mtl_tx_algorithms)
+		priv->hw->mac->prog_mtl_tx_algorithms(priv->hw,
+						priv->plat->mtl_tx_algorithm);
+
+	/* Map RX MTL to DMA channels */
+	if (rx_queues_count > 1 && priv->hw->mac->map_mtl_to_dma)
+		stmmac_rx_queue_dma_chan_map(priv);
+
+	/* Enable MAC RX Queues */
+	if (rx_queues_count > 1 && priv->hw->mac->rx_queue_enable)
+		stmmac_mac_enable_rx_queues(priv);
+
+	/* Configure RX Queues Priority */
+	if (rx_queues_count > 1 && priv->hw->mac->rx_queue_prio)
+		stmmac_mac_config_rx_queues_prio(priv);
+}
+
+/**
  * stmmac_dma_interrupt - DMA ISR
  * @priv: driver private structure
  * Description: this is the DMA ISR. It is called by the main ISR.
@@ -1684,9 +1808,9 @@ static int stmmac_hw_setup(struct net_device *dev, bool init_ptp)
 	/* Initialize the MAC Core */
 	priv->hw->mac->core_init(priv->hw, dev->mtu);
 
-	/* Initialize MAC RX Queues */
-	if (priv->hw->mac->rx_queue_enable)
-		stmmac_mac_enable_rx_queues(priv);
+	/* Initialize MTL*/
+	if (priv->synopsys_id >= DWMAC_CORE_4_00)
+		stmmac_mtl_configuration(priv);
 
 	ret = priv->hw->mac->rx_ipc(priv->hw);
 	if (!ret) {
@@ -1704,6 +1828,9 @@ static int stmmac_hw_setup(struct net_device *dev, bool init_ptp)
 	/* Set the HW DMA mode and the COE */
 	stmmac_dma_operation_mode(priv);
 
+	if (priv->synopsys_id >= DWMAC_CORE_4_00)
+		stmmac_mac_config_tx_queues_prio(priv);
+
 	stmmac_mmc_setup(priv);
 
 	if (init_ptp) {
@@ -2809,6 +2936,9 @@ static irqreturn_t stmmac_interrupt(int irq, void *dev_id)
 	if ((priv->plat->has_gmac) || (priv->plat->has_gmac4)) {
 		int status = priv->hw->mac->host_irq_status(priv->hw,
 							    &priv->xstats);
+		if (priv->synopsys_id >= DWMAC_CORE_4_00)
+			status |= priv->hw->mac->host_mtl_irq_status(priv->hw,
+								STMMAC_CHAN0);
 		if (unlikely(status)) {
 			/* For LPI we need to save the tx status */
 			if (status & CORE_IRQ_TX_PATH_IN_LPI_MODE)
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index 433a842..f68134c 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -338,6 +338,39 @@ stmmac_probe_config_dt(struct platform_device *pdev, const char **mac)
 
 	of_property_read_u32(np, "snps,ps-speed", &plat->mac_port_sel_speed);
 
+	/* Rx MTL algorithms */
+	if (of_property_read_bool(np, "snps,rx-sched-sp"))
+		plat->mtl_rx_algorithm = MTL_RX_ALGORITHM_SP;
+	else if (of_property_read_bool(np, "snps,rx-sched-wsp"))
+		plat->mtl_rx_algorithm = MTL_RX_ALGORITHM_WSP;
+	else
+		plat->mtl_rx_algorithm = MTL_RX_ALGORITHM_SP;
+
+	/* Tx MTL algorithms */
+	if (of_property_read_bool(np, "snps,tx-sched-wrr"))
+		plat->mtl_tx_algorithm = MTL_TX_ALGORITHM_WRR;
+	else if (of_property_read_bool(np, "snps,tx-sched-wfq"))
+		plat->mtl_tx_algorithm = MTL_TX_ALGORITHM_WFQ;
+	else if (of_property_read_bool(np, "snps,tx-sched-dwrr"))
+		plat->mtl_tx_algorithm = MTL_TX_ALGORITHM_DWRR;
+	else if (of_property_read_bool(np, "snps,tx-sched-prio"))
+		plat->mtl_tx_algorithm = MTL_TX_ALGORITHM_PRIO;
+	else
+		plat->mtl_tx_algorithm = MTL_TX_ALGORITHM_WRR;
+
+	/* TX queues weight */
+	of_property_read_u32_array(np, "snps,tx-queue-weight",
+				   plat->tx_queues_weight,
+				   EQOS_MAX_NUMBER_TX_QUEUES);
+
+	/* RX and TX priority */
+	of_property_read_u32_array(np, "snps,rx-queue-prio",
+				   plat->rx_queues_prio,
+				   EQOS_MAX_NUMBER_RX_QUEUES);
+	of_property_read_u32_array(np, "snps,tx-queue-prio",
+				   plat->tx_queues_prio,
+				   EQOS_MAX_NUMBER_TX_QUEUES);
+
 	plat->axi = stmmac_axi_setup(pdev);
 
 	/* clock setup */
diff --git a/include/linux/stmmac.h b/include/linux/stmmac.h
index fc273e9..98201d4 100644
--- a/include/linux/stmmac.h
+++ b/include/linux/stmmac.h
@@ -32,6 +32,9 @@
 #define STMMAC_RX_COE_TYPE1	1
 #define STMMAC_RX_COE_TYPE2	2
 
+#define EQOS_MAX_NUMBER_TX_QUEUES	8
+#define EQOS_MAX_NUMBER_RX_QUEUES	8
+
 /* Define the macros for CSR clock range parameters to be passed by
  * platform code.
  * This could also be configured at run time using CPU freq framework. */
@@ -147,5 +150,10 @@ struct plat_stmmacenet_data {
 	bool tso_en;
 	int mac_port_sel_speed;
 	bool en_tx_lpi_clockgating;
+	int mtl_tx_algorithm;
+	int mtl_rx_algorithm;
+	u32 tx_queues_weight[EQOS_MAX_NUMBER_TX_QUEUES];
+	u32 rx_queues_prio[EQOS_MAX_NUMBER_RX_QUEUES];
+	u32 tx_queues_prio[EQOS_MAX_NUMBER_TX_QUEUES];
 };
 #endif
-- 
2.9.3
