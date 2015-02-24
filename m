From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [RFC PATCH 05/29] fib_trie: Only resize N/2 times instead N *
 log(N) times in fib_table_flush
Date: Tue, 24 Feb 2015 12:48:29 -0800
Message-ID: <20150224204829.26106.22180.stgit@ahduyck-vm-fedora20>
References: <20150224202837.26106.87623.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45077 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752503AbbBXUsa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Feb 2015 15:48:30 -0500
Received: from int-mx13.intmail.prod.int.phx2.redhat.com (int-mx13.intmail.prod.int.phx2.redhat.com [10.5.11.26])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id t1OKmU6n018062
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 15:48:30 -0500
Received: from [192.168.122.173] (ovpn-112-73.phx2.redhat.com [10.3.112.73])
	by int-mx13.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id t1OKmTji030779
	for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 15:48:29 -0500
In-Reply-To: <20150224202837.26106.87623.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change makes it so that we only call resize on the tnodes, instead of
from each of the leaves.  By doing this we can significantly reduce the
time spent flushing the trie as we don't call trie rebalance and have it
walk up the trie with each removed leaf.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 net/ipv4/fib_trie.c |  141 ++++++++++++++++++++++++++++-----------------------
 1 file changed, 78 insertions(+), 63 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 8896617..02e5126 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1402,25 +1402,6 @@ found:
 EXPORT_SYMBOL_GPL(fib_table_lookup);
 
 /*
- * Remove the leaf and return parent.
- */
-static void trie_leaf_remove(struct trie *t, struct tnode *l)
-{
-	struct tnode *tp = node_parent(l);
-
-	pr_debug("entering trie_leaf_remove(%p)\n", l);
-
-	if (tp) {
-		put_child(tp, get_index(l->key, tp), NULL);
-		trie_rebalance(t, tp);
-	} else {
-		RCU_INIT_POINTER(t->trie, NULL);
-	}
-
-	node_free(l);
-}
-
-/*
  * Caller must hold RTNL.
  */
 int fib_table_delete(struct fib_table *tb, struct fib_config *cfg)
@@ -1485,8 +1466,18 @@ int fib_table_delete(struct fib_table *tb, struct fib_config *cfg)
 	if (!plen)
 		tb->tb_num_default--;
 
-	if (hlist_empty(&l->leaf))
-		trie_leaf_remove(t, l);
+	if (hlist_empty(&l->leaf)) {
+		struct tnode *tp = node_parent(l);
+
+		if (tp) {
+			put_child(tp, get_index(l->key, tp), NULL);
+			trie_rebalance(t, tp);
+		} else {
+			RCU_INIT_POINTER(t->trie, NULL);
+		}
+
+		node_free(l);
+	}
 
 	if (fa->fa_state & FA_S_ACCESSED)
 		rt_cache_flush(cfg->fc_nlinfo.nl_net);
@@ -1496,33 +1487,6 @@ int fib_table_delete(struct fib_table *tb, struct fib_config *cfg)
 	return 0;
 }
 
-static int trie_flush_leaf(struct tnode *l)
-{
-	struct hlist_node *tmp;
-	unsigned char slen = 0;
-	struct fib_alias *fa;
-	int found = 0;
-
-	hlist_for_each_entry_safe(fa, tmp, &l->leaf, fa_list) {
-		struct fib_info *fi = fa->fa_info;
-
-		if (fi && (fi->fib_flags & RTNH_F_DEAD)) {
-			hlist_del_rcu(&fa->fa_list);
-			fib_release_info(fa->fa_info);
-			alias_free_mem_rcu(fa);
-			found++;
-
-			continue;
-		}
-
-		slen = fa->fa_slen;
-	}
-
-	l->slen = slen;
-
-	return found;
-}
-
 /* Scan for the next right leaf starting at node p->child[idx]
  * Since we have back pointer, no recursion necessary.
  */
@@ -1590,30 +1554,81 @@ static struct tnode *trie_leafindex(struct trie *t, int index)
  */
 int fib_table_flush(struct fib_table *tb)
 {
-	struct trie *t = (struct trie *) tb->tb_data;
-	struct tnode *l, *ll = NULL;
+	struct trie *t = (struct trie *)tb->tb_data;
+	struct hlist_node *tmp;
+	struct fib_alias *fa;
+	struct tnode *n, *pn;
+	unsigned long cindex;
+	unsigned char slen;
 	int found = 0;
 
-	for (l = trie_firstleaf(t); l; l = trie_nextleaf(l)) {
-		found += trie_flush_leaf(l);
+	n = rcu_dereference(t->trie);
+	if (!n)
+		goto flush_complete;
+
+	pn = NULL;
+	cindex = 0;
+
+	while (IS_TNODE(n)) {
+		/* record pn and cindex for leaf walking */
+		pn = n;
+		cindex = 1ul << n->bits;
+backtrace:
+		/* walk trie in reverse order */
+		do {
+			while (!(cindex--)) {
+				t_key pkey = pn->key;
+
+				n = pn;
+				pn = node_parent(n);
+
+				/* resize completed node */
+				resize(t, n);
+
+				/* if we got the root we are done */
+				if (!pn)
+					goto flush_complete;
 
-		if (ll) {
-			if (hlist_empty(&ll->leaf))
-				trie_leaf_remove(t, ll);
-			else
-				leaf_pull_suffix(ll);
+				cindex = get_index(pkey, pn);
+			}
+
+			/* grab the next available node */
+			n = tnode_get_child(pn, cindex);
+		} while (!n);
+	}
+
+	/* track slen in case any prefixes survive */
+	slen = 0;
+
+	hlist_for_each_entry_safe(fa, tmp, &n->leaf, fa_list) {
+		struct fib_info *fi = fa->fa_info;
+
+		if (fi && (fi->fib_flags & RTNH_F_DEAD)) {
+			hlist_del_rcu(&fa->fa_list);
+			fib_release_info(fa->fa_info);
+			alias_free_mem_rcu(fa);
+			found++;
+
+			continue;
 		}
 
-		ll = l;
+		slen = fa->fa_slen;
 	}
 
-	if (ll) {
-		if (hlist_empty(&ll->leaf))
-			trie_leaf_remove(t, ll);
-		else
-			leaf_pull_suffix(ll);
+	/* update leaf slen */
+	n->slen = slen;
+
+	if (hlist_empty(&n->leaf)) {
+		put_child_root(pn, t, n->key, NULL);
+		node_free(n);
+	} else {
+		leaf_pull_suffix(n);
 	}
 
+	/* if trie is leaf only loop is completed */
+	if (pn)
+		goto backtrace;
+flush_complete:
 	pr_debug("trie_flush found=%d\n", found);
 	return found;
 }
