From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 4/6] rhashtable: Free bucket tables asynchronously after rehash
Date: Fri, 13 Mar 2015 20:57:13 +1100
Message-ID: <E1YWMLB-0000Bx-Lm@gondolin.me.apana.org.au>
References: <20150313095607.GA598@gondor.apana.org.au>
To: Thomas Graf <tgraf@suug.ch>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:39981 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752459AbbCMJ5R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 05:57:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is in fact no need to wait for an RCU grace period in the
rehash function, since all insertions are guaranteed to go into
the new table through spin locks.

This patch uses call_rcu to free the old/rehashed table at our
leisure.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/linux/rhashtable.h |    2 ++
 lib/rhashtable.c           |    9 ++++++---
 2 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/include/linux/rhashtable.h b/include/linux/rhashtable.h
index 4192682..a0abddd 100644
--- a/include/linux/rhashtable.h
+++ b/include/linux/rhashtable.h
@@ -54,6 +54,7 @@ struct rhash_head {
  * @locks_mask: Mask to apply before accessing locks[]
  * @locks: Array of spinlocks protecting individual buckets
  * @walkers: List of active walkers
+ * @rcu: RCU structure for freeing the table
  * @buckets: size * hash buckets
  */
 struct bucket_table {
@@ -63,6 +64,7 @@ struct bucket_table {
 	unsigned int		locks_mask;
 	spinlock_t		*locks;
 	struct list_head	walkers;
+	struct rcu_head		rcu;
 
 	struct rhash_head __rcu	*buckets[] ____cacheline_aligned_in_smp;
 };
diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index e55bbc8..36fb091 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -141,6 +141,11 @@ static void bucket_table_free(const struct bucket_table *tbl)
 	kvfree(tbl);
 }
 
+static void bucket_table_free_rcu(struct rcu_head *head)
+{
+	bucket_table_free(container_of(head, struct bucket_table, rcu));
+}
+
 static struct bucket_table *bucket_table_alloc(struct rhashtable *ht,
 					       size_t nbuckets)
 {
@@ -288,9 +293,7 @@ static void rhashtable_rehash(struct rhashtable *ht,
 	 * table, and thus no references to the old table will
 	 * remain.
 	 */
-	synchronize_rcu();
-
-	bucket_table_free(old_tbl);
+	call_rcu(&old_tbl->rcu, bucket_table_free_rcu);
 }
 
 /**
