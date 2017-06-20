From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH v4 net-next 3/7] qed: Disable RoCE dpm when DCBx change occurs
Date: Tue, 20 Jun 2017 16:00:02 +0300
Message-ID: <20170620130006.307-4-Yuval.Mintz@cavium.com>
References: <20170620130006.307-1-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Michal.Kalderon@cavium.com>, <linux-rdma@vger.kernel.org>,
        Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0055.outbound.protection.outlook.com ([104.47.37.55]:23792
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751095AbdFTNBl (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 20 Jun 2017 09:01:41 -0400
In-Reply-To: <20170620130006.307-1-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If DCBx update occurs while QPs are open, stop sending edpms until all
QPs are closed.

Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_dcbx.c |  8 +++++++
 drivers/net/ethernet/qlogic/qed/qed_roce.c | 36 ++++++++++++++++++++++++++++++
 drivers/net/ethernet/qlogic/qed/qed_roce.h |  5 +++++
 3 files changed, 49 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_dcbx.c b/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
index 15b516a..f888045 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dcbx.c
@@ -44,6 +44,7 @@
 #include "qed_hsi.h"
 #include "qed_sp.h"
 #include "qed_sriov.h"
+#include "qed_roce.h"
 #ifdef CONFIG_DCB
 #include <linux/qed/qed_eth_if.h>
 #endif
@@ -892,6 +893,13 @@ qed_dcbx_mib_update_event(struct qed_hwfn *p_hwfn,
 
 			/* update storm FW with negotiation results */
 			qed_sp_pf_update(p_hwfn);
+
+			/* for roce PFs, we may want to enable/disable DPM
+			 * when DCBx change occurs
+			 */
+			if (p_hwfn->hw_info.personality ==
+			    QED_PCI_ETH_ROCE)
+				qed_roce_dpm_dcbx(p_hwfn, p_ptt);
 		}
 	}
 
diff --git a/drivers/net/ethernet/qlogic/qed/qed_roce.c b/drivers/net/ethernet/qlogic/qed/qed_roce.c
index 4bc2f6c..8419dcc 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_roce.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_roce.c
@@ -162,6 +162,11 @@ static int qed_bmap_test_id(struct qed_hwfn *p_hwfn,
 	return test_bit(id_num, bmap->bitmap);
 }
 
+static bool qed_bmap_is_empty(struct qed_bmap *bmap)
+{
+	return bmap->max_count == find_first_bit(bmap->bitmap, bmap->max_count);
+}
+
 static u32 qed_rdma_get_sb_id(void *p_hwfn, u32 rel_sb_id)
 {
 	/* First sb id for RoCE is after all the l2 sb */
@@ -2638,6 +2643,23 @@ static void *qed_rdma_get_rdma_ctx(struct qed_dev *cdev)
 	return QED_LEADING_HWFN(cdev);
 }
 
+static bool qed_rdma_allocated_qps(struct qed_hwfn *p_hwfn)
+{
+	bool result;
+
+	/* if rdma info has not been allocated, naturally there are no qps */
+	if (!p_hwfn->p_rdma_info)
+		return false;
+
+	spin_lock_bh(&p_hwfn->p_rdma_info->lock);
+	if (!p_hwfn->p_rdma_info->cid_map.bitmap)
+		result = false;
+	else
+		result = !qed_bmap_is_empty(&p_hwfn->p_rdma_info->cid_map);
+	spin_unlock_bh(&p_hwfn->p_rdma_info->lock);
+	return result;
+}
+
 static void qed_rdma_dpm_conf(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt)
 {
 	u32 val;
@@ -2650,6 +2672,20 @@ static void qed_rdma_dpm_conf(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt)
 		   val, p_hwfn->dcbx_no_edpm, p_hwfn->db_bar_no_edpm);
 }
 
+void qed_roce_dpm_dcbx(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt)
+{
+	u8 val;
+
+	/* if any QPs are already active, we want to disable DPM, since their
+	 * context information contains information from before the latest DCBx
+	 * update. Otherwise enable it.
+	 */
+	val = qed_rdma_allocated_qps(p_hwfn) ? true : false;
+	p_hwfn->dcbx_no_edpm = (u8)val;
+
+	qed_rdma_dpm_conf(p_hwfn, p_ptt);
+}
+
 void qed_rdma_dpm_bar(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt)
 {
 	p_hwfn->db_bar_no_edpm = true;
diff --git a/drivers/net/ethernet/qlogic/qed/qed_roce.h b/drivers/net/ethernet/qlogic/qed/qed_roce.h
index 94be3b5..ddd7761 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_roce.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_roce.h
@@ -168,10 +168,15 @@ struct qed_rdma_qp {
 
 #if IS_ENABLED(CONFIG_QED_RDMA)
 void qed_rdma_dpm_bar(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt);
+void qed_roce_dpm_dcbx(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt);
 void qed_roce_async_event(struct qed_hwfn *p_hwfn,
 			  u8 fw_event_code, union rdma_eqe_data *rdma_data);
 #else
 static inline void qed_rdma_dpm_bar(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt) {}
+
+static inline void qed_roce_dpm_dcbx(struct qed_hwfn *p_hwfn,
+				     struct qed_ptt *p_ptt) {}
+
 static inline void qed_roce_async_event(struct qed_hwfn *p_hwfn,
 					u8 fw_event_code,
 					union rdma_eqe_data *rdma_data) {}
-- 
2.9.4
