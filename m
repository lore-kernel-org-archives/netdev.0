From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] xfrm: fix RCU bugs
Date: Sun, 19 Aug 2012 12:31:48 +0200
Message-ID: <1345372308.5158.54.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, fan.du@windriver.com,
	fengguang.wu@intel.com, Priyanka Jain <Priyanka.Jain@freescale.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:42693 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751242Ab2HSKb4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Aug 2012 06:31:56 -0400
Received: by weyx8 with SMTP id x8so3355093wey.19
        for <netdev@vger.kernel.org>; Sun, 19 Aug 2012 03:31:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

This patch reverts commit 56892261ed1a (xfrm: Use rcu_dereference_bh to
deference pointer protected by rcu_read_lock_bh), and fixes bugs
introduced in commit 418a99ac6ad ( Replace rwlock on xfrm_policy_afinfo
with rcu )

1) We properly use RCU variant in this file, not a mix of RCU/RCU_BH

2) We must defer some writes after the synchronize_rcu() call or a reader
 can crash dereferencing NULL pointer.

3) Now we use the xfrm_policy_afinfo_lock spinlock only from process
context, we no longer need to block BH in xfrm_policy_register_afinfo()
and xfrm_policy_unregister_afinfo()

4) Can use RCU_INIT_POINTER() instead of rcu_assign_pointer() in
xfrm_policy_unregister_afinfo()

5) Remove a forward inline declaration (xfrm_policy_put_afinfo()),
  and also move xfrm_policy_get_afinfo() declaration.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Fan Du <fan.du@windriver.com>
Cc: Priyanka Jain <Priyanka.Jain@freescale.com>
---
 net/xfrm/xfrm_policy.c |   76 ++++++++++++++++++++-------------------
 1 file changed, 39 insertions(+), 37 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 6405764..e52f50f 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -48,8 +48,6 @@ static struct xfrm_policy_afinfo __rcu *xfrm_policy_afinfo[NPROTO]
 
 static struct kmem_cache *xfrm_dst_cache __read_mostly;
 
-static struct xfrm_policy_afinfo *xfrm_policy_get_afinfo(unsigned short family);
-static inline void xfrm_policy_put_afinfo(struct xfrm_policy_afinfo *afinfo);
 static void xfrm_init_pmtu(struct dst_entry *dst);
 static int stale_bundle(struct dst_entry *dst);
 static int xfrm_bundle_ok(struct xfrm_dst *xdst);
@@ -96,6 +94,24 @@ bool xfrm_selector_match(const struct xfrm_selector *sel, const struct flowi *fl
 	return false;
 }
 
