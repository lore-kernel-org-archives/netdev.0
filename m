From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH RFC v4 02/12] esp4: Use the IPsec protocol multiplexer API
Date: Fri, 14 Feb 2014 09:30:10 +0100
Message-ID: <1392366620-31923-3-git-send-email-steffen.klassert@secunet.com>
References: <1392366620-31923-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	Christophe Gouault <christophe.gouault@6wind.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:39107 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751775AbaBNIap (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Feb 2014 03:30:45 -0500
In-Reply-To: <1392366620-31923-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Switch esp4 to use the new IPsec protocol multiplexer.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/esp4.c |   26 +++++++++++++++++---------
 1 file changed, 17 insertions(+), 9 deletions(-)

diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index 7785b28..360b565 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -473,7 +473,7 @@ static u32 esp4_get_mtu(struct xfrm_state *x, int mtu)
 		 net_adj) & ~(blksize - 1)) + net_adj - 2;
 }
 
-static void esp4_err(struct sk_buff *skb, u32 info)
+static int esp4_err(struct sk_buff *skb, u32 info)
 {
 	struct net *net = dev_net(skb->dev);
 	const struct iphdr *iph = (const struct iphdr *)skb->data;
@@ -483,23 +483,25 @@ static void esp4_err(struct sk_buff *skb, u32 info)
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
 			      esph->spi, IPPROTO_ESP, AF_INET);
 	if (!x)
-		return;
+		return 0;
 
 	if (icmp_hdr(skb)->type == ICMP_DEST_UNREACH)
 		ipv4_update_pmtu(skb, net, info, 0, 0, IPPROTO_ESP, 0);
 	else
 		ipv4_redirect(skb, net, 0, 0, IPPROTO_ESP, 0);
 	xfrm_state_put(x);
+
+	return 0;
 }
 
 static void esp_destroy(struct xfrm_state *x)
@@ -672,6 +674,11 @@ error:
 	return err;
 }
 
+static int esp4_rcv_cb(struct sk_buff *skb, int err)
+{
+	return 0;
+}
+
 static const struct xfrm_type esp_type =
 {
 	.description	= "ESP4",
@@ -685,11 +692,12 @@ static const struct xfrm_type esp_type =
 	.output		= esp_output
 };
 
-static const struct net_protocol esp4_protocol = {
+static struct xfrm4_protocol esp4_protocol = {
 	.handler	=	xfrm4_rcv,
+	.input_handler	=	xfrm_input,
+	.cb_handler	=	esp4_rcv_cb,
 	.err_handler	=	esp4_err,
-	.no_policy	=	1,
-	.netns_ok	=	1,
+	.priority	=	0,
 };
 
 static int __init esp4_init(void)
@@ -698,7 +706,7 @@ static int __init esp4_init(void)
 		pr_info("%s: can't add xfrm type\n", __func__);
 		return -EAGAIN;
 	}
-	if (inet_add_protocol(&esp4_protocol, IPPROTO_ESP) < 0) {
+	if (xfrm4_protocol_register(&esp4_protocol, IPPROTO_ESP) < 0) {
 		pr_info("%s: can't add protocol\n", __func__);
 		xfrm_unregister_type(&esp_type, AF_INET);
 		return -EAGAIN;
@@ -708,7 +716,7 @@ static int __init esp4_init(void)
 
 static void __exit esp4_fini(void)
 {
-	if (inet_del_protocol(&esp4_protocol, IPPROTO_ESP) < 0)
+	if (xfrm4_protocol_deregister(&esp4_protocol, IPPROTO_ESP) < 0)
 		pr_info("%s: can't remove protocol\n", __func__);
 	if (xfrm_unregister_type(&esp_type, AF_INET) < 0)
 		pr_info("%s: can't remove xfrm type\n", __func__);
-- 
1.7.9.5
