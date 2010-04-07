From: Timo Teras <timo.teras@iki.fi>
Subject: [PATCH 3/4] xfrm: remove policy garbage collection
Date: Wed,  7 Apr 2010 13:30:06 +0300
Message-ID: <1270636207-20933-4-git-send-email-timo.teras@iki.fi>
References: <1270636207-20933-1-git-send-email-timo.teras@iki.fi>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Timo Teras <timo.teras@iki.fi>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.27]:31885 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757850Ab0DGKad (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Apr 2010 06:30:33 -0400
Received: by ey-out-2122.google.com with SMTP id d26so103159eyd.19
        for <netdev@vger.kernel.org>; Wed, 07 Apr 2010 03:30:33 -0700 (PDT)
In-Reply-To: <1270636207-20933-1-git-send-email-timo.teras@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Policies are now properly reference counted and destroyed from
all code paths. The delayed gc is just an overhead now and can
be removed.

Signed-off-by: Timo Teras <timo.teras@iki.fi>
---
 net/xfrm/xfrm_policy.c |   39 +++++----------------------------------
 1 files changed, 5 insertions(+), 34 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 06ccc71..7430ac2 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -46,9 +46,6 @@ static struct xfrm_policy_afinfo *xfrm_policy_afinfo[NPROTO];
 
 static struct kmem_cache *xfrm_dst_cache __read_mostly;
 
-static HLIST_HEAD(xfrm_policy_gc_list);
-static DEFINE_SPINLOCK(xfrm_policy_gc_lock);
-
 static struct xfrm_policy_afinfo *xfrm_policy_get_afinfo(unsigned short family);
 static void xfrm_policy_put_afinfo(struct xfrm_policy_afinfo *afinfo);
 static void xfrm_init_pmtu(struct dst_entry *dst);
@@ -288,32 +285,6 @@ void xfrm_policy_destroy(struct xfrm_policy *policy)
 }
 EXPORT_SYMBOL(xfrm_policy_destroy);
 
-static void xfrm_policy_gc_kill(struct xfrm_policy *policy)
-{
-	atomic_inc(&policy->genid);
-
-	if (del_timer(&policy->timer))
-		atomic_dec(&policy->refcnt);
-
-	xfrm_pol_put(policy);
-}
-
-static void xfrm_policy_gc_task(struct work_struct *work)
-{
-	struct xfrm_policy *policy;
-	struct hlist_node *entry, *tmp;
-	struct hlist_head gc_list;
-
-	spin_lock_bh(&xfrm_policy_gc_lock);
-	gc_list.first = xfrm_policy_gc_list.first;
-	INIT_HLIST_HEAD(&xfrm_policy_gc_list);
-	spin_unlock_bh(&xfrm_policy_gc_lock);
-
-	hlist_for_each_entry_safe(policy, entry, tmp, &gc_list, bydst)
-		xfrm_policy_gc_kill(policy);
-}
-static DECLARE_WORK(xfrm_policy_gc_work, xfrm_policy_gc_task);
-
 /* Rule must be locked. Release descentant resources, announce
  * entry dead. The rule must be unlinked from lists to the moment.
  */
@@ -322,11 +293,12 @@ static void xfrm_policy_kill(struct xfrm_policy *policy)
 {
 	policy->walk.dead = 1;
 
-	spin_lock_bh(&xfrm_policy_gc_lock);
-	hlist_add_head(&policy->bydst, &xfrm_policy_gc_list);
-	spin_unlock_bh(&xfrm_policy_gc_lock);
+	atomic_inc(&policy->genid);
 
-	schedule_work(&xfrm_policy_gc_work);
+	if (del_timer(&policy->timer))
+		xfrm_pol_put(policy);
+
+	xfrm_pol_put(policy);
 }
 
 static unsigned int xfrm_policy_hashmax __read_mostly = 1 * 1024 * 1024;
@@ -2599,7 +2571,6 @@ static void xfrm_policy_fini(struct net *net)
 	audit_info.sessionid = -1;
 	audit_info.secid = 0;
 	xfrm_policy_flush(net, XFRM_POLICY_TYPE_MAIN, &audit_info);
-	flush_work(&xfrm_policy_gc_work);
 
 	WARN_ON(!list_empty(&net->xfrm.policy_all));
 
-- 
1.6.3.3

