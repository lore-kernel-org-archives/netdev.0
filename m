From: Wei Wang <weiwan@google.com>
Subject: [PATCH net-next 16/16] ipv6: take care of rt6_stats
Date: Fri,  6 Oct 2017 12:06:11 -0700
Message-ID: <20171006190611.110633-17-tracywwnj@gmail.com>
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
 <20171006190611.110633-14-tracywwnj@gmail.com>
 <20171006190611.110633-15-tracywwnj@gmail.com>
 <20171006190611.110633-16-tracywwnj@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>,
        Martin KaFai Lau <kafai@fb.com>, Wei Wang <weiwan@google.com>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:49595 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752768AbdJFTG7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2017 15:06:59 -0400
Received: by mail-pf0-f178.google.com with SMTP id l188so9979537pfc.6
        for <netdev@vger.kernel.org>; Fri, 06 Oct 2017 12:06:59 -0700 (PDT)
In-Reply-To: <20171006190611.110633-16-tracywwnj@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>

Currently, most of the rt6_stats are not hooked up correctly. As the
last part of this patch series, hook up all existing rt6_stats and add
one new stat fib_rt_uncache to indicate the number of routes in the
uncached list.
For details of the stats, please refer to the comments added in
include/net/ip6_fib.h.

Note: fib_rt_alloc and fib_rt_uncache are not guaranteed to be modified
under a lock. So atomic_t is used for them.

Signed-off-by: Wei Wang <weiwan@google.com>
Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/ip6_fib.h | 15 +++++++++------
 net/ipv6/ip6_fib.c    | 42 ++++++++++++++++++++++++------------------
 net/ipv6/route.c      | 16 ++++++++++++++--
 3 files changed, 47 insertions(+), 26 deletions(-)

diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index 0b438b9bcb10..10c913816032 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -297,12 +297,15 @@ struct fib6_walker {
 };
 
 struct rt6_statistics {
-	__u32		fib_nodes;
-	__u32		fib_route_nodes;
-	__u32		fib_rt_alloc;		/* permanent routes	*/
-	__u32		fib_rt_entries;		/* rt entries in table	*/
-	__u32		fib_rt_cache;		/* cache routes		*/
-	__u32		fib_discarded_routes;
+	__u32		fib_nodes;		/* all fib6 nodes */
+	__u32		fib_route_nodes;	/* intermediate nodes */
+	__u32		fib_rt_entries;		/* rt entries in fib table */
+	__u32		fib_rt_cache;		/* cached rt entries in exception table */
+	__u32		fib_discarded_routes;	/* total number of routes delete */
+
+	/* The following stats are not protected by any lock */
+	atomic_t	fib_rt_alloc;		/* total number of routes alloced */
+	atomic_t	fib_rt_uncache;		/* rt entries in uncached list */
 };
 
 #define RTN_TL_ROOT	0x0001
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 3f95908b39c3..52a29ba32928 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -149,18 +149,21 @@ static __be32 addr_bit_set(const void *token, int fn_bit)
 	       addr[fn_bit >> 5];
 }
 
-static struct fib6_node *node_alloc(void)
+static struct fib6_node *node_alloc(struct net *net)
 {
 	struct fib6_node *fn;
 
 	fn = kmem_cache_zalloc(fib6_node_kmem, GFP_ATOMIC);
+	if (fn)
+		net->ipv6.rt6_stats->fib_nodes++;
 
 	return fn;
 }
 
-static void node_free_immediate(struct fib6_node *fn)
+static void node_free_immediate(struct net *net, struct fib6_node *fn)
 {
 	kmem_cache_free(fib6_node_kmem, fn);
+	net->ipv6.rt6_stats->fib_nodes--;
 }
 
 static void node_free_rcu(struct rcu_head *head)
@@ -170,9 +173,10 @@ static void node_free_rcu(struct rcu_head *head)
 	kmem_cache_free(fib6_node_kmem, fn);
 }
 
-static void node_free(struct fib6_node *fn)
+static void node_free(struct net *net, struct fib6_node *fn)
 {
 	call_rcu(&fn->rcu, node_free_rcu);
+	net->ipv6.rt6_stats->fib_nodes--;
 }
 
 void rt6_free_pcpu(struct rt6_info *non_pcpu_rt)
@@ -583,7 +587,8 @@ static int inet6_dump_fib(struct sk_buff *skb, struct netlink_callback *cb)
  *	node.
  */
 
