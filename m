From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 2/12] [IPSEC]: Move tunnel parsing for IPv4 out of xfrm4_input
Date: Tue, 16 Oct 2007 22:33:10 +0800
Message-ID: <E1IhnTq-0003GL-00@gondolin.me.apana.org.au>
References: <20071016141843.GA11956@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3012 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933115AbXJPOxx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2007 10:53:53 -0400
Received: from gondolin.me.apana.org.au ([192.168.0.6] ident=mail)
	by arnor.apana.org.au with esmtp (Exim 4.50 #1 (Debian))
	id 1Ihnnq-0001GY-D8
	for <netdev@vger.kernel.org>; Wed, 17 Oct 2007 00:53:50 +1000
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPSEC]: Move tunnel parsing for IPv4 out of xfrm4_input

This patch moves the tunnel parsing for IPv4 out of xfrm4_input and into
xfrm4_tunnel.  This change is in line with what IPv6 does and will allow
us to merge the two input functions.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/net/xfrm.h      |    8 ++++++++
 net/ipv4/xfrm4_input.c  |   36 +++++++++++-------------------------
 net/ipv4/xfrm4_tunnel.c |    9 +++++++--
 3 files changed, 26 insertions(+), 27 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 0e84484..680739f 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1046,7 +1046,15 @@ extern void xfrm_replay_notify(struct xfrm_state *x, int event);
 extern int xfrm_state_mtu(struct xfrm_state *x, int mtu);
 extern int xfrm_init_state(struct xfrm_state *x);
 extern int xfrm_output(struct sk_buff *skb);
+extern int xfrm4_rcv_encap(struct sk_buff *skb, int nexthdr, __be32 spi,
+			   int encap_type);
 extern int xfrm4_rcv(struct sk_buff *skb);
+
+static inline int xfrm4_rcv_spi(struct sk_buff *skb, int nexthdr, __be32 spi)
+{
+	return xfrm4_rcv_encap(skb, nexthdr, spi, 0);
+}
+
 extern int xfrm4_output(struct sk_buff *skb);
 extern int xfrm4_tunnel_register(struct xfrm_tunnel *handler, unsigned short family);
 extern int xfrm4_tunnel_deregister(struct xfrm_tunnel *handler, unsigned short family);
diff --git a/net/ipv4/xfrm4_input.c b/net/ipv4/xfrm4_input.c
index e9bbfde..5cb0b59 100644
--- a/net/ipv4/xfrm4_input.c
+++ b/net/ipv4/xfrm4_input.c
@@ -16,19 +16,6 @@
 #include <net/ip.h>
 #include <net/xfrm.h>
 
-static int xfrm4_parse_spi(struct sk_buff *skb, u8 nexthdr, __be32 *spi, __be32 *seq)
-{
-	switch (nexthdr) {
-	case IPPROTO_IPIP:
-	case IPPROTO_IPV6:
-		*spi = ip_hdr(skb)->saddr;
-		*seq = 0;
-		return 0;
-	}
-
-	return xfrm_parse_spi(skb, nexthdr, spi, seq);
-}
-
 #ifdef CONFIG_NETFILTER
 static inline int xfrm4_rcv_encap_finish(struct sk_buff *skb)
 {
@@ -46,28 +33,29 @@ drop:
 }
 #endif
 
-static int xfrm4_rcv_encap(struct sk_buff *skb, __u16 encap_type)
+int xfrm4_rcv_encap(struct sk_buff *skb, int nexthdr, __be32 spi,
+		    int encap_type)
 {
-	__be32 spi, seq;
+	int err;
+	__be32 seq;
 	struct xfrm_state *xfrm_vec[XFRM_MAX_DEPTH];
 	struct xfrm_state *x;
 	int xfrm_nr = 0;
 	int decaps = 0;
-	int err = xfrm4_parse_spi(skb, ip_hdr(skb)->protocol, &spi, &seq);
 	unsigned int nhoff = offsetof(struct iphdr, protocol);
 
-	if (err != 0)
+	seq = 0;
+	if (!spi && (err = xfrm_parse_spi(skb, nexthdr, &spi, &seq)) != 0)
 		goto drop;
 
 	do {
 		const struct iphdr *iph = ip_hdr(skb);
-		int nexthdr;
 
 		if (xfrm_nr == XFRM_MAX_DEPTH)
 			goto drop;
 
 		x = xfrm_state_lookup((xfrm_address_t *)&iph->daddr, spi,
-				iph->protocol != IPPROTO_IPV6 ? iph->protocol : IPPROTO_IPIP, AF_INET);
+				      nexthdr, AF_INET);
 		if (x == NULL)
 			goto drop;
 
@@ -111,7 +99,7 @@ static int xfrm4_rcv_encap(struct sk_buff *skb, __u16 encap_type)
 			break;
 		}
 
-		err = xfrm_parse_spi(skb, ip_hdr(skb)->protocol, &spi, &seq);
+		err = xfrm_parse_spi(skb, nexthdr, &spi, &seq);
 		if (err < 0)
 			goto drop;
 	} while (!err);
@@ -165,6 +153,7 @@ drop:
 	kfree_skb(skb);
 	return 0;
 }
+EXPORT_SYMBOL(xfrm4_rcv_encap);
 
 /* If it's a keepalive packet, then just eat it.
  * If it's an encapsulated packet, then pass it to the
@@ -252,11 +241,8 @@ int xfrm4_udp_encap_rcv(struct sock *sk, struct sk_buff *skb)
 	__skb_pull(skb, len);
 	skb_reset_transport_header(skb);
 
-	/* modify the protocol (it's ESP!) */
-	iph->protocol = IPPROTO_ESP;
-
 	/* process ESP */
-	ret = xfrm4_rcv_encap(skb, encap_type);
+	ret = xfrm4_rcv_encap(skb, IPPROTO_ESP, 0, encap_type);
 	return ret;
 
 drop:
@@ -266,7 +252,7 @@ drop:
 
 int xfrm4_rcv(struct sk_buff *skb)
 {
-	return xfrm4_rcv_encap(skb, 0);
+	return xfrm4_rcv_spi(skb, ip_hdr(skb)->protocol, 0);
 }
 
 EXPORT_SYMBOL(xfrm4_rcv);
diff --git a/net/ipv4/xfrm4_tunnel.c b/net/ipv4/xfrm4_tunnel.c
index 83e9580..3268451 100644
--- a/net/ipv4/xfrm4_tunnel.c
+++ b/net/ipv4/xfrm4_tunnel.c
@@ -48,20 +48,25 @@ static struct xfrm_type ipip_type = {
 	.output		= ipip_output
 };
 
+static int xfrm_tunnel_rcv(struct sk_buff *skb)
+{
+	return xfrm4_rcv_spi(skb, IPPROTO_IP, ip_hdr(skb)->saddr);
+}
+
 static int xfrm_tunnel_err(struct sk_buff *skb, u32 info)
 {
 	return -ENOENT;
 }
 
 static struct xfrm_tunnel xfrm_tunnel_handler = {
-	.handler	=	xfrm4_rcv,
+	.handler	=	xfrm_tunnel_rcv,
 	.err_handler	=	xfrm_tunnel_err,
 	.priority	=	2,
 };
 
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 static struct xfrm_tunnel xfrm64_tunnel_handler = {
-	.handler	=	xfrm4_rcv,
+	.handler	=	xfrm_tunnel_rcv,
 	.err_handler	=	xfrm_tunnel_err,
 	.priority	=	2,
 };
