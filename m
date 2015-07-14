From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v2 net-next 3/3] rhashtable: Add scored lookups
Date: Tue, 14 Jul 2015 16:45:49 -0700
Message-ID: <1436917549-3666965-4-git-send-email-tom@herbertland.com>
References: <1436917549-3666965-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>, <tgraf@suug.ch>,
	<herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:28639 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753099AbbGNXqQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2015 19:46:16 -0400
Received: from pps.filterd (m0004077 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t6ENi1dM032707
	for <netdev@vger.kernel.org>; Tue, 14 Jul 2015 16:46:15 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1vnc9fr0u1-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 14 Jul 2015 16:46:15 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.212.236.87) with ESMTP	id
 82ee5a6e2a8211e596500002c9521c9e-ac7da270 for <netdev@vger.kernel.org>;	Tue,
 14 Jul 2015 16:46:13 -0700
In-Reply-To: <1436917549-3666965-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a mechanism to do scored lookups in an rhashtable.
This mechanism is based on the UDP and TCP listener socket lookup
functions.

When a bucket is traversed, a matching score is computed for each entry
and the input key. The entry with the greatest non-zero score is
returned, and if there are multiple entries with the highest score then
one entry is selected by modulo on a hash value for the key (which must
be separate from the hash used to determine the bucket).

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/linux/rhashtable.h | 66 ++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 66 insertions(+)

diff --git a/include/linux/rhashtable.h b/include/linux/rhashtable.h
index 651b5226..13aa3f9 100644
--- a/include/linux/rhashtable.h
+++ b/include/linux/rhashtable.h
@@ -24,6 +24,7 @@
 #include <linux/list_nulls.h>
 #include <linux/workqueue.h>
 #include <linux/mutex.h>
+#include <linux/random.h>
 #include <linux/rcupdate.h>
 
 /*
@@ -93,6 +94,8 @@ typedef u32 (*rht_obj_hashfn_t)(const void *data, u32 len, u32 seed);
 typedef int (*rht_obj_cmpfn_t)(struct rhashtable_compare_arg *arg,
 			       const void *obj);
 typedef int (*rht_obj_orderfn_t)(const void *obj);
+typedef unsigned int (*rht_obj_scorefn_t)(struct rhashtable_compare_arg *arg,
+					  const void *obj);
 
 struct rhashtable;
 
@@ -515,6 +518,69 @@ static inline int rhashtable_compare(struct rhashtable_compare_arg *arg,
 	return memcmp(ptr + ht->p.key_offset, arg->key, ht->p.key_len);
 }
 
+
+/**
+ * rhashtable_lookup_scored - search hash table with scoring
+ * @ht:		hash table
+ * @key:	the pointer to the key
+ * @params:	hash table parameters
+ * @obj_scorefn: Scoring function
+ * @flow_hash:	hash value used to select when multiple matches are found
+ *
+ * Computes the hash value for the key and traverses the bucket chain computing
+ * a match score for each object on the list and the key. The entry with the
+ * highest score is returned. If there is more than one entry with the highest
+ * score, then one of the entries is selected based on a hash of the input key.
+ */
+static inline void *rhashtable_lookup_scored(
+	struct rhashtable *ht, const void *key,
+	const struct rhashtable_params params,
+	rht_obj_scorefn_t obj_scorefn,
+	unsigned int flow_hash)
+{
+	struct rhashtable_compare_arg arg = {
+		.ht = ht,
+		.key = key,
+	};
+	const struct bucket_table *tbl;
+	struct rhash_head *he, *result = NULL;
+	unsigned int hash, score;
+	unsigned int best_score = 0, khash = 0;
+	int matches = 0;
+
+	rcu_read_lock();
+
+	tbl = rht_dereference_rcu(ht->tbl, ht);
+restart:
+	hash = rht_key_hashfn(ht, tbl, key, params);
+	rht_for_each_rcu(he, tbl, hash) {
+		score = obj_scorefn(&arg, rht_obj(ht, he));
+		if (!score) {
+			continue;
+		} else if (score > best_score) {
+			result = he;
+			best_score = score;
+			matches = 1;
+			khash = flow_hash;
+		} else if (score == best_score) {
+			matches++;
+			if (reciprocal_scale(khash, matches) == 0)
+				result = he;
+			khash = next_pseudo_random32(khash);
+		}
+	}
+
+	/* Ensure we see any new tables. */
+	smp_rmb();
+
+	tbl = rht_dereference_rcu(tbl->future_tbl, ht);
+	if (unlikely(tbl))
+		goto restart;
+	rcu_read_unlock();
+
+	return result ? rht_obj(ht, result) : NULL;
+}
+
 /**
  * rhashtable_lookup_fast_cmpfn - search hash table, inlined version
  * @ht:		hash table
-- 
1.8.1
