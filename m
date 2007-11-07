From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 11/24] [IPSEC]: Merge common code into xfrm_bundle_create
Date: Wed, 07 Nov 2007 22:08:27 +0800
Message-ID: <E1IplZz-0001HL-00@gondolin.me.apana.org.au>
References: <20071107140701.GA4685@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3794 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758198AbXKGO11 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2007 09:27:27 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPSEC]: Merge common code into xfrm_bundle_create

Half of the code in xfrm4_bundle_create and xfrm6_bundle_create are common.
This patch extracts that logic and puts it into xfrm_bundle_create.  The
rest of it are then accessed through afinfo.

As a result this fixes the problem with inter-family transforms where we
treat every xfrm dst in the bundle as if it belongs to the top family.

This patch also fixes a long-standing error-path bug where we may free the
xfrm states twice.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/net/xfrm.h      |   11 +-
 net/ipv4/xfrm4_policy.c |  134 ++++++-----------------------------
 net/ipv6/xfrm6_policy.c |  143 ++++++-------------------------------
 net/xfrm/xfrm_policy.c  |  183 +++++++++++++++++++++++++++++++++++++++++-------
 4 files changed, 215 insertions(+), 256 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 9b6af22..4178c2b 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -227,6 +227,7 @@ struct km_event
 	u32	event;
 };
 
+struct net_device;
 struct xfrm_type;
 struct xfrm_dst;
 struct xfrm_policy_afinfo {
@@ -237,13 +238,11 @@ struct xfrm_policy_afinfo {
 					       xfrm_address_t *daddr);
 	int			(*get_saddr)(xfrm_address_t *saddr, xfrm_address_t *daddr);
 	struct dst_entry	*(*find_bundle)(struct flowi *fl, struct xfrm_policy *policy);
-	int			(*bundle_create)(struct xfrm_policy *policy, 
-						 struct xfrm_state **xfrm, 
-						 int nx,
-						 struct flowi *fl, 
-						 struct dst_entry **dst_p);
 	void			(*decode_session)(struct sk_buff *skb,
 						  struct flowi *fl);
+	int			(*get_tos)(struct flowi *fl);
+	int			(*fill_dst)(struct xfrm_dst *xdst,
+					    struct net_device *dev);
 };
 
 extern int xfrm_policy_register_afinfo(struct xfrm_policy_afinfo *afinfo);
@@ -1094,7 +1093,6 @@ static inline int xfrm4_udp_encap_rcv(struct sock *sk, struct sk_buff *skb)
 }
 #endif
 
-extern struct dst_entry *xfrm_dst_lookup(struct xfrm_state *x, int tos);
 struct xfrm_policy *xfrm_policy_alloc(gfp_t gfp);
 extern int xfrm_policy_walk(u8 type, int (*func)(struct xfrm_policy *, int, int, void*), void *);
 int xfrm_policy_insert(int dir, struct xfrm_policy *policy, int excl);
@@ -1113,7 +1111,6 @@ extern int xfrm_policy_flush(u8 type, struct xfrm_audit *audit_info);
 extern int xfrm_sk_policy_insert(struct sock *sk, int dir, struct xfrm_policy *pol);
 extern int xfrm_bundle_ok(struct xfrm_policy *pol, struct xfrm_dst *xdst,
 			  struct flowi *fl, int family, int strict);
-extern void xfrm_init_pmtu(struct dst_entry *dst);
 
 #ifdef CONFIG_XFRM_MIGRATE
 extern int km_migrate(struct xfrm_selector *sel, u8 dir, u8 type,
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index cebc847..1d75243 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -79,122 +79,39 @@ __xfrm4_find_bundle(struct flowi *fl, struct xfrm_policy *policy)
 	return dst;
 }
 
