From: Simon Derr <simon.derr@bull.net>
Subject: [PATCH 07/10] 9P/RDMA: Do not free req->rc in error handling in rdma_request()
Date: Tue,  2 Jul 2013 15:11:21 +0200
Message-ID: <1372770684-25573-8-git-send-email-simon.derr@bull.net>
References: <1372770684-25573-1-git-send-email-simon.derr@bull.net>
Cc: simon.derr@bull.net, ericvh@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:40944 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751853Ab3GBNlp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jul 2013 09:41:45 -0400
In-Reply-To: <1372770684-25573-1-git-send-email-simon.derr@bull.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rdma_request() should never be in charge of freeing rc.

When an error occurs:
* Either the rc buffer has been recv_post()'ed.
  then kfree()'ing it certainly is a bad idea.
* Or is has not, and in that case req->rc still points to it,
  hence it needs not be freed.

Signed-off-by: Simon Derr <simon.derr@bull.net>
---
 net/9p/trans_rdma.c |    9 +++------
 1 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/net/9p/trans_rdma.c b/net/9p/trans_rdma.c
index ad8dc33..1bd4c71 100644
--- a/net/9p/trans_rdma.c
+++ b/net/9p/trans_rdma.c
@@ -447,7 +447,7 @@ static int rdma_request(struct p9_client *client, struct p9_req_t *req)
 	err = post_recv(client, rpl_context);
 	if (err) {
 		p9_debug(P9_DEBUG_FCALL, "POST RECV failed\n");
-		goto err_free1;
+		goto err_free;
 	}
 
 	/* remove posted receive buffer from request structure */
@@ -457,7 +457,7 @@ static int rdma_request(struct p9_client *client, struct p9_req_t *req)
 	c = kmalloc(sizeof *c, GFP_NOFS);
 	if (!c) {
 		err = -ENOMEM;
-		goto err_free1;
+		goto err_free;
 	}
 	c->req = req;
 
@@ -486,13 +486,10 @@ static int rdma_request(struct p9_client *client, struct p9_req_t *req)
 
  error:
 	kfree(c);
-	kfree(rpl_context->rc);
 	kfree(rpl_context);
 	p9_debug(P9_DEBUG_ERROR, "EIO\n");
 	return -EIO;
- err_free1:
-	kfree(rpl_context->rc);
- err_free2:
+ err_free:
 	kfree(rpl_context);
  err_close:
 	spin_lock_irqsave(&rdma->req_lock, flags);
-- 
1.7.2.2
