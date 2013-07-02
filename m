From: Simon Derr <simon.derr@bull.net>
Subject: [PATCH 10/10] 9P: Add cancelled() to the transport functions.
Date: Tue,  2 Jul 2013 15:11:24 +0200
Message-ID: <1372770684-25573-11-git-send-email-simon.derr@bull.net>
References: <1372770684-25573-1-git-send-email-simon.derr@bull.net>
Cc: simon.derr@bull.net, ericvh@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:40987 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752522Ab3GBNlz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jul 2013 09:41:55 -0400
In-Reply-To: <1372770684-25573-1-git-send-email-simon.derr@bull.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RDMA needs to post a buffer for each incoming reply.
Hence it needs to keep count of these and needs to be
aware of whether a flushed request has received a reply
or not.

This patch adds the cancelled() callback to the transport modules.
It is called when RFLUSH has been received and that the corresponding
request will never receive a reply.

Signed-off-by: Simon Derr <simon.derr@bull.net>
---
 include/net/9p/transport.h |    3 +++
 net/9p/client.c            |   11 ++++++++---
 net/9p/trans_rdma.c        |   10 ++++++++++
 3 files changed, 21 insertions(+), 3 deletions(-)

diff --git a/include/net/9p/transport.h b/include/net/9p/transport.h
index adcbb20..77a0578 100644
--- a/include/net/9p/transport.h
+++ b/include/net/9p/transport.h
@@ -37,6 +37,8 @@
  * @close: member function to discard a connection on this transport
  * @request: member function to issue a request to the transport
  * @cancel: member function to cancel a request (if it hasn't been sent)
+ * @cancelled: member function to notify that a cancelled request will not
+ *             not receive a reply	
  *
  * This is the basic API for a transport module which is registered by the
  * transport module with the 9P core network module and used by the client
@@ -55,6 +57,7 @@ struct p9_trans_module {
 	void (*close) (struct p9_client *);
 	int (*request) (struct p9_client *, struct p9_req_t *req);
 	int (*cancel) (struct p9_client *, struct p9_req_t *req);
+	int (*cancelled) (struct p9_client *, struct p9_req_t *req);
 	int (*zc_request)(struct p9_client *, struct p9_req_t *,
 			  char *, char *, int , int, int, int);
 };
diff --git a/net/9p/client.c b/net/9p/client.c
index 44691b9..61e0455 100644
--- a/net/9p/client.c
+++ b/net/9p/client.c
@@ -676,11 +676,16 @@ static int p9_client_flush(struct p9_client *c, struct p9_req_t *oldreq)
 
 
 	/* if we haven't received a response for oldreq,
-	   remove it from the list. */
+	   remove it from the list, and notify the transport
+	   layer that the reply will never arrive. */
 	spin_lock(&c->lock);
-	if (oldreq->status == REQ_STATUS_FLSH)
+	if (oldreq->status == REQ_STATUS_FLSH) {
 		list_del(&oldreq->req_list);
-	spin_unlock(&c->lock);
+		spin_unlock(&c->lock);
+		if (c->trans_mod->cancelled)
+			c->trans_mod->cancelled(c, req);
+	} else
+		spin_unlock(&c->lock);
 
 	p9_free_req(c, req);
 	return 0;
diff --git a/net/9p/trans_rdma.c b/net/9p/trans_rdma.c
index 8f68df5..9e6c220 100644
--- a/net/9p/trans_rdma.c
+++ b/net/9p/trans_rdma.c
@@ -588,6 +588,16 @@ static int rdma_cancel(struct p9_client *client, struct p9_req_t *req)
 	return 1;
 }
 
+/* A request has been fully flushed without a reply.
+ * That means we have posted one buffer in excess.
+ */
+static int rdma_cancelled(struct p9_client *client, struct p9_req_t *req)
+{
+	struct p9_trans_rdma *rdma = client->trans;
+	atomic_inc(&rdma->excess_rc);
+	return 0;
+}
+
 /**
  * trans_create_rdma - Transport method for creating atransport instance
  * @client: client instance
-- 
1.7.2.2
