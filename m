From: David Howells <dhowells@redhat.com>
Subject: [PATCH 01/11] rxrpc: Add a common object cache
Date: Mon, 07 Mar 2016 14:38:06 +0000
Message-ID: <20160307143806.18567.30020.stgit@warthog.procyon.org.uk>
References: <20160307143759.18567.8234.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linux-afs@lists.infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160307143759.18567.8234.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a common object cache implementation for RxRPC.  This will be used to
cache objects of various types (calls, connections, local and remote
endpoint records).  Each object that would be cached must contain an
obj_node struct for the cache to use.  The object's usage count and link
pointers are here, plus other internal metadata.

Each object cache consists of a primary hash to which all objects of that
type must be added and a secondary hash to which objects may also be added
and removed a single time.  Objects are automatically removed from both
hashes when they expire.

Objects start off life with a usage count of 2 - one for the cache and one
for the caller.  When an object's usage count is reduced to 1, it sits in
the cache until its expiry time is reached, at which point the cache
attempts to reduce the count to 0 and, if successful, clean it up.  An
object with a usage count of 1 in the cache can be looked up and have its
usage count increased, thereby stopping the expiry process.

Objects are looked up, unlinked and destroyed under RCU-safe conditions.

A garbage collector cycles through all the hash buckets in the primary hash
and compares the expiry times of the usage-count-1 objects to the current
time, removing any that have expired.  This is kicked by a single timer for
the whole cache rather than having a timer per object.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/Makefile      |    3 
 net/rxrpc/ar-internal.h |   39 ++++
 net/rxrpc/objcache.c    |  477 +++++++++++++++++++++++++++++++++++++++++++++++
 net/rxrpc/objcache.h    |   89 +++++++++
 4 files changed, 607 insertions(+), 1 deletion(-)
 create mode 100644 net/rxrpc/objcache.c
 create mode 100644 net/rxrpc/objcache.h

diff --git a/net/rxrpc/Makefile b/net/rxrpc/Makefile
index ec126f91276b..b79fee14c763 100644
--- a/net/rxrpc/Makefile
+++ b/net/rxrpc/Makefile
@@ -18,7 +18,8 @@ af-rxrpc-y := \
 	ar-recvmsg.o \
 	ar-security.o \
 	ar-skbuff.o \
-	ar-transport.o
+	ar-transport.o \
+	objcache.o
 
 af-rxrpc-$(CONFIG_PROC_FS) += ar-proc.o
 af-rxrpc-$(CONFIG_SYSCTL) += sysctl.o
diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index 8b495aed517d..21d6ae6f4cc6 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -9,7 +9,11 @@
  * 2 of the License, or (at your option) any later version.
  */
 
+#include <linux/net.h>
+#include <net/sock.h>
+#include <net/af_rxrpc.h>
 #include <rxrpc/packet.h>
+#include "objcache.h"
 
 #if 0
 #define CHECK_SLAB_OKAY(X)				     \
@@ -467,6 +471,41 @@ extern atomic_t rxrpc_n_skbs;
 extern u32 rxrpc_epoch;
 extern atomic_t rxrpc_debug_id;
 extern struct workqueue_struct *rxrpc_workqueue;
