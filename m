From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [net PATCH 2/2] ipv4: Drop suffix update from resize code
Date: Thu, 01 Dec 2016 07:27:57 -0500
Message-ID: <20161201122757.15499.51778.stgit@ahduyck-blue-test.jf.intel.com>
References: <20161201121605.15499.13176.stgit@ahduyck-blue-test.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org, rshearma@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:60534 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755513AbcLAS3g (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 1 Dec 2016 13:29:36 -0500
In-Reply-To: <20161201121605.15499.13176.stgit@ahduyck-blue-test.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It has been reported that update_suffix can be expensive when it is called
on a large node in which most of the suffix lengths are the same.  The time
required to add 200K entries had increased from around 3 seconds to almost
49 seconds.

In order to address this we need to move the code for updating the suffix
out of resize and instead just have it handled in the cases where we are
pushing a node that increases the suffix length, or will decrease the
suffix length.

Fixes: 5405afd1a306 ("fib_trie: Add tracking value for suffix length")
Reported-by: Robert Shearman <rshearma@brocade.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 net/ipv4/fib_trie.c |   42 +++++++++++++++++++++---------------------
 1 file changed, 21 insertions(+), 21 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index c5cd226..2cfa9f4 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -681,6 +681,13 @@ static unsigned char update_suffix(struct key_vector *tn)
 {
 	unsigned char slen = tn->pos;
 	unsigned long stride, i;
+	unsigned char slen_max;
+
+	/* only vector 0 can have a suffix length greater than or equal to
+	 * tn->pos + tn->bits, the second highest node will have a suffix
+	 * length at most of tn->pos + tn->bits - 1
+	 */
+	slen_max = min_t(unsigned char, tn->pos + tn->bits - 1, tn->slen);
 
 	/* search though the list of children looking for nodes that might
 	 * have a suffix greater than the one we currently have.  This is
@@ -698,12 +705,8 @@ static unsigned char update_suffix(struct key_vector *tn)
 		slen = n->slen;
 		i &= ~(stride - 1);
 
-		/* if slen covers all but the last bit we can stop here
-		 * there will be nothing longer than that since only node
-		 * 0 and 1 << (bits - 1) could have that as their suffix
-		 * length.
-		 */
-		if ((slen + 1) >= (tn->pos + tn->bits))
+		/* stop searching if we have hit the maximum possible value */
+		if (slen >= slen_max)
 			break;
 	}
 
@@ -875,21 +878,7 @@ static struct key_vector *resize(struct trie *t, struct key_vector *tn)
 		return collapse(t, tn);
 
 	/* update parent in case halve failed */
-	tp = node_parent(tn);
-
-	/* Return if at least one deflate was run */
-	if (max_work != MAX_WORK)
-		return tp;
-
-	/* push the suffix length to the parent node */
-	if (tn->slen > tn->pos) {
-		unsigned char slen = update_suffix(tn);
-
-		if (slen > tp->slen)
-			tp->slen = slen;
-	}
-
-	return tp;
+	return node_parent(tn);
 }
 
 static void node_pull_suffix(struct key_vector *tn, unsigned char slen)
@@ -1030,6 +1019,7 @@ static int fib_insert_node(struct trie *t, struct key_vector *tp,
 	}
 
 	/* Case 3: n is NULL, and will just insert a new leaf */
+	node_push_suffix(tp, new->fa_slen);
 	NODE_INIT_PARENT(l, tp);
 	put_child_root(tp, key, l);
 	trie_rebalance(t, tp);
@@ -1472,6 +1462,8 @@ static void fib_remove_alias(struct trie *t, struct key_vector *tp,
 	 * out parent suffix lengths as a part of trie_rebalance
 	 */
 	if (hlist_empty(&l->leaf)) {
+		if (tp->slen == l->slen)
+			node_pull_suffix(tp, tp->pos);
 		put_child_root(tp, l->key, NULL);
 		node_free(l);
 		trie_rebalance(t, tp);
@@ -1753,6 +1745,10 @@ void fib_table_flush_external(struct fib_table *tb)
 			if (IS_TRIE(pn))
 				break;
 
+			/* update the suffix to address pulled leaves */
+			if (pn->slen > pn->pos)
+				update_suffix(pn);
+
 			/* resize completed node */
 			pn = resize(t, pn);
 			cindex = get_index(pkey, pn);
@@ -1828,6 +1824,10 @@ int fib_table_flush(struct fib_table *tb)
 			if (IS_TRIE(pn))
 				break;
 
+			/* update the suffix to address pulled leaves */
+			if (pn->slen > pn->pos)
+				update_suffix(pn);
+
 			/* resize completed node */
 			pn = resize(t, pn);
 			cindex = get_index(pkey, pn);
