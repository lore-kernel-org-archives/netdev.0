From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [3/4] [IPSEC] Add route element to xfrm_dst
Date: Tue, 15 Feb 2005 09:14:33 +1100
Message-ID: <20050214221433.GB18465@gondor.apana.org.au>
References: <20050214221006.GA18415@gondor.apana.org.au> <20050214221200.GA18465@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="neYutvxvOLaeuPCA"
To: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@redhat.com>,
        YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>, netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20050214221200.GA18465@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--neYutvxvOLaeuPCA
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

This patch adds a pointer to the route corresponding to the specific
flow over the SA of an xfrm_dst that's being used.

It also sets the next pointer of each xfrm_dst to the one above it.
This allows to traverse the list upwards from the bottom.
 
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--neYutvxvOLaeuPCA
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=xfrm-3

===== include/net/xfrm.h 1.76 vs edited =====
--- 1.76/include/net/xfrm.h	2005-02-14 14:14:25 +11:00
+++ edited/include/net/xfrm.h	2005-02-14 14:24:04 +11:00
@@ -511,6 +511,7 @@
 		struct rtable		rt;
 		struct rt6_info		rt6;
 	} u;
+	struct dst_entry *route;
 };
 
 /* Decapsulation state, used by the input to store data during
===== net/ipv4/xfrm4_policy.c 1.14 vs edited =====
--- 1.14/net/ipv4/xfrm4_policy.c	2005-02-14 14:02:13 +11:00
+++ edited/net/ipv4/xfrm4_policy.c	2005-02-14 14:29:35 +11:00
@@ -55,18 +55,29 @@
 	struct rtable *rt = rt0;
 	u32 remote = fl->fl4_dst;
 	u32 local  = fl->fl4_src;
+	struct flowi fl_tunnel = {
+		.nl_u = {
+			.ip4_u = {
+				.saddr = local,
+				.daddr = remote
+			}
+		}
+	};
 	int i;
 	int err;
 	int header_len = 0;
 	int trailer_len = 0;
 
 	dst = dst_prev = NULL;
+	dst_hold(&rt->u.dst);
 
 	for (i = 0; i < nx; i++) {
 		struct dst_entry *dst1 = dst_alloc(&xfrm4_dst_ops);
+		struct xfrm_dst *xdst;
 
 		if (unlikely(dst1 == NULL)) {
 			err = -ENOBUFS;
+			dst_release(&rt->u.dst);
 			goto error;
 		}
 
@@ -77,6 +88,11 @@
 			dst1->flags |= DST_NOHASH;
 			dst_clone(dst1);
 		}
+
+		xdst = (struct xfrm_dst *)dst1;
+		xdst->route = &rt->u.dst;
+
+		dst1->next = dst_prev;
 		dst_prev = dst1;
 		if (xfrm[i]->props.mode) {
 			remote = xfrm[i]->id.daddr.a4;
@@ -84,23 +100,27 @@
 		}
 		header_len += xfrm[i]->props.header_len;
 		trailer_len += xfrm[i]->props.trailer_len;
-	}
 
-	if (remote != fl->fl4_dst) {
-		struct flowi fl_tunnel = { .nl_u = { .ip4_u =
-						     { .daddr = remote,
-						       .saddr = local }
-					           }
-				         };
-		err = xfrm_dst_lookup((struct xfrm_dst**)&rt, &fl_tunnel, AF_INET);
-		if (err)
-			goto error;
-	} else {
-		dst_hold(&rt->u.dst);
+		if (remote != fl_tunnel.fl4_dst) {
+			fl_tunnel.fl4_src = local;
+			fl_tunnel.fl4_dst = remote;
+			err = xfrm_dst_lookup((struct xfrm_dst **)&rt,
+					      &fl_tunnel, AF_INET);
+			if (err)
+				goto error;
+		} else
+			dst_hold(&rt->u.dst);
 	}
+
 	dst_prev->child = &rt->u.dst;
+	dst->path = &rt->u.dst;
+
+	*dst_p = dst;
+	dst = dst_prev;
+
+	dst_prev = *dst_p;
 	i = 0;
-	for (dst_prev = dst; dst_prev != &rt->u.dst; dst_prev = dst_prev->child) {
+	for (; dst_prev != &rt->u.dst; dst_prev = dst_prev->child) {
 		struct xfrm_dst *x = (struct xfrm_dst*)dst_prev;
 		x->u.rt.fl = *fl;
 
@@ -114,7 +134,6 @@
 		dst_prev->header_len	= header_len;
 		dst_prev->trailer_len	= trailer_len;
 		memcpy(&dst_prev->metrics, &rt->u.dst.metrics, sizeof(dst_prev->metrics));
-		dst_prev->path		= &rt->u.dst;
 
 		/* Copy neighbout for reachability confirmation */
 		dst_prev->neighbour	= neigh_clone(rt->u.dst.neighbour);
@@ -134,7 +153,6 @@
 		header_len -= x->u.dst.xfrm->props.header_len;
 		trailer_len -= x->u.dst.xfrm->props.trailer_len;
 	}
