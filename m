From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [4/4] [IPSEC] Store MTU at each xfrm_dst
Date: Tue, 15 Feb 2005 09:16:07 +1100
Message-ID: <20050214221607.GC18465@gondor.apana.org.au>
References: <20050214221006.GA18415@gondor.apana.org.au> <20050214221200.GA18465@gondor.apana.org.au> <20050214221433.GB18465@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="/e2eDi0V/xtL+Mc8"
To: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@redhat.com>,
        YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>, netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20050214221433.GB18465@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--/e2eDi0V/xtL+Mc8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Finally this is the patch that sets the MTU values of each xfrm_dst
and keeps it up-to-date.
  
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

To recap, at this point we've obtained accurate MTU values at each
xfrm_dst.  The next step would be to start using it as
dst_pmtu(xfrm_dst).

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--/e2eDi0V/xtL+Mc8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=xfrm-4

===== include/net/xfrm.h 1.77 vs edited =====
--- 1.77/include/net/xfrm.h	2005-02-14 14:51:26 +11:00
+++ edited/include/net/xfrm.h	2005-02-14 14:23:51 +11:00
@@ -512,6 +512,8 @@
 		struct rt6_info		rt6;
 	} u;
 	struct dst_entry *route;
+	u32 route_mtu_cached;
+	u32 child_mtu_cached;
 };
 
 /* Decapsulation state, used by the input to store data during
@@ -860,6 +862,7 @@
 extern int xfrm_sk_policy_insert(struct sock *sk, int dir, struct xfrm_policy *pol);
 extern int xfrm_flush_bundles(void);
 extern int xfrm_bundle_ok(struct xfrm_dst *xdst, struct flowi *fl, int family);
+extern void xfrm_init_pmtu(struct dst_entry *dst);
 
 extern wait_queue_head_t km_waitq;
 extern int km_new_mapping(struct xfrm_state *x, xfrm_address_t *ipaddr, u16 sport);
===== net/ipv4/xfrm4_policy.c 1.15 vs edited =====
--- 1.15/net/ipv4/xfrm4_policy.c	2005-02-14 14:51:26 +11:00
+++ edited/net/ipv4/xfrm4_policy.c	2005-02-14 14:53:06 +11:00
@@ -153,6 +153,8 @@
 		header_len -= x->u.dst.xfrm->props.header_len;
 		trailer_len -= x->u.dst.xfrm->props.trailer_len;
 	}
+
+	xfrm_init_pmtu(dst);
 	return 0;
 
 error:
===== net/ipv6/xfrm6_policy.c 1.26 vs edited =====
--- 1.26/net/ipv6/xfrm6_policy.c	2005-02-14 14:51:26 +11:00
+++ edited/net/ipv6/xfrm6_policy.c	2005-02-14 14:53:25 +11:00
@@ -167,6 +167,8 @@
 		header_len -= x->u.dst.xfrm->props.header_len;
 		trailer_len -= x->u.dst.xfrm->props.trailer_len;
 	}
+
+	xfrm_init_pmtu(dst);
 	return 0;
 
 error:
===== net/xfrm/xfrm_policy.c 1.66 vs edited =====
--- 1.66/net/xfrm/xfrm_policy.c	2005-02-14 14:51:26 +11:00
+++ edited/net/xfrm/xfrm_policy.c	2005-02-14 21:29:56 +11:00
@@ -1102,25 +1102,86 @@
 	return 0;
 }
 
+void xfrm_init_pmtu(struct dst_entry *dst)
+{
+	do {
+		struct xfrm_dst *xdst = (struct xfrm_dst *)dst;
+		u32 pmtu, route_mtu_cached;
+
+		pmtu = dst_pmtu(dst->child);
+		xdst->child_mtu_cached = pmtu;
+
+		pmtu = xfrm_state_mtu(dst->xfrm, pmtu);
+
+		route_mtu_cached = dst_pmtu(xdst->route);
+		xdst->route_mtu_cached = route_mtu_cached;
+
+		if (pmtu > route_mtu_cached)
+			pmtu = route_mtu_cached;
+
+		dst->metrics[RTAX_MTU-1] = pmtu;
+	} while ((dst = dst->next));
+}
+
+EXPORT_SYMBOL(xfrm_init_pmtu);
+
 /* Check that the bundle accepts the flow and its components are
  * still valid.
  */
 
-int xfrm_bundle_ok(struct xfrm_dst *xdst, struct flowi *fl, int family)
+int xfrm_bundle_ok(struct xfrm_dst *first, struct flowi *fl, int family)
 {
-	struct dst_entry *dst = &xdst->u.dst;
+	struct dst_entry *dst = &first->u.dst;
+	struct xfrm_dst *last;
+	u32 mtu;
 
 	if (dst->path->obsolete > 0 ||
 	    (dst->dev && !netif_running(dst->dev)))
 		return 0;
 
+	last = NULL;
+
 	do {
+		struct xfrm_dst *xdst = (struct xfrm_dst *)dst;
+
 		if (fl && !xfrm_selector_match(&dst->xfrm->sel, fl, family))
 			return 0;
 		if (dst->xfrm->km.state != XFRM_STATE_VALID)
 			return 0;
+
+		mtu = dst_pmtu(dst->child);
+		if (xdst->child_mtu_cached != mtu) {
+			last = xdst;
+			xdst->child_mtu_cached = mtu;
+		}
+
+		mtu = dst_pmtu(xdst->route);
+		if (xdst->child_mtu_cached != mtu) {
+			last = xdst;
+			xdst->route_mtu_cached = mtu;
+		}
+
 		dst = dst->child;
 	} while (dst->xfrm);
+
+	if (likely(!last))
+		return 1;
+
+	mtu = last->child_mtu_cached;
+	for (;;) {
+		dst = &last->u.dst;
+
+		mtu = xfrm_state_mtu(dst->xfrm, mtu);
+		if (mtu > last->route_mtu_cached)
+			mtu = last->route_mtu_cached;
+		dst->metrics[RTAX_MTU-1] = mtu;
+
+		if (last == first)
+			break;
+
+		last = last->u.next;
+		last->child_mtu_cached = mtu;
+	}
 
 	return 1;
 }

--/e2eDi0V/xtL+Mc8--
