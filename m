From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [v1 PATCH 2/2] rhashtable: Fix rhashtable_remove failures
Date: Sun, 15 Mar 2015 21:12:05 +1100
Message-ID: <E1YX5Wf-0005aA-JC@gondolin.me.apana.org.au>
References: <20150315101004.GA21383@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>, tgraf@suug.ch,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:60374 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751856AbbCOKMK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2015 06:12:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The commit 9d901bc05153bbf33b5da2cd6266865e531f0545 ("rhashtable:
Free bucket tables asynchronously after rehash") causes gratuitous
failures in rhashtable_remove.

The reason is that it inadvertently introduced multiple rehashing
from the perspective of readers.  IOW it is now possible to see
more than two tables during a single RCU critical section.

Fortunately the other reader rhashtable_lookup already deals with
this correctly thanks to c4db8848af6af92f90462258603be844baeab44d
("rhashtable: rhashtable: Move future_tbl into struct bucket_table")
so only rhashtable_remove is broken by this change.

This patch fixes this by looping over every table from the first
one to the last or until we find the element that we were trying
to delete.

Incidentally the simple test for detecting rehashing to prevent
starting another shrinking no longer works.  Since it isn't needed
anyway (the work queue and the mutex serves as a natural barrier
to unnecessary rehashes) I've simply killed the test.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 lib/rhashtable.c |   17 +++++++----------
 1 file changed, 7 insertions(+), 10 deletions(-)

diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index b916679..c523d3a 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -511,28 +511,25 @@ static bool __rhashtable_remove(struct rhashtable *ht,
  */
 bool rhashtable_remove(struct rhashtable *ht, struct rhash_head *obj)
 {
-	struct bucket_table *tbl, *old_tbl;
+	struct bucket_table *tbl;
 	bool ret;
 
 	rcu_read_lock();
 
-	old_tbl = rht_dereference_rcu(ht->tbl, ht);
-	ret = __rhashtable_remove(ht, old_tbl, obj);
+	tbl = rht_dereference_rcu(ht->tbl, ht);
 
 	/* Because we have already taken (and released) the bucket
 	 * lock in old_tbl, if we find that future_tbl is not yet
 	 * visible then that guarantees the entry to still be in
-	 * old_tbl if it exists.
+	 * the old tbl if it exists.
 	 */
-	tbl = rht_dereference_rcu(old_tbl->future_tbl, ht) ?: old_tbl;
-	if (!ret && old_tbl != tbl)
-		ret = __rhashtable_remove(ht, tbl, obj);
+	while (!(ret = __rhashtable_remove(ht, tbl, obj)) &&
+	       (tbl = rht_dereference_rcu(tbl->future_tbl, ht)))
+		;
 
 	if (ret) {
-		bool no_resize_running = tbl == old_tbl;
-
 		atomic_dec(&ht->nelems);
-		if (no_resize_running && rht_shrink_below_30(ht, tbl))
+		if (rht_shrink_below_30(ht, tbl))
 			schedule_work(&ht->run_work);
 	}
 
