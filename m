From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 04/13] esp6: Use the IPsec protocol multiplexer API
Date: Tue, 18 Mar 2014 08:21:29 +0100
Message-ID: <1395127298-24083-5-git-send-email-steffen.klassert@secunet.com>
References: <1395127298-24083-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:53252 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752659AbaCRHVw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Mar 2014 03:21:52 -0400
In-Reply-To: <1395127298-24083-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Switch esp6 to use the new IPsec protocol multiplexer.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv6/esp6.c |   26 +++++++++++++++++---------
 1 file changed, 17 insertions(+), 9 deletions(-)

diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index 6eef8a7..d15da13 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -421,8 +421,8 @@ static u32 esp6_get_mtu(struct xfrm_state *x, int mtu)
 		 net_adj) & ~(blksize - 1)) + net_adj - 2;
 }
 
-static void esp6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
-		     u8 type, u8 code, int offset, __be32 info)
+static int esp6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
+		    u8 type, u8 code, int offset, __be32 info)
 {
 	struct net *net = dev_net(skb->dev);
 	const struct ipv6hdr *iph = (const struct ipv6hdr *)skb->data;
@@ -431,18 +431,20 @@ static void esp6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 
 	if (type != ICMPV6_PKT_TOOBIG &&
 	    type != NDISC_REDIRECT)
-		return;
+		return 0;
 
 	x = xfrm_state_lookup(net, skb->mark, (const xfrm_address_t *)&iph->daddr,
 			      esph->spi, IPPROTO_ESP, AF_INET6);
 	if (!x)
-		return;
+		return 0;
 
 	if (type == NDISC_REDIRECT)
 		ip6_redirect(skb, net, skb->dev->ifindex, 0);
 	else
 		ip6_update_pmtu(skb, net, info, 0, 0);
 	xfrm_state_put(x);
+
+	return 0;
 }
 
 static void esp6_destroy(struct xfrm_state *x)
@@ -614,6 +616,11 @@ error:
 	return err;
 }
 
+static int esp6_rcv_cb(struct sk_buff *skb, int err)
+{
+	return 0;
+}
+
 static const struct xfrm_type esp6_type =
 {
 	.description	= "ESP6",
@@ -628,10 +635,11 @@ static const struct xfrm_type esp6_type =
 	.hdr_offset	= xfrm6_find_1stfragopt,
 };
 
-static const struct inet6_protocol esp6_protocol = {
-	.handler 	=	xfrm6_rcv,
+static struct xfrm6_protocol esp6_protocol = {
+	.handler	=	xfrm6_rcv,
+	.cb_handler	=	esp6_rcv_cb,
 	.err_handler	=	esp6_err,
-	.flags		=	INET6_PROTO_NOPOLICY,
+	.priority	=	0,
 };
 
 static int __init esp6_init(void)
@@ -640,7 +648,7 @@ static int __init esp6_init(void)
 		pr_info("%s: can't add xfrm type\n", __func__);
 		return -EAGAIN;
 	}
-	if (inet6_add_protocol(&esp6_protocol, IPPROTO_ESP) < 0) {
+	if (xfrm6_protocol_register(&esp6_protocol, IPPROTO_ESP) < 0) {
 		pr_info("%s: can't add protocol\n", __func__);
 		xfrm_unregister_type(&esp6_type, AF_INET6);
 		return -EAGAIN;
@@ -651,7 +659,7 @@ static int __init esp6_init(void)
 
 static void __exit esp6_fini(void)
 {
-	if (inet6_del_protocol(&esp6_protocol, IPPROTO_ESP) < 0)
+	if (xfrm6_protocol_deregister(&esp6_protocol, IPPROTO_ESP) < 0)
 		pr_info("%s: can't remove protocol\n", __func__);
 	if (xfrm_unregister_type(&esp6_type, AF_INET6) < 0)
 		pr_info("%s: can't remove xfrm type\n", __func__);
-- 
1.7.9.5
