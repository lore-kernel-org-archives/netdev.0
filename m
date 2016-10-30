From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 6/7] qed: Use VF-queue feature
Date: Sun, 30 Oct 2016 18:38:36 +0200
Message-ID: <1477845517-17228-7-git-send-email-Yuval.Mintz@cavium.com>
References: <1477845517-17228-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:40984 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1757171AbcJ3Qi5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Oct 2016 12:38:57 -0400
In-Reply-To: <1477845517-17228-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Driver sets several restrictions about the number of supported VFs
according to available HW/FW resources.
This creates a problem as there are constellations which can't be
supported [as limitation don't accurately describe the resources],
as well as holes where enabling IOV would fail due to supposed
lack of resources.

This introduces a new interal feature - vf-queues, which would
be used to lift some of the restriction and accurately enumerate
the queues that can be used by a given PF's VFs.

Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed.h       |  1 +
 drivers/net/ethernet/qlogic/qed/qed_dev.c   | 20 ++++++++++++++----
 drivers/net/ethernet/qlogic/qed/qed_int.c   | 32 ++++++++++++++++++++++++++++-
 drivers/net/ethernet/qlogic/qed/qed_sriov.c | 17 ++++++---------
 4 files changed, 54 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed.h b/drivers/net/ethernet/qlogic/qed/qed.h
index 8828ffa..6d3013f 100644
--- a/drivers/net/ethernet/qlogic/qed/qed.h
+++ b/drivers/net/ethernet/qlogic/qed/qed.h
@@ -174,6 +174,7 @@ enum QED_FEATURE {
 	QED_PF_L2_QUE,
 	QED_VF,
 	QED_RDMA_CNQ,
+	QED_VF_L2_QUE,
 	QED_MAX_FEATURES,
 };
 
diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev.c b/drivers/net/ethernet/qlogic/qed/qed_dev.c
index 13833a5..b59da1a 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev.c
@@ -1475,6 +1475,7 @@ static void get_function_id(struct qed_hwfn *p_hwfn)
 static void qed_hw_set_feat(struct qed_hwfn *p_hwfn)
 {
 	u32 *feat_num = p_hwfn->hw_info.feat_num;
+	struct qed_sb_cnt_info sb_cnt_info;
 	int num_features = 1;
 
 #if IS_ENABLED(CONFIG_INFINIBAND_QEDR)
@@ -1493,10 +1494,21 @@ static void qed_hw_set_feat(struct qed_hwfn *p_hwfn)
 	feat_num[QED_PF_L2_QUE] = min_t(u32, RESC_NUM(p_hwfn, QED_SB) /
 						num_features,
 					RESC_NUM(p_hwfn, QED_L2_QUEUE));
-	DP_VERBOSE(p_hwfn, NETIF_MSG_PROBE,
-		   "#PF_L2_QUEUES=%d #SBS=%d num_features=%d\n",
-		   feat_num[QED_PF_L2_QUE], RESC_NUM(p_hwfn, QED_SB),
-		   num_features);
+
+	memset(&sb_cnt_info, 0, sizeof(sb_cnt_info));
+	qed_int_get_num_sbs(p_hwfn, &sb_cnt_info);
+	feat_num[QED_VF_L2_QUE] =
+	    min_t(u32,
+		  RESC_NUM(p_hwfn, QED_L2_QUEUE) -
+		  FEAT_NUM(p_hwfn, QED_PF_L2_QUE), sb_cnt_info.sb_iov_cnt);
+
+	DP_VERBOSE(p_hwfn,
+		   NETIF_MSG_PROBE,
+		   "#PF_L2_QUEUES=%d VF_L2_QUEUES=%d #ROCE_CNQ=%d #SBS=%d num_features=%d\n",
+		   (int)FEAT_NUM(p_hwfn, QED_PF_L2_QUE),
+		   (int)FEAT_NUM(p_hwfn, QED_VF_L2_QUE),
+		   (int)FEAT_NUM(p_hwfn, QED_RDMA_CNQ),
+		   RESC_NUM(p_hwfn, QED_SB), num_features);
 }
 
 static int qed_hw_get_resc(struct qed_hwfn *p_hwfn)
diff --git a/drivers/net/ethernet/qlogic/qed/qed_int.c b/drivers/net/ethernet/qlogic/qed/qed_int.c
index 2adedc6..bb74e1c 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_int.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_int.c
@@ -3030,6 +3030,31 @@ int qed_int_igu_read_cam(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt)
 			}
 		}
 	}
