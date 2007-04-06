From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: [RFC] [PATCH] [XFRM]: Restrict upper layer information by bundle.
Date: Fri,  6 Apr 2007 16:25:39 +0900
Message-ID: <11758443392651-git-send-email-nakam@linux-ipv6.org>
Cc: netdev@vger.kernel.org, Masahide NAKAMURA <nakam@linux-ipv6.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from usagi020.linux-ipv6.org ([203.178.140.20]:60843 "EHLO
	neptune.linux-ipv6.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1767549AbXDFIWb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Apr 2007 04:22:31 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On MIPv6 usage, XFRM sub policy is enabled.
When main (IPsec) and sub (MIPv6) policy selectors have the same
address set but different upper layer information (i.e. protocol
number and its ports or type/code), multiple bundle should be created.
However, currently we have issue to use the same bundle created for
the first time with all flows covered by the case.

It is useful for the bundle to have the upper layer information
to be restructured correctly if it does not match with the flow.

1. Bundle was created by two policies
Selector from another policy is added to xfrm_dst.
If the flow does not match the selector, it goes to slow path to
restructure new bundle by single policy.

2. Bundle was created by one policy
Flow cache is added to xfrm_dst as originated one. If the flow does
not match the cache, it goes to slow path to try searching another
policy.

Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
---
 include/net/flow.h     |    6 +++++
 include/net/xfrm.h     |   10 ++++++++
 net/xfrm/xfrm_policy.c |   55 ++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 71 insertions(+), 0 deletions(-)

diff --git a/include/net/flow.h b/include/net/flow.h
index ce4b10d..f3cc1f8 100644
--- a/include/net/flow.h
+++ b/include/net/flow.h
@@ -97,4 +97,10 @@ extern void *flow_cache_lookup(struct flowi *key, u16 family, u8 dir,
 extern void flow_cache_flush(void);
 extern atomic_t flow_cache_genid;
 
+static inline int flow_cache_uli_match(struct flowi *fl1, struct flowi *fl2)
+{
+	return (fl1->proto == fl2->proto &&
+		!memcmp(&fl1->uli_u, &fl2->uli_u, sizeof(fl1->uli_u)));
+}
+
 #endif
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 5a00aa8..c216c5e 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -584,6 +584,10 @@ struct xfrm_dst
 		struct rt6_info		rt6;
 	} u;
 	struct dst_entry *route;
+#ifdef CONFIG_XFRM_SUB_POLICY
+	struct flowi *origin;
+	struct xfrm_selector *partner;
+#endif
 	u32 genid;
 	u32 route_mtu_cached;
 	u32 child_mtu_cached;
@@ -596,6 +600,12 @@ static inline void xfrm_dst_destroy(struct xfrm_dst *xdst)
 	dst_release(xdst->route);
 	if (likely(xdst->u.dst.xfrm))
 		xfrm_state_put(xdst->u.dst.xfrm);
+#ifdef CONFIG_XFRM_SUB_POLICY
+	kfree(xdst->origin);
+	xdst->origin = NULL;
+	kfree(xdst->partner);
+	xdst->partner = NULL;
+#endif
 }
 
 extern void xfrm_dst_ifdown(struct dst_entry *dst, struct net_device *dev);
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 1942575..4a2f68f 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1330,6 +1330,40 @@ xfrm_bundle_create(struct xfrm_policy *policy, struct xfrm_state **xfrm, int nx,
 	return err;
 }
 
+static int inline
+xfrm_dst_alloc_copy(void **target, void *src, int size)
+{
+	if (!*target) {
+		*target = kmalloc(size, GFP_ATOMIC);
+		if (!*target)
+			return -ENOMEM;
+	}
+	memcpy(*target, src, size);
+	return 0;
+}
+
+static int inline
+xfrm_dst_update_parent(struct dst_entry *dst, struct xfrm_selector *sel)
+{
+#ifdef CONFIG_XFRM_SUB_POLICY
+	struct xfrm_dst *xdst = (struct xfrm_dst *)dst;
+	return xfrm_dst_alloc_copy((void **)&(xdst->partner),
+				   sel, sizeof(*sel));
+#else
+	return 0;
+#endif
+}
+
+static int inline
+xfrm_dst_update_origin(struct dst_entry *dst, struct flowi *fl)
+{
+#ifdef CONFIG_XFRM_SUB_POLICY
+	struct xfrm_dst *xdst = (struct xfrm_dst *)dst;
+	return xfrm_dst_alloc_copy((void **)&(xdst->origin), fl, sizeof(*fl));
+#else
+	return 0;
+#endif
+}
 
 static int stale_bundle(struct dst_entry *dst);
 
@@ -1518,6 +1552,18 @@ restart:
 			err = -EHOSTUNREACH;
 			goto error;
 		}
+
+		if (npols > 1)
+			err = xfrm_dst_update_parent(dst, &pols[1]->selector);
+		else
+			err = xfrm_dst_update_origin(dst, fl);
+		if (unlikely(err)) {
+			write_unlock_bh(&policy->lock);
+			if (dst)
+				dst_free(dst);
+			goto error;
+		}
+
 		dst->next = policy->bundles;
 		policy->bundles = dst;
 		dst_hold(dst);
@@ -1933,6 +1979,15 @@ int xfrm_bundle_ok(struct xfrm_policy *pol, struct xfrm_dst *first,
 	if (!dst_check(dst->path, ((struct xfrm_dst *)dst)->path_cookie) ||
 	    (dst->dev && !netif_running(dst->dev)))
 		return 0;
+#ifdef CONFIG_XFRM_SUB_POLICY
+	if (fl) {
+		if (first->origin && !flow_cache_uli_match(first->origin, fl))
+			return 0;
+		if (first->partner &&
+		    !xfrm_selector_match(first->partner, fl, family))
+			return 0;
+	}
+#endif
 
 	last = NULL;
 
-- 
1.5.0.1.GIT

