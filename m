From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 9/9] netfilter: nf_tables: add support for dynamic set
 updates
Date: Fri, 30 Jan 2015 22:29:40 +1100
Message-ID: <20150130112940.GA19754@gondor.apana.org.au>
References: <1422603994-5836-1-git-send-email-kaber@trash.net>
 <1422603994-5836-10-git-send-email-kaber@trash.net>
 <20150130092845.GA18725@gondor.apana.org.au>
 <C08F666A-DAAF-4C61-A9F3-DBB3D936B4B4@trash.net>
 <20150130101802.GA19073@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tgraf@suug.ch, davem@davemloft.net, David.Laight@ACULAB.COM,
	ying.xue@windriver.com, paulmck@linux.vnet.ibm.com,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150130101802.GA19073@gondor.apana.org.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 30, 2015 at 09:18:02PM +1100, Herbert Xu wrote:
> 
> OK so it looks like you really do need a totally lockless walk.
> So I'll reshape my iterators to do that.

OK here is a completely untested patch that implements a totally
lockless walk with restart-on-resize support.

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
index 71c6aa1..a3e9e5c 100644
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
@@ -813,6 +817,165 @@ exit:
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
+	int err;
+
+	iter->ht = ht;
+	iter->p = NULL;
+	iter->slot = 0;
+	iter->skip = 0;
+
+	iter->walk = kmalloc(sizeof(*iter->walk), GFP_KERNEL);
+	if (!iter->walk)
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
+	mutex_lock(&ht->mutex);
+	list_del(&iter->walker->list);
+	mutex_unlock(&ht->mutex);
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

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
