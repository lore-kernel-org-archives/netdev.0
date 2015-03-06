From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH v2 08/10] fib_trie: Pull empty_children and
 full_children into tnode
Date: Fri, 06 Mar 2015 09:54:39 -0800
Message-ID: <20150306175439.2452.76468.stgit@ahduyck-vm-fedora20>
References: <20150306174814.2452.18308.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58334 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754987AbbCFRyl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Mar 2015 12:54:41 -0500
In-Reply-To: <20150306174814.2452.18308.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This pulls the information about the child array out of the key_vector and
places it in the tnode since that is where it is needed.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 net/ipv4/fib_trie.c |   31 ++++++++++++++++---------------
 1 file changed, 16 insertions(+), 15 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index b9b5bba..acbed2d 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -93,8 +93,6 @@ typedef unsigned int t_key;
 #define IS_LEAF(n) (!(n)->bits)
 
 struct key_vector {
-	t_key empty_children; /* KEYLENGTH bits needed */
-	t_key full_children;  /* KEYLENGTH bits needed */
 	struct key_vector __rcu *parent;
 
 	t_key key;
@@ -111,6 +109,8 @@ struct key_vector {
 
 struct tnode {
 	struct rcu_head rcu;
+	t_key empty_children;		/* KEYLENGTH bits needed */
+	t_key full_children;		/* KEYLENGTH bits needed */
 	struct key_vector kv[1];
 #define tn_bits kv[0].bits
 };
@@ -309,12 +309,12 @@ static struct tnode *tnode_alloc(int bits)
 
 static inline void empty_child_inc(struct key_vector *n)
 {
-	++n->empty_children ? : ++n->full_children;
+	++tn_info(n)->empty_children ? : ++tn_info(n)->full_children;
 }
 
 static inline void empty_child_dec(struct key_vector *n)
 {
-	n->empty_children-- ? : n->full_children--;
+	tn_info(n)->empty_children-- ? : tn_info(n)->full_children--;
 }
 
 static struct key_vector *leaf_new(t_key key, struct fib_alias *fa)
@@ -354,9 +354,9 @@ static struct key_vector *tnode_new(t_key key, int pos, int bits)
 		return NULL;
 
 	if (bits == KEYLENGTH)
-		tn->full_children = 1;
+		tnode->full_children = 1;
 	else
-		tn->empty_children = 1ul << bits;
+		tnode->empty_children = 1ul << bits;
 
 	tn->key = (shift < KEYLENGTH) ? (key >> shift) << shift : 0;
 	tn->pos = pos;
@@ -396,9 +396,9 @@ static void put_child(struct key_vector *tn, unsigned long i,
 	isfull = tnode_full(tn, n);
 
 	if (wasfull && !isfull)
-		tn->full_children--;
+		tn_info(tn)->full_children--;
 	else if (!wasfull && isfull)
-		tn->full_children++;
+		tn_info(tn)->full_children++;
 
 	if (n && (tn->slen < n->slen))
 		tn->slen = n->slen;
@@ -768,8 +768,8 @@ static inline bool should_inflate(struct key_vector *tp, struct key_vector *tn)
 
 	/* Keep root node larger */
 	threshold *= tp ? inflate_threshold : inflate_threshold_root;
-	used -= tn->empty_children;
-	used += tn->full_children;
+	used -= tn_info(tn)->empty_children;
+	used += tn_info(tn)->full_children;
 
 	/* if bits == KEYLENGTH then pos = 0, and will fail below */
 
@@ -783,7 +783,7 @@ static inline bool should_halve(struct key_vector *tp, struct key_vector *tn)
 
 	/* Keep root node larger */
 	threshold *= tp ? halve_threshold : halve_threshold_root;
-	used -= tn->empty_children;
+	used -= tn_info(tn)->empty_children;
 
 	/* if bits == KEYLENGTH then used = 100% on wrap, and will fail below */
 
@@ -794,10 +794,10 @@ static inline bool should_collapse(struct key_vector *tn)
 {
 	unsigned long used = child_length(tn);
 
-	used -= tn->empty_children;
+	used -= tn_info(tn)->empty_children;
 
 	/* account for bits == KEYLENGTH case */
-	if ((tn->bits == KEYLENGTH) && tn->full_children)
+	if ((tn->bits == KEYLENGTH) && tn_info(tn)->full_children)
 		used -= KEY_MAX;
 
 	/* One child or none, time to drop us from the trie */
@@ -1963,7 +1963,7 @@ static void trie_collect_stats(struct trie *t, struct trie_stat *s)
 			s->tnodes++;
 			if (n->bits < MAX_STAT_DEPTH)
 				s->nodesizes[n->bits]++;
-			s->nullpointers += n->empty_children;
+			s->nullpointers += tn_info(n)->empty_children;
 		}
 	}
 	rcu_read_unlock();
@@ -2238,7 +2238,8 @@ static int fib_trie_seq_show(struct seq_file *seq, void *v)
 		seq_indent(seq, iter->depth-1);
 		seq_printf(seq, "  +-- %pI4/%zu %u %u %u\n",
 			   &prf, KEYLENGTH - n->pos - n->bits, n->bits,
-			   n->full_children, n->empty_children);
+			   tn_info(n)->full_children,
+			   tn_info(n)->empty_children);
 	} else {
 		__be32 val = htonl(n->key);
 		struct fib_alias *fa;
