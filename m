From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [net PATCH] fib_trie: Correct /proc/net/route off by one error
Date: Fri, 04 Nov 2016 15:11:57 -0400
Message-ID: <20161104191157.13974.70665.stgit@ahduyck-blue-test.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Andy Whitcroft <apw@canonical.com>,
        Jason Baron <jbaron@akamai.com>, davem@davemloft.net
To: netdev@vger.kernel.org, alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:41585 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750789AbcKEBMw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 4 Nov 2016 21:12:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The display of /proc/net/route has had a couple issues due to the fact that
when I originally rewrote most of fib_trie I made it so that the iterator
was tracking the next value to use instead of the current.

In addition it had an off by 1 error where I was tracking the first piece
of data as position 0, even though in reality that belonged to the
SEQ_START_TOKEN.

This patch updates the code so the iterator tracks the last reported
position and key instead of the next expected position and key.  In
addition it shifts things so that all of the leaves start at 1 instead of
trying to report leaves starting with offset 0 as being valid.  With these
two issues addressed this should resolve any off by one errors that were
present in the display of /proc/net/route.

Fixes: 25b97c016b26 ("ipv4: off-by-one in continuation handling in /proc/net/route")
Cc: Andy Whitcroft <apw@canonical.com>
Reported-by: Jason Baron <jbaron@akamai.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 net/ipv4/fib_trie.c |   21 +++++++++------------
 1 file changed, 9 insertions(+), 12 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 31cef36..4cff74d 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -2413,22 +2413,19 @@ static struct key_vector *fib_route_get_idx(struct fib_route_iter *iter,
 	struct key_vector *l, **tp = &iter->tnode;
 	t_key key;
 
-	/* use cache location of next-to-find key */
+	/* use cached location of previously found key */
 	if (iter->pos > 0 && pos >= iter->pos) {
-		pos -= iter->pos;
 		key = iter->key;
 	} else {
-		iter->pos = 0;
+		iter->pos = 1;
 		key = 0;
 	}
 
-	while ((l = leaf_walk_rcu(tp, key)) != NULL) {
+	pos -= iter->pos;
+
+	while ((l = leaf_walk_rcu(tp, key)) && (pos-- > 0)) {
 		key = l->key + 1;
 		iter->pos++;
-
-		if (--pos <= 0)
-			break;
-
 		l = NULL;
 
 		/* handle unlikely case of a key wrap */
@@ -2437,7 +2434,7 @@ static struct key_vector *fib_route_get_idx(struct fib_route_iter *iter,
 	}
 
 	if (l)
-		iter->key = key;	/* remember it */
+		iter->key = l->key;	/* remember it */
 	else
 		iter->pos = 0;		/* forget it */
 
@@ -2465,7 +2462,7 @@ static void *fib_route_seq_start(struct seq_file *seq, loff_t *pos)
 		return fib_route_get_idx(iter, *pos);
 
 	iter->pos = 0;
-	iter->key = 0;
+	iter->key = KEY_MAX;
 
 	return SEQ_START_TOKEN;
 }
@@ -2474,7 +2471,7 @@ static void *fib_route_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 {
 	struct fib_route_iter *iter = seq->private;
 	struct key_vector *l = NULL;
-	t_key key = iter->key;
+	t_key key = iter->key + 1;
 
 	++*pos;
 
@@ -2483,7 +2480,7 @@ static void *fib_route_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 		l = leaf_walk_rcu(&iter->tnode, key);
 
 	if (l) {
-		iter->key = l->key + 1;
+		iter->key = l->key;
 		iter->pos++;
 	} else {
 		iter->pos = 0;
