From: Simon Derr <simon.derr@bull.net>
Subject: [PATCH 03/10] 9pnet: refactor struct p9_fcall alloc code
Date: Tue,  2 Jul 2013 15:11:17 +0200
Message-ID: <1372770684-25573-4-git-send-email-simon.derr@bull.net>
References: <1372770684-25573-1-git-send-email-simon.derr@bull.net>
Cc: simon.derr@bull.net, ericvh@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:40991 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752548Ab3GBNl5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jul 2013 09:41:57 -0400
In-Reply-To: <1372770684-25573-1-git-send-email-simon.derr@bull.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Simon Derr <simon.derr@bull.net>
---
 net/9p/client.c |   35 ++++++++++++++++++-----------------
 1 files changed, 18 insertions(+), 17 deletions(-)

diff --git a/net/9p/client.c b/net/9p/client.c
index 47cd7d0..44691b9 100644
--- a/net/9p/client.c
+++ b/net/9p/client.c
@@ -204,6 +204,17 @@ free_and_return:
 	return ret;
 }
 
+struct p9_fcall *p9_fcall_alloc(int alloc_msize)
+{
+	struct p9_fcall *fc;
+	fc = kmalloc(sizeof(struct p9_fcall) + alloc_msize, GFP_NOFS);
+	if (!fc)
+		return NULL;
+	fc->capacity = alloc_msize;
+	fc->sdata = (char *) fc + sizeof(struct p9_fcall);
+	return fc;
+}
+
 /**
  * p9_tag_alloc - lookup/allocate a request by tag
  * @c: client session to lookup tag within
@@ -256,29 +267,19 @@ p9_tag_alloc(struct p9_client *c, u16 tag, unsigned int max_size)
 	col = tag % P9_ROW_MAXTAG;
 
 	req = &c->reqs[row][col];
-	if (!req->tc) {
+	if (!req->wq) {
 		req->wq = kmalloc(sizeof(wait_queue_head_t), GFP_NOFS);
 		if (!req->wq) 
 			goto grow_failed;
-
 		init_waitqueue_head(req->wq);
-		req->tc = kmalloc(sizeof(struct p9_fcall) + alloc_msize,
-				  GFP_NOFS);
-		if (!req->tc)
-			goto grow_failed;
-
-		req->tc->capacity = alloc_msize;
-		req->tc->sdata = (char *) req->tc + sizeof(struct p9_fcall);
 	}
-	if (!req->rc) {
-		req->rc = kmalloc(sizeof(struct p9_fcall) + alloc_msize,
-				  GFP_NOFS);
-		if (!req->rc)
-			goto grow_failed;
 
-		req->rc->capacity = alloc_msize;
-		req->rc->sdata = (char *) req->rc + sizeof(struct p9_fcall);
-	}
+	if (!req->tc)
+		req->tc = p9_fcall_alloc(alloc_msize);
+	if (!req->rc)
+		req->rc = p9_fcall_alloc(alloc_msize);
+	if (!req->tc || !req->rc)
+		goto grow_failed;
 
 	p9pdu_reset(req->tc);
 	p9pdu_reset(req->rc);
-- 
1.7.2.2
