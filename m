From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [RFC PATCH 15/29] fib_trie: Add tnode struct as a container for
 fields not needed in key_vector
Date: Tue, 24 Feb 2015 12:49:35 -0800
Message-ID: <20150224204935.26106.44779.stgit@ahduyck-vm-fedora20>
References: <20150224202837.26106.87623.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45344 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752323AbbBXUth (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Feb 2015 15:49:37 -0500
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id t1OKnbt9016555
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 15:49:37 -0500
Received: from [192.168.122.173] (ovpn-112-73.phx2.redhat.com [10.3.112.73])
	by int-mx11.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id t1OKnZLC014740
	for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 15:49:36 -0500
In-Reply-To: <20150224202837.26106.87623.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change pulls the fields not explicitly needed in the key_vector and
placed them in the new tnode structure.  By doing this we will eventually
be able to reduce the key_vector down to 16 bytes on 64 bit systems, and
12 bytes on 32 bit systems.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 net/ipv4/fib_trie.c |   87 +++++++++++++++++++++++++++------------------------
 1 file changed, 46 insertions(+), 41 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 711f8f2..b1e9141 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -108,6 +108,10 @@ struct key_vector {
 	};
 };
 
+struct tnode {
+	struct key_vector kv[1];
+};
+
 #ifdef CONFIG_IP_FIB_TRIE_STATS
 struct trie_use_stats {
 	unsigned int gets;
@@ -264,9 +268,9 @@ static inline void alias_free_mem_rcu(struct fib_alias *fa)
 	call_rcu(&fa->rcu, __alias_free_mem);
 }
 
-#define TNODE_SIZE offsetof(struct key_vector, tnode[0])
+#define TNODE_SIZE(n) offsetof(struct tnode, kv[0].tnode[n])
 #define TNODE_KMALLOC_MAX \
-	ilog2((PAGE_SIZE - TNODE_SIZE) / sizeof(struct key_vector *))
+	ilog2((PAGE_SIZE - TNODE_SIZE(0)) / sizeof(struct key_vector *))
 
 static void __node_free_rcu(struct rcu_head *head)
 {
@@ -282,7 +286,7 @@ static void __node_free_rcu(struct rcu_head *head)
 
 #define node_free(n) call_rcu(&n->rcu, __node_free_rcu)
 
-static struct key_vector *tnode_alloc(size_t size)
+static struct tnode *tnode_alloc(size_t size)
 {
 	if (size <= PAGE_SIZE)
 		return kzalloc(size, GFP_KERNEL);
@@ -302,49 +306,51 @@ static inline void empty_child_dec(struct key_vector *n)
 
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
-	size_t sz = offsetof(struct key_vector, tnode[1ul << bits]);
-	struct key_vector *tn = tnode_alloc(sz);
+	size_t sz = TNODE_SIZE(1ul << bits);
+	struct tnode *tnode = tnode_alloc(sz);
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
-	pr_debug("AT %p s=%zu %zu\n", tn, TNODE_SIZE,
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
 
@@ -437,8 +443,7 @@ static void tnode_free(struct key_vector *tn)
 
 	while (head) {
 		head = head->next;
-		tnode_free_size += offsetof(struct key_vector,
-					    tnode[1 << tn->bits]);
+		tnode_free_size += TNODE_SIZE(1 << tn->bits);
 		node_free(tn);
 
 		tn = container_of(head, struct key_vector, rcu);
@@ -1724,7 +1729,7 @@ void __init fib_trie_init(void)
 					  0, SLAB_PANIC, NULL);
 
 	trie_leaf_kmem = kmem_cache_create("ip_fib_trie",
-					   sizeof(struct key_vector),
+					   sizeof(struct tnode),
 					   0, SLAB_PANIC, NULL);
 }
 
@@ -1882,13 +1887,13 @@ static void trie_show_stats(struct seq_file *seq, struct trie_stat *stat)
 	seq_printf(seq, "\tMax depth:      %u\n", stat->maxdepth);
 
 	seq_printf(seq, "\tLeaves:         %u\n", stat->leaves);
-	bytes = sizeof(struct key_vector) * stat->leaves;
+	bytes = TNODE_SIZE(1) * stat->leaves;
 
 	seq_printf(seq, "\tPrefixes:       %u\n", stat->prefixes);
 	bytes += sizeof(struct fib_alias) * stat->prefixes;
 
 	seq_printf(seq, "\tInternal nodes: %u\n\t", stat->tnodes);
-	bytes += TNODE_SIZE * stat->tnodes;
+	bytes += TNODE_SIZE(0) * stat->tnodes;
 
 	max = MAX_STAT_DEPTH;
 	while (max > 0 && stat->nodesizes[max-1] == 0)
@@ -1957,7 +1962,7 @@ static int fib_triestat_seq_show(struct seq_file *seq, void *v)
 	seq_printf(seq,
 		   "Basic info: size of leaf:"
 		   " %Zd bytes, size of tnode: %Zd bytes.\n",
-		   sizeof(struct key_vector), TNODE_SIZE);
+		   TNODE_SIZE(1), TNODE_SIZE(0));
 
 	for (h = 0; h < FIB_TABLE_HASHSZ; h++) {
 		struct hlist_head *head = &net->ipv4.fib_table_hash[h];
