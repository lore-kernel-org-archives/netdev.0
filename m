From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: [PATCH net-next 2/3] net: stmmac: TX and RX queue priority configuration
Date: Thu, 16 Mar 2017 10:56:56 +0000
Message-ID: <d4f473fe775aef91382a1ce93aa9234631446daf.1489661229.git.jpinto@synopsys.com>
References: <cover.1489661229.git.jpinto@synopsys.com>
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org, Joao Pinto <Joao.Pinto@synopsys.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay4.synopsys.com ([198.182.47.9]:52332 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751489AbdCPK54 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Mar 2017 06:57:56 -0400
In-Reply-To: <cover.1489661229.git.jpinto@synopsys.com>
In-Reply-To: <cover.1489661229.git.jpinto@synopsys.com>
References: <cover.1489661229.git.jpinto@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the configuration of RX and TX queues' priority.

Signed-off-by: Joao Pinto <jpinto@synopsys.com>
---
 Documentation/devicetree/bindings/net/stmmac.txt   |  5 +++
 drivers/net/ethernet/stmicro/stmmac/common.h       |  4 ++
 drivers/net/ethernet/stmicro/stmmac/dwmac4.h       | 13 ++++++
 drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c  | 37 +++++++++++++++++
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  | 48 ++++++++++++++++++++++
 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c   |  4 ++
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  | 16 ++++++++
 include/linux/stmmac.h                             |  4 ++
 8 files changed, 131 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/stmmac.txt b/Documentation/devicetree/bindings/net/stmmac.txt
index a7b0e41..b9a9ae9 100644
--- a/Documentation/devicetree/bindings/net/stmmac.txt
+++ b/Documentation/devicetree/bindings/net/stmmac.txt
@@ -83,6 +83,7 @@ Optional properties:
 			- snps,dcb-algorithm: Queue to be enabled as DCB
 			- snps,avb-algorithm: Queue to be enabled as AVB
 		- snps,map-to-dma-channel: Channel to map
+	- snps,priority: RX queue priority
 - Multiple TX Queues parameters: below the list of all the parameters to
 				 configure the multiple TX queues:
 	- snps,tx-queues-to-use: number of TX queues to be used in the driver
@@ -101,6 +102,7 @@ Optional properties:
 			- snps,idle_slope: unlock on WoL
 			- snps,high_credit: max write outstanding req. limit
 			- snps,low_credit: max read outstanding req. limit
+		- snps,priority: TX queue priority
 Examples:
 
 	stmmac_axi_setup: stmmac-axi-config {
@@ -115,6 +117,7 @@ Examples:
 		queue0 {
 			snps,dcb-algorithm;
 			snps,map-to-dma-channel = <0x0>;
+			snps,priority = <0x0>;
 		};
 	};
 
@@ -124,6 +127,7 @@ Examples:
 		queue0 {
 			snps,weight = <0x10>;
 			snps,dcb-algorithm;
+			snps,priority = <0x0>;
 		};
 
 		queue1 {
@@ -132,6 +136,7 @@ Examples:
 			snps,idle_slope = <0x1000>;
 			snps,high_credit = <0x3E800>;
 			snps,low_credit = <0xFFC18000>;
+			snps,priority = <0x1>;
 		};
 	};
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index badc441..e0b31e7 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -469,6 +469,10 @@ struct stmmac_ops {
 	int (*rx_ipc)(struct mac_device_info *hw);
 	/* Enable RX Queues */
 	void (*rx_queue_enable)(struct mac_device_info *hw, u8 mode, u32 queue);
+	/* RX Queues Priority */
+	void (*rx_queue_prio)(struct mac_device_info *hw, u32 prio, u32 queue);
+	/* TX Queues Priority */
+	void (*tx_queue_prio)(struct mac_device_info *hw, u32 prio, u32 queue);
 	/* Program RX Algorithms */
 	void (*prog_mtl_rx_algorithms)(struct mac_device_info *hw, u32 rx_alg);
 	/* Program TX Algorithms */
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4.h b/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
index 54bcdb4..a6c382d 100644
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
 #define GMAC_1US_TIC_COUNTER		0x000000dc
@@ -54,6 +59,14 @@
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
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
index 10599db..342f62a 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
@@ -74,6 +74,41 @@ static void dwmac4_rx_queue_enable(struct mac_device_info *hw,
 	writel(value, ioaddr + GMAC_RXQ_CTRL0);
 }
 
+static void dwmac4_rx_queue_priority(struct mac_device_info *hw,
+				     u32 prio, u32 queue)
+{
+	void __iomem *ioaddr = hw->pcsr;
+	u32 base_register;
+	u32 value;
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
+	u32 base_register;
+	u32 value;
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
 static void dwmac4_prog_mtl_rx_algorithms(struct mac_device_info *hw,
 					  u32 rx_alg)
 {
@@ -603,6 +638,8 @@ static const struct stmmac_ops dwmac4_ops = {
 	.core_init = dwmac4_core_init,
 	.rx_ipc = dwmac4_rx_ipc_enable,
 	.rx_queue_enable = dwmac4_rx_queue_enable,
+	.rx_queue_prio = dwmac4_rx_queue_priority,
+	.tx_queue_prio = dwmac4_tx_queue_priority,
 	.prog_mtl_rx_algorithms = dwmac4_prog_mtl_rx_algorithms,
 	.prog_mtl_tx_algorithms = dwmac4_prog_mtl_tx_algorithms,
 	.set_mtl_tx_queue_weight = dwmac4_set_mtl_tx_queue_weight,
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index a389dfb..0f2c0d7 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -2293,6 +2293,46 @@ static void stmmac_rx_queue_dma_chan_map(struct stmmac_priv *priv)
 }
 
 /**
+ *  stmmac_mac_config_rx_queues_prio - Configure RX Queue priority
+ *  @priv: driver private structure
+ *  Description: It is used for configuring the RX Queue Priority
+ */
+static void stmmac_mac_config_rx_queues_prio(struct stmmac_priv *priv)
+{
+	u32 rx_queues_count = priv->plat->rx_queues_to_use;
+	u32 queue;
+	u32 prio;
+
+	for (queue = 0; queue < rx_queues_count; queue++) {
+		if (!priv->plat->rx_queues_cfg[queue].use_prio)
+			continue;
+
+		prio = priv->plat->rx_queues_cfg[queue].prio;
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
+	u32 tx_queues_count = priv->plat->tx_queues_to_use;
+	u32 queue;
+	u32 prio;
+
+	for (queue = 0; queue < tx_queues_count; queue++) {
+		if (!priv->plat->tx_queues_cfg[queue].use_prio)
+			continue;
+
+		prio = priv->plat->tx_queues_cfg[queue].prio;
+		priv->hw->mac->tx_queue_prio(priv->hw, prio, queue);
+	}
+}
+
+/**
  *  stmmac_mtl_configuration - Configure MTL
  *  @priv: driver private structure
  *  Description: It is used for configurring MTL
@@ -2329,6 +2369,14 @@ static void stmmac_mtl_configuration(struct stmmac_priv *priv)
 
 	/* Set the HW DMA mode and the COE */
 	stmmac_dma_operation_mode(priv);
+
+	/* Set RX priorities */
+	if (rx_queues_count > 1 && priv->hw->mac->rx_queue_prio)
+		stmmac_mac_config_rx_queues_prio(priv);
+
+	/* Set TX priorities */
+	if (tx_queues_count > 1 && priv->hw->mac->tx_queue_prio)
+		stmmac_mac_config_tx_queues_prio(priv);
 }
 
 /**
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
index cea472a..ffe4fac 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
@@ -92,6 +92,10 @@ static void stmmac_default_data(struct plat_stmmacenet_data *plat)
 	/* Set default number of RX and TX queues to use */
 	plat->tx_queues_to_use = 1;
 	plat->rx_queues_to_use = 1;
+
+	/* Disable Priority config by default */
+	plat->tx_queues_cfg[0].use_prio = false;
+	plat->rx_queues_cfg[0].use_prio = false;
 }
 
 static int quark_default_data(struct plat_stmmacenet_data *plat,
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index 37f550a..77b0468 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -182,6 +182,14 @@ static void stmmac_mtl_setup(struct platform_device *pdev,
 			plat->rx_queues_cfg[queue].chan = queue;
 		/* TODO: Dynamic mapping to be included in the future */
 
+		if (of_property_read_u32(q_node, "snps,priority",
+					&plat->rx_queues_cfg[queue].prio)) {
+			plat->rx_queues_cfg[queue].prio = 0;
+			plat->rx_queues_cfg[queue].use_prio = false;
+		} else {
+			plat->rx_queues_cfg[queue].use_prio = true;
+		}
+
 		queue++;
 	}
 
@@ -235,6 +243,14 @@ static void stmmac_mtl_setup(struct platform_device *pdev,
 			plat->tx_queues_cfg[queue].mode_to_use = MTL_QUEUE_DCB;
 		}
 
+		if (of_property_read_u32(q_node, "snps,priority",
+					&plat->tx_queues_cfg[queue].prio)) {
+			plat->tx_queues_cfg[queue].prio = 0;
+			plat->tx_queues_cfg[queue].use_prio = false;
+		} else {
+			plat->tx_queues_cfg[queue].use_prio = true;
+		}
+
 		queue++;
 	}
 
diff --git a/include/linux/stmmac.h b/include/linux/stmmac.h
index be47b85..b7d5e7a 100644
--- a/include/linux/stmmac.h
+++ b/include/linux/stmmac.h
@@ -127,6 +127,8 @@ struct stmmac_axi {
 struct stmmac_rxq_cfg {
 	u8 mode_to_use;
 	u8 chan;
+	bool use_prio;
+	u32 prio;
 };
 
 struct stmmac_txq_cfg {
@@ -137,6 +139,8 @@ struct stmmac_txq_cfg {
 	u32 idle_slope;
 	u32 high_credit;
 	u32 low_credit;
+	bool use_prio;
+	u32 prio;
 };
 
 struct plat_stmmacenet_data {
-- 
2.9.3
