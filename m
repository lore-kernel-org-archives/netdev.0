From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [IPSEC] Store idev entries (was: [PATCH][IPv6][IPsec] stop infinite loop)
Date: Sat, 30 Apr 2005 21:43:49 +1000
Message-ID: <20050430114349.GA24573@gondor.apana.org.au>
References: <4272EC95.20401@miyazawa.org> <20050430.120736.45974367.yoshfuji@linux-ipv6.org> <20050430031159.GA24326@gondor.apana.org.au> <20050430082339.GA20338@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="4Ckj6UjgE2iN1+kY"
Cc: kazunori@miyazawa.org, davem@davemloft.net, netdev@oss.sgi.com,
        usagi-core@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
In-Reply-To: <20050430082339.GA20338@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--4Ckj6UjgE2iN1+kY
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi:

The ref counting on loopback_idev wasn't quite right.  Here is the
corrected version.


However, I did find a bug that stopped IPsec/IPv6 from working.  About
a month ago IPv6 started using rt6i_idev->dev on the cached socket dst
entries.  If the cached socket dst entry is IPsec, then rt6i_idev will
be NULL.

Since we want to look at the rt6i_idev of the original route in this
case, the easiest fix is to store rt6i_idev in the IPsec dst entry just
as we do for a number of other IPv6 route attributes.  Unfortunately
this means that we need some new code to handle the references to
rt6i_idev.  That's why this patch is bigger than it would otherwise be.

I've also done the same thing for IPv4 since it is conceivable that
once these idev attributes start getting used for accounting, we
probably need to dereference them for IPv4 IPsec entries too.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--4Ckj6UjgE2iN1+kY
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=xfrm-idev

--- k/include/net/xfrm.h  (mode:100644)
+++ l/include/net/xfrm.h  (mode:100644)
@@ -1,6 +1,7 @@
 #ifndef _NET_XFRM_H
 #define _NET_XFRM_H
 
+#include <linux/compiler.h>
 #include <linux/xfrm.h>
 #include <linux/spinlock.h>
 #include <linux/list.h>
@@ -516,6 +517,15 @@ struct xfrm_dst
 	u32 child_mtu_cached;
 };
 
+static inline void xfrm_dst_destroy(struct xfrm_dst *xdst)
+{
+	dst_release(xdst->route);
+	if (likely(xdst->u.dst.xfrm))
+		xfrm_state_put(xdst->u.dst.xfrm);
+}
+
+extern void xfrm_dst_ifdown(struct dst_entry *dst, struct net_device *dev);
+
 /* Decapsulation state, used by the input to store data during
  * decapsulation procedure, to be used later (during the policy
  * check
--- k/net/ipv4/xfrm4_policy.c  (mode:100644)
+++ l/net/ipv4/xfrm4_policy.c  (mode:100644)
@@ -8,7 +8,10 @@
  * 	
  */
 
+#include <asm/bug.h>
+#include <linux/compiler.h>
 #include <linux/config.h>
+#include <linux/inetdevice.h>
 #include <net/xfrm.h>
 #include <net/ip.h>
 
@@ -152,6 +155,8 @@ __xfrm4_bundle_create(struct xfrm_policy
 		x->u.rt.rt_dst = rt0->rt_dst;
 		x->u.rt.rt_gateway = rt->rt_gateway;
 		x->u.rt.rt_spec_dst = rt0->rt_spec_dst;
+		x->u.rt.idev = rt0->idev;
+		in_dev_hold(rt0->idev);
 		header_len -= x->u.dst.xfrm->props.header_len;
 		trailer_len -= x->u.dst.xfrm->props.trailer_len;
 	}
@@ -243,11 +248,48 @@ static void xfrm4_update_pmtu(struct dst
 	path->ops->update_pmtu(path, mtu);
 }
 
+static void xfrm4_dst_destroy(struct dst_entry *dst)
+{
+	struct xfrm_dst *xdst = (struct xfrm_dst *)dst;
+
+	if (likely(xdst->u.rt.idev))
+		in_dev_put(xdst->u.rt.idev);
+	xfrm_dst_destroy(xdst);
+}
+
+static void xfrm4_dst_ifdown(struct dst_entry *dst, struct net_device *dev,
+			     int unregister)
+{
+	struct xfrm_dst *xdst;
+
+	if (!unregister)
+		return;
+
+	xdst = (struct xfrm_dst *)dst;
+	if (xdst->u.rt.idev->dev == dev) {
+		struct in_device *loopback_idev = in_dev_get(&loopback_dev);
+		BUG_ON(!loopback_idev);
+
+		do {
+			in_dev_put(xdst->u.rt.idev);
+			xdst->u.rt.idev = loopback_idev;
+			in_dev_hold(loopback_idev);
+			xdst = (struct xfrm_dst *)xdst->u.dst.child;
+		} while (xdst->u.dst.xfrm);
+
+		__in_dev_put(loopback_idev);
+	}
+
+	xfrm_dst_ifdown(dst, dev);
+}
+
 static struct dst_ops xfrm4_dst_ops = {
 	.family =		AF_INET,
 	.protocol =		__constant_htons(ETH_P_IP),
 	.gc =			xfrm4_garbage_collect,
 	.update_pmtu =		xfrm4_update_pmtu,
+	.destroy =		xfrm4_dst_destroy,
+	.ifdown =		xfrm4_dst_ifdown,
 	.gc_thresh =		1024,
 	.entry_size =		sizeof(struct xfrm_dst),
 };
--- k/net/ipv6/xfrm6_policy.c  (mode:100644)
+++ l/net/ipv6/xfrm6_policy.c  (mode:100644)
@@ -11,7 +11,11 @@
  * 
  */
 
