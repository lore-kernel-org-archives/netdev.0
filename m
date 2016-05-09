From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 04/14] qed: IOV configure and FLR
Date: Mon, 9 May 2016 16:19:13 +0300
Message-ID: <1462799963-23547-5-git-send-email-Yuval.Mintz@qlogic.com>
References: <1462799963-23547-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:33752 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752475AbcEINUI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2016 09:20:08 -0400
In-Reply-To: <1462799963-23547-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While previous patches have already added the necessary logic to probe
VFs as well as enabling them in the HW, this patch adds the ability to
support VF FLR & SRIOV disable.

It then wraps both flows together into the first IOV callback to be
provided to the protocol driver - `configure'. This would later to be used
to enable and disable SRIOV in the adapter.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed_dev.c      |  17 +-
 drivers/net/ethernet/qlogic/qed/qed_dev_api.h  |   4 +-
 drivers/net/ethernet/qlogic/qed/qed_hsi.h      |  11 +-
 drivers/net/ethernet/qlogic/qed/qed_l2.c       |   7 +
 drivers/net/ethernet/qlogic/qed/qed_main.c     |   1 +
 drivers/net/ethernet/qlogic/qed/qed_mcp.c      |  72 +++
 drivers/net/ethernet/qlogic/qed/qed_mcp.h      |  12 +
 drivers/net/ethernet/qlogic/qed/qed_reg_addr.h |  10 +
 drivers/net/ethernet/qlogic/qed/qed_sp.h       |   1 +
 drivers/net/ethernet/qlogic/qed/qed_sriov.c    | 660 +++++++++++++++++++++++++
 drivers/net/ethernet/qlogic/qed/qed_sriov.h    |  33 +-
 drivers/net/ethernet/qlogic/qed/qed_vf.c       |  97 ++++
 drivers/net/ethernet/qlogic/qed/qed_vf.h       |  45 ++
 include/linux/qed/qed_eth_if.h                 |   4 +
 include/linux/qed/qed_iov_if.h                 |  20 +
 15 files changed, 983 insertions(+), 11 deletions(-)
 create mode 100644 include/linux/qed/qed_iov_if.h

diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev.c b/drivers/net/ethernet/qlogic/qed/qed_dev.c
index 362e8db..78e25cf 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev.c
@@ -31,6 +31,7 @@
 #include "qed_reg_addr.h"
 #include "qed_sp.h"
 #include "qed_sriov.h"
+#include "qed_vf.h"
 
 /* API common to all protocols */
 enum BAR_ID {
@@ -420,8 +421,7 @@ void qed_resc_setup(struct qed_dev *cdev)
 #define FINAL_CLEANUP_POLL_CNT          (100)
 #define FINAL_CLEANUP_POLL_TIME         (10)
 int qed_final_cleanup(struct qed_hwfn *p_hwfn,
-		      struct qed_ptt *p_ptt,
-		      u16 id)
+		      struct qed_ptt *p_ptt, u16 id, bool is_vf)
 {
 	u32 command = 0, addr, count = FINAL_CLEANUP_POLL_CNT;
 	int rc = -EBUSY;
@@ -429,6 +429,9 @@ int qed_final_cleanup(struct qed_hwfn *p_hwfn,
 	addr = GTT_BAR0_MAP_REG_USDM_RAM +
 		USTORM_FLR_FINAL_ACK_OFFSET(p_hwfn->rel_pf_id);
 
+	if (is_vf)
+		id += 0x10;
+
 	command |= X_FINAL_CLEANUP_AGG_INT <<
 		SDM_AGG_INT_COMP_PARAMS_AGG_INT_INDEX_SHIFT;
 	command |= 1 << SDM_AGG_INT_COMP_PARAMS_AGG_VECTOR_ENABLE_SHIFT;
@@ -663,7 +666,7 @@ static int qed_hw_init_pf(struct qed_hwfn *p_hwfn,
 	STORE_RT_REG(p_hwfn, PRS_REG_SEARCH_ROCE_RT_OFFSET, 0);
 
 	/* Cleanup chip from previous driver if such remains exist */
-	rc = qed_final_cleanup(p_hwfn, p_ptt, rel_pf_id);
+	rc = qed_final_cleanup(p_hwfn, p_ptt, rel_pf_id, false);
 	if (rc != 0)
 		return rc;
 
@@ -880,7 +883,7 @@ int qed_hw_stop(struct qed_dev *cdev)
 		DP_VERBOSE(p_hwfn, NETIF_MSG_IFDOWN, "Stopping hw/fw\n");
 
 		if (IS_VF(cdev)) {
-			/* To be implemented in a later patch */
+			qed_vf_pf_int_cleanup(p_hwfn);
 			continue;
 		}
 
@@ -989,7 +992,9 @@ int qed_hw_reset(struct qed_dev *cdev)
 		struct qed_hwfn *p_hwfn = &cdev->hwfns[i];
 
 		if (IS_VF(cdev)) {
-			/* Will be implemented in a later patch */
+			rc = qed_vf_pf_reset(p_hwfn);
+			if (rc)
+				return rc;
 			continue;
 		}
 
@@ -1590,7 +1595,7 @@ void qed_hw_remove(struct qed_dev *cdev)
 		struct qed_hwfn *p_hwfn = &cdev->hwfns[i];
 
 		if (IS_VF(cdev)) {
-			/* Will be implemented in a later patch */
+			qed_vf_pf_release(p_hwfn);
 			continue;
 		}
 
diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev_api.h b/drivers/net/ethernet/qlogic/qed/qed_dev_api.h
index f567371..dde364d 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev_api.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev_api.h
@@ -303,11 +303,11 @@ int qed_fw_rss_eng(struct qed_hwfn *p_hwfn,
  * @param p_hwfn
  * @param p_ptt
  * @param id - For PF, engine-relative. For VF, PF-relative.
+ * @param is_vf - true iff cleanup is made for a VF.
  *
  * @return int
  */
 int qed_final_cleanup(struct qed_hwfn *p_hwfn,
-		      struct qed_ptt *p_ptt,
-		      u16 id);
+		      struct qed_ptt *p_ptt, u16 id, bool is_vf);
 
 #endif
diff --git a/drivers/net/ethernet/qlogic/qed/qed_hsi.h b/drivers/net/ethernet/qlogic/qed/qed_hsi.h
index c511106..82b7727 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_hsi.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_hsi.h
@@ -30,7 +30,7 @@ enum common_event_opcode {
 	COMMON_EVENT_PF_START,
 	COMMON_EVENT_PF_STOP,
 	COMMON_EVENT_VF_START,
-	COMMON_EVENT_RESERVED2,
+	COMMON_EVENT_VF_STOP,
 	COMMON_EVENT_VF_PF_CHANNEL,
 	COMMON_EVENT_RESERVED4,
 	COMMON_EVENT_RESERVED5,
@@ -45,7 +45,7 @@ enum common_ramrod_cmd_id {
 	COMMON_RAMROD_PF_START /* PF Function Start Ramrod */,
 	COMMON_RAMROD_PF_STOP /* PF Function Stop Ramrod */,
 	COMMON_RAMROD_VF_START,
-	COMMON_RAMROD_RESERVED2,
+	COMMON_RAMROD_VF_STOP,
 	COMMON_RAMROD_PF_UPDATE,
 	COMMON_RAMROD_EMPTY,
 	MAX_COMMON_RAMROD_CMD_ID
@@ -741,6 +741,13 @@ struct vf_start_ramrod_data {
 	u8 reserved[3];
 };
 
+struct vf_stop_ramrod_data {
+	u8 vf_id;
+	u8 reserved0;
+	__le16 reserved1;
+	__le32 reserved2;
+};
+
 struct atten_status_block {
 	__le32	atten_bits;
 	__le32	atten_ack;
diff --git a/drivers/net/ethernet/qlogic/qed/qed_l2.c b/drivers/net/ethernet/qlogic/qed/qed_l2.c
index 8bcbf92..5978bb5 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_l2.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_l2.c
@@ -2066,8 +2066,15 @@ static int qed_fp_cqe_completion(struct qed_dev *dev,
 				      cqe);
 }
 
+#ifdef CONFIG_QED_SRIOV
+extern const struct qed_iov_hv_ops qed_iov_ops_pass;
+#endif
+
 static const struct qed_eth_ops qed_eth_ops_pass = {
 	.common = &qed_common_ops_pass,
+#ifdef CONFIG_QED_SRIOV
+	.iov = &qed_iov_ops_pass,
+#endif
 	.fill_dev_info = &qed_fill_eth_dev_info,
 	.register_ops = &qed_register_eth_ops,
 	.vport_start = &qed_start_vport,
diff --git a/drivers/net/ethernet/qlogic/qed/qed_main.c b/drivers/net/ethernet/qlogic/qed/qed_main.c
index 898347b..e98610e 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_main.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_main.c
@@ -897,6 +897,7 @@ static int qed_slowpath_stop(struct qed_dev *cdev)
 
 	if (IS_PF(cdev)) {
 		qed_free_stream_mem(cdev);
+		qed_sriov_disable(cdev, true);
 
 		qed_nic_stop(cdev);
 		qed_slowpath_irq_free(cdev);
diff --git a/drivers/net/ethernet/qlogic/qed/qed_mcp.c b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
index 8317500..2be943b 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_mcp.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
@@ -442,6 +442,75 @@ int qed_mcp_load_req(struct qed_hwfn *p_hwfn,
 	return 0;
 }
 
+static void qed_mcp_handle_vf_flr(struct qed_hwfn *p_hwfn,
+				  struct qed_ptt *p_ptt)
+{
+	u32 addr = SECTION_OFFSIZE_ADDR(p_hwfn->mcp_info->public_base,
+					PUBLIC_PATH);
+	u32 mfw_path_offsize = qed_rd(p_hwfn, p_ptt, addr);
+	u32 path_addr = SECTION_ADDR(mfw_path_offsize,
+				     QED_PATH_ID(p_hwfn));
+	u32 disabled_vfs[VF_MAX_STATIC / 32];
+	int i;
+
+	DP_VERBOSE(p_hwfn,
+		   QED_MSG_SP,
+		   "Reading Disabled VF information from [offset %08x], path_addr %08x\n",
+		   mfw_path_offsize, path_addr);
+
+	for (i = 0; i < (VF_MAX_STATIC / 32); i++) {
+		disabled_vfs[i] = qed_rd(p_hwfn, p_ptt,
+					 path_addr +
+					 offsetof(struct public_path,
+						  mcp_vf_disabled) +
+					 sizeof(u32) * i);
+		DP_VERBOSE(p_hwfn, (QED_MSG_SP | QED_MSG_IOV),
+			   "FLR-ed VFs [%08x,...,%08x] - %08x\n",
+			   i * 32, (i + 1) * 32 - 1, disabled_vfs[i]);
+	}
+
+	if (qed_iov_mark_vf_flr(p_hwfn, disabled_vfs))
+		qed_schedule_iov(p_hwfn, QED_IOV_WQ_FLR_FLAG);
+}
+
+int qed_mcp_ack_vf_flr(struct qed_hwfn *p_hwfn,
+		       struct qed_ptt *p_ptt, u32 *vfs_to_ack)
+{
+	u32 addr = SECTION_OFFSIZE_ADDR(p_hwfn->mcp_info->public_base,
+					PUBLIC_FUNC);
+	u32 mfw_func_offsize = qed_rd(p_hwfn, p_ptt, addr);
+	u32 func_addr = SECTION_ADDR(mfw_func_offsize,
+				     MCP_PF_ID(p_hwfn));
+	struct qed_mcp_mb_params mb_params;
+	union drv_union_data union_data;
+	int rc;
+	int i;
+
+	for (i = 0; i < (VF_MAX_STATIC / 32); i++)
+		DP_VERBOSE(p_hwfn, (QED_MSG_SP | QED_MSG_IOV),
+			   "Acking VFs [%08x,...,%08x] - %08x\n",
+			   i * 32, (i + 1) * 32 - 1, vfs_to_ack[i]);
+
+	memset(&mb_params, 0, sizeof(mb_params));
+	mb_params.cmd = DRV_MSG_CODE_VF_DISABLED_DONE;
+	memcpy(&union_data.ack_vf_disabled, vfs_to_ack, VF_MAX_STATIC / 8);
+	mb_params.p_data_src = &union_data;
+	rc = qed_mcp_cmd_and_union(p_hwfn, p_ptt, &mb_params);
+	if (rc) {
+		DP_NOTICE(p_hwfn, "Failed to pass ACK for VF flr to MFW\n");
+		return -EBUSY;
+	}
+
+	/* Clear the ACK bits */
+	for (i = 0; i < (VF_MAX_STATIC / 32); i++)
+		qed_wr(p_hwfn, p_ptt,
+		       func_addr +
+		       offsetof(struct public_func, drv_ack_vf_disabled) +
+		       i * sizeof(u32), 0);
+
+	return rc;
+}
+
 static void qed_mcp_handle_transceiver_change(struct qed_hwfn *p_hwfn,
 					      struct qed_ptt *p_ptt)
 {
@@ -753,6 +822,9 @@ int qed_mcp_handle_events(struct qed_hwfn *p_hwfn,
 		case MFW_DRV_MSG_LINK_CHANGE:
 			qed_mcp_handle_link_change(p_hwfn, p_ptt, false);
 			break;
+		case MFW_DRV_MSG_VF_DISABLED:
+			qed_mcp_handle_vf_flr(p_hwfn, p_ptt);
+			break;
 		case MFW_DRV_MSG_TRANSCEIVER_STATE_CHANGE:
 			qed_mcp_handle_transceiver_change(p_hwfn, p_ptt);
 			break;
diff --git a/drivers/net/ethernet/qlogic/qed/qed_mcp.h b/drivers/net/ethernet/qlogic/qed/qed_mcp.h
index e3d5cdf..6dd59eb 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_mcp.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_mcp.h
@@ -393,6 +393,18 @@ void qed_mcp_read_mb(struct qed_hwfn *p_hwfn,
 		     struct qed_ptt *p_ptt);
 
 /**
+ * @brief Ack to mfw that driver finished FLR process for VFs
+ *
+ * @param p_hwfn
+ * @param p_ptt
+ * @param vfs_to_ack - bit mask of all engine VFs for which the PF acks.
+ *
+ * @param return int - 0 upon success.
+ */
+int qed_mcp_ack_vf_flr(struct qed_hwfn *p_hwfn,
+		       struct qed_ptt *p_ptt, u32 *vfs_to_ack);
+
+/**
  * @brief - calls during init to read shmem of all function-related info.
  *
  * @param p_hwfn
diff --git a/drivers/net/ethernet/qlogic/qed/qed_reg_addr.h b/drivers/net/ethernet/qlogic/qed/qed_reg_addr.h
index a508b6b..80a6217 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_reg_addr.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_reg_addr.h
@@ -41,6 +41,8 @@
 	0x2aa16cUL
 #define PGLUE_B_REG_WAS_ERROR_VF_31_0_CLR \
 	0x2aa118UL
+#define PSWHST_REG_ZONE_PERMISSION_TABLE \
+	0x2a0800UL
 #define  BAR0_MAP_REG_MSDM_RAM \
 	0x1d00000UL
 #define  BAR0_MAP_REG_USDM_RAM \
@@ -79,6 +81,8 @@
 	0x2f2eb0UL
 #define  DORQ_REG_PF_DB_ENABLE \
 	0x100508UL
+#define DORQ_REG_VF_USAGE_CNT \
+	0x1009c4UL
 #define  QM_REG_PF_EN \
 	0x2f2ea4UL
 #define  TCFC_REG_STRONG_ENABLE_PF \
@@ -167,6 +171,10 @@
 	0x040200UL
 #define  PBF_REG_INIT \
 	0xd80000UL
+#define PBF_REG_NUM_BLOCKS_ALLOCATED_PROD_VOQ0 \
+	0xd806c8UL
+#define PBF_REG_NUM_BLOCKS_ALLOCATED_CONS_VOQ0 \
+	0xd806ccUL
 #define  PTU_REG_ATC_INIT_ARRAY \
 	0x560000UL
 #define  PCM_REG_INIT \
@@ -391,6 +399,8 @@
 	0x1d0000UL
 #define  IGU_REG_PF_CONFIGURATION \
 	0x180800UL
+#define IGU_REG_VF_CONFIGURATION \
+	0x180804UL
 #define  MISC_REG_AEU_ENABLE1_IGU_OUT_0 \
 	0x00849cUL
 #define MISC_REG_AEU_AFTER_INVERT_1_IGU	\
diff --git a/drivers/net/ethernet/qlogic/qed/qed_sp.h b/drivers/net/ethernet/qlogic/qed/qed_sp.h
index dde69090..c2999cb 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sp.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_sp.h
@@ -64,6 +64,7 @@ union ramrod_data {
 	struct vport_filter_update_ramrod_data vport_filter_update;
 
 	struct vf_start_ramrod_data vf_start;
+	struct vf_stop_ramrod_data vf_stop;
 };
 
 #define EQ_MAX_CREDIT   0xffffffff
diff --git a/drivers/net/ethernet/qlogic/qed/qed_sriov.c b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
index 699d96f..750166d 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sriov.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
@@ -6,6 +6,7 @@
  * this source tree.
  */
 
+#include <linux/qed/qed_iov_if.h>
 #include "qed_cxt.h"
 #include "qed_hsi.h"
 #include "qed_hw.h"
@@ -48,6 +49,33 @@ static int qed_sp_vf_start(struct qed_hwfn *p_hwfn,
 	return qed_spq_post(p_hwfn, p_ent, NULL);
 }
 
+static int qed_sp_vf_stop(struct qed_hwfn *p_hwfn,
+			  u32 concrete_vfid, u16 opaque_vfid)
+{
+	struct vf_stop_ramrod_data *p_ramrod = NULL;
+	struct qed_spq_entry *p_ent = NULL;
+	struct qed_sp_init_data init_data;
+	int rc = -EINVAL;
+
+	/* Get SPQ entry */
+	memset(&init_data, 0, sizeof(init_data));
+	init_data.cid = qed_spq_get_cid(p_hwfn);
+	init_data.opaque_fid = opaque_vfid;
+	init_data.comp_mode = QED_SPQ_MODE_EBLOCK;
+
+	rc = qed_sp_init_request(p_hwfn, &p_ent,
+				 COMMON_RAMROD_VF_STOP,
+				 PROTOCOLID_COMMON, &init_data);
+	if (rc)
+		return rc;
+
+	p_ramrod = &p_ent->ramrod.vf_stop;
+
+	p_ramrod->vf_id = GET_FIELD(concrete_vfid, PXP_CONCRETE_FID_VFID);
+
+	return qed_spq_post(p_hwfn, p_ent, NULL);
+}
+
 bool qed_iov_is_valid_vfid(struct qed_hwfn *p_hwfn,
 			   int rel_vf_id, bool b_enabled_only)
 {
@@ -422,6 +450,34 @@ static bool qed_iov_pf_sanity_check(struct qed_hwfn *p_hwfn, int vfid)
 	return true;
 }
 
+static void qed_iov_set_vf_to_disable(struct qed_dev *cdev,
+				      u16 rel_vf_id, u8 to_disable)
+{
+	struct qed_vf_info *vf;
+	int i;
+
+	for_each_hwfn(cdev, i) {
+		struct qed_hwfn *p_hwfn = &cdev->hwfns[i];
+
+		vf = qed_iov_get_vf_info(p_hwfn, rel_vf_id, false);
+		if (!vf)
+			continue;
+
+		vf->to_disable = to_disable;
+	}
+}
+
+void qed_iov_set_vfs_to_disable(struct qed_dev *cdev, u8 to_disable)
+{
+	u16 i;
+
+	if (!IS_QED_SRIOV(cdev))
+		return;
+
+	for (i = 0; i < cdev->p_iov_info->total_vfs; i++)
+		qed_iov_set_vf_to_disable(cdev, i, to_disable);
+}
+
 static void qed_iov_vf_pglue_clear_err(struct qed_hwfn *p_hwfn,
 				       struct qed_ptt *p_ptt, u8 abs_vfid)
 {
@@ -430,6 +486,27 @@ static void qed_iov_vf_pglue_clear_err(struct qed_hwfn *p_hwfn,
 	       1 << (abs_vfid & 0x1f));
 }
 
+static void qed_iov_vf_igu_set_int(struct qed_hwfn *p_hwfn,
+				   struct qed_ptt *p_ptt,
+				   struct qed_vf_info *vf, bool enable)
+{
+	u32 igu_vf_conf;
+
+	qed_fid_pretend(p_hwfn, p_ptt, (u16) vf->concrete_fid);
+
+	igu_vf_conf = qed_rd(p_hwfn, p_ptt, IGU_REG_VF_CONFIGURATION);
+
+	if (enable)
+		igu_vf_conf |= IGU_VF_CONF_MSI_MSIX_EN;
+	else
+		igu_vf_conf &= ~IGU_VF_CONF_MSI_MSIX_EN;
+
+	qed_wr(p_hwfn, p_ptt, IGU_REG_VF_CONFIGURATION, igu_vf_conf);
+
+	/* unpretend */
+	qed_fid_pretend(p_hwfn, p_ptt, (u16) p_hwfn->hw_info.concrete_fid);
+}
+
 static int qed_iov_enable_vf_access(struct qed_hwfn *p_hwfn,
 				    struct qed_ptt *p_ptt,
 				    struct qed_vf_info *vf)
@@ -437,6 +514,9 @@ static int qed_iov_enable_vf_access(struct qed_hwfn *p_hwfn,
 	u32 igu_vf_conf = IGU_VF_CONF_FUNC_EN;
 	int rc;
 
+	if (vf->to_disable)
+		return 0;
+
 	DP_VERBOSE(p_hwfn,
 		   QED_MSG_IOV,
 		   "Enable internal access for vf %x [abs %x]\n",
@@ -475,6 +555,36 @@ static int qed_iov_enable_vf_access(struct qed_hwfn *p_hwfn,
 	return rc;
 }
 
+/**
+ * @brief qed_iov_config_perm_table - configure the permission
+ *      zone table.
+ *      In E4, queue zone permission table size is 320x9. There
+ *      are 320 VF queues for single engine device (256 for dual
+ *      engine device), and each entry has the following format:
+ *      {Valid, VF[7:0]}
+ * @param p_hwfn
+ * @param p_ptt
+ * @param vf
+ * @param enable
+ */
+static void qed_iov_config_perm_table(struct qed_hwfn *p_hwfn,
+				      struct qed_ptt *p_ptt,
+				      struct qed_vf_info *vf, u8 enable)
+{
+	u32 reg_addr, val;
+	u16 qzone_id = 0;
+	int qid;
+
+	for (qid = 0; qid < vf->num_rxqs; qid++) {
+		qed_fw_l2_queue(p_hwfn, vf->vf_queues[qid].fw_rx_qid,
+				&qzone_id);
+
+		reg_addr = PSWHST_REG_ZONE_PERMISSION_TABLE + qzone_id * 4;
+		val = enable ? (vf->abs_vf_id | (1 << 8)) : 0;
+		qed_wr(p_hwfn, p_ptt, reg_addr, val);
+	}
+}
+
 static u8 qed_iov_alloc_vf_igu_sbs(struct qed_hwfn *p_hwfn,
 				   struct qed_ptt *p_ptt,
 				   struct qed_vf_info *vf, u16 num_rx_queues)
@@ -525,6 +635,32 @@ static u8 qed_iov_alloc_vf_igu_sbs(struct qed_hwfn *p_hwfn,
 	return vf->num_sbs;
 }
 
+static void qed_iov_free_vf_igu_sbs(struct qed_hwfn *p_hwfn,
+				    struct qed_ptt *p_ptt,
+				    struct qed_vf_info *vf)
+{
+	struct qed_igu_info *p_info = p_hwfn->hw_info.p_igu_info;
+	int idx, igu_id;
+	u32 addr, val;
+
+	/* Invalidate igu CAM lines and mark them as free */
+	for (idx = 0; idx < vf->num_sbs; idx++) {
+		igu_id = vf->igu_sbs[idx];
+		addr = IGU_REG_MAPPING_MEMORY + sizeof(u32) * igu_id;
+
+		val = qed_rd(p_hwfn, p_ptt, addr);
+		SET_FIELD(val, IGU_MAPPING_LINE_VALID, 0);
+		qed_wr(p_hwfn, p_ptt, addr, val);
+
+		p_info->igu_map.igu_blocks[igu_id].status |=
+		    QED_IGU_STATUS_FREE;
+
+		p_hwfn->hw_info.p_igu_info->free_blks++;
+	}
+
+	vf->num_sbs = 0;
+}
+
 static int qed_iov_init_hw_for_vf(struct qed_hwfn *p_hwfn,
 				  struct qed_ptt *p_ptt,
 				  u16 rel_vf_id, u16 num_rx_queues)
@@ -598,6 +734,54 @@ static int qed_iov_init_hw_for_vf(struct qed_hwfn *p_hwfn,
 	return rc;
 }
 
+static int qed_iov_release_hw_for_vf(struct qed_hwfn *p_hwfn,
+				     struct qed_ptt *p_ptt, u16 rel_vf_id)
+{
+	struct qed_vf_info *vf = NULL;
+	int rc = 0;
+
+	vf = qed_iov_get_vf_info(p_hwfn, rel_vf_id, true);
+	if (!vf) {
+		DP_ERR(p_hwfn, "qed_iov_release_hw_for_vf : vf is NULL\n");
+		return -EINVAL;
+	}
+
+	if (vf->state != VF_STOPPED) {
+		/* Stopping the VF */
+		rc = qed_sp_vf_stop(p_hwfn, vf->concrete_fid, vf->opaque_fid);
+
+		if (rc != 0) {
+			DP_ERR(p_hwfn, "qed_sp_vf_stop returned error %d\n",
+			       rc);
+			return rc;
+		}
+
+		vf->state = VF_STOPPED;
+	}
+
+	/* disablng interrupts and resetting permission table was done during
+	 * vf-close, however, we could get here without going through vf_close
+	 */
+	/* Disable Interrupts for VF */
+	qed_iov_vf_igu_set_int(p_hwfn, p_ptt, vf, 0);
+
+	/* Reset Permission table */
+	qed_iov_config_perm_table(p_hwfn, p_ptt, vf, 0);
+
+	vf->num_rxqs = 0;
+	vf->num_txqs = 0;
+	qed_iov_free_vf_igu_sbs(p_hwfn, p_ptt, vf);
+
+	if (vf->b_init) {
+		vf->b_init = false;
+
+		if (IS_LEAD_HWFN(p_hwfn))
+			p_hwfn->cdev->p_iov_info->num_vfs--;
+	}
+
+	return 0;
+}
+
 static bool qed_iov_tlv_supported(u16 tlvtype)
 {
 	return CHANNEL_TLV_NONE < tlvtype && tlvtype < CHANNEL_TLV_MAX;
@@ -702,6 +886,51 @@ static void qed_iov_prepare_resp(struct qed_hwfn *p_hwfn,
 	qed_iov_send_response(p_hwfn, p_ptt, vf_info, length, status);
 }
 
+struct qed_public_vf_info *qed_iov_get_public_vf_info(struct qed_hwfn *p_hwfn,
+						      u16 relative_vf_id,
+						      bool b_enabled_only)
+{
+	struct qed_vf_info *vf = NULL;
+
+	vf = qed_iov_get_vf_info(p_hwfn, relative_vf_id, b_enabled_only);
+	if (!vf)
+		return NULL;
+
+	return &vf->p_vf_info;
+}
+
+void qed_iov_clean_vf(struct qed_hwfn *p_hwfn, u8 vfid)
+{
+	struct qed_public_vf_info *vf_info;
+
+	vf_info = qed_iov_get_public_vf_info(p_hwfn, vfid, false);
+
+	if (!vf_info)
+		return;
+
+	/* Clear the VF mac */
+	memset(vf_info->mac, 0, ETH_ALEN);
+}
+
+static void qed_iov_vf_cleanup(struct qed_hwfn *p_hwfn,
+			       struct qed_vf_info *p_vf)
+{
+	u32 i;
+
+	p_vf->vf_bulletin = 0;
+	p_vf->num_mac_filters = 0;
+	p_vf->num_vlan_filters = 0;
+
+	/* If VF previously requested less resources, go back to default */
+	p_vf->num_rxqs = p_vf->num_sbs;
+	p_vf->num_txqs = p_vf->num_sbs;
+
+	for (i = 0; i < QED_MAX_VF_CHAINS_PER_PF; i++)
+		p_vf->vf_queues[i].rxq_active = 0;
+
+	qed_iov_clean_vf(p_hwfn, p_vf->relative_vf_id);
+}
+
 static void qed_iov_vf_mbx_acquire(struct qed_hwfn *p_hwfn,
 				   struct qed_ptt *p_ptt,
 				   struct qed_vf_info *vf)
@@ -845,6 +1074,271 @@ out:
 			     sizeof(struct pfvf_acquire_resp_tlv), vfpf_status);
 }
 
+static void qed_iov_vf_mbx_int_cleanup(struct qed_hwfn *p_hwfn,
+				       struct qed_ptt *p_ptt,
+				       struct qed_vf_info *vf)
+{
+	int i;
+
+	/* Reset the SBs */
+	for (i = 0; i < vf->num_sbs; i++)
+		qed_int_igu_init_pure_rt_single(p_hwfn, p_ptt,
+						vf->igu_sbs[i],
+						vf->opaque_fid, false);
+
+	qed_iov_prepare_resp(p_hwfn, p_ptt, vf, CHANNEL_TLV_INT_CLEANUP,
+			     sizeof(struct pfvf_def_resp_tlv),
+			     PFVF_STATUS_SUCCESS);
+}
+
+static void qed_iov_vf_mbx_close(struct qed_hwfn *p_hwfn,
+				 struct qed_ptt *p_ptt, struct qed_vf_info *vf)
+{
+	u16 length = sizeof(struct pfvf_def_resp_tlv);
+	u8 status = PFVF_STATUS_SUCCESS;
+
+	/* Disable Interrupts for VF */
+	qed_iov_vf_igu_set_int(p_hwfn, p_ptt, vf, 0);
+
+	/* Reset Permission table */
+	qed_iov_config_perm_table(p_hwfn, p_ptt, vf, 0);
+
+	qed_iov_prepare_resp(p_hwfn, p_ptt, vf, CHANNEL_TLV_CLOSE,
+			     length, status);
+}
+
+static void qed_iov_vf_mbx_release(struct qed_hwfn *p_hwfn,
+				   struct qed_ptt *p_ptt,
+				   struct qed_vf_info *p_vf)
+{
+	u16 length = sizeof(struct pfvf_def_resp_tlv);
+
+	qed_iov_vf_cleanup(p_hwfn, p_vf);
+
+	qed_iov_prepare_resp(p_hwfn, p_ptt, p_vf, CHANNEL_TLV_RELEASE,
+			     length, PFVF_STATUS_SUCCESS);
+}
+
+static int
+qed_iov_vf_flr_poll_dorq(struct qed_hwfn *p_hwfn,
+			 struct qed_vf_info *p_vf, struct qed_ptt *p_ptt)
+{
+	int cnt;
+	u32 val;
+
+	qed_fid_pretend(p_hwfn, p_ptt, (u16) p_vf->concrete_fid);
+
+	for (cnt = 0; cnt < 50; cnt++) {
+		val = qed_rd(p_hwfn, p_ptt, DORQ_REG_VF_USAGE_CNT);
+		if (!val)
+			break;
+		msleep(20);
+	}
+	qed_fid_pretend(p_hwfn, p_ptt, (u16) p_hwfn->hw_info.concrete_fid);
+
+	if (cnt == 50) {
+		DP_ERR(p_hwfn,
+		       "VF[%d] - dorq failed to cleanup [usage 0x%08x]\n",
+		       p_vf->abs_vf_id, val);
+		return -EBUSY;
+	}
+
+	return 0;
+}
+
+static int
+qed_iov_vf_flr_poll_pbf(struct qed_hwfn *p_hwfn,
+			struct qed_vf_info *p_vf, struct qed_ptt *p_ptt)
+{
+	u32 cons[MAX_NUM_VOQS], distance[MAX_NUM_VOQS];
+	int i, cnt;
+
+	/* Read initial consumers & producers */
+	for (i = 0; i < MAX_NUM_VOQS; i++) {
+		u32 prod;
+
+		cons[i] = qed_rd(p_hwfn, p_ptt,
+				 PBF_REG_NUM_BLOCKS_ALLOCATED_CONS_VOQ0 +
+				 i * 0x40);
+		prod = qed_rd(p_hwfn, p_ptt,
+			      PBF_REG_NUM_BLOCKS_ALLOCATED_PROD_VOQ0 +
+			      i * 0x40);
+		distance[i] = prod - cons[i];
+	}
+
+	/* Wait for consumers to pass the producers */
+	i = 0;
+	for (cnt = 0; cnt < 50; cnt++) {
+		for (; i < MAX_NUM_VOQS; i++) {
+			u32 tmp;
+
+			tmp = qed_rd(p_hwfn, p_ptt,
+				     PBF_REG_NUM_BLOCKS_ALLOCATED_CONS_VOQ0 +
+				     i * 0x40);
+			if (distance[i] > tmp - cons[i])
+				break;
+		}
+
+		if (i == MAX_NUM_VOQS)
+			break;
+
+		msleep(20);
+	}
+
+	if (cnt == 50) {
+		DP_ERR(p_hwfn, "VF[%d] - pbf polling failed on VOQ %d\n",
+		       p_vf->abs_vf_id, i);
+		return -EBUSY;
+	}
+
+	return 0;
+}
+
+static int qed_iov_vf_flr_poll(struct qed_hwfn *p_hwfn,
+			       struct qed_vf_info *p_vf, struct qed_ptt *p_ptt)
+{
+	int rc;
+
+	rc = qed_iov_vf_flr_poll_dorq(p_hwfn, p_vf, p_ptt);
+	if (rc)
+		return rc;
+
+	rc = qed_iov_vf_flr_poll_pbf(p_hwfn, p_vf, p_ptt);
+	if (rc)
+		return rc;
+
+	return 0;
+}
+
+static int
+qed_iov_execute_vf_flr_cleanup(struct qed_hwfn *p_hwfn,
+			       struct qed_ptt *p_ptt,
+			       u16 rel_vf_id, u32 *ack_vfs)
+{
+	struct qed_vf_info *p_vf;
+	int rc = 0;
+
+	p_vf = qed_iov_get_vf_info(p_hwfn, rel_vf_id, false);
+	if (!p_vf)
+		return 0;
+
+	if (p_hwfn->pf_iov_info->pending_flr[rel_vf_id / 64] &
+	    (1ULL << (rel_vf_id % 64))) {
+		u16 vfid = p_vf->abs_vf_id;
+
+		DP_VERBOSE(p_hwfn, QED_MSG_IOV,
+			   "VF[%d] - Handling FLR\n", vfid);
+
+		qed_iov_vf_cleanup(p_hwfn, p_vf);
+
+		/* If VF isn't active, no need for anything but SW */
+		if (!p_vf->b_init)
+			goto cleanup;
+
+		rc = qed_iov_vf_flr_poll(p_hwfn, p_vf, p_ptt);
+		if (rc)
+			goto cleanup;
+
+		rc = qed_final_cleanup(p_hwfn, p_ptt, vfid, true);
+		if (rc) {
+			DP_ERR(p_hwfn, "Failed handle FLR of VF[%d]\n", vfid);
+			return rc;
+		}
+
+		/* VF_STOPPED has to be set only after final cleanup
+		 * but prior to re-enabling the VF.
+		 */
+		p_vf->state = VF_STOPPED;
+
+		rc = qed_iov_enable_vf_access(p_hwfn, p_ptt, p_vf);
+		if (rc) {
+			DP_ERR(p_hwfn, "Failed to re-enable VF[%d] acces\n",
+			       vfid);
+			return rc;
+		}
+cleanup:
+		/* Mark VF for ack and clean pending state */
+		if (p_vf->state == VF_RESET)
+			p_vf->state = VF_STOPPED;
+		ack_vfs[vfid / 32] |= (1 << (vfid % 32));
+		p_hwfn->pf_iov_info->pending_flr[rel_vf_id / 64] &=
+		    ~(1ULL << (rel_vf_id % 64));
+		p_hwfn->pf_iov_info->pending_events[rel_vf_id / 64] &=
+		    ~(1ULL << (rel_vf_id % 64));
+	}
+
+	return rc;
+}
+
+int qed_iov_vf_flr_cleanup(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt)
+{
+	u32 ack_vfs[VF_MAX_STATIC / 32];
+	int rc = 0;
+	u16 i;
+
+	memset(ack_vfs, 0, sizeof(u32) * (VF_MAX_STATIC / 32));
+
+	/* Since BRB <-> PRS interface can't be tested as part of the flr
+	 * polling due to HW limitations, simply sleep a bit. And since
+	 * there's no need to wait per-vf, do it before looping.
+	 */
+	msleep(100);
+
+	for (i = 0; i < p_hwfn->cdev->p_iov_info->total_vfs; i++)
+		qed_iov_execute_vf_flr_cleanup(p_hwfn, p_ptt, i, ack_vfs);
+
+	rc = qed_mcp_ack_vf_flr(p_hwfn, p_ptt, ack_vfs);
+	return rc;
+}
+
+int qed_iov_mark_vf_flr(struct qed_hwfn *p_hwfn, u32 *p_disabled_vfs)
+{
+	u16 i, found = 0;
+
+	DP_VERBOSE(p_hwfn, QED_MSG_IOV, "Marking FLR-ed VFs\n");
+	for (i = 0; i < (VF_MAX_STATIC / 32); i++)
+		DP_VERBOSE(p_hwfn, QED_MSG_IOV,
+			   "[%08x,...,%08x]: %08x\n",
+			   i * 32, (i + 1) * 32 - 1, p_disabled_vfs[i]);
+
+	if (!p_hwfn->cdev->p_iov_info) {
+		DP_NOTICE(p_hwfn, "VF flr but no IOV\n");
+		return 0;
+	}
+
+	/* Mark VFs */
+	for (i = 0; i < p_hwfn->cdev->p_iov_info->total_vfs; i++) {
+		struct qed_vf_info *p_vf;
+		u8 vfid;
+
+		p_vf = qed_iov_get_vf_info(p_hwfn, i, false);
+		if (!p_vf)
+			continue;
+
+		vfid = p_vf->abs_vf_id;
+		if ((1 << (vfid % 32)) & p_disabled_vfs[vfid / 32]) {
+			u64 *p_flr = p_hwfn->pf_iov_info->pending_flr;
+			u16 rel_vf_id = p_vf->relative_vf_id;
+
+			DP_VERBOSE(p_hwfn, QED_MSG_IOV,
+				   "VF[%d] [rel %d] got FLR-ed\n",
+				   vfid, rel_vf_id);
+
+			p_vf->state = VF_RESET;
+
+			/* No need to lock here, since pending_flr should
+			 * only change here and before ACKing MFw. Since
+			 * MFW will not trigger an additional attention for
+			 * VF flr until ACKs, we're safe.
+			 */
+			p_flr[rel_vf_id / 64] |= 1ULL << (rel_vf_id % 64);
+			found = 1;
+		}
+	}
+
+	return found;
+}
+
 static void qed_iov_process_mbx_req(struct qed_hwfn *p_hwfn,
 				    struct qed_ptt *p_ptt, int vfid)
 {
@@ -871,6 +1365,15 @@ static void qed_iov_process_mbx_req(struct qed_hwfn *p_hwfn,
 		case CHANNEL_TLV_ACQUIRE:
 			qed_iov_vf_mbx_acquire(p_hwfn, p_ptt, p_vf);
 			break;
+		case CHANNEL_TLV_CLOSE:
+			qed_iov_vf_mbx_close(p_hwfn, p_ptt, p_vf);
+			break;
+		case CHANNEL_TLV_INT_CLEANUP:
+			qed_iov_vf_mbx_int_cleanup(p_hwfn, p_ptt, p_vf);
+			break;
+		case CHANNEL_TLV_RELEASE:
+			qed_iov_vf_mbx_release(p_hwfn, p_ptt, p_vf);
+			break;
 		}
 	} else {
 		/* unknown TLV - this may belong to a VF driver from the future
@@ -992,6 +1495,17 @@ static int qed_iov_copy_vf_msg(struct qed_hwfn *p_hwfn, struct qed_ptt *ptt,
 	return 0;
 }
 
+bool qed_iov_is_vf_stopped(struct qed_hwfn *p_hwfn, int vfid)
+{
+	struct qed_vf_info *p_vf_info;
+
+	p_vf_info = qed_iov_get_vf_info(p_hwfn, (u16) vfid, true);
+	if (!p_vf_info)
+		return true;
+
+	return p_vf_info->state == VF_STOPPED;
+}
+
 /**
  * qed_schedule_iov - schedules IOV task for VF and PF
  * @hwfn: hardware function pointer
@@ -1015,6 +1529,132 @@ void qed_vf_start_iov_wq(struct qed_dev *cdev)
 			       &cdev->hwfns[i].iov_task, 0);
 }
 
+int qed_sriov_disable(struct qed_dev *cdev, bool pci_enabled)
+{
+	int i, j;
+
+	for_each_hwfn(cdev, i)
+	    if (cdev->hwfns[i].iov_wq)
+		flush_workqueue(cdev->hwfns[i].iov_wq);
+
+	/* Mark VFs for disablement */
+	qed_iov_set_vfs_to_disable(cdev, true);
+
+	if (cdev->p_iov_info && cdev->p_iov_info->num_vfs && pci_enabled)
+		pci_disable_sriov(cdev->pdev);
+
+	for_each_hwfn(cdev, i) {
+		struct qed_hwfn *hwfn = &cdev->hwfns[i];
+		struct qed_ptt *ptt = qed_ptt_acquire(hwfn);
+
+		/* Failure to acquire the ptt in 100g creates an odd error
+		 * where the first engine has already relased IOV.
+		 */
+		if (!ptt) {
+			DP_ERR(hwfn, "Failed to acquire ptt\n");
+			return -EBUSY;
+		}
+
+		qed_for_each_vf(hwfn, j) {
+			int k;
+
+			if (!qed_iov_is_valid_vfid(hwfn, j, true))
+				continue;
+
+			/* Wait until VF is disabled before releasing */
+			for (k = 0; k < 100; k++) {
+				if (!qed_iov_is_vf_stopped(hwfn, j))
+					msleep(20);
+				else
+					break;
+			}
+
+			if (k < 100)
+				qed_iov_release_hw_for_vf(&cdev->hwfns[i],
+							  ptt, j);
+			else
+				DP_ERR(hwfn,
+				       "Timeout waiting for VF's FLR to end\n");
+		}
+
+		qed_ptt_release(hwfn, ptt);
+	}
+
+	qed_iov_set_vfs_to_disable(cdev, false);
+
+	return 0;
+}
+
+static int qed_sriov_enable(struct qed_dev *cdev, int num)
+{
+	struct qed_sb_cnt_info sb_cnt_info;
+	int i, j, rc;
+
+	if (num >= RESC_NUM(&cdev->hwfns[0], QED_VPORT)) {
+		DP_NOTICE(cdev, "Can start at most %d VFs\n",
+			  RESC_NUM(&cdev->hwfns[0], QED_VPORT) - 1);
+		return -EINVAL;
+	}
+
+	/* Initialize HW for VF access */
+	for_each_hwfn(cdev, j) {
+		struct qed_hwfn *hwfn = &cdev->hwfns[j];
+		struct qed_ptt *ptt = qed_ptt_acquire(hwfn);
+		int num_sbs = 0, limit = 16;
+
+		if (!ptt) {
+			DP_ERR(hwfn, "Failed to acquire ptt\n");
+			rc = -EBUSY;
+			goto err;
+		}
+
+		memset(&sb_cnt_info, 0, sizeof(sb_cnt_info));
+		qed_int_get_num_sbs(hwfn, &sb_cnt_info);
+		num_sbs = min_t(int, sb_cnt_info.sb_free_blk, limit);
+
+		for (i = 0; i < num; i++) {
+			if (!qed_iov_is_valid_vfid(hwfn, i, false))
+				continue;
+
+			rc = qed_iov_init_hw_for_vf(hwfn,
+						    ptt, i, num_sbs / num);
+			if (rc) {
+				DP_ERR(cdev, "Failed to enable VF[%d]\n", i);
+				qed_ptt_release(hwfn, ptt);
+				goto err;
+			}
+		}
+
+		qed_ptt_release(hwfn, ptt);
+	}
+
+	/* Enable SRIOV PCIe functions */
+	rc = pci_enable_sriov(cdev->pdev, num);
+	if (rc) {
+		DP_ERR(cdev, "Failed to enable sriov [%d]\n", rc);
+		goto err;
+	}
+
+	return num;
+
+err:
+	qed_sriov_disable(cdev, false);
+	return rc;
+}
+
+static int qed_sriov_configure(struct qed_dev *cdev, int num_vfs_param)
+{
+	if (!IS_QED_SRIOV(cdev)) {
+		DP_VERBOSE(cdev, QED_MSG_IOV, "SR-IOV is not supported\n");
+		return -EOPNOTSUPP;
+	}
+
+	if (num_vfs_param)
+		return qed_sriov_enable(cdev, num_vfs_param);
+	else
+		return qed_sriov_disable(cdev, true);
+}
+
 static void qed_handle_vf_msg(struct qed_hwfn *hwfn)
 {
 	u64 events[QED_VF_ARRAY_LENGTH];
@@ -1058,10 +1698,26 @@ void qed_iov_pf_task(struct work_struct *work)
 {
 	struct qed_hwfn *hwfn = container_of(work, struct qed_hwfn,
 					     iov_task.work);
+	int rc;
 
 	if (test_and_clear_bit(QED_IOV_WQ_STOP_WQ_FLAG, &hwfn->iov_task_flags))
 		return;
 
+	if (test_and_clear_bit(QED_IOV_WQ_FLR_FLAG, &hwfn->iov_task_flags)) {
+		struct qed_ptt *ptt = qed_ptt_acquire(hwfn);
+
+		if (!ptt) {
+			qed_schedule_iov(hwfn, QED_IOV_WQ_FLR_FLAG);
+			return;
+		}
+
+		rc = qed_iov_vf_flr_cleanup(hwfn, ptt);
+		if (rc)
+			qed_schedule_iov(hwfn, QED_IOV_WQ_FLR_FLAG);
+
+		qed_ptt_release(hwfn, ptt);
+	}
+
 	if (test_and_clear_bit(QED_IOV_WQ_MSG_FLAG, &hwfn->iov_task_flags))
 		qed_handle_vf_msg(hwfn);
 }
@@ -1112,3 +1768,7 @@ int qed_iov_wq_start(struct qed_dev *cdev)
 
 	return 0;
 }
+
+const struct qed_iov_hv_ops qed_iov_ops_pass = {
+	.configure = &qed_sriov_configure,
+};
diff --git a/drivers/net/ethernet/qlogic/qed/qed_sriov.h b/drivers/net/ethernet/qlogic/qed/qed_sriov.h
index 4f190d2..10794b0 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sriov.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_sriov.h
@@ -24,6 +24,13 @@
 #define QED_MAX_VF_CHAINS_PER_PF 16
 #define QED_ETH_VF_NUM_VLAN_FILTERS 2
 
+struct qed_public_vf_info {
+	/* These copies will later be reflected in the bulletin board,
+	 * but this copy should be newer.
+	 */
+	u8 mac[ETH_ALEN];
+};
+
 /* This struct is part of qed_dev and contains data relevant to all hwfns;
  * Initialized only if SR-IOV cpabability is exposed in PCIe config space.
  */
@@ -74,6 +81,7 @@ struct qed_vf_q_info {
 enum vf_state {
 	VF_FREE = 0,		/* VF ready to be acquired holds no resc */
 	VF_ACQUIRED,		/* VF, acquired, but not initalized */
+	VF_RESET,		/* VF, FLR'd, pending cleanup */
 	VF_STOPPED		/* VF, Stopped */
 };
 
@@ -82,6 +90,7 @@ struct qed_vf_info {
 	struct qed_iov_vf_mbx vf_mbx;
 	enum vf_state state;
 	bool b_init;
+	u8 to_disable;
 
 	struct qed_bulletin bulletin;
 	dma_addr_t vf_bulletin;
@@ -105,7 +114,7 @@ struct qed_vf_info {
 	u8 num_vlan_filters;
 	struct qed_vf_q_info vf_queues[QED_MAX_VF_CHAINS_PER_PF];
 	u16 igu_sbs[QED_MAX_VF_CHAINS_PER_PF];
-
+	struct qed_public_vf_info p_vf_info;
 };
 
 /* This structure is part of qed_hwfn and used only for PFs that have sriov
@@ -219,11 +228,22 @@ void qed_iov_free_hw_info(struct qed_dev *cdev);
 int qed_sriov_eqe_event(struct qed_hwfn *p_hwfn,
 			u8 opcode, __le16 echo, union event_ring_data *data);
 
+/**
+ * @brief Mark structs of vfs that have been FLR-ed.
+ *
+ * @param p_hwfn
+ * @param disabled_vfs - bitmask of all VFs on path that were FLRed
+ *
+ * @return 1 iff one of the PF's vfs got FLRed. 0 otherwise.
+ */
+int qed_iov_mark_vf_flr(struct qed_hwfn *p_hwfn, u32 *disabled_vfs);
+
 void qed_iov_wq_stop(struct qed_dev *cdev, bool schedule_first);
 int qed_iov_wq_start(struct qed_dev *cdev);
 
 void qed_schedule_iov(struct qed_hwfn *hwfn, enum qed_iov_wq_flag flag);
 void qed_vf_start_iov_wq(struct qed_dev *cdev);
+int qed_sriov_disable(struct qed_dev *cdev, bool pci_enabled);
 #else
 static inline u16 qed_iov_get_next_active_vf(struct qed_hwfn *p_hwfn,
 					     u16 rel_vf_id)
@@ -260,6 +280,12 @@ static inline int qed_sriov_eqe_event(struct qed_hwfn *p_hwfn,
 	return -EINVAL;
 }
 
+static inline int qed_iov_mark_vf_flr(struct qed_hwfn *p_hwfn,
+				      u32 *disabled_vfs)
+{
+	return 0;
+}
+
 static inline void qed_iov_wq_stop(struct qed_dev *cdev, bool schedule_first)
 {
 }
@@ -277,6 +303,11 @@ static inline void qed_schedule_iov(struct qed_hwfn *hwfn,
 static inline void qed_vf_start_iov_wq(struct qed_dev *cdev)
 {
 }
+
+static inline int qed_sriov_disable(struct qed_dev *cdev, bool pci_enabled)
+{
+	return 0;
+}
 #endif
 
 #define qed_for_each_vf(_p_hwfn, _i)			  \
diff --git a/drivers/net/ethernet/qlogic/qed/qed_vf.c b/drivers/net/ethernet/qlogic/qed/qed_vf.c
index a3c8f4e..2460e39 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_vf.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_vf.c
@@ -311,6 +311,103 @@ free_p_iov:
 	return -ENOMEM;
 }
 
+int qed_vf_pf_reset(struct qed_hwfn *p_hwfn)
+{
+	struct qed_vf_iov *p_iov = p_hwfn->vf_iov_info;
+	struct pfvf_def_resp_tlv *resp;
+	struct vfpf_first_tlv *req;
+	int rc;
+
+	/* clear mailbox and prep first tlv */
+	req = qed_vf_pf_prep(p_hwfn, CHANNEL_TLV_CLOSE, sizeof(*req));
+
+	/* add list termination tlv */
+	qed_add_tlv(p_hwfn, &p_iov->offset,
+		    CHANNEL_TLV_LIST_END, sizeof(struct channel_list_end_tlv));
+
+	resp = &p_iov->pf2vf_reply->default_resp;
+	rc = qed_send_msg2pf(p_hwfn, &resp->hdr.status, sizeof(*resp));
+	if (rc)
+		return rc;
+
+	if (resp->hdr.status != PFVF_STATUS_SUCCESS)
+		return -EAGAIN;
+
+	p_hwfn->b_int_enabled = 0;
+
+	return 0;
+}
+
+int qed_vf_pf_release(struct qed_hwfn *p_hwfn)
+{
+	struct qed_vf_iov *p_iov = p_hwfn->vf_iov_info;
+	struct pfvf_def_resp_tlv *resp;
+	struct vfpf_first_tlv *req;
+	u32 size;
+	int rc;
+
+	/* clear mailbox and prep first tlv */
+	req = qed_vf_pf_prep(p_hwfn, CHANNEL_TLV_RELEASE, sizeof(*req));
+
+	/* add list termination tlv */
+	qed_add_tlv(p_hwfn, &p_iov->offset,
+		    CHANNEL_TLV_LIST_END, sizeof(struct channel_list_end_tlv));
+
+	resp = &p_iov->pf2vf_reply->default_resp;
+	rc = qed_send_msg2pf(p_hwfn, &resp->hdr.status, sizeof(*resp));
+
+	if (!rc && resp->hdr.status != PFVF_STATUS_SUCCESS)
+		rc = -EAGAIN;
+
+	p_hwfn->b_int_enabled = 0;
+
+	if (p_iov->vf2pf_request)
+		dma_free_coherent(&p_hwfn->cdev->pdev->dev,
+				  sizeof(union vfpf_tlvs),
+				  p_iov->vf2pf_request,
+				  p_iov->vf2pf_request_phys);
+	if (p_iov->pf2vf_reply)
+		dma_free_coherent(&p_hwfn->cdev->pdev->dev,
+				  sizeof(union pfvf_tlvs),
+				  p_iov->pf2vf_reply, p_iov->pf2vf_reply_phys);
+
+	if (p_iov->bulletin.p_virt) {
+		size = sizeof(struct qed_bulletin_content);
+		dma_free_coherent(&p_hwfn->cdev->pdev->dev,
+				  size,
+				  p_iov->bulletin.p_virt, p_iov->bulletin.phys);
+	}
+
+	kfree(p_hwfn->vf_iov_info);
+	p_hwfn->vf_iov_info = NULL;
+
+	return rc;
+}
+
+int qed_vf_pf_int_cleanup(struct qed_hwfn *p_hwfn)
+{
+	struct qed_vf_iov *p_iov = p_hwfn->vf_iov_info;
+	struct pfvf_def_resp_tlv *resp = &p_iov->pf2vf_reply->default_resp;
+	int rc;
+
+	/* clear mailbox and prep first tlv */
+	qed_vf_pf_prep(p_hwfn, CHANNEL_TLV_INT_CLEANUP,
+		       sizeof(struct vfpf_first_tlv));
+
+	/* add list termination tlv */
+	qed_add_tlv(p_hwfn, &p_iov->offset,
+		    CHANNEL_TLV_LIST_END, sizeof(struct channel_list_end_tlv));
+
+	rc = qed_send_msg2pf(p_hwfn, &resp->hdr.status, sizeof(*resp));
+	if (rc)
+		return rc;
+
+	if (resp->hdr.status != PFVF_STATUS_SUCCESS)
+		return -EINVAL;
+
+	return 0;
+}
+
 u16 qed_vf_get_igu_sb_id(struct qed_hwfn *p_hwfn, u16 sb_id)
 {
 	struct qed_vf_iov *p_iov = p_hwfn->vf_iov_info;
diff --git a/drivers/net/ethernet/qlogic/qed/qed_vf.h b/drivers/net/ethernet/qlogic/qed/qed_vf.h
index 839b773..f3ce064 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_vf.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_vf.h
@@ -206,6 +206,9 @@ struct qed_bulletin {
 enum {
 	CHANNEL_TLV_NONE,	/* ends tlv sequence */
 	CHANNEL_TLV_ACQUIRE,
+	CHANNEL_TLV_INT_CLEANUP,
+	CHANNEL_TLV_CLOSE,
+	CHANNEL_TLV_RELEASE,
 	CHANNEL_TLV_LIST_END,
 	CHANNEL_TLV_MAX
 };
@@ -279,6 +282,24 @@ void qed_vf_get_fw_version(struct qed_hwfn *p_hwfn,
 int qed_vf_hw_prepare(struct qed_hwfn *p_hwfn);
 
 /**
+ *
+ * @brief VF - send a close message to PF
+ *
+ * @param p_hwfn
+ *
+ * @return enum _qed_status
+ */
+int qed_vf_pf_reset(struct qed_hwfn *p_hwfn);
+
+/**
+ * @brief VF - free vf`s memories
+ *
+ * @param p_hwfn
+ *
+ * @return enum _qed_status
+ */
+int qed_vf_pf_release(struct qed_hwfn *p_hwfn);
+/**
  * @brief qed_vf_get_igu_sb_id - Get the IGU SB ID for a given
  *        sb_id. For VFs igu sbs don't have to be contiguous
  *
@@ -288,6 +309,15 @@ int qed_vf_hw_prepare(struct qed_hwfn *p_hwfn);
  * @return INLINE u16
  */
 u16 qed_vf_get_igu_sb_id(struct qed_hwfn *p_hwfn, u16 sb_id);
