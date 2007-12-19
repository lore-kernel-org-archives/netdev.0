From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH net-2.6.25 5/19] [IPV4] Check fib4_rules_init failure.
Date: Wed, 19 Dec 2007 18:24:35 +0300
Message-ID: <1198077889-10693-6-git-send-email-den@openvz.org>
References: <4769370F.5020303@openvz.org>
Cc: benjamin.thery@bull.net, dlezcano@fr.ibm.com, devel@openvz.org,
	containers@lists.osdl.org, netdev@vger.kernel.org, xemul@openvz.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-mipt-nat.sw.ru ([195.214.233.10]:51139 "EHLO iris"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756034AbXLSPXX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Dec 2007 10:23:23 -0500
In-Reply-To: <4769370F.5020303@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds error paths into both versions of fib4_rules_init (with/without
CONFIG_IP_MULTIPLE_TABLES) and returns error code to the caller.

Acked-by: Benjamin Thery <benjamin.thery@bull.net>
Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 include/net/ip_fib.h    |    2 +-
 net/ipv4/fib_frontend.c |   18 +++++++++++++++---
 net/ipv4/fib_rules.c    |   14 ++++++++++++--
 3 files changed, 28 insertions(+), 6 deletions(-)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index f74cbb2..cbff18d 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -186,7 +186,7 @@ static inline void fib_select_default(const struct flowi *flp, struct fib_result
 }
 
 #else /* CONFIG_IP_MULTIPLE_TABLES */
-extern void __init fib4_rules_init(void);
+extern int __init fib4_rules_init(void);
 
 #ifdef CONFIG_NET_CLS_ROUTE
 extern u32 fib_rules_tclass(struct fib_result *res);
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index b03c4c6..82d0e00 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -59,12 +59,24 @@ struct fib_table *ip_fib_main_table;
 #define FIB_TABLE_HASHSZ 1
 static struct hlist_head fib_table_hash[FIB_TABLE_HASHSZ];
 
-static void __init fib4_rules_init(void)
+static int __init fib4_rules_init(void)
 {
 	ip_fib_local_table = fib_hash_init(RT_TABLE_LOCAL);
-	hlist_add_head_rcu(&ip_fib_local_table->tb_hlist, &fib_table_hash[0]);
+	if (ip_fib_local_table == NULL)
+		return -ENOMEM;
+
 	ip_fib_main_table  = fib_hash_init(RT_TABLE_MAIN);
+	if (ip_fib_main_table == NULL)
+		goto fail;
+
+	hlist_add_head_rcu(&ip_fib_local_table->tb_hlist, &fib_table_hash[0]);
 	hlist_add_head_rcu(&ip_fib_main_table->tb_hlist, &fib_table_hash[0]);
+	return 0;
+
+fail:
+	kfree(ip_fib_local_table);
+	ip_fib_local_table = NULL;
+	return -ENOMEM;
 }
 #else
 
@@ -941,7 +953,7 @@ void __init ip_fib_init(void)
 	for (i = 0; i < FIB_TABLE_HASHSZ; i++)
 		INIT_HLIST_HEAD(&fib_table_hash[i]);
 
-	fib4_rules_init();
+	BUG_ON(fib4_rules_init());
 
 	register_netdevice_notifier(&fib_netdev_notifier);
 	register_inetaddr_notifier(&fib_inetaddr_notifier);
diff --git a/net/ipv4/fib_rules.c b/net/ipv4/fib_rules.c
index afe669d..0751734 100644
--- a/net/ipv4/fib_rules.c
+++ b/net/ipv4/fib_rules.c
@@ -311,8 +311,18 @@ static int __init fib_default_rules_init(void)
 	return 0;
 }
 
-void __init fib4_rules_init(void)
+int __init fib4_rules_init()
 {
-	BUG_ON(fib_default_rules_init());
+	int err;
+
 	fib_rules_register(&init_net, &fib4_rules_ops);
+	err = fib_default_rules_init();
+	if (err < 0)
+		goto fail;
+	return 0;
+
+fail:
+	/* also cleans all rules already added */
+	fib_rules_unregister(&init_net, &fib4_rules_ops);
+	return err;
 }
-- 
1.5.3.rc5

