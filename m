From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 1/6] ipv6 - make fib6_init to return an error code
Date: Thu, 06 Dec 2007 14:53:30 +0100
Message-ID: <20071206140243.597293579@ICON-9-164-138-215.megacenter.de.ibm.com>
References: <20071206135329.598202596@ICON-9-164-138-215.megacenter.de.ibm.com>
Cc: yoshfuji@linux-ipv6.org, pekkas@netcore.fi, netdev@vger.kernel.org,
	Benjamin Thery <benjamin.thery@bull.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.de.ibm.com ([195.212.29.151]:22352 "EHLO
	mtagate2.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753046AbXLFOGa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2007 09:06:30 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate2.de.ibm.com (8.13.8/8.13.8) with ESMTP id lB6E6QCt112790
	for <netdev@vger.kernel.org>; Thu, 6 Dec 2007 14:06:27 GMT
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lB6E6ICV4075592
	for <netdev@vger.kernel.org>; Thu, 6 Dec 2007 14:06:20 GMT
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lB6E5mm6012086
	for <netdev@vger.kernel.org>; Thu, 6 Dec 2007 14:05:49 GMT
Content-Disposition: inline; filename=ip6_fib-handle-error-at-init.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If there is an error in the initialization function, nothing is followed up
to the caller. So I add a return value to be set for the init function.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
Acked-by: Benjamin Thery <benjamin.thery@bull.net>
---
 include/net/ip6_fib.h |    2 +-
 net/ipv6/ip6_fib.c    |   14 +++++++++++---
 2 files changed, 12 insertions(+), 4 deletions(-)

Index: net-2.6.25/include/net/ip6_fib.h
===================================================================
--- net-2.6.25.orig/include/net/ip6_fib.h
+++ net-2.6.25/include/net/ip6_fib.h
@@ -224,7 +224,7 @@ extern void			fib6_run_gc(unsigned long 
 
 extern void			fib6_gc_cleanup(void);
 
-extern void			fib6_init(void);
+extern int			fib6_init(void);
 
 extern void			fib6_rules_init(void);
 extern void			fib6_rules_cleanup(void);
Index: net-2.6.25/net/ipv6/ip6_fib.c
===================================================================
--- net-2.6.25.orig/net/ipv6/ip6_fib.c
+++ net-2.6.25/net/ipv6/ip6_fib.c
@@ -1473,16 +1473,24 @@ void fib6_run_gc(unsigned long dummy)
 	spin_unlock_bh(&fib6_gc_lock);
 }
 
-void __init fib6_init(void)
+int __init fib6_init(void)
 {
+	int ret;
 	fib6_node_kmem = kmem_cache_create("fib6_nodes",
 					   sizeof(struct fib6_node),
 					   0, SLAB_HWCACHE_ALIGN|SLAB_PANIC,
 					   NULL);
-
 	fib6_tables_init();
 
-	__rtnl_register(PF_INET6, RTM_GETROUTE, NULL, inet6_dump_fib);
+	ret = __rtnl_register(PF_INET6, RTM_GETROUTE, NULL, inet6_dump_fib);
+	if (ret)
+		goto out_kmem_cache_create;
+out:
+	return ret;
+
+out_kmem_cache_create:
+	kmem_cache_destroy(fib6_node_kmem);
+	goto out;
 }
 
 void fib6_gc_cleanup(void)

-- 
