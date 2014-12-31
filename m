From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH 03/17] fib_trie: Merge tnode_free and leaf_free
 into node_free
Date: Wed, 31 Dec 2014 10:55:41 -0800
Message-ID: <20141231185541.3006.46759.stgit@ahduyck-vm-fedora20>
References: <20141231184649.3006.29958.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51065 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751576AbaLaSzm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Dec 2014 13:55:42 -0500
Received: from int-mx13.intmail.prod.int.phx2.redhat.com (int-mx13.intmail.prod.int.phx2.redhat.com [10.5.11.26])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id sBVItgRT010247
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Wed, 31 Dec 2014 13:55:42 -0500
Received: from [192.168.122.173] (ovpn-112-50.phx2.redhat.com [10.3.112.50])
	by int-mx13.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id sBVItf5Z000791
	for <netdev@vger.kernel.org>; Wed, 31 Dec 2014 13:55:42 -0500
In-Reply-To: <20141231184649.3006.29958.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Both the leaf and the tnode had an rcu_head in them, but they had them in
slightly different places.  Since we now have them in the same spot and
know that any node with bits == 0 is a leaf and the rest are either vmalloc
or kmalloc tnodes depending on the value of bits it makes it easy to combine
the functions and reduce overhead.

In addition I have taken advantage of the rcu_head pointer to go ahead and
put together a simple linked list instead of using the tnode pointer as
this way we can merge either type of structure for freeing.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 net/ipv4/fib_trie.c |   90 +++++++++++++++++++++++----------------------------
 1 file changed, 40 insertions(+), 50 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 2b72207..d1a9907 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -95,15 +95,17 @@ struct tnode {
 	unsigned char bits;		/* 2log(KEYLENGTH) bits needed */
 	unsigned char pos;		/* 2log(KEYLENGTH) bits needed */
 	struct tnode __rcu *parent;
-	union {
-		struct rcu_head rcu;
-		struct tnode *tnode_free;
-	};
+	struct rcu_head rcu;
+	/* everything above this comment must be the same as rt_trie_node */
 	unsigned int full_children;	/* KEYLENGTH bits needed */
 	unsigned int empty_children;	/* KEYLENGTH bits needed */
 	struct rt_trie_node __rcu *child[0];
 };
 
