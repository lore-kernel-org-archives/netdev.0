From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH] Compact some ifdefs in the fib code
Date: Fri, 19 Oct 2007 18:12:26 +0400
Message-ID: <4718BB4A.7020105@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:47107 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759479AbXJSOMm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Oct 2007 10:12:42 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are places that check for CONFIG_IP_MULTIPLE_TABLES
twice in the same file, but the internals of these #ifdefs
can be merged.

As a side effect - remove one ifdef from inside a function.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index 8cadc77..ed514bf 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -185,6 +185,12 @@ static inline void fib_select_default(const struct flowi *flp, struct fib_result
 }
 
 #else /* CONFIG_IP_MULTIPLE_TABLES */
+extern void __init fib4_rules_init(void);
+
+#ifdef CONFIG_NET_CLS_ROUTE
+extern u32 fib_rules_tclass(struct fib_result *res);
+#endif
+
 #define ip_fib_local_table fib_get_table(RT_TABLE_LOCAL)
 #define ip_fib_main_table fib_get_table(RT_TABLE_MAIN)
 
@@ -214,15 +220,6 @@ extern __be32  __fib_res_prefsrc(struct fib_result *res);
 /* Exported by fib_hash.c */
 extern struct fib_table *fib_hash_init(u32 id);
 
-#ifdef CONFIG_IP_MULTIPLE_TABLES
-extern void __init fib4_rules_init(void);
-
-#ifdef CONFIG_NET_CLS_ROUTE
-extern u32 fib_rules_tclass(struct fib_result *res);
-#endif
-
-#endif
-
 static inline void fib_combine_itag(u32 *itag, struct fib_result *res)
 {
 #ifdef CONFIG_NET_CLS_ROUTE
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 78b514b..f7f0e37 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -59,6 +59,13 @@ struct fib_table *ip_fib_main_table;
 #define FIB_TABLE_HASHSZ 1
 static struct hlist_head fib_table_hash[FIB_TABLE_HASHSZ];
 
+static void __init fib4_rules_init(void)
+{
+	ip_fib_local_table = fib_hash_init(RT_TABLE_LOCAL);
+	hlist_add_head_rcu(&ip_fib_local_table->tb_hlist, &fib_table_hash[0]);
+	ip_fib_main_table  = fib_hash_init(RT_TABLE_MAIN);
+	hlist_add_head_rcu(&ip_fib_main_table->tb_hlist, &fib_table_hash[0]);
+}
 #else
 
 #define FIB_TABLE_HASHSZ 256
@@ -903,14 +910,8 @@ void __init ip_fib_init(void)
 
 	for (i = 0; i < FIB_TABLE_HASHSZ; i++)
 		INIT_HLIST_HEAD(&fib_table_hash[i]);
-#ifndef CONFIG_IP_MULTIPLE_TABLES
-	ip_fib_local_table = fib_hash_init(RT_TABLE_LOCAL);
-	hlist_add_head_rcu(&ip_fib_local_table->tb_hlist, &fib_table_hash[0]);
-	ip_fib_main_table  = fib_hash_init(RT_TABLE_MAIN);
-	hlist_add_head_rcu(&ip_fib_main_table->tb_hlist, &fib_table_hash[0]);
-#else
+
 	fib4_rules_init();
-#endif
 
 	register_netdevice_notifier(&fib_netdev_notifier);
 	register_inetaddr_notifier(&fib_inetaddr_notifier);

