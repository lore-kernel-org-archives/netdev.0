From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next 1/4] test_rhashtable: don't allocate huge static array
Date: Mon, 18 Sep 2017 23:07:08 +0200
Message-ID: <20170918210711.10202-2-fw@strlen.de>
References: <20170918210711.10202-1-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:51750 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750972AbdIRVG6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 17:06:58 -0400
In-Reply-To: <20170918210711.10202-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 lib/test_rhashtable.c | 27 ++++++++++++++++-----------
 1 file changed, 16 insertions(+), 11 deletions(-)

diff --git a/lib/test_rhashtable.c b/lib/test_rhashtable.c
index 0ffca990a833..c40d6e636f33 100644
--- a/lib/test_rhashtable.c
+++ b/lib/test_rhashtable.c
@@ -72,8 +72,6 @@ struct thread_data {
 	struct test_obj *objs;
 };
 
-static struct test_obj array[MAX_ENTRIES];
-
 static struct rhashtable_params test_rht_params = {
 	.head_offset = offsetof(struct test_obj, node),
 	.key_offset = offsetof(struct test_obj, value),
@@ -85,7 +83,7 @@ static struct rhashtable_params test_rht_params = {
 static struct semaphore prestart_sem;
 static struct semaphore startup_sem = __SEMAPHORE_INITIALIZER(startup_sem, 0);
 
-static int insert_retry(struct rhashtable *ht, struct rhash_head *obj,
+static int insert_retry(struct rhashtable *ht, struct test_obj *obj,
                         const struct rhashtable_params params)
 {
 	int err, retries = -1, enomem_retries = 0;
@@ -93,7 +91,7 @@ static int insert_retry(struct rhashtable *ht, struct rhash_head *obj,
 	do {
 		retries++;
 		cond_resched();
-		err = rhashtable_insert_fast(ht, obj, params);
+		err = rhashtable_insert_fast(ht, &obj->node, params);
 		if (err == -ENOMEM && enomem_retry) {
 			enomem_retries++;
 			err = -EBUSY;
@@ -107,7 +105,7 @@ static int insert_retry(struct rhashtable *ht, struct rhash_head *obj,
 	return err ? : retries;
 }
 
-static int __init test_rht_lookup(struct rhashtable *ht)
+static int __init test_rht_lookup(struct rhashtable *ht, struct test_obj *array)
 {
 	unsigned int i;
 
@@ -186,7 +184,7 @@ static void test_bucket_stats(struct rhashtable *ht)
 		pr_warn("Test failed: Total count mismatch ^^^");
 }
 
-static s64 __init test_rhashtable(struct rhashtable *ht)
+static s64 __init test_rhashtable(struct rhashtable *ht, struct test_obj *array)
 {
 	struct test_obj *obj;
 	int err;
@@ -203,7 +201,7 @@ static s64 __init test_rhashtable(struct rhashtable *ht)
 		struct test_obj *obj = &array[i];
 
 		obj->value.id = i * 2;
-		err = insert_retry(ht, &obj->node, test_rht_params);
+		err = insert_retry(ht, obj, test_rht_params);
 		if (err > 0)
 			insert_retries += err;
 		else if (err)
@@ -216,7 +214,7 @@ static s64 __init test_rhashtable(struct rhashtable *ht)
 
 	test_bucket_stats(ht);
 	rcu_read_lock();
-	test_rht_lookup(ht);
+	test_rht_lookup(ht, array);
 	rcu_read_unlock();
 
 	test_bucket_stats(ht);
@@ -286,7 +284,7 @@ static int threadfunc(void *data)
 	for (i = 0; i < entries; i++) {
 		tdata->objs[i].value.id = i;
 		tdata->objs[i].value.tid = tdata->id;
-		err = insert_retry(&ht, &tdata->objs[i].node, test_rht_params);
+		err = insert_retry(&ht, &tdata->objs[i], test_rht_params);
 		if (err > 0) {
 			insert_retries += err;
 		} else if (err) {
@@ -349,6 +347,10 @@ static int __init test_rht_init(void)
 	test_rht_params.max_size = max_size ? : roundup_pow_of_two(entries);
 	test_rht_params.nelem_hint = size;
 
+	objs = vzalloc((test_rht_params.max_size + 1) * sizeof(struct test_obj));
+	if (!objs)
+		return -ENOMEM;
+
 	pr_info("Running rhashtable test nelem=%d, max_size=%d, shrinking=%d\n",
 		size, max_size, shrinking);
 
@@ -356,7 +358,8 @@ static int __init test_rht_init(void)
 		s64 time;
 
 		pr_info("Test %02d:\n", i);
-		memset(&array, 0, sizeof(array));
+		memset(objs, 0, test_rht_params.max_size * sizeof(struct test_obj));
+
 		err = rhashtable_init(&ht, &test_rht_params);
 		if (err < 0) {
 			pr_warn("Test failed: Unable to initialize hashtable: %d\n",
@@ -364,9 +367,10 @@ static int __init test_rht_init(void)
 			continue;
 		}
 
-		time = test_rhashtable(&ht);
+		time = test_rhashtable(&ht, objs);
 		rhashtable_destroy(&ht);
 		if (time < 0) {
+			vfree(objs);
 			pr_warn("Test failed: return code %lld\n", time);
 			return -EINVAL;
 		}
@@ -374,6 +378,7 @@ static int __init test_rht_init(void)
 		total_time += time;
 	}
 
+	vfree(objs);
 	do_div(total_time, runs);
 	pr_info("Average test time: %llu\n", total_time);
 
-- 
2.13.5
