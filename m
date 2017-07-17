From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next 09/10] xfrm: remove flow cache
Date: Mon, 17 Jul 2017 13:57:26 +0200
Message-ID: <20170717115727.26042-10-fw@strlen.de>
References: <20170717115727.26042-1-fw@strlen.de>
Cc: steffen.klassert@secunet.com, ilant@mellanox.com,
        Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:43958 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751348AbdGQL5k (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Jul 2017 07:57:40 -0400
In-Reply-To: <20170717115727.26042-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After rcu conversions performance degradation in forward tests isn't that
noticeable anymore.

See next patch for some numbers.

A followup patcg could then also remove genid from the policies
as we do not cache bundles anymore.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/net/flow.h              |  34 ---
 include/net/flowcache.h         |  25 --
 include/net/netns/xfrm.h        |  11 -
 include/net/xfrm.h              |   8 -
 net/core/Makefile               |   1 -
 net/core/flow.c                 | 516 ----------------------------------------
 net/ipv4/xfrm4_policy.c         |   9 -
 net/ipv6/xfrm6_policy.c         |   9 -
 net/key/af_key.c                |   6 -
 net/xfrm/xfrm_device.c          |   2 -
 net/xfrm/xfrm_policy.c          | 108 +--------
 net/xfrm/xfrm_user.c            |   3 -
 security/selinux/include/xfrm.h |   4 +-
 13 files changed, 2 insertions(+), 734 deletions(-)
 delete mode 100644 include/net/flowcache.h
 delete mode 100644 net/core/flow.c

diff --git a/include/net/flow.h b/include/net/flow.h
index bae198b3039e..f3dc61b29bb5 100644
--- a/include/net/flow.h
+++ b/include/net/flow.h
@@ -218,40 +218,6 @@ static inline unsigned int flow_key_size(u16 family)
 	return 0;
 }
 
-#define FLOW_DIR_IN	0
-#define FLOW_DIR_OUT	1
-#define FLOW_DIR_FWD	2
-
-struct net;
-struct sock;
-struct flow_cache_ops;
-
-struct flow_cache_object {
-	const struct flow_cache_ops *ops;
-};
-
-struct flow_cache_ops {
-	struct flow_cache_object *(*get)(struct flow_cache_object *);
-	int (*check)(struct flow_cache_object *);
-	void (*delete)(struct flow_cache_object *);
-};
-
-typedef struct flow_cache_object *(*flow_resolve_t)(
-		struct net *net, const struct flowi *key, u16 family,
-		u8 dir, struct flow_cache_object *oldobj, void *ctx);
-
-struct flow_cache_object *flow_cache_lookup(struct net *net,
-					    const struct flowi *key, u16 family,
-					    u8 dir, flow_resolve_t resolver,
-					    void *ctx);
-int flow_cache_init(struct net *net);
-void flow_cache_fini(struct net *net);
-void flow_cache_hp_init(void);
-
-void flow_cache_flush(struct net *net);
-void flow_cache_flush_deferred(struct net *net);
-extern atomic_t flow_cache_genid;
-
 __u32 __get_hash_from_flowi6(const struct flowi6 *fl6, struct flow_keys *keys);
 
 static inline __u32 get_hash_from_flowi6(const struct flowi6 *fl6)
diff --git a/include/net/flowcache.h b/include/net/flowcache.h
deleted file mode 100644
index 51eb971e8973..000000000000
--- a/include/net/flowcache.h
+++ /dev/null
@@ -1,25 +0,0 @@
-#ifndef _NET_FLOWCACHE_H
-#define _NET_FLOWCACHE_H
-
-#include <linux/interrupt.h>
-#include <linux/types.h>
-#include <linux/timer.h>
-#include <linux/notifier.h>
-
-struct flow_cache_percpu {
-	struct hlist_head		*hash_table;
-	unsigned int			hash_count;
-	u32				hash_rnd;
-	int				hash_rnd_recalc;
-	struct tasklet_struct		flush_tasklet;
-};
-
-struct flow_cache {
-	u32				hash_shift;
-	struct flow_cache_percpu __percpu *percpu;
-	struct hlist_node		node;
-	unsigned int			low_watermark;
-	unsigned int			high_watermark;
-	struct timer_list		rnd_timer;
-};
-#endif	/* _NET_FLOWCACHE_H */
diff --git a/include/net/netns/xfrm.h b/include/net/netns/xfrm.h
index 27bb9633c69d..611521646dd4 100644
--- a/include/net/netns/xfrm.h
+++ b/include/net/netns/xfrm.h
@@ -6,7 +6,6 @@
 #include <linux/workqueue.h>
 #include <linux/xfrm.h>
 #include <net/dst_ops.h>
-#include <net/flowcache.h>
 
 struct ctl_table_header;
 
