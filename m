From: Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>
Subject: Re: [V9fs-developer] [PATCH] net/9p: convert to new CQ API
Date: Thu, 3 Mar 2016 09:36:06 +0100
Message-ID: <20160303083606.GA13828@lst.de>
References: <1456565151-27115-1-git-send-email-hch@lst.de> <1456565151-27115-2-git-send-email-hch@lst.de> <20160227154957.GA21186@nautica>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: v9fs-developer-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Dominique Martinet <asmadeus-9aU+PIKW3UvdtAWm4Da02A@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20160227154957.GA21186@nautica>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

New version with the nits fixed below.  Now that checkpath started
a stupid warning about not using tabs for indentation which I've
ignored here and will take up in my usual fights against Joes
idicotic opinions separately..

--
>From 0055e31f24c7b3642ece5ebb998fa63d772dcb1a Mon Sep 17 00:00:00 2001
From: Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>
Date: Sat, 27 Feb 2016 10:22:40 +0100
Subject: net/9p: convert to new CQ API

Trivial conversion to the new RDMA CQ API.

Signed-off-by: Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>
---
 net/9p/trans_rdma.c | 86 +++++++++++++++++++----------------------------------
 1 file changed, 31 insertions(+), 55 deletions(-)

diff --git a/net/9p/trans_rdma.c b/net/9p/trans_rdma.c
index 52b4a2f..1852e38 100644
--- a/net/9p/trans_rdma.c
+++ b/net/9p/trans_rdma.c
@@ -109,14 +109,13 @@ struct p9_trans_rdma {
 /**
  * p9_rdma_context - Keeps track of in-process WR
  *
- * @wc_op: The original WR op for when the CQE completes in error.
  * @busa: Bus address to unmap when the WR completes
  * @req: Keeps track of requests (send)
  * @rc: Keepts track of replies (receive)
  */
 struct p9_rdma_req;
 struct p9_rdma_context {
-	enum ib_wc_opcode wc_op;
+	struct ib_cqe cqe;
 	dma_addr_t busa;
 	union {
 		struct p9_req_t *req;
@@ -284,9 +283,12 @@ p9_cm_event_handler(struct rdma_cm_id *id, struct rdma_cm_event *event)
 }
 
 static void
-handle_recv(struct p9_client *client, struct p9_trans_rdma *rdma,
-	    struct p9_rdma_context *c, enum ib_wc_status status, u32 byte_len)
+recv_done(struct ib_cq *cq, struct ib_wc *wc)
 {
+	struct p9_client *client = cq->cq_context;
+	struct p9_trans_rdma *rdma = client->trans;
+	struct p9_rdma_context *c =
+		container_of(wc->wr_cqe, struct p9_rdma_context, cqe);
 	struct p9_req_t *req;
 	int err = 0;
 	int16_t tag;
@@ -295,7 +297,7 @@ handle_recv(struct p9_client *client, struct p9_trans_rdma *rdma,
 	ib_dma_unmap_single(rdma->cm_id->device, c->busa, client->msize,
 							 DMA_FROM_DEVICE);
 
-	if (status != IB_WC_SUCCESS)
+	if (wc->status != IB_WC_SUCCESS)
 		goto err_out;
 
 	err = p9_parse_header(c->rc, NULL, NULL, &tag, 1);
@@ -316,21 +318,32 @@ handle_recv(struct p9_client *client, struct p9_trans_rdma *rdma,
 	req->rc = c->rc;
 	p9_client_cb(client, req, REQ_STATUS_RCVD);
 
+ out:
+	up(&rdma->rq_sem);
+	kfree(c);
 	return;
 
  err_out:
-	p9_debug(P9_DEBUG_ERROR, "req %p err %d status %d\n", req, err, status);
+	p9_debug(P9_DEBUG_ERROR, "req %p err %d status %d\n",
+			req, err, wc->status);
 	rdma->state = P9_RDMA_FLUSHING;
 	client->status = Disconnected;
+	goto out;
 }
 
 static void
-handle_send(struct p9_client *client, struct p9_trans_rdma *rdma,
-	    struct p9_rdma_context *c, enum ib_wc_status status, u32 byte_len)
+send_done(struct ib_cq *cq, struct ib_wc *wc)
 {
+	struct p9_client *client = cq->cq_context;
+	struct p9_trans_rdma *rdma = client->trans;
+	struct p9_rdma_context *c =
+		container_of(wc->wr_cqe, struct p9_rdma_context, cqe);
+
 	ib_dma_unmap_single(rdma->cm_id->device,
 			    c->busa, c->req->tc->size,
 			    DMA_TO_DEVICE);
+	up(&rdma->sq_sem);
+	kfree(c);
 }
 
 static void qp_event_handler(struct ib_event *event, void *context)
@@ -339,42 +352,6 @@ static void qp_event_handler(struct ib_event *event, void *context)
 		 event->event, context);
 }
 
-static void cq_comp_handler(struct ib_cq *cq, void *cq_context)
-{
-	struct p9_client *client = cq_context;
-	struct p9_trans_rdma *rdma = client->trans;
-	int ret;
-	struct ib_wc wc;
-
-	ib_req_notify_cq(rdma->cq, IB_CQ_NEXT_COMP);
-	while ((ret = ib_poll_cq(cq, 1, &wc)) > 0) {
-		struct p9_rdma_context *c = (void *) (unsigned long) wc.wr_id;
-
-		switch (c->wc_op) {
-		case IB_WC_RECV:
-			handle_recv(client, rdma, c, wc.status, wc.byte_len);
-			up(&rdma->rq_sem);
-			break;
-
-		case IB_WC_SEND:
-			handle_send(client, rdma, c, wc.status, wc.byte_len);
-			up(&rdma->sq_sem);
-			break;
-
-		default:
-			pr_err("unexpected completion type, c->wc_op=%d, wc.opcode=%d, status=%d\n",
-			       c->wc_op, wc.opcode, wc.status);
-			break;
-		}
-		kfree(c);
-	}
-}
-
-static void cq_event_handler(struct ib_event *e, void *v)
-{
-	p9_debug(P9_DEBUG_ERROR, "CQ event %d context %p\n", e->event, v);
-}
-
 static void rdma_destroy_trans(struct p9_trans_rdma *rdma)
 {
 	if (!rdma)
@@ -387,7 +364,7 @@ static void rdma_destroy_trans(struct p9_trans_rdma *rdma)
 		ib_dealloc_pd(rdma->pd);
 
 	if (rdma->cq && !IS_ERR(rdma->cq))
-		ib_destroy_cq(rdma->cq);
+		ib_free_cq(rdma->cq);
 
 	if (rdma->cm_id && !IS_ERR(rdma->cm_id))
 		rdma_destroy_id(rdma->cm_id);
@@ -408,13 +385,14 @@ post_recv(struct p9_client *client, struct p9_rdma_context *c)
 	if (ib_dma_mapping_error(rdma->cm_id->device, c->busa))
 		goto error;
 
+	c->cqe.done = recv_done;
+
 	sge.addr = c->busa;
 	sge.length = client->msize;
 	sge.lkey = rdma->pd->local_dma_lkey;
 
 	wr.next = NULL;
-	c->wc_op = IB_WC_RECV;
-	wr.wr_id = (unsigned long) c;
+	wr.wr_cqe = &c->cqe;
 	wr.sg_list = &sge;
 	wr.num_sge = 1;
 	return ib_post_recv(rdma->qp, &wr, &bad_wr);
@@ -499,13 +477,14 @@ dont_need_post_recv:
 		goto send_error;
 	}
 
+	c->cqe.done = send_done;
+
 	sge.addr = c->busa;
 	sge.length = c->req->tc->size;
 	sge.lkey = rdma->pd->local_dma_lkey;
 
 	wr.next = NULL;
-	c->wc_op = IB_WC_SEND;
-	wr.wr_id = (unsigned long) c;
+	wr.wr_cqe = &c->cqe;
 	wr.opcode = IB_WR_SEND;
 	wr.send_flags = IB_SEND_SIGNALED;
 	wr.sg_list = &sge;
@@ -642,7 +621,6 @@ rdma_create_trans(struct p9_client *client, const char *addr, char *args)
 	struct p9_trans_rdma *rdma;
 	struct rdma_conn_param conn_param;
 	struct ib_qp_init_attr qp_attr;
-	struct ib_cq_init_attr cq_attr = {};
 
 	/* Parse the transport specific mount options */
 	err = parse_opts(args, &opts);
@@ -695,13 +673,11 @@ rdma_create_trans(struct p9_client *client, const char *addr, char *args)
 		goto error;
 
 	/* Create the Completion Queue */
-	cq_attr.cqe = opts.sq_depth + opts.rq_depth + 1;
-	rdma->cq = ib_create_cq(rdma->cm_id->device, cq_comp_handler,
-				cq_event_handler, client,
-				&cq_attr);
+	rdma->cq = ib_alloc_cq(rdma->cm_id->device, client,
+			opts.sq_depth + opts.rq_depth + 1,
+			0, IB_POLL_SOFTIRQ);
 	if (IS_ERR(rdma->cq))
 		goto error;
-	ib_req_notify_cq(rdma->cq, IB_CQ_NEXT_COMP);
 
 	/* Create the Protection Domain */
 	rdma->pd = ib_alloc_pd(rdma->cm_id->device);
-- 
2.1.4

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
