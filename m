From: Simon Derr <simon.derr@bull.net>
Subject: [PATCH 09/10] 9P/RDMA: count posted buffers without a pending request
Date: Tue,  2 Jul 2013 15:11:23 +0200
Message-ID: <1372770684-25573-10-git-send-email-simon.derr@bull.net>
References: <1372770684-25573-1-git-send-email-simon.derr@bull.net>
Cc: simon.derr@bull.net, ericvh@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:40985 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752373Ab3GBNlz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jul 2013 09:41:55 -0400
In-Reply-To: <1372770684-25573-1-git-send-email-simon.derr@bull.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In rdma_request():

If an error occurs between posting the recv and the send,
there will be a reply context posted without a pending
request.
Since there is no way to "un-post" it, we remember it and
skip post_recv() for the next request.

Signed-off-by: Simon Derr <simon.derr@bull.net>
---
 net/9p/trans_rdma.c |   31 ++++++++++++++++++++++++++++++-
 1 files changed, 30 insertions(+), 1 deletions(-)

diff --git a/net/9p/trans_rdma.c b/net/9p/trans_rdma.c
index 926e72d..8f68df5 100644
--- a/net/9p/trans_rdma.c
+++ b/net/9p/trans_rdma.c
@@ -74,6 +74,8 @@
  * @sq_sem: Semaphore for the SQ
  * @rq_depth: The depth of the Receive Queue.
  * @rq_sem: Semaphore for the RQ
+ * @excess_rc : Amount of posted Receive Contexts without a pending request.
+ *		See rdma_request()
  * @addr: The remote peer's address
  * @req_lock: Protects the active request list
  * @cm_done: Completion event for connection management tracking
@@ -99,6 +101,7 @@ struct p9_trans_rdma {
 	struct semaphore sq_sem;
 	int rq_depth;
 	struct semaphore rq_sem;
+	atomic_t excess_rc;
 	struct sockaddr_in addr;
 	spinlock_t req_lock;
 
@@ -426,6 +429,26 @@ static int rdma_request(struct p9_client *client, struct p9_req_t *req)
 	struct p9_rdma_context *c = NULL;
 	struct p9_rdma_context *rpl_context = NULL;
 
+	/* When an error occurs between posting the recv and the send,
+	 * there will be a receive context posted without a pending request.
+	 * Since there is no way to "un-post" it, we remember it and skip
+	 * post_recv() for the next request.
+	 * So here,
+	 * see if we are this `next request' and need to absorb an excess rc.
+	 * If yes, then drop and free our own, and do not recv_post().
+	 **/
+	if (unlikely(atomic_read(&rdma->excess_rc) > 0)) {
+		if ((atomic_sub_return(1, &rdma->excess_rc) >= 0)) {
+			/* Got one ! */
+			kfree(req->rc);
+			req->rc = NULL;
+			goto dont_need_post_recv;
+		} else {
+			/* We raced and lost. */
+			atomic_inc(&rdma->excess_rc);
+		}
+	}
+
 	/* Allocate an fcall for the reply */
 	rpl_context = kmalloc(sizeof *rpl_context, GFP_NOFS);
 	if (!rpl_context) {
@@ -451,10 +474,10 @@ static int rdma_request(struct p9_client *client, struct p9_req_t *req)
 		p9_debug(P9_DEBUG_FCALL, "POST RECV failed\n");
 		goto recv_error;
 	}
-
 	/* remove posted receive buffer from request structure */
 	req->rc = NULL;
 
+dont_need_post_recv:
 	/* Post the request */
 	c = kmalloc(sizeof *c, GFP_NOFS);
 	if (!c) {
@@ -499,6 +522,11 @@ static int rdma_request(struct p9_client *client, struct p9_req_t *req)
  send_error:
 	kfree(c);
 	p9_debug(P9_DEBUG_ERROR, "Error %d in rdma_request()\n", err);
+
+	/* Ach.
+	 *  We did recv_post(), but not send. We have one recv_post in excess.
+	 */
+	atomic_inc(&rdma->excess_rc);
 	return err;
 
  /* Handle errors that happened during or while preparing post_recv(): */
@@ -549,6 +577,7 @@ static struct p9_trans_rdma *alloc_rdma(struct p9_rdma_opts *opts)
 	init_completion(&rdma->cm_done);
 	sema_init(&rdma->sq_sem, rdma->sq_depth);
 	sema_init(&rdma->rq_sem, rdma->rq_depth);
+	atomic_set(&rdma->excess_rc, 0);
 
 	return rdma;
 }
-- 
1.7.2.2
