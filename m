From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [RFC PATCH 27/29] fib_trie: Move key and pos into key_vector from
 tnode
Date: Tue, 24 Feb 2015 12:50:56 -0800
Message-ID: <20150224205055.26106.23076.stgit@ahduyck-vm-fedora20>
References: <20150224202837.26106.87623.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45783 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753100AbbBXUu5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Feb 2015 15:50:57 -0500
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id t1OKou2S022040
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 15:50:57 -0500
Received: from [192.168.122.173] (ovpn-112-73.phx2.redhat.com [10.3.112.73])
	by int-mx09.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id t1OKoulB031323
	for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 15:50:56 -0500
In-Reply-To: <20150224202837.26106.87623.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change mmoves the pos and key values from the tnodes and leaves up one
level to their parent vectors.  We also add tn_pos as a means of
back-tracing back up through the parent node based on the key.

We do not need a copy of the key from the parent node as the key in child 0
will always be a match for the parent key as long as the bits below tn_pos
are ignored.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 net/ipv4/fib_trie.c |  124 +++++++++++++++++++++++++++++----------------------
 1 file changed, 70 insertions(+), 54 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 4a807fc..4d65f73 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -88,7 +88,7 @@
 
 typedef unsigned int t_key;
 
-#define IS_TRIE(n)	((n)->pos >= KEYLENGTH)
+#define IS_TRIE(n)	((n)->tn_pos >= KEYLENGTH)
 #define IS_TNODE(n)	((n)->bits)
 #define IS_LEAF(n)	(!(n)->bits)
 
@@ -103,6 +103,7 @@ struct key_vector {
 	unsigned char pos;		/* 2log(KEYLENGTH) bits needed */
 	unsigned char bits;		/* 2log(KEYLENGTH) bits needed */
 	unsigned char slen;
+	unsigned char tn_pos;		/* used to store tnode key info */
 };
 
 struct tnode {
@@ -200,10 +201,10 @@ static inline unsigned long get_index(t_key key, struct key_vector *kv)
 {
 	unsigned long index = key ^ kv->key;
 
-	if ((BITS_PER_LONG <= KEYLENGTH) && (KEYLENGTH == kv->pos))
+	if ((BITS_PER_LONG <= KEYLENGTH) && (KEYLENGTH == kv->tn_pos))
 		return 0;
 
-	return index >> kv->pos;
+	return index >> kv->tn_pos;
 }
 
 /* To understand this stuff, an understanding of keys and all their bits is
@@ -330,6 +331,7 @@ static struct key_vector *leaf_new(t_key key, struct fib_alias *fa)
 	l->pos = 0;
 	l->bits = 0;
 	l->slen = fa->fa_slen;
+	l->tn_pos = 0;
 
 	/* link leaf to fib alias */
 	INIT_HLIST_HEAD(&l->leaf);
@@ -343,7 +345,7 @@ static struct key_vector *leaf_new(t_key key, struct fib_alias *fa)
  */
 static inline int tnode_full(struct key_vector *tn, struct key_vector *n)
 {
-	return n && ((n->pos + n->bits) == tn->pos) && IS_TNODE(n);
+	return n && IS_TNODE(n) && ((n->tn_pos + n->bits) == tn->tn_pos);
 }
 
 static void drop_child(struct key_vector *tn, t_key key)
@@ -400,6 +402,9 @@ static void put_child(struct key_vector *tn, unsigned long i,
 		tn += i;
 	}
 
+	tn->key = n->key;
+	tn->pos = n->pos;
+
 	rcu_assign_pointer(tn->tnode, tnode);
 }
 
@@ -447,6 +452,9 @@ static void leaf_init(struct key_vector *tn, t_key key, struct key_vector *l)
 	}
 
 	/* populate key vector */
+	tn->key = key;
+	tn->pos = 0;
+
 	rcu_assign_pointer(tn->tnode, l);
 }
 