-	*dst_p = dst;
 	return 0;
 
 error:
===== net/ipv6/xfrm6_policy.c 1.25 vs edited =====
--- 1.25/net/ipv6/xfrm6_policy.c	2005-02-14 14:02:13 +11:00
+++ edited/net/ipv6/xfrm6_policy.c	2005-02-14 14:50:04 +11:00
@@ -72,18 +72,29 @@
 	struct rt6_info *rt  = rt0;
 	struct in6_addr *remote = &fl->fl6_dst;
 	struct in6_addr *local  = &fl->fl6_src;
+	struct flowi fl_tunnel = {
+		.nl_u = {
+			.ip6_u = {
+				.saddr = *local,
+				.daddr = *remote
+			}
+		}
+	};
 	int i;
 	int err = 0;
 	int header_len = 0;
 	int trailer_len = 0;
 
 	dst = dst_prev = NULL;
+	dst_hold(&rt->u.dst);
 
 	for (i = 0; i < nx; i++) {
 		struct dst_entry *dst1 = dst_alloc(&xfrm6_dst_ops);
+		struct xfrm_dst *xdst;
 
 		if (unlikely(dst1 == NULL)) {
 			err = -ENOBUFS;
+			dst_release(&rt->u.dst);
 			goto error;
 		}
 
@@ -94,6 +105,11 @@
 			dst1->flags |= DST_NOHASH;
 			dst_clone(dst1);
 		}
+
+		xdst = (struct xfrm_dst *)dst1;
+		xdst->route = &rt->u.dst;
+
+		dst1->next = dst_prev;
 		dst_prev = dst1;
 		if (xfrm[i]->props.mode) {
 			remote = (struct in6_addr*)&xfrm[i]->id.daddr;
@@ -101,25 +117,27 @@
 		}
 		header_len += xfrm[i]->props.header_len;
 		trailer_len += xfrm[i]->props.trailer_len;
-	}
-
-	if (!ipv6_addr_equal(remote, &fl->fl6_dst)) {
-		struct flowi fl_tunnel;
 
-		memset(&fl_tunnel, 0, sizeof(fl_tunnel));
-		ipv6_addr_copy(&fl_tunnel.fl6_dst, remote);
-		ipv6_addr_copy(&fl_tunnel.fl6_src, local);
-
-		err = xfrm_dst_lookup((struct xfrm_dst **) &rt,
-				      &fl_tunnel, AF_INET6);
-		if (err)
-			goto error;
-	} else {
-		dst_hold(&rt->u.dst);
+		if (!ipv6_addr_equal(remote, &fl_tunnel.fl6_dst)) {
+			ipv6_addr_copy(&fl_tunnel.fl6_dst, remote);
+			ipv6_addr_copy(&fl_tunnel.fl6_src, local);
+			err = xfrm_dst_lookup((struct xfrm_dst **) &rt,
+					      &fl_tunnel, AF_INET6);
+			if (err)
+				goto error;
+		} else
+			dst_hold(&rt->u.dst);
 	}
+
 	dst_prev->child = &rt->u.dst;
+	dst->path = &rt->u.dst;
+
+	*dst_p = dst;
+	dst = dst_prev;
+
+	dst_prev = *dst_p;
 	i = 0;
-	for (dst_prev = dst; dst_prev != &rt->u.dst; dst_prev = dst_prev->child) {
+	for (; dst_prev != &rt->u.dst; dst_prev = dst_prev->child) {
 		struct xfrm_dst *x = (struct xfrm_dst*)dst_prev;
 
 		dst_prev->xfrm = xfrm[i++];
@@ -132,7 +150,6 @@
 		dst_prev->header_len	= header_len;
 		dst_prev->trailer_len	= trailer_len;
 		memcpy(&dst_prev->metrics, &rt->u.dst.metrics, sizeof(dst_prev->metrics));
-		dst_prev->path		= &rt->u.dst;
 
 		/* Copy neighbour for reachability confirmation */
 		dst_prev->neighbour	= neigh_clone(rt->u.dst.neighbour);
@@ -150,7 +167,6 @@
 		header_len -= x->u.dst.xfrm->props.header_len;
 		trailer_len -= x->u.dst.xfrm->props.trailer_len;
 	}
-	*dst_p = dst;
 	return 0;
 
 error:
===== net/xfrm/xfrm_policy.c 1.65 vs edited =====
--- 1.65/net/xfrm/xfrm_policy.c	2005-02-14 14:02:13 +11:00
+++ edited/net/xfrm/xfrm_policy.c	2005-02-14 14:39:52 +11:00
@@ -1026,6 +1026,11 @@
 
 static void xfrm_dst_destroy(struct dst_entry *dst)
 {
+	struct xfrm_dst *xdst = (struct xfrm_dst *)dst;
+
+	if (xdst->route)
+		dst_release(xdst->route);
+
 	if (!dst->xfrm)
 		return;
 	xfrm_state_put(dst->xfrm);

--neYutvxvOLaeuPCA--
