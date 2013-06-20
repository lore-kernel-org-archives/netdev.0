From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 6/6] alx: fix ethtool support code
Date: Fri, 21 Jun 2013 00:14:54 +0200
Message-ID: <1371766494-18979-7-git-send-email-johannes@sipsolutions.net>
References: <1371766494-18979-1-git-send-email-johannes@sipsolutions.net>
Cc: ben@decadent.org.uk
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:49192 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030365Ab3FTWPE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jun 2013 18:15:04 -0400
In-Reply-To: <1371766494-18979-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A number of places treated features wrongly, listing not-supported
features instead of supported ones. Also, the get_drvinfo ethtool
callback isn't needed, and alx_get_pauseparam can be simplified.

Reported-by: Ben Hutchings <ben@decadent.org.uk>
Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 drivers/net/ethernet/atheros/alx/ethtool.c | 62 +++++++++++++-----------------
 1 file changed, 26 insertions(+), 36 deletions(-)

diff --git a/drivers/net/ethernet/atheros/alx/ethtool.c b/drivers/net/ethernet/atheros/alx/ethtool.c
index 2170b61..0f4c79e 100644
--- a/drivers/net/ethernet/atheros/alx/ethtool.c
+++ b/drivers/net/ethernet/atheros/alx/ethtool.c
@@ -46,22 +46,35 @@
 #include "reg.h"
 #include "hw.h"
 
+static u32 alx_get_supported_speeds(struct alx_hw *hw)
+{
+	u32 supported = SUPPORTED_10baseT_Half |
+			SUPPORTED_10baseT_Full |
+			SUPPORTED_100baseT_Half |
+			SUPPORTED_100baseT_Full;
+
+	if (alx_hw_giga(hw))
+		supported |= SUPPORTED_1000baseT_Full;
+
+	BUILD_BUG_ON(SUPPORTED_10baseT_Half != ADVERTISED_10baseT_Half);
+	BUILD_BUG_ON(SUPPORTED_10baseT_Full != ADVERTISED_10baseT_Full);
+	BUILD_BUG_ON(SUPPORTED_100baseT_Half != ADVERTISED_100baseT_Half);
+	BUILD_BUG_ON(SUPPORTED_100baseT_Full != ADVERTISED_100baseT_Full);
+	BUILD_BUG_ON(SUPPORTED_1000baseT_Full != ADVERTISED_1000baseT_Full);
+
+	return supported;
+}
 
 static int alx_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 {
 	struct alx_priv *alx = netdev_priv(netdev);
 	struct alx_hw *hw = &alx->hw;
 
-	ecmd->supported = SUPPORTED_10baseT_Half |
-			  SUPPORTED_10baseT_Full |
-			  SUPPORTED_100baseT_Half |
-			  SUPPORTED_100baseT_Full |
-			  SUPPORTED_Autoneg |
+	ecmd->supported = SUPPORTED_Autoneg |
 			  SUPPORTED_TP |
 			  SUPPORTED_Pause |
 			  SUPPORTED_Asym_Pause;
-	if (alx_hw_giga(hw))
-		ecmd->supported |= SUPPORTED_1000baseT_Full;
+	ecmd->supported |= alx_get_supported_speeds(hw);
 
 	ecmd->advertising = ADVERTISED_TP;
 	if (hw->adv_cfg & ADVERTISED_Autoneg)
@@ -102,7 +115,7 @@ static int alx_set_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 	ASSERT_RTNL();
 
 	if (ecmd->autoneg == AUTONEG_ENABLE) {
-		if (ecmd->advertising & ADVERTISED_1000baseT_Half)
+		if (ecmd->advertising & ~alx_get_supported_speeds(hw))
 			return -EINVAL;
 		adv_cfg = ecmd->advertising | ADVERTISED_Autoneg;
 	} else {
@@ -123,21 +136,10 @@ static void alx_get_pauseparam(struct net_device *netdev,
 	struct alx_priv *alx = netdev_priv(netdev);
 	struct alx_hw *hw = &alx->hw;
 
-	if (hw->flowctrl & ALX_FC_ANEG &&
-	    hw->adv_cfg & ADVERTISED_Autoneg)
-		pause->autoneg = AUTONEG_ENABLE;
-	else
-		pause->autoneg = AUTONEG_DISABLE;
-
-	if (hw->flowctrl & ALX_FC_TX)
-		pause->tx_pause = 1;
-	else
-		pause->tx_pause = 0;
-
-	if (hw->flowctrl & ALX_FC_RX)
-		pause->rx_pause = 1;
-	else
-		pause->rx_pause = 0;
+	pause->autoneg = !!(hw->flowctrl & ALX_FC_ANEG &&
+			    hw->adv_cfg & ADVERTISED_Autoneg);
+	pause->tx_pause = !!(hw->flowctrl & ALX_FC_TX);
+	pause->rx_pause = !!(hw->flowctrl & ALX_FC_RX);
 }
 
 
@@ -216,8 +218,7 @@ static int alx_set_wol(struct net_device *netdev, struct ethtool_wolinfo *wol)
 	struct alx_priv *alx = netdev_priv(netdev);
 	struct alx_hw *hw = &alx->hw;
 
-	if (wol->wolopts & (WAKE_ARP | WAKE_MAGICSECURE |
-			    WAKE_UCAST | WAKE_BCAST | WAKE_MCAST))
+	if (wol->wolopts & ~(WAKE_MAGIC | WAKE_PHY))
 		return -EOPNOTSUPP;
 
 	hw->sleep_ctrl = 0;
@@ -232,22 +233,11 @@ static int alx_set_wol(struct net_device *netdev, struct ethtool_wolinfo *wol)
 	return 0;
 }
 
-static void alx_get_drvinfo(struct net_device *netdev,
-			    struct ethtool_drvinfo *drvinfo)
-{
-	struct alx_priv *alx = netdev_priv(netdev);
-
-	strlcpy(drvinfo->driver, alx_drv_name, sizeof(drvinfo->driver));
-	strlcpy(drvinfo->bus_info, pci_name(alx->hw.pdev),
-		sizeof(drvinfo->bus_info));
-}
-
 const struct ethtool_ops alx_ethtool_ops = {
 	.get_settings	= alx_get_settings,
 	.set_settings	= alx_set_settings,
 	.get_pauseparam	= alx_get_pauseparam,
 	.set_pauseparam	= alx_set_pauseparam,
-	.get_drvinfo	= alx_get_drvinfo,
 	.get_msglevel	= alx_get_msglevel,
 	.set_msglevel	= alx_set_msglevel,
 	.get_wol	= alx_get_wol,
-- 
1.8.0
