From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 3/6] inet: add rsk_listener field to struct request_sock
Date: Tue, 17 Mar 2015 18:32:28 -0700
Message-ID: <1426642351-26098-4-git-send-email-edumazet@google.com>
References: <1426642351-26098-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f74.google.com ([209.85.220.74]:33311 "EHLO
	mail-pa0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932506AbbCRBe1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 21:34:27 -0400
Received: by pablj1 with SMTP id lj1so1822817pab.0
        for <netdev@vger.kernel.org>; Tue, 17 Mar 2015 18:34:27 -0700 (PDT)
In-Reply-To: <1426642351-26098-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Once we'll be able to lookup request sockets in ehash table,
we'll need to get access to listener which created this request.

This avoid doing a lookup to find the listener, which benefits
for a more solid SO_REUSEPORT, and is needed once we no
longer queue request sock into a listener private queue.

Note that 'struct tcp_request_sock'->listener could be reduced
to a single bit, as TFO listener should match req->rsk_listener.
TFO will no longer need to hold a reference on the listener.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/request_sock.h | 12 +++++++++---
 net/ipv4/tcp_input.c       |  2 +-
 2 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/include/net/request_sock.h b/include/net/request_sock.h
index 56dc2faba47e..723d1cbdf20e 100644
--- a/include/net/request_sock.h
+++ b/include/net/request_sock.h
@@ -52,6 +52,7 @@ struct request_sock {
 #define rsk_refcnt			__req_common.skc_refcnt
 
 	struct request_sock		*dl_next;
+	struct sock			*rsk_listener;
 	u16				mss;
 	u8				num_retrans; /* number of retransmits */
 	u8				cookie_ts:1; /* syncookie: encode tcpopts in timestamp */
@@ -67,13 +68,16 @@ struct request_sock {
 	u32				peer_secid;
 };
 
-static inline struct request_sock *reqsk_alloc(const struct request_sock_ops *ops)
+static inline struct request_sock *
+reqsk_alloc(const struct request_sock_ops *ops, struct sock *sk_listener)
 {
 	struct request_sock *req = kmem_cache_alloc(ops->slab, GFP_ATOMIC);
 
-	if (req != NULL)
+	if (req) {
 		req->rsk_ops = ops;
-
+		sock_hold(sk_listener);
+		req->rsk_listener = sk_listener;
+	}
 	return req;
 }
 
@@ -88,6 +92,8 @@ static inline void reqsk_free(struct request_sock *req)
 	WARN_ON_ONCE(atomic_read(&req->rsk_refcnt) != 0);
 
 	req->rsk_ops->destructor(req);
+	if (req->rsk_listener)
+		sock_put(req->rsk_listener);
 	kmem_cache_free(req->rsk_ops->slab, req);
 }
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 52b74e0eab2a..fbe518981d36 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5970,7 +5970,7 @@ static void tcp_openreq_init(struct request_sock *req,
 struct request_sock *inet_reqsk_alloc(const struct request_sock_ops *ops,
 				      struct sock *sk_listener)
 {
-	struct request_sock *req = reqsk_alloc(ops);
+	struct request_sock *req = reqsk_alloc(ops, sk_listener);
 
 	if (req) {
 		struct inet_request_sock *ireq = inet_rsk(req);
-- 
2.2.0.rc0.207.ga3a616c
