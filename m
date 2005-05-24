From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: [XFRM] Call dst_check() with appropriate cookie
Date: Tue, 24 May 2005 12:49:19 +0900 (JST)
Message-ID: <20050524.124919.00464304.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Kazunori Miyazawa <kazunori@miyazawa.org>

[XFRM] Call dst_check() with appropriate cookie.

This fixes infinite loop issue with IPv6 tunnel mode.

Signed-off-by: Kazunori Miyazawa <kazunori@miyazawa.org>
Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

diff -ruN linux-2.6.12-rc4-git7/include/net/xfrm.h linux-2.6.12-rc4-git7-ipv6ipsec/include/net/xfrm.h
--- linux-2.6.12-rc4-git7/include/net/xfrm.h	2005-05-24 00:15:26.000000000 +0900
+++ linux-2.6.12-rc4-git7-ipv6ipsec/include/net/xfrm.h	2005-05-24 00:19:24.000000000 +0900
@@ -515,6 +515,8 @@
 	struct dst_entry *route;
 	u32 route_mtu_cached;
 	u32 child_mtu_cached;
+	u32 route_cookie;
+	u32 path_cookie;
 };

 static inline void xfrm_dst_destroy(struct xfrm_dst *xdst)
diff -ruN linux-2.6.12-rc4-git7/net/ipv4/xfrm4_policy.c linux-2.6.12-rc4-git7-ipv6ipsec/net/ipv4/xfrm4_policy.c
--- linux-2.6.12-rc4-git7/net/ipv4/xfrm4_policy.c	2005-05-24 00:15:27.000000000 +0900
+++ linux-2.6.12-rc4-git7-ipv6ipsec/net/ipv4/xfrm4_policy.c	2005-05-24 00:20:29.000000000 +0900
@@ -95,6 +95,7 @@

 		xdst = (struct xfrm_dst *)dst1;
 		xdst->route = &rt->u.dst;
+		xdst->route_cookie = 0;

 		dst1->next = dst_prev;
 		dst_prev = dst1;
@@ -119,6 +120,7 @@

 	dst_prev->child = &rt->u.dst;
 	dst->path = &rt->u.dst;
+	((struct xfrm_dst*)dst)->path_cookie = 0;

 	*dst_p = dst;
 	dst = dst_prev;
diff -ruN linux-2.6.12-rc4-git7/net/ipv6/xfrm6_policy.c linux-2.6.12-rc4-git7-ipv6ipsec/net/ipv6/xfrm6_policy.c
--- linux-2.6.12-rc4-git7/net/ipv6/xfrm6_policy.c	2005-05-24 00:15:27.000000000 +0900
+++ linux-2.6.12-rc4-git7-ipv6ipsec/net/ipv6/xfrm6_policy.c	2005-05-24 00:22:15.000000000 +0900
@@ -113,6 +113,7 @@

 		xdst = (struct xfrm_dst *)dst1;
 		xdst->route = &rt->u.dst;
+		xdst->route_cookie = rt->rt6i_node->fn_sernum;

 		dst1->next = dst_prev;
 		dst_prev = dst1;
@@ -137,6 +138,7 @@

 	dst_prev->child = &rt->u.dst;
 	dst->path = &rt->u.dst;
+	((struct xfrm_dst*)dst)->path_cookie = rt->rt6i_node->fn_sernum;

 	*dst_p = dst;
 	dst = dst_prev;
diff -ruN linux-2.6.12-rc4-git7/net/xfrm/xfrm_policy.c linux-2.6.12-rc4-git7-ipv6ipsec/net/xfrm/xfrm_policy.c
--- linux-2.6.12-rc4-git7/net/xfrm/xfrm_policy.c	2005-05-24 00:15:28.000000000 +0900
+++ linux-2.6.12-rc4-git7-ipv6ipsec/net/xfrm/xfrm_policy.c	2005-05-24 00:22:57.000000000 +0900
@@ -1136,7 +1136,7 @@
 	struct xfrm_dst *last;
 	u32 mtu;

-	if (!dst_check(dst->path, 0) ||
+	if (!dst_check(dst->path, ((struct xfrm_dst*)dst)->path_cookie) ||
 	    (dst->dev && !netif_running(dst->dev)))
 		return 0;

@@ -1156,7 +1156,7 @@
 			xdst->child_mtu_cached = mtu;
 		}

-		if (!dst_check(xdst->route, 0))
+		if (!dst_check(xdst->route, xdst->route_cookie))
 			return 0;
 		mtu = dst_mtu(xdst->route);
 		if (xdst->route_mtu_cached != mtu) {

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