-static struct fib6_node *fib6_add_1(struct fib6_table *table,
+static struct fib6_node *fib6_add_1(struct net *net,
+				    struct fib6_table *table,
 				    struct fib6_node *root,
 				    struct in6_addr *addr, int plen,
 				    int offset, int allow_create,
@@ -675,7 +680,7 @@ static struct fib6_node *fib6_add_1(struct fib6_table *table,
 	 *	Create new leaf node without children.
 	 */
 
-	ln = node_alloc();
+	ln = node_alloc(net);
 
 	if (!ln)
 		return ERR_PTR(-ENOMEM);
@@ -716,14 +721,14 @@ static struct fib6_node *fib6_add_1(struct fib6_table *table,
 	 *	(new leaf node)[ln] (old node)[fn]
 	 */
 	if (plen > bit) {
-		in = node_alloc();
-		ln = node_alloc();
+		in = node_alloc(net);
+		ln = node_alloc(net);
 
 		if (!in || !ln) {
 			if (in)
-				node_free_immediate(in);
+				node_free_immediate(net, in);
 			if (ln)
-				node_free_immediate(ln);
+				node_free_immediate(net, ln);
 			return ERR_PTR(-ENOMEM);
 		}
 
@@ -768,7 +773,7 @@ static struct fib6_node *fib6_add_1(struct fib6_table *table,
 		 *	     (old node)[fn] NULL
 		 */
 
-		ln = node_alloc();
+		ln = node_alloc(net);
 
 		if (!ln)
 			return ERR_PTR(-ENOMEM);
@@ -1065,6 +1070,7 @@ static int fib6_add_rt2node(struct fib6_node *fn, struct rt6_info *rt,
 						fn->rr_ptr = NULL;
 					rt6_release(iter);
 					nsiblings--;
+					info->nl_net->ipv6.rt6_stats->fib_rt_entries--;
 				} else {
 					ins = &iter->dst.rt6_next;
 				}
@@ -1140,7 +1146,7 @@ int fib6_add(struct fib6_node *root, struct rt6_info *rt,
 	if (!allow_create && !replace_required)
 		pr_warn("RTM_NEWROUTE with no NLM_F_CREATE or NLM_F_REPLACE\n");
 
-	fn = fib6_add_1(table, root,
+	fn = fib6_add_1(info->nl_net, table, root,
 			&rt->rt6i_dst.addr, rt->rt6i_dst.plen,
 			offsetof(struct rt6_info, rt6i_dst), allow_create,
 			replace_required, extack);
@@ -1170,7 +1176,7 @@ int fib6_add(struct fib6_node *root, struct rt6_info *rt,
 			 */
 
 			/* Create subtree root node */
-			sfn = node_alloc();
+			sfn = node_alloc(info->nl_net);
 			if (!sfn)
 				goto failure;
 
@@ -1181,8 +1187,8 @@ int fib6_add(struct fib6_node *root, struct rt6_info *rt,
 
 			/* Now add the first leaf node to new subtree */
 
-			sn = fib6_add_1(table, sfn, &rt->rt6i_src.addr,
-					rt->rt6i_src.plen,
+			sn = fib6_add_1(info->nl_net, table, sfn,
+					&rt->rt6i_src.addr, rt->rt6i_src.plen,
 					offsetof(struct rt6_info, rt6i_src),
 					allow_create, replace_required, extack);
 
@@ -1191,7 +1197,7 @@ int fib6_add(struct fib6_node *root, struct rt6_info *rt,
 				   root, and then (in failure) stale node
 				   in main tree.
 				 */
-				node_free_immediate(sfn);
+				node_free_immediate(info->nl_net, sfn);
 				err = PTR_ERR(sn);
 				goto failure;
 			}
@@ -1200,8 +1206,8 @@ int fib6_add(struct fib6_node *root, struct rt6_info *rt,
 			rcu_assign_pointer(sfn->parent, fn);
 			rcu_assign_pointer(fn->subtree, sfn);
 		} else {
-			sn = fib6_add_1(table, FIB6_SUBTREE(fn), &rt->rt6i_src.addr,
-					rt->rt6i_src.plen,
+			sn = fib6_add_1(info->nl_net, table, FIB6_SUBTREE(fn),
+					&rt->rt6i_src.addr, rt->rt6i_src.plen,
 					offsetof(struct rt6_info, rt6i_src),
 					allow_create, replace_required, extack);
 
@@ -1609,7 +1615,7 @@ static struct fib6_node *fib6_repair_tree(struct net *net,
 		}
 		read_unlock(&net->ipv6.fib6_walker_lock);
 
-		node_free(fn);
+		node_free(net, fn);
 		if (pn->fn_flags & RTN_RTINFO || FIB6_SUBTREE(pn))
 			return pn;
 
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index cf44d0994b1e..399d1bceec4a 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -143,9 +143,11 @@ static void rt6_uncached_list_del(struct rt6_info *rt)
 {
 	if (!list_empty(&rt->rt6i_uncached)) {
 		struct uncached_list *ul = rt->rt6i_uncached_list;
+		struct net *net = dev_net(rt->dst.dev);
 
 		spin_lock_bh(&ul->lock);
 		list_del(&rt->rt6i_uncached);
+		atomic_dec(&net->ipv6.rt6_stats->fib_rt_uncache);
 		spin_unlock_bh(&ul->lock);
 	}
 }
@@ -359,8 +361,10 @@ static struct rt6_info *__ip6_dst_alloc(struct net *net,
 	struct rt6_info *rt = dst_alloc(&net->ipv6.ip6_dst_ops, dev,
 					1, DST_OBSOLETE_FORCE_CHK, flags);
 
-	if (rt)
+	if (rt) {
 		rt6_info_init(rt);
+		atomic_inc(&net->ipv6.rt6_stats->fib_rt_alloc);
+	}
 
 	return rt;
 }
@@ -1156,6 +1160,8 @@ static DEFINE_SPINLOCK(rt6_exception_lock);
 static void rt6_remove_exception(struct rt6_exception_bucket *bucket,
 				 struct rt6_exception *rt6_ex)
 {
+	struct net *net = dev_net(rt6_ex->rt6i->dst.dev);
+
 	if (!bucket || !rt6_ex)
 		return;
 	rt6_ex->rt6i->rt6i_node = NULL;
@@ -1164,6 +1170,7 @@ static void rt6_remove_exception(struct rt6_exception_bucket *bucket,
 	kfree_rcu(rt6_ex, rcu);
 	WARN_ON_ONCE(!bucket->depth);
 	bucket->depth--;
+	net->ipv6.rt6_stats->fib_rt_cache--;
 }
 
 /* Remove oldest rt6_ex in bucket and free the memory
@@ -1270,6 +1277,7 @@ __rt6_find_exception_rcu(struct rt6_exception_bucket **bucket,
 static int rt6_insert_exception(struct rt6_info *nrt,
 				struct rt6_info *ort)
 {
+	struct net *net = dev_net(ort->dst.dev);
 	struct rt6_exception_bucket *bucket;
 	struct in6_addr *src_key = NULL;
 	struct rt6_exception *rt6_ex;
@@ -1339,6 +1347,7 @@ static int rt6_insert_exception(struct rt6_info *nrt,
 	nrt->rt6i_node = ort->rt6i_node;
 	hlist_add_head_rcu(&rt6_ex->hlist, &bucket->chain);
 	bucket->depth++;
+	net->ipv6.rt6_stats->fib_rt_cache++;
 
 	if (bucket->depth > FIB6_MAX_DEPTH)
 		rt6_exception_remove_oldest(bucket);
@@ -1714,6 +1723,7 @@ struct rt6_info *ip6_pol_route(struct net *net, struct fib6_table *table,
 			 * No need for another dst_hold()
 			 */
 			rt6_uncached_list_add(uncached_rt);
+			atomic_inc(&net->ipv6.rt6_stats->fib_rt_uncache);
 		} else {
 			uncached_rt = net->ipv6.ip6_null_entry;
 			dst_hold(&uncached_rt->dst);
@@ -1894,6 +1904,7 @@ struct dst_entry *ip6_blackhole_route(struct net *net, struct dst_entry *dst_ori
 		       DST_OBSOLETE_NONE, 0);
 	if (rt) {
 		rt6_info_init(rt);
+		atomic_inc(&net->ipv6.rt6_stats->fib_rt_alloc);
 
 		new = &rt->dst;
 		new->__use = 1;
@@ -2341,6 +2352,7 @@ struct dst_entry *icmp6_dst_alloc(struct net_device *dev,
 	 * do proper release of the net_device
 	 */
 	rt6_uncached_list_add(rt);
+	atomic_inc(&net->ipv6.rt6_stats->fib_rt_uncache);
 
 	dst = xfrm_lookup(net, &rt->dst, flowi6_to_flowi(fl6), NULL, 0);
 
@@ -4422,7 +4434,7 @@ static int rt6_stats_seq_show(struct seq_file *seq, void *v)
 	seq_printf(seq, "%04x %04x %04x %04x %04x %04x %04x\n",
 		   net->ipv6.rt6_stats->fib_nodes,
 		   net->ipv6.rt6_stats->fib_route_nodes,
-		   net->ipv6.rt6_stats->fib_rt_alloc,
+		   atomic_read(&net->ipv6.rt6_stats->fib_rt_alloc),
 		   net->ipv6.rt6_stats->fib_rt_entries,
 		   net->ipv6.rt6_stats->fib_rt_cache,
 		   dst_entries_get_slow(&net->ipv6.ip6_dst_ops),
-- 
2.14.2.920.gcf0c67979c-goog
