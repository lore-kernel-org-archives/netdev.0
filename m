From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next v2 5/7] rhashtable: avoid
	unnecessary wakeup for worker queue
Date: Wed, 7 Jan 2015 13:41:56 +0800
Message-ID: <1420609318-3261-6-git-send-email-ying.xue@windriver.com>
References: <1420609318-3261-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, netdev@vger.kernel.org,
	Paul.Gortmaker@windriver.com,
	tipc-discussion@lists.sourceforge.net, davem@davemloft.net
To: <tgraf@suug.ch>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1420609318-3261-1-git-send-email-ying.xue@windriver.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Move condition statements of verifying whether hash table size exceeds
its maximum threshold or reaches its minimum threshold from resizing
functions to resizing decision functions, avoiding unnecessary wakeup
for worker queue thread.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Cc: Thomas Graf <tgraf@suug.ch>
---
 include/linux/rhashtable.h |    2 +-
 lib/rhashtable.c           |   18 +++++++-----------
 2 files changed, 8 insertions(+), 12 deletions(-)

diff --git a/include/linux/rhashtable.h b/include/linux/rhashtable.h
index 73c913f..326acd8 100644
--- a/include/linux/rhashtable.h
+++ b/include/linux/rhashtable.h
@@ -113,7 +113,7 @@ struct rhashtable {
 	struct bucket_table __rcu	*tbl;
 	struct bucket_table __rcu       *future_tbl;
 	atomic_t			nelems;
-	size_t				shift;
+	atomic_t			shift;
 	struct rhashtable_params	p;
 	struct delayed_work             run_work;
 	struct mutex                    mutex;
diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index 1aef942..7fb474b 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -199,7 +199,8 @@ static struct bucket_table *bucket_table_alloc(struct rhashtable *ht,
 bool rht_grow_above_75(const struct rhashtable *ht, size_t new_size)
 {
 	/* Expand table when exceeding 75% load */
-	return atomic_read(&ht->nelems) > (new_size / 4 * 3);
+	return atomic_read(&ht->nelems) > (new_size / 4 * 3) &&
+	       (ht->p.max_shift && atomic_read(&ht->shift) < ht->p.max_shift);
 }
 EXPORT_SYMBOL_GPL(rht_grow_above_75);
 
@@ -211,7 +212,8 @@ EXPORT_SYMBOL_GPL(rht_grow_above_75);
 bool rht_shrink_below_30(const struct rhashtable *ht, size_t new_size)
 {
 	/* Shrink table beneath 30% load */
-	return atomic_read(&ht->nelems) < (new_size * 3 / 10);
+	return atomic_read(&ht->nelems) < (new_size * 3 / 10) &&
+	       (atomic_read(&ht->shift) > ht->p.min_shift);
 }
 EXPORT_SYMBOL_GPL(rht_shrink_below_30);
 
@@ -318,14 +320,11 @@ int rhashtable_expand(struct rhashtable *ht)
 
 	ASSERT_RHT_MUTEX(ht);
 
-	if (ht->p.max_shift && ht->shift >= ht->p.max_shift)
-		return 0;
-
 	new_tbl = bucket_table_alloc(ht, old_tbl->size * 2);
 	if (new_tbl == NULL)
 		return -ENOMEM;
 
-	ht->shift++;
+	atomic_inc(&ht->shift);
 
 	/* Make insertions go into the new, empty table right away. Deletions
 	 * and lookups will be attempted in both tables until we synchronize.
@@ -421,9 +420,6 @@ int rhashtable_shrink(struct rhashtable *ht)
 
 	ASSERT_RHT_MUTEX(ht);
 
-	if (ht->shift <= ht->p.min_shift)
-		return 0;
-
 	new_tbl = bucket_table_alloc(ht, tbl->size / 2);
 	if (new_tbl == NULL)
 		return -ENOMEM;
@@ -462,7 +458,7 @@ int rhashtable_shrink(struct rhashtable *ht)
 
 	/* Publish the new, valid hash table */
 	rcu_assign_pointer(ht->tbl, new_tbl);
-	ht->shift--;
+	atomic_dec(&ht->shift);
 
 	/* Wait for readers. No new readers will have references to the
 	 * old hash table.
@@ -851,7 +847,7 @@ int rhashtable_init(struct rhashtable *ht, struct rhashtable_params *params)
 	if (tbl == NULL)
 		return -ENOMEM;
 
-	ht->shift = ilog2(tbl->size);
+	atomic_set(&ht->shift, ilog2(tbl->size));
 	RCU_INIT_POINTER(ht->tbl, tbl);
 	RCU_INIT_POINTER(ht->future_tbl, tbl);
 
-- 
1.7.9.5


------------------------------------------------------------------------------
Dive into the World of Parallel Programming! The Go Parallel Website,
sponsored by Intel and developed in partnership with Slashdot Media, is your
hub for all things parallel software development, from weekly thought
leadership blogs to news, videos, case studies, tutorials and more. Take a
look and join the conversation now. http://goparallel.sourceforge.net
