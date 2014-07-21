From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH 4/5] iw_cxgb4: advertise the correct device max attributes
Date: Mon, 21 Jul 2014 20:55:15 +0530
Message-ID: <1405956316-13591-5-git-send-email-hariprasad@chelsio.com>
References: <1405956316-13591-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, roland@purestorage.com,
	swise@opengridcomputing.com, leedom@chelsio.com,
	nirranjan@chelsio.com, kumaras@chelsio.com, anish@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org, linux-rdma@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:32804
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755280AbaGUPTu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2014 11:19:50 -0400
In-Reply-To: <1405956316-13591-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Advertise the actual max limits for things like qp depths, number of
qps, cqs, etc.

Clean up the queue allocation for qps and cqs.

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/infiniband/hw/cxgb4/cq.c       |    8 +------
 drivers/infiniband/hw/cxgb4/device.c   |   16 +++++++-------
 drivers/infiniband/hw/cxgb4/provider.c |    4 +-
 drivers/infiniband/hw/cxgb4/qp.c       |   35 +++++++++++++++++++------------
 drivers/infiniband/hw/cxgb4/t4.h       |    2 -
 5 files changed, 32 insertions(+), 33 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb4/cq.c b/drivers/infiniband/hw/cxgb4/cq.c
index de9bcf2..0f773e7 100644
--- a/drivers/infiniband/hw/cxgb4/cq.c
+++ b/drivers/infiniband/hw/cxgb4/cq.c
@@ -913,14 +913,8 @@ struct ib_cq *c4iw_create_cq(struct ib_device *ibdev, int entries,
 	/*
 	 * memsize must be a multiple of the page size if its a user cq.
 	 */
-	if (ucontext) {
+	if (ucontext)
 		memsize = roundup(memsize, PAGE_SIZE);
-		hwentries = memsize / sizeof *chp->cq.queue;
-		while (hwentries > rhp->rdev.hw_queue.t4_max_iq_size) {
-			memsize -= PAGE_SIZE;
-			hwentries = memsize / sizeof *chp->cq.queue;
-		}
-	}
 	chp->cq.size = hwentries;
 	chp->cq.memsize = memsize;
 	chp->cq.vector = vector;
diff --git a/drivers/infiniband/hw/cxgb4/device.c b/drivers/infiniband/hw/cxgb4/device.c
index 770ee6f..67fe634 100644
--- a/drivers/infiniband/hw/cxgb4/device.c
+++ b/drivers/infiniband/hw/cxgb4/device.c
@@ -934,17 +934,17 @@ static struct c4iw_dev *c4iw_alloc(const struct cxgb4_lld_info *infop)
 
 	devp->rdev.hw_queue.t4_eq_status_entries =
 		devp->rdev.lldi.sge_ingpadboundary > 64 ? 2 : 1;
-	devp->rdev.hw_queue.t4_max_eq_size =
-		65520 - devp->rdev.hw_queue.t4_eq_status_entries;
-	devp->rdev.hw_queue.t4_max_iq_size = 65520 - 1;
-	devp->rdev.hw_queue.t4_max_rq_size =
-		8192 - devp->rdev.hw_queue.t4_eq_status_entries;
+	devp->rdev.hw_queue.t4_max_eq_size = 65520;
+	devp->rdev.hw_queue.t4_max_iq_size = 65520;
+	devp->rdev.hw_queue.t4_max_rq_size = 8192 -
+		devp->rdev.hw_queue.t4_eq_status_entries - 1;
 	devp->rdev.hw_queue.t4_max_sq_size =
-		devp->rdev.hw_queue.t4_max_eq_size - 1;
+		devp->rdev.hw_queue.t4_max_eq_size -
+		devp->rdev.hw_queue.t4_eq_status_entries - 1;
 	devp->rdev.hw_queue.t4_max_qp_depth =
-		devp->rdev.hw_queue.t4_max_rq_size - 1;
+		devp->rdev.hw_queue.t4_max_rq_size;
 	devp->rdev.hw_queue.t4_max_cq_depth =
-		devp->rdev.hw_queue.t4_max_iq_size - 1;
+		devp->rdev.hw_queue.t4_max_iq_size - 2;
 	devp->rdev.hw_queue.t4_stat_len =
 		devp->rdev.lldi.sge_egrstatuspagesize;
 
diff --git a/drivers/infiniband/hw/cxgb4/provider.c b/drivers/infiniband/hw/cxgb4/provider.c
index 67c4a69..72e3b69 100644
--- a/drivers/infiniband/hw/cxgb4/provider.c
+++ b/drivers/infiniband/hw/cxgb4/provider.c
@@ -318,7 +318,7 @@ static int c4iw_query_device(struct ib_device *ibdev,
 	props->vendor_id = (u32)dev->rdev.lldi.pdev->vendor;
 	props->vendor_part_id = (u32)dev->rdev.lldi.pdev->device;
 	props->max_mr_size = T4_MAX_MR_SIZE;
-	props->max_qp = T4_MAX_NUM_QP;
+	props->max_qp = dev->rdev.lldi.vr->qp.size / 2;
 	props->max_qp_wr = dev->rdev.hw_queue.t4_max_qp_depth;
 	props->max_sge = T4_MAX_RECV_SGE;
 	props->max_sge_rd = 1;
@@ -326,7 +326,7 @@ static int c4iw_query_device(struct ib_device *ibdev,
 	props->max_qp_rd_atom = min(dev->rdev.lldi.max_ordird_qp,
 				    c4iw_max_read_depth);
 	props->max_qp_init_rd_atom = props->max_qp_rd_atom;
-	props->max_cq = T4_MAX_NUM_CQ;
+	props->max_cq = dev->rdev.lldi.vr->qp.size;
 	props->max_cqe = dev->rdev.hw_queue.t4_max_cq_depth;
 	props->max_mr = c4iw_num_stags(&dev->rdev);
 	props->max_pd = T4_MAX_NUM_PD;
diff --git a/drivers/infiniband/hw/cxgb4/qp.c b/drivers/infiniband/hw/cxgb4/qp.c
index 0e7e0e3..c158fcc 100644
--- a/drivers/infiniband/hw/cxgb4/qp.c
+++ b/drivers/infiniband/hw/cxgb4/qp.c
@@ -205,9 +205,9 @@ static int create_qp(struct c4iw_rdev *rdev, struct t4_wq *wq,
 	}
 
 	/*
-	 * RQT must be a power of 2.
+	 * RQT must be a power of 2 and at least 16 deep.
 	 */
-	wq->rq.rqt_size = roundup_pow_of_two(wq->rq.size);
+	wq->rq.rqt_size = roundup_pow_of_two(max_t(u16, wq->rq.size, 16));
 	wq->rq.rqt_hwaddr = c4iw_rqtpool_alloc(rdev, wq->rq.rqt_size);
 	if (!wq->rq.rqt_hwaddr) {
 		ret = -ENOMEM;
@@ -1621,13 +1621,17 @@ struct ib_qp *c4iw_create_qp(struct ib_pd *pd, struct ib_qp_init_attr *attrs,
 	if (attrs->cap.max_inline_data > T4_MAX_SEND_INLINE)
 		return ERR_PTR(-EINVAL);
 
-	rqsize = roundup(attrs->cap.max_recv_wr + 1, 16);
-	if (rqsize > rhp->rdev.hw_queue.t4_max_rq_size)
+	if (attrs->cap.max_recv_wr > rhp->rdev.hw_queue.t4_max_rq_size)
 		return ERR_PTR(-E2BIG);
+	rqsize = attrs->cap.max_recv_wr + 1;
+	if (rqsize < 8)
+		rqsize = 8;
 
-	sqsize = roundup(attrs->cap.max_send_wr + 1, 16);
-	if (sqsize > rhp->rdev.hw_queue.t4_max_sq_size)
+	if (attrs->cap.max_send_wr > rhp->rdev.hw_queue.t4_max_sq_size)
 		return ERR_PTR(-E2BIG);
+	sqsize = attrs->cap.max_send_wr + 1;
+	if (sqsize < 8)
+		sqsize = 8;
 
 	ucontext = pd->uobject ? to_c4iw_ucontext(pd->uobject->context) : NULL;
 
@@ -1635,19 +1639,20 @@ struct ib_qp *c4iw_create_qp(struct ib_pd *pd, struct ib_qp_init_attr *attrs,
 	if (!qhp)
 		return ERR_PTR(-ENOMEM);
 	qhp->wq.sq.size = sqsize;
-	qhp->wq.sq.memsize = (sqsize + 1) * sizeof *qhp->wq.sq.queue;
+	qhp->wq.sq.memsize =
+		(sqsize + rhp->rdev.hw_queue.t4_eq_status_entries) *
+		sizeof(*qhp->wq.sq.queue) + 16 * sizeof(__be64);
 	qhp->wq.sq.flush_cidx = -1;
 	qhp->wq.rq.size = rqsize;
-	qhp->wq.rq.memsize = (rqsize + 1) * sizeof *qhp->wq.rq.queue;
+	qhp->wq.rq.memsize =
+		(rqsize + rhp->rdev.hw_queue.t4_eq_status_entries) *
+		sizeof(*qhp->wq.rq.queue);
 
 	if (ucontext) {
 		qhp->wq.sq.memsize = roundup(qhp->wq.sq.memsize, PAGE_SIZE);
 		qhp->wq.rq.memsize = roundup(qhp->wq.rq.memsize, PAGE_SIZE);
 	}
 
-	PDBG("%s sqsize %u sqmemsize %zu rqsize %u rqmemsize %zu\n",
-	     __func__, sqsize, qhp->wq.sq.memsize, rqsize, qhp->wq.rq.memsize);
-
 	ret = create_qp(&rhp->rdev, &qhp->wq, &schp->cq, &rchp->cq,
 			ucontext ? &ucontext->uctx : &rhp->rdev.uctx);
 	if (ret)
@@ -1766,9 +1771,11 @@ struct ib_qp *c4iw_create_qp(struct ib_pd *pd, struct ib_qp_init_attr *attrs,
 	qhp->ibqp.qp_num = qhp->wq.sq.qid;
 	init_timer(&(qhp->timer));
 	INIT_LIST_HEAD(&qhp->db_fc_entry);
-	PDBG("%s qhp %p sq_num_entries %d, rq_num_entries %d qpid 0x%0x\n",
-	     __func__, qhp, qhp->attr.sq_num_entries, qhp->attr.rq_num_entries,
-	     qhp->wq.sq.qid);
+	PDBG("%s sq id %u size %u memsize %zu num_entries %u "
+	     "rq id %u size %u memsize %zu num_entries %u\n", __func__,
+	     qhp->wq.sq.qid, qhp->wq.sq.size, qhp->wq.sq.memsize,
+	     attrs->cap.max_send_wr, qhp->wq.rq.qid, qhp->wq.rq.size,
+	     qhp->wq.rq.memsize, attrs->cap.max_recv_wr);
 	return &qhp->ibqp;
 err8:
 	kfree(mm5);
diff --git a/drivers/infiniband/hw/cxgb4/t4.h b/drivers/infiniband/hw/cxgb4/t4.h
index c9f7034..641ab55 100644
--- a/drivers/infiniband/hw/cxgb4/t4.h
+++ b/drivers/infiniband/hw/cxgb4/t4.h
@@ -36,8 +36,6 @@
 #include "t4_msg.h"
 #include "t4fw_ri_api.h"
 
-#define T4_MAX_NUM_QP 65536
-#define T4_MAX_NUM_CQ 65536
 #define T4_MAX_NUM_PD 65536
 #define T4_MAX_NUM_STAG (1<<15)
 #define T4_MAX_MR_SIZE (~0ULL)
-- 
1.7.1
