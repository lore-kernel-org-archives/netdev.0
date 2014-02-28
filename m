From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH RFC 04/12] ah6: Use the IPsec protocol multiplexer API
Date: Fri, 28 Feb 2014 11:31:14 +0100
Message-ID: <1393583483-12480-5-git-send-email-steffen.klassert@secunet.com>
References: <1393583483-12480-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	Christophe Gouault <christophe.gouault@6wind.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:48998 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751463AbaB1Kbj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Feb 2014 05:31:39 -0500
In-Reply-To: <1393583483-12480-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Switch ah6 to use the new IPsec protocol multiplexer.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv6/ah6.c |   22 +++++++++++++++-------
 1 file changed, 15 insertions(+), 7 deletions(-)

diff --git a/net/ipv6/ah6.c b/net/ipv6/ah6.c
index 6c5f094..f35911e 100644
--- a/net/ipv6/ah6.c
+++ b/net/ipv6/ah6.c
@@ -643,7 +643,7 @@ out:
 	return err;
 }
 
-static void ah6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
+static int ah6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 		    u8 type, u8 code, int offset, __be32 info)
 {
 	struct net *net = dev_net(skb->dev);
@@ -653,17 +653,19 @@ static void ah6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 
 	if (type != ICMPV6_PKT_TOOBIG &&
 	    type != NDISC_REDIRECT)
-		return;
+		return 0;
 
 	x = xfrm_state_lookup(net, skb->mark, (xfrm_address_t *)&iph->daddr, ah->spi, IPPROTO_AH, AF_INET6);
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
 
 static int ah6_init_state(struct xfrm_state *x)
@@ -748,6 +750,11 @@ static void ah6_destroy(struct xfrm_state *x)
 	kfree(ahp);
 }
 
+static int ah6_rcv_cb(struct sk_buff *skb, int err)
+{
+	return 0;
+}
+
 static const struct xfrm_type ah6_type =
 {
 	.description	= "AH6",
@@ -761,10 +768,11 @@ static const struct xfrm_type ah6_type =
 	.hdr_offset	= xfrm6_find_1stfragopt,
 };
 
-static const struct inet6_protocol ah6_protocol = {
+static struct xfrm6_protocol ah6_protocol = {
 	.handler	=	xfrm6_rcv,
+	.cb_handler	=	ah6_rcv_cb,
 	.err_handler	=	ah6_err,
-	.flags		=	INET6_PROTO_NOPOLICY,
+	.priority	=	0,
 };
 
 static int __init ah6_init(void)
@@ -774,7 +782,7 @@ static int __init ah6_init(void)
 		return -EAGAIN;
 	}
 
-	if (inet6_add_protocol(&ah6_protocol, IPPROTO_AH) < 0) {
+	if (xfrm6_protocol_register(&ah6_protocol, IPPROTO_AH) < 0) {
 		pr_info("%s: can't add protocol\n", __func__);
 		xfrm_unregister_type(&ah6_type, AF_INET6);
 		return -EAGAIN;
@@ -785,7 +793,7 @@ static int __init ah6_init(void)
 
 static void __exit ah6_fini(void)
 {
-	if (inet6_del_protocol(&ah6_protocol, IPPROTO_AH) < 0)
+	if (xfrm6_protocol_deregister(&ah6_protocol, IPPROTO_AH) < 0)
 		pr_info("%s: can't remove protocol\n", __func__);
 
 	if (xfrm_unregister_type(&ah6_type, AF_INET6) < 0)
-- 
1.7.9.5
