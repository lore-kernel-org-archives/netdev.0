From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: [PATCH v2 net-next 8/8] net: stmicro: mac debug prepared for multiple queues
Date: Wed,  8 Mar 2017 12:22:48 +0000
Message-ID: <9efe174a43c1d6c1fa2d7fe37d626e47d98b26ae.1488975090.git.jpinto@synopsys.com>
References: <cover.1488975090.git.jpinto@synopsys.com>
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org, Joao Pinto <Joao.Pinto@synopsys.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay4.synopsys.com ([198.182.47.9]:36621 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752622AbdCHMY3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Mar 2017 07:24:29 -0500
In-Reply-To: <cover.1488975090.git.jpinto@synopsys.com>
In-Reply-To: <cover.1488975090.git.jpinto@synopsys.com>
References: <cover.1488975090.git.jpinto@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch prepares mac debug dump for multiple queues.

Signed-off-by: Joao Pinto <jpinto@synopsys.com>
---
changes v1->v2:
- Just to keep up with patch-set version

 drivers/net/ethernet/stmicro/stmmac/common.h         |  3 ++-
 drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c |  3 ++-
 drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c    | 10 ++++------
 drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c |  4 +++-
 4 files changed, 11 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index 6a348d3..d7bb498 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -488,7 +488,8 @@ struct stmmac_ops {
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
index 3a95ad9..0ebb69f 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
@@ -413,7 +413,8 @@ static void dwmac1000_get_adv_lp(void __iomem *ioaddr, struct rgmii_adv *adv)
 	dwmac_get_adv_lp(ioaddr, GMAC_PCS_BASE, adv);
 }
 
-static void dwmac1000_debug(void __iomem *ioaddr, struct stmmac_extra_stats *x)
+static void dwmac1000_debug(void __iomem *ioaddr, struct stmmac_extra_stats *x,
+			    u32 queue)
 {
 	u32 value = readl(ioaddr + GMAC_DEBUG);
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
index 3e723e1..b96acb8 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
@@ -468,12 +468,10 @@ static int dwmac4_irq_status(struct mac_device_info *hw,
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
@@ -496,7 +494,7 @@ static void dwmac4_debug(void __iomem *ioaddr, struct stmmac_extra_stats *x)
 	if (value & MTL_DEBUG_TXPAUSED)
 		x->mac_tx_in_pause++;
 
-	value = readl(ioaddr + MTL_CHAN_RX_DEBUG(STMMAC_CHAN0));
+	value = readl(ioaddr + MTL_CHAN_RX_DEBUG(queue));
 
 	if (value & MTL_DEBUG_RXFSTS_MASK) {
 		u32 rxfsts = (value & MTL_DEBUG_RXFSTS_MASK)
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
index 4a5dc89..09a714b 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
@@ -520,6 +520,7 @@ static void stmmac_get_ethtool_stats(struct net_device *dev,
 				 struct ethtool_stats *dummy, u64 *data)
 {
 	struct stmmac_priv *priv = netdev_priv(dev);
+	u32 queue = 0;
 	int i, j = 0;
 
 	/* Update the DMA HW counters for dwmac10/100 */
@@ -550,7 +551,8 @@ static void stmmac_get_ethtool_stats(struct net_device *dev,
 		if ((priv->hw->mac->debug) &&
 		    (priv->synopsys_id >= DWMAC_CORE_3_50))
 			priv->hw->mac->debug(priv->ioaddr,
-					     (void *)&priv->xstats);
+					     (void *)&priv->xstats,
+					     queue);
 	}
 	for (i = 0; i < STMMAC_STATS_LEN; i++) {
 		char *p = (char *)priv + stmmac_gstrings_stats[i].stat_offset;
-- 
2.9.3
