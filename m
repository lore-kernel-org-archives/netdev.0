From: David Miller <davem@davemloft.net>
Subject: [PATCH 4/5] inet: Add inetpeer tree roots to the FIB tables.
Date: Mon, 11 Jun 2012 02:29:17 -0700 (PDT)
Message-ID: <20120611.022917.1505959459407636128.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41166 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751732Ab2FKJ3S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2012 05:29:18 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 3AD2558426D
	for <netdev@vger.kernel.org>; Mon, 11 Jun 2012 02:29:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/ip6_fib.h |    1 +
 include/net/ip_fib.h  |   12 +++++++-----
 net/ipv4/fib_trie.c   |    3 +++
 net/ipv6/ip6_fib.c    |    5 +++++
 4 files changed, 16 insertions(+), 5 deletions(-)

diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index 3ac5f15..a192f78 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -237,6 +237,7 @@ struct fib6_table {
 	u32			tb6_id;
 	rwlock_t		tb6_lock;
 	struct fib6_node	tb6_root;
+	struct inet_peer_base	tb6_peers;
 };
 
 #define RT6_TABLE_UNSPEC	RT_TABLE_UNSPEC
diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index 78df0866..4b347c0 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -19,6 +19,7 @@
 #include <net/flow.h>
 #include <linux/seq_file.h>
 #include <net/fib_rules.h>
+#include <net/inetpeer.h>
 
 struct fib_config {
 	u8			fc_dst_len;
@@ -157,11 +158,12 @@ extern __be32 fib_info_update_nh_saddr(struct net *net, struct fib_nh *nh);
 					 FIB_RES_SADDR(net, res))
 
 struct fib_table {
-	struct hlist_node tb_hlist;
-	u32		tb_id;
-	int		tb_default;
-	int		tb_num_default;
-	unsigned long	tb_data[0];
+	struct hlist_node	tb_hlist;
+	u32			tb_id;
+	int			tb_default;
+	int			tb_num_default;
+	struct inet_peer_base	tb_peers;
+	unsigned long		tb_data[0];
 };
 
 extern int fib_table_lookup(struct fib_table *tb, const struct flowi4 *flp,
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 18cbc15..9b0f259 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1843,6 +1843,8 @@ int fib_table_flush(struct fib_table *tb)
 	if (ll && hlist_empty(&ll->list))
 		trie_leaf_remove(t, ll);
 
+	inetpeer_invalidate_tree(&tb->tb_peers);
+
 	pr_debug("trie_flush found=%d\n", found);
 	return found;
 }
@@ -1991,6 +1993,7 @@ struct fib_table *fib_trie_table(u32 id)
 	tb->tb_id = id;
 	tb->tb_default = -1;
 	tb->tb_num_default = 0;
+	inet_peer_base_init(&tb->tb_peers);
 
 	t = (struct trie *) tb->tb_data;
 	memset(t, 0, sizeof(*t));
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 0c220a4..7ef0743 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -197,6 +197,7 @@ static struct fib6_table *fib6_alloc_table(struct net *net, u32 id)
 		table->tb6_id = id;
 		table->tb6_root.leaf = net->ipv6.ip6_null_entry;
 		table->tb6_root.fn_flags = RTN_ROOT | RTN_TL_ROOT | RTN_RTINFO;
+		inet_peer_base_init(&table->tb6_peers);
 	}
 
 	return table;
@@ -1633,6 +1634,7 @@ static int __net_init fib6_net_init(struct net *net)
 	net->ipv6.fib6_main_tbl->tb6_root.leaf = net->ipv6.ip6_null_entry;
 	net->ipv6.fib6_main_tbl->tb6_root.fn_flags =
 		RTN_ROOT | RTN_TL_ROOT | RTN_RTINFO;
+	inet_peer_base_init(&net->ipv6.fib6_main_tbl->tb6_peers);
 
 #ifdef CONFIG_IPV6_MULTIPLE_TABLES
 	net->ipv6.fib6_local_tbl = kzalloc(sizeof(*net->ipv6.fib6_local_tbl),
@@ -1643,6 +1645,7 @@ static int __net_init fib6_net_init(struct net *net)
 	net->ipv6.fib6_local_tbl->tb6_root.leaf = net->ipv6.ip6_null_entry;
 	net->ipv6.fib6_local_tbl->tb6_root.fn_flags =
 		RTN_ROOT | RTN_TL_ROOT | RTN_RTINFO;
+	inet_peer_base_init(&net->ipv6.fib6_local_tbl->tb6_peers);
 #endif
 	fib6_tables_init(net);
 
@@ -1666,8 +1669,10 @@ static void fib6_net_exit(struct net *net)
 	del_timer_sync(&net->ipv6.ip6_fib_timer);
 
 #ifdef CONFIG_IPV6_MULTIPLE_TABLES
+	inetpeer_invalidate_tree(&net->ipv6.fib6_local_tbl->tb6_peers);
 	kfree(net->ipv6.fib6_local_tbl);
 #endif
+	inetpeer_invalidate_tree(&net->ipv6.fib6_main_tbl->tb6_peers);
 	kfree(net->ipv6.fib6_main_tbl);
 	kfree(net->ipv6.fib_table_hash);
 	kfree(net->ipv6.rt6_stats);
-- 
1.7.10
