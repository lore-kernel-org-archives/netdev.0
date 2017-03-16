From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: [PATCH net-next 3/3] net: stmmac: RX queue routing configuration
Date: Thu, 16 Mar 2017 10:56:57 +0000
Message-ID: <625ef961b7fd7bda4f92180afce299fc9c887e77.1489661229.git.jpinto@synopsys.com>
References: <cover.1489661229.git.jpinto@synopsys.com>
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org, Joao Pinto <Joao.Pinto@synopsys.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay4.synopsys.com ([198.182.47.9]:52335 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751531AbdCPK54 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Mar 2017 06:57:56 -0400
In-Reply-To: <cover.1489661229.git.jpinto@synopsys.com>
In-Reply-To: <cover.1489661229.git.jpinto@synopsys.com>
References: <cover.1489661229.git.jpinto@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the configuration of RX queues' routing.

Signed-off-by: Joao Pinto <jpinto@synopsys.com>
---
 Documentation/devicetree/bindings/net/stmmac.txt   | 19 ++++++-
 drivers/net/ethernet/stmicro/stmmac/common.h       |  9 ++++
 drivers/net/ethernet/stmicro/stmmac/dwmac4.h       | 18 +++++++
 drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c  | 63 ++++++++++++++++++++++
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  | 25 +++++++++
 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c   |  8 +++
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  | 49 +++++++++++++++++
 include/linux/stmmac.h                             | 12 +++++
 8 files changed, 202 insertions(+), 1 deletion(-)

diff --git a/Documentation/devicetree/bindings/net/stmmac.txt b/Documentation/devicetree/bindings/net/stmmac.txt
index b9a9ae9..9c9e774 100644
--- a/Documentation/devicetree/bindings/net/stmmac.txt
+++ b/Documentation/devicetree/bindings/net/stmmac.txt
@@ -84,6 +84,16 @@ Optional properties:
 			- snps,avb-algorithm: Queue to be enabled as AVB
 		- snps,map-to-dma-channel: Channel to map
 	- snps,priority: RX queue priority
+	- Specifiy RX Queue for processing certain types of packets:
+		- snps,avcp-to-queue: AV Untagged Control packets
+		- snps,ptp-to-queue: PTP Packets
+		- snps,dcbcp-to-queue: DCB Control Packets
+		- snps,up-to-queue: Untagged Packets
+		- snps,multi-broad-cast-queue: Multicast & Broadcast Packets
+		- snps,tpqc-queue: Tagged PTPoE Packets Queuing Control. Values:
+			0x0 - Priority based (RX queues non-AV)
+			0x1 - Routes to queue indicated in "snps,ptp-to-queue"
+			0x2 - Priority based (RX queues AV enabled)
 - Multiple TX Queues parameters: below the list of all the parameters to
 				 configure the multiple TX queues:
 	- snps,tx-queues-to-use: number of TX queues to be used in the driver
@@ -112,8 +122,15 @@ Examples:
 	};
 
 	mtl_rx_setup: rx-queues-config {
-		snps,rx-queues-to-use = <1>;
+		snps,rx-queues-to-use = <0>;
 		snps,rx-sched-sp;
+		snps,avcp-to-queue = <0>;
+		snps,ptp-to-queue = <0>;
+		snps,dcbcp-to-queue = <0>;
+		snps,up-to-queue = <0>;
+		snps,multi-broad-cast-queue = <0>;
+		snps,tpqc-queue = <0>;
+
 		queue0 {
 			snps,dcb-algorithm;
 			snps,map-to-dma-channel = <0x0>;
diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index e0b31e7..e08c4c4 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -473,6 +473,15 @@ struct stmmac_ops {
 	void (*rx_queue_prio)(struct mac_device_info *hw, u32 prio, u32 queue);
 	/* TX Queues Priority */
 	void (*tx_queue_prio)(struct mac_device_info *hw, u32 prio, u32 queue);
+	/* RX Queues Routing */
+	void (*rx_queue_routing)(struct mac_device_info *hw,
+				 bool route_avcp_enable, u8 route_avcp_queue,
+				 bool route_ptp_enable, u8 route_ptp_queue,
+				 bool route_dcbcp_enable, u8 route_dcbcp_queue,
+				 bool route_up_enable, u8 route_up_queue,
+				 bool route_multi_broad_enable,
+				 u8 route_multi_broad_queue,
+				 bool route_tpqc_enable, u8 route_tpqc_queue);
 	/* Program RX Algorithms */
 	void (*prog_mtl_rx_algorithms)(struct mac_device_info *hw, u32 rx_alg);
 	/* Program TX Algorithms */
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4.h b/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
index a6c382d..93cc3f6 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
@@ -44,6 +44,24 @@
 #define GMAC_ADDR_HIGH(reg)		(0x300 + reg * 8)
 #define GMAC_ADDR_LOW(reg)		(0x304 + reg * 8)
 
+/* RX Queues Routing */
+#define GMAC_RXQCTRL_AVCPQ_MASK		GENMASK(2, 0)
+#define GMAC_RXQCTRL_AVCPQ_SHIFT	0
+#define GMAC_RXQCTRL_PTPQ_MASK		GENMASK(6, 4)
+#define GMAC_RXQCTRL_PTPQ_SHIFT		4
+#define GMAC_RXQCTRL_DCBCPQ_MASK	GENMASK(10, 8)
+#define GMAC_RXQCTRL_DCBCPQ_SHIFT	8
+#define GMAC_RXQCTRL_UPQ_MASK		GENMASK(14, 12)
+#define GMAC_RXQCTRL_UPQ_SHIFT		12
+#define GMAC_RXQCTRL_MCBCQ_MASK		GENMASK(18, 16)
+#define GMAC_RXQCTRL_MCBCQ_SHIFT	16
+#define GMAC_RXQCTRL_MCBCQEN		BIT(20)
+#define GMAC_RXQCTRL_MCBCQEN_SHIFT	20
+#define GMAC_RXQCTRL_TACPQE		BIT(21)
+#define GMAC_RXQCTRL_TACPQE_SHIFT	21
+#define GMAC_RXQCTRL_TPQC_MASK		GENMASK(24, 22)
+#define GMAC_RXQCTRL_TPQC_SHIFT		22
+
 /* MAC Packet Filtering */
 #define GMAC_PACKET_FILTER_PR		BIT(0)
 #define GMAC_PACKET_FILTER_HMC		BIT(2)
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
index 342f62a..8fc1f56 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
@@ -109,6 +109,68 @@ static void dwmac4_tx_queue_priority(struct mac_device_info *hw,
 	writel(value, ioaddr + base_register);
 }
 
+static void dwmac4_tx_queue_routing(struct mac_device_info *hw,
+				    bool route_avcp_enable,
+				    u8 route_avcp_queue,
+				    bool route_ptp_enable,
+				    u8 route_ptp_queue,
+				    bool route_dcbcp_enable,
+				    u8 route_dcbcp_queue,
+				    bool route_up_enable,
+				    u8 route_up_queue,
+				    bool route_multi_broad_enable,
+				    u8 route_multi_broad_queue,
+				    bool route_tpqc_enable,
+				    u8 route_tpqc_queue)
+{
+	void __iomem *ioaddr = hw->pcsr;
+	u32 value;
+
+	value = readl(ioaddr + GMAC_RXQ_CTRL1);
+
+	if (route_avcp_enable) {
+		value &= ~GMAC_RXQCTRL_AVCPQ_MASK;
+		value |= (route_avcp_queue << GMAC_RXQCTRL_AVCPQ_SHIFT) &
+			 GMAC_RXQCTRL_AVCPQ_MASK;
+		value &= ~GMAC_RXQCTRL_TACPQE;
+		value |= 0x1 << GMAC_RXQCTRL_TACPQE_SHIFT;
+	}
+
+	if (route_ptp_enable) {
+		value &= ~GMAC_RXQCTRL_PTPQ_MASK;
+		value |= (route_ptp_queue << GMAC_RXQCTRL_PTPQ_SHIFT) &
+			 GMAC_RXQCTRL_PTPQ_MASK;
+	}
+
+	if (route_dcbcp_enable) {
+		value &= ~GMAC_RXQCTRL_DCBCPQ_MASK;
+		value |= (route_dcbcp_queue << GMAC_RXQCTRL_DCBCPQ_SHIFT) &
+			 GMAC_RXQCTRL_DCBCPQ_MASK;
+	}
+
+	if (route_up_enable) {
+		value &= ~GMAC_RXQCTRL_UPQ_MASK;
+		value |= (route_up_queue << GMAC_RXQCTRL_UPQ_SHIFT) &
+			 GMAC_RXQCTRL_UPQ_MASK;
+	}
+
+	if (route_multi_broad_enable) {
+		value &= ~GMAC_RXQCTRL_MCBCQ_MASK;
+		value |= (route_multi_broad_queue << GMAC_RXQCTRL_MCBCQ_SHIFT) &
+			 GMAC_RXQCTRL_MCBCQ_MASK;
+		value &= ~GMAC_RXQCTRL_MCBCQEN;
+		value |= 0x1 << GMAC_RXQCTRL_MCBCQEN_SHIFT;
+	}
+
+	if (route_tpqc_enable) {
+		value &= ~GMAC_RXQCTRL_TPQC_MASK;
+		value |= (route_tpqc_queue << GMAC_RXQCTRL_TPQC_SHIFT) &
+			 GMAC_RXQCTRL_TPQC_MASK;
+	}
+
+	writel(value, ioaddr + GMAC_RXQ_CTRL1);
+}
+
 static void dwmac4_prog_mtl_rx_algorithms(struct mac_device_info *hw,
 					  u32 rx_alg)
 {
@@ -640,6 +702,7 @@ static const struct stmmac_ops dwmac4_ops = {
 	.rx_queue_enable = dwmac4_rx_queue_enable,
 	.rx_queue_prio = dwmac4_rx_queue_priority,
 	.tx_queue_prio = dwmac4_tx_queue_priority,
+	.rx_queue_routing = dwmac4_tx_queue_routing,
 	.prog_mtl_rx_algorithms = dwmac4_prog_mtl_rx_algorithms,
 	.prog_mtl_tx_algorithms = dwmac4_prog_mtl_tx_algorithms,
 	.set_mtl_tx_queue_weight = dwmac4_set_mtl_tx_queue_weight,
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 0f2c0d7..07c8ad1 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -2333,6 +2333,27 @@ static void stmmac_mac_config_tx_queues_prio(struct stmmac_priv *priv)
 }
 
 /**
+ *  stmmac_mac_config_rx_queues_routing - Configure RX Queue Routing
+ *  @priv: driver private structure
+ *  Description: It is used for configuring the RX queue routing
+ */
+static void stmmac_mac_config_rx_queues_routing(struct stmmac_priv *priv)
+{
+	priv->hw->mac->rx_queue_routing(priv->hw, priv->plat->route_avcp_enable,
+					priv->plat->route_avcp_queue,
+					priv->plat->route_ptp_enable,
+					priv->plat->route_ptp_queue,
+					priv->plat->route_dcbcp_enable,
+					priv->plat->route_dcbcp_queue,
+					priv->plat->route_up_enable,
+					priv->plat->route_up_queue,
+					priv->plat->route_multi_broad_enable,
+					priv->plat->route_multi_broad_queue,
+					priv->plat->route_tpqc_enable,
+					priv->plat->route_tpqc_queue);
+}
+
+/**
  *  stmmac_mtl_configuration - Configure MTL
  *  @priv: driver private structure
  *  Description: It is used for configurring MTL
@@ -2377,6 +2398,10 @@ static void stmmac_mtl_configuration(struct stmmac_priv *priv)
 	/* Set TX priorities */
 	if (tx_queues_count > 1 && priv->hw->mac->tx_queue_prio)
 		stmmac_mac_config_tx_queues_prio(priv);
+
+	/* Set RX routing */
+	if (rx_queues_count > 1 && priv->hw->mac->rx_queue_routing)
+		stmmac_mac_config_rx_queues_routing(priv);
 }
 
 /**
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
index ffe4fac..119ff0c 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
@@ -96,6 +96,14 @@ static void stmmac_default_data(struct plat_stmmacenet_data *plat)
 	/* Disable Priority config by default */
 	plat->tx_queues_cfg[0].use_prio = false;
 	plat->rx_queues_cfg[0].use_prio = false;
+
+	/* Disable RX queues routing by default */
+	plat->route_avcp_enable = false;
+	plat->route_ptp_enable = false;
+	plat->route_dcbcp_enable = false;
+	plat->route_up_enable = false;
+	plat->route_multi_broad_enable = false;
+	plat->route_tpqc_enable = false;
 }
 
 static int quark_default_data(struct plat_stmmacenet_data *plat,
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index 77b0468..5e82379 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -165,6 +165,55 @@ static void stmmac_mtl_setup(struct platform_device *pdev,
 	else
 		plat->rx_sched_algorithm = MTL_RX_ALGORITHM_SP;
 
+	/* RX routing configuration */
+	if (of_property_read_u8(rx_node, "snps,avcp-to-queue",
+				&plat->route_avcp_queue)) {
+		plat->route_avcp_queue = 0;
+		plat->route_avcp_enable = false;
+	} else {
+		plat->route_avcp_enable = true;
+	}
+
+	if (of_property_read_u8(rx_node, "snps,ptp-to-queue",
+				&plat->route_ptp_queue)) {
+		plat->route_ptp_queue = 0;
+		plat->route_ptp_enable = false;
+	} else {
+		plat->route_ptp_enable = true;
+	}
+
+	if (of_property_read_u8(rx_node, "snps,dcbcp-to-queue",
+				&plat->route_dcbcp_queue)) {
+		plat->route_dcbcp_queue = 0;
+		plat->route_dcbcp_enable = false;
+	} else {
+		plat->route_dcbcp_enable = true;
+	}
+
+	if (of_property_read_u8(rx_node, "snps,up-to-queue",
+				&plat->route_up_queue)) {
+		plat->route_up_queue = 0;
+		plat->route_up_enable = false;
+	} else {
+		plat->route_up_enable = true;
+	}
+
+	if (of_property_read_u8(rx_node, "snps,multi-broad-cast-queue",
+				&plat->route_multi_broad_queue)) {
+		plat->route_multi_broad_queue = 0;
+		plat->route_multi_broad_enable = false;
+	} else {
+		plat->route_multi_broad_enable = true;
+	}
+
+	if (of_property_read_u8(rx_node, "snps,tpqc-queue",
+				&plat->route_tpqc_queue)) {
+		plat->route_tpqc_queue = 0;
+		plat->route_tpqc_enable = false;
+	} else {
+		plat->route_tpqc_enable = true;
+	}
+
 	/* Processing individual RX queue config */
 	for_each_child_of_node(rx_node, q_node) {
 		if (queue >= plat->rx_queues_to_use)
diff --git a/include/linux/stmmac.h b/include/linux/stmmac.h
index b7d5e7a..8f5ebf5 100644
--- a/include/linux/stmmac.h
+++ b/include/linux/stmmac.h
@@ -171,6 +171,18 @@ struct plat_stmmacenet_data {
 	u8 tx_queues_to_use;
 	u8 rx_sched_algorithm;
 	u8 tx_sched_algorithm;
+	bool route_avcp_enable;
+	u8 route_avcp_queue;
+	bool route_ptp_enable;
+	u8 route_ptp_queue;
+	bool route_dcbcp_enable;
+	u8 route_dcbcp_queue;
+	bool route_up_enable;
+	u8 route_up_queue;
+	bool route_multi_broad_enable;
+	u8 route_multi_broad_queue;
+	bool route_tpqc_enable;
+	u8 route_tpqc_queue;
 	struct stmmac_rxq_cfg rx_queues_cfg[MTL_MAX_RX_QUEUES];
 	struct stmmac_txq_cfg tx_queues_cfg[MTL_MAX_TX_QUEUES];
 	void (*fix_mac_speed)(void *priv, unsigned int speed);
-- 
2.9.3