-/* Allocate chain of dst_entry's, attach known xfrm's, calculate
- * all the metrics... Shortly, bundle a bundle.
- */
-
-static int
-__xfrm4_bundle_create(struct xfrm_policy *policy, struct xfrm_state **xfrm, int nx,
-		      struct flowi *fl, struct dst_entry **dst_p)
+static int xfrm4_get_tos(struct flowi *fl)
 {
-	struct dst_entry *dst, *dst_prev;
-	struct rtable *rt0 = (struct rtable*)(*dst_p);
-	struct rtable *rt = rt0;
-	int tos = fl->fl4_tos;
-	int i;
-	int err;
-	int header_len = 0;
-	int trailer_len = 0;
-
-	dst = dst_prev = NULL;
-	dst_hold(&rt->u.dst);
-
-	for (i = 0; i < nx; i++) {
-		struct dst_entry *dst1 = dst_alloc(&xfrm4_dst_ops);
-		struct xfrm_dst *xdst;
-
-		if (unlikely(dst1 == NULL)) {
-			err = -ENOBUFS;
-			dst_release(&rt->u.dst);
-			goto error;
-		}
+	return fl->fl4_tos;
+}
 
-		if (!dst)
-			dst = dst1;
-		else {
-			dst_prev->child = dst1;
-			dst1->flags |= DST_NOHASH;
-			dst_clone(dst1);
-		}
+static int xfrm4_fill_dst(struct xfrm_dst *xdst, struct net_device *dev)
+{
+	struct rtable *rt = (struct rtable *)xdst->route;
 
-		xdst = (struct xfrm_dst *)dst1;
-		xdst->route = &rt->u.dst;
-		xdst->genid = xfrm[i]->genid;
+	xdst->u.rt.fl = rt->fl;
 
-		dst1->next = dst_prev;
-		dst_prev = dst1;
+	xdst->u.dst.dev = dev;
+	dev_hold(dev);
 
-		header_len += xfrm[i]->props.header_len;
-		trailer_len += xfrm[i]->props.trailer_len;
+	xdst->u.rt.idev = in_dev_get(dev);
+	if (!xdst->u.rt.idev)
+		return -ENODEV;
 
-		if (xfrm[i]->props.mode != XFRM_MODE_TRANSPORT) {
-			dst1 = xfrm_dst_lookup(xfrm[i], tos);
-			err = PTR_ERR(dst1);
-			if (IS_ERR(dst1))
-				goto error;
+	xdst->u.rt.peer = rt->peer;
+	if (rt->peer)
+		atomic_inc(&rt->peer->refcnt);
 
-			rt = (struct rtable *)dst1;
-		} else
-			dst_hold(&rt->u.dst);
-	}
+	/* Sheit... I remember I did this right. Apparently,
+	 * it was magically lost, so this code needs audit */
+	xdst->u.rt.rt_flags = rt->rt_flags & (RTCF_BROADCAST | RTCF_MULTICAST |
+					      RTCF_LOCAL);
+	xdst->u.rt.rt_type = rt->rt_type;
+	xdst->u.rt.rt_src = rt->rt_src;
+	xdst->u.rt.rt_dst = rt->rt_dst;
+	xdst->u.rt.rt_gateway = rt->rt_gateway;
+	xdst->u.rt.rt_spec_dst = rt->rt_spec_dst;
 
-	dst_prev->child = &rt->u.dst;
-	dst->path = &rt->u.dst;
-
-	/* Copy neighbout for reachability confirmation */
-	dst->neighbour = neigh_clone(rt->u.dst.neighbour);
-
-	*dst_p = dst;
-	dst = dst_prev;
-
-	dst_prev = *dst_p;
-	i = 0;
-	err = -ENODEV;
-	for (; dst_prev != &rt->u.dst; dst_prev = dst_prev->child) {
-		struct xfrm_dst *x = (struct xfrm_dst*)dst_prev;
-		x->u.rt.fl = *fl;
-
-		dst_prev->xfrm = xfrm[i++];
-		dst_prev->dev = rt->u.dst.dev;
-		if (!rt->u.dst.dev)
-			goto error;
-		dev_hold(rt->u.dst.dev);
-
-		x->u.rt.idev = in_dev_get(rt->u.dst.dev);
-		if (!x->u.rt.idev)
-			goto error;
-
-		dst_prev->obsolete	= -1;
-		dst_prev->flags	       |= DST_HOST;
-		dst_prev->lastuse	= jiffies;
-		dst_prev->header_len	= header_len;
-		dst_prev->trailer_len	= trailer_len;
-		memcpy(&dst_prev->metrics, &x->route->metrics, sizeof(dst_prev->metrics));
-
-		dst_prev->input = dst_discard;
-		dst_prev->output = dst_prev->xfrm->outer_mode->afinfo->output;
-		if (rt0->peer)
-			atomic_inc(&rt0->peer->refcnt);
-		x->u.rt.peer = rt0->peer;
-		/* Sheit... I remember I did this right. Apparently,
-		 * it was magically lost, so this code needs audit */
-		x->u.rt.rt_flags = rt0->rt_flags&(RTCF_BROADCAST|RTCF_MULTICAST|RTCF_LOCAL);
-		x->u.rt.rt_type = rt0->rt_type;
-		x->u.rt.rt_src = rt0->rt_src;
-		x->u.rt.rt_dst = rt0->rt_dst;
-		x->u.rt.rt_gateway = rt0->rt_gateway;
-		x->u.rt.rt_spec_dst = rt0->rt_spec_dst;
-		header_len -= x->u.dst.xfrm->props.header_len;
-		trailer_len -= x->u.dst.xfrm->props.trailer_len;
-	}
-
-	xfrm_init_pmtu(dst);
 	return 0;
-
-error:
-	if (dst)
-		dst_free(dst);
-	return err;
 }
 
 static void
