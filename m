From: Wei Wang <tracywwnj@gmail.com>
Subject: [PATCH net-next 15/21] xfrm: take refcnt of dst when creating struct xfrm_dst bundle
Date: Fri, 16 Jun 2017 10:47:38 -0700
Message-ID: <20170616174744.139688-16-tracywwnj@gmail.com>
References: <20170616174744.139688-1-tracywwnj@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>,
        Martin KaFai Lau <kafai@fb.com>, Wei Wang <weiwan@google.com>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:34556 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752271AbdFPRsd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2017 13:48:33 -0400
Received: by mail-pg0-f67.google.com with SMTP id j186so7271188pge.1
        for <netdev@vger.kernel.org>; Fri, 16 Jun 2017 10:48:33 -0700 (PDT)
In-Reply-To: <20170616174744.139688-1-tracywwnj@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>

During the creation of xfrm_dst bundle, always take ref count when
allocating the dst. This way, xfrm_bundle_create() will form a linked
list of dst with dst->child pointing to a ref counted dst child. And
the returned dst pointer is also ref counted. This makes the link from
the flow cache to this dst now ref counted properly.
As the dst is always ref counted properly, we can safely mark
DST_NOGC flag so dst_release() will release dst based on refcnt only.
And dst gc is no longer needed and all dst_free() and its related
function calls should be replaced with dst_release() or
dst_release_immediate().

The special handling logic for dst->child in dst_destroy() can be
replaced with a simple dst_release_immediate() call on the child to
release the whole list linked by dst->child pointer.
Previously used DST_NOHASH flag is not needed anymore as well. The
reason that DST_NOHASH is used in the existing code is mainly to prevent
the dst inserted in the fib tree to be wrongly destroyed during the
deletion of the xfrm_dst bundle. So in the existing code, DST_NOHASH
flag is marked in all the dst children except the one which is in the
fib tree.
However, with this patch series to remove dst gc logic and release dst
only based on ref count, it is safe to release all the children from a
xfrm_dst bundle as long as the dst children are all ref counted
properly which is already the case in the existing code.
So, this patch removes the use of DST_NOHASH flag.

Signed-off-by: Wei Wang <weiwan@google.com>
Acked-by: Martin KaFai Lau <kafai@fb.com>
---
 include/net/dst.h      |  1 -
 net/core/dst.c         | 19 ++-----------------
 net/xfrm/xfrm_policy.c | 48 ++++++++++++++++++++++++++++++------------------
 3 files changed, 32 insertions(+), 36 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 11d779803c0d..88ebb87ad312 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -51,7 +51,6 @@ struct dst_entry {
 #define DST_HOST		0x0001
 #define DST_NOXFRM		0x0002
 #define DST_NOPOLICY		0x0004
-#define DST_NOHASH		0x0008
 #define DST_NOCACHE		0x0010
 #define DST_NOCOUNT		0x0020
 #define DST_FAKE_RTABLE		0x0040
diff --git a/net/core/dst.c b/net/core/dst.c
index 2031f778bf2a..b262b22e686d 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -250,7 +250,6 @@ struct dst_entry *dst_destroy(struct dst_entry * dst)
 
 	smp_rmb();
 
-again:
 	child = dst->child;
 
 	if (!(dst->flags & DST_NOCOUNT))
@@ -269,20 +268,8 @@ struct dst_entry *dst_destroy(struct dst_entry * dst)
 		kmem_cache_free(dst->ops->kmem_cachep, dst);
 
 	dst = child;
-	if (dst) {
-		int nohash = dst->flags & DST_NOHASH;
-
-		if (atomic_dec_and_test(&dst->__refcnt)) {
-			/* We were real parent of this dst, so kill child. */
-			if (nohash)
-				goto again;
-		} else {
-			/* Child is still referenced, return it for freeing. */
-			if (nohash)
-				return dst;
-			/* Child is still in his hash table */
-		}
-	}
+	if (dst)
+		dst_release_immediate(dst);
 	return NULL;
 }
 EXPORT_SYMBOL(dst_destroy);
@@ -292,8 +279,6 @@ static void dst_destroy_rcu(struct rcu_head *head)
 	struct dst_entry *dst = container_of(head, struct dst_entry, rcu_head);
 
 	dst = dst_destroy(dst);
-	if (dst)
-		__dst_free(dst);
 }
 
 /* Operations to mark dst as DEAD and clean up the net device referenced
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index ed4e52d95172..85e1e13639cc 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1590,7 +1590,9 @@ static void xfrm_bundle_flo_delete(struct flow_cache_object *flo)
 	struct xfrm_dst *xdst = container_of(flo, struct xfrm_dst, flo);
 	struct dst_entry *dst = &xdst->u.dst;
 
-	dst_free(dst);
+	/* Mark DST_OBSOLETE_DEAD to fail the next xfrm_dst_check() */
+	dst->obsolete = DST_OBSOLETE_DEAD;
+	dst_release_immediate(dst);
 }
 
 static const struct flow_cache_ops xfrm_bundle_fc_ops = {
@@ -1620,7 +1622,7 @@ static inline struct xfrm_dst *xfrm_alloc_dst(struct net *net, int family)
 	default:
 		BUG();
 	}