+static struct xfrm_policy_afinfo *xfrm_policy_get_afinfo(unsigned short family)
+{
+	struct xfrm_policy_afinfo *afinfo;
+
+	if (unlikely(family >= NPROTO))
+		return NULL;
+	rcu_read_lock();
+	afinfo = rcu_dereference(xfrm_policy_afinfo[family]);
+	if (unlikely(!afinfo))
+		rcu_read_unlock();
+	return afinfo;
+}
+
+static void xfrm_policy_put_afinfo(struct xfrm_policy_afinfo *afinfo)
+{
+	rcu_read_unlock();
+}
+
 static inline struct dst_entry *__xfrm_dst_lookup(struct net *net, int tos,
 						  const xfrm_address_t *saddr,
 						  const xfrm_address_t *daddr,
@@ -2419,7 +2435,7 @@ int xfrm_policy_register_afinfo(struct xfrm_policy_afinfo *afinfo)
 		return -EINVAL;
 	if (unlikely(afinfo->family >= NPROTO))
 		return -EAFNOSUPPORT;
-	spin_lock_bh(&xfrm_policy_afinfo_lock);
+	spin_lock(&xfrm_policy_afinfo_lock);
 	if (unlikely(xfrm_policy_afinfo[afinfo->family] != NULL))
 		err = -ENOBUFS;
 	else {
@@ -2442,7 +2458,7 @@ int xfrm_policy_register_afinfo(struct xfrm_policy_afinfo *afinfo)
 			afinfo->garbage_collect = xfrm_garbage_collect_deferred;
 		rcu_assign_pointer(xfrm_policy_afinfo[afinfo->family], afinfo);
 	}
-	spin_unlock_bh(&xfrm_policy_afinfo_lock);
+	spin_unlock(&xfrm_policy_afinfo_lock);
 
 	rtnl_lock();
 	for_each_net(net) {
@@ -2475,23 +2491,26 @@ int xfrm_policy_unregister_afinfo(struct xfrm_policy_afinfo *afinfo)
 		return -EINVAL;
 	if (unlikely(afinfo->family >= NPROTO))
 		return -EAFNOSUPPORT;
-	spin_lock_bh(&xfrm_policy_afinfo_lock);
+	spin_lock(&xfrm_policy_afinfo_lock);
 	if (likely(xfrm_policy_afinfo[afinfo->family] != NULL)) {
 		if (unlikely(xfrm_policy_afinfo[afinfo->family] != afinfo))
 			err = -EINVAL;
-		else {
-			struct dst_ops *dst_ops = afinfo->dst_ops;
-			rcu_assign_pointer(xfrm_policy_afinfo[afinfo->family],
-									NULL);
-			dst_ops->kmem_cachep = NULL;
-			dst_ops->check = NULL;
-			dst_ops->negative_advice = NULL;
-			dst_ops->link_failure = NULL;
-			afinfo->garbage_collect = NULL;
-		}
+		else
+			RCU_INIT_POINTER(xfrm_policy_afinfo[afinfo->family],
+					 NULL);
+	}
+	spin_unlock(&xfrm_policy_afinfo_lock);
+	if (!err) {
+		struct dst_ops *dst_ops = afinfo->dst_ops;
+
+		synchronize_rcu();
+
+		dst_ops->kmem_cachep = NULL;
+		dst_ops->check = NULL;
+		dst_ops->negative_advice = NULL;
+		dst_ops->link_failure = NULL;
+		afinfo->garbage_collect = NULL;
 	}
-	spin_unlock_bh(&xfrm_policy_afinfo_lock);
-	synchronize_rcu();
 	return err;
 }
 EXPORT_SYMBOL(xfrm_policy_unregister_afinfo);
@@ -2500,32 +2519,15 @@ static void __net_init xfrm_dst_ops_init(struct net *net)
 {
 	struct xfrm_policy_afinfo *afinfo;
 
-	rcu_read_lock_bh();
-	afinfo = rcu_dereference_bh(xfrm_policy_afinfo[AF_INET]);
+	rcu_read_lock();
+	afinfo = rcu_dereference(xfrm_policy_afinfo[AF_INET]);
 	if (afinfo)
 		net->xfrm.xfrm4_dst_ops = *afinfo->dst_ops;
 #if IS_ENABLED(CONFIG_IPV6)
-	afinfo = rcu_dereference_bh(xfrm_policy_afinfo[AF_INET6]);
+	afinfo = rcu_dereference(xfrm_policy_afinfo[AF_INET6]);
 	if (afinfo)
 		net->xfrm.xfrm6_dst_ops = *afinfo->dst_ops;
 #endif
-	rcu_read_unlock_bh();
-}
-
-static struct xfrm_policy_afinfo *xfrm_policy_get_afinfo(unsigned short family)
-{
-	struct xfrm_policy_afinfo *afinfo;
-	if (unlikely(family >= NPROTO))
-		return NULL;
-	rcu_read_lock();
-	afinfo = rcu_dereference(xfrm_policy_afinfo[family]);
-	if (unlikely(!afinfo))
-		rcu_read_unlock();
-	return afinfo;
-}
-
-static inline void xfrm_policy_put_afinfo(struct xfrm_policy_afinfo *afinfo)
-{
 	rcu_read_unlock();
 }
 
