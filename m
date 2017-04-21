From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH net] xfrm: fix stack access out of bounds with CONFIG_XFRM_SUB_POLICY
Date: Fri, 21 Apr 2017 12:14:51 +0200
Message-ID: <17208ec89e09ed7223ffd2302abfa3475255c384.1492769294.git.sd@queasysnail.net>
Cc: Sabrina Dubroca <sd@queasysnail.net>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        Herbert Xu <herbert@gondor.apana.org.au>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46518 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1037752AbdDUKO5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 21 Apr 2017 06:14:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When CONFIG_XFRM_SUB_POLICY=y, xfrm_dst stores a copy of the flowi for
that dst. Unfortunately, the code that allocates and fills this copy
doesn't care about what type of flowi (flowi, flowi4, flowi6) gets
passed. In multiple code paths (from raw_sendmsg, from TCP when
replying to a FIN, in vxlan, geneve, and gre), the flowi that gets
passed to xfrm is actually an on-stack flowi4, so we end up reading
memory on the stack past the end of the flowi4 struct.

Since xfrm_dst->origin isn't used anywhere, just get rid of it.
xfrm_dst->partner isn't used either, so get rid of that too.

Fixes: ca116922afa8 ("xfrm: Eliminate "fl" and "pol" args to xfrm_bundle_ok().")
Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
---
 include/net/xfrm.h     | 10 ----------
 net/xfrm/xfrm_policy.c | 47 -----------------------------------------------
 2 files changed, 57 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 14d82bf16692..85bc8e7ade2e 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -945,10 +945,6 @@ struct xfrm_dst {
 	struct flow_cache_object flo;
 	struct xfrm_policy *pols[XFRM_POLICY_TYPE_MAX];
 	int num_pols, num_xfrms;
-#ifdef CONFIG_XFRM_SUB_POLICY
-	struct flowi *origin;
-	struct xfrm_selector *partner;
-#endif
 	u32 xfrm_genid;
 	u32 policy_genid;
 	u32 route_mtu_cached;
@@ -964,12 +960,6 @@ static inline void xfrm_dst_destroy(struct xfrm_dst *xdst)
 	dst_release(xdst->route);
 	if (likely(xdst->u.dst.xfrm))
 		xfrm_state_put(xdst->u.dst.xfrm);
-#ifdef CONFIG_XFRM_SUB_POLICY
-	kfree(xdst->origin);
-	xdst->origin = NULL;
-	kfree(xdst->partner);
-	xdst->partner = NULL;
-#endif
 }
 #endif
 
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 236cbbc0ab9c..56fba8f073f5 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1793,43 +1793,6 @@ static struct dst_entry *xfrm_bundle_create(struct xfrm_policy *policy,
 	goto out;
 }
 
-#ifdef CONFIG_XFRM_SUB_POLICY
-static int xfrm_dst_alloc_copy(void **target, const void *src, int size)
-{
-	if (!*target) {
-		*target = kmalloc(size, GFP_ATOMIC);
-		if (!*target)
-			return -ENOMEM;
-	}
-
-	memcpy(*target, src, size);
-	return 0;
-}
-#endif
-
-static int xfrm_dst_update_parent(struct dst_entry *dst,
-				  const struct xfrm_selector *sel)
-{
-#ifdef CONFIG_XFRM_SUB_POLICY
-	struct xfrm_dst *xdst = (struct xfrm_dst *)dst;
-	return xfrm_dst_alloc_copy((void **)&(xdst->partner),
-				   sel, sizeof(*sel));
-#else
-	return 0;
-#endif
-}
-
-static int xfrm_dst_update_origin(struct dst_entry *dst,
-				  const struct flowi *fl)
-{
-#ifdef CONFIG_XFRM_SUB_POLICY
-	struct xfrm_dst *xdst = (struct xfrm_dst *)dst;
-	return xfrm_dst_alloc_copy((void **)&(xdst->origin), fl, sizeof(*fl));
-#else
-	return 0;
-#endif
-}
-
 static int xfrm_expand_policies(const struct flowi *fl, u16 family,
 				struct xfrm_policy **pols,
 				int *num_pols, int *num_xfrms)
@@ -1901,16 +1864,6 @@ xfrm_resolve_and_create_bundle(struct xfrm_policy **pols, int num_pols,
 
 	xdst = (struct xfrm_dst *)dst;
 	xdst->num_xfrms = err;
-	if (num_pols > 1)
-		err = xfrm_dst_update_parent(dst, &pols[1]->selector);
-	else
-		err = xfrm_dst_update_origin(dst, fl);
-	if (unlikely(err)) {
-		dst_free(dst);
-		XFRM_INC_STATS(net, LINUX_MIB_XFRMOUTBUNDLECHECKERROR);
-		return ERR_PTR(err);
-	}
-
 	xdst->num_pols = num_pols;
 	memcpy(xdst->pols, pols, sizeof(struct xfrm_policy *) * num_pols);
 	xdst->policy_genid = atomic_read(&pols[0]->genid);
-- 
2.12.2
