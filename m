From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 4/5] igbvf: use new API ethtool_{get|set}_link_ksettings
Date: Tue, 21 Mar 2017 16:00:27 -0700
Message-ID: <20170321230028.69510-5-jeffrey.t.kirsher@intel.com>
References: <20170321230028.69510-1-jeffrey.t.kirsher@intel.com>
Cc: Philippe Reynes <tremyfr@gmail.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:21237 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1758202AbdCUXNY (ORCPT <rfc822;netdev@vger.kernel.org>);
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
 drivers/net/ethernet/intel/igbvf/ethtool.c | 38 +++++++++++++++---------------
 1 file changed, 19 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/intel/igbvf/ethtool.c b/drivers/net/ethernet/intel/igbvf/ethtool.c
index 8dea1b1367ef..34faa113a8a0 100644
--- a/drivers/net/ethernet/intel/igbvf/ethtool.c
+++ b/drivers/net/ethernet/intel/igbvf/ethtool.c
@@ -71,45 +71,45 @@ static const char igbvf_gstrings_test[][ETH_GSTRING_LEN] = {
 
 #define IGBVF_TEST_LEN ARRAY_SIZE(igbvf_gstrings_test)
 
-static int igbvf_get_settings(struct net_device *netdev,
-			      struct ethtool_cmd *ecmd)
+static int igbvf_get_link_ksettings(struct net_device *netdev,
+				    struct ethtool_link_ksettings *cmd)
 {
 	struct igbvf_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
 	u32 status;
 
-	ecmd->supported   = SUPPORTED_1000baseT_Full;
+	ethtool_link_ksettings_zero_link_mode(cmd, supported);
+	ethtool_link_ksettings_add_link_mode(cmd, supported, 1000baseT_Full);
+	ethtool_link_ksettings_zero_link_mode(cmd, advertising);
+	ethtool_link_ksettings_add_link_mode(cmd, advertising, 1000baseT_Full);
 
-	ecmd->advertising = ADVERTISED_1000baseT_Full;
-
-	ecmd->port = -1;
-	ecmd->transceiver = XCVR_DUMMY1;
+	cmd->base.port = -1;
 
 	status = er32(STATUS);
 	if (status & E1000_STATUS_LU) {
 		if (status & E1000_STATUS_SPEED_1000)
-			ethtool_cmd_speed_set(ecmd, SPEED_1000);
+			cmd->base.speed = SPEED_1000;
 		else if (status & E1000_STATUS_SPEED_100)
-			ethtool_cmd_speed_set(ecmd, SPEED_100);
+			cmd->base.speed = SPEED_100;
 		else
-			ethtool_cmd_speed_set(ecmd, SPEED_10);
+			cmd->base.speed = SPEED_10;
 
 		if (status & E1000_STATUS_FD)
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
 
-	ecmd->autoneg = AUTONEG_DISABLE;
+	cmd->base.autoneg = AUTONEG_DISABLE;
 
 	return 0;
 }
 
-static int igbvf_set_settings(struct net_device *netdev,
-			      struct ethtool_cmd *ecmd)
+static int igbvf_set_link_ksettings(struct net_device *netdev,
+				    const struct ethtool_link_ksettings *cmd)
 {
 	return -EOPNOTSUPP;
 }
@@ -443,8 +443,6 @@ static void igbvf_get_strings(struct net_device *netdev, u32 stringset,
 }
 
 static const struct ethtool_ops igbvf_ethtool_ops = {
-	.get_settings		= igbvf_get_settings,
-	.set_settings		= igbvf_set_settings,
 	.get_drvinfo		= igbvf_get_drvinfo,
 	.get_regs_len		= igbvf_get_regs_len,
 	.get_regs		= igbvf_get_regs,
@@ -467,6 +465,8 @@ static const struct ethtool_ops igbvf_ethtool_ops = {
 	.get_ethtool_stats	= igbvf_get_ethtool_stats,
 	.get_coalesce		= igbvf_get_coalesce,
 	.set_coalesce		= igbvf_set_coalesce,
+	.get_link_ksettings	= igbvf_get_link_ksettings,
+	.set_link_ksettings	= igbvf_set_link_ksettings,
 };
 
 void igbvf_set_ethtool_ops(struct net_device *netdev)
-- 
2.12.0
