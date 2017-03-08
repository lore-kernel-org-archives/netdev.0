From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: [PATCH v2 net-next 3/8] net: stmicro: configure tx queue weight
Date: Wed,  8 Mar 2017 12:22:43 +0000
Message-ID: <42258a298d690256c16dec16d0ce169bd04340d9.1488975090.git.jpinto@synopsys.com>
References: <cover.1488975090.git.jpinto@synopsys.com>
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org, Joao Pinto <Joao.Pinto@synopsys.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay.synopsys.com ([198.182.60.111]:60670 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752653AbdCHMsU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Mar 2017 07:48:20 -0500
In-Reply-To: <cover.1488975090.git.jpinto@synopsys.com>
In-Reply-To: <cover.1488975090.git.jpinto@synopsys.com>
References: <cover.1488975090.git.jpinto@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds TX queues weight programming.

Signed-off-by: Joao Pinto <jpinto@synopsys.com>
---
changes v1->v2:
- Just to keep up with patch-set version

 drivers/net/ethernet/stmicro/stmmac/common.h      |  3 +++
 drivers/net/ethernet/stmicro/stmmac/dwmac4.h      |  7 +++++++
 drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c | 13 +++++++++++++
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 20 ++++++++++++++++++++
 4 files changed, 43 insertions(+)

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
index 7503b8e..ccbfa31 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
@@ -116,6 +116,18 @@ static void dwmac4_prog_mtl_tx_algorithms(struct mac_device_info *hw,
 	}
 }
 
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
 static void dwmac4_dump_regs(struct mac_device_info *hw, u32 *reg_space)
 {
 	void __iomem *ioaddr = hw->pcsr;
@@ -505,6 +517,7 @@ static const struct stmmac_ops dwmac4_ops = {
 	.rx_queue_enable = dwmac4_rx_queue_enable,
 	.prog_mtl_rx_algorithms = dwmac4_prog_mtl_rx_algorithms,
 	.prog_mtl_tx_algorithms = dwmac4_prog_mtl_tx_algorithms,
+	.set_mtl_tx_queue_weight = dwmac4_set_mtl_tx_queue_weight,
 	.dump_regs = dwmac4_dump_regs,
 	.host_irq_status = dwmac4_irq_status,
 	.flow_ctrl = dwmac4_flow_ctrl,
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index af57f8d..df3b1ee 100644
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
+	u32 queue = 0;
+	u32 weight = 0;
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