+/* This struct represents the shared bits between tnode and leaf.  If any
+ * ordering is changed here is must also be updated in tnode and leaf as
+ * well.
+ */
 struct rt_trie_node {
 	t_key key;
 	unsigned char bits;
@@ -118,6 +120,7 @@ struct leaf {
 	unsigned char pos;
 	struct tnode __rcu *parent;
 	struct rcu_head rcu;
+	/* everything above this comment must be the same as rt_trie_node */
 	struct hlist_head list;
 };
 
@@ -163,7 +166,7 @@ static struct rt_trie_node *resize(struct trie *t, struct tnode *tn);
 static struct tnode *inflate(struct trie *t, struct tnode *tn);
 static struct tnode *halve(struct trie *t, struct tnode *tn);
 /* tnodes to free after resize(); protected by RTNL */
-static struct tnode *tnode_free_head;
+static struct callback_head *tnode_free_head;
 static size_t tnode_free_size;
 
 /*
@@ -336,17 +339,23 @@ static inline void alias_free_mem_rcu(struct fib_alias *fa)
 	call_rcu(&fa->rcu, __alias_free_mem);
 }
 
-static void __leaf_free_rcu(struct rcu_head *head)
-{
-	struct leaf *l = container_of(head, struct leaf, rcu);
-	kmem_cache_free(trie_leaf_kmem, l);
-}
+#define TNODE_KMALLOC_MAX \
+	ilog2((PAGE_SIZE - sizeof(struct tnode)) / sizeof(struct rt_trie_node *))
 
-static inline void free_leaf(struct leaf *l)
+static void __node_free_rcu(struct rcu_head *head)
 {
-	call_rcu(&l->rcu, __leaf_free_rcu);
+	struct rt_trie_node *n = container_of(head, struct rt_trie_node, rcu);
+
+	if (IS_LEAF(n))
+		kmem_cache_free(trie_leaf_kmem, n);
+	else if (n->bits <= TNODE_KMALLOC_MAX)
+		kfree(n);
+	else
+		vfree(n);
 }
 
+#define node_free(n) call_rcu(&n->rcu, __node_free_rcu)
+
 static inline void free_leaf_info(struct leaf_info *leaf)
 {
 	kfree_rcu(leaf, rcu);
@@ -360,43 +369,24 @@ static struct tnode *tnode_alloc(size_t size)
 		return vzalloc(size);
 }
 
-static void __tnode_free_rcu(struct rcu_head *head)
-{
-	struct tnode *tn = container_of(head, struct tnode, rcu);
-	size_t size = sizeof(struct tnode) +
-		      (sizeof(struct rt_trie_node *) << tn->bits);
-
-	if (size <= PAGE_SIZE)
-		kfree(tn);
-	else
-		vfree(tn);
-}
-
-static inline void tnode_free(struct tnode *tn)
-{
-	if (IS_LEAF(tn))
-		free_leaf((struct leaf *) tn);
-	else
-		call_rcu(&tn->rcu, __tnode_free_rcu);
-}
-
 static void tnode_free_safe(struct tnode *tn)
 {
 	BUG_ON(IS_LEAF(tn));
-	tn->tnode_free = tnode_free_head;
-	tnode_free_head = tn;
-	tnode_free_size += sizeof(struct tnode) +
-			   (sizeof(struct rt_trie_node *) << tn->bits);
+	tn->rcu.next = tnode_free_head;
+	tnode_free_head = &tn->rcu;
 }
 
 static void tnode_free_flush(void)
 {
-	struct tnode *tn;
+	struct callback_head *head;
+
+	while ((head = tnode_free_head)) {
+		struct tnode *tn = container_of(head, struct tnode, rcu);
+
+		tnode_free_head = head->next;
+		tnode_free_size += offsetof(struct tnode, child[1 << tn->bits]);
 
-	while ((tn = tnode_free_head)) {
-		tnode_free_head = tn->tnode_free;
-		tn->tnode_free = NULL;
-		tnode_free(tn);
+		node_free(tn);
 	}
 
 	if (tnode_free_size >= PAGE_SIZE * sync_pages) {
@@ -437,7 +427,7 @@ static struct leaf_info *leaf_info_new(int plen)
 
 static struct tnode *tnode_new(t_key key, int pos, int bits)
 {
-	size_t sz = sizeof(struct tnode) + (sizeof(struct rt_trie_node *) << bits);
+	size_t sz = offsetof(struct tnode, child[1 << bits]);
 	struct tnode *tn = tnode_alloc(sz);
 	unsigned int shift = pos + bits;
 
@@ -666,15 +656,15 @@ no_children:
 
 static void tnode_clean_free(struct tnode *tn)
 {
+	struct rt_trie_node *tofree;
 	int i;
-	struct tnode *tofree;
 
 	for (i = 0; i < tnode_child_length(tn); i++) {
-		tofree = (struct tnode *)rtnl_dereference(tn->child[i]);
+		tofree = rtnl_dereference(tn->child[i]);
 		if (tofree)
-			tnode_free(tofree);
+			node_free(tofree);
 	}
-	tnode_free(tn);
+	node_free(tn);
 }
 
 static struct tnode *inflate(struct trie *t, struct tnode *tn)
@@ -717,7 +707,7 @@ static struct tnode *inflate(struct trie *t, struct tnode *tn)
 					  inode->bits - 1);
 
 			if (!right) {
-				tnode_free(left);
+				node_free(left);
 				goto nomem;
 			}
 
@@ -1068,7 +1058,7 @@ static struct list_head *fib_insert_node(struct trie *t, u32 key, int plen)
 	li = leaf_info_new(plen);
 
 	if (!li) {
-		free_leaf(l);
+		node_free(l);
 		return NULL;
 	}
 
@@ -1100,7 +1090,7 @@ static struct list_head *fib_insert_node(struct trie *t, u32 key, int plen)
 
 		if (!tn) {
 			free_leaf_info(li);
-			free_leaf(l);
+			node_free(l);
 			return NULL;
 		}
 
@@ -1580,7 +1570,7 @@ static void trie_leaf_remove(struct trie *t, struct leaf *l)
 	} else
 		RCU_INIT_POINTER(t->trie, NULL);
 
-	free_leaf(l);
+	node_free(l);
 }
 
 /*
