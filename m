From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 07/11][NETNS][IPV6] ip6_fib - clean node use namespace
Date: Sun, 02 Mar 2008 10:37:27 +0100
Message-ID: <20080302094210.742423281@mai.toulouse-stg.fr.ibm.com>
References: <20080302093720.649869114@mai.toulouse-stg.fr.ibm.com>
Cc: netdev@vger.kernel.org, benjamin.thery@bull.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.de.ibm.com ([195.212.29.156]:51163 "EHLO
	mtagate7.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753213AbYCBJoS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Mar 2008 04:44:18 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate7.de.ibm.com (8.13.8/8.13.8) with ESMTP id m229iH1v327372
	for <netdev@vger.kernel.org>; Sun, 2 Mar 2008 09:44:17 GMT
Received: from d12av01.megacenter.de.ibm.com (d12av01.megacenter.de.ibm.com [9.149.165.212])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m229iHg1565482
	for <netdev@vger.kernel.org>; Sun, 2 Mar 2008 10:44:17 +0100
Received: from d12av01.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av01.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m229iGnp012667
	for <netdev@vger.kernel.org>; Sun, 2 Mar 2008 09:44:17 GMT
Content-Disposition: inline; filename=07_11-ip6-fib-clean-node-use-namespace.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The fib6_clean_node function should have the network namespace
it is working on. The fib6_cleaner_t structure is extended with the
network namespace field to be passed to the fib6_clean_node function.

The different functions calling the fib6_clean_node function are extended
with the netns parameter when needed to propagate the netns pointer.

Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
 net/ipv6/ip6_fib.c |   25 +++++++++++++++----------
 1 file changed, 15 insertions(+), 10 deletions(-)

Index: net-2.6.26/net/ipv6/ip6_fib.c
===================================================================
--- net-2.6.26.orig/net/ipv6/ip6_fib.c
+++ net-2.6.26/net/ipv6/ip6_fib.c
@@ -66,6 +66,7 @@ enum fib_walk_state_t
 struct fib6_cleaner_t
 {
 	struct fib6_walker_t w;
+	struct net *net;
 	int (*func)(struct rt6_info *, void *arg);
 	void *arg;
 };
@@ -78,7 +79,8 @@ static DEFINE_RWLOCK(fib6_walker_lock);
 #define FWS_INIT FWS_L
 #endif
 
-static void fib6_prune_clones(struct fib6_node *fn, struct rt6_info *rt);
+static void fib6_prune_clones(struct net *net, struct fib6_node *fn,
+			      struct rt6_info *rt);
 static struct rt6_info * fib6_find_prefix(struct fib6_node *fn);
 static struct fib6_node * fib6_repair_tree(struct fib6_node *fn);
 static int fib6_walk(struct fib6_walker_t *w);
@@ -762,7 +764,7 @@ int fib6_add(struct fib6_node *root, str
 	if (err == 0) {
 		fib6_start_gc(info->nl_net, rt);
 		if (!(rt->rt6i_flags&RTF_CACHE))
-			fib6_prune_clones(pn, rt);
+			fib6_prune_clones(info->nl_net, pn, rt);
 	}
 
 out:
@@ -1168,7 +1170,7 @@ int fib6_del(struct rt6_info *rt, struct
 			pn = pn->parent;
 		}
 #endif
-		fib6_prune_clones(pn, rt);
+		fib6_prune_clones(info->nl_net, pn, rt);
 	}
 
 	/*
@@ -1298,12 +1300,12 @@ static int fib6_walk(struct fib6_walker_
 
 static int fib6_clean_node(struct fib6_walker_t *w)
 {
-	struct nl_info info = {
-		.nl_net = &init_net,
-	};
 	int res;
 	struct rt6_info *rt;
 	struct fib6_cleaner_t *c = container_of(w, struct fib6_cleaner_t, w);
+	struct nl_info info = {
+		.nl_net = c->net,
+	};
 
 	for (rt = w->leaf; rt; rt = rt->u.dst.rt6_next) {
 		res = c->func(rt, c->arg);
@@ -1335,7 +1337,7 @@ static int fib6_clean_node(struct fib6_w
  *	ignoring pure split nodes) will be scanned.
  */
 
-static void fib6_clean_tree(struct fib6_node *root,
+static void fib6_clean_tree(struct net *net, struct fib6_node *root,
 			    int (*func)(struct rt6_info *, void *arg),
 			    int prune, void *arg)
 {
@@ -1346,6 +1348,7 @@ static void fib6_clean_tree(struct fib6_
 	c.w.prune = prune;
 	c.func = func;
 	c.arg = arg;
+	c.net = net;
 
 	fib6_walk(&c.w);
 }
@@ -1363,7 +1366,8 @@ void fib6_clean_all(struct net *net, int
 		head = &net->ipv6.fib_table_hash[h];
 		hlist_for_each_entry_rcu(table, node, head, tb6_hlist) {
 			write_lock_bh(&table->tb6_lock);
-			fib6_clean_tree(&table->tb6_root, func, prune, arg);
+			fib6_clean_tree(net, &table->tb6_root,
+					func, prune, arg);
 			write_unlock_bh(&table->tb6_lock);
 		}
 	}
@@ -1380,9 +1384,10 @@ static int fib6_prune_clone(struct rt6_i
 	return 0;
 }
 
-static void fib6_prune_clones(struct fib6_node *fn, struct rt6_info *rt)
+static void fib6_prune_clones(struct net *net, struct fib6_node *fn,
+			      struct rt6_info *rt)
 {
-	fib6_clean_tree(fn, fib6_prune_clone, 1, rt);
+	fib6_clean_tree(net, fn, fib6_prune_clone, 1, rt);
 }
 
 /*

-- 
