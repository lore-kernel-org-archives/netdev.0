From: Shaohua Li <shli@kernel.org>
Subject: [PATCH net-next V2] net ipv6: convert fib6_table rwlock to a percpu lock
Date: Fri,  4 Aug 2017 09:38:28 -0700
Message-ID: <2dcefcf7e75a5c242a20d7904096be91addbfba7.1501864467.git.shli@fb.com>
Cc: Kernel-team@fb.com, Shaohua Li <shli@fb.com>,
        Wei Wang <weiwan@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Stephen Hemminger <stephen@networkplumber.org>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:37654 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752225AbdHDQic (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 4 Aug 2017 12:38:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shaohua Li <shli@fb.com>

In a syn flooding test, the fib6_table rwlock is a significant
bottleneck. While converting the rwlock to rcu sounds straighforward,
but is very challenging if it's possible. A percpu spinlock (lglock has
been removed from kernel, so I added a simple implementation here) is
quite trival for this problem since updating the routing table is a rare
event. In my test, the server receives around 1.5 Mpps in syn flooding
test without the patch in a dual sockets and 56-CPU system. With the
patch, the server receives around 3.8Mpps, and perf report doesn't show
the locking issue.

Of course the percpu lock isn't as good as rcu, so this isn't intended
to replace rcu, but this is much better than current readwrite lock.
Before we have a rcu implementation, this is a good temporary solution.
Plus, this is a trival change, there is nothing to prevent pursuing a
rcu implmentation.

Cc: Wei Wang <weiwan@google.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>
Signed-off-by: Shaohua Li <shli@fb.com>
---
 include/net/ip6_fib.h | 57 +++++++++++++++++++++++++++++++++++++-
 net/ipv6/addrconf.c   |  8 +++---
 net/ipv6/ip6_fib.c    | 76 ++++++++++++++++++++++++++++-----------------------
 net/ipv6/route.c      | 54 ++++++++++++++++++------------------
 4 files changed, 129 insertions(+), 66 deletions(-)

diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index 1d790ea..124eb04 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -247,7 +247,7 @@ struct rt6_statistics {
 struct fib6_table {
 	struct hlist_node	tb6_hlist;
 	u32			tb6_id;
-	rwlock_t		tb6_lock;
+	spinlock_t __percpu	*percpu_tb6_lock;
 	struct fib6_node	tb6_root;
 	struct inet_peer_base	tb6_peers;
 	unsigned int		flags;
@@ -255,6 +255,61 @@ struct fib6_table {
 #define RT6_TABLE_HAS_DFLT_ROUTER	BIT(0)
 };
 
+static inline void fib6_table_read_lock_bh(struct fib6_table *table)
+{
+	preempt_disable();
+	spin_lock_bh(this_cpu_ptr(table->percpu_tb6_lock));
+}
+
+static inline void fib6_table_read_unlock_bh(struct fib6_table *table)
+{
+	spin_unlock_bh(this_cpu_ptr(table->percpu_tb6_lock));
+	preempt_enable();
+}
+
+static inline void fib6_table_read_lock(struct fib6_table *table)
+{
+	preempt_disable();
+	spin_lock(this_cpu_ptr(table->percpu_tb6_lock));
+}
+
+static inline void fib6_table_read_unlock(struct fib6_table *table)
+{
+	spin_unlock(this_cpu_ptr(table->percpu_tb6_lock));
+	preempt_enable();
+}
+
+static inline void fib6_table_write_lock_bh(struct fib6_table *table)
+{
+	int first = nr_cpu_ids;
+	int i;
+
+	for_each_possible_cpu(i) {
+		if (first == nr_cpu_ids) {
+			first = i;
+			spin_lock_bh(per_cpu_ptr(table->percpu_tb6_lock, i));
+		} else
+			spin_lock_nest_lock(
+				per_cpu_ptr(table->percpu_tb6_lock, i),
+				per_cpu_ptr(table->percpu_tb6_lock, first));
+	}
+}
+
+static inline void fib6_table_write_unlock_bh(struct fib6_table *table)
+{
+	int first = nr_cpu_ids;
+	int i;
+
+	for_each_possible_cpu(i) {
+		if (first == nr_cpu_ids) {
+			first = i;
+			continue;
+		}
+		spin_unlock(per_cpu_ptr(table->percpu_tb6_lock, i));
+	}
+	spin_unlock_bh(per_cpu_ptr(table->percpu_tb6_lock, first));
+}
+
 #define RT6_TABLE_UNSPEC	RT_TABLE_UNSPEC
 #define RT6_TABLE_MAIN		RT_TABLE_MAIN
 #define RT6_TABLE_DFLT		RT6_TABLE_MAIN
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 30ee23e..22e2ad2 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2313,7 +2313,7 @@ static struct rt6_info *addrconf_get_prefix_route(const struct in6_addr *pfx,
 	if (!table)
 		return NULL;
 
-	read_lock_bh(&table->tb6_lock);
+	fib6_table_read_lock_bh(table);
 	fn = fib6_locate(&table->tb6_root, pfx, plen, NULL, 0);
 	if (!fn)
 		goto out;
@@ -2330,7 +2330,7 @@ static struct rt6_info *addrconf_get_prefix_route(const struct in6_addr *pfx,
 		break;
 	}
 out:
-	read_unlock_bh(&table->tb6_lock);
+	fib6_table_read_unlock_bh(table);
 	return rt;
 }
 
@@ -5929,7 +5929,7 @@ void addrconf_disable_policy_idev(struct inet6_dev *idev, int val)
 			struct fib6_table *table = rt->rt6i_table;
 			int cpu;
 
-			read_lock(&table->tb6_lock);
+			fib6_table_read_lock(table);
 			addrconf_set_nopolicy(ifa->rt, val);
 			if (rt->rt6i_pcpu) {
 				for_each_possible_cpu(cpu) {
@@ -5939,7 +5939,7 @@ void addrconf_disable_policy_idev(struct inet6_dev *idev, int val)
 					addrconf_set_nopolicy(*rtp, val);
 				}
 			}
-			read_unlock(&table->tb6_lock);
+			fib6_table_read_unlock(table);
 		}
 		spin_unlock(&ifa->lock);
 	}
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 69ed004..a6ae228 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -187,8 +187,16 @@ static void fib6_link_table(struct net *net, struct fib6_table *tb)
 	 * Initialize table lock at a single place to give lockdep a key,
 	 * tables aren't visible prior to being linked to the list.
 	 */
