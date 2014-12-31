From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH 17/17] fib_trie: Add tracking value for suffix
 length
Date: Wed, 31 Dec 2014 10:57:08 -0800
Message-ID: <20141231185708.3006.37691.stgit@ahduyck-vm-fedora20>
References: <20141231184649.3006.29958.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37784 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751699AbaLaS5J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Dec 2014 13:57:09 -0500
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id sBVIv9FM023131
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Wed, 31 Dec 2014 13:57:09 -0500
Received: from [192.168.122.173] (ovpn-112-50.phx2.redhat.com [10.3.112.50])
	by int-mx09.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id sBVIv8fg026884
	for <netdev@vger.kernel.org>; Wed, 31 Dec 2014 13:57:08 -0500
In-Reply-To: <20141231184649.3006.29958.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change adds a tracking value for the maximum suffix length of all
prefixes stored in any given tnode.  With this value we can determine if we
need to backtrace or not based on if the suffix is greater than the pos
value.

By doing this we can reduce the CPU overhead for lookups in the local table
as many of the prefixes there are 32b long and have a suffix length of 0
meaning we can immediately backtrace to the root node without needing to
test any of the nodes between it and where we ended up.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 net/ipv4/fib_trie.c |  122 ++++++++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 116 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 87fc9a4..281e5e0 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -96,6 +96,7 @@ struct tnode {
 	t_key key;
 	unsigned char bits;		/* 2log(KEYLENGTH) bits needed */
 	unsigned char pos;		/* 2log(KEYLENGTH) bits needed */
+	unsigned char slen;
 	struct tnode __rcu *parent;
 	struct rcu_head rcu;
 	union {
@@ -311,6 +312,7 @@ static struct tnode *leaf_new(t_key key)
 		 * as the nodes are searched
 		 */
 		l->key = key;
+		l->slen = 0;
 		l->pos = 0;
 		/* set bits to 0 indicating we are not a tnode */
 		l->bits = 0;
@@ -342,6 +344,7 @@ static struct tnode *tnode_new(t_key key, int pos, int bits)
 
 	if (tn) {
 		tn->parent = NULL;
+		tn->slen = pos;
 		tn->pos = pos;
 		tn->bits = bits;
 		tn->key = (shift < KEYLENGTH) ? (key >> shift) << shift : 0;
@@ -387,6 +390,9 @@ static void put_child(struct tnode *tn, unsigned long i, struct tnode *n)
 	else if (!wasfull && isfull)
 		tn->full_children++;
 
+	if (n && (tn->slen < n->slen))
+		tn->slen = n->slen;
+
 	rcu_assign_pointer(tn->child[i], n);
 }
 
@@ -635,6 +641,41 @@ static int halve(struct trie *t, struct tnode *oldtnode)
 	return 0;
 }
 
+static unsigned char update_suffix(struct tnode *tn)
+{
+	unsigned char slen = tn->pos;
+	unsigned long stride, i;
+
+	/* search though the list of children looking for nodes that might
+	 * have a suffix greater than the one we currently have.  This is
+	 * why we start with a stride of 2 since a stride of 1 would
+	 * represent the nodes with suffix length equal to tn->pos
+	 */
+	for (i = 0, stride = 0x2ul ; i < tnode_child_length(tn); i += stride) {
+		struct tnode *n = tnode_get_child(tn, i);
+
+		if (!n || (n->slen <= slen))
+			continue;
+
+		/* update stride and slen based on new value */
+		stride <<= (n->slen - slen);
+		slen = n->slen;
+		i &= ~(stride - 1);
+
+		/* if slen covers all but the last bit we can stop here
+		 * there will be nothing longer than that since only node
+		 * 0 and 1 << (bits - 1) could have that as their suffix
+		 * length.
+		 */
+		if ((slen + 1) >= (tn->pos + tn->bits))
+			break;
+	}
+
+	tn->slen = slen;
+
+	return slen;
+}
+
 /* From "Implementing a dynamic compressed trie" by Stefan Nilsson of
  * the Helsinki University of Technology and Matti Tikkanen of Nokia
  * Telecommunications, page 6:
@@ -790,6 +831,19 @@ no_children:
 		/* drop dead node */
 		tnode_free_init(tn);
 		tnode_free(tn);
+		return;
+	}
+
+	/* Return if at least one deflate was run */
+	if (max_work != MAX_WORK)
+		return;
+
+	/* push the suffix length to the parent node */
+	if (tn->slen > tn->pos) {
+		unsigned char slen = update_suffix(tn);
+
+		if (tp && (slen > tp->slen))
+			tp->slen = slen;
 	}
 }
 
