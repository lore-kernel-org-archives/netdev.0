From: Hariprasad Shenai <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCHv5 net-next 28/31] iw_cxgb4: SQ flush fix
Date: Mon, 10 Mar 2014 22:38:25 +0530
Message-ID: <1394471308-4304-29-git-send-email-hariprasad@chelsio.com>
References: <1394471308-4304-1-git-send-email-hariprasad@chelsio.com>
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org, dm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org, leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	santosh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, kumaras-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, nirranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1394471308-4304-1-git-send-email-hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>

There is a race when moving a QP from RTS->CLOSING where a SQ work
request could be posted after the FW receives the RDMA_RI/FINI WR.
The SQ work request will never get processed, and should be completed
with FLUSHED status.  Function c4iw_flush_sq(), however was dropping
the oldest SQ work request when in CLOSING or IDLE states, instead of
completing the pending work request. If that oldest pending work request
was actually complete and has a CQE in the CQ, then when that CQE is
proceessed in poll_cq, we'll BUG_ON() due to the inconsistent SQ/CQ state.

This is a very small timing hole and has only been hit once so far.

The fix is two-fold:

1) c4iw_flush_sq() MUST always flush all non-completed WRs with FLUSHED
status regardless of the QP state.

2) In c4iw_modify_rc_qp(), always set the "in error" bit on the queue
before moving the state out of RTS.  This ensures that the state
transition will not happen while another thread is in post_rc_send(),
because set_state() and post_rc_send() both aquire the qp spinlock.
Also, once we transition the state out of RTS, subsequent calls to
post_rc_send() will fail because the "in error" bit is set.  I don't
think this fully closes the race where the FW can get a FINI followed a
SQ work request being posted (because they are posted to differente EQs),
but the #1 fix will handle the issue by flushing the SQ work request.

Signed-off-by: Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
---
 drivers/infiniband/hw/cxgb4/cq.c | 22 ++++++++--------------
 drivers/infiniband/hw/cxgb4/qp.c |  6 +++---
 2 files changed, 11 insertions(+), 17 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb4/cq.c b/drivers/infiniband/hw/cxgb4/cq.c
index 55f7157..121ad07 100644
--- a/drivers/infiniband/hw/cxgb4/cq.c
+++ b/drivers/infiniband/hw/cxgb4/cq.c
@@ -235,27 +235,21 @@ int c4iw_flush_sq(struct c4iw_qp *qhp)
 	struct t4_cq *cq = &chp->cq;
 	int idx;
 	struct t4_swsqe *swsqe;
-	int error = (qhp->attr.state != C4IW_QP_STATE_CLOSING &&
-			qhp->attr.state != C4IW_QP_STATE_IDLE);
 
 	if (wq->sq.flush_cidx == -1)
 		wq->sq.flush_cidx = wq->sq.cidx;
 	idx = wq->sq.flush_cidx;
 	BUG_ON(idx >= wq->sq.size);
 	while (idx != wq->sq.pidx) {
-		if (error) {
-			swsqe = &wq->sq.sw_sq[idx];
-			BUG_ON(swsqe->flushed);
-			swsqe->flushed = 1;
-			insert_sq_cqe(wq, cq, swsqe);
-			if (wq->sq.oldest_read == swsqe) {
-				BUG_ON(swsqe->opcode != FW_RI_READ_REQ);
-				advance_oldest_read(wq);
-			}
-			flushed++;
-		} else {
-			t4_sq_consume(wq);
+		swsqe = &wq->sq.sw_sq[idx];
+		BUG_ON(swsqe->flushed);
+		swsqe->flushed = 1;
+		insert_sq_cqe(wq, cq, swsqe);
+		if (wq->sq.oldest_read == swsqe) {
+			BUG_ON(swsqe->opcode != FW_RI_READ_REQ);
+			advance_oldest_read(wq);
 		}
+		flushed++;
 		if (++idx == wq->sq.size)
 			idx = 0;
 	}
diff --git a/drivers/infiniband/hw/cxgb4/qp.c b/drivers/infiniband/hw/cxgb4/qp.c
index 4c70df9..141999d 100644
--- a/drivers/infiniband/hw/cxgb4/qp.c
+++ b/drivers/infiniband/hw/cxgb4/qp.c
@@ -1359,6 +1359,7 @@ int c4iw_modify_qp(struct c4iw_dev *rhp, struct c4iw_qp *qhp,
 		switch (attrs->next_state) {
 		case C4IW_QP_STATE_CLOSING:
 			BUG_ON(atomic_read(&qhp->ep->com.kref.refcount) < 2);
+			t4_set_wq_in_error(&qhp->wq);
 			set_state(qhp, C4IW_QP_STATE_CLOSING);
 			ep = qhp->ep;
 			if (!internal) {
@@ -1366,16 +1367,15 @@ int c4iw_modify_qp(struct c4iw_dev *rhp, struct c4iw_qp *qhp,
 				disconnect = 1;
 				c4iw_get_ep(&qhp->ep->com);
 			}
-			t4_set_wq_in_error(&qhp->wq);
 			ret = rdma_fini(rhp, qhp, ep);
 			if (ret)
 				goto err;
 			break;
 		case C4IW_QP_STATE_TERMINATE:
+			t4_set_wq_in_error(&qhp->wq);
 			set_state(qhp, C4IW_QP_STATE_TERMINATE);
 			qhp->attr.layer_etype = attrs->layer_etype;
 			qhp->attr.ecode = attrs->ecode;
-			t4_set_wq_in_error(&qhp->wq);
 			ep = qhp->ep;
 			disconnect = 1;
 			if (!internal)
@@ -1388,8 +1388,8 @@ int c4iw_modify_qp(struct c4iw_dev *rhp, struct c4iw_qp *qhp,
 			c4iw_get_ep(&qhp->ep->com);
 			break;
 		case C4IW_QP_STATE_ERROR:
-			set_state(qhp, C4IW_QP_STATE_ERROR);
 			t4_set_wq_in_error(&qhp->wq);
+			set_state(qhp, C4IW_QP_STATE_ERROR);
 			if (!internal) {
 				abort = 1;
 				disconnect = 1;
-- 
1.8.4

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
