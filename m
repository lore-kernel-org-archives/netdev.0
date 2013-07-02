From: Simon Derr <simon.derr@bull.net>
Subject: [PATCH 06/10] 9P/RDMA: Use a semaphore to protect the RQ
Date: Tue,  2 Jul 2013 15:11:20 +0200
Message-ID: <1372770684-25573-7-git-send-email-simon.derr@bull.net>
References: <1372770684-25573-1-git-send-email-simon.derr@bull.net>
Cc: simon.derr@bull.net, ericvh@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:40953 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751889Ab3GBNlq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jul 2013 09:41:46 -0400
In-Reply-To: <1372770684-25573-1-git-send-email-simon.derr@bull.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current code keeps track of the number of buffers posted in the RQ,
and will prevent it from overflowing. But it does so by simply dropping
post requests (And leaking memory in the process).
When this happens there will actually be too few buffers posted, and
soon the 9P server will complain about 'RNR retry counter exceeded'
errors.

Instead, use a semaphore, and block until the RQ is ready for another
buffer to be posted.

Signed-off-by: Simon Derr <simon.derr@bull.net>
---
 net/9p/trans_rdma.c |   22 ++++++++++++----------
 1 files changed, 12 insertions(+), 10 deletions(-)

diff --git a/net/9p/trans_rdma.c b/net/9p/trans_rdma.c
index 274a9c1..ad8dc33 100644
--- a/net/9p/trans_rdma.c
+++ b/net/9p/trans_rdma.c
@@ -73,7 +73,7 @@
  * @sq_depth: The depth of the Send Queue
  * @sq_sem: Semaphore for the SQ
  * @rq_depth: The depth of the Receive Queue.
- * @rq_count: Count of requests in the Receive Queue.
+ * @rq_sem: Semaphore for the RQ
  * @addr: The remote peer's address
  * @req_lock: Protects the active request list
  * @cm_done: Completion event for connection management tracking
@@ -98,7 +98,7 @@ struct p9_trans_rdma {
 	int sq_depth;
 	struct semaphore sq_sem;
 	int rq_depth;
-	atomic_t rq_count;
+	struct semaphore rq_sem;
 	struct sockaddr_in addr;
 	spinlock_t req_lock;
 
@@ -341,8 +341,8 @@ static void cq_comp_handler(struct ib_cq *cq, void *cq_context)
 
 		switch (c->wc_op) {
 		case IB_WC_RECV:
-			atomic_dec(&rdma->rq_count);
 			handle_recv(client, rdma, c, wc.status, wc.byte_len);
+			up(&rdma->rq_sem);
 			break;
 
 		case IB_WC_SEND:
@@ -441,12 +441,14 @@ static int rdma_request(struct p9_client *client, struct p9_req_t *req)
 	 * outstanding request, so we must keep a count to avoid
 	 * overflowing the RQ.
 	 */
-	if (atomic_inc_return(&rdma->rq_count) <= rdma->rq_depth) {
-		err = post_recv(client, rpl_context);
-		if (err)
-			goto err_free1;
-	} else
-		atomic_dec(&rdma->rq_count);
+	if (down_interruptible(&rdma->rq_sem))
+		goto error; /* FIXME : -EINTR instead */
+
+	err = post_recv(client, rpl_context);
+	if (err) {
+		p9_debug(P9_DEBUG_FCALL, "POST RECV failed\n");
+		goto err_free1;
+	}
 
 	/* remove posted receive buffer from request structure */
 	req->rc = NULL;
@@ -537,7 +539,7 @@ static struct p9_trans_rdma *alloc_rdma(struct p9_rdma_opts *opts)
 	spin_lock_init(&rdma->req_lock);
 	init_completion(&rdma->cm_done);
 	sema_init(&rdma->sq_sem, rdma->sq_depth);
-	atomic_set(&rdma->rq_count, 0);
+	sema_init(&rdma->rq_sem, rdma->rq_depth);
 
 	return rdma;
 }
-- 
1.7.2.2
