From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] tcp: make urg+gso work for real this time
Date: Wed, 17 Dec 2008 12:18:47 +1100
Message-ID: <E1LCl3n-00052k-6h@gondolin.me.apana.org.au>
References: <Pine.LNX.4.64.0812031320340.31282@wrl-59.cs.helsinki.fi>
Cc: davem@davemloft.net, netdev@vger.kernel.org, ptesarik@suse.cz
To: ilpo.jarvinen@helsinki.fi (Ilpo J??rvinen)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:58188 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750983AbYLQBS5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2008 20:18:57 -0500
In-Reply-To: <Pine.LNX.4.64.0812031320340.31282@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ilpo J??rvinen <ilpo.jarvinen@helsinki.fi> wrote:
> 
> I should have noticed this earlier... :-) The previous solution
> to URG+GSO/TSO will cause SACK block tcp_fragment to do zig-zig
> patterns, or even worse, a steep downward slope into packet
> counting because each skb pcount would be truncated to pcount
> of 2 and then the following fragments of the later portion would
> restore the window again.

How about just handling it, URG isn't that hard.  If anyone is
bored you can do this for GRO as well.

tcp: Add GSO support for urgent data

When segmenting packets with urgent data we need to clear the
urgent flag/pointer once we move past the end of the urgent data.
This was not handled correctly in GSO or (presumably) in existing
hardware.

This patch adds a new GSO flag for TCP urgent data and also fixes
its handling in GSO.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index e26f549..4508c48 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -532,9 +532,11 @@ struct net_device
 #define NETIF_F_GSO_ROBUST	(SKB_GSO_DODGY << NETIF_F_GSO_SHIFT)
 #define NETIF_F_TSO_ECN		(SKB_GSO_TCP_ECN << NETIF_F_GSO_SHIFT)
 #define NETIF_F_TSO6		(SKB_GSO_TCPV6 << NETIF_F_GSO_SHIFT)
+#define NETIF_F_TSO_URG		(SKB_GSO_TCP_URG << NETIF_F_GSO_SHIFT)
 
 	/* List of features with software fallbacks. */
-#define NETIF_F_GSO_SOFTWARE	(NETIF_F_TSO | NETIF_F_TSO_ECN | NETIF_F_TSO6)
+#define NETIF_F_GSO_SOFTWARE	(NETIF_F_TSO | NETIF_F_TSO_ECN | \
+				 NETIF_F_TSO6 | NETIF_F_TSO_URG)
 
 
 #define NETIF_F_GEN_CSUM	(NETIF_F_NO_CSUM | NETIF_F_HW_CSUM)
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 2725f4e..56e9179 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -188,6 +188,9 @@ enum {
 	SKB_GSO_TCP_ECN = 1 << 3,
 
 	SKB_GSO_TCPV6 = 1 << 4,
+
+	/* This indicates the tcp segment has URG set. */
+	SKB_GSO_TCP_URG = 1 << 5,
 };
 
 #if BITS_PER_LONG > 32
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 1aa2dc9..33305f6 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1202,6 +1202,7 @@ static struct sk_buff *inet_gso_segment(struct sk_buff *skb, int features)
 		       SKB_GSO_UDP |
 		       SKB_GSO_DODGY |
 		       SKB_GSO_TCP_ECN |
+		       SKB_GSO_TCP_URG |
 		       0)))
 		goto out;
 
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index c5aca0b..e6796a8 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2383,6 +2383,7 @@ struct sk_buff *tcp_tso_segment(struct sk_buff *skb, int features)
 	__be32 delta;
 	unsigned int oldlen;
 	unsigned int len;
+	unsigned int urg_ptr;
 
 	if (!pskb_may_pull(skb, sizeof(*th)))
 		goto out;
@@ -2408,6 +2409,7 @@ struct sk_buff *tcp_tso_segment(struct sk_buff *skb, int features)
 			       SKB_GSO_DODGY |
 			       SKB_GSO_TCP_ECN |
 			       SKB_GSO_TCPV6 |
+			       SKB_GSO_TCP_URG |
 			       0) ||
 			     !(type & (SKB_GSO_TCPV4 | SKB_GSO_TCPV6))))
 			goto out;
@@ -2429,6 +2431,7 @@ struct sk_buff *tcp_tso_segment(struct sk_buff *skb, int features)
 	skb = segs;
 	th = tcp_hdr(skb);
 	seq = ntohl(th->seq);
+	urg_ptr = th->urg ? ntohs(th->urg_ptr) : 0;
 
 	do {
 		th->fin = th->psh = 0;
@@ -2446,6 +2449,14 @@ struct sk_buff *tcp_tso_segment(struct sk_buff *skb, int features)
 
 		th->seq = htonl(seq);
 		th->cwr = 0;
+
+		if (urg_ptr <= len)
+			urg_ptr = 0;
+		else
+			urg_ptr -= len;
+
+		th->urg = !!urg_ptr;
+		th->urg_ptr = htons(urg_ptr);
 	} while (skb->next);
 
 	delta = htonl(oldlen + (skb->tail - skb->transport_header) +
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index fe3b4bd..d4dc0fa 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -667,6 +667,7 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 		     between(tp->snd_up, tcb->seq + 1, tcb->seq + 0xFFFF))) {
 		th->urg_ptr		= htons(tp->snd_up - tcb->seq);
 		th->urg			= 1;
+		skb_shinfo(skb)->gso_type |= SKB_GSO_TCP_URG;
 	}
 
 	tcp_options_write((__be32 *)(th + 1), tp, &opts, &md5_hash_location);
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 01edac8..c11d3d9 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -746,6 +746,7 @@ static struct sk_buff *ipv6_gso_segment(struct sk_buff *skb, int features)
 		       SKB_GSO_DODGY |
 		       SKB_GSO_TCP_ECN |
 		       SKB_GSO_TCPV6 |
+		       SKB_GSO_TCP_URG |
 		       0)))
 		goto out;
 
