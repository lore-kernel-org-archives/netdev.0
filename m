From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: [PATCH v3 net-next 1/9] net: stmicro: multiple queues dt configuration
Date: Thu,  9 Mar 2017 11:03:09 +0000
Message-ID: <a0ca37b5464af84c370e2f0bf25e88cd981e7382.1489055407.git.jpinto@synopsys.com>
References: <cover.1489055407.git.jpinto@synopsys.com>
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        niklas.cassel@axis.com, netdev@vger.kernel.org,
        Joao Pinto <Joao.Pinto@synopsys.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay2.synopsys.com ([198.182.60.111]:53029 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753583AbdCILDZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Mar 2017 06:03:25 -0500
In-Reply-To: <cover.1489055407.git.jpinto@synopsys.com>
In-Reply-To: <cover.1489055407.git.jpinto@synopsys.com>
References: <cover.1489055407.git.jpinto@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the multiple queues configuration in the Device Tree.
It was also created a set of structures to keep the RX and TX queues
configurations to be used in the driver.

Signed-off-by: Joao Pinto <jpinto@synopsys.com>
---
Changes v2->v3:
- Just to keep up with patch-set version
Changes v1->v2:
- RX and TX queues child nodes had bad handle

 Documentation/devicetree/bindings/net/stmmac.txt   | 40 ++++++++++
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  | 91 ++++++++++++++++++++++
 include/linux/stmmac.h                             | 30 +++++++
 3 files changed, 161 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/stmmac.txt b/Documentation/devicetree/bindings/net/stmmac.txt
index d3bfc2b..4107e67 100644
--- a/Documentation/devicetree/bindings/net/stmmac.txt
+++ b/Documentation/devicetree/bindings/net/stmmac.txt
@@ -72,6 +72,27 @@ Optional properties:
 	- snps,mb: mixed-burst
 	- snps,rb: rebuild INCRx Burst
 - mdio: with compatible = "snps,dwmac-mdio", create and register mdio bus.
+- Multiple RX Queues parameters: below the list of all the parameters to
+				 configure the multiple RX queues:
+	- snps,rx-queues-to-use: number of RX queues to be used in the driver
+	- Choose one of these RX scheduling algorithms:
+		- snps,rx-sched-sp: Strict priority
+		- snps,rx-sched-wsp: Weighted Strict priority
+	- For each RX queue
+		- Choose one of these modes:
+			- snps,dcb-algorithm: Queue to be enabled as DCB
+			- snps,avb-algorithm: Queue to be enabled as AVB
+		- snps,map-to-dma-channel: Channel to map
+- Multiple TX Queues parameters: below the list of all the parameters to
+				 configure the multiple TX queues:
+	- snps,tx-queues-to-use: number of TX queues to be used in the driver
+	- Choose one of these TX scheduling algorithms:
+		- snps,tx-sched-wrr: Weighted Round Robin
+		- snps,tx-sched-wfq: Weighted Fair Queuing
+		- snps,tx-sched-dwrr: Deficit Weighted Round Robin
+		- snps,tx-sched-sp: Strict priority
+	- For each TX queue
+		- snps,weight: TX queue weight (if using a weighted algorithm)
 
 Examples:
 
@@ -81,6 +102,23 @@ Examples:
 		snps,blen = <256 128 64 32 0 0 0>;
 	};
 
+	mtl_rx_setup: rx-queues-config {
+		snps,rx-queues-to-use = <1>;
+		snps,rx-sched-sp;
+		queue0 {
+			snps,dcb-algorithm;
+			snps,map-to-dma-channel = <0x0>;
+		};
+	};
+
+	mtl_tx_setup: tx-queues-config {
+		snps,tx-queues-to-use = <1>;
+		snps,tx-sched-wrr;
+		queue0 {
+			snps,weight = <0x10>;
+		};
+	};
+
 	gmac0: ethernet@e0800000 {
 		compatible = "st,spear600-gmac";
 		reg = <0xe0800000 0x8000>;
@@ -104,4 +142,6 @@ Examples:
 			phy1: ethernet-phy@0 {
 			};
 		};
