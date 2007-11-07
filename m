From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 6/24] [IPSEC]: Only set neighbour on top xfrm dst
Date: Wed, 07 Nov 2007 22:08:22 +0800
Message-ID: <E1IplZu-0001Gd-00@gondolin.me.apana.org.au>
References: <20071107140701.GA4685@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3532 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758514AbXKGOIb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2007 09:08:31 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPSEC]: Only set neighbour on top xfrm dst

The neighbour field is only used by dst_confirm which only ever happens on
the top-most xfrm dst.  So it's a waste to duplicate for every other xfrm
dst.  This patch moves its setting out of the loop so that only the top one
gets set.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/ipv4/xfrm4_policy.c |    5 +++--
 net/ipv6/xfrm6_policy.c |    6 ++++--
 2 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index 5ee3a2f..7d250a1 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -144,6 +144,9 @@ __xfrm4_bundle_create(struct xfrm_policy *policy, struct xfrm_state **xfrm, int
 	dst_prev->child = &rt->u.dst;
 	dst->path = &rt->u.dst;
 
+	/* Copy neighbout for reachability confirmation */
+	dst->neighbour = neigh_clone(rt->u.dst.neighbour);
+
 	*dst_p = dst;
 	dst = dst_prev;
 
@@ -164,8 +167,6 @@ __xfrm4_bundle_create(struct xfrm_policy *policy, struct xfrm_state **xfrm, int
 		dst_prev->trailer_len	= trailer_len;
 		memcpy(&dst_prev->metrics, &x->route->metrics, sizeof(dst_prev->metrics));
 
-		/* Copy neighbout for reachability confirmation */
-		dst_prev->neighbour	= neigh_clone(rt->u.dst.neighbour);
 		dst_prev->input		= rt->u.dst.input;
 		dst_prev->output = dst_prev->xfrm->outer_mode->afinfo->output;
 		if (rt0->peer)
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 9095dfc..15747f3 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -188,6 +188,10 @@ __xfrm6_bundle_create(struct xfrm_policy *policy, struct xfrm_state **xfrm, int
 
 	dst_prev->child = &rt->u.dst;
 	dst->path = &rt->u.dst;
+
+	/* Copy neighbour for reachability confirmation */
+	dst->neighbour = neigh_clone(rt->u.dst.neighbour);
+
 	if (rt->rt6i_node)
 		((struct xfrm_dst *)dst)->path_cookie = rt->rt6i_node->fn_sernum;
 
@@ -210,8 +214,6 @@ __xfrm6_bundle_create(struct xfrm_policy *policy, struct xfrm_state **xfrm, int
 		dst_prev->trailer_len	= trailer_len;
 		memcpy(&dst_prev->metrics, &x->route->metrics, sizeof(dst_prev->metrics));
 
-		/* Copy neighbour for reachability confirmation */
-		dst_prev->neighbour	= neigh_clone(rt->u.dst.neighbour);
 		dst_prev->input		= rt->u.dst.input;
 		dst_prev->output = dst_prev->xfrm->outer_mode->afinfo->output;
 		/* Sheit... I remember I did this right. Apparently,
