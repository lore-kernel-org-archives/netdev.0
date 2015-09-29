From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 04/14] dccp: use inet6_csk_route_req() helper
Date: Tue, 29 Sep 2015 07:42:42 -0700
Message-ID: <1443537772-15305-5-git-send-email-edumazet@google.com>
References: <1443537772-15305-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:33086 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751685AbbI2Onk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 10:43:40 -0400
Received: by pacex6 with SMTP id ex6so8412042pac.0
        for <netdev@vger.kernel.org>; Tue, 29 Sep 2015 07:43:39 -0700 (PDT)
In-Reply-To: <1443537772-15305-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Before changing dccp_v6_request_recv_sock() sock argument
to const, we need to get rid of security_sk_classify_flow(),
and it seems doable by reusing inet6_csk_route_req() helper.

We need to add a proto parameter to inet6_csk_route_req(),
not assume it is TCP.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/inet6_connection_sock.h |  2 +-
 net/dccp/ipv6.c                     | 17 +++--------------
 net/ipv6/inet6_connection_sock.c    |  8 +++++---
 net/ipv6/tcp_ipv6.c                 |  7 ++++---
 4 files changed, 13 insertions(+), 21 deletions(-)

diff --git a/include/net/inet6_connection_sock.h b/include/net/inet6_connection_sock.h
index 81d937e820c4..79b2a4c09ca6 100644
--- a/include/net/inet6_connection_sock.h
+++ b/include/net/inet6_connection_sock.h
@@ -26,7 +26,7 @@ int inet6_csk_bind_conflict(const struct sock *sk,
 			    const struct inet_bind_bucket *tb, bool relax);
 
 struct dst_entry *inet6_csk_route_req(const struct sock *sk, struct flowi6 *fl6,
-				      const struct request_sock *req);
+				      const struct request_sock *req, u8 proto);
 
 struct request_sock *inet6_csk_search_req(struct sock *sk,
 					  const __be16 rport,
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index aa719e700961..0966bc08d362 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -462,22 +462,11 @@ static struct sock *dccp_v6_request_recv_sock(struct sock *sk,
 	if (sk_acceptq_is_full(sk))
 		goto out_overflow;
 
-	if (dst == NULL) {
-		struct in6_addr *final_p, final;
+	if (!dst) {
 		struct flowi6 fl6;
 
-		memset(&fl6, 0, sizeof(fl6));
-		fl6.flowi6_proto = IPPROTO_DCCP;
-		fl6.daddr = ireq->ir_v6_rmt_addr;
-		final_p = fl6_update_dst(&fl6, np->opt, &final);
-		fl6.saddr = ireq->ir_v6_loc_addr;
-		fl6.flowi6_oif = sk->sk_bound_dev_if;
-		fl6.fl6_dport = ireq->ir_rmt_port;
-		fl6.fl6_sport = htons(ireq->ir_num);
-		security_sk_classify_flow(sk, flowi6_to_flowi(&fl6));
-
-		dst = ip6_dst_lookup_flow(sk, &fl6, final_p);
-		if (IS_ERR(dst))
+		dst = inet6_csk_route_req(sk, &fl6, req, IPPROTO_DCCP);
+		if (!dst)
 			goto out;
 	}
 
diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connection_sock.c
index 91b7d33f508b..163bfef3e5db 100644
--- a/net/ipv6/inet6_connection_sock.c
+++ b/net/ipv6/inet6_connection_sock.c
@@ -67,15 +67,16 @@ EXPORT_SYMBOL_GPL(inet6_csk_bind_conflict);
 
 struct dst_entry *inet6_csk_route_req(const struct sock *sk,
 				      struct flowi6 *fl6,
-				      const struct request_sock *req)
+				      const struct request_sock *req,
+				      u8 proto)
 {
 	struct inet_request_sock *ireq = inet_rsk(req);
-	struct ipv6_pinfo *np = inet6_sk(sk);
+	const struct ipv6_pinfo *np = inet6_sk(sk);
 	struct in6_addr *final_p, final;
 	struct dst_entry *dst;
 
 	memset(fl6, 0, sizeof(*fl6));
-	fl6->flowi6_proto = IPPROTO_TCP;
+	fl6->flowi6_proto = proto;
 	fl6->daddr = ireq->ir_v6_rmt_addr;
 	final_p = fl6_update_dst(fl6, np->opt, &final);
 	fl6->saddr = ireq->ir_v6_loc_addr;
@@ -91,6 +92,7 @@ struct dst_entry *inet6_csk_route_req(const struct sock *sk,
 
 	return dst;
 }
+EXPORT_SYMBOL(inet6_csk_route_req);
 
 /*
  * request_sock (formerly open request) hash tables.
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 334d548a0cf6..092a23ef1feb 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -447,7 +447,8 @@ static int tcp_v6_send_synack(const struct sock *sk, struct dst_entry *dst,
 	int err = -ENOMEM;
 
 	/* First, grab a route. */
-	if (!dst && (dst = inet6_csk_route_req(sk, fl6, req)) == NULL)
+	if (!dst && (dst = inet6_csk_route_req(sk, fl6, req,
+					       IPPROTO_TCP)) == NULL)
 		goto done;
 
 	skb = tcp_make_synack(sk, dst, req, foc);
@@ -694,7 +695,7 @@ static struct dst_entry *tcp_v6_route_req(struct sock *sk, struct flowi *fl,
 {
 	if (strict)
 		*strict = true;
-	return inet6_csk_route_req(sk, &fl->u.ip6, req);
+	return inet6_csk_route_req(sk, &fl->u.ip6, req, IPPROTO_TCP);
 }
 
 struct request_sock_ops tcp6_request_sock_ops __read_mostly = {
@@ -1058,7 +1059,7 @@ static struct sock *tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 		goto out_overflow;
 
 	if (!dst) {
-		dst = inet6_csk_route_req(sk, &fl6, req);
+		dst = inet6_csk_route_req(sk, &fl6, req, IPPROTO_TCP);
 		if (!dst)
 			goto out;
 	}
-- 
2.6.0.rc2.230.g3dd15c0
