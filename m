From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: atheros: atl2: use new api ethtool_{get|set}_link_ksettings
Date: Sun, 13 Nov 2016 18:53:28 +0100
Message-ID: <1479059608-32456-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: jcliburn@gmail.com, chris.snook@gmail.com, davem@davemloft.net,
        jarod@redhat.com, ben@decadent.org.uk
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
 drivers/net/ethernet/atheros/atlx/atl2.c |   66 ++++++++++++++++-------------
 1 files changed, 36 insertions(+), 30 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atlx/atl2.c b/drivers/net/ethernet/atheros/atlx/atl2.c
index 6911394..63f2dee 100644
--- a/drivers/net/ethernet/atheros/atlx/atl2.c
+++ b/drivers/net/ethernet/atheros/atlx/atl2.c
@@ -1737,81 +1737,87 @@ static void atl2_write_pci_cfg(struct atl2_hw *hw, u32 reg, u16 *value)
 	pci_write_config_word(adapter->pdev, reg, *value);
 }
 
-static int atl2_get_settings(struct net_device *netdev,
-	struct ethtool_cmd *ecmd)
+static int atl2_get_link_ksettings(struct net_device *netdev,
+				   struct ethtool_link_ksettings *cmd)
 {
 	struct atl2_adapter *adapter = netdev_priv(netdev);
 	struct atl2_hw *hw = &adapter->hw;
+	u32 supported, advertising;
 
-	ecmd->supported = (SUPPORTED_10baseT_Half |
+	supported = (SUPPORTED_10baseT_Half |
 		SUPPORTED_10baseT_Full |
 		SUPPORTED_100baseT_Half |
 		SUPPORTED_100baseT_Full |
 		SUPPORTED_Autoneg |
 		SUPPORTED_TP);
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
 
-static int atl2_set_settings(struct net_device *netdev,
-	struct ethtool_cmd *ecmd)
+static int atl2_set_link_ksettings(struct net_device *netdev,
+				   const struct ethtool_link_ksettings *cmd)
 {
 	struct atl2_adapter *adapter = netdev_priv(netdev);
 	struct atl2_hw *hw = &adapter->hw;
+	u32 advertising;
+
+	ethtool_convert_link_mode_to_legacy_u32(&advertising,
+						cmd->link_modes.advertising);
 
 	while (test_and_set_bit(__ATL2_RESETTING, &adapter->flags))
 		msleep(1);
 
-	if (ecmd->autoneg == AUTONEG_ENABLE) {
+	if (cmd->base.autoneg == AUTONEG_ENABLE) {
 #define MY_ADV_MASK	(ADVERTISE_10_HALF | \
 			 ADVERTISE_10_FULL | \
 			 ADVERTISE_100_HALF| \
 			 ADVERTISE_100_FULL)
 
-		if ((ecmd->advertising & MY_ADV_MASK) == MY_ADV_MASK) {
+		if ((advertising & MY_ADV_MASK) == MY_ADV_MASK) {
 			hw->MediaType = MEDIA_TYPE_AUTO_SENSOR;
 			hw->autoneg_advertised =  MY_ADV_MASK;
-		} else if ((ecmd->advertising & MY_ADV_MASK) ==
-				ADVERTISE_100_FULL) {
+		} else if ((advertising & MY_ADV_MASK) == ADVERTISE_100_FULL) {
 			hw->MediaType = MEDIA_TYPE_100M_FULL;
 			hw->autoneg_advertised = ADVERTISE_100_FULL;
-		} else if ((ecmd->advertising & MY_ADV_MASK) ==
-				ADVERTISE_100_HALF) {
+		} else if ((advertising & MY_ADV_MASK) == ADVERTISE_100_HALF) {
 			hw->MediaType = MEDIA_TYPE_100M_HALF;
 			hw->autoneg_advertised = ADVERTISE_100_HALF;
-		} else if ((ecmd->advertising & MY_ADV_MASK) ==
-				ADVERTISE_10_FULL) {
+		} else if ((advertising & MY_ADV_MASK) == ADVERTISE_10_FULL) {
 			hw->MediaType = MEDIA_TYPE_10M_FULL;
 			hw->autoneg_advertised = ADVERTISE_10_FULL;
-		}  else if ((ecmd->advertising & MY_ADV_MASK) ==
-				ADVERTISE_10_HALF) {
+		}  else if ((advertising & MY_ADV_MASK) == ADVERTISE_10_HALF) {
 			hw->MediaType = MEDIA_TYPE_10M_HALF;
 			hw->autoneg_advertised = ADVERTISE_10_HALF;
 		} else {
 			clear_bit(__ATL2_RESETTING, &adapter->flags);
 			return -EINVAL;
 		}
-		ecmd->advertising = hw->autoneg_advertised |
+		advertising = hw->autoneg_advertised |
 			ADVERTISED_TP | ADVERTISED_Autoneg;
 	} else {
 		clear_bit(__ATL2_RESETTING, &adapter->flags);
@@ -2080,8 +2086,6 @@ static int atl2_nway_reset(struct net_device *netdev)
 }
 
 static const struct ethtool_ops atl2_ethtool_ops = {
-	.get_settings		= atl2_get_settings,
-	.set_settings		= atl2_set_settings,
 	.get_drvinfo		= atl2_get_drvinfo,
 	.get_regs_len		= atl2_get_regs_len,
 	.get_regs		= atl2_get_regs,
@@ -2094,6 +2098,8 @@ static int atl2_nway_reset(struct net_device *netdev)
 	.get_eeprom_len		= atl2_get_eeprom_len,
 	.get_eeprom		= atl2_get_eeprom,
 	.set_eeprom		= atl2_set_eeprom,
+	.get_link_ksettings	= atl2_get_link_ksettings,
+	.set_link_ksettings	= atl2_set_link_ksettings,
 };
 
 #define LBYTESWAP(a)  ((((a) & 0x00ff00ff) << 8) | \
-- 
1.7.4.4