+ 
+static inline void __rxrpc_queue_obj(struct work_struct *work,
+				     struct objcache *cache,
+				     struct obj_node *obj)
+{
+	/* Pass the caller's ref to the workqueue or drop it if already
+	 * queued.
+	 */
+	if (!queue_work(rxrpc_workqueue, work))
+		objcache_put(cache, obj);
+}
+
+static inline void rxrpc_queue_obj(struct work_struct *work,
+				   struct objcache *cache,
+				   struct obj_node *obj)
+{
+	/* We don't want to queue the work item if the object is dead - but
+	 * whilst we want to avoid calling objcache_put(), we really, really
+	 * want to avoid calling cancel_sync_wait() or flush_workqueue().
+	 *
+	 * There is, however, a gap between calling queue_work() and doing
+	 * something conditionally on its result that would allow the work item
+	 * to be happen if we get interrupted - so we can't just increment the
+	 * usage count if we queued the work and decrement it in the work func
+	 * as the work func might decrement it *before* we manage to increment
+	 * it here.
+	 *
+	 * So we have to attempt to increment the count before trying the queue
+	 * operation and then correct afterwards if the work was already
+	 * queued.
+	 */
+	if (objcache_get_maybe(obj) &&
+	    !queue_work(rxrpc_workqueue, work))
+		objcache_put(cache, obj);
+}
 
 /*
  * ar-accept.c
diff --git a/net/rxrpc/objcache.c b/net/rxrpc/objcache.c
new file mode 100644
index 000000000000..74eed8ce5894
--- /dev/null
+++ b/net/rxrpc/objcache.c
@@ -0,0 +1,477 @@
+/* Common object cache
+ *
+ * Copyright (C) 2015 Red Hat, Inc. All Rights Reserved.
+ * Written by David Howells (dhowells@redhat.com)
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public Licence
+ * as published by the Free Software Foundation; either version
+ * 2 of the Licence, or (at your option) any later version.
+ */
+
+#include <linux/sched.h>
+#include <linux/hash.h>
+#include "ar-internal.h"
+#include "objcache.h"
+
+static void objcache_gc(struct work_struct *work);
+static void objcache_gc_timer_func(unsigned long _cache);
+
+/**
+ * objcache_init - Initialise working state of an object cache.
+ * @cache: The cache to initialise
+ *
+ * Certain fields must be supplied, notably the method pointers and the log2
+ * cache size in cache->shift.  Also, it is assumed that hash_table[] will be
+ * precleared.
+ *
+ * Note that the hash tables must be at least 2 buckets in size otherwise hash
+ * folding and hash scanning for gc won't work.
+ */
+void objcache_init(struct objcache *cache)
+{
+	_enter("%s", cache->name);
+
+	BUG_ON(!cache->hash_key || !cache->cmp_key ||
+	       !cache->hash_table || cache->nr_buckets <= 1);
+
+	INIT_WORK(&cache->gc_work, objcache_gc);
+	setup_timer(&cache->gc_timer, objcache_gc_timer_func,
+		    (unsigned long)cache);
+	cache->gc_next_run = TIME64_MAX;
+	spin_lock_init(&cache->lock);
+	atomic_set(&cache->count, 0);
+	cache->shift = ilog2(cache->nr_buckets);
+	cache->gc_needed = false;
+
+	if (cache->hash_table_2) {
+		BUG_ON(!cache->hash_key_2 || !cache->cmp_key_2 ||
+		       cache->nr_buckets_2 <= 1);
+		cache->shift_2 = ilog2(cache->nr_buckets_2);
+	}
+}
+
+/*
+ * Reduce the full hash value to the table size.
+ */
+static unsigned objcache_hash_fold(unsigned long full_hash_key, int shift)
+{
+	return hash_32(full_hash_key, shift);
+}
+
+/**
+ * objcache_try_add - Add an object to a hash table if no collision
+ * @cache: Cache to add to
+ * @candidate: Candidate object to add
+ * @key: The key to match
+ *
+ * Add an object to the hashtable if there's not already an equivalent object
+ * present.  Return whichever object ends up in the cache.  A ref is taken on
+ * the object returned.  This function will never fail.
+ */
+struct obj_node *objcache_try_add(struct objcache *cache,
+				  struct obj_node *candidate,
+				  const void *key)
+{
+	struct hlist_head *bucket;
+	struct obj_node *obj, *after;
+	unsigned long full_hash_key = cache->hash_key(key);
+	unsigned hash_key = objcache_hash_fold(full_hash_key, cache->shift);
+	int diff;
+
+	_enter("%s", cache->name);
+
+	/* Objects have a usage count of 1 when lurking in the cache with no
+	 * users, so we need two references - one for the cache and one for the
+	 * caller.
+	 */
+	atomic_set(&candidate->usage, 2);
+	INIT_HLIST_NODE(&candidate->link);
+	INIT_HLIST_NODE(&candidate->link_2);
+	candidate->full_hash_key = full_hash_key;
+	candidate->put_timestamp = TIME64_MAX;
+
+	spin_lock(&cache->lock);
+
+	bucket = cache->hash_table + hash_key;
+	_debug("%lu -> %u -> %p", full_hash_key, hash_key, bucket);
+	if (hlist_empty(bucket)) {
+		hlist_add_head_rcu(&candidate->link, bucket);
+	} else {
+		hlist_for_each_entry(obj, bucket, link) {
+			after = obj;
+			diff = ((obj->full_hash_key - candidate->full_hash_key) ?:
+				cache->cmp_key(obj, key));
+			if (diff < 0)
+				continue;
+			if (diff == 0 && atomic_inc_not_zero(&obj->usage))
+				goto already_present;
+
+			hlist_add_before_rcu(&candidate->link, &obj->link);
+			goto added;
+		}
+
+		hlist_add_behind_rcu(&candidate->link, &after->link);
+	}
+
+added:
+	obj = candidate;
+	atomic_inc(&cache->count);
+
+already_present:
+	spin_unlock(&cache->lock);
+	return obj;
+}
+
+/**
+ * objcache_lookup_rcu - Look up an object using RCU.
+ * @cache: The cache to look in
+ * @key: The key to match
+ *
+ * Look up an object in a cache using RCU.  The caller must hold the RCU read
+ * lock.  If a successful return is made, no adjustment to the object usage
+ * count is made.
+ */
+struct obj_node *objcache_lookup_rcu(struct objcache *cache, const void *key)
+{
+	struct hlist_head *bucket;
+	struct obj_node *obj;
+	unsigned long full_hash_key = cache->hash_key(key);
+	unsigned hash_key = objcache_hash_fold(full_hash_key, cache->shift);
+	int diff;
+
+	_enter("%s", cache->name);
+
+	bucket = cache->hash_table + hash_key;
+	hlist_for_each_entry(obj, bucket, link) {
+		diff = (obj->full_hash_key - full_hash_key) ?:
+			cache->cmp_key(obj, key);
+		if (diff < 0)
+			continue;
+		if (diff == 0 && atomic_read(&obj->usage) >= 1)
+			goto found;
+		break;
+	}
+
+	_leave(" = NULL");
+	return NULL;
+
+found:
+	_leave(" = %p {u=%d}", obj, atomic_read(&obj->usage));
+	return obj;
+}
+
+/**
+ * objcache_add_2 - Add an object to the secondary hash
+ * @cache: Cache to add to
+ * @candidate: Candidate object to add
+ * @key: The key to match
+ * @displace: Whether or not to displace a collision
+ *
+ * Add an object to the secondary hashtable.  The object must already be in the
+ * primary cache.  Doesn't alter the object's usage count.
+ *
+ * If there is no collision with an already cached object, the object will be
+ * added and true will be returned.  If there is a collision, then if @displace
+ * is true, the new object will be placed in front of the old one and true will
+ * be returned, otherwise if @displace is false, no change will be made and
+ * false will be returned.
+ */
+bool objcache_add_2(struct objcache *cache, struct obj_node *candidate,
+		    const void *key, bool displace)
+{
+	struct hlist_head *bucket;
+	struct obj_node *obj, *after;
+	unsigned long full_hash_key = cache->hash_key_2(key);
+	unsigned hash_key = objcache_hash_fold(full_hash_key, cache->shift_2);
+	bool ret;
+	int diff;
+
+	_enter("%s", cache->name);
+
+	BUG_ON(hlist_unhashed(&candidate->link));
+
+	/* We assume that the object is already in the primary cache.
+	 */
+	spin_lock(&cache->lock);
+
+	bucket = cache->hash_table_2 + hash_key;
+	if (hlist_empty(bucket)) {
+		hlist_add_head_rcu(&candidate->link_2, bucket);
+		ret = true;
+	} else {
+		hlist_for_each_entry(obj, bucket, link_2) {
+			after = obj;
+			diff = cache->cmp_key_2(obj, key);
+			if (diff < 0)
+				continue;
+
+			if (diff == 0 && !displace) {
+				ret = false;
+				goto out;
+			}
+
+			/* We add in front of one that has the same parameters,
+			 * effectively displacing that from future lookups.
+			 */
+			hlist_add_before_rcu(&candidate->link_2, &obj->link_2);
+			ret = true;
+			goto out;
+		}
+
+		hlist_add_behind_rcu(&candidate->link_2, &after->link_2);
+		ret = true;
+	}
+
+out:
+	spin_unlock(&cache->lock);
+	return ret;
+}
+
+/**
+ * objcache_del_2 - Remove an object from the secondary cache.
+ */
+void objcache_del_2(struct objcache *cache, struct obj_node *obj)
+{
+	BUG_ON(hlist_unhashed(&obj->link_2));
+
+	spin_lock(&cache->lock);
+	hlist_del_rcu(&obj->link_2);
+	spin_unlock(&cache->lock);
+}
+
+/**
+ * objcache_lookup_rcu_2 - Look up an object using RCU in the secondary cache.
+ * @cache: The cache to look in
+ * @key: The key to match
+ *
+ * Look up an object in a secondary cache using RCU.  The caller must hold the
+ * RCU read lock.  If a successful return is made, no adjustment to the object
+ * usage count is made.
+ */
+struct obj_node *objcache_lookup_rcu_2(struct objcache *cache, const void *key)
+{
+	struct hlist_head *bucket;
+	struct obj_node *obj;
+	unsigned long full_hash_key = cache->hash_key_2(key);
+	unsigned hash_key = objcache_hash_fold(full_hash_key, cache->shift_2);
+	int diff;
+
+	_enter("%s", cache->name);
+
+	bucket = cache->hash_table_2 + hash_key;
+	hlist_for_each_entry(obj, bucket, link_2) {
+		diff = cache->cmp_key_2(obj, key);
+		if (diff < 0)
+			continue;
+		if (diff == 0 && atomic_read(&obj->usage) >= 1)
+			goto found;
+		break;
+	}
+
+	_leave(" = NULL");
+	return NULL;
+
+found:
+	_leave(" = %p {u=%d}", obj, atomic_read(&obj->usage));
+	return obj;
+}
+
+/*
+ * Release a ref on an object that's in the cache.  The object is removed from
+ * the cache some time after it is last put.
+ */
+void objcache_put(struct objcache *cache, struct obj_node *obj)
+{
+	struct timespec64 now;
+	time64_t timestamp;
+	unsigned delay = cache->gc_delay;
+	int usage;
+
+	_enter("%s,%p{u=%d}", cache->name, obj, atomic_read(&obj->usage));
+
+	usage = atomic_read(&obj->usage);
+	if (usage < 2) {
+		pr_err("objcache_put: %s usage underrun (%d)\n",
+		       cache->name, usage);
+		BUG();
+	}
+	BUG_ON(cache->gc_clear_all);
+
+	obj->put_timestamp = TIME64_MAX;
+	usage = atomic_dec_return(&obj->usage);
+	if (usage > 1)
+		return;
+	smp_wmb();
+	now = current_kernel_time64();
+	obj->put_timestamp = timestamp = now.tv_sec;
+
+	if (timestamp + delay < cache->gc_next_run) {
+		cache->gc_next_run = timestamp + delay;
+		mod_timer(&cache->gc_timer, jiffies + delay * HZ);
+	}
+
+	_leave("");
+}
+
+/*
+ * Kick off a cache garbage collection cycle after the last put of an object
+ * plus a delay.
+ */
+static void objcache_gc_timer_func(unsigned long _cache)
+{
+	struct objcache *cache = (struct objcache *)_cache;
+
+	cache->gc_next_run = TIME64_MAX;
+	cache->gc_needed = true;
+	queue_work(system_long_wq, &cache->gc_work);
+}
+
+/**
+ * objcache_obj_rcu_done - Tell the cache that an object got RCU cleaned.
+ * @cache: The cache holding the object
+ *
+ * Tell the cache that an object got cleaned up.
+ */
+void objcache_obj_rcu_done(struct objcache *cache)
+{
+	if (atomic_dec_and_test(&cache->count))
+		wake_up_atomic_t(&cache->count);
+}
+
+/*
+ * Garbage collect a cache
+ */
+static void objcache_gc(struct work_struct *work)
+{
+	struct objcache *cache = container_of(work, struct objcache, gc_work);
+	struct hlist_head *bucket;
+	struct hlist_node *cursor;
+	LIST_HEAD(graveyard);
+	struct obj_node *obj;
+	time64_t now = get_seconds(), next_run = cache->gc_next_run, expiry;
+	unsigned gc_bucket = cache->gc_bucket;
+	int nr_scanned = 0, usage;
+
+	_enter("%s,%u-%u", cache->name, gc_bucket, cache->gc_last_bucket);
+
+	spin_lock(&cache->lock);
+
+	if (cache->gc_needed) {
+		_debug("GC NEEDED");
+		cache->gc_last_bucket = gc_bucket + cache->nr_buckets;
+		cache->gc_needed = false;
+	}
+
+	while (gc_bucket != cache->gc_last_bucket) {
+		unsigned n = gc_bucket & (cache->nr_buckets - 1);
+		bucket = &cache->hash_table[n];
+		hlist_for_each_entry_safe(obj, cursor, bucket, link) {
+			_debug("GC SEES %p %d", obj, atomic_read(&obj->usage));
+			nr_scanned++;
+			usage = atomic_read(&obj->usage);
+			if (usage > 1) {
+				if (cache->gc_clear_all) {
+					pr_err("objcache_gc: %s still in use (%d)\n",
+					       cache->name, usage);
+				}
+				continue;
+			}
+			expiry = obj->put_timestamp + cache->gc_delay;
+			_debug("GC MAYBE %p at %lld", obj, expiry - now);
+			if (expiry > now && !cache->gc_clear_all) {
+				if (expiry < next_run)
+					next_run = expiry;
+				_debug("GC defer");
+				continue;
+			}
+
+			if (atomic_cmpxchg(&obj->usage, 1, 0) != 1) {
+				_debug("GC can't dec");
+				continue;
+			}
+
+			_debug("GC %p", obj);
+			_debug("GC UNLINK %p %p", obj->link.next, obj->link.pprev);
+			hlist_del_rcu(&obj->link);
+			_debug("GC UNLINK %p %p", obj->link_2.next, obj->link_2.pprev);
+			if (!hlist_unhashed(&obj->link_2) &&
+			    obj->link_2.pprev != LIST_POISON2)
+				hlist_del_rcu(&obj->link_2);
+			list_add_tail(&obj->gc_link, &graveyard);
+		}
+
+		gc_bucket++;
+		if (nr_scanned > 20)
+			break;
+	}
+
+	cache->gc_bucket = gc_bucket;
+	if (next_run < cache->gc_next_run)
+		cache->gc_next_run = next_run;
+	spin_unlock(&cache->lock);
+
+	/* We need to wait for each dead object to quiesce before we can start
+	 * the destruction process.
+	 */
+	while (!list_empty(&graveyard)) {
+		obj = list_entry(graveyard.next, struct obj_node, gc_link);
+		list_del(&obj->gc_link);
+		if (cache->prepare_for_gc)
+			cache->prepare_for_gc(obj);
+		call_rcu(&obj->rcu, cache->gc_rcu);
+	}
+
+	if (!cache->gc_clear_all) {
+		now = get_seconds();
+		if (next_run <= now) {
+			_debug("GC NEXT now %lld", next_run - now);
+			cache->gc_next_run = TIME64_MAX;
+			cache->gc_last_bucket = gc_bucket + cache->nr_buckets;
+		} else if (next_run < TIME64_MAX) {
+			mod_timer(&cache->gc_timer,
+				  jiffies + (next_run - now) * HZ);
+			_debug("GC NEXT timer %lld", next_run - now);
+		} else {
+			_debug("GC cease");
+		}
+	}
+
+	if (gc_bucket != cache->gc_last_bucket)
+		queue_work(system_long_wq, &cache->gc_work);
+	_leave("");
+}
+
+/*
+ * wait_on_atomic_t() sleep function for uninterruptible waiting
+ */
+static int objcache_wait_atomic_t(atomic_t *p)
+{
+	schedule();
+	return 0;
+}
+
+/**
+ * objcache_clear - Clear a cache
+ * @cache: The cache to clear
+ *
+ * Preemptively destroy all the objects in a cache rather than waiting for them
+ * to time out.
+ */
+void objcache_clear(struct objcache *cache)
+{
+	_enter("%s", cache->name);
+
+	spin_lock(&cache->lock);
+	cache->gc_clear_all = true;
+	cache->gc_needed = true;
+	spin_unlock(&cache->lock);
+	del_timer_sync(&cache->gc_timer);
+	queue_work(system_long_wq, &cache->gc_work);
+	wait_on_atomic_t(&cache->count, objcache_wait_atomic_t,
+			 TASK_UNINTERRUPTIBLE);
+	flush_work(&cache->gc_work);
+	synchronize_rcu();
+
+	_leave("");
+}
diff --git a/net/rxrpc/objcache.h b/net/rxrpc/objcache.h
new file mode 100644
index 000000000000..770ec924a6d2
--- /dev/null
+++ b/net/rxrpc/objcache.h
@@ -0,0 +1,89 @@
+/* Common object cache definitions
+ *
+ * Copyright (C) 2015 Red Hat, Inc. All Rights Reserved.
+ * Written by David Howells (dhowells@redhat.com)
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public Licence
+ * as published by the Free Software Foundation; either version
+ * 2 of the Licence, or (at your option) any later version.
+ */
+
+#ifndef _OBJCACHE_H
+#define _OBJCACHE_H
+
+#include <linux/rculist.h>
+#include <linux/workqueue.h>
+#include <linux/timer.h>
+#include <linux/seq_file.h>
+
+struct seq_file;
+
+struct obj_node {
+	union {
+		struct rcu_head		rcu;
+		struct list_head	gc_link;
+	};
+	struct hlist_node	link;
+	struct hlist_node	link_2;
+	unsigned long		full_hash_key;
+	time64_t		put_timestamp;
+	atomic_t		usage;
+};
+
+struct objcache {
+	/* Parameters that must be set before initialisation */
+	const char		*name;
+	void (*prepare_for_gc)(struct obj_node *);
+	void (*gc_rcu)(struct rcu_head *);
+
+	unsigned long (*hash_key)(const void *);
+	int (*cmp_key)(const struct obj_node *, const void *);
+	struct hlist_head	*hash_table;
+	unsigned		gc_delay;
+	u16			nr_buckets;
+
+	/* Secondary hash parameters if we want one - also must be set before
+	 * initialisation.  Note that the secondary hash doesn't store its full
+	 * hash key in the obj_node struct.
+	 */
+	u16			nr_buckets_2;
+	struct hlist_head	*hash_table_2;
+	unsigned long (*hash_key_2)(const void *);
+	int (*cmp_key_2)(const struct obj_node *, const void *);
+
+	/* Internal data */
+	spinlock_t		lock;
+	atomic_t		count;
+	u8			shift;
+	u8			shift_2;
+	bool			gc_needed;
+	bool			gc_clear_all;
+	struct work_struct	gc_work;
+	struct timer_list	gc_timer;
+	time64_t		gc_next_run;
+	unsigned		gc_bucket;
+	unsigned		gc_last_bucket;
+};
+
+static inline bool objcache_get_maybe(struct obj_node *obj)
+{
+	return atomic_inc_not_zero(&obj->usage);
+}
+
+static inline void objcache_get(struct obj_node *obj)
+{
+	atomic_inc(&obj->usage);
+}
+
+extern void objcache_init(struct objcache *);
+extern struct obj_node *objcache_try_add(struct objcache *, struct obj_node *, const void *);
+extern struct obj_node *objcache_lookup_rcu(struct objcache *, const void *);
+extern bool objcache_add_2(struct objcache *, struct obj_node *, const void *, bool);
+extern void objcache_del_2(struct objcache *, struct obj_node *);
+extern struct obj_node *objcache_lookup_rcu_2(struct objcache *, const void *);
+extern void objcache_put(struct objcache *, struct obj_node *);
+extern void objcache_obj_rcu_done(struct objcache *);
+extern void objcache_clear(struct objcache *);
+
+#endif /* _OBJCACHE_H */
