From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 3/4] netns xfrm: ipcomp support
Date: Mon, 25 Jan 2010 22:38:34 +0200
Message-ID: <20100125203834.GB6145@x200>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.154]:44766 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752432Ab0AYUil (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jan 2010 15:38:41 -0500
Received: by fg-out-1718.google.com with SMTP id l26so1228472fgb.1
        for <netdev@vger.kernel.org>; Mon, 25 Jan 2010 12:38:40 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 net/ipv4/ipcomp.c |    9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

--- a/net/ipv4/ipcomp.c
+++ b/net/ipv4/ipcomp.c
@@ -25,6 +25,7 @@
 
 static void ipcomp4_err(struct sk_buff *skb, u32 info)
 {
+	struct net *net = dev_net(skb->dev);
 	__be32 spi;
 	struct iphdr *iph = (struct iphdr *)skb->data;
 	struct ip_comp_hdr *ipch = (struct ip_comp_hdr *)(skb->data+(iph->ihl<<2));
@@ -35,7 +36,7 @@ static void ipcomp4_err(struct sk_buff *skb, u32 info)
 		return;
 
 	spi = htonl(ntohs(ipch->cpi));
-	x = xfrm_state_lookup(&init_net, (xfrm_address_t *)&iph->daddr,
+	x = xfrm_state_lookup(net, (xfrm_address_t *)&iph->daddr,
 			      spi, IPPROTO_COMP, AF_INET);
 	if (!x)
 		return;
@@ -47,9 +48,10 @@ static void ipcomp4_err(struct sk_buff *skb, u32 info)
 /* We always hold one tunnel user reference to indicate a tunnel */
 static struct xfrm_state *ipcomp_tunnel_create(struct xfrm_state *x)
 {
+	struct net *net = xs_net(x);
 	struct xfrm_state *t;
 
-	t = xfrm_state_alloc(&init_net);
+	t = xfrm_state_alloc(net);
 	if (t == NULL)
 		goto out;
 
@@ -82,10 +84,11 @@ error:
  */
 static int ipcomp_tunnel_attach(struct xfrm_state *x)
 {
+	struct net *net = xs_net(x);
 	int err = 0;
 	struct xfrm_state *t;
 
-	t = xfrm_state_lookup(&init_net, (xfrm_address_t *)&x->id.daddr.a4,
+	t = xfrm_state_lookup(net, (xfrm_address_t *)&x->id.daddr.a4,
 			      x->props.saddr.a4, IPPROTO_IPIP, AF_INET);
 	if (!t) {
 		t = ipcomp_tunnel_create(x);
