From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 6/6] inet: fix request sock refcounting
Date: Tue, 17 Mar 2015 18:32:31 -0700
Message-ID: <1426642351-26098-7-git-send-email-edumazet@google.com>
References: <1426642351-26098-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f73.google.com ([209.85.192.73]:33418 "EHLO
	mail-qg0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753778AbbCRBnH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 21:43:07 -0400
Received: by qgdz107 with SMTP id z107so1021164qgd.0
        for <netdev@vger.kernel.org>; Tue, 17 Mar 2015 18:43:06 -0700 (PDT)
In-Reply-To: <1426642351-26098-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While testing last patch series, I found req sock refcounting was wrong.

We must set skc_refcnt to 1 for all request socks added in hashes,
but also on request sockets created by FastOpen or syncookies.

It is tricky because we need to defer this initialization so that
future RCU lookups do not try to take a refcount on a not yet
fully initialized request socket.

Also get rid of ireq_refcnt alias.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Fixes: 13854e5a6046 ("inet: add proper refcounting to request sock")
---
 include/net/inet_connection_sock.h |  5 -----
 include/net/inet_sock.h            |  1 -
 include/net/request_sock.h         | 12 ++++++++++++
 net/ipv4/syncookies.c              | 11 ++++++-----
 net/ipv4/tcp_fastopen.c            |  1 +
 net/ipv4/tcp_input.c               |  4 ----
 net/ipv6/syncookies.c              |  7 ++++---
 7 files changed, 23 insertions(+), 18 deletions(-)

diff --git a/include/net/inet_connection_sock.h b/include/net/inet_connection_sock.h
index 191feec60205..b9a6b0a94cc6 100644
--- a/include/net/inet_connection_sock.h
+++ b/include/net/inet_connection_sock.h
@@ -275,11 +275,6 @@ static inline void inet_csk_reqsk_queue_add(struct sock *sk,
 					    struct sock *child)
 {
 	reqsk_queue_add(&inet_csk(sk)->icsk_accept_queue, req, sk, child);
-	/* before letting lookups find us, make sure all req fields
-	 * are committed to memory.
-	 */
-	smp_wmb();
-	atomic_set(&req->rsk_refcnt, 1);
 }
 
 void inet_csk_reqsk_queue_hash_add(struct sock *sk, struct request_sock *req,
diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index 6fec7343070f..b6c3737da4e9 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -81,7 +81,6 @@ struct inet_request_sock {
 #define ir_cookie		req.__req_common.skc_cookie
 #define ireq_net		req.__req_common.skc_net
 #define ireq_state		req.__req_common.skc_state
-#define ireq_refcnt		req.__req_common.skc_refcnt
 #define ireq_family		req.__req_common.skc_family
 
 	kmemcheck_bitfield_begin(flags);
diff --git a/include/net/request_sock.h b/include/net/request_sock.h
index 723d1cbdf20e..3da166d99c09 100644
--- a/include/net/request_sock.h
+++ b/include/net/request_sock.h
@@ -77,6 +77,11 @@ reqsk_alloc(const struct request_sock_ops *ops, struct sock *sk_listener)
 		req->rsk_ops = ops;
 		sock_hold(sk_listener);
 		req->rsk_listener = sk_listener;
+
+		/* Following is temporary. It is coupled with debugging
+		 * helpers in reqsk_put() & reqsk_free()
+		 */
+		atomic_set(&req->rsk_refcnt, 0);
 	}
 	return req;
 }
@@ -292,9 +297,16 @@ static inline void reqsk_queue_hash_req(struct request_sock_queue *queue,
 	req->sk = NULL;
 	req->dl_next = lopt->syn_table[hash];
 
+	/* before letting lookups find us, make sure all req fields
+	 * are committed to memory and refcnt initialized.
+	 */
+	smp_wmb();
+	atomic_set(&req->rsk_refcnt, 1);
+
 	write_lock(&queue->syn_wait_lock);
 	lopt->syn_table[hash] = req;
 	write_unlock(&queue->syn_wait_lock);
+
 }
 
 #endif /* _REQUEST_SOCK_H */
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index 574b67765a06..34e755403715 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -227,11 +227,12 @@ static struct sock *get_cookie_sock(struct sock *sk, struct sk_buff *skb,
 	struct sock *child;
 
 	child = icsk->icsk_af_ops->syn_recv_sock(sk, skb, req, dst);
-	if (child)
+	if (child) {
+		atomic_set(&req->rsk_refcnt, 1);
 		inet_csk_reqsk_queue_add(sk, req, child);
-	else
+	} else {
 		reqsk_free(req);
-
+	}
 	return child;
 }
 
@@ -356,7 +357,7 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb)
 	ireq->opt = tcp_v4_save_options(skb);
 
 	if (security_inet_conn_request(sk, skb, req)) {
-		reqsk_put(req);
+		reqsk_free(req);
 		goto out;
 	}
 
@@ -377,7 +378,7 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb)
 	security_req_classify_flow(req, flowi4_to_flowi(&fl4));
 	rt = ip_route_output_key(sock_net(sk), &fl4);
 	if (IS_ERR(rt)) {
-		reqsk_put(req);
+		reqsk_free(req);
 		goto out;
 	}
 
diff --git a/net/ipv4/tcp_fastopen.c b/net/ipv4/tcp_fastopen.c
index 186fd394ec0a..82e375a0cbcf 100644
--- a/net/ipv4/tcp_fastopen.c
+++ b/net/ipv4/tcp_fastopen.c
@@ -169,6 +169,7 @@ static bool tcp_fastopen_create_child(struct sock *sk,
 	inet_csk_reset_xmit_timer(child, ICSK_TIME_RETRANS,
 				  TCP_TIMEOUT_INIT, TCP_RTO_MAX);
 
+	atomic_set(&req->rsk_refcnt, 1);
 	/* Add the child socket directly into the accept queue */
 	inet_csk_reqsk_queue_add(sk, req, child);
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index a94ddb96fc85..1dfbaee3554e 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5981,10 +5981,6 @@ struct request_sock *inet_reqsk_alloc(const struct request_sock_ops *ops,
 		ireq->ireq_state = TCP_NEW_SYN_RECV;
 		write_pnet(&ireq->ireq_net, sock_net(sk_listener));
 
-		/* Following is temporary. It is coupled with debugging
-		 * helpers in reqsk_put() & reqsk_free()
-		 */
-		atomic_set(&ireq->ireq_refcnt, 0);
 	}
 
 	return req;
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index 1ef0c926ce9d..da5823e5e5a7 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -49,11 +49,12 @@ static inline struct sock *get_cookie_sock(struct sock *sk, struct sk_buff *skb,
 	struct sock *child;
 
 	child = icsk->icsk_af_ops->syn_recv_sock(sk, skb, req, dst);
-	if (child)
+	if (child) {
+		atomic_set(&req->rsk_refcnt, 1);
 		inet_csk_reqsk_queue_add(sk, req, child);
-	else
+	} else {
 		reqsk_free(req);
-
+	}
 	return child;
 }
 
-- 
2.2.0.rc0.207.ga3a616c
