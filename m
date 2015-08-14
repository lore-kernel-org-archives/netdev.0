From: Phil Sutter <phil@nwl.cc>
Subject: [PATCH] rhashtable-test: extend to test concurrency
Date: Sat, 15 Aug 2015 00:37:15 +0200
Message-ID: <1439591835-30357-1-git-send-email-phil@nwl.cc>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net
To: Thomas Graf <tgraf@suug.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

After having tested insertion, lookup, table walk and removal, spawn a
number of threads running operations on the same rhashtable. Each of
them will:

1) insert it's own set of objects,
2) lookup every successfully inserted object and finally
3) remove objects in several rounds until all of them have been removed,
   making sure the remaining ones are still found after each round.

This should put a good amount of load onto the system and due to
synchronising thread startup via two semaphores also extensive
concurrent table access.

The default number of ten threads returned within half a second on my
local VM with two cores. Running 200 threads took about four seconds. If
slow systems suffer too much from this though, the default could be
lowered or even set to zero so this extended test does not run at all by
default.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 lib/test_rhashtable.c | 155 +++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 154 insertions(+), 1 deletion(-)

diff --git a/lib/test_rhashtable.c b/lib/test_rhashtable.c
index 9af7cef..a26d76f 100644
--- a/lib/test_rhashtable.c
+++ b/lib/test_rhashtable.c
@@ -16,9 +16,11 @@
 #include <linux/init.h>
 #include <linux/jhash.h>
 #include <linux/kernel.h>
+#include <linux/kthread.h>
 #include <linux/module.h>
 #include <linux/rcupdate.h>
 #include <linux/rhashtable.h>
+#include <linux/semaphore.h>
 #include <linux/slab.h>
 #include <linux/sched.h>
 
@@ -45,11 +47,21 @@ static int size = 8;
 module_param(size, int, 0);
 MODULE_PARM_DESC(size, "Initial size hint of table (default: 8)");
 
+static int tcount = 10;
+module_param(tcount, int, 0);
+MODULE_PARM_DESC(tcount, "Number of threads to spawn (default: 10)");
+
 struct test_obj {
 	int			value;
 	struct rhash_head	node;
 };
 
