From: Simon Derr <simon.derr@bull.net>
Subject: [PATCH 08/10] 9P/RDMA: Improve error handling in rdma_request
Date: Tue,  2 Jul 2013 15:11:22 +0200
Message-ID: <1372770684-25573-9-git-send-email-simon.derr@bull.net>
References: <1372770684-25573-1-git-send-email-simon.derr@bull.net>
Cc: simon.derr@bull.net, ericvh@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:40957 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751853Ab3GBNlq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jul 2013 09:41:46 -0400
In-Reply-To: <1372770684-25573-1-git-send-email-simon.derr@bull.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Most importantly:
- do not free the recv context (rpl_context) after a successful post_recv()
- but do free the send context (c) after a failed send.

Signed-off-by: Simon Derr <simon.derr@bull.net>
---
 net/9p/trans_rdma.c |   44 ++++++++++++++++++++++++++++----------------
 1 files changed, 28 insertions(+), 16 deletions(-)

diff --git a/net/9p/trans_rdma.c b/net/9p/trans_rdma.c
index 1bd4c71..926e72d 100644
--- a/net/9p/trans_rdma.c
+++ b/net/9p/trans_rdma.c
@@ -430,7 +430,7 @@ static int rdma_request(struct p9_client *client, struct p9_req_t *req)
 	rpl_context = kmalloc(sizeof *rpl_context, GFP_NOFS);
 	if (!rpl_context) {
 		err = -ENOMEM;
-		goto err_close;
+		goto recv_error;
 	}
 	rpl_context->rc = req->rc;
 
@@ -441,13 +441,15 @@ static int rdma_request(struct p9_client *client, struct p9_req_t *req)
 	 * outstanding request, so we must keep a count to avoid
 	 * overflowing the RQ.
 	 */
-	if (down_interruptible(&rdma->rq_sem))
-		goto error; /* FIXME : -EINTR instead */
+	if (down_interruptible(&rdma->rq_sem)) {
+		err = -EINTR;
+		goto recv_error;
+	}
 
 	err = post_recv(client, rpl_context);
 	if (err) {
 		p9_debug(P9_DEBUG_FCALL, "POST RECV failed\n");
-		goto err_free;
+		goto recv_error;
 	}
 
 	/* remove posted receive buffer from request structure */
@@ -457,15 +459,17 @@ static int rdma_request(struct p9_client *client, struct p9_req_t *req)
 	c = kmalloc(sizeof *c, GFP_NOFS);
 	if (!c) {
 		err = -ENOMEM;
-		goto err_free;
+		goto send_error;
 	}
 	c->req = req;
 
 	c->busa = ib_dma_map_single(rdma->cm_id->device,
 				    c->req->tc->sdata, c->req->tc->size,
 				    DMA_TO_DEVICE);
-	if (ib_dma_mapping_error(rdma->cm_id->device, c->busa))
-		goto error;
+	if (ib_dma_mapping_error(rdma->cm_id->device, c->busa)) {
+		err = -EIO;
+		goto send_error;
+	}
 
 	sge.addr = c->busa;
 	sge.length = c->req->tc->size;
@@ -479,19 +483,27 @@ static int rdma_request(struct p9_client *client, struct p9_req_t *req)
 	wr.sg_list = &sge;
 	wr.num_sge = 1;
 
-	if (down_interruptible(&rdma->sq_sem))
-		goto error;
+	if (down_interruptible(&rdma->sq_sem)) {
+		err = -EINTR;
+		goto send_error;
+	}
 
-	return ib_post_send(rdma->qp, &wr, &bad_wr);
+	err = ib_post_send(rdma->qp, &wr, &bad_wr);
+	if (err)
+		goto send_error;
 
- error:
+	/* Success */
+	return 0;
+
+ /* Handle errors that happened during or while preparing the send: */
+ send_error:
 	kfree(c);
+	p9_debug(P9_DEBUG_ERROR, "Error %d in rdma_request()\n", err);
+	return err;
+
+ /* Handle errors that happened during or while preparing post_recv(): */
+ recv_error:
 	kfree(rpl_context);
-	p9_debug(P9_DEBUG_ERROR, "EIO\n");
-	return -EIO;
- err_free:
-	kfree(rpl_context);
- err_close:
 	spin_lock_irqsave(&rdma->req_lock, flags);
 	if (rdma->state < P9_RDMA_CLOSING) {
 		rdma->state = P9_RDMA_CLOSING;
-- 
1.7.2.2
