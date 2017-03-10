From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: [PATCH v5 net-next 8/9] net: stmmac: mac debug prepared for multiple queues
Date: Fri, 10 Mar 2017 18:24:58 +0000
Message-ID: <54a7eb3d654bd77714bfa0a93b03bf2dc35fbb06.1489169213.git.jpinto@synopsys.com>
References: <cover.1489169213.git.jpinto@synopsys.com>
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        niklas.cassel@axis.com, netdev@vger.kernel.org,
        Joao Pinto <Joao.Pinto@synopsys.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from us01smtprelay-2.synopsys.com ([198.182.60.111]:51956 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933434AbdCJSZY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Mar 2017 13:25:24 -0500
In-Reply-To: <cover.1489169213.git.jpinto@synopsys.com>
In-Reply-To: <cover.1489169213.git.jpinto@synopsys.com>
References: <cover.1489169213.git.jpinto@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch prepares mac debug dump for multiple queues.

Signed-off-by: Joao Pinto <jpinto@synopsys.com>
---
Changes v4->v5:
- patch title update (stmicro replaced by stmmac)
Changes v3->v4:
- Debug function now gets all rx / tx queues data
Changes v1->v3:
- Just to keep up with patch-set version

 drivers/net/ethernet/stmicro/stmmac/common.h       |   3 +-
 .../net/ethernet/stmicro/stmmac/dwmac1000_core.c   |   3 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c  | 107 +++++++++++----------
 .../net/ethernet/stmicro/stmmac/stmmac_ethtool.c   |   5 +-
 4 files changed, 64 insertions(+), 54 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index 6a348d3..86f43ac 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -488,7 +488,8 @@ struct stmmac_ops {
 	void (*reset_eee_mode)(struct mac_device_info *hw);
 	void (*set_eee_timer)(struct mac_device_info *hw, int ls, int tw);
 	void (*set_eee_pls)(struct mac_device_info *hw, int link);
-	void (*debug)(void __iomem *ioaddr, struct stmmac_extra_stats *x);
+	void (*debug)(void __iomem *ioaddr, struct stmmac_extra_stats *x,
+		      u32 rx_queues, u32 tx_queues);
 	/* PCS calls */
 	void (*pcs_ctrl_ane)(void __iomem *ioaddr, bool ane, bool srgmi_ral,
 			     bool loopback);
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
index 3a95ad9..7f78f77 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
@@ -413,7 +413,8 @@ static void dwmac1000_get_adv_lp(void __iomem *ioaddr, struct rgmii_adv *adv)
 	dwmac_get_adv_lp(ioaddr, GMAC_PCS_BASE, adv);
 }
 
-static void dwmac1000_debug(void __iomem *ioaddr, struct stmmac_extra_stats *x)
+static void dwmac1000_debug(void __iomem *ioaddr, struct stmmac_extra_stats *x,
+			    u32 rx_queues, u32 tx_queues)
 {
 	u32 value = readl(ioaddr + GMAC_DEBUG);
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
index f0f2dce..670cfee 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
@@ -469,64 +469,69 @@ static int dwmac4_irq_status(struct mac_device_info *hw,
 	return ret;
 }
 
-static void dwmac4_debug(void __iomem *ioaddr, struct stmmac_extra_stats *x)
+static void dwmac4_debug(void __iomem *ioaddr, struct stmmac_extra_stats *x,
+			 u32 rx_queues, u32 tx_queues)
 {
 	u32 value;
-
-	/*  Currently only channel 0 is supported */
-	value = readl(ioaddr + MTL_CHAN_TX_DEBUG(STMMAC_CHAN0));
-
-	if (value & MTL_DEBUG_TXSTSFSTS)
-		x->mtl_tx_status_fifo_full++;
-	if (value & MTL_DEBUG_TXFSTS)
-		x->mtl_tx_fifo_not_empty++;
-	if (value & MTL_DEBUG_TWCSTS)
-		x->mmtl_fifo_ctrl++;
-	if (value & MTL_DEBUG_TRCSTS_MASK) {
-		u32 trcsts = (value & MTL_DEBUG_TRCSTS_MASK)
-			     >> MTL_DEBUG_TRCSTS_SHIFT;
-		if (trcsts == MTL_DEBUG_TRCSTS_WRITE)
-			x->mtl_tx_fifo_read_ctrl_write++;
-		else if (trcsts == MTL_DEBUG_TRCSTS_TXW)
-			x->mtl_tx_fifo_read_ctrl_wait++;
-		else if (trcsts == MTL_DEBUG_TRCSTS_READ)
-			x->mtl_tx_fifo_read_ctrl_read++;
-		else
-			x->mtl_tx_fifo_read_ctrl_idle++;
+	u32 queue;
+
+	for (queue = 0; queue < tx_queues; queue++) {
+		value = readl(ioaddr + MTL_CHAN_TX_DEBUG(queue));
+
+		if (value & MTL_DEBUG_TXSTSFSTS)
+			x->mtl_tx_status_fifo_full++;
+		if (value & MTL_DEBUG_TXFSTS)
+			x->mtl_tx_fifo_not_empty++;
+		if (value & MTL_DEBUG_TWCSTS)
+			x->mmtl_fifo_ctrl++;
+		if (value & MTL_DEBUG_TRCSTS_MASK) {
+			u32 trcsts = (value & MTL_DEBUG_TRCSTS_MASK)
+				     >> MTL_DEBUG_TRCSTS_SHIFT;
+			if (trcsts == MTL_DEBUG_TRCSTS_WRITE)
+				x->mtl_tx_fifo_read_ctrl_write++;
+			else if (trcsts == MTL_DEBUG_TRCSTS_TXW)
+				x->mtl_tx_fifo_read_ctrl_wait++;
+			else if (trcsts == MTL_DEBUG_TRCSTS_READ)
+				x->mtl_tx_fifo_read_ctrl_read++;
+			else
+				x->mtl_tx_fifo_read_ctrl_idle++;
+		}
+		if (value & MTL_DEBUG_TXPAUSED)
+			x->mac_tx_in_pause++;
 	}
-	if (value & MTL_DEBUG_TXPAUSED)
-		x->mac_tx_in_pause++;
 
-	value = readl(ioaddr + MTL_CHAN_RX_DEBUG(STMMAC_CHAN0));
+	for (queue = 0; queue < rx_queues; queue++) {
+		value = readl(ioaddr + MTL_CHAN_RX_DEBUG(queue));
 
-	if (value & MTL_DEBUG_RXFSTS_MASK) {
-		u32 rxfsts = (value & MTL_DEBUG_RXFSTS_MASK)
-			     >> MTL_DEBUG_RRCSTS_SHIFT;
+		if (value & MTL_DEBUG_RXFSTS_MASK) {
+			u32 rxfsts = (value & MTL_DEBUG_RXFSTS_MASK)
+				     >> MTL_DEBUG_RRCSTS_SHIFT;
 
-		if (rxfsts == MTL_DEBUG_RXFSTS_FULL)
-			x->mtl_rx_fifo_fill_level_full++;
-		else if (rxfsts == MTL_DEBUG_RXFSTS_AT)
-			x->mtl_rx_fifo_fill_above_thresh++;
-		else if (rxfsts == MTL_DEBUG_RXFSTS_BT)
-			x->mtl_rx_fifo_fill_below_thresh++;
-		else
-			x->mtl_rx_fifo_fill_level_empty++;
-	}
-	if (value & MTL_DEBUG_RRCSTS_MASK) {
-		u32 rrcsts = (value & MTL_DEBUG_RRCSTS_MASK) >>
-			     MTL_DEBUG_RRCSTS_SHIFT;
-
-		if (rrcsts == MTL_DEBUG_RRCSTS_FLUSH)
-			x->mtl_rx_fifo_read_ctrl_flush++;
-		else if (rrcsts == MTL_DEBUG_RRCSTS_RSTAT)
-			x->mtl_rx_fifo_read_ctrl_read_data++;
-		else if (rrcsts == MTL_DEBUG_RRCSTS_RDATA)
-			x->mtl_rx_fifo_read_ctrl_status++;
-		else
-			x->mtl_rx_fifo_read_ctrl_idle++;
+			if (rxfsts == MTL_DEBUG_RXFSTS_FULL)
+				x->mtl_rx_fifo_fill_level_full++;
+			else if (rxfsts == MTL_DEBUG_RXFSTS_AT)
+				x->mtl_rx_fifo_fill_above_thresh++;
+			else if (rxfsts == MTL_DEBUG_RXFSTS_BT)
+				x->mtl_rx_fifo_fill_below_thresh++;
+			else
+				x->mtl_rx_fifo_fill_level_empty++;
+		}
+		if (value & MTL_DEBUG_RRCSTS_MASK) {
+			u32 rrcsts = (value & MTL_DEBUG_RRCSTS_MASK) >>
+				     MTL_DEBUG_RRCSTS_SHIFT;
+
+			if (rrcsts == MTL_DEBUG_RRCSTS_FLUSH)
+				x->mtl_rx_fifo_read_ctrl_flush++;
+			else if (rrcsts == MTL_DEBUG_RRCSTS_RSTAT)
+				x->mtl_rx_fifo_read_ctrl_read_data++;
+			else if (rrcsts == MTL_DEBUG_RRCSTS_RDATA)
+				x->mtl_rx_fifo_read_ctrl_status++;
+			else
+				x->mtl_rx_fifo_read_ctrl_idle++;
+		}
+		if (value & MTL_DEBUG_RWCSTS)
+			x->mtl_rx_fifo_ctrl_active++;
 	}
-	if (value & MTL_DEBUG_RWCSTS)
-		x->mtl_rx_fifo_ctrl_active++;
 
 	/* GMAC debug */
 	value = readl(ioaddr + GMAC_DEBUG);
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
index 4a5dc89..61b9369 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
@@ -520,6 +520,8 @@ static void stmmac_get_ethtool_stats(struct net_device *dev,
 				 struct ethtool_stats *dummy, u64 *data)
 {
 	struct stmmac_priv *priv = netdev_priv(dev);
+	u32 rx_queues_count = priv->plat->rx_queues_to_use;
+	u32 tx_queues_count = priv->plat->tx_queues_to_use;
 	int i, j = 0;
 
 	/* Update the DMA HW counters for dwmac10/100 */
@@ -550,7 +552,8 @@ static void stmmac_get_ethtool_stats(struct net_device *dev,
 		if ((priv->hw->mac->debug) &&
 		    (priv->synopsys_id >= DWMAC_CORE_3_50))
 			priv->hw->mac->debug(priv->ioaddr,
-					     (void *)&priv->xstats);
+					     (void *)&priv->xstats,
+					     rx_queues_count, tx_queues_count);
 	}
 	for (i = 0; i < STMMAC_STATS_LEN; i++) {
 		char *p = (char *)priv + stmmac_gstrings_stats[i].stat_offset;
-- 
2.9.3
