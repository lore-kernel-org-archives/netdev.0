From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH RFC v3 04/12] ipcomp4: Use the IPsec protocol multiplexer API
Date: Mon, 27 Jan 2014 11:29:29 +0100
Message-ID: <1390818577-19589-5-git-send-email-steffen.klassert@secunet.com>
References: <1390818577-19589-1-git-send-email-steffen.klassert@secunet.com>
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	Christophe Gouault <christophe.gouault@6wind.com>,
	Saurabh Mohan <saurabh.mohan@vyatta.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:43166 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753821AbaA0KaJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jan 2014 05:30:09 -0500
In-Reply-To: <1390818577-19589-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Switch ipcomp4 to use the new IPsec protocol multiplexer.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/ipcomp.c |   25 ++++++++++++++++---------
 1 file changed, 16 insertions(+), 9 deletions(-)

diff --git a/net/ipv4/ipcomp.c b/net/ipv4/ipcomp.c
index 826be4c..6135ff8 100644
--- a/net/ipv4/ipcomp.c
+++ b/net/ipv4/ipcomp.c
@@ -23,7 +23,7 @@
 #include <net/protocol.h>
 #include <net/sock.h>
 
-static void ipcomp4_err(struct sk_buff *skb, u32 info)
+static int ipcomp4_err(struct sk_buff *skb, u32 info)
 {
 	struct net *net = dev_net(skb->dev);
 	__be32 spi;
@@ -34,24 +34,26 @@ static void ipcomp4_err(struct sk_buff *skb, u32 info)
 	switch (icmp_hdr(skb)->type) {
 	case ICMP_DEST_UNREACH:
 		if (icmp_hdr(skb)->code != ICMP_FRAG_NEEDED)
-			return;
+			return 0;
 	case ICMP_REDIRECT:
 		break;
 	default:
-		return;
+		return 0;
 	}
 
 	spi = htonl(ntohs(ipch->cpi));
 	x = xfrm_state_lookup(net, skb->mark, (const xfrm_address_t *)&iph->daddr,
 			      spi, IPPROTO_COMP, AF_INET);
 	if (!x)
-		return;
+		return 0;
 
 	if (icmp_hdr(skb)->type == ICMP_DEST_UNREACH)
 		ipv4_update_pmtu(skb, net, info, 0, 0, IPPROTO_COMP, 0);
 	else
 		ipv4_redirect(skb, net, 0, 0, IPPROTO_COMP, 0);
 	xfrm_state_put(x);
+
+	return 0;
 }
 
 /* We always hold one tunnel user reference to indicate a tunnel */
@@ -147,6 +149,11 @@ out:
 	return err;
 }
 
+static int ipcomp4_rcv_cb(struct sk_buff *skb, int err)
+{
+	return 0;
+}
+
 static const struct xfrm_type ipcomp_type = {
 	.description	= "IPCOMP4",
 	.owner		= THIS_MODULE,
@@ -157,11 +164,11 @@ static const struct xfrm_type ipcomp_type = {
 	.output		= ipcomp_output
 };
 
-static const struct net_protocol ipcomp4_protocol = {
+static struct xfrm4_protocol ipcomp4_protocol = {
 	.handler	=	xfrm4_rcv,
+	.cb_handler	=	ipcomp4_rcv_cb,
 	.err_handler	=	ipcomp4_err,
-	.no_policy	=	1,
-	.netns_ok	=	1,
+	.priority	=	0,
 };
 
 static int __init ipcomp4_init(void)
@@ -170,7 +177,7 @@ static int __init ipcomp4_init(void)
 		pr_info("%s: can't add xfrm type\n", __func__);
 		return -EAGAIN;
 	}
-	if (inet_add_protocol(&ipcomp4_protocol, IPPROTO_COMP) < 0) {
+	if (xfrm4_protocol_register(&ipcomp4_protocol, IPPROTO_COMP) < 0) {
 		pr_info("%s: can't add protocol\n", __func__);
 		xfrm_unregister_type(&ipcomp_type, AF_INET);
 		return -EAGAIN;
@@ -180,7 +187,7 @@ static int __init ipcomp4_init(void)
 
 static void __exit ipcomp4_fini(void)
 {
-	if (inet_del_protocol(&ipcomp4_protocol, IPPROTO_COMP) < 0)
+	if (xfrm4_protocol_deregister(&ipcomp4_protocol, IPPROTO_COMP) < 0)
 		pr_info("%s: can't remove protocol\n", __func__);
 	if (xfrm_unregister_type(&ipcomp_type, AF_INET) < 0)
 		pr_info("%s: can't remove xfrm type\n", __func__);
-- 
1.7.9.5