@@ -818,8 +872,58 @@ static inline struct list_head *get_fa_head(struct tnode *l, int plen)
 	return &li->falh;
 }
 
-static void insert_leaf_info(struct hlist_head *head, struct leaf_info *new)
+static void leaf_pull_suffix(struct tnode *l)
+{
+	struct tnode *tp = node_parent(l);
+
+	while (tp && (tp->slen > tp->pos) && (tp->slen > l->slen)) {
+		if (update_suffix(tp) > l->slen)
+			break;
+		tp = node_parent(tp);
+	}
+}
+
+static void leaf_push_suffix(struct tnode *l)
 {
+	struct tnode *tn = node_parent(l);
+
+	/* if this is a new leaf then tn will be NULL and we can sort
+	 * out parent suffix lengths as a part of trie_rebalance
+	 */
+	while (tn && (tn->slen < l->slen)) {
+		tn->slen = l->slen;
+		tn = node_parent(tn);
+	}
+}
+
+static void remove_leaf_info(struct tnode *l, struct leaf_info *old)
+{
+	struct hlist_node *prev;
+
+	/* record the location of the pointer to this object */
+	prev = rtnl_dereference(hlist_pprev_rcu(&old->hlist));
+
+	/* remove the leaf info from the list */
+	hlist_del_rcu(&old->hlist);
+
+	/* if we emptied the list this leaf will be freed and we can sort
+	 * out parent suffix lengths as a part of trie_rebalance
+	 */
+	if (hlist_empty(&l->list))
+		return;
+
+	/* if we removed the tail then we need to update slen */
+	if (!rcu_access_pointer(hlist_next_rcu(prev))) {
+		struct leaf_info *li = hlist_entry(prev, typeof(*li), hlist);
+
+		l->slen = KEYLENGTH - li->plen;
+		leaf_pull_suffix(l);
+	}
+}
+
+static void insert_leaf_info(struct tnode *l, struct leaf_info *new)
+{
+	struct hlist_head *head = &l->list;
 	struct leaf_info *li = NULL, *last = NULL;
 
 	if (hlist_empty(head)) {
@@ -836,6 +940,12 @@ static void insert_leaf_info(struct hlist_head *head, struct leaf_info *new)
 		else
 			hlist_add_before_rcu(&new->hlist, &li->hlist);
 	}
+
+	/* if we added to the tail node then we need to update slen */
+	if (!rcu_access_pointer(hlist_next_rcu(&new->hlist))) {
+		l->slen = KEYLENGTH - new->plen;
+		leaf_push_suffix(l);
+	}
 }
 
 /* rcu_read_lock needs to be hold by caller from readside */
@@ -925,7 +1035,7 @@ static struct list_head *fib_insert_node(struct trie *t, u32 key, int plen)
 		/* we have found a leaf. Prefixes have already been compared */
 		if (IS_LEAF(n)) {
 			/* Case 1: n is a leaf, and prefixes match*/
-			insert_leaf_info(&n->list, li);
+			insert_leaf_info(n, li);
 			return fa_head;
 		}
 
@@ -939,7 +1049,7 @@ static struct list_head *fib_insert_node(struct trie *t, u32 key, int plen)
 		return NULL;
 	}
 
-	insert_leaf_info(&l->list, li);
+	insert_leaf_info(l, li);
 
 	/* Case 2: n is a LEAF or a TNODE and the key doesn't match.
 	 *
@@ -1206,7 +1316,7 @@ int fib_table_lookup(struct fib_table *tb, const struct flowi4 *flp,
 		/* only record pn and cindex if we are going to be chopping
 		 * bits later.  Otherwise we are just wasting cycles.
 		 */
-		if (index) {
+		if (n->slen > n->pos) {
 			pn = n;
 			cindex = index;
 		}
@@ -1225,7 +1335,7 @@ int fib_table_lookup(struct fib_table *tb, const struct flowi4 *flp,
 		 * between the key and the prefix exist in the region of
 		 * the lsb and higher in the prefix.
 		 */
-		if (unlikely(prefix_mismatch(key, n)))
+		if (unlikely(prefix_mismatch(key, n)) || (n->slen == n->pos))
 			goto backtrace;
 
 		/* exit out and process leaf */
@@ -1425,7 +1535,7 @@ int fib_table_delete(struct fib_table *tb, struct fib_config *cfg)
 		tb->tb_num_default--;
 
 	if (list_empty(fa_head)) {
-		hlist_del_rcu(&li->hlist);
+		remove_leaf_info(l, li);
 		free_leaf_info(li);
 	}
 
