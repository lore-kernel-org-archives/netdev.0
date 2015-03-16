From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [v1 PATCH 0/14] rhashtable: Kill shift/Key netlink
 namespace/Merge jhash
Date: Mon, 16 Mar 2015 22:26:28 +1100
Message-ID: <20150316112628.GA1373@gondor.apana.org.au>
References: <20150316041805.GA28946@gondor.apana.org.au>
 <20150316.003049.1368221798557474722.davem@davemloft.net>
 <20150316043359.GA29124@gondor.apana.org.au>
 <20150316.004017.1903871383239941874.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tgraf@suug.ch, netdev@vger.kernel.org, eric.dumazet@gmail.com,
	Patrick McHardy <kaber@trash.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:43886 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751399AbbCPL0k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 07:26:40 -0400
Content-Disposition: inline
In-Reply-To: <20150316.004017.1903871383239941874.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 16, 2015 at 12:40:17AM -0400, David Miller wrote:
>
> Patrick McHardy had mentioned to me his consternation about this issue
> offhand the other week, and I've just failed to get around to bringing
> it up :-)

How about something like this? Compile tested only but at least
it does inline correctly.

diff --git a/include/linux/rhashtable.h b/include/linux/rhashtable.h
index c5104aa..79df647 100644
--- a/include/linux/rhashtable.h
+++ b/include/linux/rhashtable.h
@@ -42,6 +42,9 @@
 #define RHT_HASH_BITS		27
 #define RHT_BASE_SHIFT		RHT_HASH_BITS
 
+/* Base bits plus 1 bit for nulls marker */
+#define RHT_HASH_RESERVED_SPACE	(RHT_BASE_BITS + 1)
+
 struct rhash_head {
 	struct rhash_head __rcu		*next;
 };
@@ -172,6 +175,24 @@ static inline unsigned long rht_get_nulls_value(const struct rhash_head *ptr)
 	return ((unsigned long) ptr) >> 1;
 }
 
+static void *rht_obj(const struct rhashtable *ht, const struct rhash_head *he)
+{
+	return (void *) he - ht->p.head_offset;
+}
+
+static inline u32 rht_bucket_index(const struct bucket_table *tbl, u32 hash)
+{
+	return (hash >> RHT_HASH_RESERVED_SPACE) & (tbl->size - 1);
+}
+
+static inline u32 rht_key_hashfn(const struct bucket_table *tbl,
+				 const void *key,
+				 unsigned int key_len,
+				 rht_hashfn_t hashfn)
+{
+	return rht_bucket_index(tbl, hashfn(key, key_len, tbl->hash_rnd));
+}
+
 #ifdef CONFIG_PROVE_LOCKING
 int lockdep_rht_mutex_is_held(struct rhashtable *ht);
 int lockdep_rht_bucket_is_held(const struct bucket_table *tbl, u32 hash);
@@ -197,6 +218,7 @@ int rhashtable_expand(struct rhashtable *ht);
 int rhashtable_shrink(struct rhashtable *ht);
 
 void *rhashtable_lookup(struct rhashtable *ht, const void *key);
+void *rhashtable_lookup_slow(struct rhashtable *ht, const void *key);
 
 int rhashtable_lookup_insert(struct rhashtable *ht, struct rhash_head *obj);
 int rhashtable_lookup_insert_key(struct rhashtable *ht,
@@ -358,4 +380,30 @@ void rhashtable_destroy(struct rhashtable *ht);
 	rht_for_each_entry_rcu_continue(tpos, pos, (tbl)->buckets[hash],\
 					tbl, hash, member)
 
+static inline void *rhashtable_lookup_fast(struct rhashtable *ht,
+					   const void *key,
+					   unsigned int key_len,
+					   rht_hashfn_t hashfn,
+					   rht_obj_cmpfn_t obj_cmpfn)
+{
+	const struct bucket_table *tbl;
+	struct rhash_head *he;
+	u32 hash;
+
+	rcu_read_lock();
+
+	tbl = rht_dereference_rcu(ht->tbl, ht);
+	hash = rht_key_hashfn(tbl, key, key_len, hashfn);
+	rht_for_each_rcu(he, tbl, hash) {
+		if (!obj_cmpfn(key, rht_obj(ht, he)))
+			continue;
+		rcu_read_unlock();
+		return rht_obj(ht, he);
+	}
+
+	rcu_read_unlock();
+
+	return rhashtable_lookup(ht, key);
+}
+
 #endif /* _LINUX_RHASHTABLE_H */
diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index d22da74..7486e6a 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -33,9 +33,6 @@
 #define HASH_MIN_SIZE		4U
 #define BUCKET_LOCKS_PER_CPU   128UL
 
-/* Base bits plus 1 bit for nulls marker */
-#define HASH_RESERVED_SPACE	(RHT_BASE_BITS + 1)
-
 /* The bucket lock is selected based on the hash and protects mutations
  * on a group of hash buckets.
  *
@@ -54,21 +51,10 @@ static spinlock_t *bucket_lock(const struct bucket_table *tbl, u32 hash)
 	return &tbl->locks[hash & tbl->locks_mask];
 }
 
-static void *rht_obj(const struct rhashtable *ht, const struct rhash_head *he)
-{
-	return (void *) he - ht->p.head_offset;
-}
-
-static u32 rht_bucket_index(const struct bucket_table *tbl, u32 hash)
-{
-	return (hash >> HASH_RESERVED_SPACE) & (tbl->size - 1);
-}
-
 static u32 key_hashfn(struct rhashtable *ht, const struct bucket_table *tbl,
 		      const void *key)
 {
-	return rht_bucket_index(tbl, ht->p.hashfn(key, ht->hashfn_key_len,
-						  tbl->hash_rnd));
+	return rht_key_hashfn(tbl, key, ht->p.key_len, ht->p.hashfn);
 }
 
 static u32 head_hashfn(struct rhashtable *ht,
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index f521f35..4f225c7 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1000,7 +1000,7 @@ static struct sock *__netlink_lookup(struct netlink_table *table, u32 portid,
 	struct netlink_compare_arg arg;
 
 	netlink_compare_arg_init(&arg, net, portid);
-	return rhashtable_lookup(&table->hash, &arg);
+	return rhashtable_lookup_fast(&table->hash, &arg, netlink_compare_arg_len, jhash2, netlink_compare);
 }
 
 static int __netlink_insert(struct netlink_table *table, struct sock *sk)

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
