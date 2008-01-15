From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: [PATCH 2/6] [IPV4] fib hash|trie initialization
Date: Mon, 14 Jan 2008 21:00:08 -0800
Message-ID: <20080114210008.784db159@deepthought>
References: <20080112064646.282104074@linux-foundation.org>
 <20080112.205520.55747078.davem@davemloft.net>
 <4789A29C.6080000@linux-foundation.org>
 <20080112.214417.154179770.davem@davemloft.net>
 <20080114125755.6157a3bf@deepthought>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, robert.olsson@its.uu.se,
	netdev@vger.kernel.org
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:44162 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750840AbYAOFCw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jan 2008 00:02:52 -0500
In-Reply-To: <20080114125755.6157a3bf@deepthought>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Initialization of the slab cache's should be done when IP is
initialized to make sure of available memory, and that code
can be marked __init.

Signed-off-by: Stephen Hemminger <stephen.hemminger@vyatta.com>


---
Applies after statistics (#1) patch for net-2.6.25

 include/net/ip_fib.h    |    5 +++--
 net/ipv4/fib_frontend.c |    9 ++++++---
 net/ipv4/fib_hash.c     |   24 +++++++++++-------------
 net/ipv4/fib_trie.c     |   16 ++++++++--------
 4 files changed, 28 insertions(+), 26 deletions(-)

--- a/include/net/ip_fib.h	2008-01-14 14:59:32.000000000 -0800
+++ b/include/net/ip_fib.h	2008-01-14 15:01:12.000000000 -0800
@@ -231,8 +231,9 @@ extern int fib_sync_down(__be32 local, s
 extern int fib_sync_up(struct net_device *dev);
 extern __be32  __fib_res_prefsrc(struct fib_result *res);
 
-/* Exported by fib_hash.c */
-extern struct fib_table *fib_hash_init(u32 id);
+/* Exported by fib_{hash|trie}.c */
+extern void fib_hash_init(void);
+extern struct fib_table *fib_hash_table(u32 id);
 
 static inline void fib_combine_itag(u32 *itag, struct fib_result *res)
 {
--- a/net/ipv4/fib_frontend.c	2008-01-14 14:59:32.000000000 -0800
+++ b/net/ipv4/fib_frontend.c	2008-01-14 15:01:12.000000000 -0800
@@ -53,11 +53,11 @@ static int __net_init fib4_rules_init(st
 {
 	struct fib_table *local_table, *main_table;
 
-	local_table = fib_hash_init(RT_TABLE_LOCAL);
+	local_table = fib_hash_table(RT_TABLE_LOCAL);
 	if (local_table == NULL)
 		return -ENOMEM;
 
-	main_table  = fib_hash_init(RT_TABLE_MAIN);
+	main_table  = fib_hash_table(RT_TABLE_MAIN);
 	if (main_table == NULL)
 		goto fail;
 
@@ -83,7 +83,8 @@ struct fib_table *fib_new_table(struct n
 	tb = fib_get_table(net, id);
 	if (tb)
 		return tb;
-	tb = fib_hash_init(id);
+
+	tb = fib_hash_table(id);
 	if (!tb)
 		return NULL;
 	h = id & (FIB_TABLE_HASHSZ - 1);
@@ -1042,6 +1043,8 @@ void __init ip_fib_init(void)
 	register_pernet_subsys(&fib_net_ops);
 	register_netdevice_notifier(&fib_netdev_notifier);
 	register_inetaddr_notifier(&fib_inetaddr_notifier);
+
+	fib_hash_init();
 }
 
 EXPORT_SYMBOL(inet_addr_type);
--- a/net/ipv4/fib_hash.c	2008-01-14 14:59:32.000000000 -0800
+++ b/net/ipv4/fib_hash.c	2008-01-14 15:01:12.000000000 -0800
@@ -746,21 +746,19 @@ static int fn_hash_dump(struct fib_table
 	return skb->len;
 }
 
-struct fib_table *fib_hash_init(u32 id)
+void __init fib_hash_init(void)
 {
-	struct fib_table *tb;
+	fn_hash_kmem = kmem_cache_create("ip_fib_hash", sizeof(struct fib_node),
+					 0, SLAB_HWCACHE_ALIGN|SLAB_PANIC, NULL);
+
+	fn_alias_kmem = kmem_cache_create("ip_fib_alias", sizeof(struct fib_alias),
+					  0, SLAB_HWCACHE_ALIGN|SLAB_PANIC, NULL);
+
+}
 
-	if (fn_hash_kmem == NULL)
-		fn_hash_kmem = kmem_cache_create("ip_fib_hash",
-						 sizeof(struct fib_node),
-						 0, SLAB_HWCACHE_ALIGN,
-						 NULL);
-
-	if (fn_alias_kmem == NULL)
-		fn_alias_kmem = kmem_cache_create("ip_fib_alias",
-						  sizeof(struct fib_alias),
-						  0, SLAB_HWCACHE_ALIGN,
-						  NULL);
+struct fib_table *fib_hash_table(u32 id)
+{
+	struct fib_table *tb;
 
 	tb = kmalloc(sizeof(struct fib_table) + sizeof(struct fn_hash),
 		     GFP_KERNEL);
--- a/net/ipv4/fib_trie.c	2008-01-14 15:01:12.000000000 -0800
+++ b/net/ipv4/fib_trie.c	2008-01-14 20:57:41.000000000 -0800
@@ -1923,19 +1923,19 @@ out:
 	return -1;
 }
 
-/* Fix more generic FIB names for init later */
+void __init fib_hash_init(void)
+{
+	fn_alias_kmem = kmem_cache_create("ip_fib_alias", sizeof(struct fib_alias),
+					  0, SLAB_HWCACHE_ALIGN|SLAB_PANIC, NULL);
+}
 
-struct fib_table *fib_hash_init(u32 id)
+
+/* Fix more generic FIB names for init later */
+struct fib_table *fib_hash_table(u32 id)
 {
 	struct fib_table *tb;
 	struct trie *t;
 
-	if (fn_alias_kmem == NULL)
-		fn_alias_kmem = kmem_cache_create("ip_fib_alias",
-						  sizeof(struct fib_alias),
-						  0, SLAB_HWCACHE_ALIGN,
-						  NULL);
-
 	tb = kmalloc(sizeof(struct fib_table) + sizeof(struct trie),
 		     GFP_KERNEL);
 	if (tb == NULL)
