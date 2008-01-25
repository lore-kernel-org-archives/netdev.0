From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 07/11][NETNS][IPV6] make fib6_clean_node to use the network namespace
Date: Fri, 25 Jan 2008 17:50:15 +0100
Message-ID: <20080125170816.624329346@localhost.localdomain>
References: <20080125165008.317745745@localhost.localdomain>
Cc: benjamin.thery@bull.net, netdev@vger.kernel.org, den@openvz.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.uk.ibm.com ([195.212.29.136]:10844 "EHLO
	mtagate3.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753533AbYAYRLj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jan 2008 12:11:39 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate3.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m0PHBbxH043622
	for <netdev@vger.kernel.org>; Fri, 25 Jan 2008 17:11:37 GMT
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0PHBbL63739770
	for <netdev@vger.kernel.org>; Fri, 25 Jan 2008 17:11:37 GMT
Received: from d06av02.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m0PHBYFi026652
	for <netdev@vger.kernel.org>; Fri, 25 Jan 2008 17:11:34 GMT
Content-Disposition: inline; filename=ip6-fib-clean-node-use-namespace.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The fib6_clean_node function should have the network namespace
it is working on. The fib6_cleaner_t structure is extended with the
network namespace field to be passed to the fib6_clean_node function.

The different functions calling the fib6_clean_node function are extended
with the netns parameter when needed to propagate the netns pointer.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
 net/ipv6/ip6_fib.c |   25 +++++++++++++++----------
 1 file changed, 15 insertions(+), 10 deletions(-)

Index: net-2.6.25/net/ipv6/ip6_fib.c
===================================================================
--- net-2.6.25.orig/net/ipv6/ip6_fib.c
+++ net-2.6.25/net/ipv6/ip6_fib.c
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
