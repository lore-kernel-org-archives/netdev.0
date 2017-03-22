From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: vmxnet3: use new api ethtool_{get|set}_link_ksettings
Date: Wed, 22 Mar 2017 08:27:57 +0100
Message-ID: <1490167677-27130-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: skhare@vmware.com, pv-drivers@vmware.com, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/vmxnet3/vmxnet3_ethtool.c |   25 ++++++++++++++-----------
 1 files changed, 14 insertions(+), 11 deletions(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_ethtool.c b/drivers/net/vmxnet3/vmxnet3_ethtool.c
index f88ffaf..2ff2731 100644
--- a/drivers/net/vmxnet3/vmxnet3_ethtool.c
+++ b/drivers/net/vmxnet3/vmxnet3_ethtool.c
@@ -471,22 +471,25 @@ int vmxnet3_set_features(struct net_device *netdev, netdev_features_t features)
 
 
 static int
-vmxnet3_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
+vmxnet3_get_link_ksettings(struct net_device *netdev,
+			   struct ethtool_link_ksettings *ecmd)
 {
 	struct vmxnet3_adapter *adapter = netdev_priv(netdev);
 
-	ecmd->supported = SUPPORTED_10000baseT_Full | SUPPORTED_1000baseT_Full |
-			  SUPPORTED_TP;
-	ecmd->advertising = ADVERTISED_TP;
-	ecmd->port = PORT_TP;
-	ecmd->transceiver = XCVR_INTERNAL;
+	ethtool_link_ksettings_zero_link_mode(ecmd, supported);
+	ethtool_link_ksettings_add_link_mode(ecmd, supported, 10000baseT_Full);
+	ethtool_link_ksettings_add_link_mode(ecmd, supported, 1000baseT_Full);
+	ethtool_link_ksettings_add_link_mode(ecmd, supported, TP);
+	ethtool_link_ksettings_zero_link_mode(ecmd, advertising);
+	ethtool_link_ksettings_add_link_mode(ecmd, advertising, TP);
+	ecmd->base.port = PORT_TP;
 
 	if (adapter->link_speed) {
-		ethtool_cmd_speed_set(ecmd, adapter->link_speed);
-		ecmd->duplex = DUPLEX_FULL;
+		ecmd->base.speed = adapter->link_speed;
+		ecmd->base.duplex = DUPLEX_FULL;
 	} else {
-		ethtool_cmd_speed_set(ecmd, SPEED_UNKNOWN);
-		ecmd->duplex = DUPLEX_UNKNOWN;
+		ecmd->base.speed = SPEED_UNKNOWN;
+		ecmd->base.duplex = DUPLEX_UNKNOWN;
 	}
 	return 0;
 }
@@ -880,7 +883,6 @@ int vmxnet3_set_features(struct net_device *netdev, netdev_features_t features)
 }
 
 static const struct ethtool_ops vmxnet3_ethtool_ops = {
-	.get_settings      = vmxnet3_get_settings,
 	.get_drvinfo       = vmxnet3_get_drvinfo,
 	.get_regs_len      = vmxnet3_get_regs_len,
 	.get_regs          = vmxnet3_get_regs,
@@ -900,6 +902,7 @@ int vmxnet3_set_features(struct net_device *netdev, netdev_features_t features)
 	.get_rxfh          = vmxnet3_get_rss,
 	.set_rxfh          = vmxnet3_set_rss,
 #endif
+	.get_link_ksettings = vmxnet3_get_link_ksettings,
 };
 
 void vmxnet3_set_ethtool_ops(struct net_device *netdev)
-- 
1.7.4.4
