From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [IPV4] FIB_HASH: Reduce memory needs and speedup lookups
Date: Wed, 16 Jan 2008 07:58:24 +0100
Message-ID: <478DAB10.7030901@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060105010303090005060509"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:36946 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751172AbYAPG6l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2008 01:58:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060105010303090005060509
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi David

CONFIG_FIB_HASH=y being default configuration, we can still work on it.

Thank you

[IPV4] FIB_HASH: Reduce memory needs and speedup lookups

Currently, sizeof(struct fib_alias) is 24 or 48 bytes on 32/64 bits arches.

Because of SLAB_HWCACHE_ALIGN requirement, these are rounded to 32 and 64 
bytes respectively.

This patch moves rcu to the end of fib_alias, and conditionally defines it 
only for CONFIG_IP_FIB_TRIE.

We also remove SLAB_HWCACHE_ALIGN requirement for fib_alias and fib_node 
objects because it is not necessary.

(BTW SLUB currently denies it for objects smaller than cache_line_size() / 2,
but not SLAB)

Finally, sizeof(fib_alias) go back to 16 and 32 bytes.

Then, we can embed one fib_alias on each fib_node, to favor locality.
Most of the time access to the fib_alias will be free because one cache line
contains both the list head (fn_alias) and (one of) the list element.


Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

  net/ipv4/fib_hash.c   |   33 ++++++++++++++++++++-------------
  net/ipv4/fib_lookup.h |    4 +++-
  2 files changed, 23 insertions(+), 14 deletions(-)



--------------060105010303090005060509
Content-Type: text/plain;
 name="fib_hash.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="fib_hash.patch"

diff --git a/net/ipv4/fib_hash.c b/net/ipv4/fib_hash.c
index fe6008d..d92282d 100644
--- a/net/ipv4/fib_hash.c
+++ b/net/ipv4/fib_hash.c
@@ -52,6 +52,7 @@ struct fib_node {
 	struct hlist_node	fn_hash;
 	struct list_head	fn_alias;
 	__be32			fn_key;
+	struct fib_alias        fn_embedded_alias;
 };
 
 struct fn_zone {
@@ -193,10 +194,13 @@ static inline void fn_free_node(struct fib_node * f)
 	kmem_cache_free(fn_hash_kmem, f);
 }
 
-static inline void fn_free_alias(struct fib_alias *fa)
+static inline void fn_free_alias(struct fib_alias *fa, struct fib_node *f)
 {
 	fib_release_info(fa->fa_info);
-	kmem_cache_free(fn_alias_kmem, fa);
+	if (fa == &f->fn_embedded_alias)
+		fa->fa_info = NULL;
+	else
+		kmem_cache_free(fn_alias_kmem, fa);
 }
 
 static struct fn_zone *
@@ -473,15 +477,12 @@ static int fn_hash_insert(struct fib_table *tb, struct fib_config *cfg)
 		goto out;
 
 	err = -ENOBUFS;
-	new_fa = kmem_cache_alloc(fn_alias_kmem, GFP_KERNEL);
-	if (new_fa == NULL)
-		goto out;
 
 	new_f = NULL;
 	if (!f) {
-		new_f = kmem_cache_alloc(fn_hash_kmem, GFP_KERNEL);
+		new_f = kmem_cache_zalloc(fn_hash_kmem, GFP_KERNEL);
 		if (new_f == NULL)
-			goto out_free_new_fa;
+			goto out;
 
 		INIT_HLIST_NODE(&new_f->fn_hash);
 		INIT_LIST_HEAD(&new_f->fn_alias);
@@ -489,6 +490,12 @@ static int fn_hash_insert(struct fib_table *tb, struct fib_config *cfg)
 		f = new_f;
 	}
 
+	new_fa = &f->fn_embedded_alias;
+	if (new_fa->fa_info != NULL) {
+		new_fa = kmem_cache_alloc(fn_alias_kmem, GFP_KERNEL);
+		if (new_fa == NULL)
+			goto out_free_new_f;
+	}
 	new_fa->fa_info = fi;
 	new_fa->fa_tos = tos;
 	new_fa->fa_type = cfg->fc_type;
@@ -515,8 +522,8 @@ static int fn_hash_insert(struct fib_table *tb, struct fib_config *cfg)
 		  &cfg->fc_nlinfo, 0);
 	return 0;
 
-out_free_new_fa:
-	kmem_cache_free(fn_alias_kmem, new_fa);
+out_free_new_f:
+	kmem_cache_free(fn_hash_kmem, new_f);
 out:
 	fib_release_info(fi);
 	return err;
@@ -592,7 +599,7 @@ static int fn_hash_delete(struct fib_table *tb, struct fib_config *cfg)
 
 		if (fa->fa_state & FA_S_ACCESSED)
 			rt_cache_flush(-1);
-		fn_free_alias(fa);
+		fn_free_alias(fa, f);
 		if (kill_fn) {
 			fn_free_node(f);
 			fz->fz_nent--;
@@ -628,7 +635,7 @@ static int fn_flush_list(struct fn_zone *fz, int idx)
 				fib_hash_genid++;
 				write_unlock_bh(&fib_hash_lock);
 
-				fn_free_alias(fa);
+				fn_free_alias(fa, f);
 				found++;
 			}
 		}
@@ -749,10 +756,10 @@ static int fn_hash_dump(struct fib_table *tb, struct sk_buff *skb, struct netlin
 void __init fib_hash_init(void)
 {
 	fn_hash_kmem = kmem_cache_create("ip_fib_hash", sizeof(struct fib_node),
-					 0, SLAB_HWCACHE_ALIGN|SLAB_PANIC, NULL);
+					 0, SLAB_PANIC, NULL);
 
 	fn_alias_kmem = kmem_cache_create("ip_fib_alias", sizeof(struct fib_alias),
-					  0, SLAB_HWCACHE_ALIGN|SLAB_PANIC, NULL);
+					  0, SLAB_PANIC, NULL);
 
 }
 
diff --git a/net/ipv4/fib_lookup.h b/net/ipv4/fib_lookup.h
index 26ee66d..2c1623d 100644
--- a/net/ipv4/fib_lookup.h
+++ b/net/ipv4/fib_lookup.h
@@ -7,12 +7,14 @@
 
 struct fib_alias {
 	struct list_head	fa_list;
-	struct rcu_head rcu;
 	struct fib_info		*fa_info;
 	u8			fa_tos;
 	u8			fa_type;
 	u8			fa_scope;
 	u8			fa_state;
+#ifdef CONFIG_IP_FIB_TRIE
+	struct rcu_head		rcu;
+#endif
 };
 
 #define FA_S_ACCESSED	0x01

--------------060105010303090005060509--
