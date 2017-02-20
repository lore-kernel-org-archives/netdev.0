From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 03/10] qed: Don't free a QP more than once
Date: Mon, 20 Feb 2017 22:43:32 +0200
Message-ID: <1487623419-6442-4-git-send-email-Yuval.Mintz@cavium.com>
References: <1487623419-6442-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ram Amrani <Ram.Amrani@cavium.com>,
        Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:46438 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751222AbdBTU7g (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Feb 2017 15:59:36 -0500
In-Reply-To: <1487623419-6442-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ram Amrani <Ram.Amrani@cavium.com>

If QP is in reset state then there are no resources to free so avoid
freeing any.

Signed-off-by: Ram Amrani <Ram.Amrani@cavium.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_roce.c | 49 ++++++++++++++++--------------
 1 file changed, 27 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_roce.c b/drivers/net/ethernet/qlogic/qed/qed_roce.c
index 65d5b9a..d9ff6b2 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_roce.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_roce.c
@@ -1849,6 +1849,7 @@ static int qed_roce_query_qp(struct qed_hwfn *p_hwfn,
 
 static int qed_roce_destroy_qp(struct qed_hwfn *p_hwfn, struct qed_rdma_qp *qp)
 {
+	struct qed_rdma_info *p_rdma_info = p_hwfn->p_rdma_info;
 	u32 num_invalidated_mw = 0;
 	u32 num_bound_mw = 0;
 	u32 start_cid;
@@ -1863,35 +1864,39 @@ static int qed_roce_destroy_qp(struct qed_hwfn *p_hwfn, struct qed_rdma_qp *qp)
 		return -EINVAL;
 	}
 
-	rc = qed_roce_sp_destroy_qp_responder(p_hwfn, qp, &num_invalidated_mw);
-	if (rc)
-		return rc;
+	if (qp->cur_state != QED_ROCE_QP_STATE_RESET) {
+		rc = qed_roce_sp_destroy_qp_responder(p_hwfn, qp,
+						      &num_invalidated_mw);
+		if (rc)
+			return rc;
 
-	/* Send destroy requester ramrod */
-	rc = qed_roce_sp_destroy_qp_requester(p_hwfn, qp, &num_bound_mw);
-	if (rc)
-		return rc;
+		/* Send destroy requester ramrod */
+		rc = qed_roce_sp_destroy_qp_requester(p_hwfn, qp,
+						      &num_bound_mw);
+		if (rc)
+			return rc;
 
-	if (num_invalidated_mw != num_bound_mw) {
-		DP_NOTICE(p_hwfn,
-			  "number of invalidate memory windows is different from bounded ones\n");
-		return -EINVAL;
-	}
+		if (num_invalidated_mw != num_bound_mw) {
+			DP_NOTICE(p_hwfn,
+				  "number of invalidate memory windows is different from bounded ones\n");
+			return -EINVAL;
+		}
 
-	spin_lock_bh(&p_hwfn->p_rdma_info->lock);
+		spin_lock_bh(&p_rdma_info->lock);
 
-	start_cid = qed_cxt_get_proto_cid_start(p_hwfn,
-						p_hwfn->p_rdma_info->proto);
+		start_cid = qed_cxt_get_proto_cid_start(p_hwfn,
+							p_rdma_info->proto);
 
-	/* Release responder's icid */
-	qed_bmap_release_id(p_hwfn, &p_hwfn->p_rdma_info->cid_map,
-			    qp->icid - start_cid);
+		/* Release responder's icid */
+		qed_bmap_release_id(p_hwfn, &p_rdma_info->cid_map,
+				    qp->icid - start_cid);
 
-	/* Release requester's icid */
-	qed_bmap_release_id(p_hwfn, &p_hwfn->p_rdma_info->cid_map,
-			    qp->icid + 1 - start_cid);
+		/* Release requester's icid */
+		qed_bmap_release_id(p_hwfn, &p_rdma_info->cid_map,
+				    qp->icid + 1 - start_cid);
 
-	spin_unlock_bh(&p_hwfn->p_rdma_info->lock);
+		spin_unlock_bh(&p_rdma_info->lock);
+	}
 
 	return 0;
 }
-- 
1.9.3
