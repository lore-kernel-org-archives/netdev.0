From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH RFC] ipv6: fix route selection if kernel is not compiled with CONFIG_IPV6_ROUTER_PREF
Date: Sun, 7 Jul 2013 19:30:31 +0200
Message-ID: <20130707173031.GC9625@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: yoshfuji@linux-ipv6.org, petrus.lt@gmail.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s15338416.onlinehome-server.info ([87.106.68.36]:59206 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752628Ab3GGRad (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Jul 2013 13:30:33 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

This patch fixes the last (I currently know of) known problem with nexthop
selection and rt->n removal for me. I did some preliminary testing and it
looks good so far. I wanted to post it here early to gather further feedback,
reviews or even testing. I am not sure if I overlooked something, yet.

Things I have not checked, yet:
a) switching a router to host (I don't know if we handle this correctly,
   currently)
b) router disappearing (but should be fine)
c) ...

No signed-off by me, for now.

Thanks,

  Hannes

-- >8 --

This is a follow-up patch to 3630d40067a21d4dfbadc6002bb469ce26ac5d52
("ipv6: rt6_check_neigh should successfully verify neigh if no NUD
information are available").

Since the removal of rt->n in rt6_info we can end up with a dst ==
NULL in rt6_check_neigh. In case the kernel is not compiled with
CONFIG_IPV6_ROUTER_PREF we should also select a route with unkown
NUD state but we must not avoid doing round robin selection on routes
with the same target. So introduce and pass down a boolean ``do_rr'' to
indicate when we should update rt->rr_ptr. As soon as no route is valid
we do backtracking and do a lookup on a higher level in the fib trie.

To hold correct state on the NUD selection we need to create a neighbour
entry as soon as we try to validate a nexthop.

I changed the return value of rt6_check_neigh to:
   1 in case of the dst entry validated
  -1 in case of we had no dst_entry and we need to do rr now
  -2 in case a we had a dst_entry and it did not validate

In case of CONFIG_IPV6_ROUTER_PREF, rt6_probe does not allocate an
neighbour entry (!CONFIG_IPV6_ROUTER_PREF: rt6_probe is a nop). Because
of this, we have to create a neighbour entry on nexthop validation to
track earlier validation errors. We recheck NUD state here to shortcurcuit
NUD_NOARP neighbours.

This seems to be the least complex fix for stable and net. I'll introduce
a new route lookup flag 'idempotent' as soon as next opens to not let
ip route get trigger active NUD validation if CONFIG_IPV6_ROUTER_PREF
is enabled.

It also seems advantageous to make CONFIG_IPV6_ROUTER_PREF a runtime
switch and just select the default operation on compile-time.

Reported-by: Pierre Emeriaud <petrus.lt@gmail.com>
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Cc: David Miller <davem@davemloft.net>
---
 net/ipv6/route.c | 67 +++++++++++++++++++++++++++++++++++++-------------------
 1 file changed, 44 insertions(+), 23 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index bd5fd70..6a87ced 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -531,28 +531,39 @@ static inline int rt6_check_dev(struct rt6_info *rt, int oif)
 	return 0;
 }
 
