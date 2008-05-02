From: Steve Wise <swise@opengridcomputing.com>
Subject: [PATCH 2.6.26 1/3] RDMA/cxgb3: QP flush fixes
Date: Fri, 02 May 2008 11:17:41 -0500
Message-ID: <20080502161741.30500.95337.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	general@lists.openfabrics.org
To: rdreier@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:43348 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759834AbYEBQRm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2008 12:17:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


- Flush the QP only after the HW disables the connection.
  Currently we flush the QP when transitioning to CLOSING.  This
  exposes a race condition where the HW can complete a RECV WR,
  for instance, -and- the SW can flush that same WR.

- Only call CQ event handlers on flush IFF we actually flushed
  anything.

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---

 drivers/infiniband/hw/cxgb3/cxio_hal.c |   13 ++++++++++---
 drivers/infiniband/hw/cxgb3/cxio_hal.h |    4 ++--
 drivers/infiniband/hw/cxgb3/iwch_qp.c  |   13 ++++++++-----
 3 files changed, 20 insertions(+), 10 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb3/cxio_hal.c b/drivers/infiniband/hw/cxgb3/cxio_hal.c
index 3de0fbf..8a86960 100644
--- a/drivers/infiniband/hw/cxgb3/cxio_hal.c
+++ b/drivers/infiniband/hw/cxgb3/cxio_hal.c
@@ -359,9 +359,10 @@ static void insert_recv_cqe(struct t3_wq *wq, struct t3_cq *cq)
 	cq->sw_wptr++;
 }
 
