From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [RFC PATCH 09/17] fib_trie: Use unsigned long for anything dealing
 with a shift by bits
Date: Mon, 22 Dec 2014 09:41:49 -0800
Message-ID: <20141222174148.1119.29330.stgit@ahduyck-vm-fedora20>
References: <20141222172632.1119.51469.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45235 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755149AbaLVRlu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Dec 2014 12:41:50 -0500
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id sBMHfnYA023864
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Mon, 22 Dec 2014 12:41:50 -0500
Received: from [192.168.122.173] (ovpn-112-82.phx2.redhat.com [10.3.112.82])
	by int-mx09.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id sBMHfnWs016349
	for <netdev@vger.kernel.org>; Mon, 22 Dec 2014 12:41:49 -0500
In-Reply-To: <20141222172632.1119.51469.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change makes it so that anything that can be shifted by, or compared
to a value shifted by bits is updated to be an unsigned long.  This is
mostly a precaution against an insanely huge address space that somehow
starts coming close to the 2^32 root node size which would require
something like 1.5 billion addresses.

I chose unsigned long instead of unsigned long long since I do not believe
it is possible to allocate a 32 bit tnode on a 32 bit system as the memory
consumed would be 16GB + 28B which exceeds the addressible space for any
one process.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 net/ipv4/fib_trie.c |   53 +++++++++++++++++++++++++--------------------------
 1 file changed, 26 insertions(+), 27 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index d27aa27..74ad943 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -146,8 +146,8 @@ struct trie {
 #endif
 };
 
-static void tnode_put_child_reorg(struct tnode *tn, int i, struct tnode *n,
-				  int wasfull);
+static void tnode_put_child_reorg(struct tnode *tn, unsigned long i,
+				  struct tnode *n, int wasfull);
 static struct tnode *resize(struct trie *t, struct tnode *tn);
 static struct tnode *inflate(struct trie *t, struct tnode *tn);
 static struct tnode *halve(struct trie *t, struct tnode *tn);
@@ -183,25 +183,23 @@ static inline void node_set_parent(struct tnode *n, struct tnode *tp)
 /* This provides us with the number of children in this node, in the case of a
  * leaf this will return 0 meaning none of the children are accessible.
  */
-static inline int tnode_child_length(const struct tnode *tn)
+static inline unsigned long tnode_child_length(const struct tnode *tn)
 {
 	return (1ul << tn->bits) & ~(1ul);
 }
 
-/*
- * caller must hold RTNL
- */
-static inline struct tnode *tnode_get_child(const struct tnode *tn, unsigned int i)
+/* caller must hold RTNL */
+static inline struct tnode *tnode_get_child(const struct tnode *tn,
+					    unsigned long i)
 {
 	BUG_ON(i >= tnode_child_length(tn));
 
 	return rtnl_dereference(tn->child[i]);
 }
 
-/*
- * caller must hold RCU read lock or RTNL
- */
-static inline struct tnode *tnode_get_child_rcu(const struct tnode *tn, unsigned int i)
+/* caller must hold RCU read lock or RTNL */
+static inline struct tnode *tnode_get_child_rcu(const struct tnode *tn,
+						unsigned long i)
 {
 	BUG_ON(i >= tnode_child_length(tn));
 
@@ -400,7 +398,7 @@ static inline int tnode_full(const struct tnode *tn, const struct tnode *n)
 	return n && ((n->pos + n->bits) == tn->pos) && IS_TNODE(n);
 }
 
