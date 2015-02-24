From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [RFC PATCH 06/29] fib_trie: Fib walk rcu should take a tnode and
 key instead of a trie and a leaf
Date: Tue, 24 Feb 2015 12:48:35 -0800
Message-ID: <20150224204835.26106.84691.stgit@ahduyck-vm-fedora20>
References: <20150224202837.26106.87623.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45572 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752485AbbBXUsg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Feb 2015 15:48:36 -0500
Received: from int-mx13.intmail.prod.int.phx2.redhat.com (int-mx13.intmail.prod.int.phx2.redhat.com [10.5.11.26])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id t1OKmaZH021716
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 15:48:36 -0500
Received: from [192.168.122.173] (ovpn-112-73.phx2.redhat.com [10.3.112.73])
	by int-mx13.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id t1OKmZU8030803
	for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 15:48:36 -0500
In-Reply-To: <20150224202837.26106.87623.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change makes it so that leaf_walk_rcu takes a tnode and a key instead
of the trie and a leaf.

The main idea behind this is to avoid using the leaf parent pointer as that
can have additional overhead in the future as I am trying to reduce the
size of a leaf down to 16 bytes on 64b systems and 12b on 32b systems.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 net/ipv4/fib_trie.c |  216 ++++++++++++++++++++++++++++-----------------------
 1 file changed, 120 insertions(+), 96 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 02e5126..4c82e60 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1487,71 +1487,71 @@ int fib_table_delete(struct fib_table *tb, struct fib_config *cfg)
 	return 0;
 }
 
-/* Scan for the next right leaf starting at node p->child[idx]
- * Since we have back pointer, no recursion necessary.
- */
-static struct tnode *leaf_walk_rcu(struct tnode *p, struct tnode *c)
+/* Scan for the next leaf starting at the provided key value */
+static struct tnode *leaf_walk_rcu(struct tnode **pn, t_key key)
 {
-	do {
-		unsigned long idx = c ? idx = get_index(c->key, p) + 1 : 0;
-
-		while (idx < tnode_child_length(p)) {
-			c = tnode_get_child_rcu(p, idx++);
-			if (!c)
-				continue;
-
-			if (IS_LEAF(c))
-				return c;
-
-			/* Rescan start scanning in new node */
-			p = c;
-			idx = 0;
-		}
+	struct tnode *tn = NULL, *n = *pn;
+	unsigned long cindex;
 
-		/* Node empty, walk back up to parent */
-		c = p;
-	} while ((p = node_parent_rcu(c)) != NULL);
+	/* record parent node for backtracing */
+	tn = n;
+	cindex = n ? get_index(key, n) : 0;
 
-	return NULL; /* Root of trie */
-}
+	/* this loop is meant to try and find the key in the trie */
+	while (n) {
+		unsigned long idx = get_index(key, n);
 
-static struct tnode *trie_firstleaf(struct trie *t)
-{
-	struct tnode *n = rcu_dereference_rtnl(t->trie);
+		/* guarantee forward progress on the keys */
+		if (IS_LEAF(n) && (n->key >= key))
+			goto found;
+		if (idx >> n->bits)
+			break;
 
-	if (!n)
-		return NULL;
+		/* record parent and next child index */
+		tn = n;
+		cindex = idx;
 
-	if (IS_LEAF(n))          /* trie is just a leaf */
-		return n;
+		/* descend into the next child */
+		n = tnode_get_child_rcu(tn, cindex++);
+	}
 
-	return leaf_walk_rcu(n, NULL);
-}
+	/* this loop will search for the next leaf with a greater key */
+	while (tn) {
+		/* if we exhausted the parent node we will need to climb */
+		if (cindex >> tn->bits) {
+			t_key pkey = tn->key;
 
-static struct tnode *trie_nextleaf(struct tnode *l)
-{
-	struct tnode *p = node_parent_rcu(l);
+			tn = node_parent_rcu(tn);
+			if (!tn)
+				break;
 
-	if (!p)
-		return NULL;	/* trie with just one leaf */
+			cindex = get_index(pkey, tn) + 1;
+			continue;
+		}
 
-	return leaf_walk_rcu(p, l);
-}
+		/* grab the next available node */
+		n = tnode_get_child_rcu(tn, cindex++);
+		if (!n)
+			continue;
 
-static struct tnode *trie_leafindex(struct trie *t, int index)
-{
-	struct tnode *l = trie_firstleaf(t);
+		/* no need to compare keys since we bumped the index */
+		if (IS_LEAF(n))
+			goto found;
 
-	while (l && index-- > 0)
-		l = trie_nextleaf(l);
+		/* Rescan start scanning in new node */
+		tn = n;
+		cindex = 0;
+	}
 
-	return l;
+	*pn = tn;
+	return NULL; /* Root of trie */
+found:
+	/* if we are at the limit for keys just return NULL for the tnode */
+	*pn = (n->key == KEY_MAX) ? NULL : tn;
+	return n;
 }
 
