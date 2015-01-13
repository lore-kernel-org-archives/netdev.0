From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next] rhashtable: unnecessary to use delayed work
Date: Tue, 13 Jan 2015 17:00:45 +0800
Message-ID: <1421139645-1588-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:34392 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751132AbbAMJBR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 04:01:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When we put our declared work task in the global workqueue with
schedule_delayed_work(), its delay parameter is always zero.
Therefore, we should define a normal work in rhashtable structure
instead of a delayed work.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Cc: Thomas Graf <tgraf@suug.ch>
---
 include/linux/rhashtable.h |    2 +-
 lib/rhashtable.c           |    8 ++++----
 2 files changed, 5 insertions(+), 5 deletions(-)

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
index ed6ae1a..a7959ed 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -476,7 +476,7 @@ static void rht_deferred_worker(struct work_struct *work)
 	struct rhashtable *ht;
 	struct bucket_table *tbl;
 
-	ht = container_of(work, struct rhashtable, run_work.work);
+	ht = container_of(work, struct rhashtable, run_work);
 	mutex_lock(&ht->mutex);
 	tbl = rht_dereference(ht->tbl, ht);
 
@@ -498,7 +498,7 @@ static void rhashtable_wakeup_worker(struct rhashtable *ht)
 	if (tbl == new_tbl &&
 	    ((ht->p.grow_decision && ht->p.grow_decision(ht, size)) ||
 	     (ht->p.shrink_decision && ht->p.shrink_decision(ht, size))))
-		schedule_delayed_work(&ht->run_work, 0);
+		schedule_work(&ht->run_work);
 }
 
 static void __rhashtable_insert(struct rhashtable *ht, struct rhash_head *obj,
@@ -894,7 +894,7 @@ int rhashtable_init(struct rhashtable *ht, struct rhashtable_params *params)
 		get_random_bytes(&ht->p.hash_rnd, sizeof(ht->p.hash_rnd));
 
 	if (ht->p.grow_decision || ht->p.shrink_decision)
-		INIT_DEFERRABLE_WORK(&ht->run_work, rht_deferred_worker);
+		INIT_WORK(&ht->run_work, rht_deferred_worker);
 
 	return 0;
 }
@@ -914,7 +914,7 @@ void rhashtable_destroy(struct rhashtable *ht)
 
 	mutex_lock(&ht->mutex);
 
-	cancel_delayed_work(&ht->run_work);
+	cancel_work_sync(&ht->run_work);
 	bucket_table_free(rht_dereference(ht->tbl, ht));
 
 	mutex_unlock(&ht->mutex);
-- 
1.7.9.5
