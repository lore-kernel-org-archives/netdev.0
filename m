From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 4/6] ipv6 - make ip6_route_init to return an error code
Date: Thu, 06 Dec 2007 14:53:33 +0100
Message-ID: <20071206140303.281847428@ICON-9-164-138-215.megacenter.de.ibm.com>
References: <20071206135329.598202596@ICON-9-164-138-215.megacenter.de.ibm.com>
Cc: yoshfuji@linux-ipv6.org, pekkas@netcore.fi, netdev@vger.kernel.org,
	Benjamin Thery <benjamin.thery@bull.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.de.ibm.com ([195.212.29.151]:22287 "EHLO
	mtagate2.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752940AbXLFOGG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2007 09:06:06 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate2.de.ibm.com (8.13.8/8.13.8) with ESMTP id lB6E61IR082328
	for <netdev@vger.kernel.org>; Thu, 6 Dec 2007 14:06:01 GMT
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lB6E5tYr3379432
	for <netdev@vger.kernel.org>; Thu, 6 Dec 2007 14:06:00 GMT
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lB6E5bgP004383
	for <netdev@vger.kernel.org>; Thu, 6 Dec 2007 14:05:37 GMT
Content-Disposition: inline; filename=route6-handle-error-at-init.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The route initialization function does not return any value to notify if
the initialization is successful or not. This patch checks all calls made
for the initilization in order to return a value for the caller.

Unfortunatly, proc_net_fops_create will return a NULL pointer if CONFIG_PROC_FS
is off, so we can not check the return code without an ifdef CONFIG_PROC_FS 
block in the ip6_route_init function.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
Acked-by: Benjamin Thery <benjamin.thery@bull.net>
---
 include/net/ip6_route.h |    2 -
 net/ipv6/route.c        |   66 +++++++++++++++++++++++++++++++++++++++---------
 2 files changed, 55 insertions(+), 13 deletions(-)

Index: net-2.6.25/include/net/ip6_route.h
===================================================================
--- net-2.6.25.orig/include/net/ip6_route.h
+++ net-2.6.25/include/net/ip6_route.h
@@ -50,7 +50,7 @@ extern void			ip6_route_input(struct sk_
 extern struct dst_entry *	ip6_route_output(struct sock *sk,
 						 struct flowi *fl);
 
-extern void			ip6_route_init(void);
+extern int			ip6_route_init(void);
 extern void			ip6_route_cleanup(void);
 
 extern int			ipv6_route_ioctl(unsigned int cmd, void __user *arg);
Index: net-2.6.25/net/ipv6/route.c
===================================================================
--- net-2.6.25.orig/net/ipv6/route.c
+++ net-2.6.25/net/ipv6/route.c
@@ -2460,26 +2460,70 @@ ctl_table ipv6_route_table[] = {
 
 #endif
 
-void __init ip6_route_init(void)
+int __init ip6_route_init(void)
 {
+	int ret;
+
 	ip6_dst_ops.kmem_cachep =
 		kmem_cache_create("ip6_dst_cache", sizeof(struct rt6_info), 0,
 				  SLAB_HWCACHE_ALIGN|SLAB_PANIC, NULL);
 	ip6_dst_blackhole_ops.kmem_cachep = ip6_dst_ops.kmem_cachep;
 
-	fib6_init();
-	proc_net_fops_create(&init_net, "ipv6_route", 0, &ipv6_route_proc_fops);
-	proc_net_fops_create(&init_net, "rt6_stats", S_IRUGO, &rt6_stats_seq_fops);
+	ret = fib6_init();
+	if (ret)
+		goto out_kmem_cache;
+
+#ifdef CONFIG_PROC_FS
+	ret = -ENOMEM;
+	if (!proc_net_fops_create(&init_net, "ipv6_route",
+				  0, &ipv6_route_proc_fops))
+		goto out_fib6_init;
+
+	if (!proc_net_fops_create(&init_net, "rt6_stats",
+				  S_IRUGO, &rt6_stats_seq_fops))
+		goto out_proc_ipv6_route;
+#endif
+
 #ifdef CONFIG_XFRM
-	xfrm6_init();
+	ret = xfrm6_init();
+	if (ret)
+		goto out_proc_rt6_stats;
 #endif
 #ifdef CONFIG_IPV6_MULTIPLE_TABLES
-	fib6_rules_init();
-#endif
+	ret = fib6_rules_init();
+	if (ret)
+		goto xfrm6_init;
+#endif
+	ret = -ENOBUFS;
+	if (__rtnl_register(PF_INET6, RTM_NEWROUTE, inet6_rtm_newroute, NULL) ||
+	    __rtnl_register(PF_INET6, RTM_DELROUTE, inet6_rtm_delroute, NULL) ||
+	    __rtnl_register(PF_INET6, RTM_GETROUTE, inet6_rtm_getroute, NULL))
+		goto fib6_rules_init;
+
+	ret = 0;
+out:
+	return ret;
 
-	__rtnl_register(PF_INET6, RTM_NEWROUTE, inet6_rtm_newroute, NULL);
-	__rtnl_register(PF_INET6, RTM_DELROUTE, inet6_rtm_delroute, NULL);
-	__rtnl_register(PF_INET6, RTM_GETROUTE, inet6_rtm_getroute, NULL);
+fib6_rules_init:
+#ifdef CONFIG_IPV6_MULTIPLE_TABLES
+	fib6_rules_cleanup();
+xfrm6_init:
+#endif
+#ifdef CONFIG_XFRM
+	xfrm6_fini();
+out_proc_rt6_stats:
+#endif
+#ifdef CONFIG_PROC_FS
+	proc_net_remove(&init_net, "rt6_stats");
+out_proc_ipv6_route:
+	proc_net_remove(&init_net, "ipv6_route");
+out_fib6_init:
+#endif
+	rt6_ifdown(NULL);
+	fib6_gc_cleanup();
+out_kmem_cache:
+	kmem_cache_destroy(ip6_dst_ops.kmem_cachep);
+	goto out;
 }
 
 void ip6_route_cleanup(void)
@@ -2487,10 +2531,8 @@ void ip6_route_cleanup(void)
 #ifdef CONFIG_IPV6_MULTIPLE_TABLES
 	fib6_rules_cleanup();
 #endif
-#ifdef CONFIG_PROC_FS
 	proc_net_remove(&init_net, "ipv6_route");
 	proc_net_remove(&init_net, "rt6_stats");
-#endif
 #ifdef CONFIG_XFRM
 	xfrm6_fini();
 #endif

-- 