+#include <asm/bug.h>
+#include <linux/compiler.h>
 #include <linux/config.h>
+#include <linux/netdevice.h>
+#include <net/addrconf.h>
 #include <net/xfrm.h>
 #include <net/ip.h>
 #include <net/ipv6.h>
@@ -166,6 +170,8 @@ __xfrm6_bundle_create(struct xfrm_policy
 		memcpy(&x->u.rt6.rt6i_gateway, &rt0->rt6i_gateway, sizeof(x->u.rt6.rt6i_gateway)); 
 		x->u.rt6.rt6i_dst      = rt0->rt6i_dst;
 		x->u.rt6.rt6i_src      = rt0->rt6i_src;	
+		x->u.rt6.rt6i_idev     = rt0->rt6i_idev;
+		in6_dev_hold(rt0->rt6i_idev);
 		header_len -= x->u.dst.xfrm->props.header_len;
 		trailer_len -= x->u.dst.xfrm->props.trailer_len;
 	}
@@ -251,11 +257,48 @@ static void xfrm6_update_pmtu(struct dst
 	path->ops->update_pmtu(path, mtu);
 }
 
+static void xfrm6_dst_destroy(struct dst_entry *dst)
+{
+	struct xfrm_dst *xdst = (struct xfrm_dst *)dst;
+
+	if (likely(xdst->u.rt6.rt6i_idev))
+		in6_dev_put(xdst->u.rt6.rt6i_idev);
+	xfrm_dst_destroy(xdst);
+}
+
+static void xfrm6_dst_ifdown(struct dst_entry *dst, struct net_device *dev,
+			     int unregister)
+{
+	struct xfrm_dst *xdst;
+
+	if (!unregister)
+		return;
+
+	xdst = (struct xfrm_dst *)dst;
+	if (xdst->u.rt6.rt6i_idev->dev == dev) {
+		struct inet6_dev *loopback_idev = in6_dev_get(&loopback_dev);
+		BUG_ON(!loopback_idev);
+
+		do {
+			in6_dev_put(xdst->u.rt6.rt6i_idev);
+			xdst->u.rt6.rt6i_idev = loopback_idev;
+			in6_dev_hold(loopback_idev);
+			xdst = (struct xfrm_dst *)xdst->u.dst.child;
+		} while (xdst->u.dst.xfrm);
+
+		__in6_dev_put(loopback_idev);
+	}
+
+	xfrm_dst_ifdown(dst, dev);
+}
+
 static struct dst_ops xfrm6_dst_ops = {
 	.family =		AF_INET6,
 	.protocol =		__constant_htons(ETH_P_IPV6),
 	.gc =			xfrm6_garbage_collect,
 	.update_pmtu =		xfrm6_update_pmtu,
+	.destroy =		xfrm6_dst_destroy,
+	.ifdown =		xfrm6_dst_ifdown,
 	.gc_thresh =		1024,
 	.entry_size =		sizeof(struct xfrm_dst),
 };
--- k/net/xfrm/xfrm_policy.c  (mode:100644)
+++ l/net/xfrm/xfrm_policy.c  (mode:100644)
@@ -1028,30 +1028,15 @@ static int stale_bundle(struct dst_entry
 	return !xfrm_bundle_ok((struct xfrm_dst *)dst, NULL, AF_UNSPEC);
 }
 
-static void xfrm_dst_destroy(struct dst_entry *dst)
+void xfrm_dst_ifdown(struct dst_entry *dst, struct net_device *dev)
 {
-	struct xfrm_dst *xdst = (struct xfrm_dst *)dst;
-
-	dst_release(xdst->route);
-
-	if (!dst->xfrm)
-		return;
-	xfrm_state_put(dst->xfrm);
-	dst->xfrm = NULL;
-}
-
-static void xfrm_dst_ifdown(struct dst_entry *dst, struct net_device *dev,
-			    int unregister)
-{
-	if (!unregister)
-		return;
-
 	while ((dst = dst->child) && dst->xfrm && dst->dev == dev) {
 		dst->dev = &loopback_dev;
 		dev_hold(&loopback_dev);
 		dev_put(dev);
 	}
 }
+EXPORT_SYMBOL(xfrm_dst_ifdown);
 
 static void xfrm_link_failure(struct sk_buff *skb)
 {
@@ -1262,10 +1247,6 @@ int xfrm_policy_register_afinfo(struct x
 			dst_ops->kmem_cachep = xfrm_dst_cache;
 		if (likely(dst_ops->check == NULL))
 			dst_ops->check = xfrm_dst_check;
-		if (likely(dst_ops->destroy == NULL))
-			dst_ops->destroy = xfrm_dst_destroy;
-		if (likely(dst_ops->ifdown == NULL))
-			dst_ops->ifdown = xfrm_dst_ifdown;
 		if (likely(dst_ops->negative_advice == NULL))
 			dst_ops->negative_advice = xfrm_negative_advice;
 		if (likely(dst_ops->link_failure == NULL))
@@ -1297,8 +1278,6 @@ int xfrm_policy_unregister_afinfo(struct
 			xfrm_policy_afinfo[afinfo->family] = NULL;
 			dst_ops->kmem_cachep = NULL;
 			dst_ops->check = NULL;
-			dst_ops->destroy = NULL;
-			dst_ops->ifdown = NULL;
 			dst_ops->negative_advice = NULL;
 			dst_ops->link_failure = NULL;
 			dst_ops->get_mss = NULL;

--4Ckj6UjgE2iN1+kY--
