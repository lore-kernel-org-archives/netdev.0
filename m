From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 15/53] netns xfrm: per-netns policy list
Date: Tue, 25 Nov 2008 20:26:47 +0300
Message-ID: <1227634045-27534-15-git-send-email-adobriyan@gmail.com>
References: <1227634045-27534-1-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-2-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-3-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-4-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-5-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-6-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-7-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-8-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-9-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-10-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-11-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-12-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-13-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-14-git-send-email-adobriyan@gmail.com>
Cc: herbert@gondor.apana.org.au, kuznet@ms2.inr.ac.ru,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org,
	Alexey Dobriyan <adobriyan@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:28929 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753743AbYKYRYJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 12:24:09 -0500
Received: by ug-out-1314.google.com with SMTP id 39so1144223ugf.37
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2008 09:24:09 -0800 (PST)
In-Reply-To: <1227634045-27534-14-git-send-email-adobriyan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 include/net/netns/xfrm.h |    2 ++
 net/xfrm/xfrm_policy.c   |   12 ++++++------
 2 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/include/net/netns/xfrm.h b/include/net/netns/xfrm.h
index 2a383c8..6648924 100644
--- a/include/net/netns/xfrm.h
+++ b/include/net/netns/xfrm.h
@@ -25,6 +25,8 @@ struct netns_xfrm {
 	struct work_struct	state_gc_work;
 
 	wait_queue_head_t	km_waitq;
+
+	struct list_head	policy_all;
 };
 
 #endif
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 3eccefa..aabc7f2 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -46,7 +46,6 @@ EXPORT_SYMBOL(xfrm_cfg_mutex);
 
 static DEFINE_RWLOCK(xfrm_policy_lock);
 
-static struct list_head xfrm_policy_all;
 unsigned int xfrm_policy_count[XFRM_POLICY_MAX*2];
 EXPORT_SYMBOL(xfrm_policy_count);
 
@@ -615,7 +614,7 @@ int xfrm_policy_insert(int dir, struct xfrm_policy *policy, int excl)
 	policy->curlft.use_time = 0;
 	if (!mod_timer(&policy->timer, jiffies + HZ))
 		xfrm_pol_hold(policy);
-	list_add(&policy->walk.all, &xfrm_policy_all);
+	list_add(&policy->walk.all, &init_net.xfrm.policy_all);
 	write_unlock_bh(&xfrm_policy_lock);
 
 	if (delpol)
@@ -881,10 +880,10 @@ int xfrm_policy_walk(struct xfrm_policy_walk *walk,
 
 	write_lock_bh(&xfrm_policy_lock);
 	if (list_empty(&walk->walk.all))
-		x = list_first_entry(&xfrm_policy_all, struct xfrm_policy_walk_entry, all);
+		x = list_first_entry(&init_net.xfrm.policy_all, struct xfrm_policy_walk_entry, all);
 	else
 		x = list_entry(&walk->walk.all, struct xfrm_policy_walk_entry, all);
-	list_for_each_entry_from(x, &xfrm_policy_all, all) {
+	list_for_each_entry_from(x, &init_net.xfrm.policy_all, all) {
 		if (x->dead)
 			continue;
 		pol = container_of(x, struct xfrm_policy, walk);
@@ -1086,7 +1085,7 @@ static void __xfrm_policy_link(struct xfrm_policy *pol, int dir)
 	struct hlist_head *chain = policy_hash_bysel(&pol->selector,
 						     pol->family, dir);
 
-	list_add(&pol->walk.all, &xfrm_policy_all);
+	list_add(&pol->walk.all, &init_net.xfrm.policy_all);
 	hlist_add_head(&pol->bydst, chain);
 	hlist_add_head(&pol->byidx, xfrm_policy_byidx+idx_hash(pol->index));
 	xfrm_policy_count[dir]++;
@@ -2426,7 +2425,7 @@ static int __net_init xfrm_policy_init(struct net *net)
 			panic("XFRM: failed to allocate bydst hash\n");
 	}
 
-	INIT_LIST_HEAD(&xfrm_policy_all);
+	INIT_LIST_HEAD(&net->xfrm.policy_all);
 	if (net_eq(net, &init_net))
 		register_netdevice_notifier(&xfrm_dev_notifier);
 	return 0;
@@ -2434,6 +2433,7 @@ static int __net_init xfrm_policy_init(struct net *net)
 
 static void xfrm_policy_fini(struct net *net)
 {
+	WARN_ON(!list_empty(&net->xfrm.policy_all));
 }
 
 static int __net_init xfrm_net_init(struct net *net)
-- 
1.5.6.5

