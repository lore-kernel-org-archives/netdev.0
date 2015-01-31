From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 1/2] rhashtable: Introduce rhashtable_walk_*
Date: Sat, 31 Jan 2015 14:14:58 +1100
Message-ID: <E1YHOWQ-00071K-43@gondolin.me.apana.org.au>
References: <20150131031356.GA26781@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>, tgraf@suug.ch,
	ying.xue@windriver.com, kaber@trash.net,
	paulmck@linux.vnet.ibm.com, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:54288 "EHLO
	helcar.apana.org.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753422AbbAaDPQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2015 22:15:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some existing rhashtable users get too intimate with it by walking
the buckets directly.  This prevents us from easily changing the
internals of rhashtable.

This patch adds the helpers rhashtable_walk_init/exit/start/next/stop
which will replace these custom walkers.

They are meant to be usable for both procfs seq_file walks as well
as walking by a netlink dump.  The iterator structure should fit
inside a netlink dump cb structure, with at least one element to
spare.
  
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/linux/rhashtable.h |   35 +++++++++
 lib/rhashtable.c           |  162 +++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 197 insertions(+)

diff --git a/include/linux/rhashtable.h b/include/linux/rhashtable.h
index 6d7e840..a0e5b08 100644
--- a/include/linux/rhashtable.h
+++ b/include/linux/rhashtable.h
@@ -18,6 +18,7 @@
 #ifndef _LINUX_RHASHTABLE_H
 #define _LINUX_RHASHTABLE_H
 
+#include <linux/compiler.h>
 #include <linux/list_nulls.h>
 #include <linux/workqueue.h>
 #include <linux/mutex.h>
