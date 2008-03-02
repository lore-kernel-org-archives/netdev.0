From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 01/11][NETNS][IPV6] ip6_fib - dynamically allocate the fib tables
Date: Sun, 02 Mar 2008 10:37:21 +0100
Message-ID: <20080302094118.816272054@mai.toulouse-stg.fr.ibm.com>
References: <20080302093720.649869114@mai.toulouse-stg.fr.ibm.com>
Cc: netdev@vger.kernel.org, benjamin.thery@bull.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.uk.ibm.com ([195.212.29.140]:49099 "EHLO
	mtagate7.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751489AbYCBJnf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Mar 2008 04:43:35 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate7.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m229hYso277132
	for <netdev@vger.kernel.org>; Sun, 2 Mar 2008 09:43:34 GMT
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m229hY9E1781806
	for <netdev@vger.kernel.org>; Sun, 2 Mar 2008 09:43:34 GMT
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m229hYhE009041
	for <netdev@vger.kernel.org>; Sun, 2 Mar 2008 09:43:34 GMT
Content-Disposition: inline; filename=01_11-ip6-fib-dynamic-allocation.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch changes the fib6 tables to be dynamically allocated.
That provides the ability to make several instances of them when
a new network namespace is created.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
---
 net/ipv6/ip6_fib.c |   71 +++++++++++++++++++++++++++++++++++------------------
 1 file changed, 48 insertions(+), 23 deletions(-)

Index: net-2.6.26/net/ipv6/ip6_fib.c
===================================================================
--- net-2.6.26.orig/net/ipv6/ip6_fib.c
+++ net-2.6.26/net/ipv6/ip6_fib.c
@@ -166,20 +166,14 @@ static __inline__ void rt6_release(struc
 		dst_free(&rt->u.dst);
 }
 
-static struct fib6_table fib6_main_tbl = {
-	.tb6_id		= RT6_TABLE_MAIN,
-	.tb6_root	= {
-		.leaf		= &ip6_null_entry,
-		.fn_flags	= RTN_ROOT | RTN_TL_ROOT | RTN_RTINFO,
-	},
-};
+static struct fib6_table *fib6_main_tbl;
 
 #ifdef CONFIG_IPV6_MULTIPLE_TABLES
 #define FIB_TABLE_HASHSZ 256
 #else
 #define FIB_TABLE_HASHSZ 1
 #endif
-static struct hlist_head fib_table_hash[FIB_TABLE_HASHSZ];
+static struct hlist_head *fib_table_hash;
 
 static void fib6_link_table(struct fib6_table *tb)
 {
@@ -201,13 +195,8 @@ static void fib6_link_table(struct fib6_
 }
 
 #ifdef CONFIG_IPV6_MULTIPLE_TABLES
-static struct fib6_table fib6_local_tbl = {
-	.tb6_id		= RT6_TABLE_LOCAL,
-	.tb6_root 	= {
-		.leaf		= &ip6_null_entry,
-		.fn_flags	= RTN_ROOT | RTN_TL_ROOT | RTN_RTINFO,
-	},
-};
+
+static struct fib6_table *fib6_local_tbl;
 
 static struct fib6_table *fib6_alloc_table(u32 id)
 {
@@ -263,8 +252,8 @@ struct fib6_table *fib6_get_table(u32 id
 
 static void __init fib6_tables_init(void)
 {
-	fib6_link_table(&fib6_main_tbl);
-	fib6_link_table(&fib6_local_tbl);
+	fib6_link_table(fib6_main_tbl);
+	fib6_link_table(fib6_local_tbl);
 }
 
 #else
@@ -276,18 +265,18 @@ struct fib6_table *fib6_new_table(u32 id
 
 struct fib6_table *fib6_get_table(u32 id)
 {
-	return &fib6_main_tbl;
+	return fib6_main_tbl;
 }
 
 struct dst_entry *fib6_rule_lookup(struct flowi *fl, int flags,
 				   pol_lookup_t lookup)
 {
-	return (struct dst_entry *) lookup(&fib6_main_tbl, fl, flags);
+	return (struct dst_entry *) lookup(fib6_main_tbl, fl, flags);
 }
 
 static void __init fib6_tables_init(void)
 {
-	fib6_link_table(&fib6_main_tbl);
+	fib6_link_table(fib6_main_tbl);
 }
 
 #endif
@@ -1479,22 +1468,53 @@ void fib6_run_gc(unsigned long dummy)
 
 int __init fib6_init(void)
 {
-	int ret;
+	int ret = -ENOMEM;
 	fib6_node_kmem = kmem_cache_create("fib6_nodes",
 					   sizeof(struct fib6_node),
 					   0, SLAB_HWCACHE_ALIGN,
 					   NULL);
 	if (!fib6_node_kmem)
-		return -ENOMEM;
+		goto out;
+
+	fib_table_hash = kzalloc(sizeof(*fib_table_hash)*FIB_TABLE_HASHSZ,
+				 GFP_KERNEL);
+	if (!fib_table_hash)
+		goto out_kmem_cache_create;
+
+	fib6_main_tbl = kzalloc(sizeof(*fib6_main_tbl), GFP_KERNEL);
+	if (!fib6_main_tbl)
+		goto out_fib_table_hash;
+
+	fib6_main_tbl->tb6_id = RT6_TABLE_MAIN;
+	fib6_main_tbl->tb6_root.leaf = &ip6_null_entry;
+	fib6_main_tbl->tb6_root.fn_flags = RTN_ROOT | RTN_TL_ROOT | RTN_RTINFO;
+
+#ifdef CONFIG_IPV6_MULTIPLE_TABLES
+	fib6_local_tbl = kzalloc(sizeof(*fib6_local_tbl), GFP_KERNEL);
+	if (!fib6_local_tbl)
+		goto out_fib6_main_tbl;
+
+	fib6_local_tbl->tb6_id = RT6_TABLE_LOCAL;
+	fib6_local_tbl->tb6_root.leaf = &ip6_null_entry;
+	fib6_local_tbl->tb6_root.fn_flags = RTN_ROOT | RTN_TL_ROOT | RTN_RTINFO;
+#endif
 
 	fib6_tables_init();
 
 	ret = __rtnl_register(PF_INET6, RTM_GETROUTE, NULL, inet6_dump_fib);
 	if (ret)
-		goto out_kmem_cache_create;
+		goto out_fib6_local_tbl;
 out:
 	return ret;
 
+out_fib6_local_tbl:
+#ifdef CONFIG_IPV6_MULTIPLE_TABLES
+	kfree(fib6_local_tbl);
+out_fib6_main_tbl:
+#endif
+	kfree(fib6_main_tbl);
+out_fib_table_hash:
+	kfree(fib_table_hash);
 out_kmem_cache_create:
 	kmem_cache_destroy(fib6_node_kmem);
 	goto out;
@@ -1503,5 +1523,10 @@ out_kmem_cache_create:
 void fib6_gc_cleanup(void)
 {
 	del_timer(&ip6_fib_timer);
+#ifdef CONFIG_IPV6_MULTIPLE_TABLES
+	kfree(fib6_local_tbl);
+#endif
+	kfree(fib6_main_tbl);
+	kfree(fib_table_hash);
 	kmem_cache_destroy(fib6_node_kmem);
 }

-- 
