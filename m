From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: [PATCH v2 net-next] net: stmmac: add drop transmit status feature
Date: Wed, 12 Apr 2017 10:26:20 +0100
Message-ID: <f43dda26d3c43fdf19d6872306741c16b635558c.1491989111.git.jpinto@synopsys.com>
Cc: netdev@vger.kernel.org, Joao Pinto <Joao.Pinto@synopsys.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay4.synopsys.com ([198.182.47.9]:50460 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753036AbdDLJ00 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Apr 2017 05:26:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the Drop Transmit Status bit is set, the Tx packet status
received from the MAC is dropped in the MTL. When this bit is reset,
the Tx packet status received from the MAC is forwarded to the
application. This feature will cause a performance improvement.

Signed-off-by: Joao Pinto <jpinto@synopsys.com>
---
changes v1->v2:
- removed mask from dwmac4_enable_tx_drop()

 Documentation/devicetree/bindings/net/stmmac.txt      |  1 +
 drivers/net/ethernet/stmicro/stmmac/common.h          |  2 ++
 drivers/net/ethernet/stmicro/stmmac/dwmac4.h          |  1 +
 drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c     | 12 ++++++++++++
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c     |  3 +++
 drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c |  2 ++
 include/linux/stmmac.h                                |  1 +
 7 files changed, 22 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/stmmac.txt b/Documentation/devicetree/bindings/net/stmmac.txt
index f652b0c..dbcb2cc 100644
--- a/Documentation/devicetree/bindings/net/stmmac.txt
+++ b/Documentation/devicetree/bindings/net/stmmac.txt
@@ -60,6 +60,7 @@ Optional properties:
 		 and MAC2MAC connection.
 - snps,tso: this enables the TSO feature otherwise it will be managed by
 		 MAC HW capability register. Only for GMAC4 and newer.
+- snps,drop-tx-status: this enables drop tx status
 - AXI BUS Mode parameters: below the list of all the parameters to program the
 			   AXI register inside the DMA module:
 	- snps,lpi_en: enable Low Power Interface
diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index 90d28bc..312f9670 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -487,6 +487,8 @@ struct stmmac_ops {
 	/* RX Queues Routing */
 	void (*rx_queue_routing)(struct mac_device_info *hw, u8 packet,
 				 u32 queue);
+	/* Enable TX drop */
+	void (*enable_tx_drop)(struct mac_device_info *hw);
 	/* Program RX Algorithms */
 	void (*prog_mtl_rx_algorithms)(struct mac_device_info *hw, u32 rx_alg);
 	/* Program TX Algorithms */
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4.h b/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
index d74cedf..56ba01a 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
@@ -202,6 +202,7 @@ enum power_event {
 #define MTL_OPERATION_RAA		BIT(2)
 #define MTL_OPERATION_RAA_SP		(0x0 << 2)
 #define MTL_OPERATION_RAA_WSP		(0x1 << 2)
+#define MTL_OPERATION_DTXSTS		BIT(1)
 
 #define MTL_INT_STATUS			0x00000c20
 #define MTL_INT_QX(x)			BIT(x)
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
index 48793f2..e9bc51c 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
@@ -142,6 +142,16 @@ static void dwmac4_tx_queue_routing(struct mac_device_info *hw,
 	writel(value, ioaddr + GMAC_RXQ_CTRL1);
 }
 
+static void dwmac4_enable_tx_drop(struct mac_device_info *hw)
+{
+	void __iomem *ioaddr = hw->pcsr;
+	u32 value = readl(ioaddr + MTL_OPERATION_MODE);
+
+	value |= MTL_OPERATION_DTXSTS;
+
+	writel(value, ioaddr + MTL_OPERATION_MODE);
+}
+
 static void dwmac4_prog_mtl_rx_algorithms(struct mac_device_info *hw,
 					  u32 rx_alg)
 {
@@ -675,6 +685,7 @@ static const struct stmmac_ops dwmac4_ops = {
 	.rx_queue_prio = dwmac4_rx_queue_priority,
 	.tx_queue_prio = dwmac4_tx_queue_priority,
 	.rx_queue_routing = dwmac4_tx_queue_routing,
+	.enable_tx_drop = dwmac4_enable_tx_drop,
 	.prog_mtl_rx_algorithms = dwmac4_prog_mtl_rx_algorithms,
 	.prog_mtl_tx_algorithms = dwmac4_prog_mtl_tx_algorithms,
 	.set_mtl_tx_queue_weight = dwmac4_set_mtl_tx_queue_weight,
@@ -706,6 +717,7 @@ static const struct stmmac_ops dwmac410_ops = {
 	.rx_queue_prio = dwmac4_rx_queue_priority,
 	.tx_queue_prio = dwmac4_tx_queue_priority,
 	.rx_queue_routing = dwmac4_tx_queue_routing,
+	.enable_tx_drop = dwmac4_enable_tx_drop,
 	.prog_mtl_rx_algorithms = dwmac4_prog_mtl_rx_algorithms,
 	.prog_mtl_tx_algorithms = dwmac4_prog_mtl_tx_algorithms,
 	.set_mtl_tx_queue_weight = dwmac4_set_mtl_tx_queue_weight,
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index a89f76b..bbde5b2 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -2368,6 +2368,9 @@ static void stmmac_mtl_configuration(struct stmmac_priv *priv)
 	u32 rx_queues_count = priv->plat->rx_queues_to_use;
 	u32 tx_queues_count = priv->plat->tx_queues_to_use;
 
+	if (priv->plat->drop_tx_status)
+		priv->hw->mac->enable_tx_drop(priv->hw);
+
 	if (tx_queues_count > 1 && priv->hw->mac->set_mtl_tx_queue_weight)
 		stmmac_set_tx_queue_weight(priv);
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index 7fc3a1e..d15e650 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -451,6 +451,8 @@ stmmac_probe_config_dt(struct platform_device *pdev, const char **mac)
 		plat->has_gmac = 0;
 		plat->pmt = 1;
 		plat->tso_en = of_property_read_bool(np, "snps,tso");
+		plat->drop_tx_status =
+			of_property_read_bool(np, "snps,drop-tx-status");
 	}
 
 	if (of_device_is_compatible(np, "snps,dwmac-3.610") ||
diff --git a/include/linux/stmmac.h b/include/linux/stmmac.h
index 3921cb9..fe7940c 100644
--- a/include/linux/stmmac.h
+++ b/include/linux/stmmac.h
@@ -186,6 +186,7 @@ struct plat_stmmacenet_data {
 	struct stmmac_axi *axi;
 	int has_gmac4;
 	bool tso_en;
+	bool drop_tx_status;
 	int mac_port_sel_speed;
 	bool en_tx_lpi_clockgating;
 };
-- 
2.9.3
