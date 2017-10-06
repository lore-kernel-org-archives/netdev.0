From: Wei Wang <weiwan@google.com>
Subject: [PATCH net-next 13/16] ipv6: check fn->leaf before it is used
Date: Fri,  6 Oct 2017 12:06:08 -0700
Message-ID: <20171006190611.110633-14-tracywwnj@gmail.com>
References: <20171006190611.110633-1-tracywwnj@gmail.com>
 <20171006190611.110633-2-tracywwnj@gmail.com>
 <20171006190611.110633-3-tracywwnj@gmail.com>
 <20171006190611.110633-4-tracywwnj@gmail.com>
 <20171006190611.110633-5-tracywwnj@gmail.com>
 <20171006190611.110633-6-tracywwnj@gmail.com>
 <20171006190611.110633-7-tracywwnj@gmail.com>
 <20171006190611.110633-8-tracywwnj@gmail.com>
 <20171006190611.110633-9-tracywwnj@gmail.com>
 <20171006190611.110633-10-tracywwnj@gmail.com>
 <20171006190611.110633-11-tracywwnj@gmail.com>
 <20171006190611.110633-12-tracywwnj@gmail.com>
 <20171006190611.110633-13-tracywwnj@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>,
        Martin KaFai Lau <kafai@fb.com>, Wei Wang <weiwan@google.com>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f53.google.com ([74.125.83.53]:52122 "EHLO
        mail-pg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752757AbdJFTGz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2017 15:06:55 -0400
Received: by mail-pg0-f53.google.com with SMTP id u144so7688975pgb.8
        for <netdev@vger.kernel.org>; Fri, 06 Oct 2017 12:06:55 -0700 (PDT)
In-Reply-To: <20171006190611.110633-13-tracywwnj@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>

If rwlock is replaced with rcu and spinlock, it is possible that the
reader thread will see fn->leaf as NULL in the following scenarios:
1. fib6_add() is in progress and we have already inserted a new node but
not yet inserted the route.
2. fib6_del_route() is in progress and we have already set fn->leaf to
NULL but not yet freed the node because of rcu grace period.

This patch makes sure all the reader threads check fn->leaf first before
using it. And together with later patch to grab rcu_read_lock() and
rcu_dereference() fn->leaf, it makes sure reader threads are safe when
accessing fn->leaf.

Signed-off-by: Wei Wang <weiwan@google.com>
Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv6/ip6_fib.c | 23 ++++++++++++++++++-----
 net/ipv6/route.c   | 20 ++++++++++++--------
 2 files changed, 30 insertions(+), 13 deletions(-)

diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index f604b311cc3e..cf6137e81408 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -1279,10 +1279,13 @@ static struct fib6_node *fib6_lookup_1(struct fib6_node *root,
 
 	while (fn) {
 		if (FIB6_SUBTREE(fn) || fn->fn_flags & RTN_RTINFO) {
+			struct rt6_info *leaf = fn->leaf;
 			struct rt6key *key;
 
-			key = (struct rt6key *) ((u8 *) fn->leaf +
-						 args->offset);
+			if (!leaf)
+				goto backtrack;
+
+			key = (struct rt6key *) ((u8 *)leaf + args->offset);
 
 			if (ipv6_prefix_equal(&key->addr, args->addr, key->plen)) {
 #ifdef CONFIG_IPV6_SUBTREES
@@ -1299,9 +1302,7 @@ static struct fib6_node *fib6_lookup_1(struct fib6_node *root,
 					return fn;
 			}
 		}
-#ifdef CONFIG_IPV6_SUBTREES
 backtrack:
-#endif
 		if (fn->fn_flags & RTN_ROOT)
 			break;
 
@@ -1358,7 +1359,18 @@ static struct fib6_node *fib6_locate_1(struct fib6_node *root,
 	struct fib6_node *fn, *prev = NULL;
 
 	for (fn = root; fn ; ) {
-		struct rt6key *key = (struct rt6key *)((u8 *)fn->leaf + offset);
+		struct rt6_info *leaf = fn->leaf;
+		struct rt6key *key;
+
+		/* This node is being deleted */
+		if (!leaf) {
+			if (plen <= fn->fn_bit)
+				goto out;
+			else
+				goto next;
+		}
+
+		key = (struct rt6key *)((u8 *)leaf + offset);
 
 		/*
 		 *	Prefix match
@@ -1372,6 +1384,7 @@ static struct fib6_node *fib6_locate_1(struct fib6_node *root,
 
 		prev = fn;
 
+next:
 		/*
 		 *	We have more bits to go
 		 */
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index aeb349aea429..05dc450af441 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -712,6 +712,7 @@ static struct rt6_info *find_match(struct rt6_info *rt, int oif, int strict,
 }
 
 static struct rt6_info *find_rr_leaf(struct fib6_node *fn,
+				     struct rt6_info *leaf,
 				     struct rt6_info *rr_head,
 				     u32 metric, int oif, int strict,
 				     bool *do_rr)
@@ -730,7 +731,7 @@ static struct rt6_info *find_rr_leaf(struct fib6_node *fn,
 		match = find_match(rt, oif, strict, &mpri, match, do_rr);
 	}
 
-	for (rt = fn->leaf; rt && rt != rr_head; rt = rt->dst.rt6_next) {
+	for (rt = leaf; rt && rt != rr_head; rt = rt->dst.rt6_next) {
 		if (rt->rt6i_metric != metric) {
 			cont = rt;
 			break;
@@ -748,17 +749,21 @@ static struct rt6_info *find_rr_leaf(struct fib6_node *fn,
 	return match;
 }
 
-static struct rt6_info *rt6_select(struct fib6_node *fn, int oif, int strict)
+static struct rt6_info *rt6_select(struct net *net, struct fib6_node *fn,
+				   int oif, int strict)
 {
+	struct rt6_info *leaf = fn->leaf;
 	struct rt6_info *match, *rt0;
-	struct net *net;
 	bool do_rr = false;
 
+	if (!leaf)
+		return net->ipv6.ip6_null_entry;
+
 	rt0 = fn->rr_ptr;
 	if (!rt0)
-		fn->rr_ptr = rt0 = fn->leaf;
+		fn->rr_ptr = rt0 = leaf;
 
-	match = find_rr_leaf(fn, rt0, rt0->rt6i_metric, oif, strict,
+	match = find_rr_leaf(fn, leaf, rt0, rt0->rt6i_metric, oif, strict,
 			     &do_rr);
 
 	if (do_rr) {
@@ -766,13 +771,12 @@ static struct rt6_info *rt6_select(struct fib6_node *fn, int oif, int strict)
 
 		/* no entries matched; do round-robin */
 		if (!next || next->rt6i_metric != rt0->rt6i_metric)
-			next = fn->leaf;
+			next = leaf;
 
 		if (next != rt0)
 			fn->rr_ptr = next;
 	}
 
-	net = dev_net(rt0->dst.dev);
 	return match ? match : net->ipv6.ip6_null_entry;
 }
 
@@ -1623,7 +1627,7 @@ struct rt6_info *ip6_pol_route(struct net *net, struct fib6_table *table,
 		oif = 0;
 
 redo_rt6_select:
-	rt = rt6_select(fn, oif, strict);
+	rt = rt6_select(net, fn, oif, strict);
 	if (rt->rt6i_nsiblings)
 		rt = rt6_multipath_select(rt, fl6, oif, strict);
 	if (rt == net->ipv6.ip6_null_entry) {
-- 
2.14.2.920.gcf0c67979c-goog