@@ -73,16 +72,6 @@ struct netns_xfrm {
 	spinlock_t xfrm_state_lock;
 	spinlock_t xfrm_policy_lock;
 	struct mutex xfrm_cfg_mutex;
-
-	/* flow cache part */
-	struct flow_cache	flow_cache_global;
-	atomic_t		flow_cache_genid;
-	struct list_head	flow_cache_gc_list;
-	atomic_t		flow_cache_gc_count;
-	spinlock_t		flow_cache_gc_lock;
-	struct work_struct	flow_cache_gc_work;
-	struct work_struct	flow_cache_flush_work;
-	struct mutex		flow_flush_sem;
 };
 
 #endif
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index c0916ab18d32..e0feba2ce76a 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -563,7 +563,6 @@ struct xfrm_policy {
 	refcount_t		refcnt;
 	struct timer_list	timer;
 
-	struct flow_cache_object flo;
 	atomic_t		genid;
 	u32			priority;
 	u32			index;
@@ -978,7 +977,6 @@ struct xfrm_dst {
 		struct rt6_info		rt6;
 	} u;
 	struct dst_entry *route;
-	struct flow_cache_object flo;
 	struct xfrm_policy *pols[XFRM_POLICY_TYPE_MAX];
 	int num_pols, num_xfrms;
 	u32 xfrm_genid;
@@ -1226,9 +1224,6 @@ static inline void xfrm_sk_free_policy(struct sock *sk)
 	}
 }
 
-void xfrm_garbage_collect(struct net *net);
-void xfrm_garbage_collect_deferred(struct net *net);
-
 #else
 
 static inline void xfrm_sk_free_policy(struct sock *sk) {}
