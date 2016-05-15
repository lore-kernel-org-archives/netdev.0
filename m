From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 2/5] qed: Improve VF interrupt reset
Date: Sun, 15 May 2016 14:48:06 +0300
Message-ID: <1463312889-19351-3-git-send-email-Yuval.Mintz@qlogic.com>
References: <1463312889-19351-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:46649 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754197AbcEOLs2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 May 2016 07:48:28 -0400
In-Reply-To: <1463312889-19351-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

During FLR flow, need to make sure HW is no longer capable of writing to
host memory as part of its interrupt mechanisms.
While we're at it, unify the logic cleaning the driver's status-blocks
into using a single API function for both PFs and VFs.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed_int.c      | 59 ++++++++++++++------------
 drivers/net/ethernet/qlogic/qed/qed_int.h      | 20 +--------
 drivers/net/ethernet/qlogic/qed/qed_reg_addr.h |  2 +
 drivers/net/ethernet/qlogic/qed/qed_sriov.c    | 20 +++------
 4 files changed, 41 insertions(+), 60 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_int.c b/drivers/net/ethernet/qlogic/qed/qed_int.c
index bbecfa5..09a6ad3 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_int.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_int.c
@@ -2805,20 +2805,13 @@ void qed_int_igu_disable_int(struct qed_hwfn *p_hwfn,
 }
 
 #define IGU_CLEANUP_SLEEP_LENGTH                (1000)
