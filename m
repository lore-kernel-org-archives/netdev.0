From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [v1 PATCH 11/14] rhashtable: Allow hashfn to be unset
Date: Sun, 15 Mar 2015 21:44:36 +1100
Message-ID: <E1YX628-0005oy-PO@gondolin.me.apana.org.au>
References: <20150315104306.GA21999@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>, tgraf@suug.ch,
	netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:35101 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752491AbbCOKol (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2015 06:44:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since every current rhashtable user uses jhash as their hash
function, the fact that jhash is an inline function causes each
user to generate a copy of its code.

This function provides a solution to this problem by allowing
hashfn to be unset.  In which case rhashtable will automatically
set it to jhash.  Furthermore, if the key length is a multiple
of 4, we will switch over to jhash2.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/linux/rhashtable.h |    2 ++
 lib/rhashtable.c           |   19 +++++++++++++++++--
 2 files changed, 19 insertions(+), 2 deletions(-)

diff --git a/include/linux/rhashtable.h b/include/linux/rhashtable.h
index 00fe294..295580e 100644
--- a/include/linux/rhashtable.h
+++ b/include/linux/rhashtable.h
@@ -110,6 +110,7 @@ struct rhashtable_params {
  * struct rhashtable - Hash table handle
  * @tbl: Bucket table
  * @nelems: Number of elements in table
+ * @key_len: Key length for hashfn
  * @p: Configuration parameters
  * @run_work: Deferred worker to expand/shrink asynchronously
  * @mutex: Mutex to protect current/future table swapping
@@ -119,6 +120,7 @@ struct rhashtable {
 	struct bucket_table __rcu	*tbl;
 	atomic_t			nelems;
 	bool                            being_destroyed;
+	unsigned int			hashfn_key_len;
 	struct rhashtable_params	p;
 	struct work_struct		run_work;
 	struct mutex                    mutex;
diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index e33e7b9..a2dc855 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -67,7 +67,7 @@ static u32 rht_bucket_index(const struct bucket_table *tbl, u32 hash)
 static u32 key_hashfn(struct rhashtable *ht, const struct bucket_table *tbl,
 		      const void *key)
 {
-	return rht_bucket_index(tbl, ht->p.hashfn(key, ht->p.key_len,
+	return rht_bucket_index(tbl, ht->p.hashfn(key, ht->hashfn_key_len,
 						  tbl->hash_rnd));
 }
 
@@ -858,6 +858,11 @@ static size_t rounded_hashtable_size(struct rhashtable_params *params)
 		   (unsigned long)params->min_size);
 }
 
+static u32 rhashtable_jhash2(const void *key, u32 length, u32 seed)
+{
+	return jhash2(key, length, seed);
+}
+
 /**
  * rhashtable_init - initialize a new hash table
  * @ht:		hash table to be initialized
@@ -908,7 +913,7 @@ int rhashtable_init(struct rhashtable *ht, struct rhashtable_params *params)
 
 	size = HASH_DEFAULT_SIZE;
 
-	if (!params->hashfn || !params->key_len ||
+	if (!params->key_len ||
 	    (params->obj_hashfn && !params->obj_cmpfn))
 		return -EINVAL;
 
@@ -924,6 +929,16 @@ int rhashtable_init(struct rhashtable *ht, struct rhashtable_params *params)
 	mutex_init(&ht->mutex);
 	memcpy(&ht->p, params, sizeof(*params));
 
+	ht->hashfn_key_len = ht->p.key_len;
+	if (!params->hashfn) {
+		ht->p.hashfn = jhash;
+
+		if (!(ht->hashfn_key_len & (sizeof(u32) - 1))) {
+			ht->hashfn_key_len /= sizeof(u32);
+			ht->p.hashfn = rhashtable_jhash2;
+		}
+	}
+
 	if (params->locks_mul)
 		ht->p.locks_mul = roundup_pow_of_two(params->locks_mul);
 	else
