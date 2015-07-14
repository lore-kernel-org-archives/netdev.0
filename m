From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 3/3] rhashtable: Add scored lookups
Date: Mon, 13 Jul 2015 17:39:13 -0700
Message-ID: <1436834353-1851565-4-git-send-email-tom@herbertland.com>
References: <1436834353-1851565-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>, <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:9906 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752816AbbGNAjc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jul 2015 20:39:32 -0400
Received: from pps.filterd (m0044012 [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t6E0bMYW010970
	for <netdev@vger.kernel.org>; Mon, 13 Jul 2015 17:39:32 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1vmn7g8cfd-2
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 13 Jul 2015 17:39:32 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.223.100.99) with ESMTP	id
 c9e71a7229c011e59cb424be05956610-b8d92b0 for <netdev@vger.kernel.org>;	Mon,
 13 Jul 2015 17:39:30 -0700
In-Reply-To: <1436834353-1851565-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a mechanism to do scored lookups in an rhashtable.
This mechanism is based on the UDP and TCP listener socket lookup
functions.

When a bucket is traversed, a matching score is computed for each entry
and the input key. The entry with the highest non-zero score is
returned, and if there are multiple entries with the highest score then
one entry is selected by modulo on a hash value for the key (which must
be separate from the hash used to determine the bucket).

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/linux/rhashtable.h | 64 ++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 64 insertions(+)

diff --git a/include/linux/rhashtable.h b/include/linux/rhashtable.h
index 05171c3..317bc793 100644
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
 
@@ -515,6 +518,67 @@ static inline int rhashtable_compare(struct rhashtable_compare_arg *arg,
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
+		if (score > best_score) {
+			result = he;
+			best_score = score;
+			matches = 1;
+			khash = flow_hash;
+		} else if (score && score == best_score) {
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
  * rhashtable_lookup_fast - search hash table, inlined version
  * @ht:		hash table
-- 
1.8.1
