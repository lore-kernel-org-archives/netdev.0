From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [IPSEC] Merge xfrm4_bundle_ok/xfrm6_bundle_ok/stale_bundle
Date: Sat, 29 Jan 2005 23:38:03 +1100
Message-ID: <20050129123803.GA17390@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="lrZ03NoBR/3+SXJZ"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--lrZ03NoBR/3+SXJZ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

This patch merges __xfrm4_bundle_ok/__xfrm6_bundle_ok/stale_bundle
so that when I add MTU verification code I don't have to put it in
three places.

It also moves the tests on dst->dev and dst->obsolete outside the
loop since the former is identical throughout the bundle and the
latter can only be positive on the final element which also happens
to be dst->path.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--lrZ03NoBR/3+SXJZ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== include/net/xfrm.h 1.74 vs edited =====
--- 1.74/include/net/xfrm.h	2005-01-26 16:53:19 +11:00
+++ edited/include/net/xfrm.h	2005-01-29 23:22:09 +11:00
@@ -857,6 +857,7 @@
 extern void xfrm_policy_flush(void);
 extern int xfrm_sk_policy_insert(struct sock *sk, int dir, struct xfrm_policy *pol);
 extern int xfrm_flush_bundles(void);
+extern int xfrm_bundle_ok(struct xfrm_dst *xdst, struct flowi *fl, int family);
 
 extern wait_queue_head_t km_waitq;
 extern int km_new_mapping(struct xfrm_state *x, xfrm_address_t *ipaddr, u16 sport);
===== net/ipv4/xfrm4_policy.c 1.13 vs edited =====
--- 1.13/net/ipv4/xfrm4_policy.c	2004-12-28 14:49:58 +11:00
+++ edited/net/ipv4/xfrm4_policy.c	2005-01-29 23:11:46 +11:00
@@ -22,26 +22,6 @@
 	return __ip_route_output_key((struct rtable**)dst, fl);
 }
 
-/* Check that the bundle accepts the flow and its components are
- * still valid.
- */
-
-static int __xfrm4_bundle_ok(struct xfrm_dst *xdst, struct flowi *fl)
-{
-	do {
-		if (xdst->u.dst.ops != &xfrm4_dst_ops)
-			return 1;
-
-		if (!xfrm_selector_match(&xdst->u.dst.xfrm->sel, fl, AF_INET))
-			return 0;
-		if (xdst->u.dst.xfrm->km.state != XFRM_STATE_VALID ||
-		    xdst->u.dst.path->obsolete > 0)
-			return 0;
-		xdst = (struct xfrm_dst*)xdst->u.dst.child;
-	} while (xdst);
-	return 0;
-}
-
 static struct dst_entry *
 __xfrm4_find_bundle(struct flowi *fl, struct xfrm_policy *policy)
 {
@@ -53,7 +33,7 @@
 		if (xdst->u.rt.fl.oif == fl->oif &&	/*XXX*/
 		    xdst->u.rt.fl.fl4_dst == fl->fl4_dst &&
 	    	    xdst->u.rt.fl.fl4_src == fl->fl4_src &&
-		    __xfrm4_bundle_ok(xdst, fl)) {
+		    xfrm_bundle_ok(xdst, fl, AF_INET)) {
 			dst_clone(dst);
 			break;
 		}
===== net/ipv6/xfrm6_policy.c 1.24 vs edited =====
--- 1.24/net/ipv6/xfrm6_policy.c	2004-11-10 17:57:03 +11:00
+++ edited/net/ipv6/xfrm6_policy.c	2005-01-29 23:23:24 +11:00
@@ -31,26 +31,6 @@
 	return err;
 }
 
-/* Check that the bundle accepts the flow and its components are
- * still valid.
- */
-
-static int __xfrm6_bundle_ok(struct xfrm_dst *xdst, struct flowi *fl)
-{
-	do {
-		if (xdst->u.dst.ops != &xfrm6_dst_ops)
-			return 1;
-
-		if (!xfrm_selector_match(&xdst->u.dst.xfrm->sel, fl, AF_INET6))
-			return 0;
-		if (xdst->u.dst.xfrm->km.state != XFRM_STATE_VALID ||
-		    xdst->u.dst.path->obsolete > 0)
-			return 0;
-		xdst = (struct xfrm_dst*)xdst->u.dst.child;
-	} while (xdst);
-	return 0;
-}
-
 static struct dst_entry *
 __xfrm6_find_bundle(struct flowi *fl, struct xfrm_policy *policy)
 {
@@ -70,7 +50,7 @@
 				 xdst->u.rt6.rt6i_src.plen);
 		if (ipv6_addr_equal(&xdst->u.rt6.rt6i_dst.addr, &fl_dst_prefix) &&
 		    ipv6_addr_equal(&xdst->u.rt6.rt6i_src.addr, &fl_src_prefix) &&
-		    __xfrm6_bundle_ok(xdst, fl)) {
+		    xfrm_bundle_ok(xdst, fl, AF_INET6)) {
 			dst_clone(dst);
 			break;
 		}
===== net/xfrm/xfrm_policy.c 1.63 vs edited =====
--- 1.63/net/xfrm/xfrm_policy.c	2005-01-19 07:08:19 +11:00
+++ edited/net/xfrm/xfrm_policy.c	2005-01-29 23:27:39 +11:00
@@ -21,6 +21,7 @@
 #include <linux/workqueue.h>
 #include <linux/notifier.h>
 #include <linux/netdevice.h>
+#include <linux/module.h>
 #include <net/xfrm.h>
 #include <net/ip.h>
 
@@ -1005,18 +1006,7 @@
 
 static int stale_bundle(struct dst_entry *dst)
 {
-	struct dst_entry *child = dst;
-
-	while (child) {
-		if (child->obsolete > 0 ||
-		    (child->dev && !netif_running(child->dev)) ||
-		    (child->xfrm && child->xfrm->km.state != XFRM_STATE_VALID)) {
-			return 1;
-		}
-		child = child->child;
-	}
-
-	return 0;
+	return xfrm_bundle_ok((struct xfrm_dst *)dst, NULL, AF_UNSPEC);
 }
 
 static void xfrm_dst_destroy(struct dst_entry *dst)
@@ -1091,6 +1081,31 @@
 	xfrm_prune_bundles(stale_bundle);
 	return 0;
 }
+
+/* Check that the bundle accepts the flow and its components are
+ * still valid.
+ */
+
+int xfrm_bundle_ok(struct xfrm_dst *xdst, struct flowi *fl, int family)
+{
+	struct dst_entry *dst = &xdst->u.dst;
+
+	if (dst->path->obsolete > 0 ||
+	    (dst->dev && !netif_running(dst->dev)))
+		return 0;
+
+	do {
+		if (fl && !xfrm_selector_match(&dst->xfrm->sel, fl, family))
+			return 0;
+		if (dst->xfrm->km.state != XFRM_STATE_VALID)
+			return 0;
+		dst = dst->child;
+	} while (dst->xfrm);
+
+	return 1;
+}
+
+EXPORT_SYMBOL(xfrm_bundle_ok);
 
 /* Well... that's _TASK_. We need to scan through transformation
  * list and figure out what mss tcp should generate in order to

--lrZ03NoBR/3+SXJZ--