-static inline bool rt6_check_neigh(struct rt6_info *rt)
+static inline int rt6_check_neigh(struct rt6_info *rt)
 {
 	struct neighbour *neigh;
-	bool ret = false;
+	int ret = -2;
 
 	if (rt->rt6i_flags & RTF_NONEXTHOP ||
 	    !(rt->rt6i_flags & RTF_GATEWAY))
-		return true;
+		return 1;
 
 	rcu_read_lock_bh();
 	neigh = __ipv6_neigh_lookup_noref(rt->dst.dev, &rt->rt6i_gateway);
 	if (neigh) {
 		read_lock(&neigh->lock);
 		if (neigh->nud_state & NUD_VALID)
-			ret = true;
+			ret = 1;
 #ifdef CONFIG_IPV6_ROUTER_PREF
 		else if (!(neigh->nud_state & NUD_FAILED))
-			ret = true;
+			ret = 1;
 #endif
 		read_unlock(&neigh->lock);
-	} else if (IS_ENABLED(CONFIG_IPV6_ROUTER_PREF)) {
-		ret = true;
+	} else {
+		/* track state for next check */
+		neigh = __neigh_create(&nd_tbl, &rt->rt6i_gateway, rt->dst.dev,
+				       false);
+		if (!IS_ERR(neigh)) {
+			if (neigh->nud_state & NUD_VALID)
+				ret = 1;
+			else
+				ret = IS_ENABLED(CONFIG_IPV6_ROUTER_PREF) ?
+				      1 : -1;
+		} else {
+			ret = -2;
+		}
 	}
 	rcu_read_unlock_bh();
 
@@ -566,43 +577,52 @@ static int rt6_score_route(struct rt6_info *rt, int oif,
 
 	m = rt6_check_dev(rt, oif);
 	if (!m && (strict & RT6_LOOKUP_F_IFACE))
-		return -1;
+		return -2;
 #ifdef CONFIG_IPV6_ROUTER_PREF
 	m |= IPV6_DECODE_PREF(IPV6_EXTRACT_PREF(rt->rt6i_flags)) << 2;
 #endif
-	if (!rt6_check_neigh(rt) && (strict & RT6_LOOKUP_F_REACHABLE))
-		return -1;
+	if (strict & RT6_LOOKUP_F_REACHABLE) {
+		int n = rt6_check_neigh(rt);
+		if (n < 0)
+			return n;
+	}
 	return m;
 }
 
 static struct rt6_info *find_match(struct rt6_info *rt, int oif, int strict,
-				   int *mpri, struct rt6_info *match)
+				   int *mpri, struct rt6_info *match,
+				   bool *do_rr)
 {
 	int m;
+	bool match_do_rr = false;
 
 	if (rt6_check_expired(rt))
 		goto out;
 
 	m = rt6_score_route(rt, oif, strict);
-	if (m < 0)
+	if (m == -1 && !IS_ENABLED(CONFIG_IPV6_ROUTER_PREF)) {
+		match_do_rr = true;
+		m = 0; /* lowest valid score */
+	} else if (m < 0) {
 		goto out;
+	}
+
+	if (strict & RT6_LOOKUP_F_REACHABLE)
+		rt6_probe(rt);
 
 	if (m > *mpri) {
-		if (strict & RT6_LOOKUP_F_REACHABLE)
-			rt6_probe(match);
+		*do_rr = match_do_rr;
 		*mpri = m;
 		match = rt;
-	} else if (strict & RT6_LOOKUP_F_REACHABLE) {
-		rt6_probe(rt);
 	}
-
 out:
 	return match;
 }
 
 static struct rt6_info *find_rr_leaf(struct fib6_node *fn,
 				     struct rt6_info *rr_head,
-				     u32 metric, int oif, int strict)
+				     u32 metric, int oif, int strict,
+				     bool *do_rr)
 {
 	struct rt6_info *rt, *match;
 	int mpri = -1;
@@ -610,10 +630,10 @@ static struct rt6_info *find_rr_leaf(struct fib6_node *fn,
 	match = NULL;
 	for (rt = rr_head; rt && rt->rt6i_metric == metric;
 	     rt = rt->dst.rt6_next)
-		match = find_match(rt, oif, strict, &mpri, match);
+		match = find_match(rt, oif, strict, &mpri, match, do_rr);
 	for (rt = fn->leaf; rt && rt != rr_head && rt->rt6i_metric == metric;
 	     rt = rt->dst.rt6_next)
-		match = find_match(rt, oif, strict, &mpri, match);
+		match = find_match(rt, oif, strict, &mpri, match, do_rr);
 
 	return match;
 }
@@ -622,15 +642,16 @@ static struct rt6_info *rt6_select(struct fib6_node *fn, int oif, int strict)
 {
 	struct rt6_info *match, *rt0;
 	struct net *net;
+	bool do_rr = false;
 
 	rt0 = fn->rr_ptr;
 	if (!rt0)
 		fn->rr_ptr = rt0 = fn->leaf;
 
-	match = find_rr_leaf(fn, rt0, rt0->rt6i_metric, oif, strict);
+	match = find_rr_leaf(fn, rt0, rt0->rt6i_metric, oif, strict,
+			     &do_rr);
 
-	if (!match &&
-	    (strict & RT6_LOOKUP_F_REACHABLE)) {
+	if (do_rr) {
 		struct rt6_info *next = rt0->dst.rt6_next;
 
 		/* no entries matched; do round-robin */
-- 
1.8.1.4
