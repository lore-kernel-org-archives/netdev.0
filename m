From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] infiniband: nes: nes_nic: use new api ethtool_{get|set}_link_ksettings
Date: Tue, 25 Oct 2016 17:29:47 +0200
Message-ID: <1477409387-25056-1-git-send-email-tremyfr@gmail.com>
Cc: linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org, Philippe Reynes <tremyfr@gmail.com>
To: faisal.latif@intel.com, dledford@redhat.com, sean.hefty@intel.com,
        hal.rosenstock@gmail.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:37905 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752089AbcJYPa1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Oct 2016 11:30:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/infiniband/hw/nes/nes_nic.c |   76 +++++++++++++++++++---------------
 1 files changed, 42 insertions(+), 34 deletions(-)

diff --git a/drivers/infiniband/hw/nes/nes_nic.c b/drivers/infiniband/hw/nes/nes_nic.c
index 7f8597d..ad3ebe7 100644
--- a/drivers/infiniband/hw/nes/nes_nic.c
+++ b/drivers/infiniband/hw/nes/nes_nic.c
@@ -1461,7 +1461,8 @@ static int nes_netdev_set_pauseparam(struct net_device *netdev,
 /**
  * nes_netdev_get_settings
  */
-static int nes_netdev_get_settings(struct net_device *netdev, struct ethtool_cmd *et_cmd)
+static int nes_netdev_get_link_ksettings(struct net_device *netdev,
+					 struct ethtool_link_ksettings *cmd)
 {
 	struct nes_vnic *nesvnic = netdev_priv(netdev);
 	struct nes_device *nesdev = nesvnic->nesdev;
@@ -1470,54 +1471,59 @@ static int nes_netdev_get_settings(struct net_device *netdev, struct ethtool_cmd
 	u8 phy_type = nesadapter->phy_type[mac_index];
 	u8 phy_index = nesadapter->phy_index[mac_index];
 	u16 phy_data;
+	u32 supported, advertising;
 
-	et_cmd->duplex = DUPLEX_FULL;
-	et_cmd->port   = PORT_MII;
-	et_cmd->maxtxpkt = 511;
-	et_cmd->maxrxpkt = 511;
+	cmd->base.duplex = DUPLEX_FULL;
+	cmd->base.port   = PORT_MII;
 
 	if (nesadapter->OneG_Mode) {
-		ethtool_cmd_speed_set(et_cmd, SPEED_1000);
+		cmd->base.speed = SPEED_1000;
 		if (phy_type == NES_PHY_TYPE_PUMA_1G) {
-			et_cmd->supported   = SUPPORTED_1000baseT_Full;
-			et_cmd->advertising = ADVERTISED_1000baseT_Full;
-			et_cmd->autoneg     = AUTONEG_DISABLE;
-			et_cmd->transceiver = XCVR_INTERNAL;
-			et_cmd->phy_address = mac_index;
+			supported   = SUPPORTED_1000baseT_Full;
+			advertising = ADVERTISED_1000baseT_Full;
+			cmd->base.autoneg     = AUTONEG_DISABLE;
+			cmd->base.phy_address = mac_index;
 		} else {
 			unsigned long flags;
-			et_cmd->supported   = SUPPORTED_1000baseT_Full
-					    | SUPPORTED_Autoneg;
-			et_cmd->advertising = ADVERTISED_1000baseT_Full
-					    | ADVERTISED_Autoneg;
+
+			supported = SUPPORTED_1000baseT_Full
+				| SUPPORTED_Autoneg;
+			advertising = ADVERTISED_1000baseT_Full
+				| ADVERTISED_Autoneg;
 			spin_lock_irqsave(&nesadapter->phy_lock, flags);
 			nes_read_1G_phy_reg(nesdev, 0, phy_index, &phy_data);
 			spin_unlock_irqrestore(&nesadapter->phy_lock, flags);
 			if (phy_data & 0x1000)
-				et_cmd->autoneg = AUTONEG_ENABLE;
+				cmd->base.autoneg = AUTONEG_ENABLE;
 			else
-				et_cmd->autoneg = AUTONEG_DISABLE;
-			et_cmd->transceiver = XCVR_EXTERNAL;
-			et_cmd->phy_address = phy_index;
+				cmd->base.autoneg = AUTONEG_DISABLE;
+			cmd->base.phy_address = phy_index;
 		}
+		ethtool_convert_legacy_u32_to_link_mode(
+			cmd->link_modes.supported, supported);
+		ethtool_convert_legacy_u32_to_link_mode(
+			cmd->link_modes.advertising, advertising);
 		return 0;
 	}
 	if ((phy_type == NES_PHY_TYPE_ARGUS) ||
 	    (phy_type == NES_PHY_TYPE_SFP_D) ||
 	    (phy_type == NES_PHY_TYPE_KR)) {
-		et_cmd->transceiver = XCVR_EXTERNAL;
-		et_cmd->port        = PORT_FIBRE;
-		et_cmd->supported   = SUPPORTED_FIBRE;
-		et_cmd->advertising = ADVERTISED_FIBRE;
-		et_cmd->phy_address = phy_index;
+		cmd->base.port        = PORT_FIBRE;
+		supported   = SUPPORTED_FIBRE;
+		advertising = ADVERTISED_FIBRE;
+		cmd->base.phy_address = phy_index;
 	} else {
-		et_cmd->transceiver = XCVR_INTERNAL;
-		et_cmd->supported   = SUPPORTED_10000baseT_Full;
-		et_cmd->advertising = ADVERTISED_10000baseT_Full;
-		et_cmd->phy_address = mac_index;
+		supported   = SUPPORTED_10000baseT_Full;
+		advertising = ADVERTISED_10000baseT_Full;
+		cmd->base.phy_address = mac_index;
 	}
-	ethtool_cmd_speed_set(et_cmd, SPEED_10000);
-	et_cmd->autoneg = AUTONEG_DISABLE;
+	cmd->base.speed = SPEED_10000;
+	cmd->base.autoneg = AUTONEG_DISABLE;
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.supported,
+						supported);
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.advertising,
+						advertising);
+
 	return 0;
 }
 
