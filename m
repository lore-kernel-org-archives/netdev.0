From: Rajesh Borundia <rajesh.borundia@qlogic.com>
Subject: [PATCHv2 net-next 2/4] netxen_nic: Allow only useful and recommended firmware dump capture mask values
Date: Wed,  9 May 2012 11:55:28 -0400
Message-ID: <1336578930-25141-3-git-send-email-rajesh.borundia@qlogic.com>
References: <1336578930-25141-1-git-send-email-rajesh.borundia@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	Manish chopra <manish.chopra@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:30588 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1758286Ab2EIQQ1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 May 2012 12:16:27 -0400
In-Reply-To: <1336578930-25141-1-git-send-email-rajesh.borundia@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish chopra <manish.chopra@qlogic.com>

o 0x3, 0x7, 0xF, 0x1F, 0x3F, 0x7F and 0xFF are the allowed capture masks.

Signed-off-by: Manish chopra <manish.chopra@qlogic.com>
Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
---
 drivers/net/ethernet/qlogic/netxen/netxen_nic.h    |    3 +++
 .../ethernet/qlogic/netxen/netxen_nic_ethtool.c    |   18 ++++++++++--------
 2 files changed, 13 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic.h b/drivers/net/ethernet/qlogic/netxen/netxen_nic.h
index b5de8a7..ecc8d17 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic.h
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic.h
@@ -1201,6 +1201,9 @@ typedef struct {
 #define NX_FORCE_FW_RESET               0xdeaddead
 
 
+/* Fw dump levels */
+static const u32 FW_DUMP_LEVELS[] = { 0x3, 0x7, 0xf, 0x1f, 0x3f, 0x7f, 0xff };
+
 /* Flash read/write address */
 #define NX_FW_DUMP_REG1         0x00130060
 #define NX_FW_DUMP_REG2         0x001e0000
diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_ethtool.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_ethtool.c
index 8c39299..3973040 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_ethtool.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_ethtool.c
@@ -834,7 +834,7 @@ netxen_get_dump_flag(struct net_device *netdev, struct ethtool_dump *dump)
 static int
 netxen_set_dump(struct net_device *netdev, struct ethtool_dump *val)
 {
-	int ret = 0;
+	int i;
 	struct netxen_adapter *adapter = netdev_priv(netdev);
 	struct netxen_minidump *mdump = &adapter->mdump;
 
@@ -844,7 +844,7 @@ netxen_set_dump(struct net_device *netdev, struct ethtool_dump *val)
 			mdump->md_enabled = 1;
 		if (adapter->fw_mdump_rdy) {
 			netdev_info(netdev, "Previous dump not cleared, not forcing dump\n");
-			return ret;
+			return 0;
 		}
 		netdev_info(netdev, "Forcing a fw dump\n");
 		nx_dev_request_reset(adapter);
@@ -867,19 +867,21 @@ netxen_set_dump(struct net_device *netdev, struct ethtool_dump *val)
 		adapter->flags &= ~NETXEN_FW_RESET_OWNER;
 		break;
 	default:
-		if (val->flag <= NX_DUMP_MASK_MAX &&
-			val->flag >= NX_DUMP_MASK_MIN) {
-			mdump->md_capture_mask = val->flag & 0xff;
-			netdev_info(netdev, "Driver mask changed to: 0x%x\n",
+		for (i = 0; i < ARRAY_SIZE(FW_DUMP_LEVELS); i++) {
+			if (val->flag == FW_DUMP_LEVELS[i]) {
+				mdump->md_capture_mask = val->flag;
+				netdev_info(netdev,
+					"Driver mask changed to: 0x%x\n",
 					mdump->md_capture_mask);
-			break;
+				return 0;
+			}
 		}
 		netdev_info(netdev,
 			"Invalid dump level: 0x%x\n", val->flag);
 		return -EINVAL;
 	}
 
-	return ret;
+	return 0;
 }
 
 static int
-- 
1.6.3.3
