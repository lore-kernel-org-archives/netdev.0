From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 06/13] ipcomp6: Use the IPsec protocol multiplexer API
Date: Tue, 18 Mar 2014 08:21:31 +0100
Message-ID: <1395127298-24083-7-git-send-email-steffen.klassert@secunet.com>
References: <1395127298-24083-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:53270 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753461AbaCRHVz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Mar 2014 03:21:55 -0400
In-Reply-To: <1395127298-24083-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Switch ipcomp6 to use the new IPsec protocol multiplexer.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv6/ipcomp6.c |   22 +++++++++++++++-------
 1 file changed, 15 insertions(+), 7 deletions(-)

diff --git a/net/ipv6/ipcomp6.c b/net/ipv6/ipcomp6.c
index da9becb..d1c793c 100644
--- a/net/ipv6/ipcomp6.c
+++ b/net/ipv6/ipcomp6.c
@@ -53,7 +53,7 @@
 #include <linux/icmpv6.h>
 #include <linux/mutex.h>
 
-static void ipcomp6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
+static int ipcomp6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 				u8 type, u8 code, int offset, __be32 info)
 {
 	struct net *net = dev_net(skb->dev);
@@ -65,19 +65,21 @@ static void ipcomp6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 
 	if (type != ICMPV6_PKT_TOOBIG &&
 	    type != NDISC_REDIRECT)
-		return;
+		return 0;
 
 	spi = htonl(ntohs(ipcomph->cpi));
 	x = xfrm_state_lookup(net, skb->mark, (const xfrm_address_t *)&iph->daddr,
 			      spi, IPPROTO_COMP, AF_INET6);
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
 
 static struct xfrm_state *ipcomp6_tunnel_create(struct xfrm_state *x)
@@ -174,6 +176,11 @@ out:
 	return err;
 }
 
+static int ipcomp6_rcv_cb(struct sk_buff *skb, int err)
+{
+	return 0;
+}
+
 static const struct xfrm_type ipcomp6_type =
 {
 	.description	= "IPCOMP6",
@@ -186,11 +193,12 @@ static const struct xfrm_type ipcomp6_type =
 	.hdr_offset	= xfrm6_find_1stfragopt,
 };
 
-static const struct inet6_protocol ipcomp6_protocol =
+static struct xfrm6_protocol ipcomp6_protocol =
 {
 	.handler	= xfrm6_rcv,
+	.cb_handler	= ipcomp6_rcv_cb,
 	.err_handler	= ipcomp6_err,
-	.flags		= INET6_PROTO_NOPOLICY,
+	.priority	= 0,
 };
 
 static int __init ipcomp6_init(void)
@@ -199,7 +207,7 @@ static int __init ipcomp6_init(void)
 		pr_info("%s: can't add xfrm type\n", __func__);
 		return -EAGAIN;
 	}
-	if (inet6_add_protocol(&ipcomp6_protocol, IPPROTO_COMP) < 0) {
+	if (xfrm6_protocol_register(&ipcomp6_protocol, IPPROTO_COMP) < 0) {
 		pr_info("%s: can't add protocol\n", __func__);
 		xfrm_unregister_type(&ipcomp6_type, AF_INET6);
 		return -EAGAIN;
@@ -209,7 +217,7 @@ static int __init ipcomp6_init(void)
 
 static void __exit ipcomp6_fini(void)
 {
-	if (inet6_del_protocol(&ipcomp6_protocol, IPPROTO_COMP) < 0)
+	if (xfrm6_protocol_deregister(&ipcomp6_protocol, IPPROTO_COMP) < 0)
 		pr_info("%s: can't remove protocol\n", __func__);
 	if (xfrm_unregister_type(&ipcomp6_type, AF_INET6) < 0)
 		pr_info("%s: can't remove xfrm type\n", __func__);
-- 
1.7.9.5
