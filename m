From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next 4/6] rhashtable-test: Do not allocate individual test objects
Date: Thu, 30 Apr 2015 22:37:43 +0000
Message-ID: <1430433465-6066-5-git-send-email-tgraf@suug.ch>
References: <1430433465-6066-1-git-send-email-tgraf@suug.ch>
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:33731 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751605AbbD3WiA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2015 18:38:00 -0400
Received: by pacwv17 with SMTP id wv17so73208532pac.0
        for <netdev@vger.kernel.org>; Thu, 30 Apr 2015 15:38:00 -0700 (PDT)
In-Reply-To: <1430433465-6066-1-git-send-email-tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

By far the most expensive part of the selftest was the allocation
of entries. Using a static array allows to measure the rhashtable
operations.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 lib/test_rhashtable.c | 28 ++++++----------------------
 1 file changed, 6 insertions(+), 22 deletions(-)

diff --git a/lib/test_rhashtable.c b/lib/test_rhashtable.c
index d6d6719..935693e 100644
--- a/lib/test_rhashtable.c
+++ b/lib/test_rhashtable.c
@@ -49,6 +49,8 @@ struct test_obj {
 	struct rhash_head	node;
 };
 
+static struct test_obj array[MAX_ENTRIES];
+
 static struct rhashtable_params test_rht_params = {
 	.head_offset = offsetof(struct test_obj, node),
 	.key_offset = offsetof(struct test_obj, value),
@@ -129,9 +131,7 @@ static void test_bucket_stats(struct rhashtable *ht, bool quiet)
 
 static s64 __init test_rhashtable(struct rhashtable *ht)
 {
-	struct bucket_table *tbl;
 	struct test_obj *obj;
-	struct rhash_head *pos, *next;
 	int err;
 	unsigned int i;
 	s64 start, end;
@@ -143,21 +143,13 @@ static s64 __init test_rhashtable(struct rhashtable *ht)
 	pr_info("  Adding %d keys\n", entries);
 	start = ktime_get_ns();
 	for (i = 0; i < entries; i++) {
-		struct test_obj *obj;
-
-		obj = kzalloc(sizeof(*obj), GFP_KERNEL);
-		if (!obj) {
-			err = -ENOMEM;
-			goto error;
-		}
+		struct test_obj *obj = &array[i];
 
 		obj->value = i * 2;
 
 		err = rhashtable_insert_fast(ht, &obj->node, test_rht_params);
-		if (err) {
-			kfree(obj);
-			goto error;
-		}
+		if (err)
+			return err;
 	}
 
 	rcu_read_lock();
@@ -177,21 +169,12 @@ static s64 __init test_rhashtable(struct rhashtable *ht)
 		BUG_ON(!obj);
 
 		rhashtable_remove_fast(ht, &obj->node, test_rht_params);
-		kfree(obj);
 	}
 
 	end = ktime_get_ns();
 	pr_info("  Duration of test: %lld ns\n", end - start);
 
 	return end - start;
-
-error:
-	tbl = rht_dereference_rcu(ht->tbl, ht);
-	for (i = 0; i < tbl->size; i++)
-		rht_for_each_entry_safe(obj, pos, next, tbl, i, node)
-			kfree(obj);
-
-	return err;
 }
 
 static struct rhashtable ht;
@@ -214,6 +197,7 @@ static int __init test_rht_init(void)
 		s64 time;
 
 		pr_info("Test %02d:\n", i);
+		memset(&array, 0, sizeof(array));
 		err = rhashtable_init(&ht, &test_rht_params);
 		if (err < 0) {
 			pr_warn("Test failed: Unable to initialize hashtable: %d\n",
-- 
1.9.3
