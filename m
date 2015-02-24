From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [RFC PATCH 16/29] fib_trie: Move rcu from key_vector to tnode,
 add accessors.
Date: Tue, 24 Feb 2015 12:49:42 -0800
Message-ID: <20150224204942.26106.24994.stgit@ahduyck-vm-fedora20>
References: <20150224202837.26106.87623.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59265 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752323AbbBXUto (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Feb 2015 15:49:44 -0500
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id t1OKnhIX021034
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 15:49:44 -0500
Received: from [192.168.122.173] (ovpn-112-73.phx2.redhat.com [10.3.112.73])
	by int-mx09.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id t1OKng7p030258
	for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 15:49:43 -0500
In-Reply-To: <20150224202837.26106.87623.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RCU is only needed once for the entire node, not once per key_vector so we
can pull that out and move it to the tnode structure.

In addition add accessors to be used inside the RCU functions so that we
can more easily get from the key vector to either the tnode or the trie
pointers.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 net/ipv4/fib_trie.c |   46 ++++++++++++++++++++++++++--------------------
 1 file changed, 26 insertions(+), 20 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index b1e9141..76215d7 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -92,7 +92,6 @@ typedef unsigned int t_key;
 #define IS_LEAF(n) (!(n)->bits)
 
 struct key_vector {
-	struct rcu_head rcu;
 	t_key empty_children;		/* KEYLENGTH bits needed */
 	t_key full_children;		/* KEYLENGTH bits needed */
 	struct key_vector __rcu *parent;
@@ -109,7 +108,9 @@ struct key_vector {
 };
 
 struct tnode {
+	struct rcu_head rcu;
 	struct key_vector kv[1];
+#define tn_bits kv[0].bits
 };
 
 #ifdef CONFIG_IP_FIB_TRIE_STATS
@@ -154,6 +155,18 @@ static const int sync_pages = 128;
 static struct kmem_cache *fn_alias_kmem __read_mostly;
 static struct kmem_cache *trie_leaf_kmem __read_mostly;
 
+static inline struct tnode *tn_info(struct key_vector *kv)
+{
+	return container_of(kv, struct tnode, kv[0]);
+}
+
+static inline struct fib_table *table_info(struct trie *t)
+{
+	unsigned long *tb_data = (unsigned long *)t;
+
+	return container_of(tb_data, struct fib_table, tb_data[0]);
+}
+
 /* caller must hold RTNL */
 #define node_parent(n) rtnl_dereference((n)->parent)
 #define get_child(tn, i) rtnl_dereference((tn)->tnode[i])
@@ -186,13 +199,6 @@ static inline unsigned long get_index(t_key key, struct key_vector *kv)
 	return index >> kv->pos;
 }
 
-static inline struct fib_table *trie_get_table(struct trie *t)
-{
-	unsigned long *tb_data = (unsigned long *)t;
-
-	return container_of(tb_data, struct fib_table, tb_data[0]);
-}
-
 /* To understand this stuff, an understanding of keys and all their bits is
  * necessary. Every node in the trie has a key associated with it, but not
  * all of the bits in that key are significant.
@@ -274,17 +280,17 @@ static inline void alias_free_mem_rcu(struct fib_alias *fa)
 
 static void __node_free_rcu(struct rcu_head *head)
 {
-	struct key_vector *n = container_of(head, struct key_vector, rcu);
+	struct tnode *n = container_of(head, struct tnode, rcu);
 
-	if (IS_LEAF(n))
+	if (!n->tn_bits)
 		kmem_cache_free(trie_leaf_kmem, n);
-	else if (n->bits <= TNODE_KMALLOC_MAX)
+	else if (n->tn_bits <= TNODE_KMALLOC_MAX)
 		kfree(n);
 	else
 		vfree(n);
 }
 
-#define node_free(n) call_rcu(&n->rcu, __node_free_rcu)
+#define node_free(n) call_rcu(&tn_info(n)->rcu, __node_free_rcu)
 
 static struct tnode *tnode_alloc(size_t size)
 {
@@ -427,26 +433,26 @@ static inline void put_child_root(struct key_vector *tp, struct trie *t,
 
 static inline void tnode_free_init(struct key_vector *tn)
 {
-	tn->rcu.next = NULL;
+	tn_info(tn)->rcu.next = NULL;
 }
 
 static inline void tnode_free_append(struct key_vector *tn,
 				     struct key_vector *n)
 {
-	n->rcu.next = tn->rcu.next;
-	tn->rcu.next = &n->rcu;
+	tn_info(n)->rcu.next = tn_info(tn)->rcu.next;
+	tn_info(tn)->rcu.next = &tn_info(n)->rcu;
 }
 
 static void tnode_free(struct key_vector *tn)
 {
-	struct callback_head *head = &tn->rcu;
+	struct callback_head *head = &tn_info(tn)->rcu;
 
 	while (head) {
 		head = head->next;
 		tnode_free_size += TNODE_SIZE(1 << tn->bits);
 		node_free(tn);
 
-		tn = container_of(head, struct key_vector, rcu);
+		tn = container_of(head, struct tnode, rcu)->kv;
 	}
 
 	if (tnode_free_size >= PAGE_SIZE * sync_pages) {
@@ -968,7 +974,7 @@ static struct fib_table *trie_rebalance(struct trie *t,
 		tn = container_of(cptr, struct key_vector, tnode[0]);
 	}
 
-	return trie_get_table(container_of(cptr, struct trie, tnode[0]));
+	return table_info(container_of(cptr, struct trie, tnode[0]));
 }
 
 static struct fib_table *fib_insert_node(struct trie *t,
@@ -1055,7 +1061,7 @@ static struct fib_table *fib_insert_alias(struct trie *t,
 		leaf_push_suffix(tp, l);
 	}
 
-	return trie_get_table(t);
+	return table_info(t);
 }
 
 /* Caller must hold RTNL. */
@@ -1633,7 +1639,7 @@ flush_complete:
 static void __trie_free_rcu(struct rcu_head *head)
 {
 	struct trie *t = container_of(head, struct trie, rcu);
-	struct fib_table *tb = trie_get_table(t);
+	struct fib_table *tb = table_info(t);
 
 #ifdef CONFIG_IP_FIB_TRIE_STATS
 	free_percpu(t->stats);
