From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [RFC PATCH 26/29] fib_trie: Use put_child to only copy key_vectors
 instead of pointers
Date: Tue, 24 Feb 2015 12:50:49 -0800
Message-ID: <20150224205049.26106.7222.stgit@ahduyck-vm-fedora20>
References: <20150224202837.26106.87623.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45771 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753127AbbBXUuv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Feb 2015 15:50:51 -0500
Received: from int-mx13.intmail.prod.int.phx2.redhat.com (int-mx13.intmail.prod.int.phx2.redhat.com [10.5.11.26])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id t1OKooAD022022
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 15:50:50 -0500
Received: from [192.168.122.173] (ovpn-112-73.phx2.redhat.com [10.3.112.73])
	by int-mx13.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id t1OKonFC032328
	for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 15:50:50 -0500
In-Reply-To: <20150224202837.26106.87623.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change prepares put_child to copy key_vectors from one tnode to
another.  The only consumers for this are insert, inflate, halve, and
collapse.  The general idea is to make sure the empty/full statistics for
the parent node remain correct when we copy a key_vector from one node to
another.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 net/ipv4/fib_trie.c |  102 +++++++++++++++++++++++++++------------------------
 1 file changed, 53 insertions(+), 49 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index a76cc6d..4a807fc 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -373,33 +373,34 @@ static void drop_child(struct key_vector *tn, t_key key)
 static void put_child(struct key_vector *tn, unsigned long i,
 		      struct key_vector *n)
 {
-	struct key_vector *chi = get_child(tn + i);
-	int isfull, wasfull;
+	struct key_vector *tnode = get_child(n);
 
-	BUG_ON(i >= child_length(tn));
-
-	/* update emptyChildren, overflow into fullChildren */
-	if (n == NULL && chi != NULL)
-		empty_child_inc(tn);
-	if (n != NULL && chi == NULL)
-		empty_child_dec(tn);
+	if (!IS_TRIE(tn)) {
+		struct key_vector *chi = get_child(tn + i);
 
-	/* update fullChildren */
-	wasfull = tnode_full(tn, chi);
-	isfull = tnode_full(tn, n);
+		BUG_ON(i >= child_length(tn));
 
-	if (wasfull && !isfull)
-		tn_info(tn)->full_children--;
-	else if (!wasfull && isfull)
-		tn_info(tn)->full_children++;
+		/* update emptyChildren and fullChildren */
+		if (chi) {
+			empty_child_inc(tn);
+			if (tnode_full(tn, chi))
+				tn_info(tn)->full_children--;
+		}
+		if (tnode) {
+			empty_child_dec(tn);
+			if (tnode_full(tn, tnode))
+				tn_info(tn)->full_children++;
 
-	if (n && (tn->slen < n->slen))
-		tn->slen = n->slen;
+			/* update suffix length */
+			if (tn->slen < tnode->slen)
+				tn->slen = tnode->slen;
+		}
 
-	/* update offset to correct key_vector for update */
-	tn += i;
+		/* update offset to correct key_vector for update */
+		tn += i;
+	}
 
-	rcu_assign_pointer(tn->tnode, n);
+	rcu_assign_pointer(tn->tnode, tnode);
 }
 
 static void update_children(struct key_vector *tn)
