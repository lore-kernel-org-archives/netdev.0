From: David Miller <davem@davemloft.net>
Subject: [RFC PATCH 03/12] ipv6: Move rt6_next from dst_entry into ipv6
 route structure.
Date: Wed, 25 Oct 2017 23:03:01 +0900 (KST)
Message-ID: <20171025.230301.1006783966249137769.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48300 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751977AbdJYODE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 10:03:04 -0400
Received: from localhost (unknown [106.252.28.196])
        (using TLSv1 with cipher AES256-SHA (256/256 bits))
        (Client did not present a certificate)
        (Authenticated sender: davem-davemloft)
        by shards.monkeyblade.net (Postfix) with ESMTPSA id 65B8D133F06AD
        for <netdev@vger.kernel.org>; Wed, 25 Oct 2017 07:03:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/dst.h     |  1 -
 include/net/ip6_fib.h |  5 +++--
 net/ipv6/ip6_fib.c    | 26 +++++++++++++-------------
 net/ipv6/route.c      | 10 +++++-----
 4 files changed, 21 insertions(+), 21 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 14a0eec8e7d8..2409e7795ad5 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -100,7 +100,6 @@ struct dst_entry {
 	struct lwtunnel_state   *lwtstate;
 	union {
 		struct dst_entry	*next;
-		struct rt6_info __rcu	*rt6_next;
 	};
 };
 
diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index 10c913816032..281a922f0c62 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -129,6 +129,7 @@ struct rt6_exception {
 
 struct rt6_info {
 	struct dst_entry		dst;
+	struct rt6_info __rcu		*rt6_next;
 
 	/*
 	 * Tail elements of dst_entry (__refcnt etc.)
@@ -176,11 +177,11 @@ struct rt6_info {
 
 #define for_each_fib6_node_rt_rcu(fn)					\
 	for (rt = rcu_dereference((fn)->leaf); rt;			\
-	     rt = rcu_dereference(rt->dst.rt6_next))
+	     rt = rcu_dereference(rt->rt6_next))
 
 #define for_each_fib6_walker_rt(w)					\
 	for (rt = (w)->leaf; rt;					\
-	     rt = rcu_dereference_protected(rt->dst.rt6_next, 1))
+	     rt = rcu_dereference_protected(rt->rt6_next, 1))
 
 static inline struct inet6_dev *ip6_dst_idev(struct dst_entry *dst)
 {
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 1ada9672d198..0b2f7fd3e876 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -890,7 +890,7 @@ static int fib6_add_rt2node(struct fib6_node *fn, struct rt6_info *rt,
 	ins = &fn->leaf;
 
 	for (iter = leaf; iter;
-	     iter = rcu_dereference_protected(iter->dst.rt6_next,
+	     iter = rcu_dereference_protected(iter->rt6_next,
 				lockdep_is_held(&rt->rt6i_table->tb6_lock))) {
 		/*
 		 *	Search for duplicates
@@ -947,7 +947,7 @@ static int fib6_add_rt2node(struct fib6_node *fn, struct rt6_info *rt,
 			break;
 
 next_iter:
-		ins = &iter->dst.rt6_next;
+		ins = &iter->rt6_next;
 	}
 
 	if (fallback_ins && !found) {
@@ -976,7 +976,7 @@ static int fib6_add_rt2node(struct fib6_node *fn, struct rt6_info *rt,
 					      &sibling->rt6i_siblings);
 				break;
 			}
-			sibling = rcu_dereference_protected(sibling->dst.rt6_next,
+			sibling = rcu_dereference_protected(sibling->rt6_next,
 				    lockdep_is_held(&rt->rt6i_table->tb6_lock));
 		}
 		/* For each sibling in the list, increment the counter of
@@ -1006,7 +1006,7 @@ static int fib6_add_rt2node(struct fib6_node *fn, struct rt6_info *rt,
 		if (err)
 			return err;
 
-		rcu_assign_pointer(rt->dst.rt6_next, iter);
+		rcu_assign_pointer(rt->rt6_next, iter);
 		atomic_inc(&rt->rt6i_ref);
 		rcu_assign_pointer(rt->rt6i_node, fn);
 		rcu_assign_pointer(*ins, rt);
@@ -1037,7 +1037,7 @@ static int fib6_add_rt2node(struct fib6_node *fn, struct rt6_info *rt,
 
 		atomic_inc(&rt->rt6i_ref);
 		rcu_assign_pointer(rt->rt6i_node, fn);
-		rt->dst.rt6_next = iter->dst.rt6_next;
+		rt->rt6_next = iter->rt6_next;
 		rcu_assign_pointer(*ins, rt);
 		call_fib6_entry_notifiers(info->nl_net, FIB_EVENT_ENTRY_REPLACE,
 					  rt);
@@ -1056,14 +1056,14 @@ static int fib6_add_rt2node(struct fib6_node *fn, struct rt6_info *rt,
 
 		if (nsiblings) {
 			/* Replacing an ECMP route, remove all siblings */
-			ins = &rt->dst.rt6_next;
+			ins = &rt->rt6_next;
 			iter = rcu_dereference_protected(*ins,
 				    lockdep_is_held(&rt->rt6i_table->tb6_lock));
 			while (iter) {
 				if (iter->rt6i_metric > rt->rt6i_metric)
 					break;
 				if (rt6_qualify_for_ecmp(iter)) {
-					*ins = iter->dst.rt6_next;
+					*ins = iter->rt6_next;
 					iter->rt6i_node = NULL;
 					fib6_purge_rt(iter, fn, info->nl_net);
 					if (rcu_access_pointer(fn->rr_ptr) == iter)
@@ -1072,7 +1072,7 @@ static int fib6_add_rt2node(struct fib6_node *fn, struct rt6_info *rt,
 					nsiblings--;
 					info->nl_net->ipv6.rt6_stats->fib_rt_entries--;
 				} else {
-					ins = &iter->dst.rt6_next;
+					ins = &iter->rt6_next;
 				}
 				iter = rcu_dereference_protected(*ins,
 					lockdep_is_held(&rt->rt6i_table->tb6_lock));
@@ -1641,7 +1641,7 @@ static void fib6_del_route(struct fib6_table *table, struct fib6_node *fn,
 	WARN_ON_ONCE(rt->rt6i_flags & RTF_CACHE);
 
 	/* Unlink it */
-	*rtp = rt->dst.rt6_next;
+	*rtp = rt->rt6_next;
 	rt->rt6i_node = NULL;
 	net->ipv6.rt6_stats->fib_rt_entries--;
 	net->ipv6.rt6_stats->fib_discarded_routes++;
@@ -1669,7 +1669,7 @@ static void fib6_del_route(struct fib6_table *table, struct fib6_node *fn,
 	FOR_WALKERS(net, w) {
 		if (w->state == FWS_C && w->leaf == rt) {
 			RT6_TRACE("walker %p adjusted by delroute\n", w);
-			w->leaf = rcu_dereference_protected(rt->dst.rt6_next,
+			w->leaf = rcu_dereference_protected(rt->rt6_next,
 					    lockdep_is_held(&table->tb6_lock));
 			if (!w->leaf)
 				w->state = FWS_U;
@@ -1728,7 +1728,7 @@ int fib6_del(struct rt6_info *rt, struct nl_info *info)
 			fib6_del_route(table, fn, rtp, info);
 			return 0;
 		}
-		rtp_next = &cur->dst.rt6_next;
+		rtp_next = &cur->rt6_next;
 	}
 	return -ENOENT;
 }
@@ -2203,7 +2203,7 @@ static int ipv6_route_yield(struct fib6_walker *w)
 
 	do {
 		iter->w.leaf = rcu_dereference_protected(
-				iter->w.leaf->dst.rt6_next,
+				iter->w.leaf->rt6_next,
 				lockdep_is_held(&iter->tbl->tb6_lock));
 		iter->skip--;
 		if (!iter->skip && iter->w.leaf)
@@ -2269,7 +2269,7 @@ static void *ipv6_route_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 	if (!v)
 		goto iter_table;
 
-	n = rcu_dereference_bh(((struct rt6_info *)v)->dst.rt6_next);
+	n = rcu_dereference_bh(((struct rt6_info *)v)->rt6_next);
 	if (n) {
 		++*pos;
 		return n;
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 46c59a53c53f..3c943d252a33 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -497,7 +497,7 @@ static inline struct rt6_info *rt6_device_match(struct net *net,
 	if (!oif && ipv6_addr_any(saddr))
 		goto out;
 
-	for (sprt = rt; sprt; sprt = rcu_dereference(sprt->dst.rt6_next)) {
+	for (sprt = rt; sprt; sprt = rcu_dereference(sprt->rt6_next)) {
 		struct net_device *dev = sprt->dst.dev;
 
 		if (oif) {
@@ -716,7 +716,7 @@ static struct rt6_info *find_rr_leaf(struct fib6_node *fn,
 
 	match = NULL;
 	cont = NULL;
-	for (rt = rr_head; rt; rt = rcu_dereference(rt->dst.rt6_next)) {
+	for (rt = rr_head; rt; rt = rcu_dereference(rt->rt6_next)) {
 		if (rt->rt6i_metric != metric) {
 			cont = rt;
 			break;
@@ -726,7 +726,7 @@ static struct rt6_info *find_rr_leaf(struct fib6_node *fn,
 	}
 
 	for (rt = leaf; rt && rt != rr_head;
-	     rt = rcu_dereference(rt->dst.rt6_next)) {
+	     rt = rcu_dereference(rt->rt6_next)) {
 		if (rt->rt6i_metric != metric) {
 			cont = rt;
 			break;
@@ -738,7 +738,7 @@ static struct rt6_info *find_rr_leaf(struct fib6_node *fn,
 	if (match || !cont)
 		return match;
 
-	for (rt = cont; rt; rt = rcu_dereference(rt->dst.rt6_next))
+	for (rt = cont; rt; rt = rcu_dereference(rt->rt6_next))
 		match = find_match(rt, oif, strict, &mpri, match, do_rr);
 
 	return match;
@@ -776,7 +776,7 @@ static struct rt6_info *rt6_select(struct net *net, struct fib6_node *fn,
 			     &do_rr);
 
 	if (do_rr) {
-		struct rt6_info *next = rcu_dereference(rt0->dst.rt6_next);
+		struct rt6_info *next = rcu_dereference(rt0->rt6_next);
 
 		/* no entries matched; do round-robin */
 		if (!next || next->rt6i_metric != rt0->rt6i_metric)
-- 
2.13.6
