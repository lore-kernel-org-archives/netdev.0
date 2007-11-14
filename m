From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] [IPSEC]: Add async resume support on input
Date: Wed, 14 Nov 2007 01:58:12 -0800 (PST)
Message-ID: <20071114.015812.77787863.davem@davemloft.net>
References: <20071114062834.GB11173@gondor.apana.org.au>
	<20071113.223356.216207937.davem@davemloft.net>
	<20071114063657.GA11293@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36747
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750925AbXKNJ6N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 04:58:13 -0500
In-Reply-To: <20071114063657.GA11293@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 14 Nov 2007 14:36:58 +0800

> On Tue, Nov 13, 2007 at 10:33:56PM -0800, David Miller wrote:
> >
> > Also applied to net-2.6.25, thanks.
> > 
> > I'll work on integrating Patrick's NF_INET_* patch next.
> 
> Thanks! With that you would be able to remove the nf_post_routing
> field from xfrm_state_afinfo.

Done, and checked into net-2.6.25:

>From d15f51674f6e9985c84f221a7fd1026eafbe42c8 Mon Sep 17 00:00:00 2001
From: David S. Miller <davem@sunset.davemloft.net>
Date: Wed, 14 Nov 2007 01:57:47 -0800
Subject: [PATCH] [IPSEC]: Kill afinfo->nf_post_routing

After changeset:

	[NETFILTER]: Introduce NF_INET_ hook values

It always evaluates to NF_INET_POST_ROUTING.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/xfrm.h     |    1 -
 net/ipv4/xfrm4_state.c |    1 -
 net/ipv6/xfrm6_state.c |    1 -
 net/xfrm/xfrm_output.c |    2 +-
 4 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index e184c11..99251b7 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -259,7 +259,6 @@ struct xfrm_state_afinfo {
 	unsigned int		family;
 	unsigned int		proto;
 	unsigned int		eth_proto;
-	unsigned int		nf_post_routing;
 	struct module		*owner;
 	struct xfrm_type	*type_map[IPPROTO_MAX];
 	struct xfrm_mode	*mode_map[XFRM_MODE_MAX];
diff --git a/net/ipv4/xfrm4_state.c b/net/ipv4/xfrm4_state.c
index 2961135..fdeebe6 100644
--- a/net/ipv4/xfrm4_state.c
+++ b/net/ipv4/xfrm4_state.c
@@ -66,7 +66,6 @@ static struct xfrm_state_afinfo xfrm4_state_afinfo = {
 	.family			= AF_INET,
 	.proto			= IPPROTO_IPIP,
 	.eth_proto		= htons(ETH_P_IP),
-	.nf_post_routing	= NF_INET_POST_ROUTING,
 	.owner			= THIS_MODULE,
 	.init_flags		= xfrm4_init_flags,
 	.init_tempsel		= __xfrm4_init_tempsel,
diff --git a/net/ipv6/xfrm6_state.c b/net/ipv6/xfrm6_state.c
index 29e0d25..a7a7e8f 100644
--- a/net/ipv6/xfrm6_state.c
+++ b/net/ipv6/xfrm6_state.c
@@ -188,7 +188,6 @@ static struct xfrm_state_afinfo xfrm6_state_afinfo = {
 	.family			= AF_INET6,
 	.proto			= IPPROTO_IPV6,
 	.eth_proto		= htons(ETH_P_IPV6),
-	.nf_post_routing	= NF_INET_POST_ROUTING,
 	.owner			= THIS_MODULE,
 	.init_tempsel		= __xfrm6_init_tempsel,
 	.tmpl_sort		= __xfrm6_tmpl_sort,
diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
index 048d240..3c277a4 100644
--- a/net/xfrm/xfrm_output.c
+++ b/net/xfrm/xfrm_output.c
@@ -113,7 +113,7 @@ int xfrm_output_resume(struct sk_buff *skb, int err)
 			return dst_output(skb);
 
 		err = nf_hook(x->inner_mode->afinfo->family,
-			      x->inner_mode->afinfo->nf_post_routing, skb,
+			      NF_INET_POST_ROUTING, skb,
 			      NULL, skb->dst->dev, xfrm_output2);
 		if (unlikely(err != 1))
 			goto out;
-- 
1.5.3.5

