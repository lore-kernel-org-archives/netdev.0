From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [IPSEC] Merge xfrm4_bundle_ok/xfrm6_bundle_ok/stale_bundle
Date: Wed, 16 Feb 2005 09:54:42 +1100
Message-ID: <20050215225442.GA28142@gondor.apana.org.au>
References: <20050129123803.GA17390@gondor.apana.org.au> <20050215141743.1010f2e6.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="bp/iNruPH9dso1Pn"
Cc: netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050215141743.1010f2e6.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--bp/iNruPH9dso1Pn
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Feb 15, 2005 at 02:17:43PM -0800, David S. Miller wrote:
> On Sat, 29 Jan 2005 23:38:03 +1100
> Herbert Xu <herbert@gondor.apana.org.au> wrote:
> 
> > This patch merges __xfrm4_bundle_ok/__xfrm6_bundle_ok/stale_bundle
> > so that when I add MTU verification code I don't have to put it in
> > three places.
> > 
> > It also moves the tests on dst->dev and dst->obsolete outside the
> > loop since the former is identical throughout the bundle and the
> > latter can only be positive on the final element which also happens
> > to be dst->path.
> > 
> > Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> Applied to my 2.6.12-pending tree.  Thanks a lot.

Sorry Dave, but that patch has a critical error in stale_bundle
where I forgot to add an exclamation mark.

I've resent the corrected patch in the thread containing the other
MTU patches.  Here it is again.


This patch merges xfrm4_bundle_ok/xfrm6_bundle_ok/stale_bundle
so that later additions for MTU calculation only need to be done once.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--bp/iNruPH9dso1Pn
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=xfrm-1

diff -Nru a/include/net/xfrm.h b/include/net/xfrm.h
--- a/include/net/xfrm.h	2005-02-14 14:13:05 +11:00
+++ b/include/net/xfrm.h	2005-02-14 14:13:05 +11:00
@@ -857,6 +857,7 @@
 extern void xfrm_policy_flush(void);
 extern int xfrm_sk_policy_insert(struct sock *sk, int dir, struct xfrm_policy *pol);
 extern int xfrm_flush_bundles(void);
+extern int xfrm_bundle_ok(struct xfrm_dst *xdst, struct flowi *fl, int family);
 
 extern wait_queue_head_t km_waitq;
 extern int km_new_mapping(struct xfrm_state *x, xfrm_address_t *ipaddr, u16 sport);
diff -Nru a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
--- a/net/ipv4/xfrm4_policy.c	2005-02-14 14:13:05 +11:00
+++ b/net/ipv4/xfrm4_policy.c	2005-02-14 14:13:05 +11:00
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
diff -Nru a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
--- a/net/ipv6/xfrm6_policy.c	2005-02-14 14:13:05 +11:00
+++ b/net/ipv6/xfrm6_policy.c	2005-02-14 14:13:05 +11:00
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
diff -Nru a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
--- a/net/xfrm/xfrm_policy.c	2005-02-14 14:13:05 +11:00
+++ b/net/xfrm/xfrm_policy.c	2005-02-14 14:13:05 +11:00
@@ -1021,18 +1021,7 @@
 
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
+	return !xfrm_bundle_ok((struct xfrm_dst *)dst, NULL, AF_UNSPEC);
 }
 
 static void xfrm_dst_destroy(struct dst_entry *dst)
@@ -1108,6 +1097,31 @@
 	return 0;
 }
 
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
+ 
 /* Well... that's _TASK_. We need to scan through transformation
  * list and figure out what mss tcp should generate in order to
  * final datagram fit to mtu. Mama mia... :-)

--bp/iNruPH9dso1Pn--
