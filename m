From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v5 net-next 2/4] rhashtable: add function to replace an element
Date: Mon, 14 Dec 2015 15:56:46 -0800
Message-ID: <1450137408-2589240-3-git-send-email-tom@herbertland.com>
References: <1450137408-2589240-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:55777 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932808AbbLNX5C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Dec 2015 18:57:02 -0500
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
	by m0001303.ppops.net (8.15.0.59/8.15.0.59) with SMTP id tBENuuG1017631
	for <netdev@vger.kernel.org>; Mon, 14 Dec 2015 15:57:02 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0001303.ppops.net with ESMTP id 1yt5ry0qhh-2
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 14 Dec 2015 15:57:02 -0800
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.212.236.89) with ESMTP	id
 5d16d0b4a2be11e590630002c95209d8-ea6e1210 for <netdev@vger.kernel.org>;	Mon,
 14 Dec 2015 15:56:59 -0800
In-Reply-To: <1450137408-2589240-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the rhashtable_replace_fast function. This replaces one object in
the table with another atomically. The hashes of the new and old objects
must be equal.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/linux/rhashtable.h | 82 ++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 82 insertions(+)

diff --git a/include/linux/rhashtable.h b/include/linux/rhashtable.h
index 843ceca..77deece 100644
--- a/include/linux/rhashtable.h
+++ b/include/linux/rhashtable.h
@@ -819,4 +819,86 @@ out:
 	return err;
 }
 
+/* Internal function, please use rhashtable_replace_fast() instead */
+static inline int __rhashtable_replace_fast(
+	struct rhashtable *ht, struct bucket_table *tbl,
+	struct rhash_head *obj_old, struct rhash_head *obj_new,
+	const struct rhashtable_params params)
+{
+	struct rhash_head __rcu **pprev;
+	struct rhash_head *he;
+	spinlock_t *lock;
+	unsigned int hash;
+	int err = -ENOENT;
+
+	/* Minimally, the old and new objects must have same hash
+	 * (which should mean identifiers are the same).
+	 */
+	hash = rht_head_hashfn(ht, tbl, obj_old, params);
+	if (hash != rht_head_hashfn(ht, tbl, obj_new, params))
+		return -EINVAL;
+
+	lock = rht_bucket_lock(tbl, hash);
+
+	spin_lock_bh(lock);
+
+	pprev = &tbl->buckets[hash];
+	rht_for_each(he, tbl, hash) {
+		if (he != obj_old) {
+			pprev = &he->next;
+			continue;
+		}
+
+		rcu_assign_pointer(obj_new->next, obj_old->next);
+		rcu_assign_pointer(*pprev, obj_new);
+		err = 0;
+		break;
+	}
+
+	spin_unlock_bh(lock);
+
+	return err;
+}
+
+/**
+ * rhashtable_replace_fast - replace an object in hash table
+ * @ht:		hash table
+ * @obj_old:	pointer to hash head inside object being replaced
+ * @obj_new:	pointer to hash head inside object which is new
+ * @params:	hash table parameters
+ *
+ * Replacing an object doesn't affect the number of elements in the hash table
+ * or bucket, so we don't need to worry about shrinking or expanding the
+ * table here.
+ *
+ * Returns zero on success, -ENOENT if the entry could not be found,
+ * -EINVAL if hash is not the same for the old and new objects.
+ */
+static inline int rhashtable_replace_fast(
+	struct rhashtable *ht, struct rhash_head *obj_old,
+	struct rhash_head *obj_new,
+	const struct rhashtable_params params)
+{
+	struct bucket_table *tbl;
+	int err;
+
+	rcu_read_lock();
+
+	tbl = rht_dereference_rcu(ht->tbl, ht);
+
+	/* Because we have already taken (and released) the bucket
+	 * lock in old_tbl, if we find that future_tbl is not yet
+	 * visible then that guarantees the entry to still be in
+	 * the old tbl if it exists.
+	 */
+	while ((err = __rhashtable_replace_fast(ht, tbl, obj_old,
+						obj_new, params)) &&
+	       (tbl = rht_dereference_rcu(tbl->future_tbl, ht)))
+		;
+
+	rcu_read_unlock();
+
+	return err;
+}
+
 #endif /* _LINUX_RHASHTABLE_H */
-- 
2.4.6