@@ -330,8 +247,9 @@ static struct xfrm_policy_afinfo xfrm4_policy_afinfo = {
 	.dst_lookup =		xfrm4_dst_lookup,
 	.get_saddr =		xfrm4_get_saddr,
 	.find_bundle = 		__xfrm4_find_bundle,
-	.bundle_create =	__xfrm4_bundle_create,
 	.decode_session =	_decode_session4,
+	.get_tos =		xfrm4_get_tos,
+	.fill_dst =		xfrm4_fill_dst,
 };
 
 static void __init xfrm4_policy_init(void)
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 864258f..50a3841 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -93,126 +93,34 @@ __xfrm6_find_bundle(struct flowi *fl, struct xfrm_policy *policy)
 	return dst;
 }
 
-/* Allocate chain of dst_entry's, attach known xfrm's, calculate
- * all the metrics... Shortly, bundle a bundle.
- */
-
-static int
-__xfrm6_bundle_create(struct xfrm_policy *policy, struct xfrm_state **xfrm, int nx,
-		      struct flowi *fl, struct dst_entry **dst_p)
+static int xfrm6_get_tos(struct flowi *fl)
 {
-	struct dst_entry *dst, *dst_prev;
-	struct rt6_info *rt0 = (struct rt6_info*)(*dst_p);
-	struct rt6_info *rt  = rt0;
-	int i;
-	int err;
-	int header_len = 0;
-	int trailer_len = 0;
-
-	dst = dst_prev = NULL;
-	dst_hold(&rt->u.dst);
-
-	for (i = 0; i < nx; i++) {
-		struct dst_entry *dst1 = dst_alloc(&xfrm6_dst_ops);
-		struct xfrm_dst *xdst;
-
-		if (unlikely(dst1 == NULL)) {
-			err = -ENOBUFS;
-			dst_release(&rt->u.dst);
-			goto error;
-		}
-
-		if (!dst)
-			dst = dst1;
-		else {
-			dst_prev->child = dst1;
-			dst1->flags |= DST_NOHASH;
-			dst_clone(dst1);
-		}
-
-		xdst = (struct xfrm_dst *)dst1;
-		xdst->route = &rt->u.dst;
-		xdst->genid = xfrm[i]->genid;
-		if (rt->rt6i_node)
-			xdst->route_cookie = rt->rt6i_node->fn_sernum;
-
-		dst1->next = dst_prev;
-		dst_prev = dst1;
-
-		if (xfrm[i]->type->flags & XFRM_TYPE_NON_FRAGMENT)
-			((struct rt6_info *)dst)->nfheader_len +=
-				xfrm[i]->props.header_len;
-		header_len += xfrm[i]->props.header_len;
-		trailer_len += xfrm[i]->props.trailer_len;
-
-		if (xfrm[i]->props.mode != XFRM_MODE_TRANSPORT) {
-			dst1 = xfrm_dst_lookup(xfrm[i], 0);
-			err = PTR_ERR(dst1);
-			if (IS_ERR(dst1))
-				goto error;
-
-			rt = (struct rt6_info *)dst1;
-		} else
-			dst_hold(&rt->u.dst);
-	}
+	return 0;
+}
 