@@ -1263,9 +1258,6 @@ static inline int xfrm6_policy_check_reverse(struct sock *sk, int dir,
 {
 	return 1;
 }
-static inline void xfrm_garbage_collect(struct net *net)
-{
-}
 #endif
 
 static __inline__
diff --git a/net/core/Makefile b/net/core/Makefile
index 79f9479e9658..d501c4278015 100644
--- a/net/core/Makefile
+++ b/net/core/Makefile
@@ -11,7 +11,6 @@ obj-y		     += dev.o ethtool.o dev_addr_lists.o dst.o netevent.o \
 			neighbour.o rtnetlink.o utils.o link_watch.o filter.o \
 			sock_diag.o dev_ioctl.o tso.o sock_reuseport.o
 
-obj-$(CONFIG_XFRM) += flow.o
 obj-y += net-sysfs.o
 obj-$(CONFIG_PROC_FS) += net-procfs.o
 obj-$(CONFIG_NET_PKTGEN) += pktgen.o
diff --git a/net/core/flow.c b/net/core/flow.c
deleted file mode 100644
index f7f5d1932a27..000000000000
--- a/net/core/flow.c
+++ /dev/null
@@ -1,516 +0,0 @@
-/* flow.c: Generic flow cache.
- *
- * Copyright (C) 2003 Alexey N. Kuznetsov (kuznet@ms2.inr.ac.ru)
- * Copyright (C) 2003 David S. Miller (davem@redhat.com)
- */
-
-#include <linux/kernel.h>
-#include <linux/module.h>
-#include <linux/list.h>
-#include <linux/jhash.h>
-#include <linux/interrupt.h>
-#include <linux/mm.h>
-#include <linux/random.h>
-#include <linux/init.h>
-#include <linux/slab.h>
-#include <linux/smp.h>
-#include <linux/completion.h>
-#include <linux/percpu.h>
-#include <linux/bitops.h>
-#include <linux/notifier.h>
-#include <linux/cpu.h>
-#include <linux/cpumask.h>
-#include <linux/mutex.h>
-#include <net/flow.h>
-#include <linux/atomic.h>
-#include <linux/security.h>
-#include <net/net_namespace.h>
-
-struct flow_cache_entry {
-	union {
-		struct hlist_node	hlist;
-		struct list_head	gc_list;
-	} u;
-	struct net			*net;
-	u16				family;
-	u8				dir;
-	u32				genid;
-	struct flowi			key;
-	struct flow_cache_object	*object;
-};
-
-struct flow_flush_info {
-	struct flow_cache		*cache;
-	atomic_t			cpuleft;
-	struct completion		completion;
-};
-
-static struct kmem_cache *flow_cachep __read_mostly;
-
-#define flow_cache_hash_size(cache)	(1U << (cache)->hash_shift)
-#define FLOW_HASH_RND_PERIOD		(10 * 60 * HZ)
-
-static void flow_cache_new_hashrnd(unsigned long arg)
-{
-	struct flow_cache *fc = (void *) arg;
-	int i;
-
-	for_each_possible_cpu(i)
-		per_cpu_ptr(fc->percpu, i)->hash_rnd_recalc = 1;
-
-	fc->rnd_timer.expires = jiffies + FLOW_HASH_RND_PERIOD;
-	add_timer(&fc->rnd_timer);
-}
-
-static int flow_entry_valid(struct flow_cache_entry *fle,
-				struct netns_xfrm *xfrm)
-{
-	if (atomic_read(&xfrm->flow_cache_genid) != fle->genid)
-		return 0;
-	if (fle->object && !fle->object->ops->check(fle->object))
-		return 0;
-	return 1;
-}
-
-static void flow_entry_kill(struct flow_cache_entry *fle,
-				struct netns_xfrm *xfrm)
-{
-	if (fle->object)
-		fle->object->ops->delete(fle->object);
-	kmem_cache_free(flow_cachep, fle);
-}
-
-static void flow_cache_gc_task(struct work_struct *work)
-{
-	struct list_head gc_list;
-	struct flow_cache_entry *fce, *n;
-	struct netns_xfrm *xfrm = container_of(work, struct netns_xfrm,
-						flow_cache_gc_work);
-
-	INIT_LIST_HEAD(&gc_list);
-	spin_lock_bh(&xfrm->flow_cache_gc_lock);
-	list_splice_tail_init(&xfrm->flow_cache_gc_list, &gc_list);
-	spin_unlock_bh(&xfrm->flow_cache_gc_lock);
-
-	list_for_each_entry_safe(fce, n, &gc_list, u.gc_list) {
-		flow_entry_kill(fce, xfrm);
-		atomic_dec(&xfrm->flow_cache_gc_count);
-	}
-}
-
-static void flow_cache_queue_garbage(struct flow_cache_percpu *fcp,
-				     unsigned int deleted,
-				     struct list_head *gc_list,
-				     struct netns_xfrm *xfrm)
-{
-	if (deleted) {
-		atomic_add(deleted, &xfrm->flow_cache_gc_count);
-		fcp->hash_count -= deleted;
-		spin_lock_bh(&xfrm->flow_cache_gc_lock);
-		list_splice_tail(gc_list, &xfrm->flow_cache_gc_list);
-		spin_unlock_bh(&xfrm->flow_cache_gc_lock);
-		schedule_work(&xfrm->flow_cache_gc_work);
-	}
-}
-
-static void __flow_cache_shrink(struct flow_cache *fc,
-				struct flow_cache_percpu *fcp,
-				unsigned int shrink_to)
-{
-	struct flow_cache_entry *fle;
-	struct hlist_node *tmp;
-	LIST_HEAD(gc_list);
-	unsigned int deleted = 0;
-	struct netns_xfrm *xfrm = container_of(fc, struct netns_xfrm,
-						flow_cache_global);
-	unsigned int i;
-
-	for (i = 0; i < flow_cache_hash_size(fc); i++) {
-		unsigned int saved = 0;
-
-		hlist_for_each_entry_safe(fle, tmp,
-					  &fcp->hash_table[i], u.hlist) {
-			if (saved < shrink_to &&
-			    flow_entry_valid(fle, xfrm)) {
-				saved++;
-			} else {
-				deleted++;
-				hlist_del(&fle->u.hlist);
-				list_add_tail(&fle->u.gc_list, &gc_list);
-			}
-		}
-	}
-
-	flow_cache_queue_garbage(fcp, deleted, &gc_list, xfrm);
-}
-
-static void flow_cache_shrink(struct flow_cache *fc,
-			      struct flow_cache_percpu *fcp)
-{
-	unsigned int shrink_to = fc->low_watermark / flow_cache_hash_size(fc);
-
-	__flow_cache_shrink(fc, fcp, shrink_to);
-}
-
-static void flow_new_hash_rnd(struct flow_cache *fc,
-			      struct flow_cache_percpu *fcp)
-{
-	get_random_bytes(&fcp->hash_rnd, sizeof(u32));
-	fcp->hash_rnd_recalc = 0;
-	__flow_cache_shrink(fc, fcp, 0);
-}
-
-static u32 flow_hash_code(struct flow_cache *fc,
-			  struct flow_cache_percpu *fcp,
-			  const struct flowi *key,
-			  unsigned int keysize)
-{
-	const u32 *k = (const u32 *) key;
-	const u32 length = keysize * sizeof(flow_compare_t) / sizeof(u32);
-
-	return jhash2(k, length, fcp->hash_rnd)
-		& (flow_cache_hash_size(fc) - 1);
-}
-
-/* I hear what you're saying, use memcmp.  But memcmp cannot make
- * important assumptions that we can here, such as alignment.
- */
-static int flow_key_compare(const struct flowi *key1, const struct flowi *key2,
-			    unsigned int keysize)
-{
-	const flow_compare_t *k1, *k1_lim, *k2;
-
-	k1 = (const flow_compare_t *) key1;
-	k1_lim = k1 + keysize;
-
-	k2 = (const flow_compare_t *) key2;
-
-	do {
-		if (*k1++ != *k2++)
-			return 1;
-	} while (k1 < k1_lim);
-
-	return 0;
-}
-
-struct flow_cache_object *
-flow_cache_lookup(struct net *net, const struct flowi *key, u16 family, u8 dir,
-		  flow_resolve_t resolver, void *ctx)
-{
-	struct flow_cache *fc = &net->xfrm.flow_cache_global;
-	struct flow_cache_percpu *fcp;
-	struct flow_cache_entry *fle, *tfle;
-	struct flow_cache_object *flo;
-	unsigned int keysize;
-	unsigned int hash;
-
-	local_bh_disable();
-	fcp = this_cpu_ptr(fc->percpu);
-
-	fle = NULL;
-	flo = NULL;
-
-	keysize = flow_key_size(family);
-	if (!keysize)
-		goto nocache;
-
-	/* Packet really early in init?  Making flow_cache_init a
-	 * pre-smp initcall would solve this.  --RR */
-	if (!fcp->hash_table)
-		goto nocache;
-
-	if (fcp->hash_rnd_recalc)
-		flow_new_hash_rnd(fc, fcp);
-
-	hash = flow_hash_code(fc, fcp, key, keysize);
-	hlist_for_each_entry(tfle, &fcp->hash_table[hash], u.hlist) {
-		if (tfle->net == net &&
-		    tfle->family == family &&
-		    tfle->dir == dir &&
-		    flow_key_compare(key, &tfle->key, keysize) == 0) {
-			fle = tfle;
-			break;
-		}
-	}
-
-	if (unlikely(!fle)) {
-		if (fcp->hash_count > fc->high_watermark)
-			flow_cache_shrink(fc, fcp);
-
-		if (atomic_read(&net->xfrm.flow_cache_gc_count) >
-		    2 * num_online_cpus() * fc->high_watermark) {
-			flo = ERR_PTR(-ENOBUFS);
-			goto ret_object;
-		}
-
-		fle = kmem_cache_alloc(flow_cachep, GFP_ATOMIC);
-		if (fle) {
-			fle->net = net;
-			fle->family = family;
-			fle->dir = dir;
-			memcpy(&fle->key, key, keysize * sizeof(flow_compare_t));
-			fle->object = NULL;
-			hlist_add_head(&fle->u.hlist, &fcp->hash_table[hash]);
-			fcp->hash_count++;
-		}
-	} else if (likely(fle->genid == atomic_read(&net->xfrm.flow_cache_genid))) {
-		flo = fle->object;
-		if (!flo)
-			goto ret_object;
-		flo = flo->ops->get(flo);
-		if (flo)
-			goto ret_object;
-	} else if (fle->object) {
-	        flo = fle->object;
-	        flo->ops->delete(flo);
-	        fle->object = NULL;
-	}
-
-nocache:
-	flo = NULL;
-	if (fle) {
-		flo = fle->object;
-		fle->object = NULL;
-	}
-	flo = resolver(net, key, family, dir, flo, ctx);
-	if (fle) {
-		fle->genid = atomic_read(&net->xfrm.flow_cache_genid);
-		if (!IS_ERR(flo))
-			fle->object = flo;
-		else
-			fle->genid--;
-	} else {
-		if (!IS_ERR_OR_NULL(flo))
-			flo->ops->delete(flo);
-	}
-ret_object:
-	local_bh_enable();
-	return flo;
-}
-EXPORT_SYMBOL(flow_cache_lookup);
-
-static void flow_cache_flush_tasklet(unsigned long data)
-{
-	struct flow_flush_info *info = (void *)data;
-	struct flow_cache *fc = info->cache;
-	struct flow_cache_percpu *fcp;
-	struct flow_cache_entry *fle;
-	struct hlist_node *tmp;
-	LIST_HEAD(gc_list);
-	unsigned int deleted = 0;
-	struct netns_xfrm *xfrm = container_of(fc, struct netns_xfrm,
-						flow_cache_global);
-	unsigned int i;
-
-	fcp = this_cpu_ptr(fc->percpu);
-	for (i = 0; i < flow_cache_hash_size(fc); i++) {
-		hlist_for_each_entry_safe(fle, tmp,
-					  &fcp->hash_table[i], u.hlist) {
-			if (flow_entry_valid(fle, xfrm))
-				continue;
-
-			deleted++;
-			hlist_del(&fle->u.hlist);
-			list_add_tail(&fle->u.gc_list, &gc_list);
-		}
-	}
-
-	flow_cache_queue_garbage(fcp, deleted, &gc_list, xfrm);
-
-	if (atomic_dec_and_test(&info->cpuleft))
-		complete(&info->completion);
-}
-
-/*
- * Return whether a cpu needs flushing.  Conservatively, we assume
- * the presence of any entries means the core may require flushing,
- * since the flow_cache_ops.check() function may assume it's running
- * on the same core as the per-cpu cache component.
- */
-static int flow_cache_percpu_empty(struct flow_cache *fc, int cpu)
-{
-	struct flow_cache_percpu *fcp;
-	unsigned int i;
-
-	fcp = per_cpu_ptr(fc->percpu, cpu);
-	for (i = 0; i < flow_cache_hash_size(fc); i++)
-		if (!hlist_empty(&fcp->hash_table[i]))
-			return 0;
-	return 1;
-}
-
-static void flow_cache_flush_per_cpu(void *data)
-{
-	struct flow_flush_info *info = data;
-	struct tasklet_struct *tasklet;
-
-	tasklet = &this_cpu_ptr(info->cache->percpu)->flush_tasklet;
-	tasklet->data = (unsigned long)info;
-	tasklet_schedule(tasklet);
-}
-
-void flow_cache_flush(struct net *net)
-{
-	struct flow_flush_info info;
-	cpumask_var_t mask;
-	int i, self;
-
-	/* Track which cpus need flushing to avoid disturbing all cores. */
-	if (!alloc_cpumask_var(&mask, GFP_KERNEL))
-		return;
-	cpumask_clear(mask);
-
-	/* Don't want cpus going down or up during this. */
-	get_online_cpus();
-	mutex_lock(&net->xfrm.flow_flush_sem);
-	info.cache = &net->xfrm.flow_cache_global;
-	for_each_online_cpu(i)
-		if (!flow_cache_percpu_empty(info.cache, i))
-			cpumask_set_cpu(i, mask);
-	atomic_set(&info.cpuleft, cpumask_weight(mask));
-	if (atomic_read(&info.cpuleft) == 0)
-		goto done;
-
-	init_completion(&info.completion);
-
-	local_bh_disable();
-	self = cpumask_test_and_clear_cpu(smp_processor_id(), mask);
-	on_each_cpu_mask(mask, flow_cache_flush_per_cpu, &info, 0);
-	if (self)
-		flow_cache_flush_tasklet((unsigned long)&info);
-	local_bh_enable();
-
-	wait_for_completion(&info.completion);
-
-done:
-	mutex_unlock(&net->xfrm.flow_flush_sem);
-	put_online_cpus();
-	free_cpumask_var(mask);
-}
-
-static void flow_cache_flush_task(struct work_struct *work)
-{
-	struct netns_xfrm *xfrm = container_of(work, struct netns_xfrm,
-						flow_cache_flush_work);
-	struct net *net = container_of(xfrm, struct net, xfrm);
-
-	flow_cache_flush(net);
-}
-
-void flow_cache_flush_deferred(struct net *net)
-{
-	schedule_work(&net->xfrm.flow_cache_flush_work);
-}
-
-static int flow_cache_cpu_prepare(struct flow_cache *fc, int cpu)
-{
-	struct flow_cache_percpu *fcp = per_cpu_ptr(fc->percpu, cpu);
-	unsigned int sz = sizeof(struct hlist_head) * flow_cache_hash_size(fc);
-
-	if (!fcp->hash_table) {
-		fcp->hash_table = kzalloc_node(sz, GFP_KERNEL, cpu_to_node(cpu));
-		if (!fcp->hash_table) {
-			pr_err("NET: failed to allocate flow cache sz %u\n", sz);
-			return -ENOMEM;
-		}
-		fcp->hash_rnd_recalc = 1;
-		fcp->hash_count = 0;
-		tasklet_init(&fcp->flush_tasklet, flow_cache_flush_tasklet, 0);
-	}
-	return 0;
-}
-
-static int flow_cache_cpu_up_prep(unsigned int cpu, struct hlist_node *node)
-{
-	struct flow_cache *fc = hlist_entry_safe(node, struct flow_cache, node);
-
-	return flow_cache_cpu_prepare(fc, cpu);
-}
-
-static int flow_cache_cpu_dead(unsigned int cpu, struct hlist_node *node)
-{
-	struct flow_cache *fc = hlist_entry_safe(node, struct flow_cache, node);
-	struct flow_cache_percpu *fcp = per_cpu_ptr(fc->percpu, cpu);
-
-	__flow_cache_shrink(fc, fcp, 0);
-	return 0;
-}
-
-int flow_cache_init(struct net *net)
-{
-	int i;
-	struct flow_cache *fc = &net->xfrm.flow_cache_global;
-
-	if (!flow_cachep)
-		flow_cachep = kmem_cache_create("flow_cache",
-						sizeof(struct flow_cache_entry),
-						0, SLAB_PANIC, NULL);
-	spin_lock_init(&net->xfrm.flow_cache_gc_lock);
-	INIT_LIST_HEAD(&net->xfrm.flow_cache_gc_list);
-	INIT_WORK(&net->xfrm.flow_cache_gc_work, flow_cache_gc_task);
-	INIT_WORK(&net->xfrm.flow_cache_flush_work, flow_cache_flush_task);
-	mutex_init(&net->xfrm.flow_flush_sem);
-	atomic_set(&net->xfrm.flow_cache_gc_count, 0);
-
-	fc->hash_shift = 10;
-	fc->low_watermark = 2 * flow_cache_hash_size(fc);
-	fc->high_watermark = 4 * flow_cache_hash_size(fc);
-
-	fc->percpu = alloc_percpu(struct flow_cache_percpu);
-	if (!fc->percpu)
-		return -ENOMEM;
-
-	if (cpuhp_state_add_instance(CPUHP_NET_FLOW_PREPARE, &fc->node))
-		goto err;
-
-	setup_timer(&fc->rnd_timer, flow_cache_new_hashrnd,
-		    (unsigned long) fc);
-	fc->rnd_timer.expires = jiffies + FLOW_HASH_RND_PERIOD;
-	add_timer(&fc->rnd_timer);
-
-	return 0;
-
-err:
-	for_each_possible_cpu(i) {
-		struct flow_cache_percpu *fcp = per_cpu_ptr(fc->percpu, i);
-		kfree(fcp->hash_table);
-		fcp->hash_table = NULL;
-	}
-
-	free_percpu(fc->percpu);
-	fc->percpu = NULL;
-
-	return -ENOMEM;
-}
-EXPORT_SYMBOL(flow_cache_init);
-
-void flow_cache_fini(struct net *net)
-{
-	int i;
-	struct flow_cache *fc = &net->xfrm.flow_cache_global;
-
-	del_timer_sync(&fc->rnd_timer);
-
-	cpuhp_state_remove_instance_nocalls(CPUHP_NET_FLOW_PREPARE, &fc->node);
-
-	for_each_possible_cpu(i) {
-		struct flow_cache_percpu *fcp = per_cpu_ptr(fc->percpu, i);
-		kfree(fcp->hash_table);
-		fcp->hash_table = NULL;
-	}
-
-	free_percpu(fc->percpu);
-	fc->percpu = NULL;
-}
-EXPORT_SYMBOL(flow_cache_fini);
-
-void __init flow_cache_hp_init(void)
-{
-	int ret;
-
-	ret = cpuhp_setup_state_multi(CPUHP_NET_FLOW_PREPARE,
-				      "net/flow:prepare",
-				      flow_cache_cpu_up_prep,
-				      flow_cache_cpu_dead);
-	WARN_ON(ret < 0);
-}
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index 19455a5fc328..4aefb149fe0a 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -213,14 +213,6 @@ _decode_session4(struct sk_buff *skb, struct flowi *fl, int reverse)
 	fl4->flowi4_tos = iph->tos;
 }
 
