From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next] rhashtable: Fix remove logic to avoid cross
 references between buckets
Date: Fri, 6 Feb 2015 16:08:43 +0000
Message-ID: <20150206160843.GA31371@casper.infradead.org>
References: <cover.1423097592.git.tgraf@suug.ch>
 <54D2D656.8060709@windriver.com>
 <20150205084737.GA15549@casper.infradead.org>
 <54D3346E.4040302@windriver.com>
 <20150205101954.GA24388@casper.infradead.org>
 <54D42892.3030808@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
To: Ying Xue <ying.xue@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:34770 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751486AbbBFQIq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2015 11:08:46 -0500
Content-Disposition: inline
In-Reply-To: <54D42892.3030808@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The remove logic properly searched the remaining chain for a matching
entry with an identical hash but it did this while searching from both
the old and new table. Instead in order to not leave stale references
behind we need to:

 1. When growing and searching from the new table:
    Search remaining chain for entry with same hash to avoid having
    the new table directly point to a entry with a different hash.

 2. When shrinking and searching from the old table:
    Check if the element after the removed would create a cross
    reference and avoid it if so.

These bugs were present from the beginning in nft_hash.

Also, both insert functions calculated the hash based on the mask of
the new table. This worked while growing. Wwhile shrinking, the mask
of the inew table is smaller than the mask of the old table. This lead
to a bit not being taken into account when selecting the bucket lock
and thus caused the wrong bucket to be locked eventually.

Fixes: 7e1e77636e36 ("lib: Resizable, Scalable, Concurrent Hash Table")
Fixes: 97defe1ecf86 ("rhashtable: Per bucket locks & deferred expansion/shrinking")
Reported-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 lib/rhashtable.c | 28 +++++++++++++++++-----------
 1 file changed, 17 insertions(+), 11 deletions(-)

diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index 5919d63..e96fc00 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -552,8 +552,10 @@ static void rhashtable_wakeup_worker(struct rhashtable *ht)
 static void __rhashtable_insert(struct rhashtable *ht, struct rhash_head *obj,
 				struct bucket_table *tbl, u32 hash)
 {
-	struct rhash_head *head = rht_dereference_bucket(tbl->buckets[hash],
-							 tbl, hash);
+	struct rhash_head *head;
+
+	hash = rht_bucket_index(tbl, hash);
+	head = rht_dereference_bucket(tbl->buckets[hash], tbl, hash);
 
 	ASSERT_BUCKET_LOCK(ht, tbl, hash);
 
@@ -593,7 +595,7 @@ void rhashtable_insert(struct rhashtable *ht, struct rhash_head *obj)
 
 	tbl = rht_dereference_rcu(ht->future_tbl, ht);
 	old_tbl = rht_dereference_rcu(ht->tbl, ht);
-	hash = head_hashfn(ht, tbl, obj);
+	hash = obj_raw_hashfn(ht, rht_obj(ht, obj));
 
 	lock_buckets(tbl, old_tbl, hash);
 	__rhashtable_insert(ht, obj, tbl, hash);
@@ -627,8 +629,8 @@ bool rhashtable_remove(struct rhashtable *ht, struct rhash_head *obj)
 	bool ret = false;
 
 	rcu_read_lock();
-	tbl = old_tbl = rht_dereference_rcu(ht->tbl, ht);
-	new_tbl = rht_dereference_rcu(ht->future_tbl, ht);
+	old_tbl = rht_dereference_rcu(ht->tbl, ht);
+	tbl = new_tbl = rht_dereference_rcu(ht->future_tbl, ht);
 	new_hash = obj_raw_hashfn(ht, rht_obj(ht, obj));
 
 	lock_buckets(new_tbl, old_tbl, new_hash);
@@ -643,15 +645,19 @@ restart:
 
 		ASSERT_BUCKET_LOCK(ht, tbl, hash);
 
-		if (unlikely(new_tbl != tbl)) {
-			rht_for_each_continue(he2, he->next, tbl, hash) {
+		if (old_tbl->size > new_tbl->size && tbl == old_tbl &&
+		    !rht_is_a_nulls(obj->next) &&
+		    head_hashfn(ht, tbl, obj->next) != hash) {
+			rcu_assign_pointer(*pprev, (struct rhash_head *) rht_marker(ht, hash));
+		} else if (unlikely(old_tbl->size < new_tbl->size && tbl == new_tbl)) {
+			rht_for_each_continue(he2, obj->next, tbl, hash) {
 				if (head_hashfn(ht, tbl, he2) == hash) {
 					rcu_assign_pointer(*pprev, he2);
 					goto found;
 				}
 			}
 
-			INIT_RHT_NULLS_HEAD(*pprev, ht, hash);
+			rcu_assign_pointer(*pprev, (struct rhash_head *) rht_marker(ht, hash));
 		} else {
 			rcu_assign_pointer(*pprev, obj->next);
 		}
@@ -666,8 +672,8 @@ found:
 	 * resizing. Thus traversing both is fine and the added cost is
 	 * very rare.
 	 */
-	if (tbl != new_tbl) {
-		tbl = new_tbl;
+	if (tbl != old_tbl) {
+		tbl = old_tbl;
 		goto restart;
 	}
 
@@ -835,7 +841,7 @@ bool rhashtable_lookup_compare_insert(struct rhashtable *ht,
 	rcu_read_lock();
 	old_tbl = rht_dereference_rcu(ht->tbl, ht);
 	new_tbl = rht_dereference_rcu(ht->future_tbl, ht);
-	new_hash = head_hashfn(ht, new_tbl, obj);
+	new_hash = obj_raw_hashfn(ht, rht_obj(ht, obj));
 
 	lock_buckets(new_tbl, old_tbl, new_hash);
 
-- 
1.9.3