@@ -110,6 +111,7 @@ struct rhashtable_params {
  * @p: Configuration parameters
  * @run_work: Deferred worker to expand/shrink asynchronously
  * @mutex: Mutex to protect current/future table swapping
+ * @walkers: List of active walkers
  * @being_destroyed: True if table is set up for destruction
  */
 struct rhashtable {
@@ -120,9 +122,36 @@ struct rhashtable {
 	struct rhashtable_params	p;
 	struct work_struct		run_work;
 	struct mutex                    mutex;
+	struct list_head		walkers;
 	bool                            being_destroyed;
 };
 
+/**
+ * struct rhashtable_walker - Hash table walker
+ * @list: List entry on list of walkers
+ * @resize: Resize event occured
+ */
+struct rhashtable_walker {
+	struct list_head list;
+	bool resize;
+};
+
+/**
+ * struct rhashtable_iter - Hash table iterator, fits into netlink cb
+ * @ht: Table to iterate through
+ * @p: Current pointer
+ * @walker: Associated rhashtable walker
+ * @slot: Current slot
+ * @skip: Number of entries to skip in slot
+ */
+struct rhashtable_iter {
+	struct rhashtable *ht;
+	struct rhash_head *p;
+	struct rhashtable_walker *walker;
+	unsigned int slot;
+	unsigned int skip;
+};
+
 static inline unsigned long rht_marker(const struct rhashtable *ht, u32 hash)
 {
 	return NULLS_MARKER(ht->p.nulls_base + hash);
@@ -178,6 +207,12 @@ bool rhashtable_lookup_compare_insert(struct rhashtable *ht,
 				      bool (*compare)(void *, void *),
 				      void *arg);
 
+int rhashtable_walk_init(struct rhashtable *ht, struct rhashtable_iter *iter);
+void rhashtable_walk_exit(struct rhashtable_iter *iter);
+int rhashtable_walk_start(struct rhashtable_iter *iter) __acquires(RCU);
+void *rhashtable_walk_next(struct rhashtable_iter *iter);
+void rhashtable_walk_stop(struct rhashtable_iter *iter) __releases(RCU);
+
 void rhashtable_destroy(struct rhashtable *ht);
 
 #define rht_dereference(p, ht) \
diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index 71c6aa1..69a4eb0 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -485,11 +485,15 @@ static void rht_deferred_worker(struct work_struct *work)
 {
 	struct rhashtable *ht;
 	struct bucket_table *tbl;
+	struct rhashtable_walker *walker;
 
 	ht = container_of(work, struct rhashtable, run_work);
 	mutex_lock(&ht->mutex);
 	tbl = rht_dereference(ht->tbl, ht);
 
+	list_for_each_entry(walker, &ht->walkers, list)
+		walker->resize = true;
+
 	if (ht->p.grow_decision && ht->p.grow_decision(ht, tbl->size))
 		rhashtable_expand(ht);
 	else if (ht->p.shrink_decision && ht->p.shrink_decision(ht, tbl->size))
@@ -813,6 +817,163 @@ exit:
 }
 EXPORT_SYMBOL_GPL(rhashtable_lookup_compare_insert);
 
+/**
+ * rhashtable_walk_init - Initialise an iterator
+ * @ht:		Table to walk over
+ * @iter:	Hash table Iterator
+ *
+ * This function prepares a hash table walk.
+ *
+ * Note that if you restart a walk after rhashtable_walk_stop you
+ * may see the same object twice.  Also, you may miss objects if
+ * there are removals in between rhashtable_walk_stop and the next
+ * call to rhashtable_walk_start.
+ *
+ * For a completely stable walk you should construct your own data
+ * structure outside the hash table.
+ *
+ * This function may sleep so you must not call it from interrupt
+ * context or with spin locks held.
+ *
+ * You must call rhashtable_walk_exit if this function returns
+ * successfully.
+ */
+int rhashtable_walk_init(struct rhashtable *ht, struct rhashtable_iter *iter)
+{
+	iter->ht = ht;
+	iter->p = NULL;
+	iter->slot = 0;
+	iter->skip = 0;
+
+	iter->walker = kmalloc(sizeof(*iter->walker), GFP_KERNEL);
+	if (!iter->walker)
+		return -ENOMEM;
+
+	mutex_lock(&ht->mutex);
+	list_add(&iter->walker->list, &ht->walkers);
+	mutex_unlock(&ht->mutex);
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(rhashtable_walk_init);
+
+/**
+ * rhashtable_walk_exit - Free an iterator
+ * @iter:	Hash table Iterator
+ *
+ * This function frees resources allocated by rhashtable_walk_init.
+ */
+void rhashtable_walk_exit(struct rhashtable_iter *iter)
+{
+	mutex_lock(&iter->ht->mutex);
+	list_del(&iter->walker->list);
+	mutex_unlock(&iter->ht->mutex);
+	kfree(iter->walker);
+}
+EXPORT_SYMBOL_GPL(rhashtable_walk_exit);
+
+/**
+ * rhashtable_walk_start - Start a hash table walk
+ * @iter:	Hash table iterator
+ *
+ * Start a hash table walk.  Note that we take the RCU lock in all
+ * cases including when we return an error.  So you must always call
+ * rhashtable_walk_stop to clean up.
+ *
+ * Returns zero if successful.
+ *
+ * Returns -EAGAIN if resize event occured.  Note that the iterator
+ * will rewind back to the beginning and you may use it immediately
+ * by calling rhashtable_walk_next.
+ */
+int rhashtable_walk_start(struct rhashtable_iter *iter)
+{
+	rcu_read_lock();
+
+	if (iter->walker->resize) {
+		iter->slot = 0;
+		iter->skip = 0;
+		iter->walker->resize = false;
+		return -EAGAIN;
+	}
+
+	return 0;
+}
+
+/**
+ * rhashtable_walk_next - Return the next object and advance the iterator
+ * @iter:	Hash table iterator
+ *
+ * Note that you must call rhashtable_walk_stop when you are finished
+ * with the walk.
+ *
+ * Returns the next object or NULL when the end of the table is reached.
+ *
+ * Returns -EAGAIN if resize event occured.  Note that the iterator
+ * will rewind back to the beginning and you may continue to use it.
+ */
+void *rhashtable_walk_next(struct rhashtable_iter *iter)
+{
+	const struct bucket_table *tbl;
+	struct rhashtable *ht = iter->ht;
+	struct rhash_head *p = iter->p;
+	void *obj = NULL;
+
+	tbl = rht_dereference_rcu(ht->tbl, ht);
+
+	if (p) {
+		p = rht_dereference_bucket_rcu(p->next, tbl, iter->slot);
+		goto next;
+	}
+
+	for (; iter->slot < tbl->size; iter->slot++) {
+		int skip = iter->skip;
+
+		rht_for_each_rcu(p, tbl, iter->slot) {
+			if (!skip)
+				break;
+			skip--;
+		}
+
+next:
+		if (!rht_is_a_nulls(p)) {
+			iter->skip++;
+			iter->p = p;
+			obj = rht_obj(ht, p);
+			goto out;
+		}
+
+		iter->skip = 0;
+	}
+
+	iter->p = NULL;
+
+out:
+	if (iter->walker->resize) {
+		iter->p = NULL;
+		iter->slot = 0;
+		iter->skip = 0;
+		iter->walker->resize = false;
+		return ERR_PTR(-EAGAIN);
+	}
+
+	return obj;
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
+	rcu_read_unlock();
+	iter->p = NULL;
+}
+EXPORT_SYMBOL_GPL(rhashtable_walk_stop);
+
 static size_t rounded_hashtable_size(struct rhashtable_params *params)
 {
 	return max(roundup_pow_of_two(params->nelem_hint * 4 / 3),
@@ -885,6 +1046,7 @@ int rhashtable_init(struct rhashtable *ht, struct rhashtable_params *params)
 	memset(ht, 0, sizeof(*ht));
 	mutex_init(&ht->mutex);
 	memcpy(&ht->p, params, sizeof(*params));
+	INIT_LIST_HEAD(&ht->walkers);
 
 	if (params->locks_mul)
 		ht->p.locks_mul = roundup_pow_of_two(params->locks_mul);
