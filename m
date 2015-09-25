From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 01/17] tcp: constify listener socket in tcp_v[46]_init_req()
Date: Fri, 25 Sep 2015 07:39:08 -0700
Message-ID: <1443191964-923-2-git-send-email-edumazet@google.com>
References: <1443191964-923-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <edumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:34780 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932113AbbIYOjw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2015 10:39:52 -0400
Received: by padhy16 with SMTP id hy16so107758468pad.1
        for <netdev@vger.kernel.org>; Fri, 25 Sep 2015 07:39:41 -0700 (PDT)
In-Reply-To: <1443191964-923-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Soon, listener socket spinlock will no longer be held,
add const arguments to tcp_v[46]_init_req() to make clear these
functions can not mess socket fields.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/tcp.h   | 3 ++-
 net/ipv4/tcp_ipv4.c | 3 ++-
 net/ipv6/tcp_ipv6.c | 9 +++++----
 3 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 8397d49b47d4..50af10ef1a3d 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1705,7 +1705,8 @@ struct tcp_request_sock_ops {
 					  const struct sock *sk,
 					  const struct sk_buff *skb);
 #endif
-	void (*init_req)(struct request_sock *req, struct sock *sk,
+	void (*init_req)(struct request_sock *req,
+			 const struct sock *sk_listener,
 			 struct sk_buff *skb);
 #ifdef CONFIG_SYN_COOKIES
 	__u32 (*cookie_init_seq)(struct sock *sk, const struct sk_buff *skb,
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 7e2646542312..9d968ca7b669 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1168,7 +1168,8 @@ static bool tcp_v4_inbound_md5_hash(struct sock *sk,
 }
 #endif
 
-static void tcp_v4_init_req(struct request_sock *req, struct sock *sk_listener,
+static void tcp_v4_init_req(struct request_sock *req,
+			    const struct sock *sk_listener,
 			    struct sk_buff *skb)
 {
 	struct inet_request_sock *ireq = inet_rsk(req);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index a004e0b0b3e9..9016797445a2 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -663,22 +663,23 @@ static bool tcp_v6_inbound_md5_hash(struct sock *sk, const struct sk_buff *skb)
 }
 #endif
 
-static void tcp_v6_init_req(struct request_sock *req, struct sock *sk,
+static void tcp_v6_init_req(struct request_sock *req,
+			    const struct sock *sk_listener,
 			    struct sk_buff *skb)
 {
 	struct inet_request_sock *ireq = inet_rsk(req);
-	struct ipv6_pinfo *np = inet6_sk(sk);
+	const struct ipv6_pinfo *np = inet6_sk(sk_listener);
 
 	ireq->ir_v6_rmt_addr = ipv6_hdr(skb)->saddr;
 	ireq->ir_v6_loc_addr = ipv6_hdr(skb)->daddr;
 
 	/* So that link locals have meaning */
-	if (!sk->sk_bound_dev_if &&
+	if (!sk_listener->sk_bound_dev_if &&
 	    ipv6_addr_type(&ireq->ir_v6_rmt_addr) & IPV6_ADDR_LINKLOCAL)
 		ireq->ir_iif = tcp_v6_iif(skb);
 
 	if (!TCP_SKB_CB(skb)->tcp_tw_isn &&
-	    (ipv6_opt_accepted(sk, skb, &TCP_SKB_CB(skb)->header.h6) ||
+	    (ipv6_opt_accepted(sk_listener, skb, &TCP_SKB_CB(skb)->header.h6) ||
 	     np->rxopt.bits.rxinfo ||
 	     np->rxopt.bits.rxoinfo || np->rxopt.bits.rxhlim ||
 	     np->rxopt.bits.rxohlim || np->repflow)) {
-- 
2.6.0.rc2.230.g3dd15c0
