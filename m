From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next v2 2/7] rhashtable: introduce
	rhashtable_wakeup_worker helper function
Date: Wed, 7 Jan 2015 13:41:53 +0800
Message-ID: <1420609318-3261-3-git-send-email-ying.xue@windriver.com>
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

Introduce rhashtable_wakeup_worker() helper function to reduce
duplicated code where to wake up worker.

By the way, as long as the both "future_tbl" and "tbl" bucket table
pointers point to the same bucket array, we should try to wake up
the resizing worker thread, otherwise, it indicates the work of
resizing hash table is not finished yet. However, currently we will
wake up the worker thread only when the two pointers point to
different bucket array. Obviously this is wrong. So, the issue is
also fixed as well in the patch.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Cc: Thomas Graf <tgraf@suug.ch>
---
 lib/rhashtable.c |   23 +++++++++++++++--------
 1 file changed, 15 insertions(+), 8 deletions(-)

diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index f2fdd7a..2000685 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -492,6 +492,19 @@ static void rht_deferred_worker(struct work_struct *work)
 	mutex_unlock(&ht->mutex);
 }
 
+static void rhashtable_wakeup_worker(struct rhashtable *ht)
+{
+	struct bucket_table *tbl = rht_dereference_rcu(ht->tbl, ht);
+	struct bucket_table *new_tbl = rht_dereference_rcu(ht->future_tbl, ht);
+	size_t size = tbl->size;
+
+	/* Only adjust the table if no resizing is currently in progress. */
+	if (tbl == new_tbl &&
+	    ((ht->p.grow_decision && ht->p.grow_decision(ht, size)) ||
+	     (ht->p.shrink_decision && ht->p.shrink_decision(ht, size))))
+		schedule_delayed_work(&ht->run_work, 0);
+}
+
 /**
  * rhashtable_insert - insert object into hash hash table
  * @ht:		hash table
@@ -532,10 +545,7 @@ void rhashtable_insert(struct rhashtable *ht, struct rhash_head *obj)
 
 	atomic_inc(&ht->nelems);
 
-	/* Only grow the table if no resizing is currently in progress. */
-	if (ht->tbl != ht->future_tbl &&
-	    ht->p.grow_decision && ht->p.grow_decision(ht, tbl->size))
-		schedule_delayed_work(&ht->run_work, 0);
+	rhashtable_wakeup_worker(ht);
 
 	rcu_read_unlock();
 }
@@ -584,10 +594,7 @@ restart:
 
 		spin_unlock_bh(lock);
 
-		if (ht->tbl != ht->future_tbl &&
-		    ht->p.shrink_decision &&
-		    ht->p.shrink_decision(ht, tbl->size))
-			schedule_delayed_work(&ht->run_work, 0);
+		rhashtable_wakeup_worker(ht);
 
 		rcu_read_unlock();
 
-- 
1.7.9.5


------------------------------------------------------------------------------
Dive into the World of Parallel Programming! The Go Parallel Website,
sponsored by Intel and developed in partnership with Slashdot Media, is your
hub for all things parallel software development, from weekly thought
leadership blogs to news, videos, case studies, tutorials and more. Take a
look and join the conversation now. http://goparallel.sourceforge.net
