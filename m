From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: qlogic: qla3xxx: use new api ethtool_{get|set}_link_ksettings
Date: Sun, 19 Feb 2017 00:19:04 +0100
Message-ID: <1487459944-32311-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: davem@davemloft.net, Dept-GELinuxNICDev@cavium.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

As I don't have the hardware, I'd be very pleased if
someone may test this patch.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/qlogic/qla3xxx.c |   29 ++++++++++++++++++-----------
 1 files changed, 18 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qla3xxx.c b/drivers/net/ethernet/qlogic/qla3xxx.c
index ea38236..2991179 100644
--- a/drivers/net/ethernet/qlogic/qla3xxx.c
+++ b/drivers/net/ethernet/qlogic/qla3xxx.c
@@ -1707,23 +1707,30 @@ static int ql_get_full_dup(struct ql3_adapter *qdev)
 	return status;
 }
 
-static int ql_get_settings(struct net_device *ndev, struct ethtool_cmd *ecmd)
+static int ql_get_link_ksettings(struct net_device *ndev,
+				 struct ethtool_link_ksettings *cmd)
 {
 	struct ql3_adapter *qdev = netdev_priv(ndev);
+	u32 supported, advertising;
 
-	ecmd->transceiver = XCVR_INTERNAL;
-	ecmd->supported = ql_supported_modes(qdev);
+	supported = ql_supported_modes(qdev);
 
 	if (test_bit(QL_LINK_OPTICAL, &qdev->flags)) {
-		ecmd->port = PORT_FIBRE;
+		cmd->base.port = PORT_FIBRE;
 	} else {
-		ecmd->port = PORT_TP;
-		ecmd->phy_address = qdev->PHYAddr;
+		cmd->base.port = PORT_TP;
+		cmd->base.phy_address = qdev->PHYAddr;
 	}
-	ecmd->advertising = ql_supported_modes(qdev);
-	ecmd->autoneg = ql_get_auto_cfg_status(qdev);
-	ethtool_cmd_speed_set(ecmd, ql_get_speed(qdev));
-	ecmd->duplex = ql_get_full_dup(qdev);
+	advertising = ql_supported_modes(qdev);
+	cmd->base.autoneg = ql_get_auto_cfg_status(qdev);
+	cmd->base.speed = ql_get_speed(qdev);
+	cmd->base.duplex = ql_get_full_dup(qdev);
+
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.supported,
+						supported);
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.advertising,
+						advertising);
+
 	return 0;
 }
 
@@ -1769,12 +1776,12 @@ static void ql_get_pauseparam(struct net_device *ndev,
 }
 
 static const struct ethtool_ops ql3xxx_ethtool_ops = {
-	.get_settings = ql_get_settings,
 	.get_drvinfo = ql_get_drvinfo,
 	.get_link = ethtool_op_get_link,
 	.get_msglevel = ql_get_msglevel,
 	.set_msglevel = ql_set_msglevel,
 	.get_pauseparam = ql_get_pauseparam,
+	.get_link_ksettings = ql_get_link_ksettings,
 };
 
 static int ql_populate_free_queue(struct ql3_adapter *qdev)
-- 
1.7.4.4
