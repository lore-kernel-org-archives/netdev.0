From: "Merav Sicron" <meravs@broadcom.com>
Subject: [net-next patch 11/12] bnx2x: Add FCoE capabilities
 advertisement
Date: Wed, 13 Jun 2012 15:44:23 +0300
Message-ID: <1339591464-10554-12-git-send-email-meravs@broadcom.com>
References: <1339591464-10554-1-git-send-email-meravs@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Merav Sicron" <meravs@broadcom.com>,
	"Barak Witkowski" <barak@broadcom.com>
To: eilong@broadcom.com, davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2749 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752722Ab2FMJm7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jun 2012 05:42:59 -0400
In-Reply-To: <1339591464-10554-1-git-send-email-meravs@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Barak Witkowski <barak@broadcom.com>

1. When FCoE offload driver is registered, copy its capabilities to the chip
   scratchpad.
2. Copy FCoE/iSCSI MAC addresses in aligned manner to chip scratchpad.

Signed-off-by: Barak Witkowski <barak@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h      |    1 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h  |   41 +++++++++++++++++++++-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |   41 +++++++++++++++++++---
 drivers/net/ethernet/broadcom/cnic_if.h          |    6 ++++
 4 files changed, 83 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index 1f2e03a..47ec384 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -1332,6 +1332,7 @@ struct bnx2x {
 #define NO_ISCSI_FLAG			(1 << 14)
 #define NO_FCOE_FLAG			(1 << 15)
 #define BC_SUPPORTS_PFC_STATS		(1 << 17)
+#define BC_SUPPORTS_FCOE_FEATURES	(1 << 19)
 #define USING_SINGLE_MSIX_FLAG		(1 << 20)
 #define BC_SUPPORTS_DCBX_MSG_NON_PMF	(1 << 21)
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
index 6b77630..6bad5c4 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
@@ -1250,6 +1250,7 @@ struct drv_func_mb {
 	#define REQ_BC_VER_4_VRFY_AFEX_SUPPORTED        0x00070002
 	#define REQ_BC_VER_4_SFP_TX_DISABLE_SUPPORTED   0x00070014
 	#define REQ_BC_VER_4_PFC_STATS_SUPPORTED        0x00070201
+	#define REQ_BC_VER_4_FCOE_FEATURES              0x00070209
 
 	#define DRV_MSG_CODE_DCBX_ADMIN_PMF_MSG         0xb0000000
 	#define DRV_MSG_CODE_DCBX_PMF_DRV_OK            0xb2000000
@@ -2698,8 +2699,46 @@ struct host_func_stats {
 /* VIC definitions */
 #define VICSTATST_UIF_INDEX 2
 
+/* FCoE capabilities required from the driver */
+struct fcoe_capabilities {
+	u32 capability1;
+	/* Maximum number of I/Os per connection */
+	#define FCOE_IOS_PER_CONNECTION_MASK    0x0000ffff
+	#define FCOE_IOS_PER_CONNECTION_SHIFT   0
+	/* Maximum number of Logins per port */
+	#define FCOE_LOGINS_PER_PORT_MASK       0xffff0000
+	#define FCOE_LOGINS_PER_PORT_SHIFT   16
+
+	u32 capability2;
+	/* Maximum number of exchanges */
+	#define FCOE_NUMBER_OF_EXCHANGES_MASK   0x0000ffff
+	#define FCOE_NUMBER_OF_EXCHANGES_SHIFT  0
+	/* Maximum NPIV WWN per port */
+	#define FCOE_NPIV_WWN_PER_PORT_MASK     0xffff0000
+	#define FCOE_NPIV_WWN_PER_PORT_SHIFT    16
+
+	u32 capability3;
+	/* Maximum number of targets supported */
+	#define FCOE_TARGETS_SUPPORTED_MASK     0x0000ffff
+	#define FCOE_TARGETS_SUPPORTED_SHIFT    0
+	/* Maximum number of outstanding commands across all connections */
+	#define FCOE_OUTSTANDING_COMMANDS_MASK  0xffff0000
+	#define FCOE_OUTSTANDING_COMMANDS_SHIFT 16
+
+	u32 capability4;
+	#define FCOE_CAPABILITY4_STATEFUL			0x00000001
+	#define FCOE_CAPABILITY4_STATELESS			0x00000002
+	#define FCOE_CAPABILITY4_CAPABILITIES_REPORTED_VALID	0x00000004
+};
+
+struct glob_ncsi_oem_data {
+	u32 driver_version;
+	u32 unused[3];
+	struct fcoe_capabilities fcoe_features[NVM_PATH_MAX][PORT_MAX];
+};
+
 /* current drv_info version */
-#define DRV_INFO_CUR_VER 1
+#define DRV_INFO_CUR_VER 2
 
 /* drv_info op codes supported */
 enum drv_info_opcode {
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 26a8296..eb3e55a 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -74,6 +74,8 @@
 #define FW_FILE_NAME_E1H	"bnx2x/bnx2x-e1h-" FW_FILE_VERSION ".fw"
 #define FW_FILE_NAME_E2		"bnx2x/bnx2x-e2-" FW_FILE_VERSION ".fw"
 
+#define MAC_LEADING_ZERO_CNT (ALIGN(ETH_ALEN, sizeof(u32)) - ETH_ALEN)
+
 /* Time in jiffies before concluding the transmitter is hung */
 #define TX_TIMEOUT		(5*HZ)
 
@@ -3060,7 +3062,8 @@ static void bnx2x_drv_info_fcoe_stat(struct bnx2x *bp)
 	struct fcoe_stats_info *fcoe_stat =
 		&bp->slowpath->drv_info_to_mcp.fcoe_stat;
 
-	memcpy(fcoe_stat->mac_local, bp->fip_mac, ETH_ALEN);
+	memcpy(fcoe_stat->mac_local + MAC_LEADING_ZERO_CNT,
+	       bp->fip_mac, ETH_ALEN);
 
 	fcoe_stat->qos_priority =
 		app->traffic_type_priority[LLFC_TRAFFIC_TYPE_FCOE];
@@ -3151,7 +3154,8 @@ static void bnx2x_drv_info_iscsi_stat(struct bnx2x *bp)
 	struct iscsi_stats_info *iscsi_stat =
 		&bp->slowpath->drv_info_to_mcp.iscsi_stat;
 
-	memcpy(iscsi_stat->mac_local, bp->cnic_eth_dev.iscsi_mac, ETH_ALEN);
+	memcpy(iscsi_stat->mac_local + MAC_LEADING_ZERO_CNT,
+	       bp->cnic_eth_dev.iscsi_mac, ETH_ALEN);
 
 	iscsi_stat->qos_priority =
 		app->traffic_type_priority[LLFC_TRAFFIC_TYPE_ISCSI];
@@ -9732,6 +9736,9 @@ static void __devinit bnx2x_get_common_hwinfo(struct bnx2x *bp)
 	bp->flags |= (val >= REQ_BC_VER_4_PFC_STATS_SUPPORTED) ?
 			BC_SUPPORTS_PFC_STATS : 0;
 
+	bp->flags |= (val >= REQ_BC_VER_4_FCOE_FEATURES) ?
+			BC_SUPPORTS_FCOE_FEATURES : 0;
+
 	bp->flags |= (val >= REQ_BC_VER_4_DCBX_ADMIN_MSG_NON_PMF) ?
 			BC_SUPPORTS_DCBX_MSG_NON_PMF : 0;
 	boot_mode = SHMEM_RD(bp,
@@ -12548,21 +12555,45 @@ static int bnx2x_drv_ctl(struct net_device *dev, struct drv_ctl_info *ctl)
 		break;
 	}
 	case DRV_CTL_ULP_REGISTER_CMD: {
-		int ulp_type = ctl->data.ulp_type;
+		int ulp_type = ctl->data.register_data.ulp_type;
 
 		if (CHIP_IS_E3(bp)) {
 			int idx = BP_FW_MB_IDX(bp);
-			u32 cap;
+			u32 cap = SHMEM2_RD(bp, drv_capabilities_flag[idx]);
+			int path = BP_PATH(bp);
+			int port = BP_PORT(bp);
+			int i;
+			u32 scratch_offset;
+			u32 *host_addr;
 
-			cap = SHMEM2_RD(bp, drv_capabilities_flag[idx]);
+			/* first write capability to shmem2 */
 			if (ulp_type == CNIC_ULP_ISCSI)
 				cap |= DRV_FLAGS_CAPABILITIES_LOADED_ISCSI;
 			else if (ulp_type == CNIC_ULP_FCOE)
 				cap |= DRV_FLAGS_CAPABILITIES_LOADED_FCOE;
 			SHMEM2_WR(bp, drv_capabilities_flag[idx], cap);
+
+			if ((ulp_type != CNIC_ULP_FCOE) ||
+			    (!SHMEM2_HAS(bp, ncsi_oem_data_addr)) ||
+			    (!(bp->flags &  BC_SUPPORTS_FCOE_FEATURES)))
+				break;
+
+			/* if reached here - should write fcoe capabilities */
+			scratch_offset = SHMEM2_RD(bp, ncsi_oem_data_addr);
+			if (!scratch_offset)
+				break;
+			scratch_offset += offsetof(struct glob_ncsi_oem_data,
+						   fcoe_features[path][port]);
+			host_addr = (u32 *) &(ctl->data.register_data.
+					      fcoe_features);
+			for (i = 0; i < sizeof(struct fcoe_capabilities);
+			     i += 4)
+				REG_WR(bp, scratch_offset + i,
+				       *(host_addr + i/4));
 		}
 		break;
 	}
+
 	case DRV_CTL_ULP_UNREGISTER_CMD: {
 		int ulp_type = ctl->data.ulp_type;
 
diff --git a/drivers/net/ethernet/broadcom/cnic_if.h b/drivers/net/ethernet/broadcom/cnic_if.h
index 289274e..82872e6 100644
--- a/drivers/net/ethernet/broadcom/cnic_if.h
+++ b/drivers/net/ethernet/broadcom/cnic_if.h
@@ -131,6 +131,11 @@ struct drv_ctl_l2_ring {
 	u32		cid;
 };
 
+struct drv_ctl_register_data {
+	int ulp_type;
+	struct fcoe_capabilities fcoe_features;
+};
+
 struct drv_ctl_info {
 	int	cmd;
 	union {
@@ -138,6 +143,7 @@ struct drv_ctl_info {
 		struct drv_ctl_io io;
 		struct drv_ctl_l2_ring ring;
 		int ulp_type;
+		struct drv_ctl_register_data register_data;
 		char bytes[MAX_DRV_CTL_DATA];
 	} data;
 };
-- 
1.7.10
