From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 10/24] [IPSEC]: Move flow construction into xfrm_dst_lookup
Date: Wed, 07 Nov 2007 22:08:26 +0800
Message-ID: <E1IplZy-0001HD-00@gondolin.me.apana.org.au>
References: <20071107140701.GA4685@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3554 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758609AbXKGOIn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2007 09:08:43 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPSEC]: Move flow construction into xfrm_dst_lookup

This patch moves the flow construction from the callers of xfrm_dst_lookup
into that function.  It also changes xfrm_dst_lookup so that it takes an
xfrm state as its argument instead of explicit addresses.

This removes any address-specific logic from the callers of xfrm_dst_lookup
which is needed to correctly support inter-family transforms.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/net/xfrm.h      |   10 +---
 net/ipv4/xfrm4_policy.c |   80 ++++++++++++++++++---------------------
 net/ipv6/xfrm6_policy.c |   97 +++++++++++++++++-------------------------------
 net/xfrm/xfrm_policy.c  |   25 +++++++-----
 4 files changed, 91 insertions(+), 121 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index f96bae2..9b6af22 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -233,7 +233,8 @@ struct xfrm_policy_afinfo {
 	unsigned short		family;
 	struct dst_ops		*dst_ops;
 	void			(*garbage_collect)(void);
-	int			(*dst_lookup)(struct xfrm_dst **dst, struct flowi *fl);
+	struct dst_entry	*(*dst_lookup)(int tos, xfrm_address_t *saddr,
+					       xfrm_address_t *daddr);
 	int			(*get_saddr)(xfrm_address_t *saddr, xfrm_address_t *daddr);
 	struct dst_entry	*(*find_bundle)(struct flowi *fl, struct xfrm_policy *policy);
 	int			(*bundle_create)(struct xfrm_policy *policy, 
@@ -1079,7 +1080,6 @@ extern int xfrm6_find_1stfragopt(struct xfrm_state *x, struct sk_buff *skb,
 #ifdef CONFIG_XFRM
 extern int xfrm4_udp_encap_rcv(struct sock *sk, struct sk_buff *skb);
 extern int xfrm_user_policy(struct sock *sk, int optname, u8 __user *optval, int optlen);
-extern int xfrm_dst_lookup(struct xfrm_dst **dst, struct flowi *fl, unsigned short family);
 #else
 static inline int xfrm_user_policy(struct sock *sk, int optname, u8 __user *optval, int optlen)
 {
@@ -1092,13 +1092,9 @@ static inline int xfrm4_udp_encap_rcv(struct sock *sk, struct sk_buff *skb)
  	kfree_skb(skb);
 	return 0;
 }
-
-static inline int xfrm_dst_lookup(struct xfrm_dst **dst, struct flowi *fl, unsigned short family)
-{
-	return -EINVAL;
-} 
 #endif
 
+extern struct dst_entry *xfrm_dst_lookup(struct xfrm_state *x, int tos);
 struct xfrm_policy *xfrm_policy_alloc(gfp_t gfp);
 extern int xfrm_policy_walk(u8 type, int (*func)(struct xfrm_policy *, int, int, void*), void *);
 int xfrm_policy_insert(int dir, struct xfrm_policy *policy, int excl);
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index d903c8b..cebc847 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -8,7 +8,8 @@
  *
  */
 
-#include <linux/compiler.h>
+#include <linux/err.h>
+#include <linux/kernel.h>
 #include <linux/inetdevice.h>
 #include <net/dst.h>
 #include <net/xfrm.h>
@@ -17,28 +18,44 @@
 static struct dst_ops xfrm4_dst_ops;
 static struct xfrm_policy_afinfo xfrm4_policy_afinfo;
 
-static int xfrm4_dst_lookup(struct xfrm_dst **dst, struct flowi *fl)
+static struct dst_entry *xfrm4_dst_lookup(int tos, xfrm_address_t *saddr,
+					  xfrm_address_t *daddr)
 {
-	return __ip_route_output_key((struct rtable**)dst, fl);
-}
-
-static int xfrm4_get_saddr(xfrm_address_t *saddr, xfrm_address_t *daddr)
-{
-	struct rtable *rt;
-	struct flowi fl_tunnel = {
+	struct flowi fl = {
 		.nl_u = {
 			.ip4_u = {
+				.tos = tos,
 				.daddr = daddr->a4,
 			},
 		},
 	};
+	struct dst_entry *dst;
+	struct rtable *rt;
+	int err;
 
-	if (!xfrm4_dst_lookup((struct xfrm_dst **)&rt, &fl_tunnel)) {
-		saddr->a4 = rt->rt_src;
-		dst_release(&rt->u.dst);
-		return 0;
-	}
-	return -EHOSTUNREACH;
+	if (saddr)
+		fl.fl4_src = saddr->a4;
+
+	err = __ip_route_output_key(&rt, &fl);
+	dst = &rt->u.dst;
+	if (err)
+		dst = ERR_PTR(err);
+	return dst;
+}
+
+static int xfrm4_get_saddr(xfrm_address_t *saddr, xfrm_address_t *daddr)
+{
+	struct dst_entry *dst;
+	struct rtable *rt;
+
+	dst = xfrm4_dst_lookup(0, NULL, daddr);
+	if (IS_ERR(dst))
+		return -EHOSTUNREACH;
+
+	rt = (struct rtable *)dst;
+	saddr->a4 = rt->rt_src;
+	dst_release(dst);
+	return 0;
 }
 
 static struct dst_entry *
@@ -73,15 +90,7 @@ __xfrm4_bundle_create(struct xfrm_policy *policy, struct xfrm_state **xfrm, int
 	struct dst_entry *dst, *dst_prev;
 	struct rtable *rt0 = (struct rtable*)(*dst_p);
 	struct rtable *rt = rt0;
-	struct flowi fl_tunnel = {
-		.nl_u = {
-			.ip4_u = {
-				.saddr = fl->fl4_src,
-				.daddr = fl->fl4_dst,
-				.tos = fl->fl4_tos
-			}
-		}
-	};
+	int tos = fl->fl4_tos;
 	int i;
 	int err;
 	int header_len = 0;
@@ -119,25 +128,12 @@ __xfrm4_bundle_create(struct xfrm_policy *policy, struct xfrm_state **xfrm, int
 		trailer_len += xfrm[i]->props.trailer_len;
 
 		if (xfrm[i]->props.mode != XFRM_MODE_TRANSPORT) {
-			unsigned short encap_family = xfrm[i]->props.family;
-			switch (encap_family) {
-			case AF_INET:
-				fl_tunnel.fl4_dst = xfrm[i]->id.daddr.a4;
-				fl_tunnel.fl4_src = xfrm[i]->props.saddr.a4;
-				break;
-#if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
-			case AF_INET6:
-				ipv6_addr_copy(&fl_tunnel.fl6_dst, (struct in6_addr*)&xfrm[i]->id.daddr.a6);
-				ipv6_addr_copy(&fl_tunnel.fl6_src, (struct in6_addr*)&xfrm[i]->props.saddr.a6);
-				break;
-#endif
-			default:
-				BUG_ON(1);
-			}
-			err = xfrm_dst_lookup((struct xfrm_dst **)&rt,
-					      &fl_tunnel, encap_family);
-			if (err)
+			dst1 = xfrm_dst_lookup(xfrm[i], tos);
+			err = PTR_ERR(dst1);
+			if (IS_ERR(dst1))
 				goto error;
+
+			rt = (struct rtable *)dst1;
 		} else
 			dst_hold(&rt->u.dst);
 	}
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index ed29bef..864258f 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -11,7 +11,8 @@
  *
  */
 
-#include <linux/compiler.h>
+#include <linux/err.h>
+#include <linux/kernel.h>
 #include <linux/netdevice.h>
 #include <net/addrconf.h>
 #include <net/dst.h>
@@ -26,35 +27,40 @@
 static struct dst_ops xfrm6_dst_ops;
 static struct xfrm_policy_afinfo xfrm6_policy_afinfo;
 
-static int xfrm6_dst_lookup(struct xfrm_dst **xdst, struct flowi *fl)
+static struct dst_entry *xfrm6_dst_lookup(int tos, xfrm_address_t *saddr,
+					  xfrm_address_t *daddr)
 {
-	struct dst_entry *dst = ip6_route_output(NULL, fl);
-	int err = dst->error;
-	if (!err)
-		*xdst = (struct xfrm_dst *) dst;
-	else
+	struct flowi fl = {};
+	struct dst_entry *dst;
+	int err;
+
+	memcpy(&fl.fl6_dst, daddr, sizeof(fl.fl6_dst));
+	if (saddr)
+		memcpy(&fl.fl6_src, saddr, sizeof(fl.fl6_src));
+
+	dst = ip6_route_output(NULL, &fl);
+
+	err = dst->error;
+	if (dst->error) {
 		dst_release(dst);
-	return err;
+		dst = ERR_PTR(err);
+	}
+
+	return dst;
 }
 
 static int xfrm6_get_saddr(xfrm_address_t *saddr, xfrm_address_t *daddr)
 {
-	struct rt6_info *rt;
-	struct flowi fl_tunnel = {
-		.nl_u = {
-			.ip6_u = {
-				.daddr = *(struct in6_addr *)&daddr->a6,
-			},
-		},
-	};
-
-	if (!xfrm6_dst_lookup((struct xfrm_dst **)&rt, &fl_tunnel)) {
-		ipv6_get_saddr(&rt->u.dst, (struct in6_addr *)&daddr->a6,
-			       (struct in6_addr *)&saddr->a6);
-		dst_release(&rt->u.dst);
-		return 0;
-	}
-	return -EHOSTUNREACH;
+	struct dst_entry *dst;
+
+	dst = xfrm6_dst_lookup(0, NULL, daddr);
+	if (IS_ERR(dst))
+		return -EHOSTUNREACH;
+
+	ipv6_get_saddr(dst, (struct in6_addr *)&daddr->a6,
+		       (struct in6_addr *)&saddr->a6);
+	dst_release(dst);
+	return 0;
 }
 
 static struct dst_entry *
@@ -87,18 +93,6 @@ __xfrm6_find_bundle(struct flowi *fl, struct xfrm_policy *policy)
 	return dst;
 }
 
-static inline xfrm_address_t *__xfrm6_bundle_addr_remote(struct xfrm_state *x)
-{
-	return (x->type->flags & XFRM_TYPE_REMOTE_COADDR) ? x->coaddr :
-							    &x->id.daddr;
-}
-
-static inline xfrm_address_t *__xfrm6_bundle_addr_local(struct xfrm_state *x)
-{
-	return (x->type->flags & XFRM_TYPE_LOCAL_COADDR) ? x->coaddr :
-							   &x->props.saddr;
-}
-
 /* Allocate chain of dst_entry's, attach known xfrm's, calculate
  * all the metrics... Shortly, bundle a bundle.
  */
@@ -110,14 +104,6 @@ __xfrm6_bundle_create(struct xfrm_policy *policy, struct xfrm_state **xfrm, int
 	struct dst_entry *dst, *dst_prev;
 	struct rt6_info *rt0 = (struct rt6_info*)(*dst_p);
 	struct rt6_info *rt  = rt0;
-	struct flowi fl_tunnel = {
-		.nl_u = {
-			.ip6_u = {
-				.saddr = fl->fl6_src,
-				.daddr = fl->fl6_dst,
-			}
-		}
-	};
 	int i;
 	int err;
 	int header_len = 0;
@@ -160,25 +146,12 @@ __xfrm6_bundle_create(struct xfrm_policy *policy, struct xfrm_state **xfrm, int
 		trailer_len += xfrm[i]->props.trailer_len;
 
 		if (xfrm[i]->props.mode != XFRM_MODE_TRANSPORT) {
-			unsigned short encap_family = xfrm[i]->props.family;
-			switch(encap_family) {
-			case AF_INET:
-				fl_tunnel.fl4_dst = xfrm[i]->id.daddr.a4;
-				fl_tunnel.fl4_src = xfrm[i]->props.saddr.a4;
-				break;
-			case AF_INET6:
-				ipv6_addr_copy(&fl_tunnel.fl6_dst, (struct in6_addr *)__xfrm6_bundle_addr_remote(xfrm[i]));
-
-				ipv6_addr_copy(&fl_tunnel.fl6_src, (struct in6_addr *)__xfrm6_bundle_addr_local(xfrm[i]));
-				break;
-			default:
-				BUG_ON(1);
-			}
-
-			err = xfrm_dst_lookup((struct xfrm_dst **) &rt,
-					      &fl_tunnel, encap_family);
-			if (err)
+			dst1 = xfrm_dst_lookup(xfrm[i], 0);
+			err = PTR_ERR(dst1);
+			if (IS_ERR(dst1))
 				goto error;
+
+			rt = (struct rt6_info *)dst1;
 		} else
 			dst_hold(&rt->u.dst);
 	}
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index b702bd8..6168341 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -13,6 +13,7 @@
  *
  */
 
+#include <linux/err.h>
 #include <linux/slab.h>
 #include <linux/kmod.h>
 #include <linux/list.h>
@@ -84,21 +85,25 @@ int xfrm_selector_match(struct xfrm_selector *sel, struct flowi *fl,
 	return 0;
 }
 
-int xfrm_dst_lookup(struct xfrm_dst **dst, struct flowi *fl,
-		    unsigned short family)
+struct dst_entry *xfrm_dst_lookup(struct xfrm_state *x, int tos)
 {
-	struct xfrm_policy_afinfo *afinfo = xfrm_policy_get_afinfo(family);
-	int err = 0;
+	xfrm_address_t *saddr = &x->props.saddr;
+	xfrm_address_t *daddr = &x->id.daddr;
+	struct xfrm_policy_afinfo *afinfo;
+	struct dst_entry *dst;
 
+	if (x->type->flags & XFRM_TYPE_LOCAL_COADDR)
+		saddr = x->coaddr;
+	if (x->type->flags & XFRM_TYPE_REMOTE_COADDR)
+		daddr = x->coaddr;
+
+	afinfo = xfrm_policy_get_afinfo(x->props.family);
 	if (unlikely(afinfo == NULL))
-		return -EAFNOSUPPORT;
+		return ERR_PTR(-EAFNOSUPPORT);
 
-	if (likely(afinfo->dst_lookup != NULL))
-		err = afinfo->dst_lookup(dst, fl);
-	else
-		err = -EINVAL;
+	dst = afinfo->dst_lookup(tos, saddr, daddr);
 	xfrm_policy_put_afinfo(afinfo);
-	return err;
+	return dst;
 }
 EXPORT_SYMBOL(xfrm_dst_lookup);
 
