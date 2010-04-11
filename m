From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 1/3] tcp: Handle CHECKSUM_PARTIAL for SYNACK packets for IPv4
Date: Sun, 11 Apr 2010 20:15:53 +0800
Message-ID: <E1O0w4v-0005UZ-GF@gondolin.me.apana.org.au>
References: <20100411100902.GA20141@gondor.apana.org.au>
To: davem@davemloft.net, yinghai@kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

tcp: Handle CHECKSUM_PARTIAL for SYNACK packets for IPv4

This patch moves the common code between tcp_v4_send_check and
tcp_v4_gso_send_check into a new function __tcp_v4_send_check.

It then uses the new function in tcp_v4_send_synack so that it
handles CHECKSUM_PARTIAL properly.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/ipv4/tcp_ipv4.c |   31 ++++++++++++++-----------------
 1 file changed, 14 insertions(+), 17 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 3c23e70..aebfd28 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -519,26 +519,31 @@ out:
 	sock_put(sk);
 }
 
-/* This routine computes an IPv4 TCP checksum. */
-void tcp_v4_send_check(struct sock *sk, int len, struct sk_buff *skb)
+static void __tcp_v4_send_check(struct sk_buff *skb,
+				__be32 saddr, __be32 daddr)
 {
-	struct inet_sock *inet = inet_sk(sk);
 	struct tcphdr *th = tcp_hdr(skb);
 
 	if (skb->ip_summed == CHECKSUM_PARTIAL) {
-		th->check = ~tcp_v4_check(len, inet->inet_saddr,
-					  inet->inet_daddr, 0);
+		th->check = ~tcp_v4_check(skb->len, saddr, daddr, 0);
 		skb->csum_start = skb_transport_header(skb) - skb->head;
 		skb->csum_offset = offsetof(struct tcphdr, check);
 	} else {
-		th->check = tcp_v4_check(len, inet->inet_saddr,
-					 inet->inet_daddr,
+		th->check = tcp_v4_check(skb->len, saddr, daddr,
 					 csum_partial(th,
 						      th->doff << 2,
 						      skb->csum));
 	}
 }
 
+/* This routine computes an IPv4 TCP checksum. */
+void tcp_v4_send_check(struct sock *sk, int len, struct sk_buff *skb)
+{
+	struct inet_sock *inet = inet_sk(sk);
+
+	__tcp_v4_send_check(skb, inet->inet_saddr, inet->inet_daddr);
+}
+
 int tcp_v4_gso_send_check(struct sk_buff *skb)
 {
 	const struct iphdr *iph;
@@ -551,10 +556,8 @@ int tcp_v4_gso_send_check(struct sk_buff *skb)
 	th = tcp_hdr(skb);
 
 	th->check = 0;
-	th->check = ~tcp_v4_check(skb->len, iph->saddr, iph->daddr, 0);
-	skb->csum_start = skb_transport_header(skb) - skb->head;
-	skb->csum_offset = offsetof(struct tcphdr, check);
 	skb->ip_summed = CHECKSUM_PARTIAL;
+	__tcp_v4_send_check(skb, iph->saddr, iph->daddr);
 	return 0;
 }
 
@@ -763,13 +766,7 @@ static int tcp_v4_send_synack(struct sock *sk, struct dst_entry *dst,
 	skb = tcp_make_synack(sk, dst, req, rvp);
 
 	if (skb) {
-		struct tcphdr *th = tcp_hdr(skb);
-
-		th->check = tcp_v4_check(skb->len,
-					 ireq->loc_addr,
-					 ireq->rmt_addr,
-					 csum_partial(th, skb->len,
-						      skb->csum));
+		__tcp_v4_send_check(skb, ireq->loc_addr, ireq->rmt_addr);
 
 		err = ip_build_and_send_pkt(skb, sk, ireq->loc_addr,
 					    ireq->rmt_addr,