-	rwlock_init(&tb->tb6_lock);
-
+	for_each_possible_cpu(h) {
+		/*
+		 * make sure the first lock and other locks have different
+		 * lockdep map, so we can treat the first lock as nested lock
+		 */
+		if (h == 0)
+			spin_lock_init(per_cpu_ptr(tb->percpu_tb6_lock, h));
+		else
+			spin_lock_init(per_cpu_ptr(tb->percpu_tb6_lock, h));
+	}
 	h = tb->tb6_id & (FIB6_TABLE_HASHSZ - 1);
 
 	/*
@@ -198,23 +206,34 @@ static void fib6_link_table(struct net *net, struct fib6_table *tb)
 	hlist_add_head_rcu(&tb->tb6_hlist, &net->ipv6.fib_table_hash[h]);
 }
 
-#ifdef CONFIG_IPV6_MULTIPLE_TABLES
-
-static struct fib6_table *fib6_alloc_table(struct net *net, u32 id)
+static struct fib6_table *fib6_alloc_table(struct net *net, u32 id, gfp_t gfp)
 {
 	struct fib6_table *table;
 
-	table = kzalloc(sizeof(*table), GFP_ATOMIC);
-	if (table) {
+	table = kzalloc(sizeof(*table), gfp);
+	if (!table)
+		return NULL;
+	table->percpu_tb6_lock = alloc_percpu_gfp(struct spinlock, gfp);
+	if (table->percpu_tb6_lock) {
 		table->tb6_id = id;
 		table->tb6_root.leaf = net->ipv6.ip6_null_entry;
 		table->tb6_root.fn_flags = RTN_ROOT | RTN_TL_ROOT | RTN_RTINFO;
 		inet_peer_base_init(&table->tb6_peers);
+	} else {
+		kfree(table);
+		return NULL;
 	}
 
 	return table;
 }
 
+static void fib6_free_table(struct fib6_table *table)
+{
+	free_percpu(table->percpu_tb6_lock);
+	kfree(table);
+}
+
+#ifdef CONFIG_IPV6_MULTIPLE_TABLES
 struct fib6_table *fib6_new_table(struct net *net, u32 id)
 {
 	struct fib6_table *tb;
@@ -225,7 +244,7 @@ struct fib6_table *fib6_new_table(struct net *net, u32 id)
 	if (tb)
 		return tb;
 
-	tb = fib6_alloc_table(net, id);
+	tb = fib6_alloc_table(net, id, GFP_ATOMIC);
 	if (tb)
 		fib6_link_table(net, tb);
 
@@ -462,9 +481,9 @@ static int fib6_dump_table(struct fib6_table *table, struct sk_buff *skb,
 		w->count = 0;
 		w->skip = 0;
 
-		read_lock_bh(&table->tb6_lock);
+		fib6_table_read_lock_bh(table);
 		res = fib6_walk(net, w);
-		read_unlock_bh(&table->tb6_lock);
+		fib6_table_read_unlock_bh(table);
 		if (res > 0) {
 			cb->args[4] = 1;
 			cb->args[5] = w->root->fn_sernum;
@@ -479,9 +498,9 @@ static int fib6_dump_table(struct fib6_table *table, struct sk_buff *skb,
 		} else
 			w->skip = 0;
 
-		read_lock_bh(&table->tb6_lock);
+		fib6_table_read_lock_bh(table);
 		res = fib6_walk_continue(w);
-		read_unlock_bh(&table->tb6_lock);
+		fib6_table_read_unlock_bh(table);
 		if (res <= 0) {
 			fib6_walker_unlink(net, w);
 			cb->args[4] = 0;
@@ -1811,10 +1830,10 @@ static void __fib6_clean_all(struct net *net,
 	for (h = 0; h < FIB6_TABLE_HASHSZ; h++) {
 		head = &net->ipv6.fib_table_hash[h];
 		hlist_for_each_entry_rcu(table, head, tb6_hlist) {
-			write_lock_bh(&table->tb6_lock);
+			fib6_table_write_lock_bh(table);
 			fib6_clean_tree(net, &table->tb6_root,
 					func, false, sernum, arg);
-			write_unlock_bh(&table->tb6_lock);
+			fib6_table_write_unlock_bh(table);
 		}
 	}
 	rcu_read_unlock();
@@ -1962,27 +1981,16 @@ static int __net_init fib6_net_init(struct net *net)
 	if (!net->ipv6.fib_table_hash)
 		goto out_rt6_stats;
 
-	net->ipv6.fib6_main_tbl = kzalloc(sizeof(*net->ipv6.fib6_main_tbl),
-					  GFP_KERNEL);
+	net->ipv6.fib6_main_tbl = fib6_alloc_table(net, RT6_TABLE_MAIN,
+		GFP_KERNEL);
 	if (!net->ipv6.fib6_main_tbl)
 		goto out_fib_table_hash;
 
-	net->ipv6.fib6_main_tbl->tb6_id = RT6_TABLE_MAIN;
-	net->ipv6.fib6_main_tbl->tb6_root.leaf = net->ipv6.ip6_null_entry;
-	net->ipv6.fib6_main_tbl->tb6_root.fn_flags =
-		RTN_ROOT | RTN_TL_ROOT | RTN_RTINFO;
-	inet_peer_base_init(&net->ipv6.fib6_main_tbl->tb6_peers);
-
 #ifdef CONFIG_IPV6_MULTIPLE_TABLES
-	net->ipv6.fib6_local_tbl = kzalloc(sizeof(*net->ipv6.fib6_local_tbl),
-					   GFP_KERNEL);
+	net->ipv6.fib6_local_tbl = fib6_alloc_table(net, RT6_TABLE_LOCAL,
+		GFP_KERNEL);
 	if (!net->ipv6.fib6_local_tbl)
 		goto out_fib6_main_tbl;
-	net->ipv6.fib6_local_tbl->tb6_id = RT6_TABLE_LOCAL;
-	net->ipv6.fib6_local_tbl->tb6_root.leaf = net->ipv6.ip6_null_entry;
-	net->ipv6.fib6_local_tbl->tb6_root.fn_flags =
-		RTN_ROOT | RTN_TL_ROOT | RTN_RTINFO;
-	inet_peer_base_init(&net->ipv6.fib6_local_tbl->tb6_peers);
 #endif
 	fib6_tables_init(net);
 
@@ -1990,7 +1998,7 @@ static int __net_init fib6_net_init(struct net *net)
 
 #ifdef CONFIG_IPV6_MULTIPLE_TABLES
 out_fib6_main_tbl:
-	kfree(net->ipv6.fib6_main_tbl);
+	fib6_free_table(net->ipv6.fib6_main_tbl);
 #endif
 out_fib_table_hash:
 	kfree(net->ipv6.fib_table_hash);
@@ -2008,10 +2016,10 @@ static void fib6_net_exit(struct net *net)
 
 #ifdef CONFIG_IPV6_MULTIPLE_TABLES
 	inetpeer_invalidate_tree(&net->ipv6.fib6_local_tbl->tb6_peers);
-	kfree(net->ipv6.fib6_local_tbl);
+	fib6_free_table(net->ipv6.fib6_local_tbl);
 #endif
 	inetpeer_invalidate_tree(&net->ipv6.fib6_main_tbl->tb6_peers);
-	kfree(net->ipv6.fib6_main_tbl);
+	fib6_free_table(net->ipv6.fib6_main_tbl);
 	kfree(net->ipv6.fib_table_hash);
 	kfree(net->ipv6.rt6_stats);
 	fib6_notifier_exit(net);
@@ -2175,9 +2183,9 @@ static void *ipv6_route_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 
 iter_table:
 	ipv6_route_check_sernum(iter);
-	read_lock(&iter->tbl->tb6_lock);
+	fib6_table_read_lock(iter->tbl);
 	r = fib6_walk_continue(&iter->w);
-	read_unlock(&iter->tbl->tb6_lock);
+	fib6_table_read_unlock(iter->tbl);
 	if (r > 0) {
 		if (v)
 			++*pos;
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index aba07fc..9e2d141 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -877,7 +877,7 @@ static struct rt6_info *ip6_pol_route_lookup(struct net *net,
 	struct fib6_node *fn;
 	struct rt6_info *rt;
 
-	read_lock_bh(&table->tb6_lock);
+	fib6_table_read_lock_bh(table);
 	fn = fib6_lookup(&table->tb6_root, &fl6->daddr, &fl6->saddr);
 restart:
 	rt = fn->leaf;
@@ -890,7 +890,7 @@ static struct rt6_info *ip6_pol_route_lookup(struct net *net,
 			goto restart;
 	}
 	dst_use(&rt->dst, jiffies);
-	read_unlock_bh(&table->tb6_lock);
+	fib6_table_read_unlock_bh(table);
 
 	trace_fib6_table_lookup(net, rt, table->tb6_id, fl6);
 
@@ -944,9 +944,9 @@ static int __ip6_ins_rt(struct rt6_info *rt, struct nl_info *info,
 	struct fib6_table *table;
 
 	table = rt->rt6i_table;
-	write_lock_bh(&table->tb6_lock);
+	fib6_table_write_lock_bh(table);
 	err = fib6_add(&table->tb6_root, rt, info, mxc, extack);
-	write_unlock_bh(&table->tb6_lock);
+	fib6_table_write_unlock_bh(table);
 
 	return err;
 }
@@ -1044,7 +1044,7 @@ static struct rt6_info *rt6_make_pcpu_route(struct rt6_info *rt)
 		return net->ipv6.ip6_null_entry;
 	}
 
-	read_lock_bh(&table->tb6_lock);
+	fib6_table_read_lock_bh(table);
 	if (rt->rt6i_pcpu) {
 		p = this_cpu_ptr(rt->rt6i_pcpu);
 		prev = cmpxchg(p, NULL, pcpu_rt);
@@ -1065,7 +1065,7 @@ static struct rt6_info *rt6_make_pcpu_route(struct rt6_info *rt)
 	}
 	dst_hold(&pcpu_rt->dst);
 	rt6_dst_from_metrics_check(pcpu_rt);
-	read_unlock_bh(&table->tb6_lock);
+	fib6_table_read_unlock_bh(table);
 	return pcpu_rt;
 }
 
@@ -1081,7 +1081,7 @@ struct rt6_info *ip6_pol_route(struct net *net, struct fib6_table *table,
 	if (net->ipv6.devconf_all->forwarding == 0)
 		strict |= RT6_LOOKUP_F_REACHABLE;
 
-	read_lock_bh(&table->tb6_lock);
+	fib6_table_read_lock_bh(table);
 
 	fn = fib6_lookup(&table->tb6_root, &fl6->daddr, &fl6->saddr);
 	saved_fn = fn;
@@ -1108,7 +1108,7 @@ struct rt6_info *ip6_pol_route(struct net *net, struct fib6_table *table,
 
 	if (rt == net->ipv6.ip6_null_entry || (rt->rt6i_flags & RTF_CACHE)) {
 		dst_use(&rt->dst, jiffies);
-		read_unlock_bh(&table->tb6_lock);
+		fib6_table_read_unlock_bh(table);
 
 		rt6_dst_from_metrics_check(rt);
 
@@ -1125,7 +1125,7 @@ struct rt6_info *ip6_pol_route(struct net *net, struct fib6_table *table,
 		struct rt6_info *uncached_rt;
 
 		dst_use(&rt->dst, jiffies);
-		read_unlock_bh(&table->tb6_lock);
+		fib6_table_read_unlock_bh(table);
 
 		uncached_rt = ip6_rt_cache_alloc(rt, &fl6->daddr, NULL);
 		dst_release(&rt->dst);
@@ -1153,14 +1153,14 @@ struct rt6_info *ip6_pol_route(struct net *net, struct fib6_table *table,
 		pcpu_rt = rt6_get_pcpu_route(rt);
 
 		if (pcpu_rt) {
-			read_unlock_bh(&table->tb6_lock);
+			fib6_table_read_unlock_bh(table);
 		} else {
 			/* We have to do the read_unlock first
 			 * because rt6_make_pcpu_route() may trigger
 			 * ip6_dst_gc() which will take the write_lock.
 			 */
 			dst_hold(&rt->dst);
