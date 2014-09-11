From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH RFC 1/6] ipv6: also increase fib6_node sernum on deletion events
Date: Fri, 12 Sep 2014 01:21:48 +0200
Message-ID: <4f55afa99da1dab957b2dc5e7b313a1b70f864f3.1410477596.git.hannes@stressinduktion.org>
References: <cover.1410477596.git.hannes@stressinduktion.org>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:50463 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752660AbaIKXWA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2014 19:22:00 -0400
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by gateway2.nyi.internal (Postfix) with ESMTP id 0995A20D33
	for <netdev@vger.kernel.org>; Thu, 11 Sep 2014 19:22:00 -0400 (EDT)
In-Reply-To: <cover.1410477596.git.hannes@stressinduktion.org>
In-Reply-To: <cover.1410477596.git.hannes@stressinduktion.org>
References: <cover.1410477596.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fib6_add increases the fn_sernum of fib6_nodes while it traverses the
tree. This serial number is used by ip6_dst_check to judge whether a
relookup for the socket cache should be done (e.g. a better route is
available).

We didn't do so for fib6_del, so we missed relookups on ipv6 address
deletion events. Because this caused trouble in the SCTP stack, instead
the genid for ipv6 was bumped. Also TCP connections used old source
addresses, which were not available anymore.

Because we have static rt6_nodes in the tree (no RTF_GATEWAY,
RTF_NONEXTHOP nor RTF_CACHE nodes but still DST_HOST) flag, we ended up
in a situation where the genid of the routing node was always smaller
than the published genid in the namespace. That caused ip6_dst_check to
always discard the current dst_entry and a relookup happend.

This patch prepares for the removal of the ipv6 genid by also modifying
the fn_sernum on route deletion.

Thanks to Eric Dumazet who noticed this problem!

Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Vlad Yasevich <vyasevich@gmail.com>
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/ip6_fib.c | 40 +++++++++++++++++++++++++---------------
 1 file changed, 25 insertions(+), 15 deletions(-)

diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 76b7f5e..101efab 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -60,6 +60,7 @@ struct fib6_cleaner_t {
 	struct fib6_walker_t w;
 	struct net *net;
 	int (*func)(struct rt6_info *, void *arg);
+	u32 sernum;
 	void *arg;
 };
 
@@ -71,7 +72,8 @@ static DEFINE_RWLOCK(fib6_walker_lock);
 #define FWS_INIT FWS_L
 #endif
 
-static void fib6_prune_clones(struct net *net, struct fib6_node *fn);
+static void fib6_prune_clones(struct net *net, struct fib6_node *fn,
+			      u32 sernum);
 static struct rt6_info *fib6_find_prefix(struct net *net, struct fib6_node *fn);
 static struct fib6_node *fib6_repair_tree(struct net *net, struct fib6_node *fn);
 static int fib6_walk(struct fib6_walker_t *w);
@@ -84,7 +86,7 @@ static int fib6_walk_continue(struct fib6_walker_t *w);
  *	result of redirects, path MTU changes, etc.
  */
 
-static __u32 rt_sernum;
+static u32 rt_sernum;
 
 static void fib6_gc_timer_cb(unsigned long arg);
 