+		snps,mtl-rx-config = <&mtl_rx_setup>;
+		snps,mtl-tx-config = <&mtl_tx_setup>;
 	};
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index 433a842..ff6af8d 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -132,6 +132,95 @@ static struct stmmac_axi *stmmac_axi_setup(struct platform_device *pdev)
 }
 
 /**
+ * stmmac_mtl_setup - parse DT parameters for multiple queues configuration
+ * @pdev: platform device
+ */
+static void stmmac_mtl_setup(struct platform_device *pdev,
+			     struct plat_stmmacenet_data *plat)
+{
+	struct device_node *q_node;
+	struct device_node *rx_node;
+	struct device_node *tx_node;
+	u8 queue = 0;
+
+	rx_node = of_parse_phandle(pdev->dev.of_node, "snps,mtl-rx-config", 0);
+	if (!rx_node)
+		return;
+
+	tx_node = of_parse_phandle(pdev->dev.of_node, "snps,mtl-tx-config", 0);
+	if (!tx_node) {
+		of_node_put(rx_node);
+		return;
+	}
+
+	/* Processing RX queues common config */
+	if (of_property_read_u8(rx_node, "snps,rx-queues-to-use",
+				&plat->rx_queues_to_use))
+		plat->rx_queues_to_use = 1;
+
+	if (of_property_read_bool(rx_node, "snps,rx-sched-sp"))
+		plat->rx_sched_algorithm = MTL_RX_ALGORITHM_SP;
+	else if (of_property_read_bool(rx_node, "snps,rx-sched-wsp"))
+		plat->rx_sched_algorithm = MTL_RX_ALGORITHM_WSP;
+	else
+		plat->rx_sched_algorithm = MTL_RX_ALGORITHM_SP;
+
+	/* Processing individual RX queue config */
+	for_each_child_of_node(rx_node, q_node) {
+		if (queue >= plat->rx_queues_to_use)
+			break;
+
+		if (of_property_read_bool(q_node, "snps,dcb-algorithm"))
+			plat->rx_queues_cfg[queue].mode_to_use = MTL_RX_DCB;
+		else if (of_property_read_bool(q_node, "snps,avb-algorithm"))
+			plat->rx_queues_cfg[queue].mode_to_use = MTL_RX_AVB;
+		else
+			plat->rx_queues_cfg[queue].mode_to_use = MTL_RX_DCB;
+
+		if (of_property_read_u8(q_node, "snps,map-to-dma-channel",
+					&plat->rx_queues_cfg[queue].chan))
+			plat->rx_queues_cfg[queue].chan = queue;
+		/* TODO: Dynamic mapping to be included in the future */
+
+		queue++;
+	}
+
+	/* Processing TX queues common config */
+	if (of_property_read_u8(tx_node, "snps,tx-queues-to-use",
+				&plat->tx_queues_to_use))
+		plat->tx_queues_to_use = 1;
+
+	if (of_property_read_bool(tx_node, "snps,tx-sched-wrr"))
+		plat->tx_sched_algorithm = MTL_TX_ALGORITHM_WRR;
+	else if (of_property_read_bool(tx_node, "snps,tx-sched-wfq"))
+		plat->tx_sched_algorithm = MTL_TX_ALGORITHM_WFQ;
+	else if (of_property_read_bool(tx_node, "snps,tx-sched-dwrr"))
+		plat->tx_sched_algorithm = MTL_TX_ALGORITHM_DWRR;
+	else if (of_property_read_bool(tx_node, "snps,tx-sched-sp"))
+		plat->tx_sched_algorithm = MTL_TX_ALGORITHM_SP;
+	else
+		plat->tx_sched_algorithm = MTL_TX_ALGORITHM_SP;
+
+	queue = 0;
+
+	/* Processing individual TX queue config */
+	for_each_child_of_node(tx_node, q_node) {
+		if (queue >= plat->tx_queues_to_use)
+			break;
+
+		if (of_property_read_u8(q_node, "snps,weight",
+					&plat->tx_queues_cfg[queue].weight))
+			plat->tx_queues_cfg[queue].weight = 0x10 + queue;
+
+		queue++;
+	}
+
+	of_node_put(rx_node);
+	of_node_put(tx_node);
+	of_node_put(q_node);
+}
+
+/**
  * stmmac_dt_phy - parse device-tree driver parameters to allocate PHY resources
  * @plat: driver data platform structure
  * @np: device tree node
@@ -340,6 +429,8 @@ stmmac_probe_config_dt(struct platform_device *pdev, const char **mac)
 
 	plat->axi = stmmac_axi_setup(pdev);
 
+	stmmac_mtl_setup(pdev, plat);
+
 	/* clock setup */
 	plat->stmmac_clk = devm_clk_get(&pdev->dev,
 					STMMAC_RESOURCE_NAME);
