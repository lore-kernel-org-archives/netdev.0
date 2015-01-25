From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 1/2] rhashtable: Introduce rhashtable_walk_*
Date: Mon, 26 Jan 2015 10:21:31 +1100
Message-ID: <E1YFWUl-0004gE-SH@gondolin.me.apana.org.au>
References: <20150125232040.GA17936@gondor.apana.org.au>
To: Thomas Graf <tgraf@suug.ch>, Ying Xue <ying.xue@windriver.com>,
	davem@davemloft.net, kaber@trash.net, paulmck@linux.vnet.ibm.com,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:50873 "EHLO
	helcar.apana.org.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751778AbbAYXVw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Jan 2015 18:21:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some existing rhashtable users get too intimate with it by walking
the buckets directly.  This prevents us from easily changing the
internals of rhashtable.

This patch adds the helpers rhashtable_walk_init/next/end which
will replace these custom walkers.

They are meant to be usable for both procfs seq_file walks as well
as walking by a netlink dump.  The iterator structure should fit
inside a netlink dump cb structure, with at least one element to
spare.
  
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/linux/rhashtable.h |   44 +++++++++++++++++++++
 lib/rhashtable.c           |   91 +++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 135 insertions(+)

diff --git a/include/linux/rhashtable.h b/include/linux/rhashtable.h
index 6d7e840..b03b375 100644
--- a/include/linux/rhashtable.h
+++ b/include/linux/rhashtable.h
@@ -18,6 +18,7 @@
 #ifndef _LINUX_RHASHTABLE_H
 #define _LINUX_RHASHTABLE_H
 
+#include <linux/compiler.h>
 #include <linux/list_nulls.h>
 #include <linux/workqueue.h>
 #include <linux/mutex.h>
@@ -123,6 +124,22 @@ struct rhashtable {
 	bool                            being_destroyed;
 };
 
+/**
+ * struct rhashtable_iter - Hash table iterator
+ * @ht: Table to iterate through
+ * @p: Current pointer
+ * @lock: Slot lock
+ * @slot: Current slot
+ * @skip: Number of entries to skip in slot
+ */
+struct rhashtable_iter {
+	struct rhashtable *ht;
+	struct rhash_head *p;
+	spinlock_t *lock;
+	unsigned int slot;
+	unsigned int skip;
+};
+
 static inline unsigned long rht_marker(const struct rhashtable *ht, u32 hash)
 {
 	return NULLS_MARKER(ht->p.nulls_base + hash);
@@ -178,6 +195,33 @@ bool rhashtable_lookup_compare_insert(struct rhashtable *ht,
 				      bool (*compare)(void *, void *),
 				      void *arg);
 
+/**
+ * rhashtable_walk_init - Initialise an iterator
+ * @ht:		Table to walk over
+ * @iter:	Hash table Iterator
+ *
+ * This function prepares a hash table walk.
+ * Note that if you restart a walk after rhashtable_walk_stop you
+ * may see the same object twice.  Also, you may miss objects if
+ * there are removals in between rhashtable_walk_stop and the next
+ * call to rhashtable_walk_start.
+ *
+ * For a completely stable walk you should construct your own data
+ * structure outside the hash table.
+ */
+static inline void rhashtable_walk_init(struct rhashtable *ht,
+					struct rhashtable_iter *iter)
+{
+	iter->ht = ht;
+	iter->p = NULL;
+	iter->slot = 0;
+	iter->skip = 0;
+}
+
+int rhashtable_walk_start(struct rhashtable_iter *iter) __acquires(RCU);
+void *rhashtable_walk_next(struct rhashtable_iter *iter);
+void rhashtable_walk_stop(struct rhashtable_iter *iter) __releases(RCU);
+
 void rhashtable_destroy(struct rhashtable *ht);
 
 #define rht_dereference(p, ht) \
diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index 71c6aa1..d51fb06 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -813,6 +813,97 @@ exit:
 }
 EXPORT_SYMBOL_GPL(rhashtable_lookup_compare_insert);
 
+/**
+ * rhashtable_walk_start - Start a hash table walk
+ * @iter:	Hash table iterator
+ *
+ * Start a hash table walk.
+ *
+ * Returns zero if successful.  Returns -EINTR if we couldn't
+ * obtain the resize lock.
+ */
+int rhashtable_walk_start(struct rhashtable_iter *iter)
+{
+	struct rhashtable *ht = iter->ht;
+	int err;
+
+	err = mutex_lock_interruptible(&ht->mutex);
+	rcu_read_lock();
+
+	if (!err)
+		mutex_unlock(&ht->mutex);
+
+	return err;
+}
+EXPORT_SYMBOL_GPL(rhashtable_walk_start);
+
+/**
+ * rhashtable_walk_next - Return the next object and advance the iterator
+ * @iter:	Hash table iterator
+ *
+ * Note that you must call rhashtable_walk_stop when you are finished
+ * with the walk.
+ *
+ * Returns the next object or NULL when the end of the table is reached.
+ */
+void *rhashtable_walk_next(struct rhashtable_iter *iter)
+{
+	const struct bucket_table *tbl;
+	struct rhashtable *ht = iter->ht;
+	struct rhash_head *p = iter->p;
+
+	tbl = rht_dereference_rcu(ht->tbl, ht);
+
+	if (p) {
+		p = rht_dereference_bucket(p->next, tbl, iter->slot);
+		goto next;
+	}
+
+	for (; iter->slot < tbl->size; iter->slot++) {
+		int skip = iter->skip;
+
+		iter->lock = bucket_lock(tbl, iter->slot);
+		spin_lock_bh(iter->lock);
+
+		rht_for_each(p, tbl, iter->slot) {
+			if (!skip)
+				break;
+			skip--;
+		}
+
+next:
+		if (!rht_is_a_nulls(p)) {
+			iter->skip++;
+			iter->p = p;
+			return rht_obj(ht, p);
+		}
+		spin_unlock_bh(iter->lock);
+
+		iter->skip = 0;
+	}
+
+	iter->p = NULL;
+	return NULL;
+}
+EXPORT_SYMBOL_GPL(rhashtable_walk_next);
+
+/**
+ * rhashtable_walk_stop - Finish a hash table walk
+ * @iter:	Hash table iterator
+ *
+ * Finish a hash table walk.
+ */
+void rhashtable_walk_stop(struct rhashtable_iter *iter)
+{
+	if (iter->p)
+		spin_unlock_bh(iter->lock);
+
+	rcu_read_unlock();
+
+	iter->p = NULL;
+}
+EXPORT_SYMBOL_GPL(rhashtable_walk_stop);
+
 static size_t rounded_hashtable_size(struct rhashtable_params *params)
 {
 	return max(roundup_pow_of_two(params->nelem_hint * 4 / 3),