-static inline int xfrm4_garbage_collect(struct dst_ops *ops)
-{
-	struct net *net = container_of(ops, struct net, xfrm.xfrm4_dst_ops);
-
-	xfrm_garbage_collect_deferred(net);
-	return (dst_entries_get_slow(ops) > ops->gc_thresh * 2);
-}
-
 static void xfrm4_update_pmtu(struct dst_entry *dst, struct sock *sk,
 			      struct sk_buff *skb, u32 mtu)
 {
@@ -259,7 +251,6 @@ static void xfrm4_dst_ifdown(struct dst_entry *dst, struct net_device *dev,
 
 static struct dst_ops xfrm4_dst_ops_template = {
 	.family =		AF_INET,
-	.gc =			xfrm4_garbage_collect,
 	.update_pmtu =		xfrm4_update_pmtu,
 	.redirect =		xfrm4_redirect,
 	.cow_metrics =		dst_cow_metrics_generic,
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index ae30dc4973e8..f44b25a48478 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -214,14 +214,6 @@ _decode_session6(struct sk_buff *skb, struct flowi *fl, int reverse)
 	}
 }
 
-static inline int xfrm6_garbage_collect(struct dst_ops *ops)
-{
-	struct net *net = container_of(ops, struct net, xfrm.xfrm6_dst_ops);
-
-	xfrm_garbage_collect_deferred(net);
-	return dst_entries_get_fast(ops) > ops->gc_thresh * 2;
-}
-
 static void xfrm6_update_pmtu(struct dst_entry *dst, struct sock *sk,
 			      struct sk_buff *skb, u32 mtu)
 {
@@ -279,7 +271,6 @@ static void xfrm6_dst_ifdown(struct dst_entry *dst, struct net_device *dev,
 
 static struct dst_ops xfrm6_dst_ops_template = {
 	.family =		AF_INET6,
-	.gc =			xfrm6_garbage_collect,
 	.update_pmtu =		xfrm6_update_pmtu,
 	.redirect =		xfrm6_redirect,
 	.cow_metrics =		dst_cow_metrics_generic,
diff --git a/net/key/af_key.c b/net/key/af_key.c
index ca9d3ae665e7..10d7133e4fe9 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -2398,8 +2398,6 @@ static int pfkey_spddelete(struct sock *sk, struct sk_buff *skb, const struct sa
 
 out:
 	xfrm_pol_put(xp);
-	if (err == 0)
-		xfrm_garbage_collect(net);
 	return err;
 }
 
@@ -2650,8 +2648,6 @@ static int pfkey_spdget(struct sock *sk, struct sk_buff *skb, const struct sadb_
 
 out:
 	xfrm_pol_put(xp);
-	if (delete && err == 0)
-		xfrm_garbage_collect(net);
 	return err;
 }
 
@@ -2751,8 +2747,6 @@ static int pfkey_spdflush(struct sock *sk, struct sk_buff *skb, const struct sad
 	int err, err2;
 
 	err = xfrm_policy_flush(net, XFRM_POLICY_TYPE_MAIN, true);
-	if (!err)
-		xfrm_garbage_collect(net);
 	err2 = unicast_flush_resp(sk, hdr);
 	if (err || err2) {
 		if (err == -ESRCH) /* empty table - old silent behavior */
diff --git a/net/xfrm/xfrm_device.c b/net/xfrm/xfrm_device.c
index 5f7e8bfa0c2d..1f9a079e08b0 100644
--- a/net/xfrm/xfrm_device.c
+++ b/net/xfrm/xfrm_device.c
@@ -175,8 +175,6 @@ static int xfrm_dev_down(struct net_device *dev)
 	if (dev->features & NETIF_F_HW_ESP)
 		xfrm_dev_state_flush(dev_net(dev), dev, true);
 
-	xfrm_garbage_collect(dev_net(dev));
-
 	return NOTIFY_DONE;
 }
 
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 145d2395f3c0..0f1db4c18b22 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -246,36 +246,6 @@ static void xfrm_policy_timer(unsigned long data)
 	xfrm_pol_put(xp);
 }
 
-static struct flow_cache_object *xfrm_policy_flo_get(struct flow_cache_object *flo)
-{
-	struct xfrm_policy *pol = container_of(flo, struct xfrm_policy, flo);
-
-	if (unlikely(pol->walk.dead))
-		flo = NULL;
-	else
-		xfrm_pol_hold(pol);
-
-	return flo;
-}
-
-static int xfrm_policy_flo_check(struct flow_cache_object *flo)
-{
-	struct xfrm_policy *pol = container_of(flo, struct xfrm_policy, flo);
-
-	return !pol->walk.dead;
-}
-
-static void xfrm_policy_flo_delete(struct flow_cache_object *flo)
-{
-	xfrm_pol_put(container_of(flo, struct xfrm_policy, flo));
-}
-
-static const struct flow_cache_ops xfrm_policy_fc_ops = {
-	.get = xfrm_policy_flo_get,
-	.check = xfrm_policy_flo_check,
-	.delete = xfrm_policy_flo_delete,
-};
-
 /* Allocate xfrm_policy. Not used here, it is supposed to be used by pfkeyv2
  * SPD calls.
  */
@@ -298,7 +268,6 @@ struct xfrm_policy *xfrm_policy_alloc(struct net *net, gfp_t gfp)
 				(unsigned long)policy);
 		setup_timer(&policy->polq.hold_timer, xfrm_policy_queue_process,
 			    (unsigned long)policy);
-		policy->flo.ops = &xfrm_policy_fc_ops;
 	}
 	return policy;
 }
@@ -798,7 +767,6 @@ int xfrm_policy_insert(int dir, struct xfrm_policy *policy, int excl)
 	else
 		hlist_add_head(&policy->bydst, chain);
 	__xfrm_policy_link(policy, dir);
-	atomic_inc(&net->xfrm.flow_cache_genid);
 
 	/* After previous checking, family can either be AF_INET or AF_INET6 */
 	if (policy->family == AF_INET)
@@ -1490,58 +1458,6 @@ static int xfrm_get_tos(const struct flowi *fl, int family)
 	return tos;
 }
 
