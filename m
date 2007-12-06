From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 6/6] ipv6 - route6/fib6 : dont panic a kmem_cache_create
Date: Thu, 06 Dec 2007 14:53:35 +0100
Message-ID: <20071206140324.805833763@ICON-9-164-138-215.megacenter.de.ibm.com>
References: <20071206135329.598202596@ICON-9-164-138-215.megacenter.de.ibm.com>
Cc: yoshfuji@linux-ipv6.org, pekkas@netcore.fi, netdev@vger.kernel.org,
	Benjamin Thery <benjamin.thery@bull.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.de.ibm.com ([195.212.29.155]:9151 "EHLO
	mtagate6.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752998AbXLFOGV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2007 09:06:21 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate6.de.ibm.com (8.13.8/8.13.8) with ESMTP id lB6E5eTu087438
	for <netdev@vger.kernel.org>; Thu, 6 Dec 2007 14:05:40 GMT
Received: from d12av03.megacenter.de.ibm.com (d12av03.megacenter.de.ibm.com [9.149.165.213])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lB6E5eaA2924670
	for <netdev@vger.kernel.org>; Thu, 6 Dec 2007 15:05:40 +0100
Received: from d12av03.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av03.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lB6E5dcL010788
	for <netdev@vger.kernel.org>; Thu, 6 Dec 2007 15:05:40 +0100
Content-Disposition: inline; filename=ip6_fib-dont-panic-on-kmem_cache-creation-error.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the kmem_cache_creation fails, the kernel will panic. It is acceptable
if the system is booting, but if the ipv6 protocol is compiled as a module
and it is loaded after the system has booted, do we want to panic instead
of just failing to initialize the protocol ?

The init function is now returning an error and this one is checked for
protocol initialization. So the ipv6 protocol will safely fails.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
Acked-by: Benjamin Thery <benjamin.thery@bull.net>
---
 net/ipv6/ip6_fib.c |    5 ++++-
 net/ipv6/route.c   |    5 ++++-
 2 files changed, 8 insertions(+), 2 deletions(-)

Index: net-2.6.25/net/ipv6/ip6_fib.c
===================================================================
--- net-2.6.25.orig/net/ipv6/ip6_fib.c
+++ net-2.6.25/net/ipv6/ip6_fib.c
@@ -1478,8 +1478,11 @@ int __init fib6_init(void)
 	int ret;
 	fib6_node_kmem = kmem_cache_create("fib6_nodes",
 					   sizeof(struct fib6_node),
-					   0, SLAB_HWCACHE_ALIGN|SLAB_PANIC,
+					   0, SLAB_HWCACHE_ALIGN,
 					   NULL);
+	if (!fib6_node_kmem)
+		return -ENOMEM;
+
 	fib6_tables_init();
 
 	ret = __rtnl_register(PF_INET6, RTM_GETROUTE, NULL, inet6_dump_fib);
Index: net-2.6.25/net/ipv6/route.c
===================================================================
--- net-2.6.25.orig/net/ipv6/route.c
+++ net-2.6.25/net/ipv6/route.c
@@ -2466,7 +2466,10 @@ int __init ip6_route_init(void)
 
 	ip6_dst_ops.kmem_cachep =
 		kmem_cache_create("ip6_dst_cache", sizeof(struct rt6_info), 0,
-				  SLAB_HWCACHE_ALIGN|SLAB_PANIC, NULL);
+				  SLAB_HWCACHE_ALIGN, NULL);
+	if (!ip6_dst_ops.kmem_cachep)
+		return -ENOMEM;
+
 	ip6_dst_blackhole_ops.kmem_cachep = ip6_dst_ops.kmem_cachep;
 
 	ret = fib6_init();

-- 
