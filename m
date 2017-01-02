From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: emulex: benet: use new api ethtool_{get|set}_link_ksettings
Date: Mon,  2 Jan 2017 17:42:14 +0100
Message-ID: <1483375334-28056-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: sathya.perla@broadcom.com, ajit.khaparde@broadcom.com,
        sriharsha.basavapatna@broadcom.com, somnath.kotur@broadcom.com,
        davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/emulex/benet/be_ethtool.c |   73 +++++++++++-------------
 1 files changed, 34 insertions(+), 39 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_ethtool.c b/drivers/net/ethernet/emulex/benet/be_ethtool.c
index 0a48a31..7d1819c 100644
--- a/drivers/net/ethernet/emulex/benet/be_ethtool.c
+++ b/drivers/net/ethernet/emulex/benet/be_ethtool.c
@@ -606,7 +606,8 @@ bool be_pause_supported(struct be_adapter *adapter)
 		false : true;
 }
 
-static int be_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
+static int be_get_link_ksettings(struct net_device *netdev,
+				 struct ethtool_link_ksettings *cmd)
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
 	u8 link_status;
@@ -614,13 +615,14 @@ static int be_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 	int status;
 	u32 auto_speeds;
 	u32 fixed_speeds;
+	u32 supported = 0, advertising = 0;
 
 	if (adapter->phy.link_speed < 0) {
 		status = be_cmd_link_status_query(adapter, &link_speed,
 						  &link_status, 0);
 		if (!status)
 			be_link_status_update(adapter, link_status);
-		ethtool_cmd_speed_set(ecmd, link_speed);
+		cmd->base.speed = link_speed;
 
 		status = be_cmd_get_phy_info(adapter);
 		if (!status) {
@@ -629,58 +631,51 @@ static int be_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 
 			be_cmd_query_cable_type(adapter);
 
-			ecmd->supported =
+			supported =
 				convert_to_et_setting(adapter,
 						      auto_speeds |
 						      fixed_speeds);
-			ecmd->advertising =
+			advertising =
 				convert_to_et_setting(adapter, auto_speeds);
 
-			ecmd->port = be_get_port_type(adapter);
+			cmd->base.port = be_get_port_type(adapter);
 
 			if (adapter->phy.auto_speeds_supported) {
-				ecmd->supported |= SUPPORTED_Autoneg;
-				ecmd->autoneg = AUTONEG_ENABLE;
-				ecmd->advertising |= ADVERTISED_Autoneg;
+				supported |= SUPPORTED_Autoneg;
+				cmd->base.autoneg = AUTONEG_ENABLE;
+				advertising |= ADVERTISED_Autoneg;
 			}
 
-			ecmd->supported |= SUPPORTED_Pause;
+			supported |= SUPPORTED_Pause;
 			if (be_pause_supported(adapter))
-				ecmd->advertising |= ADVERTISED_Pause;
-
-			switch (adapter->phy.interface_type) {
-			case PHY_TYPE_KR_10GB:
-			case PHY_TYPE_KX4_10GB:
-				ecmd->transceiver = XCVR_INTERNAL;
-				break;
-			default:
-				ecmd->transceiver = XCVR_EXTERNAL;
-				break;
-			}
+				advertising |= ADVERTISED_Pause;
 		} else {
-			ecmd->port = PORT_OTHER;
-			ecmd->autoneg = AUTONEG_DISABLE;
-			ecmd->transceiver = XCVR_DUMMY1;
+			cmd->base.port = PORT_OTHER;
+			cmd->base.autoneg = AUTONEG_DISABLE;
 		}
 
 		/* Save for future use */
-		adapter->phy.link_speed = ethtool_cmd_speed(ecmd);
-		adapter->phy.port_type = ecmd->port;
-		adapter->phy.transceiver = ecmd->transceiver;
-		adapter->phy.autoneg = ecmd->autoneg;
-		adapter->phy.advertising = ecmd->advertising;
-		adapter->phy.supported = ecmd->supported;
+		adapter->phy.link_speed = cmd->base.speed;
+		adapter->phy.port_type = cmd->base.port;
+		adapter->phy.autoneg = cmd->base.autoneg;
+		adapter->phy.advertising = advertising;
+		adapter->phy.supported = supported;
 	} else {
-		ethtool_cmd_speed_set(ecmd, adapter->phy.link_speed);
-		ecmd->port = adapter->phy.port_type;
-		ecmd->transceiver = adapter->phy.transceiver;
-		ecmd->autoneg = adapter->phy.autoneg;
-		ecmd->advertising = adapter->phy.advertising;
-		ecmd->supported = adapter->phy.supported;
+		cmd->base.speed = adapter->phy.link_speed;
+		cmd->base.port = adapter->phy.port_type;
+		cmd->base.autoneg = adapter->phy.autoneg;
+		advertising = adapter->phy.advertising;
+		supported = adapter->phy.supported;
 	}
 
-	ecmd->duplex = netif_carrier_ok(netdev) ? DUPLEX_FULL : DUPLEX_UNKNOWN;
-	ecmd->phy_address = adapter->port_num;
+	cmd->base.duplex = netif_carrier_ok(netdev) ?
+		DUPLEX_FULL : DUPLEX_UNKNOWN;
+	cmd->base.phy_address = adapter->port_num;
+
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.supported,
+						supported);
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.advertising,
+						advertising);
 
 	return 0;
 }
@@ -1399,7 +1394,6 @@ static int be_set_priv_flags(struct net_device *netdev, u32 flags)
 }
 
 const struct ethtool_ops be_ethtool_ops = {
-	.get_settings = be_get_settings,
 	.get_drvinfo = be_get_drvinfo,
 	.get_wol = be_get_wol,
 	.set_wol = be_set_wol,
@@ -1433,5 +1427,6 @@ static int be_set_priv_flags(struct net_device *netdev, u32 flags)
 	.get_channels = be_get_channels,
 	.set_channels = be_set_channels,
 	.get_module_info = be_get_module_info,
-	.get_module_eeprom = be_get_module_eeprom
+	.get_module_eeprom = be_get_module_eeprom,
+	.get_link_ksettings = be_get_link_ksettings,
 };
-- 
1.7.4.4
