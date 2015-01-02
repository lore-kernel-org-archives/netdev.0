From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 4/9] rhashtable: Factor out bucket_tail() function
Date: Fri,  2 Jan 2015 23:00:17 +0100
Message-ID: <c09b3a163f11d2f220829f91e47f0394b4ee29b9.1420230585.git.tgraf@suug.ch>
References: <cover.1420230585.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	herbert@gondor.apana.org.au, paulmck@linux.vnet.ibm.com,
	edumazet@google.com, john.r.fastabend@intel.com,
	josh@joshtriplett.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1420230585.git.tgraf@suug.ch>
In-Reply-To: <cover.1420230585.git.tgraf@suug.ch>
References: <cover.1420230585.git.tgraf@suug.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Subsequent patches will require access to the bucket tail. Access
to the tail is relatively cheap as the automatic resizing of the
table should keep the number of entries per bucket to no more
than 0.75 on average.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 lib/rhashtable.c | 23 ++++++++++++++---------
 1 file changed, 14 insertions(+), 9 deletions(-)

diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index ce450d0..0bd29c1 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -83,6 +83,18 @@ static u32 head_hashfn(const struct rhashtable *ht,
 	return rht_bucket_index(tbl, obj_raw_hashfn(ht, rht_obj(ht, he)));
 }
 
+static struct rhash_head __rcu **bucket_tail(struct bucket_table *tbl, u32 n)
+{
+	struct rhash_head __rcu **pprev;
+
+	for (pprev = &tbl->buckets[n];
+	     rht_dereference_bucket(*pprev, tbl, n);
+	     pprev = &rht_dereference_bucket(*pprev, tbl, n)->next)
+		;
+
+	return pprev;
+}
+
 static struct bucket_table *bucket_table_alloc(size_t nbuckets)
 {
 	struct bucket_table *tbl;
@@ -266,7 +278,6 @@ EXPORT_SYMBOL_GPL(rhashtable_expand);
 int rhashtable_shrink(struct rhashtable *ht)
 {
 	struct bucket_table *ntbl, *tbl = rht_dereference(ht->tbl, ht);
-	struct rhash_head __rcu **pprev;
 	unsigned int i;
 
 	ASSERT_RHT_MUTEX(ht);
@@ -286,15 +297,9 @@ int rhashtable_shrink(struct rhashtable *ht)
 	 */
 	for (i = 0; i < ntbl->size; i++) {
 		ntbl->buckets[i] = tbl->buckets[i];
+		RCU_INIT_POINTER(*bucket_tail(ntbl, i),
+				 tbl->buckets[i + ntbl->size]);
 
-		/* Link each bucket in the new table to the first bucket
-		 * in the old table that contains entries which will hash
-		 * to the new bucket.
-		 */
-		for (pprev = &ntbl->buckets[i]; *pprev != NULL;
-		     pprev = &rht_dereference_bucket(*pprev, ntbl, i)->next)
-			;
-		RCU_INIT_POINTER(*pprev, tbl->buckets[i + ntbl->size]);
 	}
 
 	/* Publish the new, valid hash table */
-- 
1.9.3
