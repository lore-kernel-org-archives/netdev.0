From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: [PATCH v2 net-next 3/3] net: stmmac: RX queue routing configuration
Date: Fri, 17 Mar 2017 16:11:07 +0000
Message-ID: <0ec573a53fd85138763ec384524834198198898e.1489766674.git.jpinto@synopsys.com>
References: <cover.1489766674.git.jpinto@synopsys.com>
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        Joao Pinto <Joao.Pinto@synopsys.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from us01smtprelay-2.synopsys.com ([198.182.60.111]:46980 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751082AbdCQQSm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Mar 2017 12:18:42 -0400
In-Reply-To: <cover.1489766674.git.jpinto@synopsys.com>
In-Reply-To: <cover.1489766674.git.jpinto@synopsys.com>
References: <cover.1489766674.git.jpinto@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the configuration of RX queues' routing.

Signed-off-by: Joao Pinto <jpinto@synopsys.com>
---
changes v1->v2:
- DT bindings were changed to bool
- DT parsing was simplified, improving routing parameter scalability

 Documentation/devicetree/bindings/net/stmmac.txt   |  6 ++++
 drivers/net/ethernet/stmicro/stmmac/common.h       | 17 +++++++++++
 drivers/net/ethernet/stmicro/stmmac/dwmac4.h       | 16 ++++++++++
 drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c  | 34 ++++++++++++++++++++++
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  | 25 ++++++++++++++++
 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c   |  3 ++
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  | 14 +++++++++
 include/linux/stmmac.h                             |  1 +
 8 files changed, 116 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/stmmac.txt b/Documentation/devicetree/bindings/net/stmmac.txt
index d11bd09..784d988 100644
--- a/Documentation/devicetree/bindings/net/stmmac.txt
+++ b/Documentation/devicetree/bindings/net/stmmac.txt
@@ -83,6 +83,12 @@ Optional properties:
 			- snps,dcb-algorithm: Queue to be enabled as DCB
 			- snps,avb-algorithm: Queue to be enabled as AVB
 		- snps,map-to-dma-channel: Channel to map
+		- Specifiy specific packet routing:
+			- snps,route-avcp: AV Untagged Control packets
+			- snps,route-ptp: PTP Packets
+			- snps,route-dcbcp: DCB Control Packets
+			- snps,route-up: Untagged Packets
+			- snps,route-multi-broad: Multicast & Broadcast Packets
 		- snps,priority: RX queue priority (Range: 0x0 to 0xF)
 - Multiple TX Queues parameters: below the list of all the parameters to
 				 configure the multiple TX queues:
diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index e0b31e7..572cf8b 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -246,6 +246,15 @@ struct stmmac_extra_stats {
 #define STMMAC_TX_MAX_FRAMES	256
 #define STMMAC_TX_FRAMES	64
 
+/* Packets types */
+enum packets_types {
+	PACKET_AVCPQ = 0x1, /* AV Untagged Control packets */
+	PACKET_PTPQ = 0x2, /* PTP Packets */
+	PACKET_DCBCPQ = 0x3, /* DCB Control Packets */
+	PACKET_UPQ = 0x4, /* Untagged Packets */
+	PACKET_MCBCQ = 0x5, /* Multicast & Broadcast Packets */
+};
+
 /* Rx IPC status */
 enum rx_frame_status {
 	good_frame = 0x0,
@@ -473,6 +482,9 @@ struct stmmac_ops {
 	void (*rx_queue_prio)(struct mac_device_info *hw, u32 prio, u32 queue);
 	/* TX Queues Priority */
 	void (*tx_queue_prio)(struct mac_device_info *hw, u32 prio, u32 queue);
+	/* RX Queues Routing */
+	void (*rx_queue_routing)(struct mac_device_info *hw, u8 packet,
+				 u32 queue);
 	/* Program RX Algorithms */
 	void (*prog_mtl_rx_algorithms)(struct mac_device_info *hw, u32 rx_alg);
 	/* Program TX Algorithms */
@@ -581,6 +593,11 @@ struct mac_device_info {
 	unsigned int ps;
 };
 
+struct stmmac_rx_routing {
+	u32 reg_mask;
+	u32 reg_shift;
+};
+
 struct mac_device_info *dwmac1000_setup(void __iomem *ioaddr, int mcbins,
 					int perfect_uc_entries,
 					int *synopsys_id);
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4.h b/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
index a6c382d..d74cedf 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
@@ -44,6 +44,22 @@
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
+
 /* MAC Packet Filtering */
 #define GMAC_PACKET_FILTER_PR		BIT(0)
 #define GMAC_PACKET_FILTER_HMC		BIT(2)
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
index 342f62a..40ce202 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
@@ -109,6 +109,39 @@ static void dwmac4_tx_queue_priority(struct mac_device_info *hw,
 	writel(value, ioaddr + base_register);
 }
 
+static void dwmac4_tx_queue_routing(struct mac_device_info *hw,
+				    u8 packet, u32 queue)
+{
+	void __iomem *ioaddr = hw->pcsr;
+	u32 value;
+
+	const struct stmmac_rx_routing route_possibilities[] = {
+		{ GMAC_RXQCTRL_AVCPQ_MASK, GMAC_RXQCTRL_AVCPQ_SHIFT },
+		{ GMAC_RXQCTRL_PTPQ_MASK, GMAC_RXQCTRL_PTPQ_SHIFT },
+		{ GMAC_RXQCTRL_DCBCPQ_MASK, GMAC_RXQCTRL_DCBCPQ_SHIFT },
+		{ GMAC_RXQCTRL_UPQ_MASK, GMAC_RXQCTRL_UPQ_SHIFT },
+		{ GMAC_RXQCTRL_MCBCQ_MASK, GMAC_RXQCTRL_MCBCQ_SHIFT },
+	};
+
+	value = readl(ioaddr + GMAC_RXQ_CTRL1);
+
+	/* routing configuration */
+	value &= ~route_possibilities[packet - 1].reg_mask;
+	value |= (queue << route_possibilities[packet-1].reg_shift) &
+		 route_possibilities[packet - 1].reg_mask;
+
+	/* some packets require extra ops */
+	if (packet == PACKET_AVCPQ) {
+		value &= ~GMAC_RXQCTRL_TACPQE;
+		value |= 0x1 << GMAC_RXQCTRL_TACPQE_SHIFT;
+	} else if (packet == PACKET_MCBCQ) {
+		value &= ~GMAC_RXQCTRL_MCBCQEN;
+		value |= 0x1 << GMAC_RXQCTRL_MCBCQEN_SHIFT;
+	}
+
+	writel(value, ioaddr + GMAC_RXQ_CTRL1);
+}
+
 static void dwmac4_prog_mtl_rx_algorithms(struct mac_device_info *hw,
 					  u32 rx_alg)
 {
@@ -640,6 +673,7 @@ static const struct stmmac_ops dwmac4_ops = {
 	.rx_queue_enable = dwmac4_rx_queue_enable,
 	.rx_queue_prio = dwmac4_rx_queue_priority,
 	.tx_queue_prio = dwmac4_tx_queue_priority,
+	.rx_queue_routing = dwmac4_tx_queue_routing,
 	.prog_mtl_rx_algorithms = dwmac4_prog_mtl_rx_algorithms,
 	.prog_mtl_tx_algorithms = dwmac4_prog_mtl_tx_algorithms,
 	.set_mtl_tx_queue_weight = dwmac4_set_mtl_tx_queue_weight,
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 0f2c0d7..531bf1d 100644
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
+	u32 rx_queues_count = priv->plat->rx_queues_to_use;
+	u32 queue;
+	u8 packet;
+
+	for (queue = 0; queue < rx_queues_count; queue++) {
+		/* no specific packet type routing specified for the queue */
+		if (priv->plat->rx_queues_cfg[queue].pkt_route == 0x0)
+			continue;
+
+		packet = priv->plat->rx_queues_cfg[queue].pkt_route;
+		priv->hw->mac->rx_queue_prio(priv->hw, packet, queue);
+	}
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
index ffe4fac..a224d7b 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
@@ -96,6 +96,9 @@ static void stmmac_default_data(struct plat_stmmacenet_data *plat)
 	/* Disable Priority config by default */
 	plat->tx_queues_cfg[0].use_prio = false;
 	plat->rx_queues_cfg[0].use_prio = false;
+
+	/* Disable RX queues routing by default */
+	plat->rx_queues_cfg[0].pkt_route = 0x0;
 }
 
 static int quark_default_data(struct plat_stmmacenet_data *plat,
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index 77b0468..f5c8b1b 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -190,6 +190,20 @@ static void stmmac_mtl_setup(struct platform_device *pdev,
 			plat->rx_queues_cfg[queue].use_prio = true;
 		}
 
+		/* RX queue specific packet type routing */
+		if (of_property_read_bool(q_node, "snps,route-avcp"))
+			plat->rx_queues_cfg[queue].pkt_route = PACKET_AVCPQ;
+		else if (of_property_read_bool(q_node, "snps,route-ptp"))
+			plat->rx_queues_cfg[queue].pkt_route = PACKET_PTPQ;
+		else if (of_property_read_bool(q_node, "snps,route-dcbcp"))
+			plat->rx_queues_cfg[queue].pkt_route = PACKET_DCBCPQ;
+		else if (of_property_read_bool(q_node, "snps,route-up"))
+			plat->rx_queues_cfg[queue].pkt_route = PACKET_UPQ;
+		else if (of_property_read_bool(q_node, "snps,route-multi-broad"))
+			plat->rx_queues_cfg[queue].pkt_route = PACKET_MCBCQ;
+		else
+			plat->rx_queues_cfg[queue].pkt_route = 0x0;
+
 		queue++;
 	}
 
diff --git a/include/linux/stmmac.h b/include/linux/stmmac.h
index b7d5e7a..cd98ee2 100644
--- a/include/linux/stmmac.h
+++ b/include/linux/stmmac.h
@@ -127,6 +127,7 @@ struct stmmac_axi {
 struct stmmac_rxq_cfg {
 	u8 mode_to_use;
 	u8 chan;
+	u8 pkt_route;
 	bool use_prio;
 	u32 prio;
 };
-- 
2.9.3
