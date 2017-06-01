From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 11/11] qed: No need to reset SBs on IOV init
Date: Thu, 1 Jun 2017 15:29:11 +0300
Message-ID: <20170601122911.22493-12-Yuval.Mintz@cavium.com>
References: <20170601122911.22493-1-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0067.outbound.protection.outlook.com ([104.47.34.67]:54640
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751108AbdFAMaz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 1 Jun 2017 08:30:55 -0400
In-Reply-To: <20170601122911.22493-1-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since we're resetting the IGU CAM each time we initialize the PF
device, there's no need to reset the VF SBs again when initializing
IOV.

Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_dev.c   |  2 +-
 drivers/net/ethernet/qlogic/qed/qed_sriov.c | 30 +----------------------------
 drivers/net/ethernet/qlogic/qed/qed_sriov.h |  5 ++---
 3 files changed, 4 insertions(+), 33 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev.c b/drivers/net/ethernet/qlogic/qed/qed_dev.c
index 939e85c..7649f35 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev.c
@@ -1030,7 +1030,7 @@ void qed_resc_setup(struct qed_dev *cdev)
 
 		qed_int_setup(p_hwfn, p_hwfn->p_main_ptt);
 
-		qed_iov_setup(p_hwfn, p_hwfn->p_main_ptt);
+		qed_iov_setup(p_hwfn);
 #ifdef CONFIG_QED_LL2
 		if (p_hwfn->using_ll2)
 			qed_ll2_setup(p_hwfn);
diff --git a/drivers/net/ethernet/qlogic/qed/qed_sriov.c b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
index b7dda60..6ca2892 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sriov.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
@@ -378,33 +378,6 @@ static int qed_iov_pci_cfg_info(struct qed_dev *cdev)
 	return 0;
 }
 
-static void qed_iov_clear_vf_igu_blocks(struct qed_hwfn *p_hwfn,
-					struct qed_ptt *p_ptt)
-{
-	struct qed_igu_block *p_sb;
-	u16 sb_id;
-	u32 val;
-
-	if (!p_hwfn->hw_info.p_igu_info) {
-		DP_ERR(p_hwfn,
-		       "qed_iov_clear_vf_igu_blocks IGU Info not initialized\n");
-		return;
-	}
-
-	for (sb_id = 0; sb_id < QED_MAPPING_MEMORY_SIZE(p_hwfn->cdev);
-	     sb_id++) {
-		p_sb = &p_hwfn->hw_info.p_igu_info->entry[sb_id];
-		if ((p_sb->status & QED_IGU_STATUS_FREE) &&
-		    !(p_sb->status & QED_IGU_STATUS_PF)) {
-			val = qed_rd(p_hwfn, p_ptt,
-				     IGU_REG_MAPPING_MEMORY + sb_id * 4);
-			SET_FIELD(val, IGU_MAPPING_LINE_VALID, 0);
-			qed_wr(p_hwfn, p_ptt,
-			       IGU_REG_MAPPING_MEMORY + 4 * sb_id, val);
-		}
-	}
-}
-
 static void qed_iov_setup_vfdb(struct qed_hwfn *p_hwfn)
 {
 	struct qed_hw_sriov_info *p_iov = p_hwfn->cdev->p_iov_info;
@@ -555,13 +528,12 @@ int qed_iov_alloc(struct qed_hwfn *p_hwfn)
 	return qed_iov_allocate_vfdb(p_hwfn);
 }
 
-void qed_iov_setup(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt)
+void qed_iov_setup(struct qed_hwfn *p_hwfn)
 {
 	if (!IS_PF_SRIOV(p_hwfn) || !IS_PF_SRIOV_ALLOC(p_hwfn))
 		return;
 
 	qed_iov_setup_vfdb(p_hwfn);
-	qed_iov_clear_vf_igu_blocks(p_hwfn, p_ptt);
 }
 
 void qed_iov_free(struct qed_hwfn *p_hwfn)
diff --git a/drivers/net/ethernet/qlogic/qed/qed_sriov.h b/drivers/net/ethernet/qlogic/qed/qed_sriov.h
index 81a497c..801cc00 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sriov.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_sriov.h
@@ -316,9 +316,8 @@ int qed_iov_alloc(struct qed_hwfn *p_hwfn);
  * @brief qed_iov_setup - setup sriov related resources
  *
  * @param p_hwfn
- * @param p_ptt
  */
-void qed_iov_setup(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt);
+void qed_iov_setup(struct qed_hwfn *p_hwfn);
 
 /**
  * @brief qed_iov_free - free sriov related resources
@@ -397,7 +396,7 @@ static inline int qed_iov_alloc(struct qed_hwfn *p_hwfn)
 	return 0;
 }
 
-static inline void qed_iov_setup(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt)
+static inline void qed_iov_setup(struct qed_hwfn *p_hwfn)
 {
 }
 
-- 
2.9.4
