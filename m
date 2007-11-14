From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] [IPSEC]: Add async resume support on input
Date: Tue, 13 Nov 2007 22:46:23 -0800 (PST)
Message-ID: <20071113.224623.135876712.davem@davemloft.net>
References: <20071114063657.GA11293@gondor.apana.org.au>
	<20071113.223803.40309642.davem@davemloft.net>
	<20071114064154.GA11367@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45867
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755679AbXKNGqZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 01:46:25 -0500
In-Reply-To: <20071114064154.GA11367@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 14 Nov 2007 14:41:54 +0800

> On Tue, Nov 13, 2007 at 10:38:03PM -0800, David Miller wrote:
> > 
> > We need to fix something else up first :-)
> > 
> > net/ipv4/xfrm4_input.c: In function 'xfrm4_transport_finish':
> > net/ipv4/xfrm4_input.c:65: error: implicit declaration of function 'xfrm4_rcv_encap_finish'
> > net/ipv4/xfrm4_input.c:67: error: 'nexthdr' undeclared (first use in this function)
> > net/ipv4/xfrm4_input.c:67: error: (Each undeclared identifier is reported only once
> > net/ipv4/xfrm4_input.c:67: error: for each function it appears in.)
> > make[2]: *** [net/ipv4/xfrm4_input.o] Error 1
> > make[1]: *** [net/ipv4] Error 2
> > make: *** [net] Error 2
> 
> No netfilter, surely not :)
> 
> Does this patch help?
> 
> [IPSEC]: Fix build problem with netfilter off
> 
> The function xfrm4_rcv_encap_finish is now used even with NETFILTER
> off.  So we need to remove the ifdefs around i.t
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Nope, it needs a little more than that :-)  I just checked
in the following:

>From befb75b758f8a4d4de4c535db9f845726eae05eb Mon Sep 17 00:00:00 2001
From: David S. Miller <davem@sunset.davemloft.net>
Date: Tue, 13 Nov 2007 22:45:41 -0800
Subject: [PATCH] [IPV4] xfrm4_input.c: Fix build in non-NETFILTER case.

Based in part on a patch from Herbert Xu.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/xfrm4_input.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/xfrm4_input.c b/net/ipv4/xfrm4_input.c
index cd25351..d5890c8 100644
--- a/net/ipv4/xfrm4_input.c
+++ b/net/ipv4/xfrm4_input.c
@@ -21,7 +21,6 @@ int xfrm4_extract_input(struct xfrm_state *x, struct sk_buff *skb)
 	return xfrm4_extract_header(skb);
 }
 
-#ifdef CONFIG_NETFILTER
 static inline int xfrm4_rcv_encap_finish(struct sk_buff *skb)
 {
 	if (skb->dst == NULL) {
@@ -36,7 +35,6 @@ drop:
 	kfree_skb(skb);
 	return NET_RX_DROP;
 }
-#endif
 
 int xfrm4_rcv_encap(struct sk_buff *skb, int nexthdr, __be32 spi,
 		    int encap_type)
@@ -64,7 +62,7 @@ int xfrm4_transport_finish(struct sk_buff *skb, int async)
 	if (async)
 		return xfrm4_rcv_encap_finish(skb);
 
-	return -nexthdr;
+	return -iph->protocol;
 #endif
 }
 
-- 
1.5.3.5

