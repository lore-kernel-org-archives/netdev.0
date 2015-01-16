From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next v4] rhashtable: Fix race in rhashtable_destroy() and use regular work_struct
Date: Fri, 16 Jan 2015 10:23:23 +0800
Message-ID: <1421375003-7389-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <sergei.shtylyov@cogentembedded.com>,
	<netdev@vger.kernel.org>
To: <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:59543 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932271AbbAPCX4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2015 21:23:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When we put our declared work task in the global workqueue with
schedule_delayed_work(), its delay parameter is always zero.
Therefore, we should define a regular work in rhashtable structure
instead of a delayed work.

By the way, we add a condition to check whether resizing functions
are NULL before cancelling the work, avoiding to cancel an
uninitialized work.

Lastly, while we wait for all work items we submitted before to run
to completion with cancel_delayed_work(), ht->mutex has been taken in
rhashtable_destroy(). Moreover, cancel_delayed_work() doesn't return
until all work items are accomplished, and when work items are
scheduled, the work's function - rht_deferred_worker() will be called.
However, as rht_deferred_worker() also needs to acquire the lock,
deadlock might happen at the moment as the lock is already held before.
So if the cancel work function is moved out of the lock covered scope,
this will avoid the deadlock.

Fixes: 97defe1 ("rhashtable: Per bucket locks & deferred expansion/shrinking")
Signed-off-by: Ying Xue <ying.xue@windriver.com>
Cc: Thomas Graf <tgraf@suug.ch>
Signed-off-by: Ying Xue <ying.xue@windriver.com>
---
Change log:
v4:
  - Add an empty line in rhashtable_destroy()
  - Revise commit description
v3:
  - Revise patch header description from Thomas's suggestion
v2:
  - Move cancel_work_sync() out of ht->mutex lock scope from Thomas's
    comments
 include/linux/rhashtable.h |    2 +-
 lib/rhashtable.c           |   12 ++++++------
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/include/linux/rhashtable.h b/include/linux/rhashtable.h
index 9570832..a2562ed 100644
--- a/include/linux/rhashtable.h
+++ b/include/linux/rhashtable.h
@@ -119,7 +119,7 @@ struct rhashtable {
 	atomic_t			nelems;
 	atomic_t			shift;
 	struct rhashtable_params	p;
-	struct delayed_work             run_work;
+	struct work_struct		run_work;
 	struct mutex                    mutex;
 	bool                            being_destroyed;
 };
diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index aca6998..84a78e3 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -485,7 +485,7 @@ static void rht_deferred_worker(struct work_struct *work)
 	struct rhashtable *ht;
 	struct bucket_table *tbl;
 
-	ht = container_of(work, struct rhashtable, run_work.work);
+	ht = container_of(work, struct rhashtable, run_work);
 	mutex_lock(&ht->mutex);
 	tbl = rht_dereference(ht->tbl, ht);
 
@@ -507,7 +507,7 @@ static void rhashtable_wakeup_worker(struct rhashtable *ht)
 	if (tbl == new_tbl &&
 	    ((ht->p.grow_decision && ht->p.grow_decision(ht, size)) ||
 	     (ht->p.shrink_decision && ht->p.shrink_decision(ht, size))))
-		schedule_delayed_work(&ht->run_work, 0);
+		schedule_work(&ht->run_work);
 }
 
 static void __rhashtable_insert(struct rhashtable *ht, struct rhash_head *obj,
@@ -903,7 +903,7 @@ int rhashtable_init(struct rhashtable *ht, struct rhashtable_params *params)
 		get_random_bytes(&ht->p.hash_rnd, sizeof(ht->p.hash_rnd));
 
 	if (ht->p.grow_decision || ht->p.shrink_decision)
-		INIT_DEFERRABLE_WORK(&ht->run_work, rht_deferred_worker);
+		INIT_WORK(&ht->run_work, rht_deferred_worker);
 
 	return 0;
 }
@@ -921,11 +921,11 @@ void rhashtable_destroy(struct rhashtable *ht)
 {
 	ht->being_destroyed = true;
 
-	mutex_lock(&ht->mutex);
+	if (ht->p.grow_decision || ht->p.shrink_decision)
+		cancel_work_sync(&ht->run_work);
 
-	cancel_delayed_work(&ht->run_work);
+	mutex_lock(&ht->mutex);
 	bucket_table_free(rht_dereference(ht->tbl, ht));
-
 	mutex_unlock(&ht->mutex);
 }
 EXPORT_SYMBOL_GPL(rhashtable_destroy);
-- 
1.7.9.5
