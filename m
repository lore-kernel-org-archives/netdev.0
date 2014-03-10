From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCHv5 net-next 13/31] iw_cxgb4: Mind the sq_sig_all/sq_sig_type QP attributes
Date: Mon, 10 Mar 2014 22:38:10 +0530
Message-ID: <1394471308-4304-14-git-send-email-hariprasad@chelsio.com>
References: <1394471308-4304-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, roland@purestorage.com, dm@chelsio.com,
	swise@opengridcomputing.com, leedom@chelsio.com,
	santosh@chelsio.com, kumaras@chelsio.com, nirranjan@chelsio.com,
	hariprasad@chelsio.com
To: netdev@vger.kernel.org, linux-rdma@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:18122 "EHLO
	stargate.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754189AbaCJRRn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 13:17:43 -0400
In-Reply-To: <1394471308-4304-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Wise <swise@opengridcomputing.com>

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
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
index 7aee163..4c70df9 100644
--- a/drivers/infiniband/hw/cxgb4/qp.c
+++ b/drivers/infiniband/hw/cxgb4/qp.c
@@ -720,7 +720,7 @@ int c4iw_post_send(struct ib_qp *ibqp, struct ib_send_wr *wr,
 		fw_flags = 0;
 		if (wr->send_flags & IB_SEND_SOLICITED)
 			fw_flags |= FW_RI_SOLICITED_EVENT_FLAG;
-		if (wr->send_flags & IB_SEND_SIGNALED)
+		if (wr->send_flags & IB_SEND_SIGNALED || qhp->sq_sig_all)
 			fw_flags |= FW_RI_COMPLETION_FLAG;
 		swsqe = &qhp->wq.sq.sw_sq[qhp->wq.sq.pidx];
 		switch (wr->opcode) {
@@ -781,7 +781,8 @@ int c4iw_post_send(struct ib_qp *ibqp, struct ib_send_wr *wr,
 		}
 		swsqe->idx = qhp->wq.sq.pidx;
 		swsqe->complete = 0;
-		swsqe->signaled = (wr->send_flags & IB_SEND_SIGNALED);
+		swsqe->signaled = (wr->send_flags & IB_SEND_SIGNALED) ||
+				  qhp->sq_sig_all;
 		swsqe->flushed = 0;
 		swsqe->wr_id = wr->wr_id;
 
@@ -1608,6 +1609,7 @@ struct ib_qp *c4iw_create_qp(struct ib_pd *pd, struct ib_qp_init_attr *attrs,
 	qhp->attr.enable_bind = 1;
 	qhp->attr.max_ord = 1;
 	qhp->attr.max_ird = 1;
+	qhp->sq_sig_all = attrs->sq_sig_type == IB_SIGNAL_ALL_WR;
 	spin_lock_init(&qhp->lock);
 	mutex_init(&qhp->mutex);
 	init_waitqueue_head(&qhp->wait);
-- 
1.8.4
