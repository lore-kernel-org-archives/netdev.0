From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 05/17] tcp/dccp: init sk_prot and call sk_node_init() in reqsk_alloc()
Date: Fri,  2 Oct 2015 11:43:27 -0700
Message-ID: <1443811419-4798-6-git-send-email-edumazet@google.com>
References: <1443811419-4798-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>, Ying Cai <ycai@google.com>,
	Willem de Bruijn <willemb@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:35383 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753237AbbJBSn7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2015 14:43:59 -0400
Received: by pacfv12 with SMTP id fv12so115647109pac.2
        for <netdev@vger.kernel.org>; Fri, 02 Oct 2015 11:43:59 -0700 (PDT)
In-Reply-To: <1443811419-4798-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We plan to use generic functions to insert request sockets
into ehash table.

sk_prot needs to be set (to retrieve sk_prot->h.hashinfo)
sk_node needs to be cleared.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/request_sock.h | 22 ++++++++++++----------
 1 file changed, 12 insertions(+), 10 deletions(-)

diff --git a/include/net/request_sock.h b/include/net/request_sock.h
index 273fb7235ce3..97c1ba61ed2d 100644
--- a/include/net/request_sock.h
+++ b/include/net/request_sock.h
@@ -69,6 +69,16 @@ struct request_sock {
 	u32				peer_secid;
 };
 
+static inline struct request_sock *inet_reqsk(struct sock *sk)
+{
+	return (struct request_sock *)sk;
+}
+
+static inline struct sock *req_to_sk(struct request_sock *req)
+{
+	return (struct sock *)req;
+}
+
 static inline struct request_sock *
 reqsk_alloc(const struct request_sock_ops *ops, struct sock *sk_listener)
 {
@@ -78,6 +88,8 @@ reqsk_alloc(const struct request_sock_ops *ops, struct sock *sk_listener)
 		req->rsk_ops = ops;
 		sock_hold(sk_listener);
 		req->rsk_listener = sk_listener;
+		req_to_sk(req)->sk_prot = sk_listener->sk_prot;
+		sk_node_init(&req_to_sk(req)->sk_node);
 		req->saved_syn = NULL;
 		/* Following is temporary. It is coupled with debugging
 		 * helpers in reqsk_put() & reqsk_free()
@@ -87,16 +99,6 @@ reqsk_alloc(const struct request_sock_ops *ops, struct sock *sk_listener)
 	return req;
 }
 
-static inline struct request_sock *inet_reqsk(struct sock *sk)
-{
-	return (struct request_sock *)sk;
-}
-
-static inline struct sock *req_to_sk(struct request_sock *req)
-{
-	return (struct sock *)req;
-}
-
 static inline void reqsk_free(struct request_sock *req)
 {
 	/* temporary debugging */
-- 
2.6.0.rc2.230.g3dd15c0
