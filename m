From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 3/3][IPV6]: route6 remove ifdef for fib_rules
Date: Fri, 07 Dec 2007 14:13:28 +0100
Message-ID: <20071207131813.975600292@ICON-9-164-138-215.megacenter.de.ibm.com>
References: <20071207131325.332768305@ICON-9-164-138-215.megacenter.de.ibm.com>
Cc: yoshfuji@linux-ipv6.org, pekkas@netcore.fi, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate8.de.ibm.com ([195.212.29.157]:31092 "EHLO
	mtagate8.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751322AbXLGNUg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2007 08:20:36 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate8.de.ibm.com (8.13.8/8.13.8) with ESMTP id lB7DKZUJ370852
	for <netdev@vger.kernel.org>; Fri, 7 Dec 2007 13:20:35 GMT
Received: from d12av04.megacenter.de.ibm.com (d12av04.megacenter.de.ibm.com [9.149.165.229])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lB7DKYiK2867268
	for <netdev@vger.kernel.org>; Fri, 7 Dec 2007 14:20:34 +0100
Received: from d12av04.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av04.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lB7DKY0A031630
	for <netdev@vger.kernel.org>; Fri, 7 Dec 2007 14:20:34 +0100
Content-Disposition: inline; filename=route6-remove-ifdef-for-multiple-tables.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch defines the usual static inline functions when the code is
disabled for fib6_rules. That's allow to remove some ifdef in route.c
file and make the code a little more clear.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
 include/net/ip6_fib.h |   12 +++++++++++-
 net/ipv6/route.c      |    7 +------
 2 files changed, 12 insertions(+), 7 deletions(-)

Index: net-2.6.25/include/net/ip6_fib.h
===================================================================
--- net-2.6.25.orig/include/net/ip6_fib.h
+++ net-2.6.25/include/net/ip6_fib.h
@@ -226,8 +226,18 @@ extern void			fib6_gc_cleanup(void);
 
 extern int			fib6_init(void);
 
+#ifdef CONFIG_IPV6_MULTIPLE_TABLES
 extern int			fib6_rules_init(void);
 extern void			fib6_rules_cleanup(void);
-
+#else
+static inline int               fib6_rules_init(void)
+{
+	return 0;
+}
+static inline void              fib6_rules_cleanup(void)
+{
+	return ;
+}
+#endif
 #endif
 #endif
Index: net-2.6.25/net/ipv6/route.c
===================================================================
--- net-2.6.25.orig/net/ipv6/route.c
+++ net-2.6.25/net/ipv6/route.c
@@ -2521,11 +2521,10 @@ int __init ip6_route_init(void)
 	if (ret)
 		goto out_proc_init;
 
-#ifdef CONFIG_IPV6_MULTIPLE_TABLES
 	ret = fib6_rules_init();
 	if (ret)
 		goto xfrm6_init;
-#endif
+
 	ret = -ENOBUFS;
 	if (__rtnl_register(PF_INET6, RTM_NEWROUTE, inet6_rtm_newroute, NULL) ||
 	    __rtnl_register(PF_INET6, RTM_DELROUTE, inet6_rtm_delroute, NULL) ||
@@ -2537,10 +2536,8 @@ out:
 	return ret;
 
 fib6_rules_init:
-#ifdef CONFIG_IPV6_MULTIPLE_TABLES
 	fib6_rules_cleanup();
 xfrm6_init:
-#endif
 	xfrm6_fini();
 out_proc_init:
 	ipv6_route_proc_fini(&init_net);
@@ -2554,9 +2551,7 @@ out_kmem_cache:
 
 void ip6_route_cleanup(void)
 {
-#ifdef CONFIG_IPV6_MULTIPLE_TABLES
 	fib6_rules_cleanup();
-#endif
 	ipv6_route_proc_fini(&init_net);
 	xfrm6_fini();
 	rt6_ifdown(NULL);

-- 
