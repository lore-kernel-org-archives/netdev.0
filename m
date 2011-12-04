From: David Miller <davem@davemloft.net>
Subject: [PATCH 1/3] ipv6: Various cleanups in ip6_route.c
Date: Sat, 03 Dec 2011 22:23:38 -0500 (EST)
Message-ID: <20111203.222338.2024179166710442989.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:32842 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752988Ab1LDDXm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Dec 2011 22:23:42 -0500
Received: from localhost (cpe-66-65-61-233.nyc.res.rr.com [66.65.61.233])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id pB43NdvD014229
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NO)
	for <netdev@vger.kernel.org>; Sat, 3 Dec 2011 19:23:41 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) x == NULL --> !x
2) x != NULL --> x
3) if() --> if ()
4) while() --> while ()
5) (x & BIT) == 0 --> !(x & BIT)
6) (x&BIT) --> (x & BIT)
7) x=y --> x = y
8) (BIT1|BIT2) --> (BIT1 | BIT2)
9) if ((x & BIT)) --> if (x & BIT)
10) proper argument and struct member alignment

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv6/ip6_fib.c |  115 +++++++++++++++++++++++++--------------------------
 1 files changed, 56 insertions(+), 59 deletions(-)

diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 424f063..7b47303 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -190,7 +190,7 @@ static struct fib6_table *fib6_alloc_table(struct net *net, u32 id)
 	struct fib6_table *table;
 
 	table = kzalloc(sizeof(*table), GFP_ATOMIC);
