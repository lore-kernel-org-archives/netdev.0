From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 9/11] [IPSEC]: Use the top IPv4 route's peer instead of the bottom
Date: Wed, 17 Oct 2007 22:34:17 +0800
Message-ID: <E1Ii9yT-0006Hj-00@gondolin.me.apana.org.au>
References: <20071017142940.GA23879@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1135 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756518AbXJQOej (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Oct 2007 10:34:39 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPSEC]: Use the top IPv4 route's peer instead of the bottom

For IPv4 we were using the bottom route's peer instead of the top one.
This is wrong because the peer is only used by TCP to keep track of
information about the TCP destination address which certainly does not
live in the bottom route.

This patch fixes that which allows us to get rid of the family check
since the bottom route could be IPv6 while the top one must always
be IPv4.

I've also changed the other fields which are IPv4-specific to get the
info from the top route instead of potentially bogus data from the
bottom route.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/ipv4/xfrm4_policy.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index c65b8e0..1f0ea0e 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -169,16 +169,16 @@ __xfrm4_bundle_create(struct xfrm_policy *policy, struct xfrm_state **xfrm, int
 		dst_prev->neighbour	= neigh_clone(rt->u.dst.neighbour);
 		dst_prev->input		= rt->u.dst.input;
 		dst_prev->output = dst_prev->xfrm->mode->afinfo->output;
-		if (dst_prev->xfrm->props.family == AF_INET && rt->peer)
-			atomic_inc(&rt->peer->refcnt);
-		x->u.rt.peer = rt->peer;
+		if (rt0->peer)
+			atomic_inc(&rt0->peer->refcnt);
+		x->u.rt.peer = rt0->peer;
 		/* Sheit... I remember I did this right. Apparently,
 		 * it was magically lost, so this code needs audit */
 		x->u.rt.rt_flags = rt0->rt_flags&(RTCF_BROADCAST|RTCF_MULTICAST|RTCF_LOCAL);
-		x->u.rt.rt_type = rt->rt_type;
+		x->u.rt.rt_type = rt0->rt_type;
 		x->u.rt.rt_src = rt0->rt_src;
 		x->u.rt.rt_dst = rt0->rt_dst;
-		x->u.rt.rt_gateway = rt->rt_gateway;
+		x->u.rt.rt_gateway = rt0->rt_gateway;
 		x->u.rt.rt_spec_dst = rt0->rt_spec_dst;
 		x->u.rt.idev = rt0->idev;
 		in_dev_hold(rt0->idev);
@@ -280,7 +280,7 @@ static void xfrm4_dst_destroy(struct dst_entry *dst)
 
 	if (likely(xdst->u.rt.idev))
 		in_dev_put(xdst->u.rt.idev);
-	if (dst->xfrm && dst->xfrm->props.family == AF_INET && likely(xdst->u.rt.peer))
+	if (likely(xdst->u.rt.peer))
 		inet_putpeer(xdst->u.rt.peer);
 	xfrm_dst_destroy(xdst);
 }