-static struct flow_cache_object *xfrm_bundle_flo_get(struct flow_cache_object *flo)
-{
-	struct xfrm_dst *xdst = container_of(flo, struct xfrm_dst, flo);
-	struct dst_entry *dst = &xdst->u.dst;
-
-	if (xdst->route == NULL) {
-		/* Dummy bundle - if it has xfrms we were not
-		 * able to build bundle as template resolution failed.
-		 * It means we need to try again resolving. */
-		if (xdst->num_xfrms > 0)
-			return NULL;
-	} else if (dst->flags & DST_XFRM_QUEUE) {
-		return NULL;
-	} else {
-		/* Real bundle */
-		if (stale_bundle(dst))
-			return NULL;
-	}
-
-	dst_hold(dst);
-	return flo;
-}
-
-static int xfrm_bundle_flo_check(struct flow_cache_object *flo)
-{
-	struct xfrm_dst *xdst = container_of(flo, struct xfrm_dst, flo);
-	struct dst_entry *dst = &xdst->u.dst;
-
-	if (!xdst->route)
-		return 0;
-	if (stale_bundle(dst))
-		return 0;
-
-	return 1;
-}
-
-static void xfrm_bundle_flo_delete(struct flow_cache_object *flo)
-{
-	struct xfrm_dst *xdst = container_of(flo, struct xfrm_dst, flo);
-	struct dst_entry *dst = &xdst->u.dst;
-
-	/* Mark DST_OBSOLETE_DEAD to fail the next xfrm_dst_check() */
-	dst->obsolete = DST_OBSOLETE_DEAD;
-	dst_release_immediate(dst);
-}
-
-static const struct flow_cache_ops xfrm_bundle_fc_ops = {
-	.get = xfrm_bundle_flo_get,
-	.check = xfrm_bundle_flo_check,
-	.delete = xfrm_bundle_flo_delete,
-};
-
 static inline struct xfrm_dst *xfrm_alloc_dst(struct net *net, int family)
 {
 	const struct xfrm_policy_afinfo *afinfo = xfrm_policy_get_afinfo(family);
@@ -1569,7 +1485,6 @@ static inline struct xfrm_dst *xfrm_alloc_dst(struct net *net, int family)
 		struct dst_entry *dst = &xdst->u.dst;
 
 		memset(dst + 1, 0, sizeof(*xdst) - sizeof(*dst));
-		xdst->flo.ops = &xfrm_bundle_fc_ops;
 	} else
 		xdst = ERR_PTR(-ENOBUFS);
 
