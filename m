From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [IPV4 1/9] fib_trie: put leaf nodes in a slab cache
Date: Tue, 22 Jan 2008 15:37:34 -0800
Message-ID: <20080122233926.690301735@linux-foundation.org>
References: <20080122233733.404145234@linux-foundation.org>
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen.hemminger@vyatta.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:33082 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756840AbYAWAJw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jan 2008 19:09:52 -0500
Content-Disposition: inline; filename=leaf-kmem-cache.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This improves locality for operations that touch all the leaves.
Save space since these entries don't need to be hardware cache aligned.

Signed-off-by: Stephen Hemminger <stephen.hemminger@vyatta.com>


--- a/net/ipv4/fib_trie.c	2008-01-21 10:16:10.000000000 -0800
+++ b/net/ipv4/fib_trie.c	2008-01-21 10:18:42.000000000 -0800
@@ -162,6 +162,7 @@ static struct tnode *halve(struct trie *
 static void tnode_free(struct tnode *tn);
 
 static struct kmem_cache *fn_alias_kmem __read_mostly;
+static struct kmem_cache *trie_leaf_kmem __read_mostly;
 
 static inline struct tnode *node_parent(struct node *node)
 {
@@ -325,7 +326,8 @@ static inline void alias_free_mem_rcu(st
 
 static void __leaf_free_rcu(struct rcu_head *head)
 {
-	kfree(container_of(head, struct leaf, rcu));
+	struct leaf *l = container_of(head, struct leaf, rcu);
+	kmem_cache_free(trie_leaf_kmem, l);
 }
 
 static void __leaf_info_free_rcu(struct rcu_head *head)
@@ -375,7 +377,7 @@ static inline void tnode_free(struct tno
 
 static struct leaf *leaf_new(void)
 {
-	struct leaf *l = kmalloc(sizeof(struct leaf),  GFP_KERNEL);
+	struct leaf *l = kmem_cache_alloc(trie_leaf_kmem, GFP_KERNEL);
 	if (l) {
 		l->parent = T_LEAF;
 		INIT_HLIST_HEAD(&l->list);
@@ -1935,7 +1937,12 @@ out:
 void __init fib_hash_init(void)
 {
 	fn_alias_kmem = kmem_cache_create("ip_fib_alias", sizeof(struct fib_alias),
-					  0, SLAB_HWCACHE_ALIGN|SLAB_PANIC, NULL);
+					  0, SLAB_PANIC, NULL);
+
+	trie_leaf_kmem = kmem_cache_create("ip_fib_trie",
+					   max(sizeof(struct leaf),
+					       sizeof(struct leaf_info)),
+					   0, SLAB_PANIC, NULL);
 }
 
 

-- 
Stephen Hemminger <stephen.hemminger@vyatta.com>

