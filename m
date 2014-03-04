From: Hariprasad Shenai <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCHv3 net-next 13/31] iw_cxgb4: Mind the sq_sig_all/sq_sig_type QP attributes.
Date: Tue,  4 Mar 2014 18:11:39 +0530
Message-ID: <1393936917-25847-14-git-send-email-hariprasad@chelsio.com>
References: <1393936917-25847-1-git-send-email-hariprasad@chelsio.com>
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org, kumaras-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	dm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org, leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	santosh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, nirranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1393936917-25847-1-git-send-email-hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>

Signed-off-by: Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
---
 drivers/infiniband/hw/cxgb4/iw_cxgb4.h | 1 +
 drivers/infiniband/hw/cxgb4/qp.c       | 6 ++++--
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb4/iw_cxgb4.h b/drivers/infiniband/hw/cxgb4/iw_cxgb4.h
index c05c875..8c32088 100644
--- a/drivers/infiniband/hw/cxgb4/iw_cxgb4.h
+++ b/drivers/infiniband/hw/cxgb4/iw_cxgb4.h
@@ -448,6 +448,7 @@ struct c4iw_qp {
 	atomic_t refcnt;
 	wait_queue_head_t wait;
 	struct timer_list timer;
+	int sq_sig_all;
 };
 
 static inline struct c4iw_qp *to_c4iw_qp(struct ib_qp *ibqp)
diff --git a/drivers/infiniband/hw/cxgb4/qp.c b/drivers/infiniband/hw/cxgb4/qp.c
index ce75a2f..c8cc299 100644
--- a/drivers/infiniband/hw/cxgb4/qp.c
+++ b/drivers/infiniband/hw/cxgb4/qp.c
@@ -732,7 +732,7 @@ int c4iw_post_send(struct ib_qp *ibqp, struct ib_send_wr *wr,
 		fw_flags = 0;
 		if (wr->send_flags & IB_SEND_SOLICITED)
 			fw_flags |= FW_RI_SOLICITED_EVENT_FLAG;
-		if (wr->send_flags & IB_SEND_SIGNALED)
+		if (wr->send_flags & IB_SEND_SIGNALED || qhp->sq_sig_all)
 			fw_flags |= FW_RI_COMPLETION_FLAG;
 		swsqe = &qhp->wq.sq.sw_sq[qhp->wq.sq.pidx];
 		switch (wr->opcode) {
@@ -793,7 +793,8 @@ int c4iw_post_send(struct ib_qp *ibqp, struct ib_send_wr *wr,
 		}
 		swsqe->idx = qhp->wq.sq.pidx;
 		swsqe->complete = 0;
-		swsqe->signaled = (wr->send_flags & IB_SEND_SIGNALED);
+		swsqe->signaled = (wr->send_flags & IB_SEND_SIGNALED) ||
+				  qhp->sq_sig_all;
 		swsqe->flushed = 0;
 		swsqe->wr_id = wr->wr_id;
 
@@ -1620,6 +1621,7 @@ struct ib_qp *c4iw_create_qp(struct ib_pd *pd, struct ib_qp_init_attr *attrs,
 	qhp->attr.enable_bind = 1;
 	qhp->attr.max_ord = 1;
 	qhp->attr.max_ird = 1;
+	qhp->sq_sig_all = attrs->sq_sig_type == IB_SIGNAL_ALL_WR;
 	spin_lock_init(&qhp->lock);
 	mutex_init(&qhp->mutex);
 	init_waitqueue_head(&qhp->wait);
-- 
1.8.4

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
