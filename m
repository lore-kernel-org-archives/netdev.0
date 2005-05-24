From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [XFRM] Call dst_check() with appropriate cookie
Date: Tue, 24 May 2005 17:49:31 +0900 (JST)
Message-ID: <20050524.174931.46801018.yoshfuji@linux-ipv6.org>
References: <20050524.124919.00464304.yoshfuji@linux-ipv6.org>
	<20050524082021.GA31446@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org,
        kazunori@miyazawa.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
In-Reply-To: <20050524082021.GA31446@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20050524082021.GA31446@gondor.apana.org.au> (at Tue, 24 May 2005 18:20:21 +1000), Herbert Xu <herbert@gondor.apana.org.au> says:

> Also, can rt6i_node be NULL?

Good point.  Here's updated patch.

-----------------
From: Kazunori Miyazawa <kazunori@miyazawa.org>

[XFRM] Call dst_check() with appropriate cookie

This fixes infinite loop issue with IPv6 tunnel mode.

Signed-off-by: Kazunori Miyazawa <kazunori@miyazawa.org>
Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

Index: include/net/xfrm.h
===================================================================
--- 5b713315560487f8c288820b17061fe27016c2cc/include/net/xfrm.h  (mode:100644)
+++ uncommitted/include/net/xfrm.h  (mode:100644)
@@ -515,6 +515,8 @@
 	struct dst_entry *route;
 	u32 route_mtu_cached;
 	u32 child_mtu_cached;
+	u32 route_cookie;
+	u32 path_cookie;
 };
 
 static inline void xfrm_dst_destroy(struct xfrm_dst *xdst)
Index: net/ipv6/xfrm6_policy.c
===================================================================
--- 5b713315560487f8c288820b17061fe27016c2cc/net/ipv6/xfrm6_policy.c  (mode:100644)
+++ uncommitted/net/ipv6/xfrm6_policy.c  (mode:100644)
@@ -113,6 +113,8 @@
 
 		xdst = (struct xfrm_dst *)dst1;
 		xdst->route = &rt->u.dst;
+		if (rt->rt6i_node)
+			xdst->route_cookie = rt->rt6i_node->fn_sernum;
 
 		dst1->next = dst_prev;
 		dst_prev = dst1;
@@ -137,6 +139,8 @@
 
 	dst_prev->child = &rt->u.dst;
 	dst->path = &rt->u.dst;
+	if (rt->rt6i_node)
+		((struct xfrm_dst *)dst)->path_cookie = rt->rt6i_node->fn_sernum;
 
 	*dst_p = dst;
 	dst = dst_prev;
Index: net/xfrm/xfrm_policy.c
===================================================================
--- 5b713315560487f8c288820b17061fe27016c2cc/net/xfrm/xfrm_policy.c  (mode:100644)
+++ uncommitted/net/xfrm/xfrm_policy.c  (mode:100644)
@@ -1136,7 +1136,7 @@
 	struct xfrm_dst *last;
 	u32 mtu;
 
-	if (!dst_check(dst->path, 0) ||
+	if (!dst_check(dst->path, ((struct xfrm_dst *)dst)->path_cookie) ||
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
