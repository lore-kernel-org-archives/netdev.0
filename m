From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [v1 PATCH 3/10] rhashtable: Allow hashfn to be unset
Date: Sun, 22 Mar 2015 18:53:46 +1100
Message-ID: <E1YZahe-0000hs-4V@gondolin.me.apana.org.au>
References: <20150322075300.GA2441@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	Josh Triplett <josh@joshtriplett.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:47022 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751481AbbCVHyI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2015 03:54:08 -0400
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

 include/linux/rhashtable.h |   33 +++++++++++++++++++++++++++------
 lib/rhashtable.c           |   17 ++++++++++++++++-
 2 files changed, 43 insertions(+), 7 deletions(-)

diff --git a/include/linux/rhashtable.h b/include/linux/rhashtable.h
index 287b609..2a98b95 100644
--- a/include/linux/rhashtable.h
+++ b/include/linux/rhashtable.h
@@ -19,6 +19,7 @@
 
 #include <linux/compiler.h>
 #include <linux/errno.h>
+#include <linux/jhash.h>
 #include <linux/list_nulls.h>
 #include <linux/workqueue.h>
 #include <linux/mutex.h>
@@ -103,7 +104,7 @@ struct rhashtable;
  * @min_size: Minimum size while shrinking
  * @nulls_base: Base value to generate nulls marker
  * @locks_mul: Number of bucket locks to allocate per cpu (default: 128)
- * @hashfn: Function to hash key
+ * @hashfn: Hash function (default: jhash2 if !(key_len % 4), or jhash)
  * @obj_hashfn: Function to hash object
  * @obj_cmpfn: Function to compare key with object
  */
@@ -125,6 +126,7 @@ struct rhashtable_params {
  * struct rhashtable - Hash table handle
  * @tbl: Bucket table
  * @nelems: Number of elements in table
+ * @key_len: Key length for hashfn
  * @p: Configuration parameters
  * @run_work: Deferred worker to expand/shrink asynchronously
  * @mutex: Mutex to protect current/future table swapping
@@ -134,6 +136,7 @@ struct rhashtable {
 	struct bucket_table __rcu	*tbl;
 	atomic_t			nelems;
 	bool                            being_destroyed;
+	unsigned int			key_len;
 	struct rhashtable_params	p;
 	struct work_struct		run_work;
 	struct mutex                    mutex;
@@ -199,12 +202,30 @@ static inline unsigned int rht_key_hashfn(
 	struct rhashtable *ht, const struct bucket_table *tbl,
 	const void *key, const struct rhashtable_params params)
 {
-	unsigned key_len = __builtin_constant_p(params.key_len) ?
-			   (params.key_len ?: ht->p.key_len) :
-			   params.key_len;
+	unsigned hash;
+
+	if (!__builtin_constant_p(params.key_len))
+		hash = ht->p.hashfn(key, ht->key_len, tbl->hash_rnd);
+	else if (params.key_len) {
+		unsigned key_len = params.key_len;
+
+		if (params.hashfn)
+			hash = params.hashfn(key, key_len, tbl->hash_rnd);
+		else if (key_len & (sizeof(u32) - 1))
+			hash = jhash(key, key_len, tbl->hash_rnd);
+		else
+			hash = jhash2(key, key_len / sizeof(u32),
+				      tbl->hash_rnd);
+	} else {
+		unsigned key_len = ht->p.key_len;
+
+		if (params.hashfn)
+			hash = params.hashfn(key, key_len, tbl->hash_rnd);
+		else
+			hash = jhash(key, key_len, tbl->hash_rnd);
+	}
 
-	return rht_bucket_index(tbl, params.hashfn(key, key_len,
-						   tbl->hash_rnd));
+	return rht_bucket_index(tbl, hash);
 }
 
 static inline unsigned int rht_head_hashfn(
diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index 618a3f0..798f01d 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -532,6 +532,11 @@ static size_t rounded_hashtable_size(const struct rhashtable_params *params)
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
@@ -583,7 +588,7 @@ int rhashtable_init(struct rhashtable *ht,
 
 	size = HASH_DEFAULT_SIZE;
 
-	if ((!(params->key_len && params->hashfn) && !params->obj_hashfn) ||
+	if ((!params->key_len && !params->obj_hashfn) ||
 	    (params->obj_hashfn && !params->obj_cmpfn))
 		return -EINVAL;
 
@@ -610,6 +615,16 @@ int rhashtable_init(struct rhashtable *ht,
 	else
 		ht->p.locks_mul = BUCKET_LOCKS_PER_CPU;
 
+	ht->key_len = ht->p.key_len;
+	if (!params->hashfn) {
+		ht->p.hashfn = jhash;
+
+		if (!(ht->key_len & (sizeof(u32) - 1))) {
+			ht->key_len /= sizeof(u32);
+			ht->p.hashfn = rhashtable_jhash2;
+		}
+	}
+
 	tbl = bucket_table_alloc(ht, size);
 	if (tbl == NULL)
 		return -ENOMEM;
