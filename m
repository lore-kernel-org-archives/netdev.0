From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] ipv6: initialize route null entry in addrconf_init()
Date: Wed,  3 May 2017 22:07:31 -0700
Message-ID: <1493874452-3050-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: andreyknvl@google.com, dsahern@gmail.com,
        Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35146 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754040AbdEDFHo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 4 May 2017 01:07:44 -0400
Received: by mail-pf0-f193.google.com with SMTP id o68so589564pfj.2
        for <netdev@vger.kernel.org>; Wed, 03 May 2017 22:07:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrey reported a crash on init_net.ipv6.ip6_null_entry->rt6i_idev
since it is always NULL.

This is clearly wrong, we have code to initialize it to loopback_dev,
unfortunately the order is still not correct.

loopback_dev is registered very early during boot, we lose a chance
to re-initialize it in notifier. addrconf_init() is called after
ip6_route_init(), which means we have no chance to correct it.

Fix it by moving this initialization explicitly after
ipv6_add_dev(init_net.loopback_dev) in addrconf_init().

Reported-by: Andrey Konovalov <andreyknvl@google.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/net/ip6_route.h |  1 +
 net/ipv6/addrconf.c     |  2 ++
 net/ipv6/route.c        | 26 +++++++++++++++-----------
 3 files changed, 18 insertions(+), 11 deletions(-)

diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index 9dc2c18..f5e625f 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -84,6 +84,7 @@ struct dst_entry *ip6_route_lookup(struct net *net, struct flowi6 *fl6,
 struct rt6_info *ip6_pol_route(struct net *net, struct fib6_table *table,
 			       int ifindex, struct flowi6 *fl6, int flags);
 
+void ip6_route_init_special_entries(void);
 int ip6_route_init(void);
 void ip6_route_cleanup(void);
 
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index a2a370b..77a4bd5 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -6573,6 +6573,8 @@ int __init addrconf_init(void)
 		goto errlo;
 	}
 
+	ip6_route_init_special_entries();
+
 	for (i = 0; i < IN6_ADDR_HSIZE; i++)
 		INIT_HLIST_HEAD(&inet6_addr_lst[i]);
 
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index a1bf426..2f11366 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -4027,6 +4027,21 @@ static struct notifier_block ip6_route_dev_notifier = {
 	.priority = 0,
 };
 
+void __init ip6_route_init_special_entries(void)
+{
+	/* Registering of the loopback is done before this portion of code,
+	 * the loopback reference in rt6_info will not be taken, do it
+	 * manually for init_net */
+	init_net.ipv6.ip6_null_entry->dst.dev = init_net.loopback_dev;
+	init_net.ipv6.ip6_null_entry->rt6i_idev = in6_dev_get(init_net.loopback_dev);
+  #ifdef CONFIG_IPV6_MULTIPLE_TABLES
+	init_net.ipv6.ip6_prohibit_entry->dst.dev = init_net.loopback_dev;
+	init_net.ipv6.ip6_prohibit_entry->rt6i_idev = in6_dev_get(init_net.loopback_dev);
+	init_net.ipv6.ip6_blk_hole_entry->dst.dev = init_net.loopback_dev;
+	init_net.ipv6.ip6_blk_hole_entry->rt6i_idev = in6_dev_get(init_net.loopback_dev);
+  #endif
+}
+
 int __init ip6_route_init(void)
 {
 	int ret;
@@ -4053,17 +4068,6 @@ int __init ip6_route_init(void)
 
 	ip6_dst_blackhole_ops.kmem_cachep = ip6_dst_ops_template.kmem_cachep;
 
-	/* Registering of the loopback is done before this portion of code,
-	 * the loopback reference in rt6_info will not be taken, do it
-	 * manually for init_net */
-	init_net.ipv6.ip6_null_entry->dst.dev = init_net.loopback_dev;
-	init_net.ipv6.ip6_null_entry->rt6i_idev = in6_dev_get(init_net.loopback_dev);
-  #ifdef CONFIG_IPV6_MULTIPLE_TABLES
-	init_net.ipv6.ip6_prohibit_entry->dst.dev = init_net.loopback_dev;
-	init_net.ipv6.ip6_prohibit_entry->rt6i_idev = in6_dev_get(init_net.loopback_dev);
-	init_net.ipv6.ip6_blk_hole_entry->dst.dev = init_net.loopback_dev;
-	init_net.ipv6.ip6_blk_hole_entry->rt6i_idev = in6_dev_get(init_net.loopback_dev);
-  #endif
 	ret = fib6_init();
 	if (ret)
 		goto out_register_subsys;
-- 
2.5.5