+
+/**
+ * @brief qed_vf_pf_int_cleanup - clean the SB of the VF
+ *
+ * @param p_hwfn
+ *
+ * @return enum _qed_status
+ */
+int qed_vf_pf_int_cleanup(struct qed_hwfn *p_hwfn);
 #else
 static inline void qed_vf_get_num_rxqs(struct qed_hwfn *p_hwfn, u8 *num_rxqs)
 {
@@ -313,10 +343,25 @@ static inline int qed_vf_hw_prepare(struct qed_hwfn *p_hwfn)
 	return -EINVAL;
 }
 
+static inline int qed_vf_pf_reset(struct qed_hwfn *p_hwfn)
+{
+	return -EINVAL;
+}
+
+static inline int qed_vf_pf_release(struct qed_hwfn *p_hwfn)
+{
+	return -EINVAL;
+}
+
 static inline u16 qed_vf_get_igu_sb_id(struct qed_hwfn *p_hwfn, u16 sb_id)
 {
 	return 0;
 }
+
+static inline int qed_vf_pf_int_cleanup(struct qed_hwfn *p_hwfn)
+{
+	return -EINVAL;
+}
 #endif
 
 #endif
diff --git a/include/linux/qed/qed_eth_if.h b/include/linux/qed/qed_eth_if.h
index 3a4c806..acfafca 100644
--- a/include/linux/qed/qed_eth_if.h
+++ b/include/linux/qed/qed_eth_if.h
@@ -13,6 +13,7 @@
 #include <linux/if_link.h>
 #include <linux/qed/eth_common.h>
 #include <linux/qed/qed_if.h>
