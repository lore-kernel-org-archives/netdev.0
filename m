From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH v2 net-next 1/9] ipv6: support for fib6_clean_* to update fn_sernum
Date: Sun, 21 Sep 2014 16:11:45 +0200
Message-ID: <6cd53aa9595380b9e41ca86ca04a47ce27a39376.1411308211.git.hannes@stressinduktion.org>
References: <cover.1411308211.git.hannes@stressinduktion.org>
Cc: eric.dumazet@gmail.com, hideaki@yoshifuji.org, vyasevich@gmail.com,
	nicolas.dichtel@6wind.com, kafai@fb.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:37967 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751147AbaIUOMG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Sep 2014 10:12:06 -0400
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
	by gateway2.nyi.internal (Postfix) with ESMTP id 87A0B207F0
	for <netdev@vger.kernel.org>; Sun, 21 Sep 2014 10:12:05 -0400 (EDT)
In-Reply-To: <cover.1411308211.git.hannes@stressinduktion.org>
In-Reply-To: <cover.1411308211.git.hannes@stressinduktion.org>
References: <cover.1411308211.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: YOSHIFUJI Hideaki <hideaki@yoshifuji.org>
Cc: Vlad Yasevich <vyasevich@gmail.com>
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Cc: Martin Lau <kafai@fb.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/ip6_fib.h |  2 +-
 net/ipv6/ip6_fib.c    | 31 ++++++++++++++++++++-----------
 2 files changed, 21 insertions(+), 12 deletions(-)

diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index 9bcb220..1cdd46e 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -64,7 +64,7 @@ struct fib6_node {
 
 	__u16			fn_bit;		/* bit key */
 	__u16			fn_flags;
-	__u32			fn_sernum;
+	u32			fn_sernum;
 	struct rt6_info		*rr_ptr;
 };
 
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 76b7f5e..900254e 100644
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
 
@@ -107,11 +109,13 @@ static inline void fib6_walker_unlink(struct fib6_walker_t *w)
 static __inline__ u32 fib6_new_sernum(void)
 {
 	u32 n = ++rt_sernum;
-	if ((__s32)n <= 0)
+	if ((s32)n <= 0)
 		rt_sernum = n = 1;
 	return n;
 }
 
+#define FIB6_NO_SERNUM_CHANGE (0U)
+
 /*
  *	Auxiliary address test functions for the radix tree.
  *
@@ -430,7 +434,7 @@ static struct fib6_node *fib6_add_1(struct fib6_node *root,
 	struct rt6key *key;
 	int	bit;
 	__be32	dir = 0;
-	__u32	sernum = fib6_new_sernum();
+	u32	sernum = fib6_new_sernum();
 
 	RT6_TRACE("fib6_add_1\n");
 
@@ -940,7 +944,8 @@ int fib6_add(struct fib6_node *root, struct rt6_info *rt, struct nl_info *info,
 	if (!err) {
 		fib6_start_gc(info->nl_net, rt);
 		if (!(rt->rt6i_flags & RTF_CACHE))
-			fib6_prune_clones(info->nl_net, pn);
+			fib6_prune_clones(info->nl_net, pn,
+					  FIB6_NO_SERNUM_CHANGE);
 	}
 
 out:
@@ -1374,7 +1379,7 @@ int fib6_del(struct rt6_info *rt, struct nl_info *info)
 			pn = pn->parent;
 		}
 #endif
-		fib6_prune_clones(info->nl_net, pn);
+		fib6_prune_clones(info->nl_net, pn, FIB6_NO_SERNUM_CHANGE);
 	}
 
 	/*
@@ -1521,6 +1526,9 @@ static int fib6_clean_node(struct fib6_walker_t *w)
 		.nl_net = c->net,
 	};
 
+	if (c->sernum != FIB6_NO_SERNUM_CHANGE)
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
 
@@ -1564,6 +1572,7 @@ static void fib6_clean_tree(struct net *net, struct fib6_node *root,
 	c.w.count = 0;
 	c.w.skip = 0;
 	c.func = func;
+	c.sernum = sernum;
 	c.arg = arg;
 	c.net = net;
 
@@ -1583,7 +1592,7 @@ void fib6_clean_all(struct net *net, int (*func)(struct rt6_info *, void *arg),
 		hlist_for_each_entry_rcu(table, head, tb6_hlist) {
 			write_lock_bh(&table->tb6_lock);
 			fib6_clean_tree(net, &table->tb6_root,
-					func, 0, arg);
+					func, 0, FIB6_NO_SERNUM_CHANGE, arg);
 			write_unlock_bh(&table->tb6_lock);
 		}
 	}
@@ -1600,9 +1609,9 @@ static int fib6_prune_clone(struct rt6_info *rt, void *arg)
 	return 0;
 }
 
-static void fib6_prune_clones(struct net *net, struct fib6_node *fn)
+static void fib6_prune_clones(struct net *net, struct fib6_node *fn, u32 sernum)
 {
-	fib6_clean_tree(net, fn, fib6_prune_clone, 1, NULL);
+	fib6_clean_tree(net, fn, fib6_prune_clone, 1, sernum, NULL);
 }
 
 /*
@@ -1811,7 +1820,7 @@ struct ipv6_route_iter {
 	struct fib6_walker_t w;
 	loff_t skip;
 	struct fib6_table *tbl;
-	__u32 sernum;
+	u32 sernum;
 };
 
 static int ipv6_route_seq_show(struct seq_file *seq, void *v)
-- 
1.9.3
