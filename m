From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 2/3][IPV6]: remove ifdef in route6 for xfrm6
Date: Fri, 07 Dec 2007 14:13:27 +0100
Message-ID: <20071207131812.456058639@ICON-9-164-138-215.megacenter.de.ibm.com>
References: <20071207131325.332768305@ICON-9-164-138-215.megacenter.de.ibm.com>
Cc: yoshfuji@linux-ipv6.org, pekkas@netcore.fi, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.uk.ibm.com ([195.212.29.137]:12919 "EHLO
	mtagate4.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752970AbXLGNVB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2007 08:21:01 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate4.uk.ibm.com (8.13.8/8.13.8) with ESMTP id lB7DL0c7172974
	for <netdev@vger.kernel.org>; Fri, 7 Dec 2007 13:21:00 GMT
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lB7DL0wo5062852
	for <netdev@vger.kernel.org>; Fri, 7 Dec 2007 13:21:00 GMT
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lB7DKhog005564
	for <netdev@vger.kernel.org>; Fri, 7 Dec 2007 13:20:43 GMT
Content-Disposition: inline; filename=route6-remove-ifdef-for-xfrm-init.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following patch create the usual static inline functions to disable
the xfrm6_init and xfrm6_fini function when XFRM is off.
That's allow to remove some ifdef and make the code a little more clear.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
 include/net/xfrm.h |   16 +++++++++++++---
 net/ipv6/route.c   |    7 +------
 2 files changed, 14 insertions(+), 9 deletions(-)

Index: net-2.6.25/include/net/xfrm.h
===================================================================
--- net-2.6.25.orig/include/net/xfrm.h
+++ net-2.6.25/include/net/xfrm.h
@@ -842,7 +842,6 @@ xfrm_state_addr_cmp(struct xfrm_tmpl *tm
 }
 
 #ifdef CONFIG_XFRM
-
 extern int __xfrm_policy_check(struct sock *, int dir, struct sk_buff *skb, unsigned short family);
 
 static inline int xfrm_policy_check(struct sock *sk, int dir, struct sk_buff *skb, unsigned short family)
@@ -1066,12 +1065,23 @@ struct xfrm6_tunnel {
 
 extern void xfrm_init(void);
 extern void xfrm4_init(void);
-extern int xfrm6_init(void);
-extern void xfrm6_fini(void);
 extern void xfrm_state_init(void);
 extern void xfrm4_state_init(void);
+#ifdef CONFIG_XFRM
+extern int xfrm6_init(void);
+extern void xfrm6_fini(void);
 extern int xfrm6_state_init(void);
 extern void xfrm6_state_fini(void);
+#else
+static inline int xfrm6_init(void)
+{
+	return 0;
+}
+static inline void xfrm6_fini(void)
+{
+	;
+}
+#endif
 
 extern int xfrm_state_walk(u8 proto, int (*func)(struct xfrm_state *, int, void*), void *);
 extern struct xfrm_state *xfrm_state_alloc(void);
Index: net-2.6.25/net/ipv6/route.c
===================================================================
--- net-2.6.25.orig/net/ipv6/route.c
+++ net-2.6.25/net/ipv6/route.c
@@ -2517,11 +2517,10 @@ int __init ip6_route_init(void)
 	if (ret)
 		goto out_fib6_init;
 
-#ifdef CONFIG_XFRM
 	ret = xfrm6_init();
 	if (ret)
 		goto out_proc_init;
-#endif
+
 #ifdef CONFIG_IPV6_MULTIPLE_TABLES
 	ret = fib6_rules_init();
 	if (ret)
@@ -2542,9 +2541,7 @@ fib6_rules_init:
 	fib6_rules_cleanup();
 xfrm6_init:
 #endif
-#ifdef CONFIG_XFRM
 	xfrm6_fini();
-#endif
 out_proc_init:
 	ipv6_route_proc_fini(&init_net);
 out_fib6_init:
@@ -2561,9 +2558,7 @@ void ip6_route_cleanup(void)
 	fib6_rules_cleanup();
 #endif
 	ipv6_route_proc_fini(&init_net);
-#ifdef CONFIG_XFRM
 	xfrm6_fini();
-#endif
 	rt6_ifdown(NULL);
 	fib6_gc_cleanup();
 	kmem_cache_destroy(ip6_dst_ops.kmem_cachep);

-- 
