From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: [PATCH v5 net-next 3/9] net: stmmac: configure tx queue weight
Date: Fri, 10 Mar 2017 18:24:53 +0000
Message-ID: <3626cff1a36adf882af9237f15aae0592911ce68.1489169213.git.jpinto@synopsys.com>
References: <cover.1489169213.git.jpinto@synopsys.com>
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        niklas.cassel@axis.com, netdev@vger.kernel.org,
        Joao Pinto <Joao.Pinto@synopsys.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from us01smtprelay-2.synopsys.com ([198.182.47.9]:56018 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933432AbdCJSZN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Mar 2017 13:25:13 -0500
In-Reply-To: <cover.1489169213.git.jpinto@synopsys.com>
In-Reply-To: <cover.1489169213.git.jpinto@synopsys.com>
References: <cover.1489169213.git.jpinto@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds TX queues weight programming.

Signed-off-by: Joao Pinto <jpinto@synopsys.com>
---
Changes v4->v5:
- patch title update (stmicro replaced by stmmac)
Changes v3->v4:
- variable init was simplified in some functions
Changes v2->v3:
- local variable declarations from longest to shortest line
Changes v1->v2:
- Just to keep up with patch-set version

 drivers/net/ethernet/stmicro/stmmac/common.h      |  3 +++
 drivers/net/ethernet/stmicro/stmmac/dwmac4.h      |  7 +++++++
 drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c | 12 ++++++++++++
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 20 ++++++++++++++++++++
 4 files changed, 42 insertions(+)

diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index 5a0a781..a25b2f8 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -459,6 +459,9 @@ struct stmmac_ops {
 	void (*prog_mtl_rx_algorithms)(struct mac_device_info *hw, u32 rx_alg);
 	/* Program TX Algorithms */
 	void (*prog_mtl_tx_algorithms)(struct mac_device_info *hw, u32 tx_alg);
+	/* Set MTL TX queues weight */
+	void (*set_mtl_tx_queue_weight)(struct mac_device_info *hw,
+					u32 weight, u32 queue);
 	/* Dump MAC registers */
 	void (*dump_regs)(struct mac_device_info *hw, u32 *reg_space);
 	/* Handle extra events on specific interrupts hw dependent */
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4.h b/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
index 748ab6f..7d77e78 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
@@ -211,6 +211,13 @@ enum power_event {
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
index f966755..fda6cfa 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
@@ -116,6 +116,17 @@ static void dwmac4_prog_mtl_tx_algorithms(struct mac_device_info *hw,
 	}
 }
 
+static void dwmac4_set_mtl_tx_queue_weight(struct mac_device_info *hw,
+					   u32 weight, u32 queue)
+{
+	void __iomem *ioaddr = hw->pcsr;
+	u32 value = readl(ioaddr + MTL_TXQX_WEIGHT_BASE_ADDR(queue));
+
+	value &= ~MTL_TXQ_WEIGHT_ISCQW_MASK;
+	value |= weight & MTL_TXQ_WEIGHT_ISCQW_MASK;
+	writel(value, ioaddr + MTL_TXQX_WEIGHT_BASE_ADDR(queue));
+}
+
 static void dwmac4_dump_regs(struct mac_device_info *hw, u32 *reg_space)
 {
 	void __iomem *ioaddr = hw->pcsr;
@@ -505,6 +516,7 @@ static const struct stmmac_ops dwmac4_ops = {
 	.rx_queue_enable = dwmac4_rx_queue_enable,
 	.prog_mtl_rx_algorithms = dwmac4_prog_mtl_rx_algorithms,
 	.prog_mtl_tx_algorithms = dwmac4_prog_mtl_tx_algorithms,
+	.set_mtl_tx_queue_weight = dwmac4_set_mtl_tx_queue_weight,
 	.dump_regs = dwmac4_dump_regs,
 	.host_irq_status = dwmac4_irq_status,
 	.flow_ctrl = dwmac4_flow_ctrl,
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index af57f8d..735540f 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1645,6 +1645,23 @@ static void stmmac_init_tx_coalesce(struct stmmac_priv *priv)
 }
 
 /**
+ *  stmmac_set_tx_queue_weight - Set TX queue weight
+ *  @priv: driver private structure
+ *  Description: It is used for setting TX queues weight
+ */
+static void stmmac_set_tx_queue_weight(struct stmmac_priv *priv)
+{
+	u32 tx_queues_count = priv->plat->tx_queues_to_use;
+	u32 weight;
+	u32 queue;
+
+	for (queue = 0; queue < tx_queues_count; queue++) {
+		weight = priv->plat->tx_queues_cfg[queue].weight;
+		priv->hw->mac->set_mtl_tx_queue_weight(priv->hw, weight, queue);
+	}
+}
+
+/**
  *  stmmac_mtl_configuration - Configure MTL
  *  @priv: driver private structure
  *  Description: It is used for configurring MTL
@@ -1654,6 +1671,9 @@ static void stmmac_mtl_configuration(struct stmmac_priv *priv)
 	u32 rx_queues_count = priv->plat->rx_queues_to_use;
 	u32 tx_queues_count = priv->plat->tx_queues_to_use;
 
+	if (tx_queues_count > 1 && priv->hw->mac->set_mtl_tx_queue_weight)
+		stmmac_set_tx_queue_weight(priv);
+
 	/* Configure MTL RX algorithms */
 	if (rx_queues_count > 1 && priv->hw->mac->prog_mtl_rx_algorithms)
 		priv->hw->mac->prog_mtl_rx_algorithms(priv->hw,
-- 
2.9.3
