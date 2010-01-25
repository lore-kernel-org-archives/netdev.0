From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 4/4] netns xfrm: ipcomp6 support
Date: Mon, 25 Jan 2010 22:39:09 +0200
Message-ID: <20100125203909.GC6145@x200>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f220.google.com ([209.85.220.220]:49513 "EHLO
	mail-fx0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751852Ab0AYUjQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jan 2010 15:39:16 -0500
Received: by fxm20 with SMTP id 20so4007778fxm.21
        for <netdev@vger.kernel.org>; Mon, 25 Jan 2010 12:39:14 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 net/ipv6/ipcomp6.c |   13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

--- a/net/ipv6/ipcomp6.c
+++ b/net/ipv6/ipcomp6.c
@@ -53,6 +53,7 @@
 static void ipcomp6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 				u8 type, u8 code, int offset, __be32 info)
 {
+	struct net *net = dev_net(skb->dev);
 	__be32 spi;
 	struct ipv6hdr *iph = (struct ipv6hdr*)skb->data;
 	struct ip_comp_hdr *ipcomph =
@@ -63,7 +64,7 @@ static void ipcomp6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 		return;
 
 	spi = htonl(ntohs(ipcomph->cpi));
-	x = xfrm_state_lookup(&init_net, (xfrm_address_t *)&iph->daddr, spi, IPPROTO_COMP, AF_INET6);
+	x = xfrm_state_lookup(net, (xfrm_address_t *)&iph->daddr, spi, IPPROTO_COMP, AF_INET6);
 	if (!x)
 		return;
 
@@ -74,14 +75,15 @@ static void ipcomp6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 
 static struct xfrm_state *ipcomp6_tunnel_create(struct xfrm_state *x)
 {
+	struct net *net = xs_net(x);
 	struct xfrm_state *t = NULL;
 
-	t = xfrm_state_alloc(&init_net);
+	t = xfrm_state_alloc(net);
 	if (!t)
 		goto out;
 
 	t->id.proto = IPPROTO_IPV6;
-	t->id.spi = xfrm6_tunnel_alloc_spi(&init_net, (xfrm_address_t *)&x->props.saddr);
+	t->id.spi = xfrm6_tunnel_alloc_spi(net, (xfrm_address_t *)&x->props.saddr);
 	if (!t->id.spi)
 		goto error;
 
@@ -108,13 +110,14 @@ error:
 
 static int ipcomp6_tunnel_attach(struct xfrm_state *x)
 {
+	struct net *net = xs_net(x);
 	int err = 0;
 	struct xfrm_state *t = NULL;
 	__be32 spi;
 
-	spi = xfrm6_tunnel_spi_lookup(&init_net, (xfrm_address_t *)&x->props.saddr);
+	spi = xfrm6_tunnel_spi_lookup(net, (xfrm_address_t *)&x->props.saddr);
 	if (spi)
-		t = xfrm_state_lookup(&init_net, (xfrm_address_t *)&x->id.daddr,
+		t = xfrm_state_lookup(net, (xfrm_address_t *)&x->id.daddr,
 					      spi, IPPROTO_IPV6, AF_INET6);
 	if (!t) {
 		t = ipcomp6_tunnel_create(x);
