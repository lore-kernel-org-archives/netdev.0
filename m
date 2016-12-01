From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [net PATCH 1/2] ipv4: Drop leaf from suffix pull/push functions
Date: Thu, 01 Dec 2016 07:27:52 -0500
Message-ID: <20161201122752.15499.8184.stgit@ahduyck-blue-test.jf.intel.com>
References: <20161201121605.15499.13176.stgit@ahduyck-blue-test.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org, rshearma@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:13355 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755561AbcLAS3b (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 1 Dec 2016 13:29:31 -0500
In-Reply-To: <20161201121605.15499.13176.stgit@ahduyck-blue-test.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It wasn't necessary to pass a leaf in when doing the suffix updates so just
drop it.  Instead just pass the suffix and work with that.

Since we dropped the leaf there is no need to include that in the name so
the names are updated to node_push_suffix and node_pull_suffix.

Finally I noticed that the logic for pulling the suffix length back
actually had some issues.  Specifically it would stop prematurely if there
was a longer suffix, but it was not as long as the original suffix.  I
updated the code to address that in node_pull_suffix.

Fixes: 5405afd1a306 ("fib_trie: Add tracking value for suffix length")
Suggested-by: Robert Shearman <rshearma@brocade.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 net/ipv4/fib_trie.c |   26 ++++++++++++++------------
 1 file changed, 14 insertions(+), 12 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index e2ffc2a..c5cd226 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -892,22 +892,24 @@ static struct key_vector *resize(struct trie *t, struct key_vector *tn)
 	return tp;
 }
 
-static void leaf_pull_suffix(struct key_vector *tp, struct key_vector *l)
+static void node_pull_suffix(struct key_vector *tn, unsigned char slen)
 {
-	while ((tp->slen > tp->pos) && (tp->slen > l->slen)) {
-		if (update_suffix(tp) > l->slen)
+	unsigned char node_slen = tn->slen;
+
+	while ((node_slen > tn->pos) && (node_slen > slen)) {
+		slen = update_suffix(tn);
+		if (node_slen == slen)
 			break;
-		tp = node_parent(tp);
+
+		tn = node_parent(tn);
+		node_slen = tn->slen;
 	}
 }
 
-static void leaf_push_suffix(struct key_vector *tn, struct key_vector *l)
+static void node_push_suffix(struct key_vector *tn, unsigned char slen)
 {
-	/* if this is a new leaf then tn will be NULL and we can sort
-	 * out parent suffix lengths as a part of trie_rebalance
-	 */
-	while (tn->slen < l->slen) {
-		tn->slen = l->slen;
+	while (tn->slen < slen) {
+		tn->slen = slen;
 		tn = node_parent(tn);
 	}
 }
@@ -1069,7 +1071,7 @@ static int fib_insert_alias(struct trie *t, struct key_vector *tp,
 	/* if we added to the tail node then we need to update slen */
 	if (l->slen < new->fa_slen) {
 		l->slen = new->fa_slen;
-		leaf_push_suffix(tp, l);
+		node_push_suffix(tp, new->fa_slen);
 	}
 
 	return 0;
@@ -1482,7 +1484,7 @@ static void fib_remove_alias(struct trie *t, struct key_vector *tp,
 
 	/* update the trie with the latest suffix length */
 	l->slen = fa->fa_slen;
-	leaf_pull_suffix(tp, l);
+	node_pull_suffix(tp, fa->fa_slen);
 }
 
 /* Caller must hold RTNL. */
