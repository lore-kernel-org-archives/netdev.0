From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: [PATCH v5 net-next 5/9] net: stmmac: mapping mtl rx to dma channel
Date: Fri, 10 Mar 2017 18:24:55 +0000
Message-ID: <0983a4554047407ea6a6fc7948caa544d5dd4dd1.1489169213.git.jpinto@synopsys.com>
References: <cover.1489169213.git.jpinto@synopsys.com>
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        niklas.cassel@axis.com, netdev@vger.kernel.org,
        Joao Pinto <Joao.Pinto@synopsys.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from us01smtprelay-2.synopsys.com ([198.182.60.111]:51950 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933428AbdCJSZW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Mar 2017 13:25:22 -0500
In-Reply-To: <cover.1489169213.git.jpinto@synopsys.com>
In-Reply-To: <cover.1489169213.git.jpinto@synopsys.com>
References: <cover.1489169213.git.jpinto@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the functionality of RX queue to dma channel mapping
based on configuration.

Signed-off-by: Joao Pinto <jpinto@synopsys.com>
---
Changes v4->v5:
- patch title update (stmicro replaced by stmmac)
Changes v3->v4:
- variable init was simplified in some functions
Changes v1->v3:
- Just to keep up with patch-set version

 drivers/net/ethernet/stmicro/stmmac/common.h      |  2 ++
 drivers/net/ethernet/stmicro/stmmac/dwmac4.h      |  7 +++++++
 drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c | 25 +++++++++++++++++++++++
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 21 +++++++++++++++++++
 4 files changed, 55 insertions(+)

diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index ad89c47..32f5f25 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -462,6 +462,8 @@ struct stmmac_ops {
 	/* Set MTL TX queues weight */
 	void (*set_mtl_tx_queue_weight)(struct mac_device_info *hw,
 					u32 weight, u32 queue);
+	/* RX MTL queue to RX dma mapping */
+	void (*map_mtl_to_dma)(struct mac_device_info *hw, u32 queue, u32 chan);
 	/* Dump MAC registers */
 	void (*dump_regs)(struct mac_device_info *hw, u32 *reg_space);
 	/* Handle extra events on specific interrupts hw dependent */
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4.h b/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
index 7d77e78..9dd8ac1 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
@@ -174,6 +174,13 @@ enum power_event {
 #define MTL_INT_STATUS			0x00000c20
 #define MTL_INT_Q0			BIT(0)
 
+#define MTL_RXQ_DMA_MAP0		0x00000c30 /* queue 0 to 3 */
+#define MTL_RXQ_DMA_MAP1		0x00000c34 /* queue 4 to 7 */
+#define MTL_RXQ_DMA_Q04MDMACH_MASK	GENMASK(3, 0)
+#define MTL_RXQ_DMA_Q04MDMACH(x)	((x) << 0)
+#define MTL_RXQ_DMA_QXMDMACH_MASK(x)	GENMASK(11 + (8 * ((x) - 1)), 8 * (x))
+#define MTL_RXQ_DMA_QXMDMACH(chan, q)	((chan) << (8 * (q)))
+
 #define MTL_CHAN_BASE_ADDR		0x00000d00
 #define MTL_CHAN_BASE_OFFSET		0x40
 #define MTL_CHANX_BASE_ADDR(x)		(MTL_CHAN_BASE_ADDR + \
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
index 21a696e..e9b153f 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
@@ -131,6 +131,30 @@ static void dwmac4_set_mtl_tx_queue_weight(struct mac_device_info *hw,
 	writel(value, ioaddr + MTL_TXQX_WEIGHT_BASE_ADDR(queue));
 }
 
+static void dwmac4_map_mtl_dma(struct mac_device_info *hw, u32 queue, u32 chan)
+{
+	void __iomem *ioaddr = hw->pcsr;
+	u32 value;
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
 static void dwmac4_dump_regs(struct mac_device_info *hw, u32 *reg_space)
 {
 	void __iomem *ioaddr = hw->pcsr;
@@ -521,6 +545,7 @@ static const struct stmmac_ops dwmac4_ops = {
 	.prog_mtl_rx_algorithms = dwmac4_prog_mtl_rx_algorithms,
 	.prog_mtl_tx_algorithms = dwmac4_prog_mtl_tx_algorithms,
 	.set_mtl_tx_queue_weight = dwmac4_set_mtl_tx_queue_weight,
+	.map_mtl_to_dma = dwmac4_map_mtl_dma,
 	.dump_regs = dwmac4_dump_regs,
 	.host_irq_status = dwmac4_irq_status,
 	.flow_ctrl = dwmac4_flow_ctrl,
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index c3e2dbf..619bcc6 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1657,6 +1657,23 @@ static void stmmac_set_tx_queue_weight(struct stmmac_priv *priv)
 }
 
 /**
+ *  stmmac_rx_queue_dma_chan_map - Map RX queue to RX dma channel
+ *  @priv: driver private structure
+ *  Description: It is used for mapping RX queues to RX dma channels
+ */
+static void stmmac_rx_queue_dma_chan_map(struct stmmac_priv *priv)
+{
+	u32 rx_queues_count = priv->plat->rx_queues_to_use;
+	u32 queue;
+	u32 chan;
+
+	for (queue = 0; queue < rx_queues_count; queue++) {
+		chan = priv->plat->rx_queues_cfg[queue].chan;
+		priv->hw->mac->map_mtl_to_dma(priv->hw, queue, chan);
+	}
+}
+
+/**
  *  stmmac_mtl_configuration - Configure MTL
  *  @priv: driver private structure
  *  Description: It is used for configurring MTL
@@ -1679,6 +1696,10 @@ static void stmmac_mtl_configuration(struct stmmac_priv *priv)
 		priv->hw->mac->prog_mtl_tx_algorithms(priv->hw,
 						priv->plat->tx_sched_algorithm);
 
+	/* Map RX MTL to DMA channels */
+	if (rx_queues_count > 1 && priv->hw->mac->map_mtl_to_dma)
+		stmmac_rx_queue_dma_chan_map(priv);
+
 	/* Enable MAC RX Queues */
 	if (rx_queues_count > 1 && priv->hw->mac->rx_queue_enable)
 		stmmac_mac_enable_rx_queues(priv);
-- 
2.9.3