-
-/*
- * Caller must hold RTNL.
- */
+/* Caller must hold RTNL. */
 int fib_table_flush(struct fib_table *tb)
 {
 	struct trie *t = (struct trie *)tb->tb_data;
@@ -1682,42 +1682,42 @@ static int fn_trie_dump_leaf(struct tnode *l, struct fib_table *tb,
 int fib_table_dump(struct fib_table *tb, struct sk_buff *skb,
 		   struct netlink_callback *cb)
 {
-	struct tnode *l;
-	struct trie *t = (struct trie *) tb->tb_data;
-	t_key key = cb->args[2];
-	int count = cb->args[3];
-
-	rcu_read_lock();
+	struct trie *t = (struct trie *)tb->tb_data;
+	struct tnode *l, *tp;
 	/* Dump starting at last key.
 	 * Note: 0.0.0.0/0 (ie default) is first key.
 	 */
-	if (count == 0)
-		l = trie_firstleaf(t);
-	else {
-		/* Normally, continue from last key, but if that is missing
-		 * fallback to using slow rescan
-		 */
-		l = fib_find_node(t, key);
-		if (!l)
-			l = trie_leafindex(t, count);
-	}
+	int count = cb->args[2];
+	t_key key = cb->args[3];
+
+	rcu_read_lock();
 
-	while (l) {
-		cb->args[2] = l->key;
+	tp = rcu_dereference_rtnl(t->trie);
+
+	while ((l = leaf_walk_rcu(&tp, key)) != NULL) {
 		if (fn_trie_dump_leaf(l, tb, skb, cb) < 0) {
-			cb->args[3] = count;
+			cb->args[3] = key;
+			cb->args[2] = count;
 			rcu_read_unlock();
 			return -1;
 		}
 
 		++count;
-		l = trie_nextleaf(l);
+		key = l->key + 1;
+
 		memset(&cb->args[4], 0,
 		       sizeof(cb->args) - 4*sizeof(cb->args[0]));
+
+		/* stop loop if key wrapped back to 0 */
+		if (key < l->key)
+			break;
 	}
-	cb->args[3] = count;
+
 	rcu_read_unlock();
 
+	cb->args[3] = key;
+	cb->args[2] = count;
+
 	return skb->len;
 }
 
@@ -2188,31 +2188,46 @@ static const struct file_operations fib_trie_fops = {
 
 struct fib_route_iter {
 	struct seq_net_private p;
-	struct trie *main_trie;
+	struct fib_table *main_tb;
+	struct tnode *tnode;
 	loff_t	pos;
 	t_key	key;
 };
 
 static struct tnode *fib_route_get_idx(struct fib_route_iter *iter, loff_t pos)
 {
-	struct tnode *l = NULL;
-	struct trie *t = iter->main_trie;
+	struct fib_table *tb = iter->main_tb;
+	struct tnode *l, **tp = &iter->tnode;
+	struct trie *t;
+	t_key key;
 
-	/* use cache location of last found key */
-	if (iter->pos > 0 && pos >= iter->pos && (l = fib_find_node(t, iter->key)))
+	/* use cache location of next-to-find key */
+	if (iter->pos > 0 && pos >= iter->pos) {
 		pos -= iter->pos;
-	else {
+		key = iter->key;
+	} else {
+		t = (struct trie *)tb->tb_data;
+		iter->tnode = rcu_dereference_rtnl(t->trie);
 		iter->pos = 0;
-		l = trie_firstleaf(t);
+		key = 0;
 	}
 
-	while (l && pos-- > 0) {
+	while ((l = leaf_walk_rcu(tp, key)) != NULL) {
+		key = l->key + 1;
 		iter->pos++;
-		l = trie_nextleaf(l);
+
+		if (pos-- <= 0)
+			break;
+
+		l = NULL;
+
+		/* handle unlikely case of a key wrap */
+		if (!key)
+			break;
 	}
 
 	if (l)
-		iter->key = pos;	/* remember it */
+		iter->key = key;	/* remember it */
 	else
 		iter->pos = 0;		/* forget it */
 
@@ -2224,37 +2239,46 @@ static void *fib_route_seq_start(struct seq_file *seq, loff_t *pos)
 {
 	struct fib_route_iter *iter = seq->private;
 	struct fib_table *tb;
+	struct trie *t;
 
 	rcu_read_lock();
+
 	tb = fib_get_table(seq_file_net(seq), RT_TABLE_MAIN);
 	if (!tb)
 		return NULL;
 
-	iter->main_trie = (struct trie *) tb->tb_data;
-	if (*pos == 0)
-		return SEQ_START_TOKEN;
-	else
-		return fib_route_get_idx(iter, *pos - 1);
+	iter->main_tb = tb;
+
+	if (*pos != 0)
+		return fib_route_get_idx(iter, *pos);
+
+	t = (struct trie *)tb->tb_data;
+	iter->tnode = rcu_dereference_rtnl(t->trie);
+	iter->pos = 0;
+	iter->key = 0;
+
+	return SEQ_START_TOKEN;
 }
 
 static void *fib_route_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 {
 	struct fib_route_iter *iter = seq->private;
-	struct tnode *l = v;
+	struct tnode *l = NULL;
+	t_key key = iter->key;
 
 	++*pos;
-	if (v == SEQ_START_TOKEN) {
-		iter->pos = 0;
-		l = trie_firstleaf(iter->main_trie);
-	} else {
+
+	/* only allow key of 0 for start of sequence */
+	if ((v == SEQ_START_TOKEN) || key)
+		l = leaf_walk_rcu(&iter->tnode, key);
+
+	if (l) {
+		iter->key = l->key + 1;
 		iter->pos++;
-		l = trie_nextleaf(l);
+	} else {
+		iter->pos = 0;
 	}
 
-	if (l)
-		iter->key = l->key;
-	else
-		iter->pos = 0;
 	return l;
 }
 