-	dst_prev->child = &rt->u.dst;
-	dst->path = &rt->u.dst;
-
-	/* Copy neighbour for reachability confirmation */
-	dst->neighbour = neigh_clone(rt->u.dst.neighbour);
-
-	if (rt->rt6i_node)
-		((struct xfrm_dst *)dst)->path_cookie = rt->rt6i_node->fn_sernum;
-
-	*dst_p = dst;
-	dst = dst_prev;
-
-	dst_prev = *dst_p;
-	i = 0;
-	err = -ENODEV;
-	for (; dst_prev != &rt->u.dst; dst_prev = dst_prev->child) {
-		struct xfrm_dst *x = (struct xfrm_dst*)dst_prev;
-
-		dst_prev->xfrm = xfrm[i++];
-		dst_prev->dev = rt->u.dst.dev;
-		if (!rt->u.dst.dev)
-			goto error;
-		dev_hold(rt->u.dst.dev);
-
-		x->u.rt6.rt6i_idev = in6_dev_get(rt->u.dst.dev);
-		if (!x->u.rt6.rt6i_idev)
-			goto error;
-
-		dst_prev->obsolete	= -1;
-		dst_prev->flags	       |= DST_HOST;
-		dst_prev->lastuse	= jiffies;
-		dst_prev->header_len	= header_len;
-		dst_prev->trailer_len	= trailer_len;
-		memcpy(&dst_prev->metrics, &x->route->metrics, sizeof(dst_prev->metrics));
-
-		dst_prev->input = dst_discard;
-		dst_prev->output = dst_prev->xfrm->outer_mode->afinfo->output;
-		/* Sheit... I remember I did this right. Apparently,
-		 * it was magically lost, so this code needs audit */
-		x->u.rt6.rt6i_flags    = rt0->rt6i_flags&(RTCF_BROADCAST|RTCF_MULTICAST|RTCF_LOCAL);
-		x->u.rt6.rt6i_metric   = rt0->rt6i_metric;
-		x->u.rt6.rt6i_node     = rt0->rt6i_node;
-		x->u.rt6.rt6i_gateway  = rt0->rt6i_gateway;
-		memcpy(&x->u.rt6.rt6i_gateway, &rt0->rt6i_gateway, sizeof(x->u.rt6.rt6i_gateway));
-		x->u.rt6.rt6i_dst      = rt0->rt6i_dst;
-		x->u.rt6.rt6i_src      = rt0->rt6i_src;
-		header_len -= x->u.dst.xfrm->props.header_len;
-		trailer_len -= x->u.dst.xfrm->props.trailer_len;
-	}
+static int xfrm6_fill_dst(struct xfrm_dst *xdst, struct net_device *dev)
+{
+	struct rt6_info *rt = (struct rt6_info*)xdst->route;
+
+	xdst->u.dst.dev = dev;
+	dev_hold(dev);
+
+	xdst->u.rt6.rt6i_idev = in6_dev_get(rt->u.dst.dev);
+	if (!xdst->u.rt6.rt6i_idev)
+		return -ENODEV;
+
+	/* Sheit... I remember I did this right. Apparently,
+	 * it was magically lost, so this code needs audit */
+	xdst->u.rt6.rt6i_flags = rt->rt6i_flags & (RTCF_BROADCAST |
+						   RTCF_MULTICAST |
+						   RTCF_LOCAL);
+	xdst->u.rt6.rt6i_metric = rt->rt6i_metric;
+	xdst->u.rt6.rt6i_node = rt->rt6i_node;
+	xdst->u.rt6.rt6i_gateway = rt->rt6i_gateway;
+	xdst->u.rt6.rt6i_dst = rt->rt6i_dst;
+	xdst->u.rt6.rt6i_src = rt->rt6i_src;
 
-	xfrm_init_pmtu(dst);
 	return 0;
-
-error:
-	if (dst)
-		dst_free(dst);
-	return err;
 }
 
 static inline void
@@ -355,8 +263,9 @@ static struct xfrm_policy_afinfo xfrm6_policy_afinfo = {
 	.dst_lookup =		xfrm6_dst_lookup,
 	.get_saddr = 		xfrm6_get_saddr,
 	.find_bundle =		__xfrm6_find_bundle,
-	.bundle_create =	__xfrm6_bundle_create,
 	.decode_session =	_decode_session6,
+	.get_tos =		xfrm6_get_tos,
+	.fill_dst =		xfrm6_fill_dst,
 };
 
 static void __init xfrm6_policy_init(void)
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 6168341..5a03612 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -24,6 +24,7 @@
 #include <linux/netfilter.h>
 #include <linux/module.h>
 #include <linux/cache.h>
+#include <net/dst.h>
 #include <net/xfrm.h>
 #include <net/ip.h>
 
@@ -50,6 +51,7 @@ static DEFINE_SPINLOCK(xfrm_policy_gc_lock);
 
 static struct xfrm_policy_afinfo *xfrm_policy_get_afinfo(unsigned short family);
 static void xfrm_policy_put_afinfo(struct xfrm_policy_afinfo *afinfo);
