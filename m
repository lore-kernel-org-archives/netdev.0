From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: sit: Clean up DF code by copying from IPIP
Date: Mon, 9 Nov 2009 13:42:01 -0500
Message-ID: <20091109184201.GA9493@gondor.apana.org.au>
References: <20091106203741.GA19736@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:40465 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751121AbZKISl7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2009 13:41:59 -0500
Content-Disposition: inline
In-Reply-To: <20091106203741.GA19736@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave:

This can go into net-next since it doesn't really alter the
behaviour in any significant way.

sit: Clean up DF code by copying from IPIP

This patch rearranges the SIT DF bit handling using the new IPIP
DF code.  The only externally visible effect should be the case where
PMTU is enabled and the MTU is exactly 1280 bytes.  In this case
the previous code would send packets out with DF off while the new
code would set the DF bit.  This is inline with RFC 4213.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index dbd19a7..97739ee 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -559,6 +559,7 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 	struct iphdr  *tiph = &tunnel->parms.iph;
 	struct ipv6hdr *iph6 = ipv6_hdr(skb);
 	u8     tos = tunnel->parms.iph.tos;
+	__be16 df = tiph->frag_off;
 	struct rtable *rt;     			/* Route to the other host */
 	struct net_device *tdev;			/* Device to other host */
 	struct iphdr  *iph;			/* Our new IP header */
@@ -648,25 +649,28 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 		goto tx_error;
 	}
 
-	if (tiph->frag_off)
+	if (df) {
 		mtu = dst_mtu(&rt->u.dst) - sizeof(struct iphdr);
-	else
-		mtu = skb_dst(skb) ? dst_mtu(skb_dst(skb)) : dev->mtu;
 
-	if (mtu < 68) {
-		stats->collisions++;
-		ip_rt_put(rt);
-		goto tx_error;
-	}
-	if (mtu < IPV6_MIN_MTU)
-		mtu = IPV6_MIN_MTU;
-	if (tunnel->parms.iph.daddr && skb_dst(skb))
-		skb_dst(skb)->ops->update_pmtu(skb_dst(skb), mtu);
+		if (mtu < 68) {
+			stats->collisions++;
+			ip_rt_put(rt);
+			goto tx_error;
+		}
 
-	if (skb->len > mtu) {
-		icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu, dev);
-		ip_rt_put(rt);
-		goto tx_error;
+		if (mtu < IPV6_MIN_MTU) {
+			mtu = IPV6_MIN_MTU;
+			df = 0;
+		}
+
+		if (tunnel->parms.iph.daddr && skb_dst(skb))
+			skb_dst(skb)->ops->update_pmtu(skb_dst(skb), mtu);
+
+		if (skb->len > mtu) {
+			icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu, dev);
+			ip_rt_put(rt);
+			goto tx_error;
+		}
 	}
 
 	if (tunnel->err_count > 0) {
@@ -714,11 +718,7 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 	iph 			=	ip_hdr(skb);
 	iph->version		=	4;
 	iph->ihl		=	sizeof(struct iphdr)>>2;
-	if (mtu > IPV6_MIN_MTU)
-		iph->frag_off	=	tiph->frag_off;
-	else
-		iph->frag_off	=	0;
-
+	iph->frag_off		=	df;
 	iph->protocol		=	IPPROTO_IPV6;
 	iph->tos		=	INET_ECN_encapsulate(tos, ipv6_get_dsfield(iph6));
 	iph->daddr		=	rt->rt_dst;

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
