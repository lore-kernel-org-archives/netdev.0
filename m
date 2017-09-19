From: Florian Westphal <fw@strlen.de>
Subject: [net-next v2 2/4] test_rhashtable: don't use global entries variable
Date: Wed, 20 Sep 2017 01:12:12 +0200
Message-ID: <20170919231214.2281-3-fw@strlen.de>
References: <20170919231214.2281-1-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:57780 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751618AbdISXMC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 19:12:02 -0400
In-Reply-To: <20170919231214.2281-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

pass the entries to test as an argument instead.
Followup patch will add an rhlist test case; rhlist delete opererations
are slow so we need to use a smaller number to test it.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 lib/test_rhashtable.c | 37 +++++++++++++++++++++++--------------
 1 file changed, 23 insertions(+), 14 deletions(-)

diff --git a/lib/test_rhashtable.c b/lib/test_rhashtable.c
index c40d6e636f33..69f5b3849980 100644
--- a/lib/test_rhashtable.c
+++ b/lib/test_rhashtable.c
@@ -28,9 +28,9 @@
 #define MAX_ENTRIES	1000000
 #define TEST_INSERT_FAIL INT_MAX
 
-static int entries = 50000;
-module_param(entries, int, 0);
-MODULE_PARM_DESC(entries, "Number of entries to add (default: 50000)");
+static int parm_entries = 50000;
+module_param(parm_entries, int, 0);
+MODULE_PARM_DESC(parm_entries, "Number of entries to add (default: 50000)");
 
 static int runs = 4;
 module_param(runs, int, 0);
@@ -67,6 +67,7 @@ struct test_obj {
 };
 
 struct thread_data {
+	unsigned int entries;
 	int id;
 	struct task_struct *task;
 	struct test_obj *objs;
@@ -105,11 +106,12 @@ static int insert_retry(struct rhashtable *ht, struct test_obj *obj,
 	return err ? : retries;
 }
 
-static int __init test_rht_lookup(struct rhashtable *ht, struct test_obj *array)
+static int __init test_rht_lookup(struct rhashtable *ht, struct test_obj *array,
+				  unsigned int entries)
 {
 	unsigned int i;
 
-	for (i = 0; i < entries * 2; i++) {
+	for (i = 0; i < entries; i++) {
 		struct test_obj *obj;
 		bool expected = !(i % 2);
 		struct test_obj_val key = {
@@ -142,7 +144,7 @@ static int __init test_rht_lookup(struct rhashtable *ht, struct test_obj *array)
 	return 0;
 }
 
-static void test_bucket_stats(struct rhashtable *ht)
+static void test_bucket_stats(struct rhashtable *ht, unsigned int entries)
 {
 	unsigned int err, total = 0, chain_len = 0;
 	struct rhashtable_iter hti;
@@ -184,7 +186,8 @@ static void test_bucket_stats(struct rhashtable *ht)
 		pr_warn("Test failed: Total count mismatch ^^^");
 }
 
-static s64 __init test_rhashtable(struct rhashtable *ht, struct test_obj *array)
+static s64 __init test_rhashtable(struct rhashtable *ht, struct test_obj *array,
+				  unsigned int entries)
 {
 	struct test_obj *obj;
 	int err;
@@ -212,12 +215,12 @@ static s64 __init test_rhashtable(struct rhashtable *ht, struct test_obj *array)
 		pr_info("  %u insertions retried due to memory pressure\n",
 			insert_retries);
 
-	test_bucket_stats(ht);
+	test_bucket_stats(ht, entries);
 	rcu_read_lock();
-	test_rht_lookup(ht, array);
+	test_rht_lookup(ht, array, entries);
 	rcu_read_unlock();
 
-	test_bucket_stats(ht);
+	test_bucket_stats(ht, entries);
 
 	pr_info("  Deleting %d keys\n", entries);
 	for (i = 0; i < entries; i++) {
@@ -245,6 +248,7 @@ static struct rhashtable ht;
 
 static int thread_lookup_test(struct thread_data *tdata)
 {
+	unsigned int entries = tdata->entries;
 	int i, err = 0;
 
 	for (i = 0; i < entries; i++) {
@@ -281,7 +285,7 @@ static int threadfunc(void *data)
 	if (down_interruptible(&startup_sem))
 		pr_err("  thread[%d]: down_interruptible failed\n", tdata->id);
 
-	for (i = 0; i < entries; i++) {
+	for (i = 0; i < tdata->entries; i++) {
 		tdata->objs[i].value.id = i;
 		tdata->objs[i].value.tid = tdata->id;
 		err = insert_retry(&ht, &tdata->objs[i], test_rht_params);
@@ -305,7 +309,7 @@ static int threadfunc(void *data)
 	}
 
 	for (step = 10; step > 0; step--) {
-		for (i = 0; i < entries; i += step) {
+		for (i = 0; i < tdata->entries; i += step) {
 			if (tdata->objs[i].value.id == TEST_INSERT_FAIL)
 				continue;
 			err = rhashtable_remove_fast(&ht, &tdata->objs[i].node,
@@ -336,12 +340,16 @@ static int threadfunc(void *data)
 
 static int __init test_rht_init(void)
 {
+	unsigned int entries;
 	int i, err, started_threads = 0, failed_threads = 0;
 	u64 total_time = 0;
 	struct thread_data *tdata;
 	struct test_obj *objs;
 
-	entries = min(entries, MAX_ENTRIES);
+	if (parm_entries < 0)
+		parm_entries = 1;
+
+	entries = min(parm_entries, MAX_ENTRIES);
 
 	test_rht_params.automatic_shrinking = shrinking;
 	test_rht_params.max_size = max_size ? : roundup_pow_of_two(entries);
@@ -367,7 +375,7 @@ static int __init test_rht_init(void)
 			continue;
 		}
 
-		time = test_rhashtable(&ht, objs);
+		time = test_rhashtable(&ht, objs, entries);
 		rhashtable_destroy(&ht);
 		if (time < 0) {
 			vfree(objs);
@@ -409,6 +417,7 @@ static int __init test_rht_init(void)
 	}
 	for (i = 0; i < tcount; i++) {
 		tdata[i].id = i;
+		tdata[i].entries = entries;
 		tdata[i].objs = objs + i * entries;
 		tdata[i].task = kthread_run(threadfunc, &tdata[i],
 		                            "rhashtable_thrad[%d]", i);
-- 
2.13.5
