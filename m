From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 5/5] ixgb: use new API ethtool_{get|set}_link_ksettings
Date: Tue, 21 Mar 2017 16:00:28 -0700
Message-ID: <20170321230028.69510-6-jeffrey.t.kirsher@intel.com>
References: <20170321230028.69510-1-jeffrey.t.kirsher@intel.com>
Cc: Philippe Reynes <tremyfr@gmail.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:21237 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1758004AbdCUXNY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 21 Mar 2017 19:13:24 -0400
In-Reply-To: <20170321230028.69510-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Philippe Reynes <tremyfr@gmail.com>

The ethtool API {get|set}_settings is deprecated.
We move this driver to new API {get|set}_link_ksettings.

As I don't have the hardware, I'd be very pleased if
someone may test this patch.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgb/ixgb_ethtool.c | 39 +++++++++++++++-----------
 1 file changed, 23 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgb/ixgb_ethtool.c b/drivers/net/ethernet/intel/ixgb/ixgb_ethtool.c
index e5d72559cca9..d10a0d242dda 100644
--- a/drivers/net/ethernet/intel/ixgb/ixgb_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgb/ixgb_ethtool.c
@@ -94,24 +94,30 @@ static struct ixgb_stats ixgb_gstrings_stats[] = {
 #define IXGB_STATS_LEN	ARRAY_SIZE(ixgb_gstrings_stats)
 
 static int
-ixgb_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
+ixgb_get_link_ksettings(struct net_device *netdev,
+			struct ethtool_link_ksettings *cmd)
 {
 	struct ixgb_adapter *adapter = netdev_priv(netdev);
 
-	ecmd->supported = (SUPPORTED_10000baseT_Full | SUPPORTED_FIBRE);
-	ecmd->advertising = (ADVERTISED_10000baseT_Full | ADVERTISED_FIBRE);
-	ecmd->port = PORT_FIBRE;
-	ecmd->transceiver = XCVR_EXTERNAL;
+	ethtool_link_ksettings_zero_link_mode(cmd, supported);
+	ethtool_link_ksettings_add_link_mode(cmd, supported, 10000baseT_Full);
+	ethtool_link_ksettings_add_link_mode(cmd, supported, FIBRE);
+
+	ethtool_link_ksettings_zero_link_mode(cmd, advertising);
+	ethtool_link_ksettings_add_link_mode(cmd, advertising, 10000baseT_Full);
+	ethtool_link_ksettings_add_link_mode(cmd, advertising, FIBRE);
+
+	cmd->base.port = PORT_FIBRE;
 
 	if (netif_carrier_ok(adapter->netdev)) {
-		ethtool_cmd_speed_set(ecmd, SPEED_10000);
-		ecmd->duplex = DUPLEX_FULL;
+		cmd->base.speed = SPEED_10000;
+		cmd->base.duplex = DUPLEX_FULL;
 	} else {
-		ethtool_cmd_speed_set(ecmd, SPEED_UNKNOWN);
-		ecmd->duplex = DUPLEX_UNKNOWN;
+		cmd->base.speed = SPEED_UNKNOWN;
+		cmd->base.duplex = DUPLEX_UNKNOWN;
 	}
 
-	ecmd->autoneg = AUTONEG_DISABLE;
+	cmd->base.autoneg = AUTONEG_DISABLE;
 	return 0;
 }
 
@@ -126,13 +132,14 @@ void ixgb_set_speed_duplex(struct net_device *netdev)
 }
 
 static int
-ixgb_set_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
+ixgb_set_link_ksettings(struct net_device *netdev,
+			const struct ethtool_link_ksettings *cmd)
 {
 	struct ixgb_adapter *adapter = netdev_priv(netdev);
-	u32 speed = ethtool_cmd_speed(ecmd);
+	u32 speed = cmd->base.speed;
 
-	if (ecmd->autoneg == AUTONEG_ENABLE ||
-	    (speed + ecmd->duplex != SPEED_10000 + DUPLEX_FULL))
+	if (cmd->base.autoneg == AUTONEG_ENABLE ||
+	    (speed + cmd->base.duplex != SPEED_10000 + DUPLEX_FULL))
 		return -EINVAL;
 
 	if (netif_running(adapter->netdev)) {
@@ -630,8 +637,6 @@ ixgb_get_strings(struct net_device *netdev, u32 stringset, u8 *data)
 }
 
 static const struct ethtool_ops ixgb_ethtool_ops = {
-	.get_settings = ixgb_get_settings,
-	.set_settings = ixgb_set_settings,
 	.get_drvinfo = ixgb_get_drvinfo,
 	.get_regs_len = ixgb_get_regs_len,
 	.get_regs = ixgb_get_regs,
@@ -649,6 +654,8 @@ static const struct ethtool_ops ixgb_ethtool_ops = {
 	.set_phys_id = ixgb_set_phys_id,
 	.get_sset_count = ixgb_get_sset_count,
 	.get_ethtool_stats = ixgb_get_ethtool_stats,
+	.get_link_ksettings = ixgb_get_link_ksettings,
+	.set_link_ksettings = ixgb_set_link_ksettings,
 };
 
 void ixgb_set_ethtool_ops(struct net_device *netdev)
-- 
2.12.0