-void qed_int_igu_cleanup_sb(struct qed_hwfn *p_hwfn,
-			    struct qed_ptt *p_ptt,
-			    u32 sb_id,
-			    bool cleanup_set,
-			    u16 opaque_fid
-			    )
+static void qed_int_igu_cleanup_sb(struct qed_hwfn *p_hwfn,
+				   struct qed_ptt *p_ptt,
+				   u32 sb_id, bool cleanup_set, u16 opaque_fid)
 {
+	u32 cmd_ctrl = 0, val = 0, sb_bit = 0, sb_bit_addr = 0, data = 0;
 	u32 pxp_addr = IGU_CMD_INT_ACK_BASE + sb_id;
 	u32 sleep_cnt = IGU_CLEANUP_SLEEP_LENGTH;
-	u32 data = 0;
-	u32 cmd_ctrl = 0;
-	u32 val = 0;
-	u32 sb_bit = 0;
-	u32 sb_bit_addr = 0;
 
 	/* Set the data field */
 	SET_FIELD(data, IGU_CLEANUP_CLEANUP_SET, cleanup_set ? 1 : 0);
@@ -2863,11 +2856,9 @@ void qed_int_igu_cleanup_sb(struct qed_hwfn *p_hwfn,
 
 void qed_int_igu_init_pure_rt_single(struct qed_hwfn *p_hwfn,
 				     struct qed_ptt *p_ptt,
-				     u32 sb_id,
-				     u16 opaque,
-				     bool b_set)
+				     u32 sb_id, u16 opaque, bool b_set)
 {
-	int pi;
+	int pi, i;
 
 	/* Set */
 	if (b_set)
@@ -2876,6 +2867,22 @@ void qed_int_igu_init_pure_rt_single(struct qed_hwfn *p_hwfn,
 	/* Clear */
 	qed_int_igu_cleanup_sb(p_hwfn, p_ptt, sb_id, 0, opaque);
 
+	/* Wait for the IGU SB to cleanup */
+	for (i = 0; i < IGU_CLEANUP_SLEEP_LENGTH; i++) {
+		u32 val;
+
+		val = qed_rd(p_hwfn, p_ptt,
+			     IGU_REG_WRITE_DONE_PENDING + ((sb_id / 32) * 4));
+		if (val & (1 << (sb_id % 32)))
+			usleep_range(10, 20);
+		else
+			break;
+	}
+	if (i == IGU_CLEANUP_SLEEP_LENGTH)
+		DP_NOTICE(p_hwfn,
+			  "Failed SB[0x%08x] still appearing in WRITE_DONE_PENDING\n",
+			  sb_id);
+
 	/* Clear the CAU for the SB */
 	for (pi = 0; pi < 12; pi++)
 		qed_wr(p_hwfn, p_ptt,
@@ -2884,13 +2891,11 @@ void qed_int_igu_init_pure_rt_single(struct qed_hwfn *p_hwfn,
 
 void qed_int_igu_init_pure_rt(struct qed_hwfn *p_hwfn,
 			      struct qed_ptt *p_ptt,
-			      bool b_set,
-			      bool b_slowpath)
+			      bool b_set, bool b_slowpath)
 {
 	u32 igu_base_sb = p_hwfn->hw_info.p_igu_info->igu_base_sb;
 	u32 igu_sb_cnt = p_hwfn->hw_info.p_igu_info->igu_sb_cnt;
-	u32 sb_id = 0;
-	u32 val = 0;
+	u32 sb_id = 0, val = 0;
 
 	val = qed_rd(p_hwfn, p_ptt, IGU_REG_BLOCK_CONFIGURATION);
 	val |= IGU_REG_BLOCK_CONFIGURATION_VF_CLEANUP_EN;
@@ -2906,14 +2911,14 @@ void qed_int_igu_init_pure_rt(struct qed_hwfn *p_hwfn,
 						p_hwfn->hw_info.opaque_fid,
 						b_set);
 
-	if (b_slowpath) {
-		sb_id = p_hwfn->hw_info.p_igu_info->igu_dsb_id;
-		DP_VERBOSE(p_hwfn, NETIF_MSG_INTR,
-			   "IGU cleaning slowpath SB [%d]\n", sb_id);
-		qed_int_igu_init_pure_rt_single(p_hwfn, p_ptt, sb_id,
-						p_hwfn->hw_info.opaque_fid,
-						b_set);
-	}
+	if (!b_slowpath)
+		return;
+
+	sb_id = p_hwfn->hw_info.p_igu_info->igu_dsb_id;
+	DP_VERBOSE(p_hwfn, NETIF_MSG_INTR,
+		   "IGU cleaning slowpath SB [%d]\n", sb_id);
+	qed_int_igu_init_pure_rt_single(p_hwfn, p_ptt, sb_id,
+					p_hwfn->hw_info.opaque_fid, b_set);
 }
 
 static u32 qed_int_igu_read_cam_block(struct qed_hwfn	*p_hwfn,
diff --git a/drivers/net/ethernet/qlogic/qed/qed_int.h b/drivers/net/ethernet/qlogic/qed/qed_int.h
index 295df44..20b4686 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_int.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_int.h
@@ -298,26 +298,8 @@ u16 qed_int_get_sp_sb_id(struct qed_hwfn *p_hwfn);
  * @param p_hwfn
  * @param p_ptt
  * @param sb_id		- igu status block id
- * @param cleanup_set	- set(1) / clear(0)
- * @param opaque_fid    - the function for which to perform
- *			cleanup, for example a PF on behalf of
- *			its VFs.
- */
-void qed_int_igu_cleanup_sb(struct qed_hwfn *p_hwfn,
-			    struct qed_ptt *p_ptt,
-			    u32 sb_id,
-			    bool cleanup_set,
-			    u16 opaque_fid);
-
-/**
- * @brief Status block cleanup. Should be called for each status
- *        block that will be used -> both PF / VF
- *
- * @param p_hwfn
- * @param p_ptt
- * @param sb_id		- igu status block id
  * @param opaque	- opaque fid of the sb owner.
- * @param cleanup_set	- set(1) / clear(0)
+ * @param b_set		- set(1) / clear(0)
  */
 void qed_int_igu_init_pure_rt_single(struct qed_hwfn *p_hwfn,
 				     struct qed_ptt *p_ptt,
diff --git a/drivers/net/ethernet/qlogic/qed/qed_reg_addr.h b/drivers/net/ethernet/qlogic/qed/qed_reg_addr.h
index bb7dcf1..3a6c506 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_reg_addr.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_reg_addr.h
@@ -429,6 +429,8 @@
 	0x184000UL
 #define IGU_REG_STATISTIC_NUM_VF_MSG_SENT \
 	0x180408UL
+#define IGU_REG_WRITE_DONE_PENDING \
+	0x180900UL
 #define  MISCS_REG_GENERIC_POR_0	\
 	0x0096d4UL
 #define  MCP_REG_NVM_CFG4 \
diff --git a/drivers/net/ethernet/qlogic/qed/qed_sriov.c b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
index 2c4f9b0..7b6b4a0 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sriov.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
@@ -526,7 +526,6 @@ static void qed_iov_vf_pglue_clear_err(struct qed_hwfn *p_hwfn,
 static void qed_iov_vf_igu_reset(struct qed_hwfn *p_hwfn,
 				 struct qed_ptt *p_ptt, struct qed_vf_info *vf)
 {
-	u16 igu_sb_id;
 	int i;
 
 	/* Set VF masks and configuration - pretend */
@@ -534,23 +533,14 @@ static void qed_iov_vf_igu_reset(struct qed_hwfn *p_hwfn,
 
 	qed_wr(p_hwfn, p_ptt, IGU_REG_STATISTIC_NUM_VF_MSG_SENT, 0);
 
-	DP_VERBOSE(p_hwfn, QED_MSG_IOV,
-		   "value in VF_CONFIGURATION of vf %d after write %x\n",
-		   vf->abs_vf_id,
-		   qed_rd(p_hwfn, p_ptt, IGU_REG_VF_CONFIGURATION));
-
 	/* unpretend */
 	qed_fid_pretend(p_hwfn, p_ptt, (u16) p_hwfn->hw_info.concrete_fid);
 
 	/* iterate over all queues, clear sb consumer */
-	for (i = 0; i < vf->num_sbs; i++) {
-		igu_sb_id = vf->igu_sbs[i];
-		/* Set then clear... */
-		qed_int_igu_cleanup_sb(p_hwfn, p_ptt, igu_sb_id, 1,
-				       vf->opaque_fid);
-		qed_int_igu_cleanup_sb(p_hwfn, p_ptt, igu_sb_id, 0,
-				       vf->opaque_fid);
-	}
+	for (i = 0; i < vf->num_sbs; i++)
+		qed_int_igu_init_pure_rt_single(p_hwfn, p_ptt,
+						vf->igu_sbs[i],
+						vf->opaque_fid, true);
 }
 
 static void qed_iov_vf_igu_set_int(struct qed_hwfn *p_hwfn,
@@ -591,6 +581,8 @@ static int qed_iov_enable_vf_access(struct qed_hwfn *p_hwfn,
 
 	qed_iov_vf_pglue_clear_err(p_hwfn, p_ptt, QED_VF_ABS_ID(p_hwfn, vf));
 
+	qed_iov_vf_igu_reset(p_hwfn, p_ptt, vf);
+
 	rc = qed_mcp_config_vf_msix(p_hwfn, p_ptt, vf->abs_vf_id, vf->num_sbs);
 	if (rc)
 		return rc;
-- 
1.9.3
