From: Yuval Mintz <Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net 3/3] qed: Don't free a QP more than once
Date: Tue, 24 Jan 2017 23:15:23 +0200
Message-ID: <1485292523-8821-4-git-send-email-Yuval.Mintz@cavium.com>
References: <1485292523-8821-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <Ram.Amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        Yuval Mintz <Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
To: <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1485292523-8821-1-git-send-email-Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Ram Amrani <Ram.Amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>

If QP is in reset state then there are no resources to free so avoid
freeing any.

Signed-off-by: Ram Amrani <Ram.Amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Signed-off-by: Yuval Mintz <Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
---
 drivers/net/ethernet/qlogic/qed/qed_roce.c | 49 ++++++++++++++++--------------
 1 file changed, 27 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_roce.c b/drivers/net/ethernet/qlogic/qed/qed_roce.c
index 0846068..a074c76 100644
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
1.8.3.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
