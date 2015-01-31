From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: rhashtable: Move hash_rnd into bucket_table
Date: Sat, 31 Jan 2015 21:21:50 +1100
Message-ID: <20150131102150.GA29498@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Thomas Graf <tgraf@suug.ch>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:39627 "EHLO
	helcar.apana.org.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751715AbbAaKVz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Jan 2015 05:21:55 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently hash_rnd is a parameter that users can set.  However,
no existing users set this parameter.  It is also something that
people are unlikely to want to set directly since it's just a
random number.
    
In preparation for allowing the reseeding/rehashing of rhashtable,
this patch moves hash_rnd into bucket_table so that it's now an
internal state rather than a parameter.
    
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/include/linux/rhashtable.h b/include/linux/rhashtable.h
index a2562ed..6d7e840 100644
--- a/include/linux/rhashtable.h
+++ b/include/linux/rhashtable.h
@@ -55,6 +55,7 @@ struct rhash_head {
 struct bucket_table {
 	size_t				size;
 	unsigned int			locks_mask;
+	u32				hash_rnd;
 	spinlock_t			*locks;
 	struct rhash_head __rcu		*buckets[];
 };
@@ -70,7 +71,6 @@ struct rhashtable;
  * @key_len: Length of key
  * @key_offset: Offset of key in struct to be hashed
  * @head_offset: Offset of rhash_head in struct to be hashed
- * @hash_rnd: Seed to use while hashing
  * @max_shift: Maximum number of shifts while expanding
  * @min_shift: Minimum number of shifts while shrinking
  * @nulls_base: Base value to generate nulls marker
@@ -89,7 +89,6 @@ struct rhashtable_params {
 	size_t			key_len;
 	size_t			key_offset;
 	size_t			head_offset;
-	u32			hash_rnd;
 	size_t			max_shift;
 	size_t			min_shift;
 	u32			nulls_base;
diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index 84a78e3..71c6aa1 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -81,13 +81,14 @@ static u32 rht_bucket_index(const struct bucket_table *tbl, u32 hash)
 
 static u32 obj_raw_hashfn(const struct rhashtable *ht, const void *ptr)
 {
+	struct bucket_table *tbl = rht_dereference_rcu(ht->tbl, ht);
 	u32 hash;
 
 	if (unlikely(!ht->p.key_len))
-		hash = ht->p.obj_hashfn(ptr, ht->p.hash_rnd);
+		hash = ht->p.obj_hashfn(ptr, tbl->hash_rnd);
 	else
 		hash = ht->p.hashfn(ptr + ht->p.key_offset, ht->p.key_len,
-				    ht->p.hash_rnd);
+				    tbl->hash_rnd);
 
 	return hash >> HASH_RESERVED_SPACE;
 }
@@ -97,7 +98,7 @@ static u32 key_hashfn(struct rhashtable *ht, const void *key, u32 len)
 	struct bucket_table *tbl = rht_dereference_rcu(ht->tbl, ht);
 	u32 hash;
 
-	hash = ht->p.hashfn(key, len, ht->p.hash_rnd);
+	hash = ht->p.hashfn(key, len, tbl->hash_rnd);
 	hash >>= HASH_RESERVED_SPACE;
 
 	return rht_bucket_index(tbl, hash);
@@ -894,14 +895,13 @@ int rhashtable_init(struct rhashtable *ht, struct rhashtable_params *params)
 	if (tbl == NULL)
 		return -ENOMEM;
 
+	get_random_bytes(&tbl->hash_rnd, sizeof(tbl->hash_rnd));
+
 	atomic_set(&ht->nelems, 0);
 	atomic_set(&ht->shift, ilog2(tbl->size));
 	RCU_INIT_POINTER(ht->tbl, tbl);
 	RCU_INIT_POINTER(ht->future_tbl, tbl);
 
-	if (!ht->p.hash_rnd)
-		get_random_bytes(&ht->p.hash_rnd, sizeof(ht->p.hash_rnd));
-
 	if (ht->p.grow_decision || ht->p.shrink_decision)
 		INIT_WORK(&ht->run_work, rht_deferred_worker);
 
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
