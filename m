From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net-next 05/11] inet: reqsk_alloc() needs to take care of dead listeners
Date: Fri,  1 Apr 2016 08:52:16 -0700
Message-ID: <1459525942-30399-6-git-send-email-edumazet@google.com>
References: <1459525942-30399-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <tom@herbertland.com>,
	Willem de Bruijn <willemb@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	=?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:33615 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932736AbcDAPwh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2016 11:52:37 -0400
Received: by mail-pa0-f44.google.com with SMTP id zm5so94038524pac.0
        for <netdev@vger.kernel.org>; Fri, 01 Apr 2016 08:52:37 -0700 (PDT)
In-Reply-To: <1459525942-30399-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We'll soon no longer take a refcount on listeners,
so reqsk_alloc() can not assume a listener refcount is not
zero. We need to use atomic_inc_not_zero()

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/request_sock.h | 31 +++++++++++++++----------------
 1 file changed, 15 insertions(+), 16 deletions(-)

diff --git a/include/net/request_sock.h b/include/net/request_sock.h
index f49759decb28..6ebe13eb1c4c 100644
--- a/include/net/request_sock.h
+++ b/include/net/request_sock.h
@@ -85,24 +85,23 @@ reqsk_alloc(const struct request_sock_ops *ops, struct sock *sk_listener,
 	struct request_sock *req;
 
 	req = kmem_cache_alloc(ops->slab, GFP_ATOMIC | __GFP_NOWARN);
-
-	if (req) {
-		req->rsk_ops = ops;
-		if (attach_listener) {
-			sock_hold(sk_listener);
-			req->rsk_listener = sk_listener;
-		} else {
-			req->rsk_listener = NULL;
+	if (!req)
+		return NULL;
+	req->rsk_listener = NULL;
+	if (attach_listener) {
+		if (unlikely(!atomic_inc_not_zero(&sk_listener->sk_refcnt))) {
+			kmem_cache_free(ops->slab, req);
+			return NULL;
 		}
-		req_to_sk(req)->sk_prot = sk_listener->sk_prot;
-		sk_node_init(&req_to_sk(req)->sk_node);
-		sk_tx_queue_clear(req_to_sk(req));
-		req->saved_syn = NULL;
-		/* Following is temporary. It is coupled with debugging
-		 * helpers in reqsk_put() & reqsk_free()
-		 */
-		atomic_set(&req->rsk_refcnt, 0);
+		req->rsk_listener = sk_listener;
 	}
+	req->rsk_ops = ops;
+	req_to_sk(req)->sk_prot = sk_listener->sk_prot;
+	sk_node_init(&req_to_sk(req)->sk_node);
+	sk_tx_queue_clear(req_to_sk(req));
+	req->saved_syn = NULL;
+	atomic_set(&req->rsk_refcnt, 0);
+
 	return req;
 }
 
-- 
2.8.0.rc3.226.g39d4020