-void cxio_flush_rq(struct t3_wq *wq, struct t3_cq *cq, int count)
+int cxio_flush_rq(struct t3_wq *wq, struct t3_cq *cq, int count)
 {
 	u32 ptr;
+	int flushed = 0;
 
 	PDBG("%s wq %p cq %p\n", __FUNCTION__, wq, cq);
 
@@ -369,8 +370,11 @@ void cxio_flush_rq(struct t3_wq *wq, struct t3_cq *cq, int count)
 	PDBG("%s rq_rptr %u rq_wptr %u skip count %u\n", __FUNCTION__,
 	    wq->rq_rptr, wq->rq_wptr, count);
 	ptr = wq->rq_rptr + count;
-	while (ptr++ != wq->rq_wptr)
+	while (ptr++ != wq->rq_wptr) {
 		insert_recv_cqe(wq, cq);
+		flushed++;
+	}
+	return flushed;
 }
 
 static void insert_sq_cqe(struct t3_wq *wq, struct t3_cq *cq,
@@ -394,9 +398,10 @@ static void insert_sq_cqe(struct t3_wq *wq, struct t3_cq *cq,
 	cq->sw_wptr++;
 }
 
-void cxio_flush_sq(struct t3_wq *wq, struct t3_cq *cq, int count)
+int cxio_flush_sq(struct t3_wq *wq, struct t3_cq *cq, int count)
 {
 	__u32 ptr;
+	int flushed = 0;
 	struct t3_swsq *sqp = wq->sq + Q_PTR2IDX(wq->sq_rptr, wq->sq_size_log2);
 
 	ptr = wq->sq_rptr + count;
@@ -405,7 +410,9 @@ void cxio_flush_sq(struct t3_wq *wq, struct t3_cq *cq, int count)
 		insert_sq_cqe(wq, cq, sqp);
 		sqp++;
 		ptr++;
+		flushed++;
 	}
+	return flushed;
 }
 
 /*
diff --git a/drivers/infiniband/hw/cxgb3/cxio_hal.h b/drivers/infiniband/hw/cxgb3/cxio_hal.h
index 2bcff7f..69ab08e 100644
--- a/drivers/infiniband/hw/cxgb3/cxio_hal.h
+++ b/drivers/infiniband/hw/cxgb3/cxio_hal.h
@@ -173,8 +173,8 @@ u32 cxio_hal_get_pdid(struct cxio_hal_resource *rscp);
 void cxio_hal_put_pdid(struct cxio_hal_resource *rscp, u32 pdid);
 int __init cxio_hal_init(void);
 void __exit cxio_hal_exit(void);
-void cxio_flush_rq(struct t3_wq *wq, struct t3_cq *cq, int count);
-void cxio_flush_sq(struct t3_wq *wq, struct t3_cq *cq, int count);
+int cxio_flush_rq(struct t3_wq *wq, struct t3_cq *cq, int count);
+int cxio_flush_sq(struct t3_wq *wq, struct t3_cq *cq, int count);
 void cxio_count_rcqes(struct t3_cq *cq, struct t3_wq *wq, int *count);
 void cxio_count_scqes(struct t3_cq *cq, struct t3_wq *wq, int *count);
 void cxio_flush_hw_cq(struct t3_cq *cq);
diff --git a/drivers/infiniband/hw/cxgb3/iwch_qp.c b/drivers/infiniband/hw/cxgb3/iwch_qp.c
index b0e5aea..353fbb3 100644
--- a/drivers/infiniband/hw/cxgb3/iwch_qp.c
+++ b/drivers/infiniband/hw/cxgb3/iwch_qp.c
@@ -655,6 +655,7 @@ static void __flush_qp(struct iwch_qp *qhp, unsigned long *flag)
 {
 	struct iwch_cq *rchp, *schp;
 	int count;
+	int flushed;
 
 	rchp = get_chp(qhp->rhp, qhp->attr.rcq);
 	schp = get_chp(qhp->rhp, qhp->attr.scq);
@@ -669,20 +670,22 @@ static void __flush_qp(struct iwch_qp *qhp, unsigned long *flag)
 	spin_lock(&qhp->lock);
 	cxio_flush_hw_cq(&rchp->cq);
 	cxio_count_rcqes(&rchp->cq, &qhp->wq, &count);
-	cxio_flush_rq(&qhp->wq, &rchp->cq, count);
+	flushed = cxio_flush_rq(&qhp->wq, &rchp->cq, count);
 	spin_unlock(&qhp->lock);
 	spin_unlock_irqrestore(&rchp->lock, *flag);
-	(*rchp->ibcq.comp_handler)(&rchp->ibcq, rchp->ibcq.cq_context);
+	if (flushed)
+		(*rchp->ibcq.comp_handler)(&rchp->ibcq, rchp->ibcq.cq_context);
 
 	/* locking heirarchy: cq lock first, then qp lock. */
 	spin_lock_irqsave(&schp->lock, *flag);
 	spin_lock(&qhp->lock);
 	cxio_flush_hw_cq(&schp->cq);
 	cxio_count_scqes(&schp->cq, &qhp->wq, &count);
-	cxio_flush_sq(&qhp->wq, &schp->cq, count);
+	flushed = cxio_flush_sq(&qhp->wq, &schp->cq, count);
 	spin_unlock(&qhp->lock);
 	spin_unlock_irqrestore(&schp->lock, *flag);
-	(*schp->ibcq.comp_handler)(&schp->ibcq, schp->ibcq.cq_context);
+	if (flushed)
+		(*schp->ibcq.comp_handler)(&schp->ibcq, schp->ibcq.cq_context);
 
 	/* deref */
 	if (atomic_dec_and_test(&qhp->refcnt))
@@ -880,7 +883,6 @@ int iwch_modify_qp(struct iwch_dev *rhp, struct iwch_qp *qhp,
 				ep = qhp->ep;
 				get_ep(&ep->com);
 			}
-			flush_qp(qhp, &flag);
 			break;
 		case IWCH_QP_STATE_TERMINATE:
 			qhp->attr.state = IWCH_QP_STATE_TERMINATE;
@@ -911,6 +913,7 @@ int iwch_modify_qp(struct iwch_dev *rhp, struct iwch_qp *qhp,
 		}
 		switch (attrs->next_state) {
 			case IWCH_QP_STATE_IDLE:
+				flush_qp(qhp, &flag);
 				qhp->attr.state = IWCH_QP_STATE_IDLE;
 				qhp->attr.llp_stream_handle = NULL;
 				put_ep(&qhp->ep->com);
