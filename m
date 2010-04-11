From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 2/3] tcp: Handle CHECKSUM_PARTIAL for SYNACK packets for IPv6
Date: Sun, 11 Apr 2010 20:15:54 +0800
Message-ID: <E1O0w4w-0005V0-Ip@gondolin.me.apana.org.au>
References: <20100411100902.GA20141@gondor.apana.org.au>
To: davem@davemloft.net, yinghai@kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:55358 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751247Ab0DKMQF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Apr 2010 08:16:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tcp: Handle CHECKSUM_PARTIAL for SYNACK packets for IPv6

This patch moves the common code between tcp_v6_send_check and
tcp_v6_gso_send_check into a new function __tcp_v6_send_check.

It then uses the new function in tcp_v6_send_synack as well as
tcp_v6_send_response so that they handle CHECKSUM_PARTIAL properly.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/ipv6/tcp_ipv6.c |   37 +++++++++++++++++++------------------
 1 file changed, 19 insertions(+), 18 deletions(-)

diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index c92ebe8..f84c506 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -75,6 +75,9 @@ static void	tcp_v6_reqsk_send_ack(struct sock *sk, struct sk_buff *skb,
 				      struct request_sock *req);
 
 static int	tcp_v6_do_rcv(struct sock *sk, struct sk_buff *skb);
+static void	__tcp_v6_send_check(struct sk_buff *skb,
+				    struct in6_addr *saddr,
+				    struct in6_addr *daddr);
 
 static const struct inet_connection_sock_af_ops ipv6_mapped;
 static const struct inet_connection_sock_af_ops ipv6_specific;
@@ -503,11 +506,7 @@ static int tcp_v6_send_synack(struct sock *sk, struct request_sock *req,
 
 	skb = tcp_make_synack(sk, dst, req, rvp);
 	if (skb) {
-		struct tcphdr *th = tcp_hdr(skb);
-
-		th->check = tcp_v6_check(skb->len,
-					 &treq->loc_addr, &treq->rmt_addr,
-					 csum_partial(th, skb->len, skb->csum));
+		__tcp_v6_send_check(skb, &treq->loc_addr, &treq->rmt_addr);
 
 		ipv6_addr_copy(&fl.fl6_dst, &treq->rmt_addr);
 		err = ip6_xmit(sk, skb, &fl, opt, 0);
@@ -918,22 +917,29 @@ static struct timewait_sock_ops tcp6_timewait_sock_ops = {
 	.twsk_destructor= tcp_twsk_destructor,
 };
 
-static void tcp_v6_send_check(struct sock *sk, int len, struct sk_buff *skb)
+static void __tcp_v6_send_check(struct sk_buff *skb,
+				struct in6_addr *saddr, struct in6_addr *daddr)
 {
-	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct tcphdr *th = tcp_hdr(skb);
 
 	if (skb->ip_summed == CHECKSUM_PARTIAL) {
-		th->check = ~csum_ipv6_magic(&np->saddr, &np->daddr, len, IPPROTO_TCP,  0);
+		th->check = ~tcp_v6_check(skb->len, saddr, daddr, 0);
 		skb->csum_start = skb_transport_header(skb) - skb->head;
 		skb->csum_offset = offsetof(struct tcphdr, check);
 	} else {
-		th->check = csum_ipv6_magic(&np->saddr, &np->daddr, len, IPPROTO_TCP,
-					    csum_partial(th, th->doff<<2,
-							 skb->csum));
+		th->check = tcp_v6_check(skb->len, saddr, daddr,
+					 csum_partial(th, th->doff << 2,
+						      skb->csum));
 	}
 }
 
+static void tcp_v6_send_check(struct sock *sk, int len, struct sk_buff *skb)
+{
+	struct ipv6_pinfo *np = inet6_sk(sk);
+
+	__tcp_v6_send_check(skb, &np->saddr, &np->daddr);
+}
+
 static int tcp_v6_gso_send_check(struct sk_buff *skb)
 {
 	struct ipv6hdr *ipv6h;
@@ -946,11 +952,8 @@ static int tcp_v6_gso_send_check(struct sk_buff *skb)
 	th = tcp_hdr(skb);
 
 	th->check = 0;
-	th->check = ~csum_ipv6_magic(&ipv6h->saddr, &ipv6h->daddr, skb->len,
-				     IPPROTO_TCP, 0);
-	skb->csum_start = skb_transport_header(skb) - skb->head;
-	skb->csum_offset = offsetof(struct tcphdr, check);
 	skb->ip_summed = CHECKSUM_PARTIAL;
+	__tcp_v6_send_check(skb, &ipv6h->saddr, &ipv6h->daddr);
 	return 0;
 }
 
@@ -1053,9 +1056,7 @@ static void tcp_v6_send_response(struct sk_buff *skb, u32 seq, u32 ack, u32 win,
 	ipv6_addr_copy(&fl.fl6_dst, &ipv6_hdr(skb)->saddr);
 	ipv6_addr_copy(&fl.fl6_src, &ipv6_hdr(skb)->daddr);
 
-	t1->check = csum_ipv6_magic(&fl.fl6_src, &fl.fl6_dst,
-				    tot_len, IPPROTO_TCP,
-				    buff->csum);
+	__tcp_v6_send_check(buff, &fl.fl6_src, &fl.fl6_dst);
 
 	fl.proto = IPPROTO_TCP;
 	fl.oif = inet6_iif(skb);