+static void xfrm_init_pmtu(struct dst_entry *dst);
 
 static inline int
 __xfrm4_selector_match(struct xfrm_selector *sel, struct flowi *fl)
@@ -85,7 +87,8 @@ int xfrm_selector_match(struct xfrm_selector *sel, struct flowi *fl,
 	return 0;
 }
 
-struct dst_entry *xfrm_dst_lookup(struct xfrm_state *x, int tos)
+static inline struct dst_entry *xfrm_dst_lookup(struct xfrm_state *x, int tos,
+						int family)
 {
 	xfrm_address_t *saddr = &x->props.saddr;
 	xfrm_address_t *daddr = &x->id.daddr;
@@ -97,7 +100,7 @@ struct dst_entry *xfrm_dst_lookup(struct xfrm_state *x, int tos)
 	if (x->type->flags & XFRM_TYPE_REMOTE_COADDR)
 		daddr = x->coaddr;
 
-	afinfo = xfrm_policy_get_afinfo(x->props.family);
+	afinfo = xfrm_policy_get_afinfo(family);
 	if (unlikely(afinfo == NULL))
 		return ERR_PTR(-EAFNOSUPPORT);
 
@@ -105,7 +108,6 @@ struct dst_entry *xfrm_dst_lookup(struct xfrm_state *x, int tos)
 	xfrm_policy_put_afinfo(afinfo);
 	return dst;
 }
