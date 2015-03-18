From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 2/6] inet: uninline inet_reqsk_alloc()
Date: Tue, 17 Mar 2015 18:32:27 -0700
Message-ID: <1426642351-26098-3-git-send-email-edumazet@google.com>
References: <1426642351-26098-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f73.google.com ([209.85.220.73]:33201 "EHLO
	mail-pa0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932387AbbCRBdH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 21:33:07 -0400
Received: by pablj1 with SMTP id lj1so1821712pab.0
        for <netdev@vger.kernel.org>; Tue, 17 Mar 2015 18:33:06 -0700 (PDT)
In-Reply-To: <1426642351-26098-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

inet_reqsk_alloc() is becoming fat and should not be inlined.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/inet_sock.h | 24 ++----------------------
 net/ipv4/tcp_input.c    | 24 ++++++++++++++++++++++++
 2 files changed, 26 insertions(+), 22 deletions(-)

diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index cf7abb00941b..6fec7343070f 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -244,28 +244,8 @@ static inline unsigned int __inet_ehashfn(const __be32 laddr,
 			    initval);
 }
 
-static inline struct request_sock *
-inet_reqsk_alloc(const struct request_sock_ops *ops, struct sock *sk_listener)
-{
-	struct request_sock *req = reqsk_alloc(ops);
-
-	if (req) {
-		struct inet_request_sock *ireq = inet_rsk(req);
-
-		kmemcheck_annotate_bitfield(ireq, flags);
-		ireq->opt = NULL;
-		atomic64_set(&ireq->ir_cookie, 0);
-		ireq->ireq_state = TCP_NEW_SYN_RECV;
-		write_pnet(&ireq->ireq_net, sock_net(sk_listener));
-
-		/* Following is temporary. It is coupled with debugging
-		 * helpers in reqsk_put() & reqsk_free()
-		 */
-		atomic_set(&ireq->ireq_refcnt, 0);
-	}
-
-	return req;
-}
+struct request_sock *inet_reqsk_alloc(const struct request_sock_ops *ops,
+				      struct sock *sk_listener);
 
 static inline __u8 inet_sk_flowi_flags(const struct sock *sk)
 {
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 2a480f6811ea..52b74e0eab2a 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5967,6 +5967,30 @@ static void tcp_openreq_init(struct request_sock *req,
 	ireq->ir_mark = inet_request_mark(sk, skb);
 }
 
+struct request_sock *inet_reqsk_alloc(const struct request_sock_ops *ops,
+				      struct sock *sk_listener)
+{
+	struct request_sock *req = reqsk_alloc(ops);
+
+	if (req) {
+		struct inet_request_sock *ireq = inet_rsk(req);
+
+		kmemcheck_annotate_bitfield(ireq, flags);
+		ireq->opt = NULL;
+		atomic64_set(&ireq->ir_cookie, 0);
+		ireq->ireq_state = TCP_NEW_SYN_RECV;
+		write_pnet(&ireq->ireq_net, sock_net(sk_listener));
+
+		/* Following is temporary. It is coupled with debugging
+		 * helpers in reqsk_put() & reqsk_free()
+		 */
+		atomic_set(&ireq->ireq_refcnt, 0);
+	}
+
+	return req;
+}
+EXPORT_SYMBOL(inet_reqsk_alloc);
+
 int tcp_conn_request(struct request_sock_ops *rsk_ops,
 		     const struct tcp_request_sock_ops *af_ops,
 		     struct sock *sk, struct sk_buff *skb)
-- 
2.2.0.rc0.207.ga3a616c
