From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: intel: igbvf: use new api ethtool_{get|set}_link_ksettings
Date: Sun,  5 Feb 2017 23:55:19 +0100
Message-ID: <1486335319-16273-1-git-send-email-tremyfr@gmail.com>
Cc: intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Philippe Reynes <tremyfr@gmail.com>
To: jeffrey.t.kirsher@intel.com, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

As I don't have the hardware, I'd be very pleased if
someone may test this patch.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/intel/igbvf/ethtool.c |   38 ++++++++++++++--------------
 1 files changed, 19 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/intel/igbvf/ethtool.c b/drivers/net/ethernet/intel/igbvf/ethtool.c
index 8dea1b1..34faa11 100644
--- a/drivers/net/ethernet/intel/igbvf/ethtool.c
+++ b/drivers/net/ethernet/intel/igbvf/ethtool.c
@@ -71,45 +71,45 @@ struct igbvf_stats {
 
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
@@ -467,6 +465,8 @@ static void igbvf_get_strings(struct net_device *netdev, u32 stringset,
 	.get_ethtool_stats	= igbvf_get_ethtool_stats,
 	.get_coalesce		= igbvf_get_coalesce,
 	.set_coalesce		= igbvf_set_coalesce,
+	.get_link_ksettings	= igbvf_get_link_ksettings,
+	.set_link_ksettings	= igbvf_set_link_ksettings,
 };
 
 void igbvf_set_ethtool_ops(struct net_device *netdev)
-- 
1.7.4.4
