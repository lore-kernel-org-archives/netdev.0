From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH RFC 6/6] ipv6: switch rt_sernum to atomic_t and clean up types
Date: Fri, 12 Sep 2014 01:21:53 +0200
Message-ID: <9c157a6cf424ef33694c95aef54b5f6ee6d27401.1410477596.git.hannes@stressinduktion.org>
References: <cover.1410477596.git.hannes@stressinduktion.org>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:56202 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751066AbaIKXWG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2014 19:22:06 -0400
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
	by gateway2.nyi.internal (Postfix) with ESMTP id 8EC9820E31
	for <netdev@vger.kernel.org>; Thu, 11 Sep 2014 19:22:05 -0400 (EDT)
In-Reply-To: <cover.1410477596.git.hannes@stressinduktion.org>
In-Reply-To: <cover.1410477596.git.hannes@stressinduktion.org>
References: <cover.1410477596.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Switch rt_sernum to atomic_t, make it concurrency safe (the old scheme
looked broken to me) and switch from u32 to int types for the fn_sernum.

Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Vlad Yasevich <vyasevich@gmail.com>
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/ip6_fib.h    |  2 +-
 include/net/netns/ipv6.h |  2 +-
 net/ipv6/af_inet6.c      |  2 +-
 net/ipv6/ip6_fib.c       | 40 ++++++++++++++++++++--------------------
 4 files changed, 23 insertions(+), 23 deletions(-)

diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index 9bcb220..59c391f 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -64,7 +64,7 @@ struct fib6_node {
 
 	__u16			fn_bit;		/* bit key */
 	__u16			fn_flags;
-	__u32			fn_sernum;
+	int			fn_sernum;
 	struct rt6_info		*rr_ptr;
 };
 
diff --git a/include/net/netns/ipv6.h b/include/net/netns/ipv6.h
index 2319949..7dee21b 100644
--- a/include/net/netns/ipv6.h
+++ b/include/net/netns/ipv6.h
@@ -76,7 +76,7 @@ struct netns_ipv6 {
 #endif
 #endif
 	atomic_t		dev_addr_genid;
-	u32			rt_sernum;
+	atomic_t		rt_sernum;
 };
 
 #if IS_ENABLED(CONFIG_NF_DEFRAG_IPV6)
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 7ff8996..6cde9b4 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -766,7 +766,7 @@ static int __net_init inet6_net_init(struct net *net)
 	net->ipv6.sysctl.icmpv6_time = 1*HZ;
 	net->ipv6.sysctl.flowlabel_consistency = 1;
 	net->ipv6.sysctl.auto_flowlabels = 0;
-	net->ipv6.rt_sernum = 1;
+	atomic_set(&net->ipv6.rt_sernum, 1);
 
 	err = ipv6_init_mibs(net);
 	if (err)
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 0ffabe2..03234bb 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -60,7 +60,7 @@ struct fib6_cleaner_t {
 	struct fib6_walker_t w;
 	struct net *net;
 	int (*func)(struct rt6_info *, void *arg);
-	u32 sernum;
+	int sernum;
 	void *arg;
 };
 
@@ -73,7 +73,7 @@ static DEFINE_RWLOCK(fib6_walker_lock);
 #endif
 
 static void fib6_prune_clones(struct net *net, struct fib6_node *fn,
-			      u32 sernum);
+			      int sernum);
 static struct rt6_info *fib6_find_prefix(struct net *net, struct fib6_node *fn);
 static struct fib6_node *fib6_repair_tree(struct net *net, struct fib6_node *fn);
 static int fib6_walk(struct fib6_walker_t *w);
@@ -105,14 +105,17 @@ static inline void fib6_walker_unlink(struct fib6_walker_t *w)
 	write_unlock_bh(&fib6_walker_lock);
 }
 
