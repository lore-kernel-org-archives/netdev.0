From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: [PATCH net-next 6/8] net: stmicro: flow_ctrl functions adapted to mtl
Date: Wed,  8 Mar 2017 11:03:13 +0000
Message-ID: <1ac651072246dfbd5c6532e223363a8f8a9a10e6.1488969672.git.jpinto@synopsys.com>
References: <cover.1488969672.git.jpinto@synopsys.com>
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org, Joao Pinto <Joao.Pinto@synopsys.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from us01smtprelay-2.synopsys.com ([198.182.60.111]:60138 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750728AbdCHL5r (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Mar 2017 06:57:47 -0500
In-Reply-To: <cover.1488969672.git.jpinto@synopsys.com>
In-Reply-To: <cover.1488969672.git.jpinto@synopsys.com>
References: <cover.1488969672.git.jpinto@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adapts flow_ctrl function to prepare it for multiple queues.

Signed-off-by: Joao Pinto <jpinto@synopsys.com>
---
 drivers/net/ethernet/stmicro/stmmac/common.h         |  2 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c |  3 ++-
 drivers/net/ethernet/stmicro/stmmac/dwmac100_core.c  |  3 ++-
 drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c    | 20 +++++++++++++-------
 drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c |  3 ++-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c    | 17 ++++++++++++++---
 6 files changed, 34 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index 32f5f25..5532633 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -473,7 +473,7 @@ struct stmmac_ops {
 	void (*set_filter)(struct mac_device_info *hw, struct net_device *dev);
 	/* Flow control setting */
 	void (*flow_ctrl)(struct mac_device_info *hw, unsigned int duplex,
-			  unsigned int fc, unsigned int pause_time);
+			  unsigned int fc, unsigned int pause_time, u32 tx_cnt);
 	/* Set power management mode (e.g. magic frame) */
 	void (*pmt)(struct mac_device_info *hw, unsigned long mode);
 	/* Set/Get Unicast MAC addresses */
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
index 19b9b30..3a95ad9 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
@@ -216,7 +216,8 @@ static void dwmac1000_set_filter(struct mac_device_info *hw,
 
 
 static void dwmac1000_flow_ctrl(struct mac_device_info *hw, unsigned int duplex,
-				unsigned int fc, unsigned int pause_time)
+				unsigned int fc, unsigned int pause_time,
+				u32 tx_cnt)
 {
 	void __iomem *ioaddr = hw->pcsr;
 	/* Set flow such that DZPQ in Mac Register 6 is 0,
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac100_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac100_core.c
index e370cce..524135e 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac100_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac100_core.c
@@ -131,7 +131,8 @@ static void dwmac100_set_filter(struct mac_device_info *hw,
 }
 
 static void dwmac100_flow_ctrl(struct mac_device_info *hw, unsigned int duplex,
-			       unsigned int fc, unsigned int pause_time)
+			       unsigned int fc, unsigned int pause_time,
+			       u32 tx_cnt)
 {
 	void __iomem *ioaddr = hw->pcsr;
 	unsigned int flow = MAC_FLOW_CTRL_ENABLE;
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
index a348f7d..65528c4 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
@@ -337,11 +337,12 @@ static void dwmac4_set_filter(struct mac_device_info *hw,
 }
 
 static void dwmac4_flow_ctrl(struct mac_device_info *hw, unsigned int duplex,
-			     unsigned int fc, unsigned int pause_time)
+			     unsigned int fc, unsigned int pause_time,
+			     u32 tx_cnt)
 {
 	void __iomem *ioaddr = hw->pcsr;
-	u32 channel = STMMAC_CHAN0;	/* FIXME */
 	unsigned int flow = 0;
+	u32 queue = 0;
 
 	pr_debug("GMAC Flow-Control:\n");
 	if (fc & FLOW_RX) {
@@ -351,13 +352,18 @@ static void dwmac4_flow_ctrl(struct mac_device_info *hw, unsigned int duplex,
 	}
 	if (fc & FLOW_TX) {
 		pr_debug("\tTransmit Flow-Control ON\n");
-		flow |= GMAC_TX_FLOW_CTRL_TFE;
-		writel(flow, ioaddr + GMAC_QX_TX_FLOW_CTRL(channel));
 
-		if (duplex) {
+		if (duplex)
 			pr_debug("\tduplex mode: PAUSE %d\n", pause_time);
-			flow |= (pause_time << GMAC_TX_FLOW_CTRL_PT_SHIFT);
-			writel(flow, ioaddr + GMAC_QX_TX_FLOW_CTRL(channel));
+
+		for (queue = 0; queue < tx_cnt; queue++) {
+			flow |= GMAC_TX_FLOW_CTRL_TFE;
+
+			if (duplex)
+				flow |=
+				(pause_time << GMAC_TX_FLOW_CTRL_PT_SHIFT);
+
+			writel(flow, ioaddr + GMAC_QX_TX_FLOW_CTRL(queue));
 		}
 	}
 }
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
index 85d6411..4a5dc89 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
@@ -481,6 +481,7 @@ stmmac_set_pauseparam(struct net_device *netdev,
 		      struct ethtool_pauseparam *pause)
 {
 	struct stmmac_priv *priv = netdev_priv(netdev);
+	u32 tx_cnt = priv->plat->tx_queues_to_use;
 	struct phy_device *phy = netdev->phydev;
 	int new_pause = FLOW_OFF;
 
@@ -511,7 +512,7 @@ stmmac_set_pauseparam(struct net_device *netdev,
 	}
 
 	priv->hw->mac->flow_ctrl(priv->hw, phy->duplex, priv->flow_ctrl,
-				 priv->pause);
+				 priv->pause, tx_cnt);
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index c10f7a2..1a072e9 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -673,6 +673,19 @@ static void stmmac_release_ptp(struct stmmac_priv *priv)
 }
 
 /**
+ *  stmmac_mac_flow_ctrl - Configure flow control in all queues
+ *  @priv: driver private structure
+ *  Description: It is used for configuring the flow control in all queues
+ */
+static void stmmac_mac_flow_ctrl(struct stmmac_priv *priv, u32 duplex)
+{
+	u32 tx_cnt = priv->plat->tx_queues_to_use;
+
+	priv->hw->mac->flow_ctrl(priv->hw, duplex, priv->flow_ctrl,
+				 priv->pause, tx_cnt);
+}
+
+/**
  * stmmac_adjust_link - adjusts the link parameters
  * @dev: net device structure
  * Description: this is the helper called by the physical abstraction layer
@@ -687,7 +700,6 @@ static void stmmac_adjust_link(struct net_device *dev)
 	struct phy_device *phydev = dev->phydev;
 	unsigned long flags;
 	int new_state = 0;
-	unsigned int fc = priv->flow_ctrl, pause_time = priv->pause;
 
 	if (!phydev)
 		return;
@@ -709,8 +721,7 @@ static void stmmac_adjust_link(struct net_device *dev)
 		}
 		/* Flow Control operation */
 		if (phydev->pause)
-			priv->hw->mac->flow_ctrl(priv->hw, phydev->duplex,
-						 fc, pause_time);
+			stmmac_mac_flow_ctrl(priv, phydev->duplex);
 
 		if (phydev->speed != priv->speed) {
 			new_state = 1;
-- 
2.9.3
