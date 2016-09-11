From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 2/2] net: ethernet: apm: xgene: use new api ethtool_{get|set}_link_ksettings
Date: Sun, 11 Sep 2016 17:54:04 +0200
Message-ID: <1473609244-4365-2-git-send-email-tremyfr@gmail.com>
References: <1473609244-4365-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: isubramanian@apm.com, kchudgar@apm.com, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1473609244-4365-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 .../net/ethernet/apm/xgene/xgene_enet_ethtool.c    |   61 ++++++++++++--------
 1 files changed, 37 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_ethtool.c b/drivers/net/ethernet/apm/xgene/xgene_enet_ethtool.c
index e1f44ae..d372d42 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_ethtool.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_ethtool.c
@@ -54,46 +54,59 @@ static void xgene_get_drvinfo(struct net_device *ndev,
 	sprintf(info->bus_info, "%s", pdev->name);
 }
 
-static int xgene_get_settings(struct net_device *ndev, struct ethtool_cmd *cmd)
+static int xgene_get_link_ksettings(struct net_device *ndev,
+				    struct ethtool_link_ksettings *cmd)
 {
 	struct xgene_enet_pdata *pdata = netdev_priv(ndev);
 	struct phy_device *phydev = ndev->phydev;
+	u32 supported;
 
 	if (pdata->phy_mode == PHY_INTERFACE_MODE_RGMII) {
 		if (phydev == NULL)
 			return -ENODEV;
 
-		return phy_ethtool_gset(phydev, cmd);
+		return phy_ethtool_ksettings_get(phydev, cmd);
 	} else if (pdata->phy_mode == PHY_INTERFACE_MODE_SGMII) {
 		if (pdata->mdio_driver) {
 			if (!phydev)
 				return -ENODEV;
 
-			return phy_ethtool_gset(phydev, cmd);
+			return phy_ethtool_ksettings_get(phydev, cmd);
 		}
 
-		cmd->supported = SUPPORTED_1000baseT_Full | SUPPORTED_Autoneg |
-				 SUPPORTED_MII;
-		cmd->advertising = cmd->supported;
-		ethtool_cmd_speed_set(cmd, SPEED_1000);
-		cmd->duplex = DUPLEX_FULL;
-		cmd->port = PORT_MII;
-		cmd->transceiver = XCVR_INTERNAL;
-		cmd->autoneg = AUTONEG_ENABLE;
+		supported = SUPPORTED_1000baseT_Full | SUPPORTED_Autoneg |
+			SUPPORTED_MII;
+		ethtool_convert_legacy_u32_to_link_mode(
+			cmd->link_modes.supported,
+			supported);
+		ethtool_convert_legacy_u32_to_link_mode(
+			cmd->link_modes.advertising,
+			supported);
+
+		cmd->base.speed = SPEED_1000;
+		cmd->base.duplex = DUPLEX_FULL;
+		cmd->base.port = PORT_MII;
+		cmd->base.autoneg = AUTONEG_ENABLE;
 	} else {
-		cmd->supported = SUPPORTED_10000baseT_Full | SUPPORTED_FIBRE;
-		cmd->advertising = cmd->supported;
-		ethtool_cmd_speed_set(cmd, SPEED_10000);
-		cmd->duplex = DUPLEX_FULL;
-		cmd->port = PORT_FIBRE;
-		cmd->transceiver = XCVR_INTERNAL;
-		cmd->autoneg = AUTONEG_DISABLE;
+		supported = SUPPORTED_10000baseT_Full | SUPPORTED_FIBRE;
+		ethtool_convert_legacy_u32_to_link_mode(
+			cmd->link_modes.supported,
+			supported);
+		ethtool_convert_legacy_u32_to_link_mode(
+			cmd->link_modes.advertising,
+			supported);
+
+		cmd->base.speed = SPEED_10000;
+		cmd->base.duplex = DUPLEX_FULL;
+		cmd->base.port = PORT_FIBRE;
+		cmd->base.autoneg = AUTONEG_DISABLE;
 	}
 
 	return 0;
 }
 
-static int xgene_set_settings(struct net_device *ndev, struct ethtool_cmd *cmd)
+static int xgene_set_link_ksettings(struct net_device *ndev,
+				    const struct ethtool_link_ksettings *cmd)
 {
 	struct xgene_enet_pdata *pdata = netdev_priv(ndev);
 	struct phy_device *phydev = ndev->phydev;
@@ -102,7 +115,7 @@ static int xgene_set_settings(struct net_device *ndev, struct ethtool_cmd *cmd)
 		if (!phydev)
 			return -ENODEV;
 
-		return phy_ethtool_sset(phydev, cmd);
+		return phy_ethtool_ksettings_set(phydev, cmd);
 	}
 
 	if (pdata->phy_mode == PHY_INTERFACE_MODE_SGMII) {
@@ -110,7 +123,7 @@ static int xgene_set_settings(struct net_device *ndev, struct ethtool_cmd *cmd)
 			if (!phydev)
 				return -ENODEV;
 
-			return phy_ethtool_sset(phydev, cmd);
+			return phy_ethtool_ksettings_set(phydev, cmd);
 		}
 	}
 
@@ -152,12 +165,12 @@ static void xgene_get_ethtool_stats(struct net_device *ndev,
 
 static const struct ethtool_ops xgene_ethtool_ops = {
 	.get_drvinfo = xgene_get_drvinfo,
-	.get_settings = xgene_get_settings,
-	.set_settings = xgene_set_settings,
 	.get_link = ethtool_op_get_link,
 	.get_strings = xgene_get_strings,
 	.get_sset_count = xgene_get_sset_count,
-	.get_ethtool_stats = xgene_get_ethtool_stats
+	.get_ethtool_stats = xgene_get_ethtool_stats,
+	.get_link_ksettings = xgene_get_link_ksettings,
+	.set_link_ksettings = xgene_set_link_ksettings,
 };
 
 void xgene_enet_set_ethtool_ops(struct net_device *ndev)
-- 
1.7.4.4
