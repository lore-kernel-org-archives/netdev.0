From: "Merav Sicron" <meravs@broadcom.com>
Subject: [net-next patch] bnx2x,bnx2fc,bnx2i,cnic: Add statistics
 support and FCoE capabilities advertisement
Date: Tue, 26 Jun 2012 14:31:19 +0300
Message-ID: <1340710279-18241-1-git-send-email-meravs@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Merav Sicron" <meravs@broadcom.com>,
	"Barak Witkowski" <barak@broadcom.com>,
	"Eddie Wai" <eddie.wai@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>,
	"Bhanu Prakash Gollapudi" <bprakash@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org, eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4058 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758434Ab2FZIYM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jun 2012 04:24:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Barak Witkowski <barak@broadcom.com>

1. When FCoE offload driver is registered, copy its capabilities to the chip
   scratchpad.
2. Copy FCoE/iSCSI MAC addresses in aligned manner to chip scratchpad.
3. Add FCoE/iSCSI statistics collection support

Signed-off-by: Barak Witkowski <barak@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
Signed-off-by: Eddie Wai <eddie.wai@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Bhanu Prakash Gollapudi <bprakash@broadcom.com>
---
Hi Dave,

Please consider applying this patch to net-next.

Thanks,
Merav

 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h        |    2 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h    |  120 +--------------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c   |   41 ++++-
 .../net/ethernet/broadcom/bnx2x/bnx2x_mfw_req.h    |  168 ++++++++++++++++++++
 drivers/net/ethernet/broadcom/cnic.c               |   11 +-
 drivers/net/ethernet/broadcom/cnic_if.h            |    9 +
 drivers/scsi/bnx2fc/bnx2fc.h                       |    4 +
 drivers/scsi/bnx2fc/bnx2fc_fcoe.c                  |   44 +++++
 drivers/scsi/bnx2i/57xx_iscsi_hsi.h                |   16 ++-
 drivers/scsi/bnx2i/bnx2i.h                         |   58 +++++++
 drivers/scsi/bnx2i/bnx2i_hwi.c                     |   35 +++-
 drivers/scsi/bnx2i/bnx2i_init.c                    |   40 +++++
 drivers/scsi/bnx2i/bnx2i_iscsi.c                   |   11 ++
 13 files changed, 420 insertions(+), 139 deletions(-)
 create mode 100644 drivers/net/ethernet/broadcom/bnx2x/bnx2x_mfw_req.h

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index 1f2e03a..27a4dd9 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -51,6 +51,7 @@
 
 #include "bnx2x_reg.h"
 #include "bnx2x_fw_defs.h"
+#include "bnx2x_mfw_req.h"
 #include "bnx2x_hsi.h"
 #include "bnx2x_link.h"
 #include "bnx2x_sp.h"