@@ -2521,11 +2436,9 @@ static struct dst_entry *xfrm_dst_check(struct dst_entry *dst, u32 cookie)
 	 * notice.  That's what we are validating here via the
 	 * stale_bundle() check.
 	 *
-	 * When an xdst is removed from flow cache, DST_OBSOLETE_DEAD will
-	 * be marked on it.
 	 * When a dst is removed from the fib tree, DST_OBSOLETE_DEAD will
 	 * be marked on it.
-	 * Both will force stable_bundle() to fail on any xdst bundle with
+	 * This will force stale_bundle() to fail on any xdst bundle with
 	 * this dst linked in it.
 	 */
 	if (dst->obsolete < 0 && !stale_bundle(dst))
@@ -2565,18 +2478,6 @@ static struct dst_entry *xfrm_negative_advice(struct dst_entry *dst)
 	return dst;
 }
 
-void xfrm_garbage_collect(struct net *net)
-{
-	flow_cache_flush(net);
-}
-EXPORT_SYMBOL(xfrm_garbage_collect);
-
-void xfrm_garbage_collect_deferred(struct net *net)
-{
-	flow_cache_flush_deferred(net);
-}
-EXPORT_SYMBOL(xfrm_garbage_collect_deferred);
-
 static void xfrm_init_pmtu(struct dst_entry *dst)
 {
 	do {
@@ -2914,14 +2815,9 @@ static int __net_init xfrm_net_init(struct net *net)
 	rv = xfrm_sysctl_init(net);
 	if (rv < 0)
 		goto out_sysctl;
-	rv = flow_cache_init(net);
-	if (rv < 0)
-		goto out;
 
 	return 0;
 
-out:
-	xfrm_sysctl_fini(net);
 out_sysctl:
 	xfrm_policy_fini(net);
 out_policy:
@@ -2934,7 +2830,6 @@ static int __net_init xfrm_net_init(struct net *net)
 
 static void __net_exit xfrm_net_exit(struct net *net)
 {
-	flow_cache_fini(net);
 	xfrm_sysctl_fini(net);
 	xfrm_policy_fini(net);
 	xfrm_state_fini(net);
@@ -2948,7 +2843,6 @@ static struct pernet_operations __net_initdata xfrm_net_ops = {
 
 void __init xfrm_init(void)
 {
-	flow_cache_hp_init();
 	register_pernet_subsys(&xfrm_net_ops);
 	seqcount_init(&xfrm_policy_hash_generation);
 	xfrm_input_init();
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 2be4c6af008a..1b539b7dcfab 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -1815,8 +1815,6 @@ static int xfrm_get_policy(struct sk_buff *skb, struct nlmsghdr *nlh,
 
 out:
 	xfrm_pol_put(xp);
-	if (delete && err == 0)
-		xfrm_garbage_collect(net);
 	return err;
 }
 
@@ -2027,7 +2025,6 @@ static int xfrm_flush_policy(struct sk_buff *skb, struct nlmsghdr *nlh,
 			return 0;
 		return err;
 	}
-	xfrm_garbage_collect(net);
 
 	c.data.type = type;
 	c.event = nlh->nlmsg_type;
diff --git a/security/selinux/include/xfrm.h b/security/selinux/include/xfrm.h
index 1450f85b946d..36a7ce9e11ff 100644
--- a/security/selinux/include/xfrm.h
+++ b/security/selinux/include/xfrm.h
@@ -47,10 +47,8 @@ static inline void selinux_xfrm_notify_policyload(void)
 	struct net *net;
 
 	rtnl_lock();
-	for_each_net(net) {
-		atomic_inc(&net->xfrm.flow_cache_genid);
+	for_each_net(net)
 		rt_genid_bump_all(net);
-	}
 	rtnl_unlock();
 }
 #else
-- 
2.13.0
