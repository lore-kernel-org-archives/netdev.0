From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 11/11] [IPSEC]: Rename mode to outer_mode and add inner_mode
Date: Wed, 17 Oct 2007 22:34:19 +0800
Message-ID: <E1Ii9yV-0006Hz-00@gondolin.me.apana.org.au>
References: <20071017142940.GA23879@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1133 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759637AbXJQOef (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Oct 2007 10:34:35 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPSEC]: Rename mode to outer_mode and add inner_mode

This patch adds a new field to xfrm states called inner_mode.  The existing
mode object is renamed to outer_mode.

This is the first part of an attempt to fix inter-family transforms.  As it
is we always use the outer family when determining which mode to use.  As a
result we may end up shoving IPv4 packets into netfilter6 and vice versa.

What we really want is to use the inner family for the first part of outbound
processing and the outer family for the second part.  For inbound processing
we'd use the opposite pairing.

I've also added a check to prevent silly combinations such as transport mode
with inter-family transforms.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/net/xfrm.h      |    3 ++-
 net/core/pktgen.c       |    2 +-
 net/ipv4/xfrm4_input.c  |    4 ++--
 net/ipv4/xfrm4_policy.c |    2 +-
 net/ipv6/xfrm6_input.c  |    4 ++--
 net/ipv6/xfrm6_policy.c |    2 +-
 net/xfrm/xfrm_output.c  |    4 ++--
 net/xfrm/xfrm_policy.c  |    2 +-
 net/xfrm/xfrm_state.c   |   18 ++++++++++++++----
 9 files changed, 26 insertions(+), 15 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index f0f3318..688f6f5 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -186,7 +186,8 @@ struct xfrm_state
 	/* Reference to data common to all the instances of this
 	 * transformer. */
 	struct xfrm_type	*type;
-	struct xfrm_mode	*mode;
+	struct xfrm_mode	*inner_mode;
+	struct xfrm_mode	*outer_mode;
 
 	/* Security context */
 	struct xfrm_sec_ctx	*security;
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 2100c73..8cae60c 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -2454,7 +2454,7 @@ static int pktgen_output_ipsec(struct sk_buff *skb, struct pktgen_dev *pkt_dev)
 	spin_lock(&x->lock);
 	iph = ip_hdr(skb);
 
-	err = x->mode->output(x, skb);
+	err = x->outer_mode->output(x, skb);
 	if (err)
 		goto error;
 	err = x->type->output(x, skb);
