From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH v2 2/2] net: stmmac: use new api ethtool_{get|set}_link_ksettings
Date: Mon,  3 Oct 2016 08:28:20 +0200
Message-ID: <1475476100-28219-2-git-send-email-tremyfr@gmail.com>
References: <1475476100-28219-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33900 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751454AbcJCG2g (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Oct 2016 02:28:36 -0400
In-Reply-To: <1475476100-28219-1-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
Changelog:
v2:
- no change on this patch

 .../net/ethernet/stmicro/stmmac/stmmac_ethtool.c   |   97 +++++++++++--------
 1 files changed, 56 insertions(+), 41 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
index ac823bf..3fe9340 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
@@ -269,8 +269,8 @@ static void stmmac_ethtool_getdrvinfo(struct net_device *dev,
 	strlcpy(info->version, DRV_MODULE_VERSION, sizeof(info->version));
 }
 
-static int stmmac_ethtool_getsettings(struct net_device *dev,
-				      struct ethtool_cmd *cmd)
+static int stmmac_ethtool_get_link_ksettings(struct net_device *dev,
+					     struct ethtool_link_ksettings *cmd)
 {
 	struct stmmac_priv *priv = netdev_priv(dev);
 	struct phy_device *phy = dev->phydev;
@@ -279,15 +279,16 @@ static int stmmac_ethtool_getsettings(struct net_device *dev,
 	if (priv->hw->pcs & STMMAC_PCS_RGMII ||
 	    priv->hw->pcs & STMMAC_PCS_SGMII) {
 		struct rgmii_adv adv;
+		u32 supported, advertising, lp_advertising;
 
 		if (!priv->xstats.pcs_link) {
-			ethtool_cmd_speed_set(cmd, SPEED_UNKNOWN);
-			cmd->duplex = DUPLEX_UNKNOWN;
+			cmd->base.speed = SPEED_UNKNOWN;
+			cmd->base.duplex = DUPLEX_UNKNOWN;
 			return 0;
 		}
-		cmd->duplex = priv->xstats.pcs_duplex;
+		cmd->base.duplex = priv->xstats.pcs_duplex;
 
-		ethtool_cmd_speed_set(cmd, priv->xstats.pcs_speed);
+		cmd->base.speed = priv->xstats.pcs_speed;
 
 		/* Get and convert ADV/LP_ADV from the HW AN registers */
 		if (!priv->hw->mac->pcs_get_adv_lp)
@@ -297,45 +298,59 @@ static int stmmac_ethtool_getsettings(struct net_device *dev,
 
 		/* Encoding of PSE bits is defined in 802.3z, 37.2.1.4 */
 
+		ethtool_convert_link_mode_to_legacy_u32(
+			&supported, cmd->link_modes.supported);
+		ethtool_convert_link_mode_to_legacy_u32(
+			&advertising, cmd->link_modes.advertising);
+		ethtool_convert_link_mode_to_legacy_u32(
+			&lp_advertising, cmd->link_modes.lp_advertising);
+
 		if (adv.pause & STMMAC_PCS_PAUSE)
-			cmd->advertising |= ADVERTISED_Pause;
+			advertising |= ADVERTISED_Pause;
 		if (adv.pause & STMMAC_PCS_ASYM_PAUSE)
-			cmd->advertising |= ADVERTISED_Asym_Pause;
+			advertising |= ADVERTISED_Asym_Pause;
 		if (adv.lp_pause & STMMAC_PCS_PAUSE)
-			cmd->lp_advertising |= ADVERTISED_Pause;
+			lp_advertising |= ADVERTISED_Pause;
 		if (adv.lp_pause & STMMAC_PCS_ASYM_PAUSE)
-			cmd->lp_advertising |= ADVERTISED_Asym_Pause;
+			lp_advertising |= ADVERTISED_Asym_Pause;
 
 		/* Reg49[3] always set because ANE is always supported */
-		cmd->autoneg = ADVERTISED_Autoneg;
-		cmd->supported |= SUPPORTED_Autoneg;
-		cmd->advertising |= ADVERTISED_Autoneg;
-		cmd->lp_advertising |= ADVERTISED_Autoneg;
+		cmd->base.autoneg = ADVERTISED_Autoneg;
+		supported |= SUPPORTED_Autoneg;
+		advertising |= ADVERTISED_Autoneg;
+		lp_advertising |= ADVERTISED_Autoneg;
 
 		if (adv.duplex) {
-			cmd->supported |= (SUPPORTED_1000baseT_Full |
-					   SUPPORTED_100baseT_Full |
-					   SUPPORTED_10baseT_Full);
-			cmd->advertising |= (ADVERTISED_1000baseT_Full |
-					     ADVERTISED_100baseT_Full |
-					     ADVERTISED_10baseT_Full);
+			supported |= (SUPPORTED_1000baseT_Full |
+				      SUPPORTED_100baseT_Full |
+				      SUPPORTED_10baseT_Full);
+			advertising |= (ADVERTISED_1000baseT_Full |
+					ADVERTISED_100baseT_Full |
+					ADVERTISED_10baseT_Full);
 		} else {
-			cmd->supported |= (SUPPORTED_1000baseT_Half |
-					   SUPPORTED_100baseT_Half |
-					   SUPPORTED_10baseT_Half);
-			cmd->advertising |= (ADVERTISED_1000baseT_Half |
-					     ADVERTISED_100baseT_Half |
-					     ADVERTISED_10baseT_Half);
+			supported |= (SUPPORTED_1000baseT_Half |
+				      SUPPORTED_100baseT_Half |
+				      SUPPORTED_10baseT_Half);
+			advertising |= (ADVERTISED_1000baseT_Half |
+					ADVERTISED_100baseT_Half |
+					ADVERTISED_10baseT_Half);
 		}
 		if (adv.lp_duplex)
-			cmd->lp_advertising |= (ADVERTISED_1000baseT_Full |
-						ADVERTISED_100baseT_Full |
-						ADVERTISED_10baseT_Full);
+			lp_advertising |= (ADVERTISED_1000baseT_Full |
+					   ADVERTISED_100baseT_Full |
+					   ADVERTISED_10baseT_Full);
 		else
-			cmd->lp_advertising |= (ADVERTISED_1000baseT_Half |
-						ADVERTISED_100baseT_Half |
-						ADVERTISED_10baseT_Half);
-		cmd->port = PORT_OTHER;
+			lp_advertising |= (ADVERTISED_1000baseT_Half |
+					   ADVERTISED_100baseT_Half |
+					   ADVERTISED_10baseT_Half);
+		cmd->base.port = PORT_OTHER;
+
+		ethtool_convert_legacy_u32_to_link_mode(
+			cmd->link_modes.supported, supported);
+		ethtool_convert_legacy_u32_to_link_mode(
+			cmd->link_modes.advertising, advertising);
+		ethtool_convert_legacy_u32_to_link_mode(
+			cmd->link_modes.lp_advertising, lp_advertising);
 
 		return 0;
 	}
@@ -350,13 +365,13 @@ static int stmmac_ethtool_getsettings(struct net_device *dev,
 		"link speed / duplex setting\n", dev->name);
 		return -EBUSY;
 	}
-	cmd->transceiver = XCVR_INTERNAL;
-	rc = phy_ethtool_gset(phy, cmd);
+	rc = phy_ethtool_ksettings_get(phy, cmd);
 	return rc;
 }
 
-static int stmmac_ethtool_setsettings(struct net_device *dev,
-				      struct ethtool_cmd *cmd)
+static int
+stmmac_ethtool_set_link_ksettings(struct net_device *dev,
+				  const struct ethtool_link_ksettings *cmd)
 {
 	struct stmmac_priv *priv = netdev_priv(dev);
 	struct phy_device *phy = dev->phydev;
@@ -367,7 +382,7 @@ static int stmmac_ethtool_setsettings(struct net_device *dev,
 		u32 mask = ADVERTISED_Autoneg | ADVERTISED_Pause;
 
 		/* Only support ANE */
-		if (cmd->autoneg != AUTONEG_ENABLE)
+		if (cmd->base.autoneg != AUTONEG_ENABLE)
 			return -EINVAL;
 
 		mask &= (ADVERTISED_1000baseT_Half |
@@ -389,7 +404,7 @@ static int stmmac_ethtool_setsettings(struct net_device *dev,
 	}
 
 	spin_lock(&priv->lock);
-	rc = phy_ethtool_sset(phy, cmd);
+	rc = phy_ethtool_ksettings_set(phy, cmd);
 	spin_unlock(&priv->lock);
 
 	return rc;
@@ -850,8 +865,6 @@ static int stmmac_set_tunable(struct net_device *dev,
 static const struct ethtool_ops stmmac_ethtool_ops = {
 	.begin = stmmac_check_if_running,
 	.get_drvinfo = stmmac_ethtool_getdrvinfo,
-	.get_settings = stmmac_ethtool_getsettings,
-	.set_settings = stmmac_ethtool_setsettings,
 	.get_msglevel = stmmac_ethtool_getmsglevel,
 	.set_msglevel = stmmac_ethtool_setmsglevel,
 	.get_regs = stmmac_ethtool_gregs,
@@ -871,6 +884,8 @@ static const struct ethtool_ops stmmac_ethtool_ops = {
 	.set_coalesce = stmmac_set_coalesce,
 	.get_tunable = stmmac_get_tunable,
 	.set_tunable = stmmac_set_tunable,
+	.get_link_ksettings = stmmac_ethtool_get_link_ksettings,
+	.set_link_ksettings = stmmac_ethtool_set_link_ksettings,
 };
 
 void stmmac_set_ethtool_ops(struct net_device *netdev)
-- 
1.7.4.4
