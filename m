From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: Re: [RFC 6/6] fib_trie: combine leaf and info
Date: Tue, 15 Jan 2008 09:47:53 -0800
Message-ID: <20080115094753.32e35823@deepthought>
References: <20080112064646.282104074@linux-foundation.org>
	<20080112.205520.55747078.davem@davemloft.net>
	<4789A29C.6080000@linux-foundation.org>
	<20080112.214417.154179770.davem@davemloft.net>
	<20080114125755.6157a3bf@deepthought>
	<20080114164450.55f8c9b2@deepthought>
	<20080114164621.2bc5011f@deepthought>
	<20080114164727.210047f6@deepthought>
	<20080114185843.0981f0ff@deepthought>
	<20080114210716.4b09c84d@deepthought>
	<478C4EB7.6060807@cosmosbay.com>
	<478C4FBE.5040308@cosmosbay.com>
	<20080115081905.3b8b6f05@deepthought>
	<18316.58111.211387.271534@robur.slu.se>
	<20080115182544.98c18d08.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
	David Miller <davem@davemloft.net>, robert.olsson@its.uu.se,
	netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:56296 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750971AbYAORuj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jan 2008 12:50:39 -0500
In-Reply-To: <20080115182544.98c18d08.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is how I did it:

--- a/net/ipv4/fib_trie.c	2008-01-15 09:14:53.000000000 -0800
+++ b/net/ipv4/fib_trie.c	2008-01-15 09:21:48.000000000 -0800
@@ -101,13 +101,6 @@ struct node {
 	t_key key;
 };
 
-struct leaf {
-	unsigned long parent;
-	t_key key;
-	struct hlist_head list;
-	struct rcu_head rcu;
-};
-
 struct leaf_info {
 	struct hlist_node hlist;
 	struct rcu_head rcu;
@@ -115,6 +108,13 @@ struct leaf_info {
 	struct list_head falh;
 };
 
+struct leaf {
+	unsigned long parent;
+	t_key key;
+	struct hlist_head list;
+	struct rcu_head rcu;
+};
+
 struct tnode {
 	unsigned long parent;
 	t_key key;
@@ -321,16 +321,6 @@ static void __leaf_free_rcu(struct rcu_h
 	kmem_cache_free(trie_leaf_kmem, leaf);
 }
 
-static void __leaf_info_free_rcu(struct rcu_head *head)
-{
-	kfree(container_of(head, struct leaf_info, rcu));
-}
-
-static inline void free_leaf_info(struct leaf_info *leaf)
-{
-	call_rcu(&leaf->rcu, __leaf_info_free_rcu);
-}
-
 static struct tnode *tnode_alloc(size_t size)
 {
 	struct page *pages;
@@ -357,7 +347,7 @@ static void __tnode_free_rcu(struct rcu_
 		free_pages((unsigned long)tn, get_order(size));
 }
 
-static inline void tnode_free(struct tnode *tn)
+static void tnode_free(struct tnode *tn)
 {
 	if (IS_LEAF(tn)) {
 		struct leaf *l = (struct leaf *) tn;
@@ -376,16 +366,41 @@ static struct leaf *leaf_new(void)
 	return l;
 }
 
+static void leaf_info_init(struct leaf_info *li, int plen)
+{
+	li->plen = plen;
+	INIT_LIST_HEAD(&li->falh);
+}
+
+static struct leaf_info *leaf_info_first(struct leaf *l, int plen)
+{
+	struct leaf_info *li = (struct leaf_info *) (l + 1);
+	leaf_info_init(li, plen);
+	return li;
+}
+
 static struct leaf_info *leaf_info_new(int plen)
 {
 	struct leaf_info *li = kmalloc(sizeof(struct leaf_info),  GFP_KERNEL);
-	if (li) {
-		li->plen = plen;
-		INIT_LIST_HEAD(&li->falh);
-	}
+	if (li)
+		leaf_info_init(li, plen);
+
 	return li;
 }
 
+static void __leaf_info_free_rcu(struct rcu_head *head)
+{
+	kfree(container_of(head, struct leaf_info, rcu));
+}
+
+static inline void free_leaf_info(struct leaf *l, struct leaf_info *leaf)
+{
+	if (leaf == (struct leaf_info *)(l + 1))
+		return;
+
+	call_rcu(&leaf->rcu, __leaf_info_free_rcu);
+}
+
 static struct tnode* tnode_new(t_key key, int pos, int bits)
 {
 	size_t sz = sizeof(struct tnode) + (sizeof(struct node *) << bits);
@@ -1047,18 +1062,13 @@ static struct list_head *fib_insert_node
 		insert_leaf_info(&l->list, li);
 		goto done;
 	}
-	l = leaf_new();
 
+	l = leaf_new();
 	if (!l)
 		return NULL;
 
 	l->key = key;
-	li = leaf_info_new(plen);
-
-	if (!li) {
-		tnode_free((struct tnode *) l);
-		return NULL;
-	}
+	li = leaf_info_first(l, plen);
 
 	fa_head = &li->falh;
 	insert_leaf_info(&l->list, li);
@@ -1091,7 +1101,7 @@ static struct list_head *fib_insert_node
 		}
 
 		if (!tn) {
-			free_leaf_info(li);
+			free_leaf_info(l, li);
 			tnode_free((struct tnode *) l);
 			return NULL;
 		}
@@ -1624,7 +1634,7 @@ static int fn_trie_delete(struct fib_tab
 
 	if (list_empty(fa_head)) {
 		hlist_del_rcu(&li->hlist);
-		free_leaf_info(li);
+		free_leaf_info(l, li);
 	}
 
 	if (hlist_empty(&l->list))
@@ -1668,7 +1678,7 @@ static int trie_flush_leaf(struct trie *
 
 		if (list_empty(&li->falh)) {
 			hlist_del_rcu(&li->hlist);
-			free_leaf_info(li);
+			free_leaf_info(l, li);
 		}
 	}
 	return found;
@@ -1935,7 +1945,8 @@ void __init fib_hash_init(void)
 	fn_alias_kmem = kmem_cache_create("ip_fib_alias", sizeof(struct fib_alias),
 					  0, SLAB_PANIC, NULL);
 
-	trie_leaf_kmem = kmem_cache_create("ip_fib_trie", sizeof(struct leaf),
+	trie_leaf_kmem = kmem_cache_create("ip_fib_trie",
+					   sizeof(struct leaf) + sizeof(struct leaf_info),
 					   0, SLAB_PANIC, NULL);
 }
 
