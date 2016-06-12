From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: ethernet: enic: move to new ethtool api {get|set}_link_ksettings
Date: Sun, 12 Jun 2016 23:30:54 +0200
Message-ID: <1465767054-28765-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Philippe Reynes <tremyfr@gmail.com>
To: benve@cisco.com, ssujith@cisco.com, _govind@gmx.com,
	neepatel@cisco.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ethtool api {get|set}_settings is deprecated.
We move the enic driver to new api {get|set}_link_ksettings.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/cisco/enic/enic_ethtool.c |   28 +++++++++++++----------
 1 files changed, 16 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/cisco/enic/enic_ethtool.c b/drivers/net/ethernet/cisco/enic/enic_ethtool.c
index f44a39c..fd3980c 100644
--- a/drivers/net/ethernet/cisco/enic/enic_ethtool.c
+++ b/drivers/net/ethernet/cisco/enic/enic_ethtool.c
@@ -103,25 +103,29 @@ static void enic_intr_coal_set_rx(struct enic *enic, u32 timer)
 	}
 }
 
-static int enic_get_settings(struct net_device *netdev,
-	struct ethtool_cmd *ecmd)
+static int enic_get_ksettings(struct net_device *netdev,
+			      struct ethtool_link_ksettings *ecmd)
 {
 	struct enic *enic = netdev_priv(netdev);
+	struct ethtool_link_settings *base = &ecmd->base;
 
-	ecmd->supported = (SUPPORTED_10000baseT_Full | SUPPORTED_FIBRE);
-	ecmd->advertising = (ADVERTISED_10000baseT_Full | ADVERTISED_FIBRE);
-	ecmd->port = PORT_FIBRE;
-	ecmd->transceiver = XCVR_EXTERNAL;
+	ethtool_link_ksettings_add_link_mode(ecmd, supported,
+					     10000baseT_Full);
+	ethtool_link_ksettings_add_link_mode(ecmd, supported, FIBRE);
+	ethtool_link_ksettings_add_link_mode(ecmd, advertising,
+					     10000baseT_Full);
+	ethtool_link_ksettings_add_link_mode(ecmd, advertising, FIBRE);
+	base->port = PORT_FIBRE;
 
 	if (netif_carrier_ok(netdev)) {
-		ethtool_cmd_speed_set(ecmd, vnic_dev_port_speed(enic->vdev));
-		ecmd->duplex = DUPLEX_FULL;
+		base->speed = vnic_dev_port_speed(enic->vdev);
+		base->duplex = DUPLEX_FULL;
 	} else {
-		ethtool_cmd_speed_set(ecmd, SPEED_UNKNOWN);
-		ecmd->duplex = DUPLEX_UNKNOWN;
+		base->speed = SPEED_UNKNOWN;
+		base->duplex = DUPLEX_UNKNOWN;
 	}
 
-	ecmd->autoneg = AUTONEG_DISABLE;
+	base->autoneg = AUTONEG_DISABLE;
 
 	return 0;
 }
@@ -500,7 +504,6 @@ static int enic_set_rxfh(struct net_device *netdev, const u32 *indir,
 }
 
 static const struct ethtool_ops enic_ethtool_ops = {
-	.get_settings = enic_get_settings,
 	.get_drvinfo = enic_get_drvinfo,
 	.get_msglevel = enic_get_msglevel,
 	.set_msglevel = enic_set_msglevel,
@@ -516,6 +519,7 @@ static const struct ethtool_ops enic_ethtool_ops = {
 	.get_rxfh_key_size = enic_get_rxfh_key_size,
 	.get_rxfh = enic_get_rxfh,
 	.set_rxfh = enic_set_rxfh,
+	.get_link_ksettings = enic_get_ksettings,
 };
 
 void enic_set_ethtool_ops(struct net_device *netdev)
-- 
1.7.4.4