@@ -1525,7 +1531,9 @@ static int nes_netdev_get_settings(struct net_device *netdev, struct ethtool_cmd
 /**
  * nes_netdev_set_settings
  */
-static int nes_netdev_set_settings(struct net_device *netdev, struct ethtool_cmd *et_cmd)
+static int
+nes_netdev_set_link_ksettings(struct net_device *netdev,
+			      const struct ethtool_link_ksettings *cmd)
 {
 	struct nes_vnic *nesvnic = netdev_priv(netdev);
 	struct nes_device *nesdev = nesvnic->nesdev;
@@ -1539,7 +1547,7 @@ static int nes_netdev_set_settings(struct net_device *netdev, struct ethtool_cmd
 
 		spin_lock_irqsave(&nesadapter->phy_lock, flags);
 		nes_read_1G_phy_reg(nesdev, 0, phy_index, &phy_data);
-		if (et_cmd->autoneg) {
+		if (cmd->base.autoneg) {
 			/* Turn on Full duplex, Autoneg, and restart autonegotiation */
 			phy_data |= 0x1300;
 		} else {
@@ -1556,8 +1564,6 @@ static int nes_netdev_set_settings(struct net_device *netdev, struct ethtool_cmd
 
 static const struct ethtool_ops nes_ethtool_ops = {
 	.get_link = ethtool_op_get_link,
-	.get_settings = nes_netdev_get_settings,
-	.set_settings = nes_netdev_set_settings,
 	.get_strings = nes_netdev_get_strings,
 	.get_sset_count = nes_netdev_get_sset_count,
 	.get_ethtool_stats = nes_netdev_get_ethtool_stats,
@@ -1566,6 +1572,8 @@ static int nes_netdev_set_settings(struct net_device *netdev, struct ethtool_cmd
 	.set_coalesce = nes_netdev_set_coalesce,
 	.get_pauseparam = nes_netdev_get_pauseparam,
 	.set_pauseparam = nes_netdev_set_pauseparam,
+	.get_link_ksettings = nes_netdev_get_link_ksettings,
+	.set_link_ksettings = nes_netdev_set_link_ksettings,
 };
 
 static void nes_vlan_mode(struct net_device *netdev, struct nes_device *nesdev, netdev_features_t features)
-- 
1.7.4.4
