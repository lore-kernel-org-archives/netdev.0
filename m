From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH RFC v3 03/12] ah4: Use the IPsec protocol multiplexer API
Date: Mon, 27 Jan 2014 11:29:28 +0100
Message-ID: <1390818577-19589-4-git-send-email-steffen.klassert@secunet.com>
References: <1390818577-19589-1-git-send-email-steffen.klassert@secunet.com>
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	Christophe Gouault <christophe.gouault@6wind.com>,
	Saurabh Mohan <saurabh.mohan@vyatta.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:43161 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753766AbaA0KaI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jan 2014 05:30:08 -0500
In-Reply-To: <1390818577-19589-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Switch ah4 to use the new IPsec protocol multiplexer.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/ah4.c |   24 +++++++++++++++---------
 1 file changed, 15 insertions(+), 9 deletions(-)

diff --git a/net/ipv4/ah4.c b/net/ipv4/ah4.c
index 7179026..ea30e4e 100644
--- a/net/ipv4/ah4.c
+++ b/net/ipv4/ah4.c
@@ -397,7 +397,7 @@ out:
 	return err;
 }
 
-static void ah4_err(struct sk_buff *skb, u32 info)
+static int ah4_err(struct sk_buff *skb, u32 info)
 {
 	struct net *net = dev_net(skb->dev);
 	const struct iphdr *iph = (const struct iphdr *)skb->data;
@@ -407,23 +407,25 @@ static void ah4_err(struct sk_buff *skb, u32 info)
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
 
 	x = xfrm_state_lookup(net, skb->mark, (const xfrm_address_t *)&iph->daddr,
 			      ah->spi, IPPROTO_AH, AF_INET);
 	if (!x)
-		return;
+		return 0;
 
 	if (icmp_hdr(skb)->type == ICMP_DEST_UNREACH)
 		ipv4_update_pmtu(skb, net, info, 0, 0, IPPROTO_AH, 0);
 	else
 		ipv4_redirect(skb, net, 0, 0, IPPROTO_AH, 0);
 	xfrm_state_put(x);
+
+	return 0;
 }
 
 static int ah_init_state(struct xfrm_state *x)
@@ -505,6 +507,10 @@ static void ah_destroy(struct xfrm_state *x)
 	kfree(ahp);
 }
 
+static int ah4_rcv_cb(struct sk_buff *skb, int err)
+{
+	return 0;
+}
 
 static const struct xfrm_type ah_type =
 {
@@ -518,11 +524,11 @@ static const struct xfrm_type ah_type =
 	.output		= ah_output
 };
 
-static const struct net_protocol ah4_protocol = {
+static struct xfrm4_protocol ah4_protocol = {
 	.handler	=	xfrm4_rcv,
+	.cb_handler	=	ah4_rcv_cb,
 	.err_handler	=	ah4_err,
-	.no_policy	=	1,
-	.netns_ok	=	1,
+	.priority	=	0,
 };
 
 static int __init ah4_init(void)
@@ -531,7 +537,7 @@ static int __init ah4_init(void)
 		pr_info("%s: can't add xfrm type\n", __func__);
 		return -EAGAIN;
 	}
-	if (inet_add_protocol(&ah4_protocol, IPPROTO_AH) < 0) {
+	if (xfrm4_protocol_register(&ah4_protocol, IPPROTO_AH) < 0) {
 		pr_info("%s: can't add protocol\n", __func__);
 		xfrm_unregister_type(&ah_type, AF_INET);
 		return -EAGAIN;
@@ -541,7 +547,7 @@ static int __init ah4_init(void)
 
 static void __exit ah4_fini(void)
 {
-	if (inet_del_protocol(&ah4_protocol, IPPROTO_AH) < 0)
+	if (xfrm4_protocol_deregister(&ah4_protocol, IPPROTO_AH) < 0)
 		pr_info("%s: can't remove protocol\n", __func__);
 	if (xfrm_unregister_type(&ah_type, AF_INET) < 0)
 		pr_info("%s: can't remove xfrm type\n", __func__);
-- 
1.7.9.5
