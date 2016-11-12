From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: atheros: atl1e: use new api ethtool_{get|set}_link_ksettings
Date: Sat, 12 Nov 2016 23:16:51 +0100
Message-ID: <1478989011-11078-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: jcliburn@gmail.com, chris.snook@gmail.com, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

The previous implementation of set_settings was modifying
the value of advertising, but with the new API, it's not
possible. The structure ethtool_link_ksettings is defined
as const.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/atheros/atl1e/atl1e_ethtool.c |   62 +++++++++++--------
 1 files changed, 36 insertions(+), 26 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atl1e/atl1e_ethtool.c b/drivers/net/ethernet/atheros/atl1e/atl1e_ethtool.c
index 8e3dbd4..cb489e7 100644
--- a/drivers/net/ethernet/atheros/atl1e/atl1e_ethtool.c
+++ b/drivers/net/ethernet/atheros/atl1e/atl1e_ethtool.c
@@ -26,73 +26,83 @@
 
 #include "atl1e.h"
 
-static int atl1e_get_settings(struct net_device *netdev,
-			      struct ethtool_cmd *ecmd)
+static int atl1e_get_link_ksettings(struct net_device *netdev,
+				    struct ethtool_link_ksettings *cmd)
 {
 	struct atl1e_adapter *adapter = netdev_priv(netdev);
 	struct atl1e_hw *hw = &adapter->hw;
+	u32 supported, advertising;
 
-	ecmd->supported = (SUPPORTED_10baseT_Half  |
+	supported = (SUPPORTED_10baseT_Half  |
 			   SUPPORTED_10baseT_Full  |
 			   SUPPORTED_100baseT_Half |
 			   SUPPORTED_100baseT_Full |
 			   SUPPORTED_Autoneg       |
 			   SUPPORTED_TP);
 	if (hw->nic_type == athr_l1e)
-		ecmd->supported |= SUPPORTED_1000baseT_Full;
+		supported |= SUPPORTED_1000baseT_Full;
 
-	ecmd->advertising = ADVERTISED_TP;
+	advertising = ADVERTISED_TP;
 
-	ecmd->advertising |= ADVERTISED_Autoneg;
-	ecmd->advertising |= hw->autoneg_advertised;
+	advertising |= ADVERTISED_Autoneg;
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
 
-static int atl1e_set_settings(struct net_device *netdev,
-			      struct ethtool_cmd *ecmd)
+static int atl1e_set_link_ksettings(struct net_device *netdev,
+				    const struct ethtool_link_ksettings *cmd)
 {
 	struct atl1e_adapter *adapter = netdev_priv(netdev);
 	struct atl1e_hw *hw = &adapter->hw;
+	u32 advertising;
+
+	ethtool_convert_link_mode_to_legacy_u32(&advertising,
+						cmd->link_modes.advertising);
 
 	while (test_and_set_bit(__AT_RESETTING, &adapter->flags))
 		msleep(1);
 
-	if (ecmd->autoneg == AUTONEG_ENABLE) {
+	if (cmd->base.autoneg == AUTONEG_ENABLE) {
 		u16 adv4, adv9;
 
-		if ((ecmd->advertising&ADVERTISE_1000_FULL)) {
+		if (advertising & ADVERTISE_1000_FULL) {
 			if (hw->nic_type == athr_l1e) {
 				hw->autoneg_advertised =
-					ecmd->advertising & AT_ADV_MASK;
+					advertising & AT_ADV_MASK;
 			} else {
 				clear_bit(__AT_RESETTING, &adapter->flags);
 				return -EINVAL;
 			}
-		} else if (ecmd->advertising&ADVERTISE_1000_HALF) {
+		} else if (advertising & ADVERTISE_1000_HALF) {
 			clear_bit(__AT_RESETTING, &adapter->flags);
 			return -EINVAL;
 		} else {
 			hw->autoneg_advertised =
-				ecmd->advertising & AT_ADV_MASK;
+				advertising & AT_ADV_MASK;
 		}
-		ecmd->advertising = hw->autoneg_advertised |
+		advertising = hw->autoneg_advertised |
 				    ADVERTISED_TP | ADVERTISED_Autoneg;
 
 		adv4 = hw->mii_autoneg_adv_reg & ~ADVERTISE_ALL;
@@ -367,8 +377,6 @@ static int atl1e_nway_reset(struct net_device *netdev)
 }
 
 static const struct ethtool_ops atl1e_ethtool_ops = {
-	.get_settings           = atl1e_get_settings,
-	.set_settings           = atl1e_set_settings,
 	.get_drvinfo            = atl1e_get_drvinfo,
 	.get_regs_len           = atl1e_get_regs_len,
 	.get_regs               = atl1e_get_regs,
@@ -380,6 +388,8 @@ static int atl1e_nway_reset(struct net_device *netdev)
 	.get_eeprom_len         = atl1e_get_eeprom_len,
 	.get_eeprom             = atl1e_get_eeprom,
 	.set_eeprom             = atl1e_set_eeprom,
+	.get_link_ksettings     = atl1e_get_link_ksettings,
+	.set_link_ksettings     = atl1e_set_link_ksettings,
 };
 
 void atl1e_set_ethtool_ops(struct net_device *netdev)
-- 
1.7.4.4
