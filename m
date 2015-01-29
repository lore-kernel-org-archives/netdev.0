From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH] rhashtable: Make selftest modular
Date: Thu, 29 Jan 2015 15:40:25 +0100
Message-ID: <1422542425-20940-1-git-send-email-geert@linux-m68k.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Geert Uytterhoeven <geert@linux-m68k.org>
To: Thomas Graf <tgraf@suug.ch>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Allow the selftest on the resizable hash table to be built modular, just
like all other tests that do not depend on DEBUG_KERNEL.

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
This is against -next

Tested on m68k and arm.

 lib/Kconfig.debug     |   2 +-
 lib/Makefile          |   1 +
 lib/rhashtable.c      | 205 ---------------------------------------------
 lib/test_rhashtable.c | 227 ++++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 229 insertions(+), 206 deletions(-)
 create mode 100644 lib/test_rhashtable.c

diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index 68668f65ac0d26aa..385553a9e0e45d23 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -1605,7 +1605,7 @@ config TEST_KSTRTOX
 	tristate "Test kstrto*() family of functions at runtime"
 
 config TEST_RHASHTABLE
-	bool "Perform selftest on resizable hash table"
+	tristate "Perform selftest on resizable hash table"
 	default n
 	help
 	  Enable this option to test the rhashtable functions at boot.
diff --git a/lib/Makefile b/lib/Makefile
index b1dbda74ef65aeff..4755d43f3f4020d4 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -37,6 +37,7 @@ obj-$(CONFIG_TEST_LKM) += test_module.o
 obj-$(CONFIG_TEST_USER_COPY) += test_user_copy.o
 obj-$(CONFIG_TEST_BPF) += test_bpf.o
 obj-$(CONFIG_TEST_FIRMWARE) += test_firmware.o
+obj-$(CONFIG_TEST_RHASHTABLE) += test_rhashtable.o
 
 ifeq ($(CONFIG_DEBUG_KOBJECT),y)
 CFLAGS_kobject.o += -DDEBUG
diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index bc2d0d80d1f91e73..c41e21096373156a 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -935,208 +935,3 @@ void rhashtable_destroy(struct rhashtable *ht)
 	mutex_unlock(&ht->mutex);
 }
 EXPORT_SYMBOL_GPL(rhashtable_destroy);
