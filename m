From: Andi Shyti <andi@etezian.org>
Subject: [PATCH] 9p: client: remove unused code and any reference to "cancelled" function
Date: Thu, 25 Jul 2013 10:54:24 +0200
Message-ID: <1374742464-10686-1-git-send-email-andi@etezian.org>
References: <20130725061411.GA8579@nautica>
Cc: dominique.martinet@cea.fr, pebolle@tiscali.nl, lucho@ionkov.net,
	ericvh@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, v9fs-developer@lists.sourceforge.net,
	rminnich@sandia.gov, andi@etezian.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from etezian.org ([198.101.225.253]:41817 "EHLO mail.etezian.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751750Ab3GYIxG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Jul 2013 04:53:06 -0400
In-Reply-To: <20130725061411.GA8579@nautica>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch reverts commit

80b45261a0b263536b043c5ccfc4ba4fc27c2acc

which was implementing a 'cancelled' functionality to notify that
a cancelled request will not be replied.

This implementation was not used anywhere and therefore removed.

Signed-off-by: Andi Shyti <andi@etezian.org>
---
 include/net/9p/transport.h | 3 ---
 net/9p/client.c            | 9 ++-------
 2 files changed, 2 insertions(+), 10 deletions(-)

diff --git a/include/net/9p/transport.h b/include/net/9p/transport.h
index d9fa68f..9a36d92 100644
--- a/include/net/9p/transport.h
+++ b/include/net/9p/transport.h
@@ -40,8 +40,6 @@
  * @close: member function to discard a connection on this transport
  * @request: member function to issue a request to the transport
  * @cancel: member function to cancel a request (if it hasn't been sent)
- * @cancelled: member function to notify that a cancelled request will not
- *             not receive a reply
  *
  * This is the basic API for a transport module which is registered by the
  * transport module with the 9P core network module and used by the client
@@ -60,7 +58,6 @@ struct p9_trans_module {
 	void (*close) (struct p9_client *);
 	int (*request) (struct p9_client *, struct p9_req_t *req);
 	int (*cancel) (struct p9_client *, struct p9_req_t *req);
-	int (*cancelled)(struct p9_client *, struct p9_req_t *req);
 	int (*zc_request)(struct p9_client *, struct p9_req_t *,
 			  char *, char *, int , int, int, int);
 };
diff --git a/net/9p/client.c b/net/9p/client.c
index 8b93cae..ba93bda 100644
--- a/net/9p/client.c
+++ b/net/9p/client.c
@@ -658,17 +658,12 @@ static int p9_client_flush(struct p9_client *c, struct p9_req_t *oldreq)
 
 	/*
 	 * if we haven't received a response for oldreq,
-	 * remove it from the list, and notify the transport
-	 * layer that the reply will never arrive.
+	 * remove it from the list
 	 */
-	spin_lock(&c->lock);
 	if (oldreq->status == REQ_STATUS_FLSH) {
+		spin_lock(&c->lock);
 		list_del(&oldreq->req_list);
 		spin_unlock(&c->lock);
-		if (c->trans_mod->cancelled)
-			c->trans_mod->cancelled(c, req);
-	} else {
-		spin_unlock(&c->lock);
 	}
 
 	p9_free_req(c, req);
-- 
1.8.3.2
