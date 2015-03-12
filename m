From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 2/4] rhashtable: Use head_hashfn instead of obj_raw_hashfn
Date: Thu, 12 Mar 2015 14:49:39 +1100
Message-ID: <E1YVu7v-0003lg-9c@gondolin.me.apana.org.au>
References: <20150312034923.GA14415@gondor.apana.org.au>
To: Thomas Graf <tgraf@suug.ch>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:56795 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752361AbbCLDtm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 23:49:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that we don't have cross-table hashes, we no longer need to
keep the entire hash value so all users of obj_raw_hashfn can
use head_hashfn instead.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 lib/rhashtable.c |   12 +++++-------
 1 file changed, 5 insertions(+), 7 deletions(-)

diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index ff9cc33..03fdaf8 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -403,7 +403,7 @@ static bool __rhashtable_insert(struct rhashtable *ht, struct rhash_head *obj,
 	rcu_read_lock();
 
 	old_tbl = rht_dereference_rcu(ht->tbl, ht);
-	hash = obj_raw_hashfn(ht, old_tbl, rht_obj(ht, obj));
+	hash = head_hashfn(ht, old_tbl, obj);
 
 	spin_lock_bh(bucket_lock(old_tbl, hash));
 
@@ -415,7 +415,7 @@ static bool __rhashtable_insert(struct rhashtable *ht, struct rhash_head *obj,
 	 */
 	tbl = rht_dereference_rcu(ht->future_tbl, ht);
 	if (tbl != old_tbl) {
-		hash = obj_raw_hashfn(ht, tbl, rht_obj(ht, obj));
+		hash = head_hashfn(ht, tbl, obj);
 		spin_lock_nested(bucket_lock(tbl, hash), RHT_LOCK_NESTED);
 	}
 
@@ -428,7 +428,6 @@ static bool __rhashtable_insert(struct rhashtable *ht, struct rhash_head *obj,
 
 	no_resize_running = tbl == old_tbl;
 
-	hash = rht_bucket_index(tbl, hash);
 	head = rht_dereference_bucket(tbl->buckets[hash], tbl, hash);
 
 	if (rht_is_a_nulls(head))
@@ -444,11 +443,11 @@ static bool __rhashtable_insert(struct rhashtable *ht, struct rhash_head *obj,
 
 exit:
 	if (tbl != old_tbl) {
-		hash = obj_raw_hashfn(ht, tbl, rht_obj(ht, obj));
+		hash = head_hashfn(ht, tbl, obj);
 		spin_unlock(bucket_lock(tbl, hash));
 	}
 
-	hash = obj_raw_hashfn(ht, old_tbl, rht_obj(ht, obj));
+	hash = head_hashfn(ht, old_tbl, obj);
 	spin_unlock_bh(bucket_lock(old_tbl, hash));
 
 	rcu_read_unlock();
@@ -487,9 +486,8 @@ static bool __rhashtable_remove(struct rhashtable *ht,
 	unsigned hash;
 	bool ret = false;
 
-	hash = obj_raw_hashfn(ht, tbl, rht_obj(ht, obj));
+	hash = head_hashfn(ht, tbl, obj);
 	lock = bucket_lock(tbl, hash);
-	hash = rht_bucket_index(tbl, hash);
 
 	spin_lock_bh(lock);
 
