From: Florian Westphal <fw@strlen.de>
Subject: [PATCH ipsec-next] xfrm: state: remove per-netns gc task
Date: Tue, 23 Aug 2016 16:00:12 +0200
Message-ID: <1471960812-25835-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:40912 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1757369AbcHWOVE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 10:21:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After commit 5b8ef3415a21f173
("xfrm: Remove ancient sleeping when the SA is in acquire state")
gc does not need any per-netns data anymore.

As far as gc is concerned all state structs are the same, so we
can use a global work struct for it.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/net/netns/xfrm.h |  2 --
 net/xfrm/xfrm_state.c    | 18 +++++++++---------
 2 files changed, 9 insertions(+), 11 deletions(-)

diff --git a/include/net/netns/xfrm.h b/include/net/netns/xfrm.h
index 177ed44..27bb963 100644
--- a/include/net/netns/xfrm.h
+++ b/include/net/netns/xfrm.h
@@ -44,8 +44,6 @@ struct netns_xfrm {
 	unsigned int		state_hmask;
 	unsigned int		state_num;
 	struct work_struct	state_hash_work;
-	struct hlist_head	state_gc_list;
-	struct work_struct	state_gc_work;
 
 	struct list_head	policy_all;
 	struct hlist_head	*policy_byidx;
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 0f70fd9..e7b1baf 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -31,6 +31,8 @@
 #define xfrm_state_deref_prot(table, net) \
 	rcu_dereference_protected((table), lockdep_is_held(&(net)->xfrm.xfrm_state_lock))
 
+static void xfrm_state_gc_task(struct work_struct *work);
+
 /* Each xfrm_state may be linked to two tables:
 
    1. Hash table by (spi,daddr,ah/esp) to find SA by SPI. (input,ctl)
@@ -41,6 +43,9 @@
 static unsigned int xfrm_state_hashmax __read_mostly = 1 * 1024 * 1024;
 static __read_mostly seqcount_t xfrm_state_hash_generation = SEQCNT_ZERO(xfrm_state_hash_generation);
 
+static DECLARE_WORK(xfrm_state_gc_work, xfrm_state_gc_task);
+static HLIST_HEAD(xfrm_state_gc_list);
+
 static inline bool xfrm_state_hold_rcu(struct xfrm_state __rcu *x)
 {
 	return atomic_inc_not_zero(&x->refcnt);
@@ -368,13 +373,12 @@ static void xfrm_state_gc_destroy(struct xfrm_state *x)
 
 static void xfrm_state_gc_task(struct work_struct *work)
 {
-	struct net *net = container_of(work, struct net, xfrm.state_gc_work);
 	struct xfrm_state *x;
 	struct hlist_node *tmp;
 	struct hlist_head gc_list;
 
 	spin_lock_bh(&xfrm_state_gc_lock);
-	hlist_move_list(&net->xfrm.state_gc_list, &gc_list);
+	hlist_move_list(&xfrm_state_gc_list, &gc_list);
 	spin_unlock_bh(&xfrm_state_gc_lock);
 
 	synchronize_rcu();
@@ -515,14 +519,12 @@ EXPORT_SYMBOL(xfrm_state_alloc);
 
 void __xfrm_state_destroy(struct xfrm_state *x)
 {
-	struct net *net = xs_net(x);
-
 	WARN_ON(x->km.state != XFRM_STATE_DEAD);
 
 	spin_lock_bh(&xfrm_state_gc_lock);
-	hlist_add_head(&x->gclist, &net->xfrm.state_gc_list);
+	hlist_add_head(&x->gclist, &xfrm_state_gc_list);
 	spin_unlock_bh(&xfrm_state_gc_lock);
-	schedule_work(&net->xfrm.state_gc_work);
+	schedule_work(&xfrm_state_gc_work);
 }
 EXPORT_SYMBOL(__xfrm_state_destroy);
 
@@ -2134,8 +2136,6 @@ int __net_init xfrm_state_init(struct net *net)
 
 	net->xfrm.state_num = 0;
 	INIT_WORK(&net->xfrm.state_hash_work, xfrm_hash_resize);
-	INIT_HLIST_HEAD(&net->xfrm.state_gc_list);
-	INIT_WORK(&net->xfrm.state_gc_work, xfrm_state_gc_task);
 	spin_lock_init(&net->xfrm.xfrm_state_lock);
 	return 0;
 
@@ -2153,7 +2153,7 @@ void xfrm_state_fini(struct net *net)
 
 	flush_work(&net->xfrm.state_hash_work);
 	xfrm_state_flush(net, IPSEC_PROTO_ANY, false);
-	flush_work(&net->xfrm.state_gc_work);
+	flush_work(&xfrm_state_gc_work);
 
 	WARN_ON(!list_empty(&net->xfrm.state_all));
 
-- 
2.7.3
