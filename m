From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 3/12] [IPSEC]: Get nexthdr from caller in xfrm6_rcv_spi
Date: Tue, 16 Oct 2007 22:33:11 +0800
Message-ID: <E1IhnTr-0003GS-00@gondolin.me.apana.org.au>
References: <20071016141843.GA11956@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3013 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933128AbXJPOxz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2007 10:53:55 -0400
Received: from gondolin.me.apana.org.au ([192.168.0.6] ident=mail)
	by arnor.apana.org.au with esmtp (Exim 4.50 #1 (Debian))
	id 1Ihnnp-0001GY-OS
	for <netdev@vger.kernel.org>; Wed, 17 Oct 2007 00:53:50 +1000
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPSEC]: Get nexthdr from caller in xfrm6_rcv_spi

Currently xfrm6_rcv_spi gets the nexthdr value itself from the packet.
This means that we need to fix up the value in case we have a 4-on-6
tunnel.  Moving this logic into the caller simplifies things and allows
us to merge the code with IPv4.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/net/xfrm.h      |    2 +-
 net/ipv6/xfrm6_input.c  |    9 ++++-----
 net/ipv6/xfrm6_tunnel.c |    2 +-
 3 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 680739f..d8974ca 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1058,7 +1058,7 @@ static inline int xfrm4_rcv_spi(struct sk_buff *skb, int nexthdr, __be32 spi)
 extern int xfrm4_output(struct sk_buff *skb);
 extern int xfrm4_tunnel_register(struct xfrm_tunnel *handler, unsigned short family);
 extern int xfrm4_tunnel_deregister(struct xfrm_tunnel *handler, unsigned short family);
-extern int xfrm6_rcv_spi(struct sk_buff *skb, __be32 spi);
+extern int xfrm6_rcv_spi(struct sk_buff *skb, int nexthdr, __be32 spi);
 extern int xfrm6_rcv(struct sk_buff *skb);
 extern int xfrm6_input_addr(struct sk_buff *skb, xfrm_address_t *daddr,
 			    xfrm_address_t *saddr, u8 proto);
diff --git a/net/ipv6/xfrm6_input.c b/net/ipv6/xfrm6_input.c
index 02f69e5..596a730 100644
--- a/net/ipv6/xfrm6_input.c
+++ b/net/ipv6/xfrm6_input.c
@@ -16,7 +16,7 @@
 #include <net/ipv6.h>
 #include <net/xfrm.h>
 
-int xfrm6_rcv_spi(struct sk_buff *skb, __be32 spi)
+int xfrm6_rcv_spi(struct sk_buff *skb, int nexthdr, __be32 spi)
 {
 	int err;
 	__be32 seq;
@@ -24,11 +24,9 @@ int xfrm6_rcv_spi(struct sk_buff *skb, __be32 spi)
 	struct xfrm_state *x;
 	int xfrm_nr = 0;
 	int decaps = 0;
-	int nexthdr;
 	unsigned int nhoff;
 
 	nhoff = IP6CB(skb)->nhoff;
-	nexthdr = skb_network_header(skb)[nhoff];
 
 	seq = 0;
 	if (!spi && (err = xfrm_parse_spi(skb, nexthdr, &spi, &seq)) != 0)
@@ -41,7 +39,7 @@ int xfrm6_rcv_spi(struct sk_buff *skb, __be32 spi)
 			goto drop;
 
 		x = xfrm_state_lookup((xfrm_address_t *)&iph->daddr, spi,
-				nexthdr != IPPROTO_IPIP ? nexthdr : IPPROTO_IPV6, AF_INET6);
+				      nexthdr, AF_INET6);
 		if (x == NULL)
 			goto drop;
 		spin_lock(&x->lock);
@@ -135,7 +133,8 @@ EXPORT_SYMBOL(xfrm6_rcv_spi);
 
 int xfrm6_rcv(struct sk_buff *skb)
 {
-	return xfrm6_rcv_spi(skb, 0);
+	return xfrm6_rcv_spi(skb, skb_network_header(skb)[IP6CB(skb)->nhoff],
+			     0);
 }
 
 EXPORT_SYMBOL(xfrm6_rcv);
diff --git a/net/ipv6/xfrm6_tunnel.c b/net/ipv6/xfrm6_tunnel.c
index 6c67ac1..fae90ff 100644
--- a/net/ipv6/xfrm6_tunnel.c
+++ b/net/ipv6/xfrm6_tunnel.c
@@ -257,7 +257,7 @@ static int xfrm6_tunnel_rcv(struct sk_buff *skb)
 	__be32 spi;
 
 	spi = xfrm6_tunnel_spi_lookup((xfrm_address_t *)&iph->saddr);
-	return xfrm6_rcv_spi(skb, spi) > 0 ? : 0;
+	return xfrm6_rcv_spi(skb, IPPROTO_IPV6, spi) > 0 ? : 0;
 }
 
 static int xfrm6_tunnel_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