-static u32 fib6_new_sernum(struct net *net)
+static int fib6_new_sernum(struct net *net)
 {
-	int *n = &net->ipv6.rt_sernum;
+	int old, new;
 
-	(*n)++;
-	if ((s32)*n <= 0)
-		*n = 1;
-	return *n;
+	do {
+		old = atomic_read(&net->ipv6.rt_sernum);
+		new = old + 1;
+		if (new <= 0)
+			new = 1;
+	} while (atomic_cmpxchg(&net->ipv6.rt_sernum, old, new) != old);
+	return new;
 }
 
 /*
@@ -427,7 +430,7 @@ static struct fib6_node *fib6_add_1(struct fib6_node *root,
 				     struct in6_addr *addr, int plen,
 				     int offset, int allow_create,
 				     int replace_required,
-				     u32 sernum)
+				     int sernum)
 {
 	struct fib6_node *fn, *in, *ln;
 	struct fib6_node *pn = NULL;
@@ -851,7 +854,7 @@ int fib6_add(struct fib6_node *root, struct rt6_info *rt, struct nl_info *info,
 	int err = -ENOMEM;
 	int allow_create = 1;
 	int replace_required = 0;
-	u32 sernum = fib6_new_sernum(dev_net(rt->dst.dev));
+	int sernum = fib6_new_sernum(dev_net(rt->dst.dev));
 
 	if (info->nlh) {
 		if (!(info->nlh->nlmsg_flags & NLM_F_CREATE))
@@ -1356,7 +1359,7 @@ int fib6_del(struct rt6_info *rt, struct nl_info *info)
 	struct net *net = info->nl_net;
 	struct fib6_node *fn = rt->rt6i_node;
 	struct rt6_info **rtp;
-	u32 sernum = fib6_new_sernum(dev_net(rt->dst.dev));
+	int sernum = fib6_new_sernum(dev_net(rt->dst.dev));
 
 #if RT6_DEBUG >= 2
 	if (rt->dst.obsolete > 0) {
@@ -1570,7 +1573,7 @@ static int fib6_clean_node(struct fib6_walker_t *w)
 
 static void fib6_clean_tree(struct net *net, struct fib6_node *root,
 			    int (*func)(struct rt6_info *, void *arg),
-			    int prune, u32 sernum, void *arg)
+			    int prune, int sernum, void *arg)
 {
 	struct fib6_cleaner_t c;
 
@@ -1589,20 +1592,17 @@ static void fib6_clean_tree(struct net *net, struct fib6_node *root,
 
 static void __fib6_clean_all(struct net *net,
 			     int (*func)(struct rt6_info *, void *arg),
-			     bool update_sernum, void *arg)
+			     int sernum, void *arg)
 {
 	struct fib6_table *table;
 	struct hlist_head *head;
 	unsigned int h;
-	u32 sernum = 0;
 
 	rcu_read_lock();
 	for (h = 0; h < FIB6_TABLE_HASHSZ; h++) {
 		head = &net->ipv6.fib_table_hash[h];
 		hlist_for_each_entry_rcu(table, head, tb6_hlist) {
 			write_lock_bh(&table->tb6_lock);
-			sernum = update_sernum && !sernum ?
-				 fib6_new_sernum(net) : 0;
 			fib6_clean_tree(net, &table->tb6_root,
 					func, 0, sernum, arg);
 			write_unlock_bh(&table->tb6_lock);
@@ -1614,7 +1614,7 @@ static void __fib6_clean_all(struct net *net,
 void fib6_clean_all(struct net *net, int (*func)(struct rt6_info *, void *arg),
 		    void *arg)
 {
-	__fib6_clean_all(net, func, false, arg);
+	__fib6_clean_all(net, func, fib6_new_sernum(net), arg);
 }
 
 static int fib6_prune_clone(struct rt6_info *rt, void *arg)
@@ -1628,14 +1628,14 @@ static int fib6_prune_clone(struct rt6_info *rt, void *arg)
 }
 
 static void fib6_prune_clones(struct net *net, struct fib6_node *fn,
-			      u32 sernum)
+			      int sernum)
 {
 	fib6_clean_tree(net, fn, fib6_prune_clone, 1, sernum, NULL);
 }
 
 static void fib6_flush_trees(struct net *net)
 {
-	__fib6_clean_all(net, NULL, true, NULL);
+	__fib6_clean_all(net, NULL, fib6_new_sernum(net), NULL);
 }
 
 /*
@@ -1846,7 +1846,7 @@ struct ipv6_route_iter {
 	struct fib6_walker_t w;
 	loff_t skip;
 	struct fib6_table *tbl;
-	u32 sernum;
+	int sernum;
 };
 
 static int ipv6_route_seq_show(struct seq_file *seq, void *v)
-- 
1.9.3
