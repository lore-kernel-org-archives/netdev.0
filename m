From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next 5/5] ipv6: don't walk node's leaf during serial number update
Date: Mon,  6 Oct 2014 10:52:14 +0200
Message-ID: <60321af8a7305bec398e62858ef53bb6605878fb.1412585163.git.hannes@stressinduktion.org>
References: <cover.1412585162.git.hannes@stressinduktion.org>
Cc: hideaki@yoshifuji.org, kafai@fb.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:57252 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752149AbaJFIw0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 04:52:26 -0400
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
	by gateway2.nyi.internal (Postfix) with ESMTP id A5B37208B7
	for <netdev@vger.kernel.org>; Mon,  6 Oct 2014 04:52:25 -0400 (EDT)
In-Reply-To: <cover.1412585162.git.hannes@stressinduktion.org>
In-Reply-To: <cover.1412585162.git.hannes@stressinduktion.org>
References: <cover.1412585162.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc: YOSHIFUJI Hideaki <hideaki@yoshifuji.org>
Cc: Martin Lau <kafai@fb.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/ip6_fib.c | 47 ++++++++++++++++++++++++++++++-----------------
 1 file changed, 30 insertions(+), 17 deletions(-)

diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 6c10c26..f36207f 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -50,6 +50,7 @@ struct fib6_cleaner_t {
 	struct fib6_walker_t w;
 	struct net *net;
 	int (*func)(struct rt6_info *, void *arg);
+	int sernum;
 	void *arg;
 };
 
@@ -105,6 +106,10 @@ static int fib6_new_sernum(struct net *net)
 	return new;
 }
 
+enum {
+	FIB6_NO_SERNUM_CHANGE = 0,
+};
+
 /*
  *	Auxiliary address test functions for the radix tree.
  *
@@ -1514,6 +1519,16 @@ static int fib6_clean_node(struct fib6_walker_t *w)
 		.nl_net = c->net,
 	};
 
+	if (c->sernum != FIB6_NO_SERNUM_CHANGE &&
+	    w->node->fn_sernum != c->sernum)
+		w->node->fn_sernum = c->sernum;
+
+	if (!c->func) {
+		WARN_ON_ONCE(c->sernum == FIB6_NO_SERNUM_CHANGE);
+		w->leaf = NULL;
+		return 0;
+	}
+
 	for (rt = w->leaf; rt; rt = rt->dst.rt6_next) {
 		res = c->func(rt, c->arg);
 		if (res < 0) {
@@ -1547,7 +1562,7 @@ static int fib6_clean_node(struct fib6_walker_t *w)
 
 static void fib6_clean_tree(struct net *net, struct fib6_node *root,
 			    int (*func)(struct rt6_info *, void *arg),
-			    bool prune, void *arg)
+			    bool prune, int sernum, void *arg)
 {
 	struct fib6_cleaner_t c;
 
@@ -1557,14 +1572,16 @@ static void fib6_clean_tree(struct net *net, struct fib6_node *root,
 	c.w.count = 0;
 	c.w.skip = 0;
 	c.func = func;
+	c.sernum = sernum;
 	c.arg = arg;
 	c.net = net;
 
 	fib6_walk(&c.w);
 }
 
-void fib6_clean_all(struct net *net, int (*func)(struct rt6_info *, void *arg),
-		    void *arg)
+static void __fib6_clean_all(struct net *net,
+			     int (*func)(struct rt6_info *, void *),
+			     int sernum, void *arg)
 {
 	struct fib6_table *table;
 	struct hlist_head *head;
@@ -1576,13 +1593,19 @@ void fib6_clean_all(struct net *net, int (*func)(struct rt6_info *, void *arg),
 		hlist_for_each_entry_rcu(table, head, tb6_hlist) {
 			write_lock_bh(&table->tb6_lock);
 			fib6_clean_tree(net, &table->tb6_root,
-					func, false, arg);
+					func, false, sernum, arg);
 			write_unlock_bh(&table->tb6_lock);
 		}
 	}
 	rcu_read_unlock();
 }
 
+void fib6_clean_all(struct net *net, int (*func)(struct rt6_info *, void *),
+		    void *arg)
+{
+	__fib6_clean_all(net, func, FIB6_NO_SERNUM_CHANGE, arg);
+}
+
 static int fib6_prune_clone(struct rt6_info *rt, void *arg)
 {
 	if (rt->rt6i_flags & RTF_CACHE) {
@@ -1595,25 +1618,15 @@ static int fib6_prune_clone(struct rt6_info *rt, void *arg)
 
 static void fib6_prune_clones(struct net *net, struct fib6_node *fn)
 {
-	fib6_clean_tree(net, fn, fib6_prune_clone, true, NULL);
-}
-
-static int fib6_update_sernum(struct rt6_info *rt, void *arg)
-{
-	int sernum = *(__u32 *)arg;
-
-	if (rt->rt6i_node &&
-	    rt->rt6i_node->fn_sernum != sernum)
-		rt->rt6i_node->fn_sernum = sernum;
-
-	return 0;
+	fib6_clean_tree(net, fn, fib6_prune_clone, true,
+			FIB6_NO_SERNUM_CHANGE, NULL);
 }
 
 static void fib6_flush_trees(struct net *net)
 {
 	int new_sernum = fib6_new_sernum(net);
 
-	fib6_clean_all(net, fib6_update_sernum, &new_sernum);
+	__fib6_clean_all(net, NULL, new_sernum, NULL);
 }
 
 /*
-- 
1.9.3
