From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 5/5] tcp: avoid two atomic ops for syncookies
Date: Sun,  4 Oct 2015 21:08:11 -0700
Message-ID: <1444018091-21987-6-git-send-email-edumazet@google.com>
References: <1444018091-21987-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:35139 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751175AbbJEEIp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 00:08:45 -0400
Received: by pacfv12 with SMTP id fv12so166862769pac.2
        for <netdev@vger.kernel.org>; Sun, 04 Oct 2015 21:08:45 -0700 (PDT)
In-Reply-To: <1444018091-21987-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

inet_reqsk_alloc() is used to allocate a temporary request
in order to generate a SYNACK with a cookie. Then later,
syncookie validation also uses a temporary request.

These paths already took a reference on listener refcount,
we can avoid a couple of atomic operations.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/inet_sock.h    |  3 ++-
 include/net/request_sock.h | 11 ++++++++---
 net/dccp/ipv4.c            |  2 +-
 net/dccp/ipv6.c            |  2 +-
 net/ipv4/syncookies.c      |  2 +-
 net/ipv4/tcp_input.c       |  8 +++++---
 net/ipv6/syncookies.c      |  2 +-
 7 files changed, 19 insertions(+), 11 deletions(-)

diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index 47eb67b08abd..f5bf7310e334 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -245,7 +245,8 @@ static inline unsigned int __inet_ehashfn(const __be32 laddr,
 }
 
 struct request_sock *inet_reqsk_alloc(const struct request_sock_ops *ops,
-				      struct sock *sk_listener);
+				      struct sock *sk_listener,
+				      bool attach_listener);
 
 static inline __u8 inet_sk_flowi_flags(const struct sock *sk)
 {
diff --git a/include/net/request_sock.h b/include/net/request_sock.h
index f83669460d82..95ab5d7aab96 100644
--- a/include/net/request_sock.h
+++ b/include/net/request_sock.h
@@ -80,7 +80,8 @@ static inline struct sock *req_to_sk(struct request_sock *req)
 }
 
 static inline struct request_sock *
-reqsk_alloc(const struct request_sock_ops *ops, struct sock *sk_listener)
+reqsk_alloc(const struct request_sock_ops *ops, struct sock *sk_listener,
+	    bool attach_listener)
 {
 	struct request_sock *req;
 
@@ -88,8 +89,12 @@ reqsk_alloc(const struct request_sock_ops *ops, struct sock *sk_listener)
 
 	if (req) {
 		req->rsk_ops = ops;
-		sock_hold(sk_listener);
-		req->rsk_listener = sk_listener;
+		if (attach_listener) {
+			sock_hold(sk_listener);
+			req->rsk_listener = sk_listener;
+		} else {
+			req->rsk_listener = NULL;
+		}
 		req_to_sk(req)->sk_prot = sk_listener->sk_prot;
 		sk_node_init(&req_to_sk(req)->sk_node);
 		sk_tx_queue_clear(req_to_sk(req));
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 8910c9567719..8e99681c8189 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -595,7 +595,7 @@ int dccp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	if (sk_acceptq_is_full(sk) && inet_csk_reqsk_queue_young(sk) > 1)
 		goto drop;
 
-	req = inet_reqsk_alloc(&dccp_request_sock_ops, sk);
+	req = inet_reqsk_alloc(&dccp_request_sock_ops, sk, true);
 	if (req == NULL)
 		goto drop;
 
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 1361a3f45df7..aed314f8c7c6 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -319,7 +319,7 @@ static int dccp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 	if (sk_acceptq_is_full(sk) && inet_csk_reqsk_queue_young(sk) > 1)
 		goto drop;
 
-	req = inet_reqsk_alloc(&dccp6_request_sock_ops, sk);
+	req = inet_reqsk_alloc(&dccp6_request_sock_ops, sk, true);
 	if (req == NULL)
 		goto drop;
 
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index 729ceb5f63c6..8113c30ccf96 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -326,7 +326,7 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb)
 		goto out;
 
 	ret = NULL;
-	req = inet_reqsk_alloc(&tcp_request_sock_ops, sk); /* for safety */
+	req = inet_reqsk_alloc(&tcp_request_sock_ops, sk, false); /* for safety */
 	if (!req)
 		goto out;
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index a95c8eb04ff7..ddadb318e850 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -6042,9 +6042,11 @@ static void tcp_openreq_init(struct request_sock *req,
 }
 
 struct request_sock *inet_reqsk_alloc(const struct request_sock_ops *ops,
-				      struct sock *sk_listener)
+				      struct sock *sk_listener,
+				      bool attach_listener)
 {
-	struct request_sock *req = reqsk_alloc(ops, sk_listener);
+	struct request_sock *req = reqsk_alloc(ops, sk_listener,
+					       attach_listener);
 
 	if (req) {
 		struct inet_request_sock *ireq = inet_rsk(req);
@@ -6143,7 +6145,7 @@ int tcp_conn_request(struct request_sock_ops *rsk_ops,
 		goto drop;
 	}
 
-	req = inet_reqsk_alloc(rsk_ops, sk);
+	req = inet_reqsk_alloc(rsk_ops, sk, !want_cookie);
 	if (!req)
 		goto drop;
 
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index 7606eba83e7b..f610b5310b17 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -170,7 +170,7 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 		goto out;
 
 	ret = NULL;
-	req = inet_reqsk_alloc(&tcp6_request_sock_ops, sk);
+	req = inet_reqsk_alloc(&tcp6_request_sock_ops, sk, false);
 	if (!req)
 		goto out;
 
-- 
2.6.0.rc2.230.g3dd15c0