-EXPORT_SYMBOL(xfrm_dst_lookup);
 
 static inline unsigned long make_jiffies(long secs)
 {
@@ -1235,24 +1237,164 @@ xfrm_find_bundle(struct flowi *fl, struct xfrm_policy *policy, unsigned short fa
 	return x;
 }
 
-/* Allocate chain of dst_entry's, attach known xfrm's, calculate
- * all the metrics... Shortly, bundle a bundle.
- */
+static inline int xfrm_get_tos(struct flowi *fl, int family)
+{
+	struct xfrm_policy_afinfo *afinfo = xfrm_policy_get_afinfo(family);
+	int tos;
 
-static int
-xfrm_bundle_create(struct xfrm_policy *policy, struct xfrm_state **xfrm, int nx,
-		   struct flowi *fl, struct dst_entry **dst_p,
-		   unsigned short family)
+	if (!afinfo)
+		return -EINVAL;
+
+	tos = afinfo->get_tos(fl);
+
+	xfrm_policy_put_afinfo(afinfo);
+
+	return tos;
+}
+
+static inline struct xfrm_dst *xfrm_alloc_dst(int family)
 {
-	int err;
 	struct xfrm_policy_afinfo *afinfo = xfrm_policy_get_afinfo(family);
-	if (unlikely(afinfo == NULL))
+	struct xfrm_dst *xdst;
+
+	if (!afinfo)
+		return ERR_PTR(-EINVAL);
+
+	xdst = dst_alloc(afinfo->dst_ops) ?: ERR_PTR(-ENOBUFS);
+
+	xfrm_policy_put_afinfo(afinfo);
+
+	return xdst;
+}
+
+static inline int xfrm_fill_dst(struct xfrm_dst *xdst, struct net_device *dev)
+{
+	struct xfrm_policy_afinfo *afinfo =
+		xfrm_policy_get_afinfo(xdst->u.dst.ops->family);
+	int err;
+
+	if (!afinfo)
 		return -EINVAL;
-	err = afinfo->bundle_create(policy, xfrm, nx, fl, dst_p);
+
+	err = afinfo->fill_dst(xdst, dev);
+
 	xfrm_policy_put_afinfo(afinfo);
+
 	return err;
 }
 
+/* Allocate chain of dst_entry's, attach known xfrm's, calculate
+ * all the metrics... Shortly, bundle a bundle.
+ */
+
+static struct dst_entry *xfrm_bundle_create(struct xfrm_policy *policy,
+					    struct xfrm_state **xfrm, int nx,
+					    struct flowi *fl,
+					    struct dst_entry *dst)
+{
+	unsigned long now = jiffies;
+	struct net_device *dev;
+	struct dst_entry *dst_prev = NULL;
+	struct dst_entry *dst0 = NULL;
+	int i = 0;
+	int err;
+	int header_len = 0;
+	int trailer_len = 0;
+	int tos;
+	int family = policy->selector.family;
+
+	tos = xfrm_get_tos(fl, family);
+	err = tos;
+	if (tos < 0)
+		goto put_states;
+
+	dst_hold(dst);
+
+	for (; i < nx; i++) {
+		struct xfrm_dst *xdst = xfrm_alloc_dst(family);
+		struct dst_entry *dst1 = &xdst->u.dst;
+
+		err = PTR_ERR(xdst);
+		if (IS_ERR(xdst)) {
+			dst_release(dst);
+			goto put_states;
+		}
+
+		if (!dst_prev)
+			dst0 = dst1;
+		else {
+			dst_prev->child = dst_clone(dst1);
+			dst1->flags |= DST_NOHASH;
+		}
+
+		xdst->route = dst;
+		memcpy(&dst1->metrics, &dst->metrics, sizeof(dst->metrics));
+
+		if (xfrm[i]->props.mode != XFRM_MODE_TRANSPORT) {
+			family = xfrm[i]->props.family;
+			dst = xfrm_dst_lookup(xfrm[i], tos, family);
+			err = PTR_ERR(dst);
+			if (IS_ERR(dst))
+				goto put_states;
+		} else
+			dst_hold(dst);
+
+		dst1->xfrm = xfrm[i];
+		xdst->genid = xfrm[i]->genid;
+
+		dst1->obsolete = -1;
+		dst1->flags |= DST_HOST;
+		dst1->lastuse = now;
+
+		dst1->input = dst_discard;
+		dst1->output = xfrm[i]->outer_mode->afinfo->output;
+
+		dst1->next = dst_prev;
+		dst_prev = dst1;
+
+		header_len += xfrm[i]->props.header_len;
+		trailer_len += xfrm[i]->props.trailer_len;
+	}
+
+	dst_prev->child = dst;
+	dst0->path = dst;
+
+	err = -ENODEV;
+	dev = dst->dev;
+	if (!dev)
+		goto free_dst;
+
+	/* Copy neighbout for reachability confirmation */
+	dst0->neighbour = neigh_clone(dst->neighbour);
+
+	xfrm_init_pmtu(dst_prev);
+
+	for (dst_prev = dst0; dst_prev != dst; dst_prev = dst_prev->child) {
+		struct xfrm_dst *xdst = (struct xfrm_dst *)dst_prev;
+
+		err = xfrm_fill_dst(xdst, dev);
+		if (err)
+			goto free_dst;
+
+		dst_prev->header_len = header_len;
+		dst_prev->trailer_len = trailer_len;
+		header_len -= xdst->u.dst.xfrm->props.header_len;
+		trailer_len -= xdst->u.dst.xfrm->props.trailer_len;
+	}
+
+out:
+	return dst0;
+
+put_states:
+	for (; i < nx; i++)
+		xfrm_state_put(xfrm[i]);
+free_dst:
+	if (dst0)
+		dst_free(dst0);
+	dst0 = ERR_PTR(err);
+	goto out;
+}
+
 static int inline
 xfrm_dst_alloc_copy(void **target, void *src, int size)
 {
@@ -1452,15 +1594,10 @@ restart:
 			return 0;
 		}
 
-		dst = dst_orig;
-		err = xfrm_bundle_create(policy, xfrm, nx, fl, &dst, family);
-
-		if (unlikely(err)) {
-			int i;
-			for (i=0; i<nx; i++)
-				xfrm_state_put(xfrm[i]);
+		dst = xfrm_bundle_create(policy, xfrm, nx, fl, dst_orig);
+		err = PTR_ERR(dst);
+		if (IS_ERR(dst))
 			goto error;
-		}
 
 		for (pi = 0; pi < npols; pi++) {
 			read_lock_bh(&pols[pi]->lock);
@@ -1883,7 +2020,7 @@ static int xfrm_flush_bundles(void)
 	return 0;
 }
 
-void xfrm_init_pmtu(struct dst_entry *dst)
+static void xfrm_init_pmtu(struct dst_entry *dst)
 {
 	do {
 		struct xfrm_dst *xdst = (struct xfrm_dst *)dst;
@@ -1904,8 +2041,6 @@ void xfrm_init_pmtu(struct dst_entry *dst)
 	} while ((dst = dst->next));
 }
 
-EXPORT_SYMBOL(xfrm_init_pmtu);
-
 /* Check that the bundle accepts the flow and its components are
  * still valid.
  */