-
-/**************************************************************************
- * Self Test
- **************************************************************************/
-
-#ifdef CONFIG_TEST_RHASHTABLE
-
-#define TEST_HT_SIZE	8
-#define TEST_ENTRIES	2048
-#define TEST_PTR	((void *) 0xdeadbeef)
-#define TEST_NEXPANDS	4
-
-struct test_obj {
-	void			*ptr;
-	int			value;
-	struct rhash_head	node;
-};
-
-static int __init test_rht_lookup(struct rhashtable *ht)
-{
-	unsigned int i;
-
-	for (i = 0; i < TEST_ENTRIES * 2; i++) {
-		struct test_obj *obj;
-		bool expected = !(i % 2);
-		u32 key = i;
-
-		obj = rhashtable_lookup(ht, &key);
-
-		if (expected && !obj) {
-			pr_warn("Test failed: Could not find key %u\n", key);
-			return -ENOENT;
-		} else if (!expected && obj) {
-			pr_warn("Test failed: Unexpected entry found for key %u\n",
-				key);
-			return -EEXIST;
-		} else if (expected && obj) {
-			if (obj->ptr != TEST_PTR || obj->value != i) {
-				pr_warn("Test failed: Lookup value mismatch %p!=%p, %u!=%u\n",
-					obj->ptr, TEST_PTR, obj->value, i);
-				return -EINVAL;
-			}
-		}
-	}
-
-	return 0;
-}
-
-static void test_bucket_stats(struct rhashtable *ht, bool quiet)
-{
-	unsigned int cnt, rcu_cnt, i, total = 0;
-	struct rhash_head *pos;
-	struct test_obj *obj;
-	struct bucket_table *tbl;
-
-	tbl = rht_dereference_rcu(ht->tbl, ht);
-	for (i = 0; i < tbl->size; i++) {
-		rcu_cnt = cnt = 0;
-
-		if (!quiet)
-			pr_info(" [%#4x/%zu]", i, tbl->size);
-
-		rht_for_each_entry_rcu(obj, pos, tbl, i, node) {
-			cnt++;
-			total++;
-			if (!quiet)
-				pr_cont(" [%p],", obj);
-		}
-
-		rht_for_each_entry_rcu(obj, pos, tbl, i, node)
-			rcu_cnt++;
-
-		if (rcu_cnt != cnt)
-			pr_warn("Test failed: Chain count mismach %d != %d",
-				cnt, rcu_cnt);
-
-		if (!quiet)
-			pr_cont("\n  [%#x] first element: %p, chain length: %u\n",
-				i, tbl->buckets[i], cnt);
-	}
-
-	pr_info("  Traversal complete: counted=%u, nelems=%u, entries=%d\n",
-		total, atomic_read(&ht->nelems), TEST_ENTRIES);
-
-	if (total != atomic_read(&ht->nelems) || total != TEST_ENTRIES)
-		pr_warn("Test failed: Total count mismatch ^^^");
-}
-
-static int __init test_rhashtable(struct rhashtable *ht)
-{
-	struct bucket_table *tbl;
-	struct test_obj *obj;
-	struct rhash_head *pos, *next;
-	int err;
-	unsigned int i;
-
-	/*
-	 * Insertion Test:
-	 * Insert TEST_ENTRIES into table with all keys even numbers
-	 */
-	pr_info("  Adding %d keys\n", TEST_ENTRIES);
-	for (i = 0; i < TEST_ENTRIES; i++) {
-		struct test_obj *obj;
-
-		obj = kzalloc(sizeof(*obj), GFP_KERNEL);
-		if (!obj) {
-			err = -ENOMEM;
-			goto error;
-		}
-
-		obj->ptr = TEST_PTR;
-		obj->value = i * 2;
-
-		rhashtable_insert(ht, &obj->node);
-	}
-
-	rcu_read_lock();
-	test_bucket_stats(ht, true);
-	test_rht_lookup(ht);
-	rcu_read_unlock();
-
-	for (i = 0; i < TEST_NEXPANDS; i++) {
-		pr_info("  Table expansion iteration %u...\n", i);
-		mutex_lock(&ht->mutex);
-		rhashtable_expand(ht);
-		mutex_unlock(&ht->mutex);
-
-		rcu_read_lock();
-		pr_info("  Verifying lookups...\n");
-		test_rht_lookup(ht);
-		rcu_read_unlock();
-	}
-
-	for (i = 0; i < TEST_NEXPANDS; i++) {
-		pr_info("  Table shrinkage iteration %u...\n", i);
-		mutex_lock(&ht->mutex);
-		rhashtable_shrink(ht);
-		mutex_unlock(&ht->mutex);
-
-		rcu_read_lock();
-		pr_info("  Verifying lookups...\n");
-		test_rht_lookup(ht);
-		rcu_read_unlock();
-	}
-
-	rcu_read_lock();
-	test_bucket_stats(ht, true);
-	rcu_read_unlock();
-
-	pr_info("  Deleting %d keys\n", TEST_ENTRIES);
-	for (i = 0; i < TEST_ENTRIES; i++) {
-		u32 key = i * 2;
-
-		obj = rhashtable_lookup(ht, &key);
-		BUG_ON(!obj);
-
-		rhashtable_remove(ht, &obj->node);
-		kfree(obj);
-	}
-
-	return 0;
-
-error:
-	tbl = rht_dereference_rcu(ht->tbl, ht);
-	for (i = 0; i < tbl->size; i++)
-		rht_for_each_entry_safe(obj, pos, next, tbl, i, node)
-			kfree(obj);
-
-	return err;
-}
-
-static int __init test_rht_init(void)
-{
-	struct rhashtable ht;
-	struct rhashtable_params params = {
-		.nelem_hint = TEST_HT_SIZE,
-		.head_offset = offsetof(struct test_obj, node),
-		.key_offset = offsetof(struct test_obj, value),
-		.key_len = sizeof(int),
-		.hashfn = jhash,
-		.nulls_base = (3U << RHT_BASE_SHIFT),
-		.grow_decision = rht_grow_above_75,
-		.shrink_decision = rht_shrink_below_30,
-	};
-	int err;
-
-	pr_info("Running resizable hashtable tests...\n");
-
-	err = rhashtable_init(&ht, &params);
-	if (err < 0) {
-		pr_warn("Test failed: Unable to initialize hashtable: %d\n",
-			err);
-		return err;
-	}
-
-	err = test_rhashtable(&ht);
-
-	rhashtable_destroy(&ht);
-
-	return err;
-}
-
-subsys_initcall(test_rht_init);
-
-#endif /* CONFIG_TEST_RHASHTABLE */
diff --git a/lib/test_rhashtable.c b/lib/test_rhashtable.c
new file mode 100644
index 0000000000000000..1dfeba73fc743718
--- /dev/null
+++ b/lib/test_rhashtable.c
@@ -0,0 +1,227 @@
+/*
+ * Resizable, Scalable, Concurrent Hash Table
+ *
+ * Copyright (c) 2014 Thomas Graf <tgraf@suug.ch>
+ * Copyright (c) 2008-2014 Patrick McHardy <kaber@trash.net>
+ *
+ * Based on the following paper:
+ * https://www.usenix.org/legacy/event/atc11/tech/final_files/Triplett.pdf
+ *
+ * Code partially derived from nft_hash
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+/**************************************************************************
+ * Self Test
+ **************************************************************************/
+
+#include <linux/init.h>
+#include <linux/jhash.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/rcupdate.h>
+#include <linux/rhashtable.h>
+#include <linux/slab.h>
+
+
+#define TEST_HT_SIZE	8
+#define TEST_ENTRIES	2048
+#define TEST_PTR	((void *) 0xdeadbeef)
+#define TEST_NEXPANDS	4
+
+struct test_obj {
+	void			*ptr;
+	int			value;
+	struct rhash_head	node;
+};
+
+static int __init test_rht_lookup(struct rhashtable *ht)
+{
+	unsigned int i;
+
+	for (i = 0; i < TEST_ENTRIES * 2; i++) {
+		struct test_obj *obj;
+		bool expected = !(i % 2);
+		u32 key = i;
+
+		obj = rhashtable_lookup(ht, &key);
+
+		if (expected && !obj) {
+			pr_warn("Test failed: Could not find key %u\n", key);
+			return -ENOENT;
+		} else if (!expected && obj) {
+			pr_warn("Test failed: Unexpected entry found for key %u\n",
+				key);
+			return -EEXIST;
+		} else if (expected && obj) {
+			if (obj->ptr != TEST_PTR || obj->value != i) {
+				pr_warn("Test failed: Lookup value mismatch %p!=%p, %u!=%u\n",
+					obj->ptr, TEST_PTR, obj->value, i);
+				return -EINVAL;
+			}
+		}
+	}
+
+	return 0;
+}
+
+static void test_bucket_stats(struct rhashtable *ht, bool quiet)
+{
+	unsigned int cnt, rcu_cnt, i, total = 0;
+	struct rhash_head *pos;
+	struct test_obj *obj;
+	struct bucket_table *tbl;
+
+	tbl = rht_dereference_rcu(ht->tbl, ht);
+	for (i = 0; i < tbl->size; i++) {
+		rcu_cnt = cnt = 0;
+
+		if (!quiet)
+			pr_info(" [%#4x/%zu]", i, tbl->size);
+
+		rht_for_each_entry_rcu(obj, pos, tbl, i, node) {
+			cnt++;
+			total++;
+			if (!quiet)
+				pr_cont(" [%p],", obj);
+		}
+
+		rht_for_each_entry_rcu(obj, pos, tbl, i, node)
+			rcu_cnt++;
+
+		if (rcu_cnt != cnt)
+			pr_warn("Test failed: Chain count mismach %d != %d",
+				cnt, rcu_cnt);
+
+		if (!quiet)
+			pr_cont("\n  [%#x] first element: %p, chain length: %u\n",
+				i, tbl->buckets[i], cnt);
+	}
+
+	pr_info("  Traversal complete: counted=%u, nelems=%u, entries=%d\n",
+		total, atomic_read(&ht->nelems), TEST_ENTRIES);
+
+	if (total != atomic_read(&ht->nelems) || total != TEST_ENTRIES)
+		pr_warn("Test failed: Total count mismatch ^^^");
+}
+
+static int __init test_rhashtable(struct rhashtable *ht)
+{
+	struct bucket_table *tbl;
+	struct test_obj *obj;
+	struct rhash_head *pos, *next;
+	int err;
+	unsigned int i;
+
+	/*
+	 * Insertion Test:
+	 * Insert TEST_ENTRIES into table with all keys even numbers
+	 */
+	pr_info("  Adding %d keys\n", TEST_ENTRIES);
+	for (i = 0; i < TEST_ENTRIES; i++) {
+		struct test_obj *obj;
+
+		obj = kzalloc(sizeof(*obj), GFP_KERNEL);
+		if (!obj) {
+			err = -ENOMEM;
+			goto error;
+		}
+
+		obj->ptr = TEST_PTR;
+		obj->value = i * 2;
+
+		rhashtable_insert(ht, &obj->node);
+	}
+
+	rcu_read_lock();
+	test_bucket_stats(ht, true);
+	test_rht_lookup(ht);
+	rcu_read_unlock();
+
+	for (i = 0; i < TEST_NEXPANDS; i++) {
+		pr_info("  Table expansion iteration %u...\n", i);
+		mutex_lock(&ht->mutex);
+		rhashtable_expand(ht);
+		mutex_unlock(&ht->mutex);
+
+		rcu_read_lock();
+		pr_info("  Verifying lookups...\n");
+		test_rht_lookup(ht);
+		rcu_read_unlock();
+	}
+
+	for (i = 0; i < TEST_NEXPANDS; i++) {
+		pr_info("  Table shrinkage iteration %u...\n", i);
+		mutex_lock(&ht->mutex);
+		rhashtable_shrink(ht);
+		mutex_unlock(&ht->mutex);
+
+		rcu_read_lock();
+		pr_info("  Verifying lookups...\n");
+		test_rht_lookup(ht);
+		rcu_read_unlock();
+	}
+
+	rcu_read_lock();
+	test_bucket_stats(ht, true);
+	rcu_read_unlock();
+
+	pr_info("  Deleting %d keys\n", TEST_ENTRIES);
+	for (i = 0; i < TEST_ENTRIES; i++) {
+		u32 key = i * 2;
+
+		obj = rhashtable_lookup(ht, &key);
+		BUG_ON(!obj);
+
+		rhashtable_remove(ht, &obj->node);
+		kfree(obj);
+	}
+
+	return 0;
+
+error:
+	tbl = rht_dereference_rcu(ht->tbl, ht);
+	for (i = 0; i < tbl->size; i++)
+		rht_for_each_entry_safe(obj, pos, next, tbl, i, node)
+			kfree(obj);
+
+	return err;
+}
+
+static int __init test_rht_init(void)
+{
+	struct rhashtable ht;
+	struct rhashtable_params params = {
+		.nelem_hint = TEST_HT_SIZE,
+		.head_offset = offsetof(struct test_obj, node),
+		.key_offset = offsetof(struct test_obj, value),
+		.key_len = sizeof(int),
+		.hashfn = jhash,
+		.nulls_base = (3U << RHT_BASE_SHIFT),
+		.grow_decision = rht_grow_above_75,
+		.shrink_decision = rht_shrink_below_30,
+	};
+	int err;
+
+	pr_info("Running resizable hashtable tests...\n");
+
+	err = rhashtable_init(&ht, &params);
+	if (err < 0) {
+		pr_warn("Test failed: Unable to initialize hashtable: %d\n",
+			err);
+		return err;
+	}
+
+	err = test_rhashtable(&ht);
+
+	rhashtable_destroy(&ht);
+
+	return err;
+}
+
+module_init(test_rht_init);
+
+MODULE_LICENSE("GPL v2");
-- 
1.9.1
