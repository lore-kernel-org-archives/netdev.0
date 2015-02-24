From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [RFC PATCH 14/29] fib_trie: Rename tnode_child_length to
 child_length
Date: Tue, 24 Feb 2015 12:49:29 -0800
Message-ID: <20150224204929.26106.47615.stgit@ahduyck-vm-fedora20>
References: <20150224202837.26106.87623.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45292 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752323AbbBXUta (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Feb 2015 15:49:30 -0500
Received: from int-mx13.intmail.prod.int.phx2.redhat.com (int-mx13.intmail.prod.int.phx2.redhat.com [10.5.11.26])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id t1OKnUUT016516
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 15:49:30 -0500
Received: from [192.168.122.173] (ovpn-112-73.phx2.redhat.com [10.3.112.73])
	by int-mx13.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id t1OKnTIg031179
	for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 15:49:29 -0500
In-Reply-To: <20150224202837.26106.87623.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We are now checking the length of a key_vector instead of a tnode so it
makes sense to probably just rename this to child_length since it would
probably even be applicable to a leaf.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 net/ipv4/fib_trie.c |   53 ++++++++++++++++++++++++++++-----------------------
 1 file changed, 29 insertions(+), 24 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index d9b192b..711f8f2 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -91,8 +91,6 @@ typedef unsigned int t_key;
 #define IS_TNODE(n) ((n)->bits)
 #define IS_LEAF(n) (!(n)->bits)
 
-#define get_index(_key, _kv) (((_key) ^ (_kv)->key) >> (_kv)->pos)
-
 struct key_vector {
 	struct rcu_head rcu;
 	t_key empty_children;		/* KEYLENGTH bits needed */
@@ -172,11 +170,18 @@ static inline void node_set_parent(struct key_vector *n, struct key_vector *tp)
 /* This provides us with the number of children in this node, in the case of a
  * leaf this will return 0 meaning none of the children are accessible.
  */
-static inline unsigned long tnode_child_length(const struct key_vector *tn)
+static inline unsigned long child_length(const struct key_vector *tn)
 {
 	return (1ul << tn->bits) & ~(1ul);
 }
 
+static inline unsigned long get_index(t_key key, struct key_vector *kv)
+{
+	unsigned long index = key ^ kv->key;
+
+	return index >> kv->pos;
+}
+
 static inline struct fib_table *trie_get_table(struct trie *t)
 {
 	unsigned long *tb_data = (unsigned long *)t;
@@ -360,7 +365,7 @@ static void put_child(struct key_vector *tn, unsigned long i,
 	struct key_vector *chi = get_child(tn, i);
 	int isfull, wasfull;
 
-	BUG_ON(i >= tnode_child_length(tn));
+	BUG_ON(i >= child_length(tn));
 
 	/* update emptyChildren, overflow into fullChildren */
 	if (n == NULL && chi != NULL)
@@ -388,7 +393,7 @@ static void update_children(struct key_vector *tn)
 	unsigned long i;
 
 	/* update all of the child parent pointers */
-	for (i = tnode_child_length(tn); i;) {
+	for (i = child_length(tn); i;) {
 		struct key_vector *inode = get_child(tn, --i);
 
 		if (!inode)
@@ -467,7 +472,7 @@ static struct key_vector __rcu **replace(struct trie *t,
 	cptr = tp ? tp->tnode : t->tnode;
 
 	/* resize children now that oldtnode is freed */
-	for (i = tnode_child_length(tn); i;) {
+	for (i = child_length(tn); i;) {
 		struct key_vector *inode = get_child(tn, --i);
 
 		/* resize child node */
@@ -499,7 +504,7 @@ static struct key_vector __rcu **inflate(struct trie *t,
 	 * point to existing tnodes and the links between our allocated
 	 * nodes.
 	 */
-	for (i = tnode_child_length(oldtnode), m = 1u << tn->pos; i;) {
+	for (i = child_length(oldtnode), m = 1u << tn->pos; i;) {
 		struct key_vector *inode = get_child(oldtnode, --i);
 		struct key_vector *node0, *node1;
 		unsigned long j, k;
@@ -549,7 +554,7 @@ static struct key_vector __rcu **inflate(struct trie *t,
 		tnode_free_append(tn, node0);
 
 		/* populate child pointers in new nodes */
-		for (k = tnode_child_length(inode), j = k / 2; j;) {
+		for (k = child_length(inode), j = k / 2; j;) {
 			put_child(node1, --j, get_child(inode, --k));
 			put_child(node0, j, get_child(inode, j));
 			put_child(node1, --j, get_child(inode, --k));
@@ -594,7 +599,7 @@ static struct key_vector __rcu **halve(struct trie *t,
 	 * point to existing tnodes and the links between our allocated
 	 * nodes.
 	 */
-	for (i = tnode_child_length(oldtnode); i;) {
+	for (i = child_length(oldtnode); i;) {
 		struct key_vector *node1 = get_child(oldtnode, --i);
 		struct key_vector *node0 = get_child(oldtnode, --i);
 		struct key_vector *inode;
@@ -635,7 +640,7 @@ static void collapse(struct trie *t, struct key_vector *oldtnode)
 	unsigned long i;
 
 	/* scan the tnode looking for that one child that might still exist */
-	for (n = NULL, i = tnode_child_length(oldtnode); !n && i;)
+	for (n = NULL, i = child_length(oldtnode); !n && i;)
 		n = get_child(oldtnode, --i);
 
 	/* compress one level */
@@ -657,7 +662,7 @@ static unsigned char update_suffix(struct key_vector *tn)
 	 * why we start with a stride of 2 since a stride of 1 would
 	 * represent the nodes with suffix length equal to tn->pos
 	 */
-	for (i = 0, stride = 0x2ul ; i < tnode_child_length(tn); i += stride) {
+	for (i = 0, stride = 0x2ul ; i < child_length(tn); i += stride) {
 		struct key_vector *n = get_child(tn, i);
 
 		if (!n || (n->slen <= slen))
@@ -690,12 +695,12 @@ static unsigned char update_suffix(struct key_vector *tn)
  *
  * 'high' in this instance is the variable 'inflate_threshold'. It
  * is expressed as a percentage, so we multiply it with
- * tnode_child_length() and instead of multiplying by 2 (since the
+ * child_length() and instead of multiplying by 2 (since the
  * child array will be doubled by inflate()) and multiplying
  * the left-hand side by 100 (to handle the percentage thing) we
  * multiply the left-hand side by 50.
  *
- * The left-hand side may look a bit weird: tnode_child_length(tn)
+ * The left-hand side may look a bit weird: child_length(tn)
  * - tn->empty_children is of course the number of non-null children
  * in the current node. tn->full_children is the number of "full"
  * children, that is non-null tnodes with a skip value of 0.
@@ -705,10 +710,10 @@ static unsigned char update_suffix(struct key_vector *tn)
  * A clearer way to write this would be:
  *
  * to_be_doubled = tn->full_children;
- * not_to_be_doubled = tnode_child_length(tn) - tn->empty_children -
+ * not_to_be_doubled = child_length(tn) - tn->empty_children -
  *     tn->full_children;
  *
- * new_child_length = tnode_child_length(tn) * 2;
+ * new_child_length = child_length(tn) * 2;
  *
  * new_fill_factor = 100 * (not_to_be_doubled + 2*to_be_doubled) /
  *      new_child_length;
@@ -725,23 +730,23 @@ static unsigned char update_suffix(struct key_vector *tn)
  *      inflate_threshold * new_child_length
  *
  * expand not_to_be_doubled and to_be_doubled, and shorten:
- * 100 * (tnode_child_length(tn) - tn->empty_children +
+ * 100 * (child_length(tn) - tn->empty_children +
  *    tn->full_children) >= inflate_threshold * new_child_length
  *
  * expand new_child_length:
- * 100 * (tnode_child_length(tn) - tn->empty_children +
+ * 100 * (child_length(tn) - tn->empty_children +
  *    tn->full_children) >=
- *      inflate_threshold * tnode_child_length(tn) * 2
+ *      inflate_threshold * child_length(tn) * 2
  *
  * shorten again:
- * 50 * (tn->full_children + tnode_child_length(tn) -
+ * 50 * (tn->full_children + child_length(tn) -
  *    tn->empty_children) >= inflate_threshold *
- *    tnode_child_length(tn)
+ *    child_length(tn)
  *
  */
 static inline bool should_inflate(struct key_vector *tp, struct key_vector *tn)
 {
-	unsigned long used = tnode_child_length(tn);
+	unsigned long used = child_length(tn);
 	unsigned long threshold = used;
 
 	/* Keep root node larger */
@@ -756,7 +761,7 @@ static inline bool should_inflate(struct key_vector *tp, struct key_vector *tn)
 
 static inline bool should_halve(struct key_vector *tp, struct key_vector *tn)
 {
-	unsigned long used = tnode_child_length(tn);
+	unsigned long used = child_length(tn);
 	unsigned long threshold = used;
 
 	/* Keep root node larger */
@@ -770,7 +775,7 @@ static inline bool should_halve(struct key_vector *tp, struct key_vector *tn)
 
 static inline bool should_collapse(struct key_vector *tn)
 {
-	unsigned long used = tnode_child_length(tn);
+	unsigned long used = child_length(tn);
 
 	used -= tn->empty_children;
 
@@ -1774,7 +1779,7 @@ static struct key_vector *fib_trie_get_next(struct fib_trie_iter *iter)
 	pr_debug("get_next iter={node=%p index=%d depth=%d}\n",
 		 iter->tnode, iter->index, iter->depth);
 rescan:
-	while (cindex < tnode_child_length(tn)) {
+	while (cindex < child_length(tn)) {
 		struct key_vector *n = get_child_rcu(tn, cindex);
 
 		if (n) {