+
+	/* There's a possibility the igu_sb_cnt_iov doesn't properly reflect
+	 * the number of VF SBs [especially for first VF on engine, as we can't
+	 * diffrentiate between empty entries and its entries].
+	 * Since we don't really support more SBs than VFs today, prevent any
+	 * such configuration by sanitizing the number of SBs to equal the
+	 * number of VFs.
+	 */
+	if (IS_PF_SRIOV(p_hwfn)) {
+		u16 total_vfs = p_hwfn->cdev->p_iov_info->total_vfs;
+
+		if (total_vfs < p_igu_info->free_blks) {
+			DP_VERBOSE(p_hwfn,
+				   (NETIF_MSG_INTR | QED_MSG_IOV),
+				   "Limiting number of SBs for IOV - %04x --> %04x\n",
+				   p_igu_info->free_blks,
+				   p_hwfn->cdev->p_iov_info->total_vfs);
+			p_igu_info->free_blks = total_vfs;
+		} else if (total_vfs > p_igu_info->free_blks) {
+			DP_NOTICE(p_hwfn,
+				  "IGU has only %04x SBs for VFs while the device has %04x VFs\n",
+				  p_igu_info->free_blks, total_vfs);
+			return -EINVAL;
+		}
+	}
 	p_igu_info->igu_sb_cnt_iov = p_igu_info->free_blks;
 
 	DP_VERBOSE(
@@ -3163,7 +3188,12 @@ u16 qed_int_queue_id_from_sb_id(struct qed_hwfn *p_hwfn, u16 sb_id)
 		return sb_id - p_info->igu_base_sb;
 	} else if ((sb_id >= p_info->igu_base_sb_iov) &&
 		   (sb_id < p_info->igu_base_sb_iov + p_info->igu_sb_cnt_iov)) {
-		return sb_id - p_info->igu_base_sb_iov + p_info->igu_sb_cnt;
+		/* We want the first VF queue to be adjacent to the
+		 * last PF queue. Since L2 queues can be partial to
+		 * SBs, we'll use the feature instead.
+		 */
+		return sb_id - p_info->igu_base_sb_iov +
+		       FEAT_NUM(p_hwfn, QED_PF_L2_QUE);
 	} else {
 		DP_NOTICE(p_hwfn, "SB %d not in range for function\n", sb_id);
 		return 0;
diff --git a/drivers/net/ethernet/qlogic/qed/qed_sriov.c b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
index 6f029f9..f3f742a 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sriov.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
@@ -3470,7 +3470,6 @@ int qed_sriov_disable(struct qed_dev *cdev, bool pci_enabled)
 
 static int qed_sriov_enable(struct qed_dev *cdev, int num)
 {
-	struct qed_sb_cnt_info sb_cnt_info;
 	int i, j, rc;
 
 	if (num >= RESC_NUM(&cdev->hwfns[0], QED_VPORT)) {
@@ -3483,7 +3482,11 @@ static int qed_sriov_enable(struct qed_dev *cdev, int num)
 	for_each_hwfn(cdev, j) {
 		struct qed_hwfn *hwfn = &cdev->hwfns[j];
 		struct qed_ptt *ptt = qed_ptt_acquire(hwfn);
-		int num_sbs = 0, limit = 16;
+		int num_queues;
+
+		/* Make sure not to use more than 16 queues per VF */
+		num_queues = min_t(int,
+				   FEAT_NUM(hwfn, QED_VF_L2_QUE) / num, 16);
 
 		if (!ptt) {
 			DP_ERR(hwfn, "Failed to acquire ptt\n");
@@ -3491,19 +3494,11 @@ static int qed_sriov_enable(struct qed_dev *cdev, int num)
 			goto err;
 		}
 
-		if (IS_MF_DEFAULT(hwfn))
-			limit = MAX_NUM_VFS_BB / hwfn->num_funcs_on_engine;
-
-		memset(&sb_cnt_info, 0, sizeof(sb_cnt_info));
-		qed_int_get_num_sbs(hwfn, &sb_cnt_info);
-		num_sbs = min_t(int, sb_cnt_info.sb_free_blk, limit);
-
 		for (i = 0; i < num; i++) {
 			if (!qed_iov_is_valid_vfid(hwfn, i, false, true))
 				continue;
 
-			rc = qed_iov_init_hw_for_vf(hwfn,
-						    ptt, i, num_sbs / num);
+			rc = qed_iov_init_hw_for_vf(hwfn, ptt, i, num_queues);
 			if (rc) {
 				DP_ERR(cdev, "Failed to enable VF[%d]\n", i);
 				qed_ptt_release(hwfn, ptt);
-- 
1.9.3