-			read_unlock_bh(&table->tb6_lock);
+			fib6_table_read_unlock_bh(table);
 			pcpu_rt = rt6_make_pcpu_route(rt);
 			dst_release(&rt->dst);
 		}
@@ -1503,7 +1503,7 @@ static struct rt6_info *__ip6_route_redirect(struct net *net,
 	 * routes.
 	 */
 
-	read_lock_bh(&table->tb6_lock);
+	fib6_table_read_lock_bh(table);
 	fn = fib6_lookup(&table->tb6_root, &fl6->daddr, &fl6->saddr);
 restart:
 	for (rt = fn->leaf; rt; rt = rt->dst.rt6_next) {
@@ -1536,7 +1536,7 @@ static struct rt6_info *__ip6_route_redirect(struct net *net,
 out:
 	dst_hold(&rt->dst);
 
-	read_unlock_bh(&table->tb6_lock);
+	fib6_table_read_unlock_bh(table);
 
 	trace_fib6_table_lookup(net, rt, table->tb6_id, fl6);
 	return rt;
@@ -2140,9 +2140,9 @@ static int __ip6_del_rt(struct rt6_info *rt, struct nl_info *info)
 	}
 
 	table = rt->rt6i_table;
-	write_lock_bh(&table->tb6_lock);
+	fib6_table_write_lock_bh(table);
 	err = fib6_del(rt, info);
-	write_unlock_bh(&table->tb6_lock);
+	fib6_table_write_unlock_bh(table);
 
 out:
 	ip6_rt_put(rt);
@@ -2168,7 +2168,7 @@ static int __ip6_del_rt_siblings(struct rt6_info *rt, struct fib6_config *cfg)
 	if (rt == net->ipv6.ip6_null_entry)
 		goto out_put;
 	table = rt->rt6i_table;
-	write_lock_bh(&table->tb6_lock);
+	fib6_table_write_lock_bh(table);
 
 	if (rt->rt6i_nsiblings && cfg->fc_delete_all_nh) {
 		struct rt6_info *sibling, *next_sibling;
@@ -2198,7 +2198,7 @@ static int __ip6_del_rt_siblings(struct rt6_info *rt, struct fib6_config *cfg)
 
 	err = fib6_del(rt, info);
 out_unlock:
-	write_unlock_bh(&table->tb6_lock);
+	fib6_table_write_unlock_bh(table);
 out_put:
 	ip6_rt_put(rt);
 
@@ -2223,7 +2223,7 @@ static int ip6_route_del(struct fib6_config *cfg,
 		return err;
 	}
 
-	read_lock_bh(&table->tb6_lock);
+	fib6_table_read_lock_bh(table);
 
 	fn = fib6_locate(&table->tb6_root,
 			 &cfg->fc_dst, cfg->fc_dst_len,
@@ -2246,7 +2246,7 @@ static int ip6_route_del(struct fib6_config *cfg,
 			if (cfg->fc_protocol && cfg->fc_protocol != rt->rt6i_protocol)
 				continue;
 			dst_hold(&rt->dst);
-			read_unlock_bh(&table->tb6_lock);
+			fib6_table_read_unlock_bh(table);
 
 			/* if gateway was specified only delete the one hop */
 			if (cfg->fc_flags & RTF_GATEWAY)
@@ -2255,7 +2255,7 @@ static int ip6_route_del(struct fib6_config *cfg,
 			return __ip6_del_rt_siblings(rt, cfg);
 		}
 	}
-	read_unlock_bh(&table->tb6_lock);
+	fib6_table_read_unlock_bh(table);
 
 	return err;
 }
@@ -2434,7 +2434,7 @@ static struct rt6_info *rt6_get_route_info(struct net *net,
 	if (!table)
 		return NULL;
 
-	read_lock_bh(&table->tb6_lock);
+	fib6_table_read_lock_bh(table);
 	fn = fib6_locate(&table->tb6_root, prefix, prefixlen, NULL, 0);
 	if (!fn)
 		goto out;
@@ -2450,7 +2450,7 @@ static struct rt6_info *rt6_get_route_info(struct net *net,
 		break;
 	}
 out:
-	read_unlock_bh(&table->tb6_lock);
+	fib6_table_read_unlock_bh(table);
 	return rt;
 }
 
@@ -2495,7 +2495,7 @@ struct rt6_info *rt6_get_dflt_router(const struct in6_addr *addr, struct net_dev
 	if (!table)
 		return NULL;
 
-	read_lock_bh(&table->tb6_lock);
+	fib6_table_read_lock_bh(table);
 	for (rt = table->tb6_root.leaf; rt; rt = rt->dst.rt6_next) {
 		if (dev == rt->dst.dev &&
 		    ((rt->rt6i_flags & (RTF_ADDRCONF | RTF_DEFAULT)) == (RTF_ADDRCONF | RTF_DEFAULT)) &&
@@ -2504,7 +2504,7 @@ struct rt6_info *rt6_get_dflt_router(const struct in6_addr *addr, struct net_dev
 	}
 	if (rt)
 		dst_hold(&rt->dst);
-	read_unlock_bh(&table->tb6_lock);
+	fib6_table_read_unlock_bh(table);
 	return rt;
 }
 
@@ -2541,17 +2541,17 @@ static void __rt6_purge_dflt_routers(struct fib6_table *table)
 	struct rt6_info *rt;
 
 restart:
-	read_lock_bh(&table->tb6_lock);
+	fib6_table_read_lock_bh(table);
 	for (rt = table->tb6_root.leaf; rt; rt = rt->dst.rt6_next) {
 		if (rt->rt6i_flags & (RTF_DEFAULT | RTF_ADDRCONF) &&
 		    (!rt->rt6i_idev || rt->rt6i_idev->cnf.accept_ra != 2)) {
 			dst_hold(&rt->dst);
-			read_unlock_bh(&table->tb6_lock);
+			fib6_table_read_unlock_bh(table);
 			ip6_del_rt(rt);
 			goto restart;
 		}
 	}
-	read_unlock_bh(&table->tb6_lock);
+	fib6_table_read_unlock_bh(table);
 
 	table->flags &= ~RT6_TABLE_HAS_DFLT_ROUTER;
 }
-- 
2.9.3