@@ -676,31 +677,32 @@ static struct key_vector *inflate(struct net *net, struct trie *t,
 	 * nodes.
 	 */
 	for (i = child_length(oldtnode), m = 1u << tn->pos; i;) {
-		struct key_vector *inode = get_child(oldtnode + --i);
+		struct key_vector *inode = oldtnode + --i;
+		struct key_vector *tnode = get_child(inode);
 		struct key_vector *node0, *node1;
 		unsigned long j, k;
 
 		/* An empty child */
-		if (inode == NULL)
+		if (!tnode)
 			continue;
 
 		/* A leaf or an internal node with skipped bits */
-		if (!tnode_full(oldtnode, inode)) {
-			put_child(tn, get_index(inode->key, tn), inode);
+		if (!tnode_full(oldtnode, tnode)) {
+			put_child(tn, get_index(tnode->key, tn), inode);
 			continue;
 		}
 
 		/* drop the node in the old tnode free list */
-		tnode_free_append(oldtnode, inode);
+		tnode_free_append(oldtnode, tnode);
 
 		/* An internal node with two children */
-		if (inode->bits == 1) {
-			put_child(tn, 2 * i + 1, get_child(inode + 1));
-			put_child(tn, 2 * i, get_child(inode));
+		if (tnode->bits == 1) {
+			put_child(tn, 2 * i + 1, tnode + 1);
+			put_child(tn, 2 * i, tnode);
 			continue;
 		}
 
-		/* We will replace this node 'inode' with two new
+		/* We will replace this node 'tnode' with two new
 		 * ones, 'node0' and 'node1', each with half of the
 		 * original children. The two new nodes will have
 		 * a position one bit further down the key and this
@@ -714,12 +716,12 @@ static struct key_vector *inflate(struct net *net, struct trie *t,
 		 * node0 and node1. So... we synthesize that bit in the
 		 * two new keys.
 		 */
-		node1 = tnode_new(tn, inode->key | m,
-				  inode->pos, inode->bits - 1);
+		node1 = tnode_new(tn, tnode->key | m,
+				  tnode->pos, tnode->bits - 1);
 		if (!node1)
 			goto nomem;
-		node0 = tnode_new(tn, inode->key,
-				  inode->pos, inode->bits - 1);
+		node0 = tnode_new(tn, tnode->key,
+				  tnode->pos, tnode->bits - 1);
 
 		tnode_free_append(tn, node1);
 		if (!node0)
@@ -727,11 +729,11 @@ static struct key_vector *inflate(struct net *net, struct trie *t,
 		tnode_free_append(tn, node0);
 
 		/* populate child pointers in new nodes */
-		for (k = child_length(inode), j = k / 2; j;) {
-			put_child(node1, --j, get_child(inode + --k));
-			put_child(node0, j, get_child(inode + j));
-			put_child(node1, --j, get_child(inode + --k));
-			put_child(node0, j, get_child(inode + j));
+		for (k = child_length(tnode), j = k / 2; j;) {
+			put_child(node1, --j, tnode + --k);
+			put_child(node0, j, tnode + j);
+			put_child(node1, --j, tnode + --k);
+			put_child(node0, j, tnode + j);
 		}
 	}
 
@@ -773,18 +775,23 @@ static struct key_vector *halve(struct net *net, struct trie *t,
 	 * nodes.
 	 */
 	for (i = child_length(oldtnode); i;) {
-		struct key_vector *node1 = get_child(oldtnode + --i);
-		struct key_vector *node0 = get_child(oldtnode + --i);
+		struct key_vector *node1 = oldtnode + --i;
+		struct key_vector *node0 = oldtnode + --i;
+		struct key_vector *tnode = get_child(node0);
 		struct key_vector *inode;
 
 		/* At least one of the children is empty */
-		if (!node1 || !node0) {
-			put_child(tn, i / 2, node1 ? : node0);
+		if (!get_child(node1)) {
+			put_child(tn, i / 2, node0);
+			continue;
+		}
+		if (!get_child(node0)) {
+			put_child(tn, i / 2, node1);
 			continue;
 		}
 
 		/* Two nonempty children */
-		inode = tnode_new(tn, node0->key, oldtnode->pos, 1);
+		inode = tnode_new(tn, tnode->key, oldtnode->pos, 1);
 		if (!inode)
 			goto nomem;
 		tnode_free_append(tn, inode);
@@ -827,10 +834,7 @@ static struct key_vector *collapse(struct net *net, struct trie *t,
 			return node_parent(oldtnode);
 
 		/* compress one level */
-		if (IS_TRIE(pn))
-			rcu_assign_pointer(pn->tnode, n);
-		else
-			put_child(pn, get_index(oldtnode->key, pn), n);
+		put_child(pn, get_index(oldtnode->key, pn), oldtnode + i);
 
 		/* drop dead node */
 		vector_replace(net, node_parent(oldtnode), pn);
@@ -1180,7 +1184,7 @@ static struct fib_table *fib_insert_node(struct net *net, struct trie *t,
 			goto notnode;
 
 		/* initialize routes out of node */
-		put_child(tn, get_index(key, tn) ^ 1, n);
+		put_child(tn, get_index(key, tn) ^ 1, tp + get_index(key, tp));
 
 		/* pop back out to bring tn to the same level as tp */
 		n = tn;