+#include <linux/qed/qed_iov_if.h>
 
 struct qed_dev_eth_info {
 	struct qed_dev_info common;
@@ -125,6 +126,9 @@ struct qed_eth_cb_ops {
 
 struct qed_eth_ops {
 	const struct qed_common_ops *common;
+#ifdef CONFIG_QED_SRIOV
+	const struct qed_iov_hv_ops *iov;
+#endif
 
 	int (*fill_dev_info)(struct qed_dev *cdev,
 			     struct qed_dev_eth_info *info);
diff --git a/include/linux/qed/qed_iov_if.h b/include/linux/qed/qed_iov_if.h
new file mode 100644
index 0000000..c53bfa6
--- /dev/null
+++ b/include/linux/qed/qed_iov_if.h
@@ -0,0 +1,20 @@
+/* QLogic qed NIC Driver
+ * Copyright (c) 2015 QLogic Corporation
+ *
+ * This software is available under the terms of the GNU General Public License
+ * (GPL) Version 2, available from the file COPYING in the main directory of
+ * this source tree.
+ */
+
+#ifndef _QED_IOV_IF_H
+#define _QED_IOV_IF_H
+
+#include <linux/qed/qed_if.h>
+
+/* Structs used by PF to control and manipulate child VFs */
+struct qed_iov_hv_ops {
+	int (*configure)(struct qed_dev *cdev, int num_vfs_param);
+
+};
+
+#endif
-- 
1.9.3