@@ -423,14 +425,14 @@ out:
 static struct fib6_node *fib6_add_1(struct fib6_node *root,
 				     struct in6_addr *addr, int plen,
 				     int offset, int allow_create,
-				     int replace_required)
+				     int replace_required,
+				     u32 sernum)
 {
 	struct fib6_node *fn, *in, *ln;
 	struct fib6_node *pn = NULL;
 	struct rt6key *key;
 	int	bit;
 	__be32	dir = 0;
-	__u32	sernum = fib6_new_sernum();
 
 	RT6_TRACE("fib6_add_1\n");
 
@@ -848,6 +850,7 @@ int fib6_add(struct fib6_node *root, struct rt6_info *rt, struct nl_info *info,
 	int err = -ENOMEM;
 	int allow_create = 1;
 	int replace_required = 0;
+	u32 sernum = fib6_new_sernum();
 
 	if (info->nlh) {
 		if (!(info->nlh->nlmsg_flags & NLM_F_CREATE))
@@ -860,7 +863,7 @@ int fib6_add(struct fib6_node *root, struct rt6_info *rt, struct nl_info *info,
 
 	fn = fib6_add_1(root, &rt->rt6i_dst.addr, rt->rt6i_dst.plen,
 			offsetof(struct rt6_info, rt6i_dst), allow_create,
-			replace_required);
+			replace_required, sernum);
 	if (IS_ERR(fn)) {
 		err = PTR_ERR(fn);
 		fn = NULL;
@@ -894,14 +897,14 @@ int fib6_add(struct fib6_node *root, struct rt6_info *rt, struct nl_info *info,
 			sfn->leaf = info->nl_net->ipv6.ip6_null_entry;
 			atomic_inc(&info->nl_net->ipv6.ip6_null_entry->rt6i_ref);
 			sfn->fn_flags = RTN_ROOT;
-			sfn->fn_sernum = fib6_new_sernum();
+			sfn->fn_sernum = sernum;
 
 			/* Now add the first leaf node to new subtree */
 
 			sn = fib6_add_1(sfn, &rt->rt6i_src.addr,
 					rt->rt6i_src.plen,
 					offsetof(struct rt6_info, rt6i_src),
-					allow_create, replace_required);
+					allow_create, replace_required, sernum);
 
 			if (IS_ERR(sn)) {
 				/* If it is failed, discard just allocated
@@ -920,7 +923,7 @@ int fib6_add(struct fib6_node *root, struct rt6_info *rt, struct nl_info *info,
 			sn = fib6_add_1(fn->subtree, &rt->rt6i_src.addr,
 					rt->rt6i_src.plen,
 					offsetof(struct rt6_info, rt6i_src),
-					allow_create, replace_required);
+					allow_create, replace_required, sernum);
 
 			if (IS_ERR(sn)) {
 				err = PTR_ERR(sn);
@@ -940,7 +943,7 @@ int fib6_add(struct fib6_node *root, struct rt6_info *rt, struct nl_info *info,
 	if (!err) {
 		fib6_start_gc(info->nl_net, rt);
 		if (!(rt->rt6i_flags & RTF_CACHE))
-			fib6_prune_clones(info->nl_net, pn);
+			fib6_prune_clones(info->nl_net, pn, sernum);
 	}
 
 out:
@@ -1352,6 +1355,7 @@ int fib6_del(struct rt6_info *rt, struct nl_info *info)
 	struct net *net = info->nl_net;
 	struct fib6_node *fn = rt->rt6i_node;
 	struct rt6_info **rtp;
+	u32 sernum = fib6_new_sernum();
 
 #if RT6_DEBUG >= 2
 	if (rt->dst.obsolete > 0) {
@@ -1364,6 +1368,7 @@ int fib6_del(struct rt6_info *rt, struct nl_info *info)
 
 	WARN_ON(!(fn->fn_flags & RTN_RTINFO));
 
+	fn->fn_sernum = sernum;
 	if (!(rt->rt6i_flags & RTF_CACHE)) {
 		struct fib6_node *pn = fn;
 #ifdef CONFIG_IPV6_SUBTREES
@@ -1374,7 +1379,7 @@ int fib6_del(struct rt6_info *rt, struct nl_info *info)
 			pn = pn->parent;
 		}
 #endif
-		fib6_prune_clones(info->nl_net, pn);
+		fib6_prune_clones(info->nl_net, pn, sernum);
 	}
 
 	/*
@@ -1521,6 +1526,9 @@ static int fib6_clean_node(struct fib6_walker_t *w)
 		.nl_net = c->net,
 	};
 
+	if (c->sernum)
+		c->w.node->fn_sernum = c->sernum;
+
 	for (rt = w->leaf; rt; rt = rt->dst.rt6_next) {
 		res = c->func(rt, c->arg);
 		if (res < 0) {
@@ -1554,7 +1562,7 @@ static int fib6_clean_node(struct fib6_walker_t *w)
 
 static void fib6_clean_tree(struct net *net, struct fib6_node *root,
 			    int (*func)(struct rt6_info *, void *arg),
-			    int prune, void *arg)
+			    int prune, u32 sernum, void *arg)
 {
 	struct fib6_cleaner_t c;
 
@@ -1563,6 +1571,7 @@ static void fib6_clean_tree(struct net *net, struct fib6_node *root,
 	c.w.prune = prune;
 	c.w.count = 0;
 	c.w.skip = 0;
+	c.sernum = sernum;
 	c.func = func;
 	c.arg = arg;
 	c.net = net;
@@ -1583,7 +1592,7 @@ void fib6_clean_all(struct net *net, int (*func)(struct rt6_info *, void *arg),
 		hlist_for_each_entry_rcu(table, head, tb6_hlist) {
 			write_lock_bh(&table->tb6_lock);
 			fib6_clean_tree(net, &table->tb6_root,
-					func, 0, arg);
+					func, 0, 0, arg);
 			write_unlock_bh(&table->tb6_lock);
 		}
 	}
@@ -1600,9 +1609,10 @@ static int fib6_prune_clone(struct rt6_info *rt, void *arg)
 	return 0;
 }
 
-static void fib6_prune_clones(struct net *net, struct fib6_node *fn)
+static void fib6_prune_clones(struct net *net, struct fib6_node *fn,
+			      u32 sernum)
 {
-	fib6_clean_tree(net, fn, fib6_prune_clone, 1, NULL);
+	fib6_clean_tree(net, fn, fib6_prune_clone, 1, sernum, NULL);
 }
 
 /*
@@ -1811,7 +1821,7 @@ struct ipv6_route_iter {
 	struct fib6_walker_t w;
 	loff_t skip;
 	struct fib6_table *tbl;
-	__u32 sernum;
+	u32 sernum;
 };
 
 static int ipv6_route_seq_show(struct seq_file *seq, void *v)
-- 
1.9.3
