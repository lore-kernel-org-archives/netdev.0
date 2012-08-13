From: Priyanka Jain <Priyanka.Jain@freescale.com>
Subject: [PATCH][XFRM][v3] Replace rwlock on xfrm_policy_afinfo with rcu
Date: Mon, 13 Aug 2012 12:52:29 +0530
Message-ID: <1344842549-25923-1-git-send-email-Priyanka.Jain@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Priyanka Jain <Priyanka.Jain@freescale.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe003.messaging.microsoft.com ([65.55.88.13]:30588 "EHLO
	tx2outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752210Ab2HMHWv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Aug 2012 03:22:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

xfrm_policy_afinfo is read mosly data structure.
Write on xfrm_policy_afinfo is done only at the
time of configuration.
So rwlocks can be safely replaced with RCU.

RCUs usage optimizes the performance.

Signed-off-by: Priyanka Jain <Priyanka.Jain@freescale.com>
---
 Changes for v3:
	Replaced 'local_bh_disable;rcu_read_lock' with 'rcu_read_lock_bh' as
	suggested by David

 Changes for v2:
	Re-spined to netdev-next & corrected indentation as suggested by David

 For IPSEC fwd test 
 -On p4080ds (8-core, SMP system)
	 Around 110% throughput increase in case of PREEMPT_RT enabled
	 Around 5-6% throughput increase in case of PREEMPT_RT disabled

 -On p2020 (2-core, SMP system)
	 Around 4-5% throughput increase in case of PREEMPT_RT disabled

 net/xfrm/xfrm_policy.c |   39 +++++++++++++++++++++------------------
 1 files changed, 21 insertions(+), 18 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index c5a5165..5ad4d2c 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -42,13 +42,14 @@ static DEFINE_SPINLOCK(xfrm_policy_sk_bundle_lock);
 static struct dst_entry *xfrm_policy_sk_bundles;
 static DEFINE_RWLOCK(xfrm_policy_lock);
 
-static DEFINE_RWLOCK(xfrm_policy_afinfo_lock);
-static struct xfrm_policy_afinfo *xfrm_policy_afinfo[NPROTO];
+static DEFINE_SPINLOCK(xfrm_policy_afinfo_lock);
+static struct xfrm_policy_afinfo __rcu *xfrm_policy_afinfo[NPROTO]
+						__read_mostly;
 
 static struct kmem_cache *xfrm_dst_cache __read_mostly;
 
 static struct xfrm_policy_afinfo *xfrm_policy_get_afinfo(unsigned short family);
-static void xfrm_policy_put_afinfo(struct xfrm_policy_afinfo *afinfo);
+static inline void xfrm_policy_put_afinfo(struct xfrm_policy_afinfo *afinfo);
 static void xfrm_init_pmtu(struct dst_entry *dst);
 static int stale_bundle(struct dst_entry *dst);
 static int xfrm_bundle_ok(struct xfrm_dst *xdst);
@@ -2418,7 +2419,7 @@ int xfrm_policy_register_afinfo(struct xfrm_policy_afinfo *afinfo)
 		return -EINVAL;
 	if (unlikely(afinfo->family >= NPROTO))
 		return -EAFNOSUPPORT;
-	write_lock_bh(&xfrm_policy_afinfo_lock);
+	spin_lock_bh(&xfrm_policy_afinfo_lock);
 	if (unlikely(xfrm_policy_afinfo[afinfo->family] != NULL))
 		err = -ENOBUFS;
 	else {
@@ -2439,9 +2440,9 @@ int xfrm_policy_register_afinfo(struct xfrm_policy_afinfo *afinfo)
 			dst_ops->neigh_lookup = xfrm_neigh_lookup;
 		if (likely(afinfo->garbage_collect == NULL))
 			afinfo->garbage_collect = xfrm_garbage_collect_deferred;
-		xfrm_policy_afinfo[afinfo->family] = afinfo;
+		rcu_assign_pointer(xfrm_policy_afinfo[afinfo->family], afinfo);
 	}
-	write_unlock_bh(&xfrm_policy_afinfo_lock);
+	spin_unlock_bh(&xfrm_policy_afinfo_lock);
 
 	rtnl_lock();
 	for_each_net(net) {
@@ -2474,13 +2475,14 @@ int xfrm_policy_unregister_afinfo(struct xfrm_policy_afinfo *afinfo)
 		return -EINVAL;
 	if (unlikely(afinfo->family >= NPROTO))
 		return -EAFNOSUPPORT;
-	write_lock_bh(&xfrm_policy_afinfo_lock);
+	spin_lock_bh(&xfrm_policy_afinfo_lock);
 	if (likely(xfrm_policy_afinfo[afinfo->family] != NULL)) {
 		if (unlikely(xfrm_policy_afinfo[afinfo->family] != afinfo))
 			err = -EINVAL;
 		else {
 			struct dst_ops *dst_ops = afinfo->dst_ops;
-			xfrm_policy_afinfo[afinfo->family] = NULL;
+			rcu_assign_pointer(xfrm_policy_afinfo[afinfo->family],
+									NULL);
 			dst_ops->kmem_cachep = NULL;
 			dst_ops->check = NULL;
 			dst_ops->negative_advice = NULL;
@@ -2488,7 +2490,8 @@ int xfrm_policy_unregister_afinfo(struct xfrm_policy_afinfo *afinfo)
 			afinfo->garbage_collect = NULL;
 		}
 	}
-	write_unlock_bh(&xfrm_policy_afinfo_lock);
+	spin_unlock_bh(&xfrm_policy_afinfo_lock);
+	synchronize_rcu();
 	return err;
 }
 EXPORT_SYMBOL(xfrm_policy_unregister_afinfo);
@@ -2497,16 +2500,16 @@ static void __net_init xfrm_dst_ops_init(struct net *net)
 {
 	struct xfrm_policy_afinfo *afinfo;
 
-	read_lock_bh(&xfrm_policy_afinfo_lock);
-	afinfo = xfrm_policy_afinfo[AF_INET];
+	rcu_read_lock_bh();
+	afinfo = rcu_dereference(xfrm_policy_afinfo[AF_INET]);
 	if (afinfo)
 		net->xfrm.xfrm4_dst_ops = *afinfo->dst_ops;
 #if IS_ENABLED(CONFIG_IPV6)
-	afinfo = xfrm_policy_afinfo[AF_INET6];
+	afinfo = rcu_dereference(xfrm_policy_afinfo[AF_INET6]);
 	if (afinfo)
 		net->xfrm.xfrm6_dst_ops = *afinfo->dst_ops;
 #endif
-	read_unlock_bh(&xfrm_policy_afinfo_lock);
+	rcu_read_unlock_bh();
 }
 
 static struct xfrm_policy_afinfo *xfrm_policy_get_afinfo(unsigned short family)
@@ -2514,16 +2517,16 @@ static struct xfrm_policy_afinfo *xfrm_policy_get_afinfo(unsigned short family)
 	struct xfrm_policy_afinfo *afinfo;
 	if (unlikely(family >= NPROTO))
 		return NULL;
-	read_lock(&xfrm_policy_afinfo_lock);
-	afinfo = xfrm_policy_afinfo[family];
+	rcu_read_lock();
+	afinfo = rcu_dereference(xfrm_policy_afinfo[family]);
 	if (unlikely(!afinfo))
-		read_unlock(&xfrm_policy_afinfo_lock);
+		rcu_read_unlock();
 	return afinfo;
 }
 
-static void xfrm_policy_put_afinfo(struct xfrm_policy_afinfo *afinfo)
+static inline void xfrm_policy_put_afinfo(struct xfrm_policy_afinfo *afinfo)
 {
-	read_unlock(&xfrm_policy_afinfo_lock);
+	rcu_read_unlock();
 }
 
 static int xfrm_dev_event(struct notifier_block *this, unsigned long event, void *ptr)
-- 
1.7.4.1
