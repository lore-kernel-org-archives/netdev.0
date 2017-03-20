From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/13] i40evf: use new api ethtool_{get|set}_link_ksettings
Date: Mon, 20 Mar 2017 16:47:01 -0700
Message-ID: <20170320234712.84157-3-jeffrey.t.kirsher@intel.com>
References: <20170320234712.84157-1-jeffrey.t.kirsher@intel.com>
Cc: Philippe Reynes <tremyfr@gmail.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:59023 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754163AbdCTXrT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 20 Mar 2017 19:47:19 -0400
In-Reply-To: <20170320234712.84157-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Philippe Reynes <tremyfr@gmail.com>

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

As I don't have the hardware, I'd be very pleased if
someone may test this patch.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c | 31 +++++++++++-----------
 1 file changed, 15 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c b/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
index 272d600c1ed0..122efbd29a19 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
@@ -64,51 +64,50 @@ static const struct i40evf_stats i40evf_gstrings_stats[] = {
 	(I40EVF_GLOBAL_STATS_LEN + I40EVF_QUEUE_STATS_LEN(_dev))
 
 /**
- * i40evf_get_settings - Get Link Speed and Duplex settings
+ * i40evf_get_link_ksettings - Get Link Speed and Duplex settings
  * @netdev: network interface device structure
- * @ecmd: ethtool command
+ * @cmd: ethtool command
  *
  * Reports speed/duplex settings. Because this is a VF, we don't know what
  * kind of link we really have, so we fake it.
  **/
-static int i40evf_get_settings(struct net_device *netdev,
-			       struct ethtool_cmd *ecmd)
+static int i40evf_get_link_ksettings(struct net_device *netdev,
+				     struct ethtool_link_ksettings *cmd)
 {
 	struct i40evf_adapter *adapter = netdev_priv(netdev);
 
-	ecmd->supported = 0;
-	ecmd->autoneg = AUTONEG_DISABLE;
-	ecmd->transceiver = XCVR_DUMMY1;
-	ecmd->port = PORT_NONE;
+	ethtool_link_ksettings_zero_link_mode(cmd, supported);
+	cmd->base.autoneg = AUTONEG_DISABLE;
+	cmd->base.port = PORT_NONE;
 	/* Set speed and duplex */
 	switch (adapter->link_speed) {
 	case I40E_LINK_SPEED_40GB:
-		ethtool_cmd_speed_set(ecmd, SPEED_40000);
+		cmd->base.speed = SPEED_40000;
 		break;
 	case I40E_LINK_SPEED_25GB:
 #ifdef SPEED_25000
-		ethtool_cmd_speed_set(ecmd, SPEED_25000);
+		cmd->base.speed = SPEED_25000;
 #else
 		netdev_info(netdev,
 			    "Speed is 25G, display not supported by this version of ethtool.\n");
 #endif
 		break;
 	case I40E_LINK_SPEED_20GB:
-		ethtool_cmd_speed_set(ecmd, SPEED_20000);
+		cmd->base.speed = SPEED_20000;
 		break;
 	case I40E_LINK_SPEED_10GB:
-		ethtool_cmd_speed_set(ecmd, SPEED_10000);
+		cmd->base.speed = SPEED_10000;
 		break;
 	case I40E_LINK_SPEED_1GB:
-		ethtool_cmd_speed_set(ecmd, SPEED_1000);
+		cmd->base.speed = SPEED_1000;
 		break;
 	case I40E_LINK_SPEED_100MB:
-		ethtool_cmd_speed_set(ecmd, SPEED_100);
+		cmd->base.speed = SPEED_100;
 		break;
 	default:
 		break;
 	}
-	ecmd->duplex = DUPLEX_FULL;
+	cmd->base.duplex = DUPLEX_FULL;
 
 	return 0;
 }
@@ -643,7 +642,6 @@ static int i40evf_set_rxfh(struct net_device *netdev, const u32 *indir,
 }
 
 static const struct ethtool_ops i40evf_ethtool_ops = {
-	.get_settings		= i40evf_get_settings,
 	.get_drvinfo		= i40evf_get_drvinfo,
 	.get_link		= ethtool_op_get_link,
 	.get_ringparam		= i40evf_get_ringparam,
@@ -663,6 +661,7 @@ static const struct ethtool_ops i40evf_ethtool_ops = {
 	.set_rxfh		= i40evf_set_rxfh,
 	.get_channels		= i40evf_get_channels,
 	.get_rxfh_key_size	= i40evf_get_rxfh_key_size,
+	.get_link_ksettings	= i40evf_get_link_ksettings,
 };
 
 /**
-- 
2.12.0
