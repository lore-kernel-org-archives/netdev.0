From: David Miller <davem@davemloft.net>
Subject: [PATCH 10/15]: [XFRM]: Purge dst references to deleted SAs
 passively.
Date: Thu, 17 Aug 2006 01:28:25 -0700 (PDT)
Message-ID: <20060817.012825.48533033.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:36282
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932344AbWHQI2W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Aug 2006 04:28:22 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


[XFRM]: Purge dst references to deleted SAs passively.

Just let GC and other normal mechanisms take care of getting
rid of DST cache references to deleted xfrm_state objects
instead of walking all the policy bundles.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/xfrm.h     |    1 -
 net/xfrm/xfrm_policy.c |    2 +-
 net/xfrm/xfrm_state.c  |   17 -----------------
 3 files changed, 1 insertions(+), 19 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 3f54542..8123d49 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -895,7 +895,6 @@ struct xfrm_state * xfrm_find_acq(u8 mod
 				  int create, unsigned short family);
 extern void xfrm_policy_flush(void);
 extern int xfrm_sk_policy_insert(struct sock *sk, int dir, struct xfrm_policy *pol);
-extern int xfrm_flush_bundles(void);
 extern int xfrm_bundle_ok(struct xfrm_dst *xdst, struct flowi *fl, int family);
 extern void xfrm_init_pmtu(struct dst_entry *dst);
 
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index c16b30a..bc4d66a 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1238,7 +1238,7 @@ static void __xfrm_garbage_collect(void)
 	xfrm_prune_bundles(unused_bundle);
 }
 
-int xfrm_flush_bundles(void)
+static int xfrm_flush_bundles(void)
 {
 	xfrm_prune_bundles(stale_bundle);
 	return 0;
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index a3a7396..b1c0ae7 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -219,8 +219,6 @@ static struct work_struct xfrm_state_gc_
 static HLIST_HEAD(xfrm_state_gc_list);
 static DEFINE_SPINLOCK(xfrm_state_gc_lock);
 
-static int xfrm_state_gc_flush_bundles;
-
 int __xfrm_state_delete(struct xfrm_state *x);
 
 static struct xfrm_state_afinfo *xfrm_state_get_afinfo(unsigned short family);
@@ -255,11 +253,6 @@ static void xfrm_state_gc_task(void *dat
 	struct hlist_node *entry, *tmp;
 	struct hlist_head gc_list;
 
-	if (xfrm_state_gc_flush_bundles) {
-		xfrm_state_gc_flush_bundles = 0;
-		xfrm_flush_bundles();
-	}
-
 	spin_lock_bh(&xfrm_state_gc_lock);
 	gc_list.first = xfrm_state_gc_list.first;
 	INIT_HLIST_HEAD(&xfrm_state_gc_list);
@@ -413,16 +406,6 @@ int __xfrm_state_delete(struct xfrm_stat
 		if (del_timer(&x->rtimer))
 			__xfrm_state_put(x);
 
-		/* The number two in this test is the reference
-		 * mentioned in the comment below plus the reference
-		 * our caller holds.  A larger value means that
-		 * there are DSTs attached to this xfrm_state.
-		 */
-		if (atomic_read(&x->refcnt) > 2) {
-			xfrm_state_gc_flush_bundles = 1;
-			schedule_work(&xfrm_state_gc_work);
-		}
-
 		/* All xfrm_state objects are created by xfrm_state_alloc.
 		 * The xfrm_state_alloc call gives a reference, and that
 		 * is what we are dropping here.
-- 
1.4.2.rc2.g3e042

