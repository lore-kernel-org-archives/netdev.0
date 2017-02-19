From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: qlogic: qlge: use new api ethtool_{get|set}_link_ksettings
Date: Sun, 19 Feb 2017 23:21:41 +0100
Message-ID: <1487542901-26785-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: harish.patil@cavium.com, manish.chopra@cavium.com,
        Dept-GELinuxNICDev@cavium.com, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

As I don't have the hardware, I'd be very pleased if
someone may test this patch.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/qlogic/qlge/qlge_ethtool.c |   36 +++++++++++++---------
 1 files changed, 21 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_ethtool.c b/drivers/net/ethernet/qlogic/qlge/qlge_ethtool.c
index 5dade1f..31f4014 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_ethtool.c
@@ -375,28 +375,34 @@ static int ql_get_sset_count(struct net_device *dev, int sset)
 	}
 }
 
-static int ql_get_settings(struct net_device *ndev,
-			      struct ethtool_cmd *ecmd)
+static int ql_get_link_ksettings(struct net_device *ndev,
+				 struct ethtool_link_ksettings *ecmd)
 {
 	struct ql_adapter *qdev = netdev_priv(ndev);
+	u32 supported, advertising;
+
+	supported = SUPPORTED_10000baseT_Full;
+	advertising = ADVERTISED_10000baseT_Full;
 
-	ecmd->supported = SUPPORTED_10000baseT_Full;
-	ecmd->advertising = ADVERTISED_10000baseT_Full;
-	ecmd->transceiver = XCVR_EXTERNAL;
 	if ((qdev->link_status & STS_LINK_TYPE_MASK) ==
 				STS_LINK_TYPE_10GBASET) {
-		ecmd->supported |= (SUPPORTED_TP | SUPPORTED_Autoneg);
-		ecmd->advertising |= (ADVERTISED_TP | ADVERTISED_Autoneg);
-		ecmd->port = PORT_TP;
-		ecmd->autoneg = AUTONEG_ENABLE;
+		supported |= (SUPPORTED_TP | SUPPORTED_Autoneg);
+		advertising |= (ADVERTISED_TP | ADVERTISED_Autoneg);
+		ecmd->base.port = PORT_TP;
+		ecmd->base.autoneg = AUTONEG_ENABLE;
 	} else {
-		ecmd->supported |= SUPPORTED_FIBRE;
-		ecmd->advertising |= ADVERTISED_FIBRE;
-		ecmd->port = PORT_FIBRE;
+		supported |= SUPPORTED_FIBRE;
+		advertising |= ADVERTISED_FIBRE;
+		ecmd->base.port = PORT_FIBRE;
 	}
 
-	ethtool_cmd_speed_set(ecmd, SPEED_10000);
-	ecmd->duplex = DUPLEX_FULL;
+	ecmd->base.speed = SPEED_10000;
+	ecmd->base.duplex = DUPLEX_FULL;
+
+	ethtool_convert_legacy_u32_to_link_mode(ecmd->link_modes.supported,
+						supported);
+	ethtool_convert_legacy_u32_to_link_mode(ecmd->link_modes.advertising,
+						advertising);
 
 	return 0;
 }
@@ -706,7 +712,6 @@ static void ql_set_msglevel(struct net_device *ndev, u32 value)
 }
 
 const struct ethtool_ops qlge_ethtool_ops = {
-	.get_settings = ql_get_settings,
 	.get_drvinfo = ql_get_drvinfo,
 	.get_wol = ql_get_wol,
 	.set_wol = ql_set_wol,
@@ -724,5 +729,6 @@ static void ql_set_msglevel(struct net_device *ndev, u32 value)
 	.get_sset_count = ql_get_sset_count,
 	.get_strings = ql_get_strings,
 	.get_ethtool_stats = ql_get_ethtool_stats,
+	.get_link_ksettings = ql_get_link_ksettings,
 };
 
-- 
1.7.4.4
