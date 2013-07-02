From: Simon Derr <simon.derr@bull.net>
Subject: [PATCH 01/10] 9P: Fix fcall allocation for rdma
Date: Tue,  2 Jul 2013 15:11:15 +0200
Message-ID: <1372770684-25573-2-git-send-email-simon.derr@bull.net>
References: <1372770684-25573-1-git-send-email-simon.derr@bull.net>
Cc: simon.derr@bull.net, ericvh@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:40988 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752534Ab3GBNl4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jul 2013 09:41:56 -0400
In-Reply-To: <1372770684-25573-1-git-send-email-simon.derr@bull.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current code assumes that when a request in the request array
does have a tc, it also has a rc.

This is normally true, but not always : when using RDMA, req->rc
will temporarily be set to NULL after the request has been sent.
That is usually OK though, as when the reply arrives, req->rc will be
reassigned to a sane value before the request is recycled.

But there is a catch : if the request is flushed, the reply will never
arrive, and req->rc will be NULL, but not req->tc.

This patch fixes p9_tag_alloc to take this into account.

Signed-off-by: Simon Derr <simon.derr@bull.net>
---
 net/9p/client.c |   39 +++++++++++++++++++++++----------------
 1 files changed, 23 insertions(+), 16 deletions(-)

diff --git a/net/9p/client.c b/net/9p/client.c
index 8eb7542..47cd7d0 100644
--- a/net/9p/client.c
+++ b/net/9p/client.c
@@ -258,27 +258,25 @@ p9_tag_alloc(struct p9_client *c, u16 tag, unsigned int max_size)
 	req = &c->reqs[row][col];
 	if (!req->tc) {
 		req->wq = kmalloc(sizeof(wait_queue_head_t), GFP_NOFS);
-		if (!req->wq) {
-			pr_err("Couldn't grow tag array\n");
-			return ERR_PTR(-ENOMEM);
-		}
+		if (!req->wq) 
+			goto grow_failed;
+
 		init_waitqueue_head(req->wq);
 		req->tc = kmalloc(sizeof(struct p9_fcall) + alloc_msize,
 				  GFP_NOFS);
+		if (!req->tc)
+			goto grow_failed;
+
+		req->tc->capacity = alloc_msize;
+		req->tc->sdata = (char *) req->tc + sizeof(struct p9_fcall);
+	}
+	if (!req->rc) {
 		req->rc = kmalloc(sizeof(struct p9_fcall) + alloc_msize,
 				  GFP_NOFS);
-		if ((!req->tc) || (!req->rc)) {
-			pr_err("Couldn't grow tag array\n");
-			kfree(req->tc);
-			kfree(req->rc);
-			kfree(req->wq);
-			req->tc = req->rc = NULL;
-			req->wq = NULL;
-			return ERR_PTR(-ENOMEM);
-		}
-		req->tc->capacity = alloc_msize;
+		if (!req->rc)
+			goto grow_failed;
+
 		req->rc->capacity = alloc_msize;
-		req->tc->sdata = (char *) req->tc + sizeof(struct p9_fcall);
 		req->rc->sdata = (char *) req->rc + sizeof(struct p9_fcall);
 	}
 
@@ -288,7 +286,16 @@ p9_tag_alloc(struct p9_client *c, u16 tag, unsigned int max_size)
 	req->tc->tag = tag-1;
 	req->status = REQ_STATUS_ALLOC;
 
-	return &c->reqs[row][col];
+	return req;
+
+grow_failed:
+	pr_err("Couldn't grow tag array\n");
+	kfree(req->tc);
+	kfree(req->rc);
+	kfree(req->wq);
+	req->tc = req->rc = NULL;
+	req->wq = NULL;
+	return ERR_PTR(-ENOMEM);
 }
 
 /**
-- 
1.7.2.2