diff --git a/include/linux/stmmac.h b/include/linux/stmmac.h
index fc273e9..266ff2a 100644
--- a/include/linux/stmmac.h
+++ b/include/linux/stmmac.h
@@ -28,6 +28,9 @@
 
 #include <linux/platform_device.h>
 
+#define MTL_MAX_RX_QUEUES	8
+#define MTL_MAX_TX_QUEUES	8
+
 #define STMMAC_RX_COE_NONE	0
 #define STMMAC_RX_COE_TYPE1	1
 #define STMMAC_RX_COE_TYPE2	2
@@ -44,6 +47,18 @@
 #define	STMMAC_CSR_150_250M	0x4	/* MDC = clk_scr_i/102 */
 #define	STMMAC_CSR_250_300M	0x5	/* MDC = clk_scr_i/122 */
 
+/* MTL algorithms identifiers */
+#define MTL_TX_ALGORITHM_WRR	0x0
+#define MTL_TX_ALGORITHM_WFQ	0x1
+#define MTL_TX_ALGORITHM_DWRR	0x2
+#define MTL_TX_ALGORITHM_SP	0x3
+#define MTL_RX_ALGORITHM_SP	0x4
+#define MTL_RX_ALGORITHM_WSP	0x5
+
+/* RX Queue Mode */
+#define MTL_RX_DCB		0x0
+#define MTL_RX_AVB		0x1
+
 /* The MDC clock could be set higher than the IEEE 802.3
  * specified frequency limit 0f 2.5 MHz, by programming a clock divider
  * of value different than the above defined values. The resultant MDIO
@@ -109,6 +124,15 @@ struct stmmac_axi {
 	bool axi_rb;
 };
 
+struct stmmac_rxq_cfg {
+	u8 mode_to_use;
+	u8 chan;
+};
+
+struct stmmac_txq_cfg {
+	u8 weight;
+};
+
 struct plat_stmmacenet_data {
 	int bus_id;
 	int phy_addr;
@@ -133,6 +157,12 @@ struct plat_stmmacenet_data {
 	int unicast_filter_entries;
 	int tx_fifo_size;
 	int rx_fifo_size;
+	u8 rx_queues_to_use;
+	u8 tx_queues_to_use;
+	u8 rx_sched_algorithm;
+	u8 tx_sched_algorithm;
+	struct stmmac_rxq_cfg rx_queues_cfg[MTL_MAX_RX_QUEUES];
+	struct stmmac_txq_cfg tx_queues_cfg[MTL_MAX_TX_QUEUES];
 	void (*fix_mac_speed)(void *priv, unsigned int speed);
 	int (*init)(struct platform_device *pdev, void *priv);
 	void (*exit)(struct platform_device *pdev, void *priv);
-- 
2.9.3
