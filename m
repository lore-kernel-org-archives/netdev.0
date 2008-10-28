From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] net: don't use INIT_RCU_HEAD
Date: Tue, 28 Oct 2008 16:31:24 +0300
Message-ID: <20081028133124.GA3006@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.24]:7088 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751568AbYJ1N2A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2008 09:28:00 -0400
Received: by ey-out-2122.google.com with SMTP id 6so1027315eyi.37
        for <netdev@vger.kernel.org>; Tue, 28 Oct 2008 06:27:58 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

call_rcu() will unconditionally rewrite RCU head anyway.
Applies to 
	struct neigh_parms
	struct neigh_table
	struct net
	struct cipso_v4_doi
	struct in_ifaddr
	struct in_device
	rt->u.dst

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 net/core/neighbour.c     |    2 --
 net/core/net_namespace.c |    2 --
 net/ipv4/cipso_ipv4.c    |    1 -
 net/ipv4/devinet.c       |    9 +--------
 net/ipv4/route.c         |    1 -
 5 files changed, 1 insertion(+), 14 deletions(-)

--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -1340,7 +1340,6 @@ struct neigh_parms *neigh_parms_alloc(struct net_device *dev,
 	if (p) {
 		p->tbl		  = tbl;
 		atomic_set(&p->refcnt, 1);
-		INIT_RCU_HEAD(&p->rcu_head);
 		p->reachable_time =
 				neigh_rand_reach_time(p->base_reachable_time);
 
@@ -1412,7 +1411,6 @@ void neigh_table_init_no_netlink(struct neigh_table *tbl)
 	tbl->parms.net = &init_net;
 #endif
 	atomic_set(&tbl->parms.refcnt, 1);
-	INIT_RCU_HEAD(&tbl->parms.rcu_head);
 	tbl->parms.reachable_time =
 			  neigh_rand_reach_time(tbl->parms.base_reachable_time);
 
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -47,7 +47,6 @@ static __net_init int setup_net(struct net *net)
 		goto out;
 
 	ng->len = INITIAL_NET_GEN_PTRS;
-	INIT_RCU_HEAD(&ng->rcu);
 	rcu_assign_pointer(net->gen, ng);
 
 	error = 0;
@@ -446,7 +445,6 @@ int net_assign_generic(struct net *net, int id, void *data)
 	 */
 
 	ng->len = id;
-	INIT_RCU_HEAD(&ng->rcu);
 	memcpy(&ng->ptr, &old_ng->ptr, old_ng->len);
 
 	rcu_assign_pointer(net->gen, ng);
--- a/net/ipv4/cipso_ipv4.c
+++ b/net/ipv4/cipso_ipv4.c
@@ -490,7 +490,6 @@ int cipso_v4_doi_add(struct cipso_v4_doi *doi_def)
 	}
 
 	atomic_set(&doi_def->refcount, 1);
-	INIT_RCU_HEAD(&doi_def->rcu);
 
 	spin_lock(&cipso_v4_doi_list_lock);
 	if (cipso_v4_doi_search(doi_def->doi) != NULL)
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -112,13 +112,7 @@ static inline void devinet_sysctl_unregister(struct in_device *idev)
 
 static struct in_ifaddr *inet_alloc_ifa(void)
 {
-	struct in_ifaddr *ifa = kzalloc(sizeof(*ifa), GFP_KERNEL);
-
-	if (ifa) {
-		INIT_RCU_HEAD(&ifa->rcu_head);
-	}
-
-	return ifa;
+	return kzalloc(sizeof(struct in_ifaddr), GFP_KERNEL);
 }
 
 static void inet_rcu_free_ifa(struct rcu_head *head)
@@ -161,7 +155,6 @@ static struct in_device *inetdev_init(struct net_device *dev)
 	in_dev = kzalloc(sizeof(*in_dev), GFP_KERNEL);
 	if (!in_dev)
 		goto out;
-	INIT_RCU_HEAD(&in_dev->rcu_head);
 	memcpy(&in_dev->cnf, dev_net(dev)->ipv4.devconf_dflt,
 			sizeof(in_dev->cnf));
 	in_dev->cnf.sysctl = NULL;
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1386,7 +1386,6 @@ void ip_rt_redirect(__be32 old_gw, __be32 daddr, __be32 new_gw,
 
 				/* Copy all the information. */
 				*rt = *rth;
-				INIT_RCU_HEAD(&rt->u.dst.rcu_head);
 				rt->u.dst.__use		= 1;
 				atomic_set(&rt->u.dst.__refcnt, 1);
 				rt->u.dst.child		= NULL;
