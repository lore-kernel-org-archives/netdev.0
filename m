From: Florian Westphal <fw@strlen.de>
Subject: [net-next v2 4/4] test_rhashtable: add test case for rhl_table interface
Date: Wed, 20 Sep 2017 01:12:14 +0200
Message-ID: <20170919231214.2281-5-fw@strlen.de>
References: <20170919231214.2281-1-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:57790 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751618AbdISXMJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 19:12:09 -0400
In-Reply-To: <20170919231214.2281-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

also test rhltable.  rhltable remove operations are slow as
deletions require a list walk, thus test with 1/16th of the given
entry count number to get a run duration similar to rhashtable one.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 change since v1:
 place struct rhltable in initdata section to avoid large onstack
 allocation warnings when lockdep is enabled.

 lib/test_rhashtable.c | 196 +++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 194 insertions(+), 2 deletions(-)

diff --git a/lib/test_rhashtable.c b/lib/test_rhashtable.c
index 1eee90e6e394..de4d0584631a 100644
--- a/lib/test_rhashtable.c
+++ b/lib/test_rhashtable.c
@@ -23,6 +23,7 @@
 #include <linux/semaphore.h>
 #include <linux/slab.h>
 #include <linux/sched.h>
+#include <linux/random.h>
 #include <linux/vmalloc.h>
 
 #define MAX_ENTRIES	1000000
@@ -66,6 +67,11 @@ struct test_obj {
 	struct rhash_head	node;
 };
 
