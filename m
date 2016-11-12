From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: atheros: atl1c: use new api ethtool_{get|set}_link_ksettings
Date: Sat, 12 Nov 2016 17:32:49 +0100
Message-ID: <1478968369-25034-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: jcliburn@gmail.com, chris.snook@gmail.com, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/atheros/atl1c/atl1c_ethtool.c |   54 +++++++++++---------
 1 files changed, 30 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_ethtool.c b/drivers/net/ethernet/atheros/atl1c/atl1c_ethtool.c
index 872b7ab..cfe86a2 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_ethtool.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_ethtool.c
@@ -26,46 +26,52 @@
 
 #include "atl1c.h"
 
-static int atl1c_get_settings(struct net_device *netdev,
-			      struct ethtool_cmd *ecmd)
+static int atl1c_get_link_ksettings(struct net_device *netdev,
+				    struct ethtool_link_ksettings *cmd)
 {
 	struct atl1c_adapter *adapter = netdev_priv(netdev);
 	struct atl1c_hw *hw = &adapter->hw;
+	u32 supported, advertising;
 
-	ecmd->supported = (SUPPORTED_10baseT_Half  |
+	supported = (SUPPORTED_10baseT_Half  |
 			   SUPPORTED_10baseT_Full  |
 			   SUPPORTED_100baseT_Half |
 			   SUPPORTED_100baseT_Full |
 			   SUPPORTED_Autoneg       |
 			   SUPPORTED_TP);
 	if (hw->link_cap_flags & ATL1C_LINK_CAP_1000M)
-		ecmd->supported |= SUPPORTED_1000baseT_Full;
+		supported |= SUPPORTED_1000baseT_Full;
 
-	ecmd->advertising = ADVERTISED_TP;
+	advertising = ADVERTISED_TP;
 
-	ecmd->advertising |= hw->autoneg_advertised;
+	advertising |= hw->autoneg_advertised;
 
-	ecmd->port = PORT_TP;
-	ecmd->phy_address = 0;
-	ecmd->transceiver = XCVR_INTERNAL;
+	cmd->base.port = PORT_TP;
+	cmd->base.phy_address = 0;
 
 	if (adapter->link_speed != SPEED_0) {
-		ethtool_cmd_speed_set(ecmd, adapter->link_speed);
+		cmd->base.speed = adapter->link_speed;
 		if (adapter->link_duplex == FULL_DUPLEX)
-			ecmd->duplex = DUPLEX_FULL;
+			cmd->base.duplex = DUPLEX_FULL;
 		else
-			ecmd->duplex = DUPLEX_HALF;
+			cmd->base.duplex = DUPLEX_HALF;
 	} else {
-		ethtool_cmd_speed_set(ecmd, SPEED_UNKNOWN);
-		ecmd->duplex = DUPLEX_UNKNOWN;
+		cmd->base.speed = SPEED_UNKNOWN;
+		cmd->base.duplex = DUPLEX_UNKNOWN;
 	}
 
-	ecmd->autoneg = AUTONEG_ENABLE;
+	cmd->base.autoneg = AUTONEG_ENABLE;
+
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.supported,
+						supported);
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.advertising,
+						advertising);
+
 	return 0;
 }
 
-static int atl1c_set_settings(struct net_device *netdev,
-			      struct ethtool_cmd *ecmd)
+static int atl1c_set_link_ksettings(struct net_device *netdev,
+				    const struct ethtool_link_ksettings *cmd)
 {
 	struct atl1c_adapter *adapter = netdev_priv(netdev);
 	struct atl1c_hw *hw = &adapter->hw;
@@ -74,12 +80,12 @@ static int atl1c_set_settings(struct net_device *netdev,
 	while (test_and_set_bit(__AT_RESETTING, &adapter->flags))
 		msleep(1);
 
-	if (ecmd->autoneg == AUTONEG_ENABLE) {
+	if (cmd->base.autoneg == AUTONEG_ENABLE) {
 		autoneg_advertised = ADVERTISED_Autoneg;
 	} else {
-		u32 speed = ethtool_cmd_speed(ecmd);
+		u32 speed = cmd->base.speed;
 		if (speed == SPEED_1000) {
-			if (ecmd->duplex != DUPLEX_FULL) {
+			if (cmd->base.duplex != DUPLEX_FULL) {
 				if (netif_msg_link(adapter))
 					dev_warn(&adapter->pdev->dev,
 						"1000M half is invalid\n");
@@ -88,12 +94,12 @@ static int atl1c_set_settings(struct net_device *netdev,
 			}
 			autoneg_advertised = ADVERTISED_1000baseT_Full;
 		} else if (speed == SPEED_100) {
-			if (ecmd->duplex == DUPLEX_FULL)
+			if (cmd->base.duplex == DUPLEX_FULL)
 				autoneg_advertised = ADVERTISED_100baseT_Full;
 			else
 				autoneg_advertised = ADVERTISED_100baseT_Half;
 		} else {
-			if (ecmd->duplex == DUPLEX_FULL)
+			if (cmd->base.duplex == DUPLEX_FULL)
 				autoneg_advertised = ADVERTISED_10baseT_Full;
 			else
 				autoneg_advertised = ADVERTISED_10baseT_Half;
@@ -284,8 +290,6 @@ static int atl1c_nway_reset(struct net_device *netdev)
 }
 
 static const struct ethtool_ops atl1c_ethtool_ops = {
-	.get_settings           = atl1c_get_settings,
-	.set_settings           = atl1c_set_settings,
 	.get_drvinfo            = atl1c_get_drvinfo,
 	.get_regs_len           = atl1c_get_regs_len,
 	.get_regs               = atl1c_get_regs,
@@ -297,6 +301,8 @@ static int atl1c_nway_reset(struct net_device *netdev)
 	.get_link               = ethtool_op_get_link,
 	.get_eeprom_len         = atl1c_get_eeprom_len,
 	.get_eeprom             = atl1c_get_eeprom,
+	.get_link_ksettings     = atl1c_get_link_ksettings,
+	.set_link_ksettings     = atl1c_set_link_ksettings,
 };
 
 void atl1c_set_ethtool_ops(struct net_device *netdev)
-- 
1.7.4.4
