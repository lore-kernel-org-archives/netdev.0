From: Phil Sutter <phil@nwl.cc>
Subject: [PATCH v2 2/4] rhashtable-test: retry insert operations
Date: Fri, 20 Nov 2015 18:17:18 +0100
Message-ID: <1448039840-11367-3-git-send-email-phil@nwl.cc>
References: <1448039840-11367-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	tgraf@suug.ch, fengguang.wu@intel.com, wfg@linux.intel.com,
	lkp@01.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:41935 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760114AbbKTRRX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Nov 2015 12:17:23 -0500
In-Reply-To: <1448039840-11367-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After adding cond_resched() calls to threadfunc(), a surprisingly high
rate of insert failures occurred probably due to table resizes getting a
better chance to run in background. To not soften up the remaining
tests, retry inserts until they either succeed or fail permanently.

Also change the non-threaded test to retry insert operations, too.

Suggested-by: Thomas Graf <tgraf@suug.ch>
Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 lib/test_rhashtable.c | 53 ++++++++++++++++++++++++++++-----------------------
 1 file changed, 29 insertions(+), 24 deletions(-)

diff --git a/lib/test_rhashtable.c b/lib/test_rhashtable.c
index 63654e3..cfc3440 100644
--- a/lib/test_rhashtable.c
+++ b/lib/test_rhashtable.c
@@ -76,6 +76,20 @@ static struct rhashtable_params test_rht_params = {
 static struct semaphore prestart_sem;
 static struct semaphore startup_sem = __SEMAPHORE_INITIALIZER(startup_sem, 0);
 
+static int insert_retry(struct rhashtable *ht, struct rhash_head *obj,
+                        const struct rhashtable_params params)
+{
+	int err, retries = -1;
+
+	do {
+		retries++;
+		cond_resched();
+		err = rhashtable_insert_fast(ht, obj, params);
+	} while (err == -EBUSY);
+
+	return err ? : retries;
+}
+
 static int __init test_rht_lookup(struct rhashtable *ht)
 {
 	unsigned int i;
@@ -157,7 +171,7 @@ static s64 __init test_rhashtable(struct rhashtable *ht)
 {
 	struct test_obj *obj;
 	int err;
-	unsigned int i, insert_fails = 0;
+	unsigned int i, insert_retries = 0;
 	s64 start, end;
 
 	/*
@@ -170,22 +184,16 @@ static s64 __init test_rhashtable(struct rhashtable *ht)
 		struct test_obj *obj = &array[i];
 
 		obj->value = i * 2;
-
-		err = rhashtable_insert_fast(ht, &obj->node, test_rht_params);
-		if (err == -ENOMEM || err == -EBUSY) {
-			/* Mark failed inserts but continue */
-			obj->value = TEST_INSERT_FAIL;
-			insert_fails++;
-		} else if (err) {
+		err = insert_retry(ht, &obj->node, test_rht_params);
+		if (err > 0)
+			insert_retries += err;
+		else if (err)
 			return err;
-		}
-
-		cond_resched();
 	}
 
-	if (insert_fails)
-		pr_info("  %u insertions failed due to memory pressure\n",
-			insert_fails);
+	if (insert_retries)
+		pr_info("  %u insertions retried due to memory pressure\n",
+			insert_retries);
 
 	test_bucket_stats(ht);
 	rcu_read_lock();
@@ -244,7 +252,7 @@ static int thread_lookup_test(struct thread_data *tdata)
 
 static int threadfunc(void *data)
 {
-	int i, step, err = 0, insert_fails = 0;
+	int i, step, err = 0, insert_retries = 0;
 	struct thread_data *tdata = data;
 
 	up(&prestart_sem);
@@ -253,21 +261,18 @@ static int threadfunc(void *data)
 
 	for (i = 0; i < entries; i++) {
 		tdata->objs[i].value = (tdata->id << 16) | i;
-		cond_resched();
-		err = rhashtable_insert_fast(&ht, &tdata->objs[i].node,
-		                             test_rht_params);
-		if (err == -ENOMEM || err == -EBUSY) {
-			tdata->objs[i].value = TEST_INSERT_FAIL;
-			insert_fails++;
+		err = insert_retry(&ht, &tdata->objs[i].node, test_rht_params);
+		if (err > 0) {
+			insert_retries += err;
 		} else if (err) {
 			pr_err("  thread[%d]: rhashtable_insert_fast failed\n",
 			       tdata->id);
 			goto out;
 		}
 	}
-	if (insert_fails)
-		pr_info("  thread[%d]: %d insert failures\n",
-		        tdata->id, insert_fails);
+	if (insert_retries)
+		pr_info("  thread[%d]: %u insertions retried due to memory pressure\n",
+			tdata->id, insert_retries);
 
 	err = thread_lookup_test(tdata);
 	if (err) {
-- 
2.1.2