+struct test_obj_rhl {
+	struct test_obj_val	value;
+	struct rhlist_head	list_node;
+};
+
 struct thread_data {
 	unsigned int entries;
 	int id;
@@ -245,6 +251,186 @@ static s64 __init test_rhashtable(struct rhashtable *ht, struct test_obj *array,
 }
 
 static struct rhashtable ht;
+static struct rhltable rhlt __initdata;
+
+static int __init test_rhltable(unsigned int entries)
+{
+	struct test_obj_rhl *rhl_test_objects;
+	unsigned long *obj_in_table;
+	unsigned int i, j, k;
+	int ret, err;
+
+	if (entries == 0)
+		entries = 1;
+
+	rhl_test_objects = vzalloc(sizeof(*rhl_test_objects) * entries);
+	if (!rhl_test_objects)
+		return -ENOMEM;
+
+	ret = -ENOMEM;
+	obj_in_table = vzalloc(BITS_TO_LONGS(entries) * sizeof(unsigned long));
+	if (!obj_in_table)
+		goto out_free;
+
+	/* nulls_base not supported in rhlist interface */
+	test_rht_params.nulls_base = 0;
+	err = rhltable_init(&rhlt, &test_rht_params);
+	if (WARN_ON(err))
+		goto out_free;
+
+	k = prandom_u32();
+	ret = 0;
+	for (i = 0; i < entries; i++) {
+		rhl_test_objects[i].value.id = k;
+		err = rhltable_insert(&rhlt, &rhl_test_objects[i].list_node,
+				      test_rht_params);
+		if (WARN(err, "error %d on element %d\n", err, i))
+			break;
+		if (err == 0)
+			set_bit(i, obj_in_table);
+	}
+
+	if (err)
+		ret = err;
+
+	pr_info("test %d add/delete pairs into rhlist\n", entries);
+	for (i = 0; i < entries; i++) {
+		struct rhlist_head *h, *pos;
+		struct test_obj_rhl *obj;
+		struct test_obj_val key = {
+			.id = k,
+		};
+		bool found;
+
+		rcu_read_lock();
+		h = rhltable_lookup(&rhlt, &key, test_rht_params);
+		if (WARN(!h, "key not found during iteration %d of %d", i, entries)) {
+			rcu_read_unlock();
+			break;
+		}
+
+		if (i) {
+			j = i - 1;
+			rhl_for_each_entry_rcu(obj, pos, h, list_node) {
+				if (WARN(pos == &rhl_test_objects[j].list_node, "old element found, should be gone"))
+					break;
+			}
+		}
+
+		cond_resched_rcu();
+
+		found = false;
+
+		rhl_for_each_entry_rcu(obj, pos, h, list_node) {
+			if (pos == &rhl_test_objects[i].list_node) {
+				found = true;
+				break;
+			}
+		}
+
+		rcu_read_unlock();
+
+		if (WARN(!found, "element %d not found", i))
+			break;
+
+		err = rhltable_remove(&rhlt, &rhl_test_objects[i].list_node, test_rht_params);
+		WARN(err, "rhltable_remove: err %d for iteration %d\n", err, i);
+		if (err == 0)
+			clear_bit(i, obj_in_table);
+	}
+
+	if (ret == 0 && err)
+		ret = err;
+
+	for (i = 0; i < entries; i++) {
+		WARN(test_bit(i, obj_in_table), "elem %d allegedly still present", i);
+
+		err = rhltable_insert(&rhlt, &rhl_test_objects[i].list_node,
+				      test_rht_params);
+		if (WARN(err, "error %d on element %d\n", err, i))
+			break;
+		if (err == 0)
+			set_bit(i, obj_in_table);
+	}
+
+	pr_info("test %d random rhlist add/delete operations\n", entries);
+	for (j = 0; j < entries; j++) {
+		u32 i = prandom_u32_max(entries);
+		u32 prand = prandom_u32();
+
+		cond_resched();
+
+		if (prand == 0)
+			prand = prandom_u32();
+
+		if (prand & 1) {
+			prand >>= 1;
+			continue;
+		}
+
+		err = rhltable_remove(&rhlt, &rhl_test_objects[i].list_node, test_rht_params);
+		if (test_bit(i, obj_in_table)) {
+			clear_bit(i, obj_in_table);
+			if (WARN(err, "cannot remove element at slot %d", i))
+				continue;
+		} else {
+			if (WARN(err != -ENOENT, "removed non-existant element %d, error %d not %d",
+			     i, err, -ENOENT))
+				continue;
+		}
+
+		if (prand & 1) {
+			prand >>= 1;
+			continue;
+		}
+
+		err = rhltable_insert(&rhlt, &rhl_test_objects[i].list_node, test_rht_params);
+		if (err == 0) {
+			if (WARN(test_and_set_bit(i, obj_in_table), "succeeded to insert same object %d", i))
+				continue;
+		} else {
+			if (WARN(!test_bit(i, obj_in_table), "failed to insert object %d", i))
+				continue;
+		}
+
+		if (prand & 1) {
+			prand >>= 1;
+			continue;
+		}
+
+		i = prandom_u32_max(entries);
+		if (test_bit(i, obj_in_table)) {
+			err = rhltable_remove(&rhlt, &rhl_test_objects[i].list_node, test_rht_params);
+			WARN(err, "cannot remove element at slot %d", i);
+			if (err == 0)
+				clear_bit(i, obj_in_table);
+		} else {
+			err = rhltable_insert(&rhlt, &rhl_test_objects[i].list_node, test_rht_params);
+			WARN(err, "failed to insert object %d", i);
+			if (err == 0)
+				set_bit(i, obj_in_table);
+		}
+	}
+
+	for (i = 0; i < entries; i++) {
+		cond_resched();
+		err = rhltable_remove(&rhlt, &rhl_test_objects[i].list_node, test_rht_params);
+		if (test_bit(i, obj_in_table)) {
+			if (WARN(err, "cannot remove element at slot %d", i))
+				continue;
+		} else {
+			if (WARN(err != -ENOENT, "removed non-existant element, error %d not %d",
+				 err, -ENOENT))
+			continue;
+		}
+	}
+
+	rhltable_destroy(&rhlt);
+out_free:
+	vfree(rhl_test_objects);
+	vfree(obj_in_table);
+	return ret;
+}
 
 static int __init test_rhashtable_max(struct test_obj *array,
 				      unsigned int entries)
@@ -480,11 +666,17 @@ static int __init test_rht_init(void)
 			failed_threads++;
 		}
 	}
-	pr_info("Started %d threads, %d failed\n",
-	        started_threads, failed_threads);
 	rhashtable_destroy(&ht);
 	vfree(tdata);
 	vfree(objs);
+
+	/*
+	 * rhltable_remove is very expensive, default values can cause test
+	 * to run for 2 minutes or more,  use a smaller number instead.
+	 */
+	err = test_rhltable(entries / 16);
+	pr_info("Started %d threads, %d failed, rhltable test returns %d\n",
+	        started_threads, failed_threads, err);
 	return 0;
 }
 
-- 
2.13.5
