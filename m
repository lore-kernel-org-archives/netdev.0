From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: [PATCH 3/6] [IPV4] trie: put leaf nodes in a slab cache
Date: Mon, 14 Jan 2008 16:46:21 -0800
Message-ID: <20080114164621.2bc5011f@deepthought>
References: <20080112064646.282104074@linux-foundation.org>
	<20080112.205520.55747078.davem@davemloft.net>
	<4789A29C.6080000@linux-foundation.org>
	<20080112.214417.154179770.davem@davemloft.net>
	<20080114125755.6157a3bf@deepthought>
	<20080114164450.55f8c9b2@deepthought>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: robert.olsson@its.uu.se, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:44172 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750941AbYAOFDE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jan 2008 00:03:04 -0500
In-Reply-To: <20080114164450.55f8c9b2@deepthought>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This improves locality for operations that touch all the leaves.
Later patch will grow the size of the leaf so it becomes more
important.

Signed-off-by: Stephen Hemminger <stephen.hemminger@vyatta.com>


--- a/net/ipv4/fib_trie.c	2008-01-14 12:26:51.000000000 -0800
+++ b/net/ipv4/fib_trie.c	2008-01-14 13:41:00.000000000 -0800
@@ -162,6 +162,7 @@ static struct tnode *halve(struct trie *
 static void tnode_free(struct tnode *tn);
 
 static struct kmem_cache *fn_alias_kmem __read_mostly;
+static struct kmem_cache *trie_leaf_kmem __read_mostly;
 
 static inline struct tnode *node_parent(struct node *node)
 {
@@ -316,7 +317,8 @@ static inline void alias_free_mem_rcu(st
 
 static void __leaf_free_rcu(struct rcu_head *head)
 {
-	kfree(container_of(head, struct leaf, rcu));
+	struct leaf *leaf = container_of(head, struct leaf, rcu);
+	kmem_cache_free(trie_leaf_kmem, leaf);
 }
 
 static void __leaf_info_free_rcu(struct rcu_head *head)
@@ -366,7 +368,7 @@ static inline void tnode_free(struct tno
 
 static struct leaf *leaf_new(void)
 {
-	struct leaf *l = kmalloc(sizeof(struct leaf),  GFP_KERNEL);
+	struct leaf *l = kmem_cache_alloc(trie_leaf_kmem, GFP_KERNEL);
 	if (l) {
 		l->parent = T_LEAF;
 		INIT_HLIST_HEAD(&l->list);
@@ -1927,6 +1929,9 @@ void __init fib_hash_init(void)
 {
 	fn_alias_kmem = kmem_cache_create("ip_fib_alias", sizeof(struct fib_alias),
 					  0, SLAB_HWCACHE_ALIGN|SLAB_PANIC, NULL);
+
+	trie_leaf_kmem = kmem_cache_create("ip_fib_trie", sizeof(struct leaf),
+					   0, SLAB_HWCACHE_ALIGN|SLAB_PANIC, NULL);
 }
 
 
