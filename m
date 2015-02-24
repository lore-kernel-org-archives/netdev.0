From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [RFC PATCH 28/29] fib_trie: Move slen from tnode to key vector
Date: Tue, 24 Feb 2015 12:51:02 -0800
Message-ID: <20150224205102.26106.97825.stgit@ahduyck-vm-fedora20>
References: <20150224202837.26106.87623.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46208 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753181AbbBXUvE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Feb 2015 15:51:04 -0500
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id t1OKp3O7018815
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 15:51:03 -0500
Received: from [192.168.122.173] (ovpn-112-73.phx2.redhat.com [10.3.112.73])
	by int-mx09.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id t1OKp2c3031354
	for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 15:51:02 -0500
In-Reply-To: <20150224202837.26106.87623.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change pushes the suffix length up one level.  An added advantage to
pushing the suffix length up on level is that we now only have to check the
values contained in the local tnode instead of having to peek into the
pointer for each node.

I have also added a function called get_vector.  It is meant to find the
key_vector for a given tnode within the parent array for that tnode.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 net/ipv4/fib_trie.c |   61 ++++++++++++++++++++++++++++++++++++++++-----------
 1 file changed, 48 insertions(+), 13 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 4d65f73..0953247 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -207,6 +207,13 @@ static inline unsigned long get_index(t_key key, struct key_vector *kv)
 	return index >> kv->tn_pos;
 }
 
+static inline struct key_vector *get_vector(struct key_vector *tn)
+{
+	struct key_vector *kv = node_parent(tn);
+
+	return kv + get_index(tn->key, kv);
+}
+
 /* To understand this stuff, an understanding of keys and all their bits is
  * necessary. Every node in the trie has a key associated with it, but not
  * all of the bits in that key are significant.
@@ -389,13 +396,15 @@ static void put_child(struct key_vector *tn, unsigned long i,
 				tn_info(tn)->full_children--;
 		}
 		if (tnode) {
+			struct key_vector *kv = get_vector(tn);
+
 			empty_child_dec(tn);
 			if (tnode_full(tn, tnode))
 				tn_info(tn)->full_children++;
 
 			/* update suffix length */
-			if (tn->slen < tnode->slen)
-				tn->slen = tnode->slen;
+			if (kv->slen < n->slen)
+				kv->slen = n->slen;
 		}
 
 		/* update offset to correct key_vector for update */
@@ -404,6 +413,7 @@ static void put_child(struct key_vector *tn, unsigned long i,
 
 	tn->key = n->key;
 	tn->pos = n->pos;
+	tn->slen = n->slen;
 
 	rcu_assign_pointer(tn->tnode, tnode);
 }
@@ -437,6 +447,7 @@ static void leaf_init(struct key_vector *tn, t_key key, struct key_vector *l)
 
 	/* update parent node stats */
 	if (!IS_TRIE(tn)) {
+		struct key_vector *kv = get_vector(tn);
 		unsigned long i = get_index(key, tn);
 		struct key_vector *n = get_child(tn + i);
 
@@ -447,6 +458,10 @@ static void leaf_init(struct key_vector *tn, t_key key, struct key_vector *l)
 		else if (tnode_full(tn, n))
 			tn_info(tn)->full_children--;
 
+		/* update suffix length */
+		if (kv->slen < l->slen)
+			kv->slen = l->slen;
+
 		/* update offset to correct key_vector for update */
 		tn += i;
 	}
@@ -454,6 +469,7 @@ static void leaf_init(struct key_vector *tn, t_key key, struct key_vector *l)
 	/* populate key vector */
 	tn->key = key;
 	tn->pos = 0;
+	tn->slen = l->slen;
 
 	rcu_assign_pointer(tn->tnode, l);
 }
