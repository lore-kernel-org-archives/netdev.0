From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [2/2] tcp6: Add GRO support
Date: Wed, 7 Jan 2009 14:15:36 +1100
Message-ID: <20090107031536.GA18655@gondor.apana.org.au>
References: <20090107031404.GA16827@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:44515 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751661AbZAGDPi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2009 22:15:38 -0500
Content-Disposition: inline
In-Reply-To: <20090107031404.GA16827@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tcp6: Add GRO support

This patch adds GRO support for TCP over IPv6.  The code is exactly
the same as the IPv4 version except for the pseudo-header checksum
computation.

Note that I've removed the unused tcphdr argument from tcp_v6_check
rather than invent a bogus value for GRO.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 218a6e5..e23bbb6 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2545,6 +2545,7 @@ out:
 
 	return pp;
 }
+EXPORT_SYMBOL(tcp_gro_receive);
 
 int tcp_gro_complete(struct sk_buff *skb)
 {
@@ -2561,6 +2562,7 @@ int tcp_gro_complete(struct sk_buff *skb)
 
 	return 0;
 }
+EXPORT_SYMBOL(tcp_gro_complete);
 
 #ifdef CONFIG_TCP_MD5SIG
 static unsigned long tcp_md5sig_users;
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 8702b06..be668ac 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -100,7 +100,7 @@ static void tcp_v6_hash(struct sock *sk)
 	}
 }
 
-static __inline__ __sum16 tcp_v6_check(struct tcphdr *th, int len,
+static __inline__ __sum16 tcp_v6_check(int len,
 				   struct in6_addr *saddr,
 				   struct in6_addr *daddr,
 				   __wsum base)
@@ -500,7 +500,7 @@ static int tcp_v6_send_synack(struct sock *sk, struct request_sock *req)
 	if (skb) {
 		struct tcphdr *th = tcp_hdr(skb);
 
-		th->check = tcp_v6_check(th, skb->len,
+		th->check = tcp_v6_check(skb->len,
 					 &treq->loc_addr, &treq->rmt_addr,
 					 csum_partial(th, skb->len, skb->csum));
 
@@ -941,6 +941,41 @@ static int tcp_v6_gso_send_check(struct sk_buff *skb)
 	return 0;
 }
 
+struct sk_buff **tcp6_gro_receive(struct sk_buff **head, struct sk_buff *skb)
+{
+	struct ipv6hdr *iph = ipv6_hdr(skb);
+
+	switch (skb->ip_summed) {
+	case CHECKSUM_COMPLETE:
+		if (!tcp_v6_check(skb->len, &iph->saddr, &iph->daddr,
+				  skb->csum)) {
+			skb->ip_summed = CHECKSUM_UNNECESSARY;
+			break;
+		}
+
+		/* fall through */
+	case CHECKSUM_NONE:
+		NAPI_GRO_CB(skb)->flush = 1;
+		return NULL;
+	}
+
+	return tcp_gro_receive(head, skb);
+}
+EXPORT_SYMBOL(tcp6_gro_receive);
+
+int tcp6_gro_complete(struct sk_buff *skb)
+{
+	struct ipv6hdr *iph = ipv6_hdr(skb);
+	struct tcphdr *th = tcp_hdr(skb);
+
+	th->check = ~tcp_v6_check(skb->len - skb_transport_offset(skb),
+				  &iph->saddr, &iph->daddr, 0);
+	skb_shinfo(skb)->gso_type = SKB_GSO_TCPV6;
+
+	return tcp_gro_complete(skb);
+}
+EXPORT_SYMBOL(tcp6_gro_complete);
+
 static void tcp_v6_send_response(struct sk_buff *skb, u32 seq, u32 ack, u32 win,
 				 u32 ts, struct tcp_md5sig_key *key, int rst)
 {
@@ -1428,14 +1463,14 @@ out:
 static __sum16 tcp_v6_checksum_init(struct sk_buff *skb)
 {
 	if (skb->ip_summed == CHECKSUM_COMPLETE) {
-		if (!tcp_v6_check(tcp_hdr(skb), skb->len, &ipv6_hdr(skb)->saddr,
+		if (!tcp_v6_check(skb->len, &ipv6_hdr(skb)->saddr,
 				  &ipv6_hdr(skb)->daddr, skb->csum)) {
 			skb->ip_summed = CHECKSUM_UNNECESSARY;
 			return 0;
 		}
 	}
 
-	skb->csum = ~csum_unfold(tcp_v6_check(tcp_hdr(skb), skb->len,
+	skb->csum = ~csum_unfold(tcp_v6_check(skb->len,
 					      &ipv6_hdr(skb)->saddr,
 					      &ipv6_hdr(skb)->daddr, 0));
 
@@ -2059,6 +2094,8 @@ static struct inet6_protocol tcpv6_protocol = {
 	.err_handler	=	tcp_v6_err,
 	.gso_send_check	=	tcp_v6_gso_send_check,
 	.gso_segment	=	tcp_tso_segment,
+	.gro_receive	=	tcp6_gro_receive,
+	.gro_complete	=	tcp6_gro_complete,
 	.flags		=	INET6_PROTO_NOPOLICY|INET6_PROTO_FINAL,
 };

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
