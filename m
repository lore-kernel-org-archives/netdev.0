From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 1/3][IPV6]: create route6 proc init-fini functions
Date: Fri, 07 Dec 2007 14:13:26 +0100
Message-ID: <20071207131810.854735805@ICON-9-164-138-215.megacenter.de.ibm.com>
References: <20071207131325.332768305@ICON-9-164-138-215.megacenter.de.ibm.com>
Cc: yoshfuji@linux-ipv6.org, pekkas@netcore.fi, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.uk.ibm.com ([195.212.29.139]:29462 "EHLO
	mtagate6.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753589AbXLGNVF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2007 08:21:05 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate6.uk.ibm.com (8.13.8/8.13.8) with ESMTP id lB7DL4IF185654
	for <netdev@vger.kernel.org>; Fri, 7 Dec 2007 13:21:04 GMT
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lB7DL4a63457262
	for <netdev@vger.kernel.org>; Fri, 7 Dec 2007 13:21:04 GMT
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lB7DKlVM005548
	for <netdev@vger.kernel.org>; Fri, 7 Dec 2007 13:20:47 GMT
Content-Disposition: inline; filename=route6-make-a-specific-proc-init-fini-function.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make the proc creation/destruction to be a separate function. That allows to
remove the #ifdef CONFIG_PROC_FS in the init/fini function and make them more
readable.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
 net/ipv6/route.c |   58 +++++++++++++++++++++++++++++++++++++------------------
 1 file changed, 40 insertions(+), 18 deletions(-)

Index: net-2.6.25/net/ipv6/route.c
===================================================================
--- net-2.6.25.orig/net/ipv6/route.c
+++ net-2.6.25/net/ipv6/route.c
@@ -2353,6 +2353,40 @@ static const struct file_operations rt6_
 	.llseek	 = seq_lseek,
 	.release = single_release,
 };
+
+static int ipv6_route_proc_init(struct net *net)
+{
+	int ret = -ENOMEM;
+	if (!proc_net_fops_create(net, "ipv6_route",
+				  0, &ipv6_route_proc_fops))
+		goto out;
+
+	if (!proc_net_fops_create(net, "rt6_stats",
+				  S_IRUGO, &rt6_stats_seq_fops))
+		goto out_ipv6_route;
+
+	ret = 0;
+out:
+	return ret;
+out_ipv6_route:
+	proc_net_remove(net, "ipv6_route");
+	goto out;
+}
+
+static void ipv6_route_proc_fini(struct net *net)
+{
+	proc_net_remove(net, "ipv6_route");
+	proc_net_remove(net, "rt6_stats");
+}
+#else
+static inline int ipv6_route_proc_init(struct net *net)
+{
+	return 0;
+}
+static inline void ipv6_route_proc_fini(struct net *net)
+{
+	return ;
+}
 #endif	/* CONFIG_PROC_FS */
 
 #ifdef CONFIG_SYSCTL
@@ -2479,21 +2513,14 @@ int __init ip6_route_init(void)
 	if (ret)
 		goto out_kmem_cache;
 
-#ifdef CONFIG_PROC_FS
-	ret = -ENOMEM;
-	if (!proc_net_fops_create(&init_net, "ipv6_route",
-				  0, &ipv6_route_proc_fops))
+	ret = ipv6_route_proc_init(&init_net);
+	if (ret)
 		goto out_fib6_init;
 
-	if (!proc_net_fops_create(&init_net, "rt6_stats",
-				  S_IRUGO, &rt6_stats_seq_fops))
-		goto out_proc_ipv6_route;
-#endif
-
 #ifdef CONFIG_XFRM
 	ret = xfrm6_init();
 	if (ret)
-		goto out_proc_rt6_stats;
+		goto out_proc_init;
 #endif
 #ifdef CONFIG_IPV6_MULTIPLE_TABLES
 	ret = fib6_rules_init();
@@ -2517,14 +2544,10 @@ xfrm6_init:
 #endif
 #ifdef CONFIG_XFRM
 	xfrm6_fini();
-out_proc_rt6_stats:
 #endif
-#ifdef CONFIG_PROC_FS
-	proc_net_remove(&init_net, "rt6_stats");
-out_proc_ipv6_route:
-	proc_net_remove(&init_net, "ipv6_route");
+out_proc_init:
+	ipv6_route_proc_fini(&init_net);
 out_fib6_init:
-#endif
 	rt6_ifdown(NULL);
 	fib6_gc_cleanup();
 out_kmem_cache:
@@ -2537,8 +2560,7 @@ void ip6_route_cleanup(void)
 #ifdef CONFIG_IPV6_MULTIPLE_TABLES
 	fib6_rules_cleanup();
 #endif
-	proc_net_remove(&init_net, "ipv6_route");
-	proc_net_remove(&init_net, "rt6_stats");
+	ipv6_route_proc_fini(&init_net);
 #ifdef CONFIG_XFRM
 	xfrm6_fini();
 #endif

-- 