@@ -503,7 +519,6 @@ static struct key_vector *tnode_new(struct key_vector *tn, t_key key,
 		tnode->empty_children = 1ul << bits;
 	tnode->kv[0].tn_pos = pos;
 	tnode->kv[0].bits = bits;
-	tnode->kv[0].slen = pos;
 
 	/* populate keys as though we are full of leaves */
 	for (i = (1ul << bits); i--;)
@@ -512,6 +527,7 @@ static struct key_vector *tnode_new(struct key_vector *tn, t_key key,
 	/* populate key vector */
 	tn->key = key;
 	tn->pos = pos;
+	tn->slen = pos;
 
 	rcu_assign_pointer(tn->tnode, tnode->kv);
 
@@ -862,8 +878,12 @@ static struct key_vector *collapse(struct net *net, struct trie *t,
 static unsigned char update_suffix(struct key_vector *tn)
 {
 	unsigned char slen = tn->tn_pos;
+	struct key_vector *n, *tp = tn;
 	unsigned long stride, i;
 
+	/* move tn from the tnode, up to the tnode pointer */
+	tn = get_vector(tn);
+
 	/* simply bail out if there is nothing to do */
 	if (tn->slen == slen)
 		return 0;
@@ -873,10 +893,10 @@ static unsigned char update_suffix(struct key_vector *tn)
 	 * why we start with a stride of 2 since a stride of 1 would
 	 * represent the nodes with suffix length equal to tn->tn_pos
 	 */
-	for (i = 0, stride = 0x2ul ; i < child_length(tn); i += stride) {
-		struct key_vector *n = get_child(tn + i);
+	for (i = 0, stride = 0x2ul ; i < child_length(tp); i += stride) {
+		n = tp + i;
 
-		if (!n || (n->slen <= slen))
+		if (!get_child(n) || (n->slen <= slen))
 			continue;
 
 		/* update stride and slen based on new value */
@@ -889,7 +909,7 @@ static unsigned char update_suffix(struct key_vector *tn)
 		 * 0 and 1 << (bits - 1) could have that as their suffix
 		 * length.
 		 */
-		if ((slen + 1) >= (tn->tn_pos + tn->bits))
+		if ((slen + 1) >= (tn->pos + tp->bits))
 			break;
 	}
 
@@ -1076,7 +1096,13 @@ static struct key_vector *resize(struct net *net, struct trie *t,
 
 static void leaf_pull_suffix(struct key_vector *tp, struct key_vector *l)
 {
-	while (!IS_TRIE(tp) && tp->slen > l->slen) {
+	struct key_vector *n = tp + get_index(l->key, tp);
+
+	/* update our local vector first */
+	n->slen = l->slen;
+
+	/* work our way back up the trie sorting out slen in the key vectors */
+	while (!IS_TRIE(tp)) {
 		/* if the suffix doesn't change then we are done */
 		if (update_suffix(tp))
 			break;
@@ -1087,9 +1113,19 @@ static void leaf_pull_suffix(struct key_vector *tp, struct key_vector *l)
 
 static void leaf_push_suffix(struct key_vector *tn, struct key_vector *l)
 {
+	struct key_vector *n = tn + get_index(l->key, tn);
+
+	/* update our local vector first */
+	n->slen = l->slen;
+
 	/* work our way back up the trie sorting out slen in the key vectors */
-	while (!IS_TRIE(tn) && (tn->slen < l->slen)) {
-		tn->slen = l->slen;
+	while (!IS_TRIE(tn)) {
+		n = get_vector(tn);
+
+		/* if the suffix doesn't change then we are done */
+		if (n->slen < l->slen)
+			n->slen = l->slen;
+
 		tn = node_parent(tn);
 	}
 }
@@ -1460,7 +1496,7 @@ int fib_table_lookup(struct fib_table *tb, const struct flowi4 *flp,
 		/* only record pn and cindex if we are going to be chopping
 		 * bits later.  Otherwise we are just wasting cycles.
 		 */
-		if (n->slen > tn->pos) {
+		if (tn->slen > tn->pos) {
 			pn = n;
 			cindex = index;
 		}
@@ -1479,7 +1515,7 @@ int fib_table_lookup(struct fib_table *tb, const struct flowi4 *flp,
 		 * between the key and the prefix exist in the region of
 		 * the lsb and higher in the prefix.
 		 */
-		if (unlikely(prefix_mismatch(key, tn)) || (n->slen <= tn->pos))
+		if (unlikely(prefix_mismatch(key, tn)) || (tn->slen <= tn->pos))
 			goto backtrace;
 
 		/* exit out and process leaf */
@@ -1931,7 +1967,6 @@ struct fib_table *fib_trie_table(u32 id)
 
 	t = (struct trie *) tb->tb_data;
 	t->kv[0].tn_pos = KEYLENGTH;
-	t->kv[0].slen = KEYLENGTH;
 #ifdef CONFIG_IP_FIB_TRIE_STATS
 	t->stats = alloc_percpu(struct trie_use_stats);
 	if (!t->stats) {
