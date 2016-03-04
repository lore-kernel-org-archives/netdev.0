From: Michal Kubecek <mkubecek@suse.cz>
Subject: [PATCH net-next 2/3] ipv6: per netns fib6 walkers
Date: Fri,  4 Mar 2016 11:59:25 +0100 (CET)
Message-ID: <6df8e224d6337b658a097ac87e72e1467cddf13d.1457085016.git.mkubecek@suse.cz>
References: <cover.1457085016.git.mkubecek@suse.cz>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Martin KaFai Lau <kafai@fb.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:43022 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756538AbcCDK7m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Mar 2016 05:59:42 -0500
In-Reply-To: <cover.1457085016.git.mkubecek@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The IPv6 FIB data structures are separated per network namespace but
there is still only one global walkers list and one global walker list
lock. This means changes in one namespace unnecessarily check walkers
in other namespaces and block them.

Replace the global list with per-netns lists and give each its own
lock.

Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
---
 include/net/netns/ipv6.h |  2 ++
 net/ipv6/ip6_fib.c       | 67 +++++++++++++++++++++++++++---------------------
 2 files changed, 40 insertions(+), 29 deletions(-)

diff --git a/include/net/netns/ipv6.h b/include/net/netns/ipv6.h
index c0368db6df54..f0109b973648 100644
--- a/include/net/netns/ipv6.h
+++ b/include/net/netns/ipv6.h
@@ -58,7 +58,9 @@ struct netns_ipv6 {
 	struct timer_list       ip6_fib_timer;
 	struct hlist_head       *fib_table_hash;
 	struct fib6_table       *fib6_main_tbl;
+	struct list_head	fib6_walkers;
 	struct dst_ops		ip6_dst_ops;
+	rwlock_t		fib6_walker_lock;
 	unsigned int		 ip6_rt_gc_expire;
 	unsigned long		 ip6_rt_last_gc;
 #ifdef CONFIG_IPV6_MULTIPLE_TABLES
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index d7c715accac9..af8a0fb39eda 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -55,8 +55,6 @@ struct fib6_cleaner {
 	void *arg;
 };
 
-static DEFINE_RWLOCK(fib6_walker_lock);
-
 #ifdef CONFIG_IPV6_SUBTREES
 #define FWS_INIT FWS_S
 #else
@@ -66,7 +64,7 @@ static DEFINE_RWLOCK(fib6_walker_lock);
 static void fib6_prune_clones(struct net *net, struct fib6_node *fn);
 static struct rt6_info *fib6_find_prefix(struct net *net, struct fib6_node *fn);
 static struct fib6_node *fib6_repair_tree(struct net *net, struct fib6_node *fn);
-static int fib6_walk(struct fib6_walker *w);
+static int fib6_walk(struct net *net, struct fib6_walker *w);
 static int fib6_walk_continue(struct fib6_walker *w);
 
 /*
@@ -78,21 +76,21 @@ static int fib6_walk_continue(struct fib6_walker *w);
 
 static void fib6_gc_timer_cb(unsigned long arg);
 
-static LIST_HEAD(fib6_walkers);
-#define FOR_WALKERS(w) list_for_each_entry(w, &fib6_walkers, lh)
+#define FOR_WALKERS(net, w) \
+	list_for_each_entry(w, &(net)->ipv6.fib6_walkers, lh)
 
-static void fib6_walker_link(struct fib6_walker *w)
+static void fib6_walker_link(struct net *net, struct fib6_walker *w)
 {
-	write_lock_bh(&fib6_walker_lock);
-	list_add(&w->lh, &fib6_walkers);
-	write_unlock_bh(&fib6_walker_lock);
+	write_lock_bh(&net->ipv6.fib6_walker_lock);
+	list_add(&w->lh, &net->ipv6.fib6_walkers);
+	write_unlock_bh(&net->ipv6.fib6_walker_lock);
 }
 
-static void fib6_walker_unlink(struct fib6_walker *w)
+static void fib6_walker_unlink(struct net *net, struct fib6_walker *w)
 {
-	write_lock_bh(&fib6_walker_lock);
+	write_lock_bh(&net->ipv6.fib6_walker_lock);
 	list_del(&w->lh);
-	write_unlock_bh(&fib6_walker_lock);
+	write_unlock_bh(&net->ipv6.fib6_walker_lock);
 }
 
 static int fib6_new_sernum(struct net *net)
@@ -325,12 +323,13 @@ static int fib6_dump_node(struct fib6_walker *w)
 
 static void fib6_dump_end(struct netlink_callback *cb)
 {
+	struct net *net = sock_net(cb->skb->sk);
 	struct fib6_walker *w = (void *)cb->args[2];
 
 	if (w) {
 		if (cb->args[4]) {
 			cb->args[4] = 0;
-			fib6_walker_unlink(w);
+			fib6_walker_unlink(net, w);
 		}
 		cb->args[2] = 0;
 		kfree(w);
@@ -348,6 +347,7 @@ static int fib6_dump_done(struct netlink_callback *cb)
 static int fib6_dump_table(struct fib6_table *table, struct sk_buff *skb,
 			   struct netlink_callback *cb)
 {
+	struct net *net = sock_net(skb->sk);
 	struct fib6_walker *w;
 	int res;
 
@@ -359,7 +359,7 @@ static int fib6_dump_table(struct fib6_table *table, struct sk_buff *skb,
 		w->skip = 0;
 
 		read_lock_bh(&table->tb6_lock);
-		res = fib6_walk(w);
+		res = fib6_walk(net, w);
 		read_unlock_bh(&table->tb6_lock);
 		if (res > 0) {
 			cb->args[4] = 1;
@@ -379,7 +379,7 @@ static int fib6_dump_table(struct fib6_table *table, struct sk_buff *skb,
 		res = fib6_walk_continue(w);
 		read_unlock_bh(&table->tb6_lock);
 		if (res <= 0) {
-			fib6_walker_unlink(w);
+			fib6_walker_unlink(net, w);
 			cb->args[4] = 0;
 		}
 	}
@@ -1340,8 +1340,8 @@ static struct fib6_node *fib6_repair_tree(struct net *net,
 		}
 #endif
 
-		read_lock(&fib6_walker_lock);
-		FOR_WALKERS(w) {
+		read_lock(&net->ipv6.fib6_walker_lock);
+		FOR_WALKERS(net, w) {
 			if (!child) {
 				if (w->root == fn) {
 					w->root = w->node = NULL;
@@ -1368,7 +1368,7 @@ static struct fib6_node *fib6_repair_tree(struct net *net,
 				}
 			}
 		}
-		read_unlock(&fib6_walker_lock);
+		read_unlock(&net->ipv6.fib6_walker_lock);
 
 		node_free(fn);
 		if (pn->fn_flags & RTN_RTINFO || FIB6_SUBTREE(pn))
@@ -1411,8 +1411,8 @@ static void fib6_del_route(struct fib6_node *fn, struct rt6_info **rtp,
 	}
 
 	/* Adjust walkers */
-	read_lock(&fib6_walker_lock);
-	FOR_WALKERS(w) {
+	read_lock(&net->ipv6.fib6_walker_lock);
+	FOR_WALKERS(net, w) {
 		if (w->state == FWS_C && w->leaf == rt) {
 			RT6_TRACE("walker %p adjusted by delroute\n", w);
 			w->leaf = rt->dst.rt6_next;
@@ -1420,7 +1420,7 @@ static void fib6_del_route(struct fib6_node *fn, struct rt6_info **rtp,
 				w->state = FWS_U;
 		}
 	}
-	read_unlock(&fib6_walker_lock);
+	read_unlock(&net->ipv6.fib6_walker_lock);
 
 	rt->dst.rt6_next = NULL;
 
@@ -1588,17 +1588,17 @@ skip:
 	}
 }
 
-static int fib6_walk(struct fib6_walker *w)
+static int fib6_walk(struct net *net, struct fib6_walker *w)
 {
 	int res;
 
 	w->state = FWS_INIT;
 	w->node = w->root;
 
-	fib6_walker_link(w);
+	fib6_walker_link(net, w);
 	res = fib6_walk_continue(w);
 	if (res <= 0)
-		fib6_walker_unlink(w);
+		fib6_walker_unlink(net, w);
 	return res;
 }
 
@@ -1668,7 +1668,7 @@ static void fib6_clean_tree(struct net *net, struct fib6_node *root,
 	c.arg = arg;
 	c.net = net;
 
-	fib6_walk(&c.w);
+	fib6_walk(net, &c.w);
 }
 
 static void __fib6_clean_all(struct net *net,
@@ -1816,6 +1816,8 @@ static int __net_init fib6_net_init(struct net *net)
 {
 	size_t size = sizeof(struct hlist_head) * FIB6_TABLE_HASHSZ;
 
+	rwlock_init(&net->ipv6.fib6_walker_lock);
+	INIT_LIST_HEAD(&net->ipv6.fib6_walkers);
 	setup_timer(&net->ipv6.ip6_fib_timer, fib6_gc_timer_cb, (unsigned long)net);
 
 	net->ipv6.rt6_stats = kzalloc(sizeof(*net->ipv6.rt6_stats), GFP_KERNEL);
@@ -1978,6 +1980,12 @@ static int ipv6_route_yield(struct fib6_walker *w)
 
 static void ipv6_route_seq_setup_walk(struct ipv6_route_iter *iter)
 {
+#ifdef CONFIG_NET_NS
+	struct net *net = iter->p.net;
+#else
+	struct net *net = &init_net;
+#endif
+
 	memset(&iter->w, 0, sizeof(iter->w));
 	iter->w.func = ipv6_route_yield;
 	iter->w.root = &iter->tbl->tb6_root;
@@ -1986,7 +1994,7 @@ static void ipv6_route_seq_setup_walk(struct ipv6_route_iter *iter)
 	iter->w.args = iter;
 	iter->sernum = iter->w.root->fn_sernum;
 	INIT_LIST_HEAD(&iter->w.lh);
-	fib6_walker_link(&iter->w);
+	fib6_walker_link(net, &iter->w);
 }
 
 static struct fib6_table *ipv6_route_seq_next_table(struct fib6_table *tbl,
@@ -2047,10 +2055,10 @@ iter_table:
 			++*pos;
 		return iter->w.leaf;
 	} else if (r < 0) {
-		fib6_walker_unlink(&iter->w);
+		fib6_walker_unlink(net, &iter->w);
 		return NULL;
 	}
-	fib6_walker_unlink(&iter->w);
+	fib6_walker_unlink(net, &iter->w);
 
 	iter->tbl = ipv6_route_seq_next_table(iter->tbl, net);
 	if (!iter->tbl)
@@ -2087,10 +2095,11 @@ static bool ipv6_route_iter_active(struct ipv6_route_iter *iter)
 static void ipv6_route_seq_stop(struct seq_file *seq, void *v)
 	__releases(RCU_BH)
 {
+	struct net *net = seq_file_net(seq);
 	struct ipv6_route_iter *iter = seq->private;
 
 	if (ipv6_route_iter_active(iter))
-		fib6_walker_unlink(&iter->w);
+		fib6_walker_unlink(net, &iter->w);
 
 	rcu_read_unlock_bh();
 }
-- 
2.7.2
