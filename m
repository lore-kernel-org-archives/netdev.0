From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 01/12][NETNS][IPV6] route6 - create route6 proc files for the namespace
Date: Tue, 04 Mar 2008 22:03:27 +0100
Message-ID: <20080304210959.536677809@mai.toulouse-stg.fr.ibm.com>
References: <20080304210326.169013927@mai.toulouse-stg.fr.ibm.com>
Cc: netdev@vger.kernel.org, benjamin.thery@bull.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.de.ibm.com ([195.212.29.155]:35477 "EHLO
	mtagate6.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752610AbYCDVMn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 16:12:43 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate6.de.ibm.com (8.13.8/8.13.8) with ESMTP id m24LCgTf491782
	for <netdev@vger.kernel.org>; Tue, 4 Mar 2008 21:12:42 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m24LCggd1806350
	for <netdev@vger.kernel.org>; Tue, 4 Mar 2008 22:12:42 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m24LCfGG019279
	for <netdev@vger.kernel.org>; Tue, 4 Mar 2008 21:12:41 GMT
Content-Disposition: inline; filename=route6-procfs.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make /proc/net/ipv6_route and /proc/net/rt6_stats to be per namespace.
These proc files are now created when the network namespace is initialized.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
---
 net/ipv6/route.c |   70 +++++++++++++++++++++----------------------------------
 1 file changed, 27 insertions(+), 43 deletions(-)

Index: net-2.6.26/net/ipv6/route.c
===================================================================
--- net-2.6.26.orig/net/ipv6/route.c
+++ net-2.6.26/net/ipv6/route.c
@@ -2377,40 +2377,6 @@ static const struct file_operations rt6_
 	.llseek	 = seq_lseek,
 	.release = single_release,
 };
-
-static int ipv6_route_proc_init(struct net *net)
-{
-	int ret = -ENOMEM;
-	if (!proc_net_fops_create(net, "ipv6_route",
-				  0, &ipv6_route_proc_fops))
-		goto out;
-
-	if (!proc_net_fops_create(net, "rt6_stats",
-				  S_IRUGO, &rt6_stats_seq_fops))
-		goto out_ipv6_route;
-
-	ret = 0;
-out:
-	return ret;
-out_ipv6_route:
-	proc_net_remove(net, "ipv6_route");
-	goto out;
-}
-
-static void ipv6_route_proc_fini(struct net *net)
-{
-	proc_net_remove(net, "ipv6_route");
-	proc_net_remove(net, "rt6_stats");
-}
-#else
-static inline int ipv6_route_proc_init(struct net *net)
-{
-	return 0;
-}
-static inline void ipv6_route_proc_fini(struct net *net)
-{
-	return ;
-}
 #endif	/* CONFIG_PROC_FS */
 
 #ifdef CONFIG_SYSCTL
@@ -2544,6 +2510,28 @@ struct ctl_table *ipv6_route_sysctl_init
 }
 #endif
 
+static int ip6_route_net_init(struct net *net)
+{
+#ifdef CONFIG_PROC_FS
+	proc_net_fops_create(net, "ipv6_route", 0, &ipv6_route_proc_fops);
+	proc_net_fops_create(net, "rt6_stats", S_IRUGO, &rt6_stats_seq_fops);
+#endif
+	return 0;
+}
+
+static void ip6_route_net_exit(struct net *net)
+{
+#ifdef CONFIG_PROC_FS
+	proc_net_remove(net, "ipv6_route");
+	proc_net_remove(net, "rt6_stats");
+#endif
+}
+
+static struct pernet_operations ip6_route_net_ops = {
+	.init = ip6_route_net_init,
+	.exit = ip6_route_net_exit,
+};
+
 int __init ip6_route_init(void)
 {
 	int ret;
@@ -2560,13 +2548,9 @@ int __init ip6_route_init(void)
 	if (ret)
 		goto out_kmem_cache;
 
-	ret = ipv6_route_proc_init(&init_net);
-	if (ret)
-		goto out_fib6_init;
-
 	ret = xfrm6_init();
 	if (ret)
-		goto out_proc_init;
+		goto out_fib6_init;
 
 	ret = fib6_rules_init();
 	if (ret)
@@ -2578,7 +2562,9 @@ int __init ip6_route_init(void)
 	    __rtnl_register(PF_INET6, RTM_GETROUTE, inet6_rtm_getroute, NULL))
 		goto fib6_rules_init;
 
-	ret = 0;
+	ret = register_pernet_subsys(&ip6_route_net_ops);
+	if (ret)
+		goto fib6_rules_init;
 out:
 	return ret;
 
@@ -2586,8 +2572,6 @@ fib6_rules_init:
 	fib6_rules_cleanup();
 xfrm6_init:
 	xfrm6_fini();
-out_proc_init:
-	ipv6_route_proc_fini(&init_net);
 out_fib6_init:
 	rt6_ifdown(&init_net, NULL);
 	fib6_gc_cleanup();
@@ -2598,8 +2582,8 @@ out_kmem_cache:
 
 void ip6_route_cleanup(void)
 {
+	unregister_pernet_subsys(&ip6_route_net_ops);
 	fib6_rules_cleanup();
-	ipv6_route_proc_fini(&init_net);
 	xfrm6_fini();
 	rt6_ifdown(&init_net, NULL);
 	fib6_gc_cleanup();

-- 
