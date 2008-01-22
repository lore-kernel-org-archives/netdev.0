From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [IPV4 6/9] fib_trie: iterator recode
Date: Tue, 22 Jan 2008 15:37:39 -0800
Message-ID: <20080122233927.068623860@linux-foundation.org>
References: <20080122233733.404145234@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:33107 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757305AbYAWAJw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jan 2008 19:09:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove the complex loop structure of nextleaf() andreplace it with a
simpler tree walker. This improves the performance and is much
cleaner.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/net/ipv4/fib_trie.c	2008-01-22 09:52:46.000000000 -0800
+++ b/net/ipv4/fib_trie.c	2008-01-22 12:58:59.000000000 -0800
@@ -1708,64 +1708,65 @@ static int trie_flush_leaf(struct trie *
 	return found;
 }
 
-/* rcu_read_lock needs to be hold by caller from readside */
-
-static struct leaf *nextleaf(struct trie *t, struct leaf *thisleaf)
+/*
+ * Scan for the next right leaf starting at node p->child[idx]
+ * Since we have back pointer, no recursion necessary.
+ */
+static struct leaf *leaf_walk_rcu(struct tnode *p, struct node *c)
 {
-	struct node *c = (struct node *) thisleaf;
-	struct tnode *p;
-	int idx;
-	struct node *trie = rcu_dereference(t->trie);
-
-	if (c == NULL) {
-		if (trie == NULL)
-			return NULL;
-
-		if (IS_LEAF(trie))          /* trie w. just a leaf */
-			return (struct leaf *) trie;
-
-		p = (struct tnode *)trie;  /* Start */
-	} else
-		p = node_parent_rcu(c);
+	do {
+		t_key idx;
 
-	while (p) {
-		int pos, last;
-
-		/*  Find the next child of the parent */
 		if (c)
-			pos = 1 + tkey_extract_bits(c->key, p->pos, p->bits);
+			idx = tkey_extract_bits(c->key, p->pos, p->bits) + 1;
 		else
-			pos = 0;
-
-		last = 1 << p->bits;
-		for (idx = pos; idx < last ; idx++) {
-			c = rcu_dereference(p->child[idx]);
+			idx = 0;
 
+		while (idx < 1u << p->bits) {
+			c = tnode_get_child_rcu(p, idx++);
 			if (!c)
 				continue;
 
-			/* Decend if tnode */
-			while (IS_TNODE(c)) {
-				p = (struct tnode *) c;
-				idx = 0;
-
-				/* Rightmost non-NULL branch */
-				if (p && IS_TNODE(p))
-					while (!(c = rcu_dereference(p->child[idx]))
-					       && idx < (1<<p->bits)) idx++;
-
-				/* Done with this tnode? */
-				if (idx >= (1 << p->bits) || !c)
-					goto up;
+			if (IS_LEAF(c)) {
+				prefetch(p->child[idx]);
+				return (struct leaf *) c;
 			}
-			return (struct leaf *) c;
+
+			/* Rescan start scanning in new node */
+			p = (struct tnode *) c;
+			idx = 0;
 		}
-up:
-		/* No more children go up one step  */
+
+		/* Node empty, walk back up to parent */
 		c = (struct node *) p;
-		p = node_parent_rcu(c);
-	}
-	return NULL; /* Ready. Root of trie */
+	} while ( (p = node_parent_rcu(c)) != NULL);
+
+	return NULL; /* Root of trie */
+}
+
+
+static struct leaf *trie_firstleaf(struct trie *t)
+{
+	struct tnode *n = (struct tnode *) rcu_dereference(t->trie);
+
+	if (!n)
+		return NULL;
+
+	if (IS_LEAF(n))          /* trie is just a leaf */
+		return (struct leaf *) n;
+
+	return leaf_walk_rcu(n, NULL);
+}
+
+static struct leaf *trie_nextleaf(struct leaf *l)
+{
+	struct node *c = (struct node *) l;
+	struct tnode *p = node_parent(c);
+
+	if (!p)
+		return NULL;	/* trie with just one leaf */
+
+	return leaf_walk_rcu(p, c);
 }
 
 /*
@@ -1775,9 +1776,9 @@ static int fn_trie_flush(struct fib_tabl
 {
 	struct trie *t = (struct trie *) tb->tb_data;
 	struct leaf *ll = NULL, *l = NULL;
-	int found = 0, h;
+	int found = 0;
 
-	for (h = 0; (l = nextleaf(t, l)) != NULL; h++) {
+	for (l = trie_firstleaf(t); l; l = trie_nextleaf(l)) {
 		found += trie_flush_leaf(t, l);
 
 		if (ll && hlist_empty(&ll->list))
@@ -1884,7 +1885,6 @@ static int fn_trie_dump_fa(t_key key, in
 			i++;
 			continue;
 		}
-		BUG_ON(!fa->fa_info);
 
 		if (fib_dump_info(skb, NETLINK_CB(cb->skb).pid,
 				  cb->nlh->nlmsg_seq,
@@ -1913,8 +1913,9 @@ static int fn_trie_dump_plen(struct trie
 	struct leaf *l = NULL;
 
 	s_h = cb->args[3];
+	h = 0;
 
-	for (h = 0; (l = nextleaf(t, l)) != NULL; h++) {
+	for (l = trie_firstleaf(t); l != NULL; h++, l = trie_nextleaf(l)) {
 		if (h < s_h)
 			continue;
 		if (h > s_h)

-- 
Stephen Hemminger <stephen.hemminger@vyatta.com>

