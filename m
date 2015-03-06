From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH v2 06/10] fib_trie: Add tnode struct as a container
 for fields not needed in key_vector
Date: Fri, 06 Mar 2015 09:54:27 -0800
Message-ID: <20150306175427.2452.4527.stgit@ahduyck-vm-fedora20>
References: <20150306174814.2452.18308.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59751 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754061AbbCFRy3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Mar 2015 12:54:29 -0500
In-Reply-To: <20150306174814.2452.18308.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change pulls the fields not explicitly needed in the key_vector and
placed them in the new tnode structure.  By doing this we will eventually
be able to reduce the key_vector down to 16 bytes on 64 bit systems, and
12 bytes on 32 bit systems.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 net/ipv4/fib_trie.c |   72 ++++++++++++++++++++++++++++-----------------------
 1 file changed, 39 insertions(+), 33 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index b88c0d0..3a06237 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -111,7 +111,11 @@ struct key_vector {
 	};
 };
 
-#define TNODE_SIZE(n)	offsetof(struct key_vector, tnode[n])
+struct tnode {
+	struct key_vector kv[1];
+};
+
+#define TNODE_SIZE(n)	offsetof(struct tnode, kv[0].tnode[n])
 #define LEAF_SIZE	TNODE_SIZE(1)
 
 #ifdef CONFIG_IP_FIB_TRIE_STATS
@@ -288,7 +292,7 @@ static void __node_free_rcu(struct rcu_head *head)
 
 #define node_free(n) call_rcu(&n->rcu, __node_free_rcu)
 
-static struct key_vector *tnode_alloc(int bits)
+static struct tnode *tnode_alloc(int bits)
 {
 	size_t size;
 
@@ -317,48 +321,50 @@ static inline void empty_child_dec(struct key_vector *n)
 
 static struct key_vector *leaf_new(t_key key, struct fib_alias *fa)
 {
-	struct key_vector *l = kmem_cache_alloc(trie_leaf_kmem, GFP_KERNEL);
-	if (l) {
-		l->parent = NULL;
-		/* set key and pos to reflect full key value
-		 * any trailing zeros in the key should be ignored
-		 * as the nodes are searched
-		 */
-		l->key = key;
-		l->slen = fa->fa_slen;
-		l->pos = 0;
-		/* set bits to 0 indicating we are not a tnode */
-		l->bits = 0;
-
-		/* link leaf to fib alias */
-		INIT_HLIST_HEAD(&l->leaf);
-		hlist_add_head(&fa->fa_list, &l->leaf);
-	}
+	struct tnode *kv = kmem_cache_alloc(trie_leaf_kmem, GFP_KERNEL);
+	struct key_vector *l = kv->kv;
+
+	if (!kv)
+		return NULL;
+
+	/* initialize key vector */
+	l->key = key;
+	l->pos = 0;
+	l->bits = 0;
+	l->slen = fa->fa_slen;
+
+	/* link leaf to fib alias */
+	INIT_HLIST_HEAD(&l->leaf);
+	hlist_add_head(&fa->fa_list, &l->leaf);
+
 	return l;
 }
 
 static struct key_vector *tnode_new(t_key key, int pos, int bits)
 {
-	struct key_vector *tn = tnode_alloc(bits);
+	struct tnode *tnode = tnode_alloc(bits);
 	unsigned int shift = pos + bits;
+	struct key_vector *tn = tnode->kv;
 
 	/* verify bits and pos their msb bits clear and values are valid */
 	BUG_ON(!bits || (shift > KEYLENGTH));
 
-	if (tn) {
-		tn->parent = NULL;
-		tn->slen = pos;
-		tn->pos = pos;
-		tn->bits = bits;
-		tn->key = (shift < KEYLENGTH) ? (key >> shift) << shift : 0;
-		if (bits == KEYLENGTH)
-			tn->full_children = 1;
-		else
-			tn->empty_children = 1ul << bits;
-	}
-
-	pr_debug("AT %p s=%zu %zu\n", tn, TNODE_SIZE(0),
+	pr_debug("AT %p s=%zu %zu\n", tnode, TNODE_SIZE(0),
 		 sizeof(struct key_vector *) << bits);
+
+	if (!tnode)
+		return NULL;
+
+	if (bits == KEYLENGTH)
+		tn->full_children = 1;
+	else
+		tn->empty_children = 1ul << bits;
+
+	tn->key = (shift < KEYLENGTH) ? (key >> shift) << shift : 0;
+	tn->pos = pos;
+	tn->bits = bits;
+	tn->slen = pos;
+
 	return tn;
 }
 