-	xdst = dst_alloc(dst_ops, NULL, 0, DST_OBSOLETE_NONE, 0);
+	xdst = dst_alloc(dst_ops, NULL, 1, DST_OBSOLETE_NONE, DST_NOGC);
 
 	if (likely(xdst)) {
 		struct dst_entry *dst = &xdst->u.dst;
@@ -1723,10 +1725,11 @@ static struct dst_entry *xfrm_bundle_create(struct xfrm_policy *policy,
 
 		if (!dst_prev)
 			dst0 = dst1;
-		else {
-			dst_prev->child = dst_clone(dst1);
-			dst1->flags |= DST_NOHASH;
-		}
+		else
+			/* Ref count is taken during xfrm_alloc_dst()
+			 * No need to do dst_clone() on dst1
+			 */
+			dst_prev->child = dst1;
 
 		xdst->route = dst;
 		dst_copy_metrics(dst1, dst);
@@ -1792,7 +1795,7 @@ static struct dst_entry *xfrm_bundle_create(struct xfrm_policy *policy,
 		xfrm_state_put(xfrm[i]);
 free_dst:
 	if (dst0)
-		dst_free(dst0);
+		dst_release_immediate(dst0);
 	dst0 = ERR_PTR(err);
 	goto out;
 }
@@ -2073,7 +2076,11 @@ xfrm_bundle_lookup(struct net *net, const struct flowi *fl, u16 family, u8 dir,
 			pol_dead |= pols[i]->walk.dead;
 		}
 		if (pol_dead) {
-			dst_free(&xdst->u.dst);
+			/* Mark DST_OBSOLETE_DEAD to fail the next
+			 * xfrm_dst_check()
+			 */
+			xdst->u.dst.obsolete = DST_OBSOLETE_DEAD;
+			dst_release_immediate(&xdst->u.dst);
 			xdst = NULL;
 			num_pols = 0;
 			num_xfrms = 0;
@@ -2120,11 +2127,12 @@ xfrm_bundle_lookup(struct net *net, const struct flowi *fl, u16 family, u8 dir,
 	if (xdst) {
 		/* The policies were stolen for newly generated bundle */
 		xdst->num_pols = 0;
-		dst_free(&xdst->u.dst);
+		/* Mark DST_OBSOLETE_DEAD to fail the next xfrm_dst_check() */
+		xdst->u.dst.obsolete = DST_OBSOLETE_DEAD;
+		dst_release_immediate(&xdst->u.dst);
 	}
 
-	/* Flow cache does not have reference, it dst_free()'s,
-	 * but we do need to return one reference for original caller */
+	/* We do need to return one reference for original caller */
 	dst_hold(&new_xdst->u.dst);
 	return &new_xdst->flo;
 
@@ -2147,9 +2155,11 @@ xfrm_bundle_lookup(struct net *net, const struct flowi *fl, u16 family, u8 dir,
 inc_error:
 	XFRM_INC_STATS(net, LINUX_MIB_XFRMOUTPOLERROR);
 error:
-	if (xdst != NULL)
-		dst_free(&xdst->u.dst);
-	else
+	if (xdst != NULL) {
+		/* Mark DST_OBSOLETE_DEAD to fail the next xfrm_dst_check() */
+		xdst->u.dst.obsolete = DST_OBSOLETE_DEAD;
+		dst_release_immediate(&xdst->u.dst);
+	} else
 		xfrm_pols_put(pols, num_pols);
 	return ERR_PTR(err);
 }
@@ -2636,10 +2646,12 @@ static struct dst_entry *xfrm_dst_check(struct dst_entry *dst, u32 cookie)
 	 * notice.  That's what we are validating here via the
 	 * stale_bundle() check.
 	 *
-	 * When a policy's bundle is pruned, we dst_free() the XFRM
-	 * dst which causes it's ->obsolete field to be set to
-	 * DST_OBSOLETE_DEAD.  If an XFRM dst has been pruned like
-	 * this, we want to force a new route lookup.
+	 * When an xdst is removed from flow cache, DST_OBSOLETE_DEAD will
+	 * be marked on it.
+	 * When a dst is removed from the fib tree, DST_OBSOLETE_DEAD will
+	 * be marked on it.
+	 * Both will force stable_bundle() to fail on any xdst bundle with
+	 * this dst linked in it.
 	 */
 	if (dst->obsolete < 0 && !stale_bundle(dst))
 		return dst;
-- 
2.13.1.518.g3df882009-goog
