From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH] ipv6: Prevent access to uninitialized fib_table_hash via /proc/net/ipv6_route
Date: Fri, 15 Jun 2012 11:00:17 +0200
Message-ID: <e4b53a15fadbe5c1aa5402fcc8172b0ee281da33.1339750783.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53432 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753394Ab2FOJAV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Jun 2012 05:00:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

/proc/net/ipv6_route reflects the contents of fib_table_hash. The proc
handler is installed in ip6_route_net_init() whereas fib_table_hash is
allocated in fib6_net_init() _after_ the proc handler has been installed.

This opens up a short time frame to access fib_table_hash with its pants
down.

fib6_init() as a whole can't be moved to an earlier position as it also
registers the rtnetlink message handlers which should be registered at
the end. Therefore split it into fib6_init() which is run early and
fib6_init_late() to register the rtnetlink message handlers.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 include/net/ip6_fib.h |    2 ++
 net/ipv6/ip6_fib.c    |   18 +++++++++++-------
 net/ipv6/route.c      |   16 +++++++++++-----
 3 files changed, 24 insertions(+), 12 deletions(-)

diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index 0ae759a..209af13 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -271,6 +271,8 @@ extern void			fib6_run_gc(unsigned long expires,
 extern void			fib6_gc_cleanup(void);
 
 extern int			fib6_init(void);
+extern int			fib6_init_late(void);
+extern void			fib6_cleanup_late(void);
 
 #ifdef CONFIG_IPV6_MULTIPLE_TABLES
 extern int			fib6_rules_init(void);
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 74c21b9..fbd4aff 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -1692,21 +1692,25 @@ int __init fib6_init(void)
 	ret = register_pernet_subsys(&fib6_net_ops);
 	if (ret)
 		goto out_kmem_cache_create;
-
-	ret = __rtnl_register(PF_INET6, RTM_GETROUTE, NULL, inet6_dump_fib,
-			      NULL);
-	if (ret)
-		goto out_unregister_subsys;
 out:
 	return ret;
 
-out_unregister_subsys:
-	unregister_pernet_subsys(&fib6_net_ops);
 out_kmem_cache_create:
 	kmem_cache_destroy(fib6_node_kmem);
 	goto out;
 }
 
+int __init fib6_init_late(void)
+{
+	return __rtnl_register(PF_INET6, RTM_GETROUTE, NULL, inet6_dump_fib,
+			       NULL);
+}
+
+void fib6_cleanup_late(void)
+{
+	rtnl_unregister(PF_INET6, RTM_GETROUTE);
+}
+
 void fib6_gc_cleanup(void)
 {
 	unregister_pernet_subsys(&fib6_net_ops);
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 999a982..dc60bf5 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -3018,10 +3018,14 @@ int __init ip6_route_init(void)
 	if (ret)
 		goto out_kmem_cache;
 
-	ret = register_pernet_subsys(&ip6_route_net_ops);
+	ret = fib6_init();
 	if (ret)
 		goto out_dst_entries;
 
+	ret = register_pernet_subsys(&ip6_route_net_ops);
+	if (ret)
+		goto out_fib6_init;
+
 	ip6_dst_blackhole_ops.kmem_cachep = ip6_dst_ops_template.kmem_cachep;
 
 	/* Registering of the loopback is done before this portion of code,
@@ -3035,13 +3039,13 @@ int __init ip6_route_init(void)
 	init_net.ipv6.ip6_blk_hole_entry->dst.dev = init_net.loopback_dev;
 	init_net.ipv6.ip6_blk_hole_entry->rt6i_idev = in6_dev_get(init_net.loopback_dev);
   #endif
-	ret = fib6_init();
+	ret = fib6_init_late();
 	if (ret)
 		goto out_register_subsys;
 
 	ret = xfrm6_init();
 	if (ret)
-		goto out_fib6_init;
+		goto out_fib6_init_late;
 
 	ret = fib6_rules_init();
 	if (ret)
@@ -3064,10 +3068,12 @@ fib6_rules_init:
 	fib6_rules_cleanup();
 xfrm6_init:
 	xfrm6_fini();
-out_fib6_init:
-	fib6_gc_cleanup();
+out_fib6_init_late:
+	fib6_cleanup_late();
 out_register_subsys:
 	unregister_pernet_subsys(&ip6_route_net_ops);
+out_fib6_init:
+	fib6_gc_cleanup();
 out_dst_entries:
 	dst_entries_destroy(&ip6_dst_blackhole_ops);
 out_kmem_cache:
-- 
1.7.7.6
