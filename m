From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 3/4] rhashtable: Move mutex_is_held under PROVE_LOCKING
Date: Thu, 13 Nov 2014 18:11:20 +0800
Message-ID: <E1XorN2-0000zW-Np@gondolin.me.apana.org.au>
References: <20141113101025.GA3728@gondor.apana.org.au>
To: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:49794 "EHLO
	helcar.apana.org.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932174AbaKMKLY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2014 05:11:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The rhashtable function mutex_is_held is only used when PROVE_LOCKING
is enabled.  This patch makes the mutex_is_held field in rhashtable
optional depending on PROVE_LOCKING.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/linux/rhashtable.h |    2 ++
 lib/rhashtable.c           |    8 ++++++++
 2 files changed, 10 insertions(+)

diff --git a/include/linux/rhashtable.h b/include/linux/rhashtable.h
index fb298e9d..96ce8ce 100644
--- a/include/linux/rhashtable.h
+++ b/include/linux/rhashtable.h
@@ -65,7 +65,9 @@ struct rhashtable_params {
 						 size_t new_size);
 	bool			(*shrink_decision)(const struct rhashtable *ht,
 						   size_t new_size);
+#ifdef CONFIG_PROVE_LOCKING
 	int			(*mutex_is_held)(void);
+#endif
 };
 
 /**
diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index 624a0b7..548bb29 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -532,7 +532,9 @@ static size_t rounded_hashtable_size(struct rhashtable_params *params)
  *	.key_offset = offsetof(struct test_obj, key),
  *	.key_len = sizeof(int),
  *	.hashfn = arch_fast_hash,
+ * #ifdef CONFIG_PROVE_LOCKING
  *	.mutex_is_held = &my_mutex_is_held,
+ * #endif
  * };
  *
  * Configuration Example 2: Variable length keys
@@ -552,7 +554,9 @@ static size_t rounded_hashtable_size(struct rhashtable_params *params)
  *	.head_offset = offsetof(struct test_obj, node),
  *	.hashfn = arch_fast_hash,
  *	.obj_hashfn = my_hash_fn,
+ * #ifdef CONFIG_PROVE_LOCKING
  *	.mutex_is_held = &my_mutex_is_held,
+ * #endif
  * };
  */
 int rhashtable_init(struct rhashtable *ht, struct rhashtable_params *params)
@@ -613,10 +617,12 @@ EXPORT_SYMBOL_GPL(rhashtable_destroy);
 #define TEST_PTR	((void *) 0xdeadbeef)
 #define TEST_NEXPANDS	4
 
+#ifdef CONFIG_PROVE_LOCKING
 static int test_mutex_is_held(void)
 {
 	return 1;
 }
+#endif
 
 struct test_obj {
 	void			*ptr;
@@ -767,7 +773,9 @@ static int __init test_rht_init(void)
 		.key_offset = offsetof(struct test_obj, value),
 		.key_len = sizeof(int),
 		.hashfn = arch_fast_hash,
+#ifdef CONFIG_PROVE_LOCKING
 		.mutex_is_held = &test_mutex_is_held,
+#endif
 		.grow_decision = rht_grow_above_75,
 		.shrink_decision = rht_shrink_below_30,
 	};
