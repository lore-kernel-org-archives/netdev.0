From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next 3/4] test_rhashtable: add a check for max_size
Date: Mon, 18 Sep 2017 23:07:10 +0200
Message-ID: <20170918210711.10202-4-fw@strlen.de>
References: <20170918210711.10202-1-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:51760 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750972AbdIRVHE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 17:07:04 -0400
In-Reply-To: <20170918210711.10202-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

add a test that tries to insert more than max_size elements.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 lib/test_rhashtable.c | 41 +++++++++++++++++++++++++++++++++++++++++
 1 file changed, 41 insertions(+)

diff --git a/lib/test_rhashtable.c b/lib/test_rhashtable.c
index 69f5b3849980..1eee90e6e394 100644
--- a/lib/test_rhashtable.c
+++ b/lib/test_rhashtable.c
@@ -246,6 +246,43 @@ static s64 __init test_rhashtable(struct rhashtable *ht, struct test_obj *array,
 
 static struct rhashtable ht;
 
+static int __init test_rhashtable_max(struct test_obj *array,
+				      unsigned int entries)
+{
+	unsigned int i, insert_retries = 0;
+	int err;
+
+	test_rht_params.max_size = roundup_pow_of_two(entries / 8);
+	err = rhashtable_init(&ht, &test_rht_params);
+	if (err)
+		return err;
+
+	for (i = 0; i < ht.max_elems; i++) {
+		struct test_obj *obj = &array[i];
+
+		obj->value.id = i * 2;
+		err = insert_retry(&ht, obj, test_rht_params);
+		if (err > 0)
+			insert_retries += err;
+		else if (err)
+			return err;
+	}
+
+	err = insert_retry(&ht, &array[ht.max_elems], test_rht_params);
+	if (err == -E2BIG) {
+		err = 0;
+	} else {
+		pr_info("insert element %u should have failed with %d, got %d\n",
+				ht.max_elems, -E2BIG, err);
+		if (err == 0)
+			err = -1;
+	}
+
+	rhashtable_destroy(&ht);
+
+	return err;
+}
+
 static int thread_lookup_test(struct thread_data *tdata)
 {
 	unsigned int entries = tdata->entries;
@@ -386,7 +423,11 @@ static int __init test_rht_init(void)
 		total_time += time;
 	}
 
+	pr_info("test if its possible to exceed max_size %d: %s\n",
+			test_rht_params.max_size, test_rhashtable_max(objs, entries) == 0 ?
+			"no, ok" : "YES, failed");
 	vfree(objs);
+
 	do_div(total_time, runs);
 	pr_info("Average test time: %llu\n", total_time);
 
-- 
2.13.5
