From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH 6/9] fib_trie: Move rcu from key_vector to tnode,
 add accessors.
Date: Thu, 05 Mar 2015 14:51:06 -0800
Message-ID: <20150305225106.1642.31473.stgit@ahduyck-vm-fedora20>
References: <20150305224208.1642.34205.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58166 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753122AbbCEWvI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Mar 2015 17:51:08 -0500
In-Reply-To: <20150305224208.1642.34205.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RCU is only needed once for the entire node, not once per key_vector so we
can pull that out and move it to the tnode structure.

In addition add accessors to be used inside the RCU functions so that we
can more easily get from the key vector to either the tnode or the trie
pointers.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 net/ipv4/fib_trie.c |   34 ++++++++++++++++------------------
 1 file changed, 16 insertions(+), 18 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 5e1c469..a9c62f7 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -92,8 +92,6 @@ typedef unsigned int t_key;
 #define IS_LEAF(n) (!(n)->bits)
 
 struct key_vector {
-	struct rcu_head rcu;
-
 	t_key empty_children; /* KEYLENGTH bits needed */
 	t_key full_children;  /* KEYLENGTH bits needed */
 	struct key_vector __rcu *parent;
@@ -111,7 +109,9 @@ struct key_vector {
 };
 
 struct tnode {
+	struct rcu_head rcu;
 	struct key_vector kv[1];
+#define tn_bits kv[0].bits
 };
 
 #define TNODE_SIZE(n)	offsetof(struct tnode, kv[0].tnode[n])
@@ -158,6 +158,11 @@ static const int sync_pages = 128;
 static struct kmem_cache *fn_alias_kmem __read_mostly;
 static struct kmem_cache *trie_leaf_kmem __read_mostly;
 
+static inline struct tnode *tn_info(struct key_vector *kv)
+{
+	return container_of(kv, struct tnode, kv[0]);
+}
+
 /* caller must hold RTNL */
 #define node_parent(n) rtnl_dereference((n)->parent)
 #define get_child(tn, i) rtnl_dereference((tn)->tnode[i])
@@ -190,13 +195,6 @@ static inline unsigned long get_index(t_key key, struct key_vector *kv)
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
@@ -279,17 +277,17 @@ static inline void alias_free_mem_rcu(struct fib_alias *fa)
 
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
 
 static struct tnode *tnode_alloc(int bits)
 {
@@ -440,26 +438,26 @@ static inline void put_child_root(struct key_vector *tp, struct trie *t,
 
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
 		tnode_free_size += TNODE_SIZE(1ul << tn->bits);
 		node_free(tn);
 
-		tn = container_of(head, struct key_vector, rcu);
+		tn = container_of(head, struct tnode, rcu)->kv;
 	}
 
 	if (tnode_free_size >= PAGE_SIZE * sync_pages) {