-static inline void put_child(struct tnode *tn, int i,
+static inline void put_child(struct tnode *tn, unsigned long i,
 			     struct tnode *n)
 {
 	tnode_put_child_reorg(tn, i, n, -1);
@@ -411,13 +409,13 @@ static inline void put_child(struct tnode *tn, int i,
   * Update the value of full_children and empty_children.
   */
 
-static void tnode_put_child_reorg(struct tnode *tn, int i, struct tnode *n,
-				  int wasfull)
+static void tnode_put_child_reorg(struct tnode *tn, unsigned long i,
+				  struct tnode *n, int wasfull)
 {
 	struct tnode *chi = rtnl_dereference(tn->child[i]);
 	int isfull;
 
-	BUG_ON(i >= 1<<tn->bits);
+	BUG_ON(i >= tnode_child_length(tn));
 
 	/* update emptyChildren */
 	if (n == NULL && chi != NULL)
@@ -607,10 +605,10 @@ no_children:
 static void tnode_clean_free(struct tnode *tn)
 {
 	struct tnode *tofree;
-	int i;
+	unsigned long i;
 
 	for (i = 0; i < tnode_child_length(tn); i++) {
-		tofree = rtnl_dereference(tn->child[i]);
+		tofree = tnode_get_child(tn, i);
 		if (tofree)
 			node_free(tofree);
 	}
@@ -619,10 +617,10 @@ static void tnode_clean_free(struct tnode *tn)
 
 static struct tnode *inflate(struct trie *t, struct tnode *oldtnode)
 {
-	int olen = tnode_child_length(oldtnode);
+	unsigned long olen = tnode_child_length(oldtnode);
 	struct tnode *tn;
+	unsigned long i;
 	t_key m;
-	int i;
 
 	pr_debug("In inflate\n");
 
@@ -664,7 +662,7 @@ static struct tnode *inflate(struct trie *t, struct tnode *oldtnode)
 	for (i = 0; i < olen; i++) {
 		struct tnode *inode = tnode_get_child(oldtnode, i);
 		struct tnode *left, *right;
-		int size, j;
+		unsigned long size, j;
 
 		/* An empty child */
 		if (inode == NULL)
@@ -737,7 +735,7 @@ nomem:
 
 static struct tnode *halve(struct trie *t, struct tnode *oldtnode)
 {
-	int olen = tnode_child_length(oldtnode);
+	unsigned long olen = tnode_child_length(oldtnode);
 	struct tnode *tn, *left, *right;
 	int i;
 
@@ -1528,9 +1526,9 @@ static int trie_flush_leaf(struct tnode *l)
 static struct tnode *leaf_walk_rcu(struct tnode *p, struct tnode *c)
 {
 	do {
-		t_key idx = c ? idx = get_index(c->key, p) + 1 : 0;
+		unsigned long idx = c ? idx = get_index(c->key, p) + 1 : 0;
 
-		while (idx < 1u << p->bits) {
+		while (idx < tnode_child_length(p)) {
 			c = tnode_get_child_rcu(p, idx++);
 			if (!c)
 				continue;
@@ -1782,8 +1780,8 @@ struct fib_trie_iter {
 
 static struct tnode *fib_trie_get_next(struct fib_trie_iter *iter)
 {
+	unsigned long cindex = iter->index;
 	struct tnode *tn = iter->tnode;
-	unsigned int cindex = iter->index;
 	struct tnode *p;
 
 	/* A single entry routing table */
@@ -1793,7 +1791,7 @@ static struct tnode *fib_trie_get_next(struct fib_trie_iter *iter)
 	pr_debug("get_next iter={node=%p index=%d depth=%d}\n",
 		 iter->tnode, iter->index, iter->depth);
 rescan:
-	while (cindex < (1<<tn->bits)) {
+	while (cindex < tnode_child_length(tn)) {
 		struct tnode *n = tnode_get_child_rcu(tn, cindex);
 
 		if (n) {
@@ -1870,15 +1868,16 @@ static void trie_collect_stats(struct trie *t, struct trie_stat *s)
 			hlist_for_each_entry_rcu(li, &n->list, hlist)
 				++s->prefixes;
 		} else {
-			int i;
+			unsigned long i;
 
 			s->tnodes++;
 			if (n->bits < MAX_STAT_DEPTH)
 				s->nodesizes[n->bits]++;
 
-			for (i = 0; i < tnode_child_length(n); i++)
+			for (i = 0; i < tnode_child_length(n); i++) {
 				if (!rcu_access_pointer(n->child[i]))
 					s->nullpointers++;
+			}
 		}
 	}
 	rcu_read_unlock();