-	if (table != NULL) {
+	if (table) {
 		table->tb6_id = id;
 		table->tb6_root.leaf = net->ipv6.ip6_null_entry;
 		table->tb6_root.fn_flags = RTN_ROOT | RTN_TL_ROOT | RTN_RTINFO;
@@ -210,7 +210,7 @@ struct fib6_table *fib6_new_table(struct net *net, u32 id)
 		return tb;
 
 	tb = fib6_alloc_table(net, id);
-	if (tb != NULL)
+	if (tb)
 		fib6_link_table(net, tb);
 
 	return tb;
@@ -367,7 +367,7 @@ static int inet6_dump_fib(struct sk_buff *skb, struct netlink_callback *cb)
 	s_e = cb->args[1];
 
 	w = (void *)cb->args[2];
-	if (w == NULL) {
+	if (!w) {
 		/* New dump:
 		 *
 		 * 1. hook callback destructor.
@@ -379,7 +379,7 @@ static int inet6_dump_fib(struct sk_buff *skb, struct netlink_callback *cb)
 		 * 2. allocate and initialize walker.
 		 */
 		w = kzalloc(sizeof(*w), GFP_ATOMIC);
-		if (w == NULL)
+		if (!w)
 			return -ENOMEM;
 		w->func = fib6_dump_node;
 		cb->args[2] = (long)w;
@@ -467,7 +467,7 @@ static struct fib6_node * fib6_add_1(struct fib6_node *root, void *addr,
 
 		if (plen == fn->fn_bit) {
 			/* clean up an intermediate node */
-			if ((fn->fn_flags & RTN_RTINFO) == 0) {
+			if (!(fn->fn_flags & RTN_RTINFO)) {
 				rt6_release(fn->leaf);
 				fn->leaf = NULL;
 			}
@@ -512,7 +512,7 @@ static struct fib6_node * fib6_add_1(struct fib6_node *root, void *addr,
 
 	ln = node_alloc();
 
-	if (ln == NULL)
+	if (!ln)
 		return NULL;
 	ln->fn_bit = plen;
 
@@ -555,7 +555,7 @@ insert_above:
 		in = node_alloc();
 		ln = node_alloc();
 
-		if (in == NULL || ln == NULL) {
+		if (!in || !ln) {
 			if (in)
 				node_free(in);
 			if (ln)
@@ -609,7 +609,7 @@ insert_above:
 
 		ln = node_alloc();
 
-		if (ln == NULL)
+		if (!ln)
 			return NULL;
 
 		ln->fn_bit = plen;
@@ -642,15 +642,15 @@ static int fib6_add_rt2node(struct fib6_node *fn, struct rt6_info *rt,
 {
 	struct rt6_info *iter = NULL;
 	struct rt6_info **ins;
-	int replace = (NULL != info->nlh &&
-	    (info->nlh->nlmsg_flags&NLM_F_REPLACE));
-	int add = (NULL == info->nlh ||
-	    (info->nlh->nlmsg_flags&NLM_F_CREATE));
+	int replace = (info->nlh &&
+		       (info->nlh->nlmsg_flags & NLM_F_REPLACE));
+	int add = (!info->nlh ||
+		   (info->nlh->nlmsg_flags & NLM_F_CREATE));
 	int found = 0;
 
 	ins = &fn->leaf;
 
-	for (iter = fn->leaf; iter; iter=iter->dst.rt6_next) {
+	for (iter = fn->leaf; iter; iter = iter->dst.rt6_next) {
 		/*
 		 *	Search for duplicates
 		 */
@@ -659,8 +659,8 @@ static int fib6_add_rt2node(struct fib6_node *fn, struct rt6_info *rt,
 			/*
 			 *	Same priority level
 			 */
-			if (NULL != info->nlh &&
-			    (info->nlh->nlmsg_flags&NLM_F_EXCL))
+			if (info->nlh &&
+			    (info->nlh->nlmsg_flags & NLM_F_EXCL))
 				return -EEXIST;
 			if (replace) {
 				found++;
@@ -671,10 +671,10 @@ static int fib6_add_rt2node(struct fib6_node *fn, struct rt6_info *rt,
 			    iter->rt6i_idev == rt->rt6i_idev &&
 			    ipv6_addr_equal(&iter->rt6i_gateway,
 					    &rt->rt6i_gateway)) {
-				if (!(iter->rt6i_flags&RTF_EXPIRES))
+				if (!(iter->rt6i_flags & RTF_EXPIRES))
 					return -EEXIST;
 				iter->rt6i_expires = rt->rt6i_expires;
-				if (!(rt->rt6i_flags&RTF_EXPIRES)) {
+				if (!(rt->rt6i_flags & RTF_EXPIRES)) {
 					iter->rt6i_flags &= ~RTF_EXPIRES;
 					iter->rt6i_expires = 0;
 				}
@@ -707,7 +707,7 @@ add:
 		inet6_rt_notify(RTM_NEWROUTE, rt, info);
 		info->nl_net->ipv6.rt6_stats->fib_rt_entries++;
 
-		if ((fn->fn_flags & RTN_RTINFO) == 0) {
+		if (!(fn->fn_flags & RTN_RTINFO)) {
 			info->nl_net->ipv6.rt6_stats->fib_route_nodes++;
 			fn->fn_flags |= RTN_RTINFO;
 		}
@@ -725,7 +725,7 @@ add:
 		atomic_inc(&rt->rt6i_ref);
 		inet6_rt_notify(RTM_NEWROUTE, rt, info);
 		rt6_release(iter);
-		if ((fn->fn_flags & RTN_RTINFO) == 0) {
+		if (!(fn->fn_flags & RTN_RTINFO)) {
 			info->nl_net->ipv6.rt6_stats->fib_route_nodes++;
 			fn->fn_flags |= RTN_RTINFO;
 		}
@@ -737,7 +737,7 @@ add:
 static __inline__ void fib6_start_gc(struct net *net, struct rt6_info *rt)
 {
 	if (!timer_pending(&net->ipv6.ip6_fib_timer) &&
-	    (rt->rt6i_flags & (RTF_EXPIRES|RTF_CACHE)))
+	    (rt->rt6i_flags & (RTF_EXPIRES | RTF_CACHE)))
 		mod_timer(&net->ipv6.ip6_fib_timer,
 			  jiffies + net->ipv6.sysctl.ip6_rt_gc_interval);
 }
@@ -761,25 +761,26 @@ int fib6_add(struct fib6_node *root, struct rt6_info *rt, struct nl_info *info)
 	int err = -ENOMEM;
 	int allow_create = 1;
 	int replace_required = 0;
-	if (NULL != info->nlh) {
-		if (!(info->nlh->nlmsg_flags&NLM_F_CREATE))
+
+	if (info->nlh) {
+		if (!(info->nlh->nlmsg_flags & NLM_F_CREATE))
 			allow_create = 0;
-		if ((info->nlh->nlmsg_flags&NLM_F_REPLACE))
+		if (info->nlh->nlmsg_flags & NLM_F_REPLACE)
 			replace_required = 1;
 	}
 	if (!allow_create && !replace_required)
 		pr_warn("IPv6: RTM_NEWROUTE with no NLM_F_CREATE or NLM_F_REPLACE\n");
 
 	fn = fib6_add_1(root, &rt->rt6i_dst.addr, sizeof(struct in6_addr),
-		    rt->rt6i_dst.plen, offsetof(struct rt6_info, rt6i_dst),
-		    allow_create, replace_required);
+			rt->rt6i_dst.plen, offsetof(struct rt6_info, rt6i_dst),
+			allow_create, replace_required);
 
 	if (IS_ERR(fn)) {
 		err = PTR_ERR(fn);
 		fn = NULL;
 	}
 
-	if (fn == NULL)
+	if (!fn)
 		goto out;
 
 	pn = fn;
@@ -788,7 +789,7 @@ int fib6_add(struct fib6_node *root, struct rt6_info *rt, struct nl_info *info)
 	if (rt->rt6i_src.plen) {
 		struct fib6_node *sn;
 
-		if (fn->subtree == NULL) {
+		if (!fn->subtree) {
 			struct fib6_node *sfn;
 
 			/*
@@ -803,7 +804,7 @@ int fib6_add(struct fib6_node *root, struct rt6_info *rt, struct nl_info *info)
 
 			/* Create subtree root node */
 			sfn = node_alloc();
-			if (sfn == NULL)
+			if (!sfn)
 				goto st_failure;
 
 			sfn->leaf = info->nl_net->ipv6.ip6_null_entry;
@@ -818,7 +819,7 @@ int fib6_add(struct fib6_node *root, struct rt6_info *rt, struct nl_info *info)
 					offsetof(struct rt6_info, rt6i_src),
 					allow_create, replace_required);
 
-			if (sn == NULL) {
+			if (!sn) {
 				/* If it is failed, discard just allocated
 				   root, and then (in st_failure) stale node
 				   in main tree.
@@ -840,11 +841,11 @@ int fib6_add(struct fib6_node *root, struct rt6_info *rt, struct nl_info *info)
 				err = PTR_ERR(sn);
 				sn = NULL;
 			}
-			if (sn == NULL)
+			if (!sn)
 				goto st_failure;
 		}
 
-		if (fn->leaf == NULL) {
+		if (!fn->leaf) {
 			fn->leaf = rt;
 			atomic_inc(&rt->rt6i_ref);
 		}
@@ -853,10 +854,9 @@ int fib6_add(struct fib6_node *root, struct rt6_info *rt, struct nl_info *info)
 #endif
 
 	err = fib6_add_rt2node(fn, rt, info);
-
-	if (err == 0) {
+	if (!err) {
 		fib6_start_gc(info->nl_net, rt);
-		if (!(rt->rt6i_flags&RTF_CACHE))
+		if (!(rt->rt6i_flags & RTF_CACHE))
 			fib6_prune_clones(info->nl_net, pn, rt);
 	}
 
@@ -904,7 +904,7 @@ st_failure:
  */
 
 struct lookup_args {
-	int		offset;		/* key offset on rt6_info	*/
+	int			offset;		/* key offset on rt6_info	*/
 	const struct in6_addr	*addr;		/* search key			*/
 };
 
@@ -934,11 +934,10 @@ static struct fib6_node * fib6_lookup_1(struct fib6_node *root,
 			fn = next;
 			continue;
 		}
-
 		break;
 	}
 
-	while(fn) {
+	while (fn) {
 		if (FIB6_SUBTREE(fn) || fn->fn_flags & RTN_RTINFO) {
 			struct rt6key *key;
 
@@ -985,8 +984,7 @@ struct fib6_node * fib6_lookup(struct fib6_node *root, const struct in6_addr *da
 	};
 
 	fn = fib6_lookup_1(root, daddr ? args : args + 1);
-
-	if (fn == NULL || fn->fn_flags & RTN_TL_ROOT)
+	if (!fn || fn->fn_flags & RTN_TL_ROOT)
 		fn = root;
 
 	return fn;
@@ -1046,7 +1044,7 @@ struct fib6_node * fib6_locate(struct fib6_node *root,
 	}
 #endif
 
-	if (fn && fn->fn_flags&RTN_RTINFO)
+	if (fn && fn->fn_flags & RTN_RTINFO)
 		return fn;
 
 	return NULL;
@@ -1060,14 +1058,13 @@ struct fib6_node * fib6_locate(struct fib6_node *root,
 
 static struct rt6_info *fib6_find_prefix(struct net *net, struct fib6_node *fn)
 {
-	if (fn->fn_flags&RTN_ROOT)
+	if (fn->fn_flags & RTN_ROOT)
 		return net->ipv6.ip6_null_entry;
 
-	while(fn) {
-		if(fn->left)
+	while (fn) {
+		if (fn->left)
 			return fn->left->leaf;
-
-		if(fn->right)
+		if (fn->right)
 			return fn->right->leaf;
 
 		fn = FIB6_SUBTREE(fn);
@@ -1105,12 +1102,12 @@ static struct fib6_node *fib6_repair_tree(struct net *net,
 		if (children == 3 || FIB6_SUBTREE(fn)
 #ifdef CONFIG_IPV6_SUBTREES
 		    /* Subtree root (i.e. fn) may have one child */
-		    || (children && fn->fn_flags&RTN_ROOT)
+		    || (children && fn->fn_flags & RTN_ROOT)
 #endif
 		    ) {
 			fn->leaf = fib6_find_prefix(net, fn);
 #if RT6_DEBUG >= 2
-			if (fn->leaf==NULL) {
+			if (!fn->leaf) {
 				WARN_ON(!fn->leaf);
 				fn->leaf = net->ipv6.ip6_null_entry;
 			}
@@ -1143,7 +1140,7 @@ static struct fib6_node *fib6_repair_tree(struct net *net,
 
 		read_lock(&fib6_walker_lock);
 		FOR_WALKERS(w) {
-			if (child == NULL) {
+			if (!child) {
 				if (w->root == fn) {
 					w->root = w->node = NULL;
 					RT6_TRACE("W %p adjusted by delroot 1\n", w);
@@ -1172,7 +1169,7 @@ static struct fib6_node *fib6_repair_tree(struct net *net,
 		read_unlock(&fib6_walker_lock);
 
 		node_free(fn);
-		if (pn->fn_flags&RTN_RTINFO || FIB6_SUBTREE(pn))
+		if (pn->fn_flags & RTN_RTINFO || FIB6_SUBTREE(pn))
 			return pn;
 
 		rt6_release(pn->leaf);
@@ -1206,7 +1203,7 @@ static void fib6_del_route(struct fib6_node *fn, struct rt6_info **rtp,
 		if (w->state == FWS_C && w->leaf == rt) {
 			RT6_TRACE("walker %p adjusted by delroute\n", w);
 			w->leaf = rt->dst.rt6_next;
-			if (w->leaf == NULL)
+			if (!w->leaf)
 				w->state = FWS_U;
 		}
 	}
@@ -1215,7 +1212,7 @@ static void fib6_del_route(struct fib6_node *fn, struct rt6_info **rtp,
 	rt->dst.rt6_next = NULL;
 
 	/* If it was last route, expunge its radix tree node */
-	if (fn->leaf == NULL) {
+	if (!fn->leaf) {
 		fn->fn_flags &= ~RTN_RTINFO;
 		net->ipv6.rt6_stats->fib_route_nodes--;
 		fn = fib6_repair_tree(net, fn);
@@ -1229,7 +1226,7 @@ static void fib6_del_route(struct fib6_node *fn, struct rt6_info **rtp,
 		 * to still alive ones.
 		 */
 		while (fn) {
-			if (!(fn->fn_flags&RTN_RTINFO) && fn->leaf == rt) {
+			if (!(fn->fn_flags & RTN_RTINFO) && fn->leaf == rt) {
 				fn->leaf = fib6_find_prefix(net, fn);
 				atomic_inc(&fn->leaf->rt6i_ref);
 				rt6_release(rt);
@@ -1256,17 +1253,17 @@ int fib6_del(struct rt6_info *rt, struct nl_info *info)
 		return -ENOENT;
 	}
 #endif
-	if (fn == NULL || rt == net->ipv6.ip6_null_entry)
+	if (!fn || rt == net->ipv6.ip6_null_entry)
 		return -ENOENT;
 
 	WARN_ON(!(fn->fn_flags & RTN_RTINFO));
 
-	if (!(rt->rt6i_flags&RTF_CACHE)) {
+	if (!(rt->rt6i_flags & RTF_CACHE)) {
 		struct fib6_node *pn = fn;
 #ifdef CONFIG_IPV6_SUBTREES
 		/* clones of this route might be in another subtree */
 		if (rt->rt6i_src.plen) {
-			while (!(pn->fn_flags&RTN_ROOT))
+			while (!(pn->fn_flags & RTN_ROOT))
 				pn = pn->parent;
 			pn = pn->parent;
 		}
@@ -1317,11 +1314,11 @@ static int fib6_walk_continue(struct fib6_walker_t *w)
 
 	for (;;) {
 		fn = w->node;
-		if (fn == NULL)
+		if (!fn)
 			return 0;
 
 		if (w->prune && fn != w->root &&
-		    fn->fn_flags&RTN_RTINFO && w->state < FWS_C) {
+		    fn->fn_flags & RTN_RTINFO && w->state < FWS_C) {
 			w->state = FWS_C;
 			w->leaf = fn->leaf;
 		}
@@ -1350,7 +1347,7 @@ static int fib6_walk_continue(struct fib6_walker_t *w)
 			w->state = FWS_C;
 			w->leaf = fn->leaf;
 		case FWS_C:
-			if (w->leaf && fn->fn_flags&RTN_RTINFO) {
+			if (w->leaf && fn->fn_flags & RTN_RTINFO) {
 				int err;
 
 				if (w->count < w->skip) {
@@ -1524,7 +1521,7 @@ static int fib6_age(struct rt6_info *rt, void *arg)
 	 *	only if they are not in use now.
 	 */
 
-	if (rt->rt6i_flags&RTF_EXPIRES && rt->rt6i_expires) {
+	if (rt->rt6i_flags & RTF_EXPIRES && rt->rt6i_expires) {
 		if (time_after(now, rt->rt6i_expires)) {
 			RT6_TRACE("expiring %p\n", rt);
 			return -1;
-- 
1.7.7.3