@@ -1332,6 +1333,7 @@ struct bnx2x {
 #define NO_ISCSI_FLAG			(1 << 14)
 #define NO_FCOE_FLAG			(1 << 15)
 #define BC_SUPPORTS_PFC_STATS		(1 << 17)
+#define BC_SUPPORTS_FCOE_FEATURES	(1 << 19)
 #define USING_SINGLE_MSIX_FLAG		(1 << 20)
 #define BC_SUPPORTS_DCBX_MSG_NON_PMF	(1 << 21)
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
index 6b77630..b4837c8 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
@@ -10,6 +10,7 @@
 #define BNX2X_HSI_H
 
 #include "bnx2x_fw_defs.h"
+#include "bnx2x_mfw_req.h"
 
 #define FW_ENCODE_32BIT_PATTERN         0x1e1e1e1e
 
@@ -33,12 +34,6 @@ struct license_key {
 	u32 reserved_b[4];
 };
 
-
-#define PORT_0			0
-#define PORT_1			1
-#define PORT_MAX		2
-#define NVM_PATH_MAX		2
-
 /****************************************************************************
  * Shared HW configuration                                                  *
  ****************************************************************************/
@@ -1250,6 +1245,7 @@ struct drv_func_mb {
 	#define REQ_BC_VER_4_VRFY_AFEX_SUPPORTED        0x00070002
 	#define REQ_BC_VER_4_SFP_TX_DISABLE_SUPPORTED   0x00070014
 	#define REQ_BC_VER_4_PFC_STATS_SUPPORTED        0x00070201
+	#define REQ_BC_VER_4_FCOE_FEATURES              0x00070209
 
 	#define DRV_MSG_CODE_DCBX_ADMIN_PMF_MSG         0xb0000000
 	#define DRV_MSG_CODE_DCBX_PMF_DRV_OK            0xb2000000
@@ -2698,118 +2694,6 @@ struct host_func_stats {
 /* VIC definitions */
 #define VICSTATST_UIF_INDEX 2
 
-/* current drv_info version */
-#define DRV_INFO_CUR_VER 1
-
-/* drv_info op codes supported */
-enum drv_info_opcode {
-	ETH_STATS_OPCODE,
-	FCOE_STATS_OPCODE,
-	ISCSI_STATS_OPCODE
-};
-
-#define ETH_STAT_INFO_VERSION_LEN	12
-/*  Per PCI Function Ethernet Statistics required from the driver */
-struct eth_stats_info {
-	/* Function's Driver Version. padded to 12 */
-	u8 version[ETH_STAT_INFO_VERSION_LEN];
-	/* Locally Admin Addr. BigEndian EIU48. Actual size is 6 bytes */
-	u8 mac_local[8];
-	u8 mac_add1[8];		/* Additional Programmed MAC Addr 1. */
-	u8 mac_add2[8];		/* Additional Programmed MAC Addr 2. */
-	u32 mtu_size;		/* MTU Size. Note   : Negotiated MTU */
-	u32 feature_flags;	/* Feature_Flags. */
-#define FEATURE_ETH_CHKSUM_OFFLOAD_MASK		0x01
-#define FEATURE_ETH_LSO_MASK			0x02
-#define FEATURE_ETH_BOOTMODE_MASK		0x1C
-#define FEATURE_ETH_BOOTMODE_SHIFT		2
-#define FEATURE_ETH_BOOTMODE_NONE		(0x0 << 2)
-#define FEATURE_ETH_BOOTMODE_PXE		(0x1 << 2)
-#define FEATURE_ETH_BOOTMODE_ISCSI		(0x2 << 2)
-#define FEATURE_ETH_BOOTMODE_FCOE		(0x3 << 2)
-#define FEATURE_ETH_TOE_MASK			0x20
-	u32 lso_max_size;	/* LSO MaxOffloadSize. */
-	u32 lso_min_seg_cnt;	/* LSO MinSegmentCount. */
-	/* Num Offloaded Connections TCP_IPv4. */
-	u32 ipv4_ofld_cnt;
-	/* Num Offloaded Connections TCP_IPv6. */
-	u32 ipv6_ofld_cnt;
-	u32 promiscuous_mode;	/* Promiscuous Mode. non-zero true */
-	u32 txq_size;		/* TX Descriptors Queue Size */
-	u32 rxq_size;		/* RX Descriptors Queue Size */
-	/* TX Descriptor Queue Avg Depth. % Avg Queue Depth since last poll */
-	u32 txq_avg_depth;
-	/* RX Descriptors Queue Avg Depth. % Avg Queue Depth since last poll */
-	u32 rxq_avg_depth;
-	/* IOV_Offload. 0=none; 1=MultiQueue, 2=VEB 3= VEPA*/
-	u32 iov_offload;
-	/* Number of NetQueue/VMQ Config'd. */
-	u32 netq_cnt;
-	u32 vf_cnt;		/* Num VF assigned to this PF. */
-};
-
-/*  Per PCI Function FCOE Statistics required from the driver */
-struct fcoe_stats_info {
-	u8 version[12];		/* Function's Driver Version. */
-	u8 mac_local[8];	/* Locally Admin Addr. */
-	u8 mac_add1[8];		/* Additional Programmed MAC Addr 1. */
-	u8 mac_add2[8];		/* Additional Programmed MAC Addr 2. */
-	/* QoS Priority (per 802.1p). 0-7255 */
-	u32 qos_priority;
-	u32 txq_size;		/* FCoE TX Descriptors Queue Size. */
-	u32 rxq_size;		/* FCoE RX Descriptors Queue Size. */
-	/* FCoE TX Descriptor Queue Avg Depth. */
-	u32 txq_avg_depth;
-	/* FCoE RX Descriptors Queue Avg Depth. */
-	u32 rxq_avg_depth;
-	u32 rx_frames_lo;	/* FCoE RX Frames received. */
-	u32 rx_frames_hi;	/* FCoE RX Frames received. */
-	u32 rx_bytes_lo;	/* FCoE RX Bytes received. */
-	u32 rx_bytes_hi;	/* FCoE RX Bytes received. */
-	u32 tx_frames_lo;	/* FCoE TX Frames sent. */
-	u32 tx_frames_hi;	/* FCoE TX Frames sent. */
-	u32 tx_bytes_lo;	/* FCoE TX Bytes sent. */
-	u32 tx_bytes_hi;	/* FCoE TX Bytes sent. */
-};
-
-/* Per PCI  Function iSCSI Statistics required from the driver*/
-struct iscsi_stats_info {
-	u8 version[12];		/* Function's Driver Version. */
-	u8 mac_local[8];	/* Locally Admin iSCSI MAC Addr. */
-	u8 mac_add1[8];		/* Additional Programmed MAC Addr 1. */
-	/* QoS Priority (per 802.1p). 0-7255 */
-	u32 qos_priority;
-	u8 initiator_name[64];	/* iSCSI Boot Initiator Node name. */
-	u8 ww_port_name[64];	/* iSCSI World wide port name */
-	u8 boot_target_name[64];/* iSCSI Boot Target Name. */
-	u8 boot_target_ip[16];	/* iSCSI Boot Target IP. */
-	u32 boot_target_portal;	/* iSCSI Boot Target Portal. */
-	u8 boot_init_ip[16];	/* iSCSI Boot Initiator IP Address. */
-	u32 max_frame_size;	/* Max Frame Size. bytes */
-	u32 txq_size;		/* PDU TX Descriptors Queue Size. */
-	u32 rxq_size;		/* PDU RX Descriptors Queue Size. */
-	u32 txq_avg_depth;	/* PDU TX Descriptor Queue Avg Depth. */
-	u32 rxq_avg_depth;	/* PDU RX Descriptors Queue Avg Depth. */
-	u32 rx_pdus_lo;		/* iSCSI PDUs received. */
-	u32 rx_pdus_hi;		/* iSCSI PDUs received. */
-	u32 rx_bytes_lo;	/* iSCSI RX Bytes received. */
-	u32 rx_bytes_hi;	/* iSCSI RX Bytes received. */
-	u32 tx_pdus_lo;		/* iSCSI PDUs sent. */
-	u32 tx_pdus_hi;		/* iSCSI PDUs sent. */
-	u32 tx_bytes_lo;	/* iSCSI PDU TX Bytes sent. */
-	u32 tx_bytes_hi;	/* iSCSI PDU TX Bytes sent. */
-	u32 pcp_prior_map_tbl;	/* C-PCP to S-PCP Priority MapTable.
-				 * 9 nibbles, the position of each nibble
-				 * represents the C-PCP value, the value
-				 * of the nibble = S-PCP value.
-				 */
-};
-
-union drv_info_to_mcp {
-	struct eth_stats_info	ether_stat;
-	struct fcoe_stats_info	fcoe_stat;
-	struct iscsi_stats_info	iscsi_stat;
-};
 
 /* stats collected for afex.
  * NOTE: structure is exactly as expected to be received by the switch.
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
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_mfw_req.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_mfw_req.h
new file mode 100644
index 0000000..ddd5106
--- /dev/null
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_mfw_req.h
@@ -0,0 +1,168 @@
+/* bnx2x_mfw_req.h: Broadcom Everest network driver.
+ *
+ * Copyright (c) 2012 Broadcom Corporation
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation.
+ */
+
+#ifndef BNX2X_MFW_REQ_H
+#define BNX2X_MFW_REQ_H
+
+#define PORT_0			0
+#define PORT_1			1
+#define PORT_MAX		2
+#define NVM_PATH_MAX		2
+
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
+/* current drv_info version */
+#define DRV_INFO_CUR_VER 2
+
+/* drv_info op codes supported */
+enum drv_info_opcode {
+	ETH_STATS_OPCODE,
+	FCOE_STATS_OPCODE,
+	ISCSI_STATS_OPCODE
+};
+
+#define ETH_STAT_INFO_VERSION_LEN	12
+/*  Per PCI Function Ethernet Statistics required from the driver */
+struct eth_stats_info {
+	/* Function's Driver Version. padded to 12 */
+	u8 version[ETH_STAT_INFO_VERSION_LEN];
+	/* Locally Admin Addr. BigEndian EIU48. Actual size is 6 bytes */
+	u8 mac_local[8];
+	u8 mac_add1[8];		/* Additional Programmed MAC Addr 1. */
+	u8 mac_add2[8];		/* Additional Programmed MAC Addr 2. */
+	u32 mtu_size;		/* MTU Size. Note   : Negotiated MTU */
+	u32 feature_flags;	/* Feature_Flags. */
+#define FEATURE_ETH_CHKSUM_OFFLOAD_MASK		0x01
+#define FEATURE_ETH_LSO_MASK			0x02
+#define FEATURE_ETH_BOOTMODE_MASK		0x1C
+#define FEATURE_ETH_BOOTMODE_SHIFT		2
+#define FEATURE_ETH_BOOTMODE_NONE		(0x0 << 2)
+#define FEATURE_ETH_BOOTMODE_PXE		(0x1 << 2)
+#define FEATURE_ETH_BOOTMODE_ISCSI		(0x2 << 2)
+#define FEATURE_ETH_BOOTMODE_FCOE		(0x3 << 2)
+#define FEATURE_ETH_TOE_MASK			0x20
+	u32 lso_max_size;	/* LSO MaxOffloadSize. */
+	u32 lso_min_seg_cnt;	/* LSO MinSegmentCount. */
+	/* Num Offloaded Connections TCP_IPv4. */
+	u32 ipv4_ofld_cnt;
+	/* Num Offloaded Connections TCP_IPv6. */
+	u32 ipv6_ofld_cnt;
+	u32 promiscuous_mode;	/* Promiscuous Mode. non-zero true */
+	u32 txq_size;		/* TX Descriptors Queue Size */
+	u32 rxq_size;		/* RX Descriptors Queue Size */
+	/* TX Descriptor Queue Avg Depth. % Avg Queue Depth since last poll */
+	u32 txq_avg_depth;
+	/* RX Descriptors Queue Avg Depth. % Avg Queue Depth since last poll */
+	u32 rxq_avg_depth;
+	/* IOV_Offload. 0=none; 1=MultiQueue, 2=VEB 3= VEPA*/
+	u32 iov_offload;
+	/* Number of NetQueue/VMQ Config'd. */
+	u32 netq_cnt;
+	u32 vf_cnt;		/* Num VF assigned to this PF. */
+};
+
+/*  Per PCI Function FCOE Statistics required from the driver */
+struct fcoe_stats_info {
+	u8 version[12];		/* Function's Driver Version. */
+	u8 mac_local[8];	/* Locally Admin Addr. */
+	u8 mac_add1[8];		/* Additional Programmed MAC Addr 1. */
+	u8 mac_add2[8];		/* Additional Programmed MAC Addr 2. */
+	/* QoS Priority (per 802.1p). 0-7255 */
+	u32 qos_priority;
+	u32 txq_size;		/* FCoE TX Descriptors Queue Size. */
+	u32 rxq_size;		/* FCoE RX Descriptors Queue Size. */
+	/* FCoE TX Descriptor Queue Avg Depth. */
+	u32 txq_avg_depth;
+	/* FCoE RX Descriptors Queue Avg Depth. */
+	u32 rxq_avg_depth;
+	u32 rx_frames_lo;	/* FCoE RX Frames received. */
+	u32 rx_frames_hi;	/* FCoE RX Frames received. */
+	u32 rx_bytes_lo;	/* FCoE RX Bytes received. */
+	u32 rx_bytes_hi;	/* FCoE RX Bytes received. */
+	u32 tx_frames_lo;	/* FCoE TX Frames sent. */
+	u32 tx_frames_hi;	/* FCoE TX Frames sent. */
+	u32 tx_bytes_lo;	/* FCoE TX Bytes sent. */
+	u32 tx_bytes_hi;	/* FCoE TX Bytes sent. */
+};
+
+/* Per PCI  Function iSCSI Statistics required from the driver*/
+struct iscsi_stats_info {
+	u8 version[12];		/* Function's Driver Version. */
+	u8 mac_local[8];	/* Locally Admin iSCSI MAC Addr. */
+	u8 mac_add1[8];		/* Additional Programmed MAC Addr 1. */
+	/* QoS Priority (per 802.1p). 0-7255 */
+	u32 qos_priority;
+	u8 initiator_name[64];	/* iSCSI Boot Initiator Node name. */
+	u8 ww_port_name[64];	/* iSCSI World wide port name */
+	u8 boot_target_name[64];/* iSCSI Boot Target Name. */
+	u8 boot_target_ip[16];	/* iSCSI Boot Target IP. */
+	u32 boot_target_portal;	/* iSCSI Boot Target Portal. */
+	u8 boot_init_ip[16];	/* iSCSI Boot Initiator IP Address. */
+	u32 max_frame_size;	/* Max Frame Size. bytes */
+	u32 txq_size;		/* PDU TX Descriptors Queue Size. */
+	u32 rxq_size;		/* PDU RX Descriptors Queue Size. */
+	u32 txq_avg_depth;	/* PDU TX Descriptor Queue Avg Depth. */
+	u32 rxq_avg_depth;	/* PDU RX Descriptors Queue Avg Depth. */
+	u32 rx_pdus_lo;		/* iSCSI PDUs received. */
+	u32 rx_pdus_hi;		/* iSCSI PDUs received. */
+	u32 rx_bytes_lo;	/* iSCSI RX Bytes received. */
+	u32 rx_bytes_hi;	/* iSCSI RX Bytes received. */
+	u32 tx_pdus_lo;		/* iSCSI PDUs sent. */
+	u32 tx_pdus_hi;		/* iSCSI PDUs sent. */
+	u32 tx_bytes_lo;	/* iSCSI PDU TX Bytes sent. */
+	u32 tx_bytes_hi;	/* iSCSI PDU TX Bytes sent. */
+	u32 pcp_prior_map_tbl;	/* C-PCP to S-PCP Priority MapTable.
+				 * 9 nibbles, the position of each nibble
+				 * represents the C-PCP value, the value
+				 * of the nibble = S-PCP value.
+				 */
+};
+
+union drv_info_to_mcp {
+	struct eth_stats_info	ether_stat;
+	struct fcoe_stats_info	fcoe_stat;
+	struct iscsi_stats_info	iscsi_stat;
+};
+#endif /* BNX2X_MFW_REQ_H */
diff --git a/drivers/net/ethernet/broadcom/cnic.c b/drivers/net/ethernet/broadcom/cnic.c
index 65e66ca..0e9be2b 100644
--- a/drivers/net/ethernet/broadcom/cnic.c
+++ b/drivers/net/ethernet/broadcom/cnic.c
@@ -256,11 +256,16 @@ static void cnic_ulp_ctl(struct cnic_dev *dev, int ulp_type, bool reg)
 	struct cnic_local *cp = dev->cnic_priv;
 	struct cnic_eth_dev *ethdev = cp->ethdev;
 	struct drv_ctl_info info;
+	struct fcoe_capabilities *fcoe_cap =
+		&info.data.register_data.fcoe_features;
 
-	if (reg)
+	if (reg) {
 		info.cmd = DRV_CTL_ULP_REGISTER_CMD;
-	else
+		if (ulp_type == CNIC_ULP_FCOE && dev->fcoe_cap)
+			memcpy(fcoe_cap, dev->fcoe_cap, sizeof(*fcoe_cap));
+	} else {
 		info.cmd = DRV_CTL_ULP_UNREGISTER_CMD;
+	}
 
 	info.data.ulp_type = ulp_type;
 	ethdev->drv_ctl(dev->netdev, &info);
@@ -611,6 +616,8 @@ static int cnic_unregister_device(struct cnic_dev *dev, int ulp_type)
 
 	if (ulp_type == CNIC_ULP_ISCSI)
 		cnic_send_nlmsg(cp, ISCSI_KEVENT_IF_DOWN, NULL);
+	else if (ulp_type == CNIC_ULP_FCOE)
+		dev->fcoe_cap = NULL;
 
 	synchronize_rcu();
 
diff --git a/drivers/net/ethernet/broadcom/cnic_if.h b/drivers/net/ethernet/broadcom/cnic_if.h
index 289274e..d63d455 100644
--- a/drivers/net/ethernet/broadcom/cnic_if.h
+++ b/drivers/net/ethernet/broadcom/cnic_if.h
@@ -12,6 +12,8 @@
 #ifndef CNIC_IF_H
 #define CNIC_IF_H
 
+#include "bnx2x/bnx2x_mfw_req.h"
+
 #define CNIC_MODULE_VERSION	"2.5.10"
 #define CNIC_MODULE_RELDATE	"March 21, 2012"
 
@@ -131,6 +133,11 @@ struct drv_ctl_l2_ring {
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
@@ -138,6 +145,7 @@ struct drv_ctl_info {
 		struct drv_ctl_io io;
 		struct drv_ctl_l2_ring ring;
 		int ulp_type;
+		struct drv_ctl_register_data register_data;
 		char bytes[MAX_DRV_CTL_DATA];
 	} data;
 };
@@ -305,6 +313,7 @@ struct cnic_dev {
 	int		max_rdma_conn;
 
 	union drv_info_to_mcp	*stats_addr;
+	struct fcoe_capabilities	*fcoe_cap;
 
 	void		*cnic_priv;
 };
diff --git a/drivers/scsi/bnx2fc/bnx2fc.h b/drivers/scsi/bnx2fc/bnx2fc.h
index 0578fa0..42969e8 100644
--- a/drivers/scsi/bnx2fc/bnx2fc.h
+++ b/drivers/scsi/bnx2fc/bnx2fc.h
@@ -59,6 +59,7 @@
 #include "57xx_hsi_bnx2fc.h"
 #include "bnx2fc_debug.h"
 #include "../../net/ethernet/broadcom/cnic_if.h"
+#include  "../../net/ethernet/broadcom/bnx2x/bnx2x_mfw_req.h"
 #include "bnx2fc_constants.h"
 
 #define BNX2FC_NAME		"bnx2fc"
@@ -84,6 +85,8 @@
 #define BNX2FC_NUM_MAX_SESS	1024
 #define BNX2FC_NUM_MAX_SESS_LOG	(ilog2(BNX2FC_NUM_MAX_SESS))
 
+#define BNX2FC_MAX_NPIV		256
+
 #define BNX2FC_MAX_OUTSTANDING_CMNDS	2048
 #define BNX2FC_CAN_QUEUE		BNX2FC_MAX_OUTSTANDING_CMNDS
 #define BNX2FC_ELSTM_XIDS		BNX2FC_CAN_QUEUE
@@ -206,6 +209,7 @@ struct bnx2fc_hba {
 	struct fcoe_statistics_params *stats_buffer;
 	dma_addr_t stats_buf_dma;
 	struct completion stat_req_done;
+	struct fcoe_capabilities fcoe_cap;
 
 	/*destroy handling */
 	struct timer_list destroy_timer;
diff --git a/drivers/scsi/bnx2fc/bnx2fc_fcoe.c b/drivers/scsi/bnx2fc/bnx2fc_fcoe.c
index f52f668..05fe662 100644
--- a/drivers/scsi/bnx2fc/bnx2fc_fcoe.c
+++ b/drivers/scsi/bnx2fc/bnx2fc_fcoe.c
@@ -1326,6 +1326,7 @@ static void bnx2fc_hba_destroy(struct bnx2fc_hba *hba)
 static struct bnx2fc_hba *bnx2fc_hba_create(struct cnic_dev *cnic)
 {
 	struct bnx2fc_hba *hba;
+	struct fcoe_capabilities *fcoe_cap;
 	int rc;
 
 	hba = kzalloc(sizeof(*hba), GFP_KERNEL);
@@ -1361,6 +1362,21 @@ static struct bnx2fc_hba *bnx2fc_hba_create(struct cnic_dev *cnic)
 		printk(KERN_ERR PFX "em_config:bnx2fc_cmd_mgr_alloc failed\n");
 		goto cmgr_err;
 	}
+	fcoe_cap = &hba->fcoe_cap;
+
+	fcoe_cap->capability1 = BNX2FC_TM_MAX_SQES <<
+					FCOE_IOS_PER_CONNECTION_SHIFT;
+	fcoe_cap->capability1 |= BNX2FC_NUM_MAX_SESS <<
+					FCOE_LOGINS_PER_PORT_SHIFT;
+	fcoe_cap->capability2 = BNX2FC_MAX_OUTSTANDING_CMNDS <<
+					FCOE_NUMBER_OF_EXCHANGES_SHIFT;
+	fcoe_cap->capability2 |= BNX2FC_MAX_NPIV <<
+					FCOE_NPIV_WWN_PER_PORT_SHIFT;
+	fcoe_cap->capability3 = BNX2FC_NUM_MAX_SESS <<
+					FCOE_TARGETS_SUPPORTED_SHIFT;
+	fcoe_cap->capability3 |= BNX2FC_MAX_OUTSTANDING_CMNDS <<
+					FCOE_OUTSTANDING_COMMANDS_SHIFT;
+	fcoe_cap->capability4 = FCOE_CAPABILITY4_STATEFUL;
 
 	init_waitqueue_head(&hba->shutdown_wait);
 	init_waitqueue_head(&hba->destroy_wait);
@@ -1691,6 +1707,32 @@ static void bnx2fc_unbind_pcidev(struct bnx2fc_hba *hba)
 	hba->pcidev = NULL;
 }
 
+/**
+ * bnx2fc_ulp_get_stats - cnic callback to populate FCoE stats
+ *
+ * @handle:    transport handle pointing to adapter struture
+ */
+static int bnx2fc_ulp_get_stats(void *handle)
+{
+	struct bnx2fc_hba *hba = handle;
+	struct cnic_dev *cnic;
+	struct fcoe_stats_info *stats_addr;
+
+	if (!hba)
+		return -EINVAL;
+
+	cnic = hba->cnic;
+	stats_addr = &cnic->stats_addr->fcoe_stat;
+	if (!stats_addr)
+		return -EINVAL;
+
+	strncpy(stats_addr->version, BNX2FC_VERSION,
+		sizeof(stats_addr->version));
+	stats_addr->txq_size = BNX2FC_SQ_WQES_MAX;
+	stats_addr->rxq_size = BNX2FC_CQ_WQES_MAX;
+
+	return 0;
+}
 
 
 /**
@@ -1944,6 +1986,7 @@ static void bnx2fc_ulp_init(struct cnic_dev *dev)
 	adapter_count++;
 	mutex_unlock(&bnx2fc_dev_lock);
 
+	dev->fcoe_cap = &hba->fcoe_cap;
 	clear_bit(BNX2FC_CNIC_REGISTERED, &hba->reg_with_cnic);
 	rc = dev->register_device(dev, CNIC_ULP_FCOE,
 						(void *) hba);
@@ -2643,4 +2686,5 @@ static struct cnic_ulp_ops bnx2fc_cnic_cb = {
 	.cnic_stop		= bnx2fc_ulp_stop,
 	.indicate_kcqes		= bnx2fc_indicate_kcqe,
 	.indicate_netevent	= bnx2fc_indicate_netevent,
+	.cnic_get_stats		= bnx2fc_ulp_get_stats,
 };
diff --git a/drivers/scsi/bnx2i/57xx_iscsi_hsi.h b/drivers/scsi/bnx2i/57xx_iscsi_hsi.h
index dc0a08e..f2db5fe 100644
--- a/drivers/scsi/bnx2i/57xx_iscsi_hsi.h
+++ b/drivers/scsi/bnx2i/57xx_iscsi_hsi.h
@@ -267,7 +267,13 @@ struct bnx2i_cmd_request {
  * task statistics for write response
  */
 struct bnx2i_write_resp_task_stat {
-	u32 num_data_ins;
+#if defined(__BIG_ENDIAN)
+	u16 num_r2ts;
+	u16 num_data_outs;
+#elif defined(__LITTLE_ENDIAN)
+	u16 num_data_outs;
+	u16 num_r2ts;
+#endif
 };
 
 /*
@@ -275,11 +281,11 @@ struct bnx2i_write_resp_task_stat {
  */
 struct bnx2i_read_resp_task_stat {
 #if defined(__BIG_ENDIAN)
-	u16 num_data_outs;
-	u16 num_r2ts;
+	u16 reserved;
+	u16 num_data_ins;
 #elif defined(__LITTLE_ENDIAN)
-	u16 num_r2ts;
-	u16 num_data_outs;
+	u16 num_data_ins;
+	u16 reserved;
 #endif
 };
 
diff --git a/drivers/scsi/bnx2i/bnx2i.h b/drivers/scsi/bnx2i/bnx2i.h
index 0c53c28..2e32614 100644
--- a/drivers/scsi/bnx2i/bnx2i.h
+++ b/drivers/scsi/bnx2i/bnx2i.h
@@ -44,6 +44,8 @@
 #include "57xx_iscsi_hsi.h"
 #include "57xx_iscsi_constants.h"
 
+#include "../../net/ethernet/broadcom/bnx2x/bnx2x_mfw_req.h"
+
 #define BNX2_ISCSI_DRIVER_NAME		"bnx2i"
 
 #define BNX2I_MAX_ADAPTERS		8
@@ -126,6 +128,43 @@
 #define REG_WR(__hba, offset, val)			\
 		writel(val, __hba->regview + offset)
 
+#ifdef CONFIG_32BIT
+#define GET_STATS_64(__hba, dst, field)				\
+	do {							\
+		spin_lock_bh(&__hba->stat_lock);		\
+		dst->field##_lo = __hba->stats.field##_lo;	\
+		dst->field##_hi = __hba->stats.field##_hi;	\
+		spin_unlock_bh(&__hba->stat_lock);		\
+	} while (0)
+
+#define ADD_STATS_64(__hba, field, len)				\
+	do {							\
+		if (spin_trylock(&__hba->stat_lock)) {		\
+			if (__hba->stats.field##_lo + len <	\
+			    __hba->stats.field##_lo)		\
+				__hba->stats.field##_hi++;	\
+			__hba->stats.field##_lo += len;		\
+			spin_unlock(&__hba->stat_lock);		\
+		}						\
+	} while (0)
+
+#else
+#define GET_STATS_64(__hba, dst, field)				\
+	do {							\
+		u64 val, *out;					\
+								\
+		val = __hba->bnx2i_stats.field;			\
+		out = (u64 *)&__hba->stats.field##_lo;		\
+		*out = cpu_to_le64(val);			\
+		out = (u64 *)&dst->field##_lo;			\
+		*out = cpu_to_le64(val);			\
+	} while (0)
+
+#define ADD_STATS_64(__hba, field, len)				\
+	do {							\
+		__hba->bnx2i_stats.field += len;		\
+	} while (0)
+#endif
 
 /**
  * struct generic_pdu_resc - login pdu resource structure
@@ -288,6 +327,15 @@ struct iscsi_cid_queue {
 	struct bnx2i_conn **conn_cid_tbl;
 };
 
+
+struct bnx2i_stats_info {
+	u64 rx_pdus;
+	u64 rx_bytes;
+	u64 tx_pdus;
+	u64 tx_bytes;
+};
+
+
 /**
  * struct bnx2i_hba - bnx2i adapter structure
  *
@@ -341,6 +389,8 @@ struct iscsi_cid_queue {
  * @ctx_ccell_tasks:       captures number of ccells and tasks supported by
  *                         currently offloaded connection, used to decode
  *                         context memory
+ * @stat_lock:		   spin lock used by the statistic collector (32 bit)
+ * @stats:		   local iSCSI statistic collection place holder
  *
  * Adapter Data Structure
  */
@@ -426,6 +476,12 @@ struct bnx2i_hba {
 	u32 num_sess_opened;
 	u32 num_conn_opened;
 	unsigned int ctx_ccell_tasks;
+
+#ifdef CONFIG_32BIT
+	spinlock_t stat_lock;
+#endif
+	struct bnx2i_stats_info bnx2i_stats;
+	struct iscsi_stats_info stats;
 };
 
 
@@ -749,6 +805,8 @@ extern void bnx2i_ulp_init(struct cnic_dev *dev);
 extern void bnx2i_ulp_exit(struct cnic_dev *dev);
 extern void bnx2i_start(void *handle);
 extern void bnx2i_stop(void *handle);
+extern int bnx2i_get_stats(void *handle);
+
 extern struct bnx2i_hba *get_adapter_list_head(void);
 
 struct bnx2i_conn *bnx2i_get_conn_from_id(struct bnx2i_hba *hba,
diff --git a/drivers/scsi/bnx2i/bnx2i_hwi.c b/drivers/scsi/bnx2i/bnx2i_hwi.c
index ece47e5..49e8b05 100644
--- a/drivers/scsi/bnx2i/bnx2i_hwi.c
+++ b/drivers/scsi/bnx2i/bnx2i_hwi.c
@@ -1350,6 +1350,7 @@ int bnx2i_process_scsi_cmd_resp(struct iscsi_session *session,
 				struct cqe *cqe)
 {
 	struct iscsi_conn *conn = bnx2i_conn->cls_conn->dd_data;
+	struct bnx2i_hba *hba = bnx2i_conn->hba;
 	struct bnx2i_cmd_response *resp_cqe;
 	struct bnx2i_cmd *bnx2i_cmd;
 	struct iscsi_task *task;
@@ -1367,16 +1368,26 @@ int bnx2i_process_scsi_cmd_resp(struct iscsi_session *session,
 
 	if (bnx2i_cmd->req.op_attr & ISCSI_CMD_REQUEST_READ) {
 		conn->datain_pdus_cnt +=
-			resp_cqe->task_stat.read_stat.num_data_outs;
+			resp_cqe->task_stat.read_stat.num_data_ins;
 		conn->rxdata_octets +=
 			bnx2i_cmd->req.total_data_transfer_length;
+		ADD_STATS_64(hba, rx_pdus,
+			     resp_cqe->task_stat.read_stat.num_data_ins);
+		ADD_STATS_64(hba, rx_bytes,
+			     bnx2i_cmd->req.total_data_transfer_length);
 	} else {
 		conn->dataout_pdus_cnt +=
-			resp_cqe->task_stat.read_stat.num_data_outs;
+			resp_cqe->task_stat.write_stat.num_data_outs;
 		conn->r2t_pdus_cnt +=
-			resp_cqe->task_stat.read_stat.num_r2ts;
+			resp_cqe->task_stat.write_stat.num_r2ts;
 		conn->txdata_octets +=
 			bnx2i_cmd->req.total_data_transfer_length;
+		ADD_STATS_64(hba, tx_pdus,
+			     resp_cqe->task_stat.write_stat.num_data_outs);
+		ADD_STATS_64(hba, tx_bytes,
+			     bnx2i_cmd->req.total_data_transfer_length);
+		ADD_STATS_64(hba, rx_pdus,
+			     resp_cqe->task_stat.write_stat.num_r2ts);
 	}
 	bnx2i_iscsi_unmap_sg_list(bnx2i_cmd);
 
@@ -1961,6 +1972,7 @@ static int bnx2i_process_new_cqes(struct bnx2i_conn *bnx2i_conn)
 {
 	struct iscsi_conn *conn = bnx2i_conn->cls_conn->dd_data;
 	struct iscsi_session *session = conn->session;
+	struct bnx2i_hba *hba = bnx2i_conn->hba;
 	struct qp_info *qp;
 	struct bnx2i_nop_in_msg *nopin;
 	int tgt_async_msg;
@@ -1973,7 +1985,7 @@ static int bnx2i_process_new_cqes(struct bnx2i_conn *bnx2i_conn)
 
 	if (!qp->cq_virt) {
 		printk(KERN_ALERT "bnx2i (%s): cq resr freed in bh execution!",
-			bnx2i_conn->hba->netdev->name);
+		       hba->netdev->name);
 		goto out;
 	}
 	while (1) {
@@ -1985,9 +1997,9 @@ static int bnx2i_process_new_cqes(struct bnx2i_conn *bnx2i_conn)
 			if (nopin->op_code == ISCSI_OP_NOOP_IN &&
 			    nopin->itt == (u16) RESERVED_ITT) {
 				printk(KERN_ALERT "bnx2i: Unsolicited "
-					"NOP-In detected for suspended "
-					"connection dev=%s!\n",
-					bnx2i_conn->hba->netdev->name);
+				       "NOP-In detected for suspended "
+				       "connection dev=%s!\n",
+				       hba->netdev->name);
 				bnx2i_unsol_pdu_adjust_rq(bnx2i_conn);
 				goto cqe_out;
 			}
@@ -2001,7 +2013,7 @@ static int bnx2i_process_new_cqes(struct bnx2i_conn *bnx2i_conn)
 			/* Run the kthread engine only for data cmds
 			   All other cmds will be completed in this bh! */
 			bnx2i_queue_scsi_cmd_resp(session, bnx2i_conn, nopin);
-			break;
+			goto done;
 		case ISCSI_OP_LOGIN_RSP:
 			bnx2i_process_login_resp(session, bnx2i_conn,
 						 qp->cq_cons_qe);
@@ -2044,11 +2056,15 @@ static int bnx2i_process_new_cqes(struct bnx2i_conn *bnx2i_conn)
 			printk(KERN_ALERT "bnx2i: unknown opcode 0x%x\n",
 					  nopin->op_code);
 		}
+
+		ADD_STATS_64(hba, rx_pdus, 1);
+		ADD_STATS_64(hba, rx_bytes, nopin->data_length);
+done:
 		if (!tgt_async_msg) {
 			if (!atomic_read(&bnx2i_conn->ep->num_active_cmds))
 				printk(KERN_ALERT "bnx2i (%s): no active cmd! "
 				       "op 0x%x\n",
-				       bnx2i_conn->hba->netdev->name,
+				       hba->netdev->name,
 				       nopin->op_code);
 			else
 				atomic_dec(&bnx2i_conn->ep->num_active_cmds);
@@ -2692,6 +2708,7 @@ struct cnic_ulp_ops bnx2i_cnic_cb = {
 	.cm_remote_close = bnx2i_cm_remote_close,
 	.cm_remote_abort = bnx2i_cm_remote_abort,
 	.iscsi_nl_send_msg = bnx2i_send_nl_mesg,
+	.cnic_get_stats = bnx2i_get_stats,
 	.owner = THIS_MODULE
 };
 
diff --git a/drivers/scsi/bnx2i/bnx2i_init.c b/drivers/scsi/bnx2i/bnx2i_init.c
index 8b68167..7729a52 100644
--- a/drivers/scsi/bnx2i/bnx2i_init.c
+++ b/drivers/scsi/bnx2i/bnx2i_init.c
@@ -381,6 +381,46 @@ void bnx2i_ulp_exit(struct cnic_dev *dev)
 
 
 /**
+ * bnx2i_get_stats - Retrieve various statistic from iSCSI offload
+ * @handle:	bnx2i_hba
+ *
+ * function callback exported via bnx2i - cnic driver interface to
+ *      retrieve various iSCSI offload related statistics.
+ */
+int bnx2i_get_stats(void *handle)
+{
+	struct bnx2i_hba *hba = handle;
+	struct iscsi_stats_info *stats;
+
+	if (!hba)
+		return -EINVAL;
+
+	stats = (struct iscsi_stats_info *)hba->cnic->stats_addr;
+
+	if (!stats)
+		return -ENOMEM;
+
+	memcpy(stats->version, DRV_MODULE_VERSION, sizeof(stats->version));
+	memcpy(stats->mac_add1 + 2, hba->cnic->mac_addr, ETH_ALEN);
+
+	stats->max_frame_size = hba->netdev->mtu;
+	stats->txq_size = hba->max_sqes;
+	stats->rxq_size = hba->max_cqes;
+
+	stats->txq_avg_depth = 0;
+	stats->rxq_avg_depth = 0;
+
+	GET_STATS_64(hba, stats, rx_pdus);
+	GET_STATS_64(hba, stats, rx_bytes);
+
+	GET_STATS_64(hba, stats, tx_pdus);
+	GET_STATS_64(hba, stats, tx_bytes);
+
+	return 0;
+}
+
+
+/**
  * bnx2i_percpu_thread_create - Create a receive thread for an
  *				online CPU
  *
diff --git a/drivers/scsi/bnx2i/bnx2i_iscsi.c b/drivers/scsi/bnx2i/bnx2i_iscsi.c
index f8d516b..b40ac01 100644
--- a/drivers/scsi/bnx2i/bnx2i_iscsi.c
+++ b/drivers/scsi/bnx2i/bnx2i_iscsi.c
@@ -874,6 +874,11 @@ struct bnx2i_hba *bnx2i_alloc_hba(struct cnic_dev *cnic)
 		hba->conn_ctx_destroy_tmo = 2 * HZ;
 	}
 
+#ifdef CONFIG_32BIT
+	spin_lock_init(&hba->stat_lock);
+#endif
+	memset(&hba->stats, 0, sizeof(struct iscsi_stats_info));
+
 	if (iscsi_host_add(shost, &hba->pcidev->dev))
 		goto free_dump_mem;
 	return hba;
@@ -1181,12 +1186,18 @@ static int
 bnx2i_mtask_xmit(struct iscsi_conn *conn, struct iscsi_task *task)
 {
 	struct bnx2i_conn *bnx2i_conn = conn->dd_data;
+	struct bnx2i_hba *hba = bnx2i_conn->hba;
 	struct bnx2i_cmd *cmd = task->dd_data;
 
 	memset(bnx2i_conn->gen_pdu.req_buf, 0, ISCSI_DEF_MAX_RECV_SEG_LEN);
 
 	bnx2i_setup_cmd_wqe_template(cmd);
 	bnx2i_conn->gen_pdu.req_buf_size = task->data_count;
+
+	/* Tx PDU/data length count */
+	ADD_STATS_64(hba, tx_pdus, 1);
+	ADD_STATS_64(hba, tx_bytes, task->data_count);
+
 	if (task->data_count) {
 		memcpy(bnx2i_conn->gen_pdu.req_buf, task->data,
 		       task->data_count);
-- 
1.7.0.6