+struct thread_data {
+	int id;
+	struct task_struct *task;
+	struct test_obj *objs;
+};
+
 static struct test_obj array[MAX_ENTRIES];
 
 static struct rhashtable_params test_rht_params = {
@@ -60,6 +72,9 @@ static struct rhashtable_params test_rht_params = {
 	.nulls_base = (3U << RHT_BASE_SHIFT),
 };
 
+static struct semaphore prestart_sem;
+static struct semaphore startup_sem = __SEMAPHORE_INITIALIZER(startup_sem, 0);
+
 static int __init test_rht_lookup(struct rhashtable *ht)
 {
 	unsigned int i;
@@ -200,10 +215,97 @@ static s64 __init test_rhashtable(struct rhashtable *ht)
 
 static struct rhashtable ht;
 
+static int thread_lookup_test(struct thread_data *tdata)
+{
+	int i, err = 0;
+
+	for (i = 0; i < entries; i++) {
+		struct test_obj *obj;
+		int key = (tdata->id << 16) | i;
+
+		obj = rhashtable_lookup_fast(&ht, &key, test_rht_params);
+		if (obj && (tdata->objs[i].value == TEST_INSERT_FAIL)) {
+			pr_err("  found unexpected object %d\n", key);
+			err++;
+		} else if (!obj && (tdata->objs[i].value != TEST_INSERT_FAIL)) {
+			pr_err("  object %d not found!\n", key);
+			err++;
+		} else if (obj && (obj->value != key)) {
+			pr_err("  wrong object returned (got %d, expected %d)\n",
+			       obj->value, key);
+			err++;
+		}
+	}
+	return err;
+}
+
+static int threadfunc(void *data)
+{
+	int i, step, err = 0, insert_fails = 0;
+	struct thread_data *tdata = data;
+
+	up(&prestart_sem);
+	if (down_interruptible(&startup_sem))
+		pr_err("  thread[%d]: down_interruptible failed\n", tdata->id);
+
+	for (i = 0; i < entries; i++) {
+		tdata->objs[i].value = (tdata->id << 16) | i;
+		err = rhashtable_insert_fast(&ht, &tdata->objs[i].node,
+		                             test_rht_params);
+		if (err == -ENOMEM || err == -EBUSY) {
+			tdata->objs[i].value = TEST_INSERT_FAIL;
+			insert_fails++;
+		} else if (err) {
+			pr_err("  thread[%d]: rhashtable_insert_fast failed\n",
+			       tdata->id);
+			goto out;
+		}
+	}
+	if (insert_fails)
+		pr_info("  thread[%d]: %d insert failures\n",
+		        tdata->id, insert_fails);
+
+	err = thread_lookup_test(tdata);
+	if (err) {
+		pr_err("  thread[%d]: rhashtable_lookup_test failed\n",
+		       tdata->id);
+		goto out;
+	}
+
+	for (step = 10; step > 0; step--) {
+		for (i = 0; i < entries; i += step) {
+			if (tdata->objs[i].value == TEST_INSERT_FAIL)
+				continue;
+			err = rhashtable_remove_fast(&ht, &tdata->objs[i].node,
+			                             test_rht_params);
+			if (err) {
+				pr_err("  thread[%d]: rhashtable_remove_fast failed\n",
+				       tdata->id);
+				goto out;
+			}
+			tdata->objs[i].value = TEST_INSERT_FAIL;
+		}
+		err = thread_lookup_test(tdata);
+		if (err) {
+			pr_err("  thread[%d]: rhashtable_lookup_test (2) failed\n",
+			       tdata->id);
+			goto out;
+		}
+	}
+out:
+	while (!kthread_should_stop()) {
+		set_current_state(TASK_INTERRUPTIBLE);
+		schedule();
+	}
+	return err;
+}
+
 static int __init test_rht_init(void)
 {
-	int i, err;
+	int i, err, started_threads = 0, failed_threads = 0;
 	u64 total_time = 0;
+	struct thread_data *tdata;
+	struct test_obj *objs;
 
 	entries = min(entries, MAX_ENTRIES);
 
@@ -239,6 +341,57 @@ static int __init test_rht_init(void)
 	do_div(total_time, runs);
 	pr_info("Average test time: %llu\n", total_time);
 
+	if (!tcount)
+		return 0;
+
+	pr_info("Testing concurrent rhashtable access from %d threads\n",
+	        tcount);
+	sema_init(&prestart_sem, 1 - tcount);
+	tdata = vzalloc(tcount * sizeof(struct thread_data));
+	if (!tdata)
+		return -ENOMEM;
+	objs  = vzalloc(tcount * entries * sizeof(struct test_obj));
+	if (!objs) {
+		vfree(tdata);
+		return -ENOMEM;
+	}
+
+	err = rhashtable_init(&ht, &test_rht_params);
+	if (err < 0) {
+		pr_warn("Test failed: Unable to initialize hashtable: %d\n",
+			err);
+		vfree(tdata);
+		vfree(objs);
+		return -EINVAL;
+	}
+	for (i = 0; i < tcount; i++) {
+		tdata[i].id = i;
+		tdata[i].objs = objs + i * entries;
+		tdata[i].task = kthread_run(threadfunc, &tdata[i],
+		                            "rhashtable_thrad[%d]", i);
+		if (IS_ERR(tdata[i].task))
+			pr_err(" kthread_run failed for thread %d\n", i);
+		else
+			started_threads++;
+	}
+	if (down_interruptible(&prestart_sem))
+		pr_err("  down interruptible failed\n");
+	for (i = 0; i < tcount; i++)
+		up(&startup_sem);
+	for (i = 0; i < tcount; i++) {
+		if (IS_ERR(tdata[i].task))
+			continue;
+		if ((err = kthread_stop(tdata[i].task))) {
+			pr_warn("Test failed: thread %d returned: %d\n",
+			        i, err);
+			failed_threads++;
+		}
+	}
+	pr_info("Started %d threads, %d failed\n",
+	        started_threads, failed_threads);
+	rhashtable_destroy(&ht);
+	vfree(tdata);
+	vfree(objs);
 	return 0;
 }
 
-- 
2.1.2