@@ -480,7 +488,7 @@ static struct key_vector *tnode_new(struct key_vector *tn, t_key key,
 			empty_child_dec(tn);
 		else if (tnode_full(tn, n))
 			tn_info(tn)->full_children--;
-		if ((pos + bits) == tn->pos)
+		if ((pos + bits) == tn->tn_pos)
 			tn_info(tn)->full_children++;
 
 		/* update offset to correct key_vector for update */
@@ -493,17 +501,18 @@ static struct key_vector *tnode_new(struct key_vector *tn, t_key key,
 		tnode->full_children = 1;
 	else
 		tnode->empty_children = 1ul << bits;
+	tnode->kv[0].tn_pos = pos;
+	tnode->kv[0].bits = bits;
+	tnode->kv[0].slen = pos;
 
 	/* populate keys as though we are full of leaves */
 	for (i = (1ul << bits); i--;)
 		tnode->kv[i].key = key + (i << pos);
 
 	/* populate key vector */
-	tnode->kv[0].pos = pos;
-	tnode->kv[0].bits = bits;
-	tnode->kv[0].slen = pos;
+	tn->key = key;
+	tn->pos = pos;
 
-	/* link parent to node */
 	rcu_assign_pointer(tn->tnode, tnode->kv);
 
 	return tnode->kv;
@@ -664,7 +673,7 @@ static struct key_vector *inflate(struct net *net, struct trie *t,
 		return NULL;
 
 	tn = tnode_new(pn, oldtnode->key,
-		       oldtnode->pos - 1, oldtnode->bits + 1);
+		       oldtnode->tn_pos - 1, oldtnode->bits + 1);
 	if (!tn)
 		goto notnode;
 
@@ -676,7 +685,7 @@ static struct key_vector *inflate(struct net *net, struct trie *t,
 	 * point to existing tnodes and the links between our allocated
 	 * nodes.
 	 */
-	for (i = child_length(oldtnode), m = 1u << tn->pos; i;) {
+	for (i = child_length(oldtnode), m = 1u << tn->tn_pos; i;) {
 		struct key_vector *inode = oldtnode + --i;
 		struct key_vector *tnode = get_child(inode);
 		struct key_vector *node0, *node1;
@@ -688,7 +697,7 @@ static struct key_vector *inflate(struct net *net, struct trie *t,
 
 		/* A leaf or an internal node with skipped bits */
 		if (!tnode_full(oldtnode, tnode)) {
-			put_child(tn, get_index(tnode->key, tn), inode);
+			put_child(tn, get_index(inode->key, tn), inode);
 			continue;
 		}
 
@@ -716,12 +725,12 @@ static struct key_vector *inflate(struct net *net, struct trie *t,
 		 * node0 and node1. So... we synthesize that bit in the
 		 * two new keys.
 		 */
-		node1 = tnode_new(tn, tnode->key | m,
-				  tnode->pos, tnode->bits - 1);
+		node1 = tnode_new(tn, inode->key | m,
+				  inode->pos, tnode->bits - 1);
 		if (!node1)
 			goto nomem;
-		node0 = tnode_new(tn, tnode->key,
-				  tnode->pos, tnode->bits - 1);
+		node0 = tnode_new(tn, inode->key,
+				  inode->pos, tnode->bits - 1);
 
 		tnode_free_append(tn, node1);
 		if (!node0)
@@ -765,7 +774,7 @@ static struct key_vector *halve(struct net *net, struct trie *t,
 		return NULL;
 
 	tn = tnode_new(pn, oldtnode->key,
-		       oldtnode->pos + 1, oldtnode->bits - 1);
+		       oldtnode->tn_pos + 1, oldtnode->bits - 1);
 	if (!tn)
 		goto notnode;
 
@@ -777,7 +786,6 @@ static struct key_vector *halve(struct net *net, struct trie *t,
 	for (i = child_length(oldtnode); i;) {
 		struct key_vector *node1 = oldtnode + --i;
 		struct key_vector *node0 = oldtnode + --i;
-		struct key_vector *tnode = get_child(node0);
 		struct key_vector *inode;
 
 		/* At least one of the children is empty */
@@ -791,7 +799,7 @@ static struct key_vector *halve(struct net *net, struct trie *t,
 		}
 
 		/* Two nonempty children */
-		inode = tnode_new(tn, tnode->key, oldtnode->pos, 1);
+		inode = tnode_new(tn, node0->key, oldtnode->tn_pos, 1);
 		if (!inode)
 			goto nomem;
 		tnode_free_append(tn, inode);
@@ -853,13 +861,17 @@ static struct key_vector *collapse(struct net *net, struct trie *t,
 
 static unsigned char update_suffix(struct key_vector *tn)
 {
-	unsigned char slen = tn->pos;
+	unsigned char slen = tn->tn_pos;
 	unsigned long stride, i;
 
+	/* simply bail out if there is nothing to do */
+	if (tn->slen == slen)
+		return 0;
+
 	/* search though the list of children looking for nodes that might
 	 * have a suffix greater than the one we currently have.  This is
 	 * why we start with a stride of 2 since a stride of 1 would
-	 * represent the nodes with suffix length equal to tn->pos
+	 * represent the nodes with suffix length equal to tn->tn_pos
 	 */
 	for (i = 0, stride = 0x2ul ; i < child_length(tn); i += stride) {
 		struct key_vector *n = get_child(tn + i);
@@ -877,11 +889,14 @@ static unsigned char update_suffix(struct key_vector *tn)
 		 * 0 and 1 << (bits - 1) could have that as their suffix
 		 * length.
 		 */
-		if ((slen + 1) >= (tn->pos + tn->bits))
+		if ((slen + 1) >= (tn->tn_pos + tn->bits))
 			break;
 	}
 
-	tn->slen = slen;
+	if (tn->slen < slen)
+		tn->slen = slen;
+	else
+		slen = 0;
 
 	return slen;
 }
@@ -955,7 +970,7 @@ static inline bool should_inflate(struct key_vector *tp, struct key_vector *tn)
 
 	/* if bits == KEYLENGTH then pos = 0, and will fail below */
 
-	return (used > 1) && tn->pos && ((50 * used) >= threshold);
+	return (used > 1) && tn->tn_pos && ((50 * used) >= threshold);
 }
 
 static inline bool should_halve(struct key_vector *tp, struct key_vector *tn)
@@ -1054,31 +1069,26 @@ static struct key_vector *resize(struct net *net, struct trie *t,
 		return tp;
 
 	/* push the suffix length to the parent node */
-	if (tn->slen > tn->pos) {
-		unsigned char slen = update_suffix(tn);
-
-		if (slen > tp->slen)
-			tp->slen = slen;
-	}
+	update_suffix(tn);
 
 	return tp;
 }
 
 static void leaf_pull_suffix(struct key_vector *tp, struct key_vector *l)
 {
-	while ((tp->slen > tp->pos) && (tp->slen > l->slen)) {
-		if (update_suffix(tp) > l->slen)
+	while (!IS_TRIE(tp) && tp->slen > l->slen) {
+		/* if the suffix doesn't change then we are done */
+		if (update_suffix(tp))
 			break;
+
 		tp = node_parent(tp);
 	}
 }
 
 static void leaf_push_suffix(struct key_vector *tn, struct key_vector *l)
 {
-	/* if this is a new leaf then tn will be NULL and we can sort
-	 * out parent suffix lengths as a part of trie_rebalance
-	 */
-	while (tn->slen < l->slen) {
+	/* work our way back up the trie sorting out slen in the key vectors */
+	while (!IS_TRIE(tn) && (tn->slen < l->slen)) {
 		tn->slen = l->slen;
 		tn = node_parent(tn);
 	}
@@ -1093,13 +1103,13 @@ static struct key_vector *fib_find_node(struct trie *t,
 
 	do {
 		*tp = n;
-		n = get_child_rcu(n + index);
+		n += index;
 
+		index = get_cindex(key, n);
+		n = get_child_rcu(n);
 		if (!n)
 			break;
 
-		index = get_cindex(key, n);
-
 		/* This bit of code is a bit tricky but it combines multiple
 		 * checks into a single check.  The prefix consists of the
 		 * prefix plus zeros for the bits in the cindex. The index
@@ -1170,7 +1180,7 @@ static struct fib_table *fib_insert_node(struct net *net, struct trie *t,
 		goto noleaf;
 
 	/* retrieve child from parent node */
-	n = get_child(tp + get_index(key, tp));
+	n = tp + get_index(key, tp);
 
 	/* Case 2: n is a LEAF or a TNODE and the key doesn't match.
 	 *
@@ -1178,13 +1188,13 @@ static struct fib_table *fib_insert_node(struct net *net, struct trie *t,
 	 *  first tnode need some special handling
 	 *  leaves us in position for handling as case 3
 	 */
-	if (n) {
+	if (get_child(n)) {
 		tn = tnode_new(tn, key, __fls(key ^ n->key), 1);
 		if (!tn)
 			goto notnode;
 
 		/* initialize routes out of node */
-		put_child(tn, get_index(key, tn) ^ 1, tp + get_index(key, tp));
+		put_child(tn, get_index(key, tn) ^ 1, n);
 
 		/* pop back out to bring tn to the same level as tp */
 		n = tn;
@@ -1410,14 +1420,15 @@ int fib_table_lookup(struct fib_table *tb, const struct flowi4 *flp,
 	struct trie_use_stats __percpu *stats = t->stats;
 #endif
 	const t_key key = ntohl(flp->daddr);
-	struct key_vector *n, *pn;
+	struct key_vector *n, *pn, *tn;
+	unsigned long cindex;
 	struct fib_alias *fa;
-	t_key cindex;
 
 	pn = t->kv;
 	cindex = 0;
 
-	n = get_child_rcu(pn);
+	tn = pn;
+	n = get_child_rcu(tn);
 	if (!n)
 		return -EAGAIN;
 
@@ -1427,7 +1438,7 @@ int fib_table_lookup(struct fib_table *tb, const struct flowi4 *flp,
 
 	/* Step 1: Travel to the longest prefix match in the trie */
 	for (;;) {
-		unsigned long index = get_cindex(key, n);
+		unsigned long index = get_cindex(key, tn);
 
 		/* This bit of code is a bit tricky but it combines multiple
 		 * checks into a single check.  The prefix consists of the
@@ -1449,12 +1460,15 @@ int fib_table_lookup(struct fib_table *tb, const struct flowi4 *flp,
 		/* only record pn and cindex if we are going to be chopping
 		 * bits later.  Otherwise we are just wasting cycles.
 		 */
-		if (n->slen > n->pos) {
+		if (n->slen > tn->pos) {
 			pn = n;
 			cindex = index;
 		}
 
-		n = get_child_rcu(n + index);
+		tn = n + index;
+
+		/* verify there is a tnode to go with the key vector */
+		n = get_child_rcu(tn);
 		if (unlikely(!n))
 			goto backtrace;
 	}
@@ -1465,7 +1479,7 @@ int fib_table_lookup(struct fib_table *tb, const struct flowi4 *flp,
 		 * between the key and the prefix exist in the region of
 		 * the lsb and higher in the prefix.
 		 */
-		if (unlikely(prefix_mismatch(key, n)) || (n->slen == n->pos))
+		if (unlikely(prefix_mismatch(key, tn)) || (n->slen <= tn->pos))
 			goto backtrace;
 
 		/* exit out and process leaf */
@@ -1477,7 +1491,9 @@ int fib_table_lookup(struct fib_table *tb, const struct flowi4 *flp,
 		 * we started this traversal anyway
 		 */
 
-		while ((n = get_child_rcu(n)) == NULL) {
+		tn = n;
+
+		while ((n = get_child_rcu(tn)) == NULL) {
 backtrace:
 #ifdef CONFIG_IP_FIB_TRIE_STATS
 			if (!n)
@@ -1509,7 +1525,7 @@ backtrace:
 			cindex &= cindex - 1;
 
 			/* grab pointer for next child node */
-			n = pn + cindex;
+			tn = pn + cindex;
 		}
 	}
 
@@ -1914,7 +1930,7 @@ struct fib_table *fib_trie_table(u32 id)
 	tb->tb_num_default = 0;
 
 	t = (struct trie *) tb->tb_data;
-	t->kv[0].pos = KEYLENGTH;
+	t->kv[0].tn_pos = KEYLENGTH;
 	t->kv[0].slen = KEYLENGTH;
 #ifdef CONFIG_IP_FIB_TRIE_STATS
 	t->stats = alloc_percpu(struct trie_use_stats);
@@ -2298,11 +2314,11 @@ static int fib_trie_seq_show(struct seq_file *seq, void *v)
 		fib_table_print(seq, iter->tb);
 
 	if (IS_TNODE(n)) {
-		__be32 prf = htonl((n->key >> n->pos) << n->pos);
+		__be32 prf = htonl((n->key >> n->tn_pos) << n->tn_pos);
 
 		seq_indent(seq, iter->depth-1);
 		seq_printf(seq, "  +-- %pI4/%zu %u %u %u\n",
-			   &prf, KEYLENGTH - n->pos - n->bits, n->bits,
+			   &prf, KEYLENGTH - n->tn_pos - n->bits, n->bits,
 			   tn_info(n)->full_children,
 			   tn_info(n)->empty_children);
 	} else {