diff --git a/net/ipv4/xfrm4_input.c b/net/ipv4/xfrm4_input.c
index bc5dc07..5e95c8a 100644
--- a/net/ipv4/xfrm4_input.c
+++ b/net/ipv4/xfrm4_input.c
@@ -91,10 +91,10 @@ int xfrm4_rcv_encap(struct sk_buff *skb, int nexthdr, __be32 spi,
 
 		xfrm_vec[xfrm_nr++] = x;
 
-		if (x->mode->input(x, skb))
+		if (x->outer_mode->input(x, skb))
 			goto drop;
 
-		if (x->mode->flags & XFRM_MODE_FLAG_TUNNEL) {
+		if (x->outer_mode->flags & XFRM_MODE_FLAG_TUNNEL) {
 			decaps = 1;
 			break;
 		}
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index 1f0ea0e..cc86fb1 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -168,7 +168,7 @@ __xfrm4_bundle_create(struct xfrm_policy *policy, struct xfrm_state **xfrm, int
 		/* Copy neighbout for reachability confirmation */
 		dst_prev->neighbour	= neigh_clone(rt->u.dst.neighbour);
 		dst_prev->input		= rt->u.dst.input;
-		dst_prev->output = dst_prev->xfrm->mode->afinfo->output;
+		dst_prev->output = dst_prev->xfrm->outer_mode->afinfo->output;
 		if (rt0->peer)
 			atomic_inc(&rt0->peer->refcnt);
 		x->u.rt.peer = rt0->peer;
diff --git a/net/ipv6/xfrm6_input.c b/net/ipv6/xfrm6_input.c
index c6ee1a3..5157837 100644
--- a/net/ipv6/xfrm6_input.c
+++ b/net/ipv6/xfrm6_input.c
@@ -68,10 +68,10 @@ int xfrm6_rcv_spi(struct sk_buff *skb, int nexthdr, __be32 spi)
 
 		xfrm_vec[xfrm_nr++] = x;
 
-		if (x->mode->input(x, skb))
+		if (x->outer_mode->input(x, skb))
 			goto drop;
 
-		if (x->mode->flags & XFRM_MODE_FLAG_TUNNEL) {
+		if (x->outer_mode->flags & XFRM_MODE_FLAG_TUNNEL) {
 			decaps = 1;
 			break;
 		}
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 3242683..82e27b8 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -230,7 +230,7 @@ __xfrm6_bundle_create(struct xfrm_policy *policy, struct xfrm_state **xfrm, int
 		/* Copy neighbour for reachability confirmation */
 		dst_prev->neighbour	= neigh_clone(rt->u.dst.neighbour);
 		dst_prev->input		= rt->u.dst.input;
-		dst_prev->output = dst_prev->xfrm->mode->afinfo->output;
+		dst_prev->output = dst_prev->xfrm->outer_mode->afinfo->output;
 		/* Sheit... I remember I did this right. Apparently,
 		 * it was magically lost, so this code needs audit */
 		x->u.rt6.rt6i_flags    = rt0->rt6i_flags&(RTCF_BROADCAST|RTCF_MULTICAST|RTCF_LOCAL);
diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
index 8bf71ba..f4bfd6c 100644
--- a/net/xfrm/xfrm_output.c
+++ b/net/xfrm/xfrm_output.c
@@ -63,7 +63,7 @@ int xfrm_output(struct sk_buff *skb)
 				xfrm_replay_notify(x, XFRM_REPLAY_UPDATE);
 		}
 
-		err = x->mode->output(x, skb);
+		err = x->outer_mode->output(x, skb);
 		if (err)
 			goto error;
 
@@ -82,7 +82,7 @@ int xfrm_output(struct sk_buff *skb)
 		}
 		dst = skb->dst;
 		x = dst->xfrm;
-	} while (x && !(x->mode->flags & XFRM_MODE_FLAG_TUNNEL));
+	} while (x && !(x->outer_mode->flags & XFRM_MODE_FLAG_TUNNEL));
 
 	err = 0;
 
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 1d66fb4..b702bd8 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1941,7 +1941,7 @@ int xfrm_bundle_ok(struct xfrm_policy *pol, struct xfrm_dst *first,
 			return 0;
 
 		if (strict && fl &&
-		    !(dst->xfrm->mode->flags & XFRM_MODE_FLAG_TUNNEL) &&
+		    !(dst->xfrm->outer_mode->flags & XFRM_MODE_FLAG_TUNNEL) &&
 		    !xfrm_state_addr_flow_check(dst->xfrm, fl, family))
 			return 0;
 
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 48b4a06..224b44e 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -377,8 +377,10 @@ static void xfrm_state_gc_destroy(struct xfrm_state *x)
 	kfree(x->calg);
 	kfree(x->encap);
 	kfree(x->coaddr);
-	if (x->mode)
-		xfrm_put_mode(x->mode);
+	if (x->inner_mode)
+		xfrm_put_mode(x->inner_mode);
+	if (x->outer_mode)
+		xfrm_put_mode(x->outer_mode);
 	if (x->type) {
 		x->type->destructor(x);
 		xfrm_put_type(x->type);
@@ -1947,6 +1949,14 @@ int xfrm_init_state(struct xfrm_state *x)
 		goto error;
 
 	err = -EPROTONOSUPPORT;
+	x->inner_mode = xfrm_get_mode(x->props.mode, x->sel.family);
+	if (x->inner_mode == NULL)
+		goto error;
+
+	if (!(x->inner_mode->flags & XFRM_MODE_FLAG_TUNNEL) &&
+	    family != x->sel.family)
+		goto error;
+
 	x->type = xfrm_get_type(x->id.proto, family);
 	if (x->type == NULL)
 		goto error;
@@ -1955,8 +1965,8 @@ int xfrm_init_state(struct xfrm_state *x)
 	if (err)
 		goto error;
 
-	x->mode = xfrm_get_mode(x->props.mode, family);
-	if (x->mode == NULL)
+	x->outer_mode = xfrm_get_mode(x->props.mode, family);
+	if (x->outer_mode == NULL)
 		goto error;
 
 	x->km.state = XFRM_STATE_VALID;
