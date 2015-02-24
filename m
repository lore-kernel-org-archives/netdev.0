From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [RFC PATCH 25/29] fib_trie: Add function for dropping children from
 trie
Date: Tue, 24 Feb 2015 12:50:43 -0800
Message-ID: <20150224205043.26106.81972.stgit@ahduyck-vm-fedora20>
References: <20150224202837.26106.87623.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45764 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753099AbbBXUuo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Feb 2015 15:50:44 -0500
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id t1OKoi1x016893
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 15:50:44 -0500
Received: from [192.168.122.173] (ovpn-112-73.phx2.redhat.com [10.3.112.73])
	by int-mx11.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id t1OKohDe015447
	for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 15:50:44 -0500
In-Reply-To: <20150224202837.26106.87623.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The freeing of tnodes and leaves becomes a special case when the
key_vectors for those nodes have been pushed up to the parent.  The
handling is pretty strait forward.  A removed node will have its' pointer
set to NULL and will require suffix length to be reset to pos when the
suffix and pos values have been moved into the parent key_vector array.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 net/ipv4/fib_trie.c |   41 ++++++++++++++++++++++++++++-------------
 1 file changed, 28 insertions(+), 13 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index e91233b..a76cc6d 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -346,6 +346,27 @@ static inline int tnode_full(struct key_vector *tn, struct key_vector *n)
 	return n && ((n->pos + n->bits) == tn->pos) && IS_TNODE(n);
 }
 
+static void drop_child(struct key_vector *tn, t_key key)
+{
+	/* update parent tnode statistics */
+	if (!IS_TRIE(tn)) {
+		unsigned long i = get_index(key, tn);
+		struct key_vector *n = get_child(tn + i);
+
+		if (n) {
+			empty_child_inc(tn);
+			if (tnode_full(tn, n))
+				tn_info(tn)->full_children--;
+		}
+
+		/* update offset to correct key_vector for update */
+		tn += i;
+	}
+
+	/* clear tnode pointers */
+	RCU_INIT_POINTER(tn->tnode, NULL);
+}
+
 /* Add a child at position i overwriting the old value.
  * Update the value of full_children and empty_children.
  */
@@ -403,15 +424,6 @@ static void update_children(struct key_vector *tn)
 	}
 }
 
-static inline void put_child_root(struct key_vector *tp, t_key key,
-				  struct key_vector *n)
-{
-	if (IS_TRIE(tp))
-		rcu_assign_pointer(tp->tnode, n);
-	else
-		put_child(tp, get_index(key, tp), n);
-}
-
 static void leaf_init(struct key_vector *tn, t_key key, struct key_vector *l)
 {
 	/* link leaf to parent */
@@ -815,7 +827,10 @@ static struct key_vector *collapse(struct net *net, struct trie *t,
 			return node_parent(oldtnode);
 
 		/* compress one level */
-		put_child_root(pn, oldtnode->key, n);
+		if (IS_TRIE(pn))
+			rcu_assign_pointer(pn->tnode, n);
+		else
+			put_child(pn, get_index(oldtnode->key, pn), n);
 
 		/* drop dead node */
 		vector_replace(net, node_parent(oldtnode), pn);
@@ -826,7 +841,7 @@ static struct key_vector *collapse(struct net *net, struct trie *t,
 	}
 
 	/* no children, just update pointer to NULL */
-	put_child_root(pn, oldtnode->key, NULL);
+	drop_child(pn, oldtnode->key);
 	node_free(oldtnode);
 
 	return pn;
@@ -1565,7 +1580,7 @@ static void fib_remove_alias(struct net *net, struct trie *t,
 	 * out parent suffix lengths as a part of trie_rebalance
 	 */
 	if (hlist_empty(&l->leaf)) {
-		put_child_root(tp, l->key, NULL);
+		drop_child(tp, l->key);
 		node_free(l);
 		trie_rebalance(net, t, tp);
 		return;
@@ -1768,7 +1783,7 @@ int fib_table_flush(struct net *net, struct fib_table *tb)
 		n->slen = slen;
 
 		if (hlist_empty(&n->leaf)) {
-			put_child_root(pn, n->key, NULL);
+			drop_child(pn, n->key);
 			node_free(n);
 		} else {
 			leaf_pull_suffix(pn, n);
