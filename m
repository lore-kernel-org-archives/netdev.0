From: David Miller <davem@davemloft.net>
Subject: [PATCH 9/10]: [XFRM]: Do not flush all bundles on SA insert.
Date: Tue, 15 Aug 2006 04:40:37 -0700 (PDT)
Message-ID: <20060815.044037.15244425.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:5083
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030260AbWHOLkj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Aug 2006 07:40:39 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


[XFRM]: Do not flush all bundles on SA insert.

Instead, simply set all potentially aliasing existing xfrm_state
objects to have the current generation counter value.

This will make routes get relooked up the next time an existing
route mentioning these aliased xfrm_state objects gets used,
via xfrm_dst_check().

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/xfrm.h     |    1 -
 net/xfrm/xfrm_policy.c |   10 ----------
 net/xfrm/xfrm_state.c  |   25 ++++++++++++++++++++-----
 3 files changed, 20 insertions(+), 16 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 7d18fff..3f54542 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -896,7 +896,6 @@ struct xfrm_state * xfrm_find_acq(u8 mod
 extern void xfrm_policy_flush(void);
 extern int xfrm_sk_policy_insert(struct sock *sk, int dir, struct xfrm_policy *pol);
 extern int xfrm_flush_bundles(void);
-extern void xfrm_flush_all_bundles(void);
 extern int xfrm_bundle_ok(struct xfrm_dst *xdst, struct flowi *fl, int family);
 extern void xfrm_init_pmtu(struct dst_entry *dst);
 
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index c504b9a..c16b30a 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1244,16 +1244,6 @@ int xfrm_flush_bundles(void)
 	return 0;
 }
 
-static int always_true(struct dst_entry *dst)
-{
-	return 1;
-}
-
-void xfrm_flush_all_bundles(void)
-{
-	xfrm_prune_bundles(always_true);
-}
-
 void xfrm_init_pmtu(struct dst_entry *dst)
 {
 	do {
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 3e8485a..a3a7396 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -655,13 +655,30 @@ static void __xfrm_state_insert(struct x
 		schedule_work(&xfrm_hash_work);
 }
 
+/* xfrm_state_lock is held */
+static void __xfrm_state_bump_genids(struct xfrm_state *xnew)
+{
+	unsigned short family = xnew->props.family;
+	u32 reqid = xnew->props.reqid;
+	struct xfrm_state *x;
+	struct hlist_node *entry;
+	unsigned int h;
+
+	h = xfrm_dst_hash(&xnew->id.daddr, reqid, family);
+	hlist_for_each_entry(x, entry, xfrm_state_bydst+h, bydst) {
+		if (x->props.family	== family &&
+		    x->props.reqid	== reqid &&
+		    !xfrm_addr_cmp(&x->id.daddr, &xnew->id.daddr, family))
+			x->genid = xfrm_state_genid;
+	}
+}
+
 void xfrm_state_insert(struct xfrm_state *x)
 {
 	spin_lock_bh(&xfrm_state_lock);
+	__xfrm_state_bump_genids(x);
 	__xfrm_state_insert(x);
 	spin_unlock_bh(&xfrm_state_lock);
-
-	xfrm_flush_all_bundles();
 }
 EXPORT_SYMBOL(xfrm_state_insert);
 
@@ -779,15 +796,13 @@ int xfrm_state_add(struct xfrm_state *x)
 				     x->id.proto,
 				     &x->id.daddr, &x->props.saddr, 0);
 
+	__xfrm_state_bump_genids(x);
 	__xfrm_state_insert(x);
 	err = 0;
 
 out:
 	spin_unlock_bh(&xfrm_state_lock);
 
-	if (!err)
-		xfrm_flush_all_bundles();
-
 	if (x1) {
 		xfrm_state_delete(x1);
 		xfrm_state_put(x1);
-- 
1.4.2.rc2.g3e042

