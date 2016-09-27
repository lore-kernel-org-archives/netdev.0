From: Florian Westphal <fw@strlen.de>
Subject: [RFC 3/3] xfrm: remove flow cache
Date: Tue, 27 Sep 2016 18:05:23 +0200
Message-ID: <1474992323-11327-4-git-send-email-fw@strlen.de>
References: <1474992323-11327-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:53296 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S934439AbcI0QFg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2016 12:05:36 -0400
In-Reply-To: <1474992323-11327-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

has similar problems as the ipv4 route cache had.

After rcu conversions scalability issues in forward tests
have been resolved.

Performance degradation is currently between 30% (small 64byte packets)
and 10% (1400 byte packets, udp forwarding), mostly due to extra dst
alloc/free overhead.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/net/flow.h       |  52 -----
 include/net/netns/xfrm.h |  10 -
 include/net/xfrm.h       |   3 -
 net/core/Makefile        |   1 -
 net/core/flow.c          | 523 -----------------------------------------------
 net/ipv4/xfrm4_policy.c  |   9 -
 net/ipv6/xfrm6_policy.c  |   9 -
 net/xfrm/xfrm_policy.c   | 294 ++++----------------------
 net/xfrm/xfrm_user.c     |   2 -
 9 files changed, 36 insertions(+), 867 deletions(-)
 delete mode 100644 net/core/flow.c

diff --git a/include/net/flow.h b/include/net/flow.h
index 035aa7716967..ccea17714f6b 100644
--- a/include/net/flow.h
+++ b/include/net/flow.h
@@ -193,57 +193,6 @@ static inline struct flowi *flowidn_to_flowi(struct flowidn *fldn)
 	return container_of(fldn, struct flowi, u.dn);
 }
 
-typedef unsigned long flow_compare_t;
-
-static inline size_t flow_key_size(u16 family)
-{
-	switch (family) {
-	case AF_INET:
-		BUILD_BUG_ON(sizeof(struct flowi4) % sizeof(flow_compare_t));
-		return sizeof(struct flowi4) / sizeof(flow_compare_t);
-	case AF_INET6:
-		BUILD_BUG_ON(sizeof(struct flowi6) % sizeof(flow_compare_t));
-		return sizeof(struct flowi6) / sizeof(flow_compare_t);
-	case AF_DECnet:
-		BUILD_BUG_ON(sizeof(struct flowidn) % sizeof(flow_compare_t));
-		return sizeof(struct flowidn) / sizeof(flow_compare_t);
-	}
-	return 0;
-}
-
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
-
-void flow_cache_flush(struct net *net);
-void flow_cache_flush_deferred(struct net *net);
-extern atomic_t flow_cache_genid;
-
 __u32 __get_hash_from_flowi6(const struct flowi6 *fl6, struct flow_keys *keys);
 
 static inline __u32 get_hash_from_flowi6(const struct flowi6 *fl6)
@@ -261,5 +210,4 @@ static inline __u32 get_hash_from_flowi4(const struct flowi4 *fl4)
 
 	return __get_hash_from_flowi4(fl4, &keys);
 }
-
 #endif
diff --git a/include/net/netns/xfrm.h b/include/net/netns/xfrm.h
index 27bb9633c69d..9dc622ab2328 100644
--- a/include/net/netns/xfrm.h
+++ b/include/net/netns/xfrm.h
@@ -73,16 +73,6 @@ struct netns_xfrm {
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
index 31947b9c21d6..01721c18587c 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -280,7 +280,6 @@ struct xfrm_dst;
 struct xfrm_policy_afinfo {
 	unsigned short		family;
 	struct dst_ops		*dst_ops;
-	void			(*garbage_collect)(struct net *net);
 	struct dst_entry	*(*dst_lookup)(struct net *net,
 					       int tos, int oif,
 					       const xfrm_address_t *saddr,
@@ -527,7 +526,6 @@ struct xfrm_policy {
 	atomic_t		refcnt;
 	struct timer_list	timer;
 
-	struct flow_cache_object flo;
 	atomic_t		genid;
 	u32			priority;
 	u32			index;
@@ -941,7 +939,6 @@ struct xfrm_dst {
 		struct rt6_info		rt6;
 	} u;
 	struct dst_entry *route;
-	struct flow_cache_object flo;
 	struct xfrm_policy *pols[XFRM_POLICY_TYPE_MAX];
 	int num_pols, num_xfrms;
 #ifdef CONFIG_XFRM_SUB_POLICY
diff --git a/net/core/Makefile b/net/core/Makefile
index d6508c2ddca5..1239317a5b0c 100644
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
index 3937b1b68d5b..000000000000
--- a/net/core/flow.c
+++ /dev/null
@@ -1,523 +0,0 @@
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
-#define flow_cache_hash_size(cache)	(1 << (cache)->hash_shift)
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
-		WARN_ON(atomic_read(&xfrm->flow_cache_gc_count) < 0);
-	}
-}
-
-static void flow_cache_queue_garbage(struct flow_cache_percpu *fcp,
-				     int deleted, struct list_head *gc_list,
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
-				int shrink_to)
-{
-	struct flow_cache_entry *fle;
-	struct hlist_node *tmp;
-	LIST_HEAD(gc_list);
-	int i, deleted = 0;
-	struct netns_xfrm *xfrm = container_of(fc, struct netns_xfrm,
-						flow_cache_global);
-
-	for (i = 0; i < flow_cache_hash_size(fc); i++) {
-		int saved = 0;
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
-	int shrink_to = fc->low_watermark / flow_cache_hash_size(fc);
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
-			  size_t keysize)
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
-			    size_t keysize)
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
-	size_t keysize;
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
-		if (fcp->hash_count > 2 * fc->high_watermark ||
-		    atomic_read(&net->xfrm.flow_cache_gc_count) > fc->high_watermark) {
-			atomic_inc(&net->xfrm.flow_cache_genid);
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
-	int i, deleted = 0;
-	struct netns_xfrm *xfrm = container_of(fc, struct netns_xfrm,
-						flow_cache_global);
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
-	int i;
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
-	size_t sz = sizeof(struct hlist_head) * flow_cache_hash_size(fc);
-
-	if (!fcp->hash_table) {
-		fcp->hash_table = kzalloc_node(sz, GFP_KERNEL, cpu_to_node(cpu));
-		if (!fcp->hash_table) {
-			pr_err("NET: failed to allocate flow cache sz %zu\n", sz);
-			return -ENOMEM;
-		}
-		fcp->hash_rnd_recalc = 1;
-		fcp->hash_count = 0;
-		tasklet_init(&fcp->flush_tasklet, flow_cache_flush_tasklet, 0);
-	}
-	return 0;
-}
-
-static int flow_cache_cpu(struct notifier_block *nfb,
-			  unsigned long action,
-			  void *hcpu)
-{
-	struct flow_cache *fc = container_of(nfb, struct flow_cache,
-						hotcpu_notifier);
-	int res, cpu = (unsigned long) hcpu;
-	struct flow_cache_percpu *fcp = per_cpu_ptr(fc->percpu, cpu);
-
-	switch (action) {
-	case CPU_UP_PREPARE:
-	case CPU_UP_PREPARE_FROZEN:
-		res = flow_cache_cpu_prepare(fc, cpu);
-		if (res)
-			return notifier_from_errno(res);
-		break;
-	case CPU_DEAD:
-	case CPU_DEAD_FROZEN:
-		__flow_cache_shrink(fc, fcp, 0);
-		break;
-	}
-	return NOTIFY_OK;
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
-	cpu_notifier_register_begin();
-
-	for_each_online_cpu(i) {
-		if (flow_cache_cpu_prepare(fc, i))
-			goto err;
-	}
-	fc->hotcpu_notifier = (struct notifier_block){
-		.notifier_call = flow_cache_cpu,
-	};
-	__register_hotcpu_notifier(&fc->hotcpu_notifier);
-
-	cpu_notifier_register_done();
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
-	cpu_notifier_register_done();
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
-	unregister_hotcpu_notifier(&fc->hotcpu_notifier);
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
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index 6a7ff6957535..592ccf5a738a 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -215,14 +215,6 @@ _decode_session4(struct sk_buff *skb, struct flowi *fl, int reverse)
 	fl4->flowi4_tos = iph->tos;
 }
 
-static inline int xfrm4_garbage_collect(struct dst_ops *ops)
-{
-	struct net *net = container_of(ops, struct net, xfrm.xfrm4_dst_ops);
-
-	xfrm4_policy_afinfo.garbage_collect(net);
-	return (dst_entries_get_slow(ops) > ops->gc_thresh * 2);
-}
-
 static void xfrm4_update_pmtu(struct dst_entry *dst, struct sock *sk,
 			      struct sk_buff *skb, u32 mtu)
 {
@@ -261,7 +253,6 @@ static void xfrm4_dst_ifdown(struct dst_entry *dst, struct net_device *dev,
 
 static struct dst_ops xfrm4_dst_ops_template = {
 	.family =		AF_INET,
-	.gc =			xfrm4_garbage_collect,
 	.update_pmtu =		xfrm4_update_pmtu,
 	.redirect =		xfrm4_redirect,
 	.cow_metrics =		dst_cow_metrics_generic,
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index e0f71c01d728..5f9494338d00 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -216,14 +216,6 @@ _decode_session6(struct sk_buff *skb, struct flowi *fl, int reverse)
 	}
 }
 
-static inline int xfrm6_garbage_collect(struct dst_ops *ops)
-{
-	struct net *net = container_of(ops, struct net, xfrm.xfrm6_dst_ops);
-
-	xfrm6_policy_afinfo.garbage_collect(net);
-	return dst_entries_get_fast(ops) > ops->gc_thresh * 2;
-}
-
 static void xfrm6_update_pmtu(struct dst_entry *dst, struct sock *sk,
 			      struct sk_buff *skb, u32 mtu)
 {
@@ -281,7 +273,6 @@ static void xfrm6_dst_ifdown(struct dst_entry *dst, struct net_device *dev,
 
 static struct dst_ops xfrm6_dst_ops_template = {
 	.family =		AF_INET6,
-	.gc =			xfrm6_garbage_collect,
 	.update_pmtu =		xfrm6_update_pmtu,
 	.redirect =		xfrm6_redirect,
 	.cow_metrics =		dst_cow_metrics_generic,
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index fd6986634e6f..b8981ef67b55 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -251,36 +251,6 @@ expired:
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
@@ -303,7 +273,6 @@ struct xfrm_policy *xfrm_policy_alloc(struct net *net, gfp_t gfp)
 				(unsigned long)policy);
 		setup_timer(&policy->polq.hold_timer, xfrm_policy_queue_process,
 			    (unsigned long)policy);
-		policy->flo.ops = &xfrm_policy_fc_ops;
 	}
 	return policy;
 }
@@ -803,7 +772,6 @@ int xfrm_policy_insert(int dir, struct xfrm_policy *policy, int excl)
 	else
 		hlist_add_head(&policy->bydst, chain);
 	__xfrm_policy_link(policy, dir);
-	atomic_inc(&net->xfrm.flow_cache_genid);
 
 	/* After previous checking, family can either be AF_INET or AF_INET6 */
 	if (policy->family == AF_INET)
@@ -1192,59 +1160,11 @@ __xfrm_policy_lookup(struct net *net, const struct flowi *fl, u16 family, u8 dir
 	return xfrm_policy_lookup_bytype(net, XFRM_POLICY_TYPE_MAIN, fl, family, dir);
 }
 
-static int flow_to_policy_dir(int dir)
-{
-	if (XFRM_POLICY_IN == FLOW_DIR_IN &&
-	    XFRM_POLICY_OUT == FLOW_DIR_OUT &&
-	    XFRM_POLICY_FWD == FLOW_DIR_FWD)
-		return dir;
-
-	switch (dir) {
-	default:
-	case FLOW_DIR_IN:
-		return XFRM_POLICY_IN;
-	case FLOW_DIR_OUT:
-		return XFRM_POLICY_OUT;
-	case FLOW_DIR_FWD:
-		return XFRM_POLICY_FWD;
-	}
-}
-
-static struct flow_cache_object *
+static struct xfrm_policy *
 xfrm_policy_lookup(struct net *net, const struct flowi *fl, u16 family,
-		   u8 dir, struct flow_cache_object *old_obj, void *ctx)
+		   u8 dir, void *ctx)
 {
-	struct xfrm_policy *pol;
-
-	if (old_obj)
-		xfrm_pol_put(container_of(old_obj, struct xfrm_policy, flo));
-
-	pol = __xfrm_policy_lookup(net, fl, family, flow_to_policy_dir(dir));
-	if (IS_ERR_OR_NULL(pol))
-		return ERR_CAST(pol);
-
-	/* Resolver returns two references:
-	 * one for cache and one for caller of flow_cache_lookup() */
-	xfrm_pol_hold(pol);
-
-	return &pol->flo;
-}
-
-static inline int policy_to_flow_dir(int dir)
-{
-	if (XFRM_POLICY_IN == FLOW_DIR_IN &&
-	    XFRM_POLICY_OUT == FLOW_DIR_OUT &&
-	    XFRM_POLICY_FWD == FLOW_DIR_FWD)
-		return dir;
-	switch (dir) {
-	default:
-	case XFRM_POLICY_IN:
-		return FLOW_DIR_IN;
-	case XFRM_POLICY_OUT:
-		return FLOW_DIR_OUT;
-	case XFRM_POLICY_FWD:
-		return FLOW_DIR_FWD;
-	}
+	return __xfrm_policy_lookup(net, fl, family, dir);
 }
 
 static struct xfrm_policy *xfrm_sk_policy_lookup(const struct sock *sk, int dir,
@@ -1267,7 +1187,7 @@ static struct xfrm_policy *xfrm_sk_policy_lookup(const struct sock *sk, int dir,
 			}
 			err = security_xfrm_policy_lookup(pol->security,
 						      fl->flowi_secid,
-						      policy_to_flow_dir(dir));
+						      dir);
 			if (!err && !xfrm_pol_hold_rcu(pol))
 				goto again;
 			else if (err == -ESRCH)
@@ -1555,56 +1475,6 @@ static inline int xfrm_get_tos(const struct flowi *fl, int family)
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
-	dst_free(dst);
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
 	struct xfrm_policy_afinfo *afinfo = xfrm_policy_get_afinfo(family);
@@ -1626,13 +1496,12 @@ static inline struct xfrm_dst *xfrm_alloc_dst(struct net *net, int family)
 	default:
 		BUG();
 	}
-	xdst = dst_alloc(dst_ops, NULL, 0, DST_OBSOLETE_NONE, 0);
+	xdst = dst_alloc(dst_ops, NULL, 0, DST_OBSOLETE_NONE, DST_NOCACHE);
 
 	if (likely(xdst)) {
 		struct dst_entry *dst = &xdst->u.dst;
 
 		memset(dst + 1, 0, sizeof(*xdst) - sizeof(*dst));
-		xdst->flo.ops = &xfrm_bundle_fc_ops;
 	} else
 		xdst = ERR_PTR(-ENOBUFS);
 
@@ -2108,81 +1977,43 @@ free_dst:
 	goto out;
 }
 
-static struct flow_cache_object *
-xfrm_bundle_lookup(struct net *net, const struct flowi *fl, u16 family, u8 dir,
-		   struct flow_cache_object *oldflo, void *ctx)
+static struct xfrm_dst *
+xfrm_bundle_lookup(struct net *net, const struct flowi *fl, u16 family, u8 dir, struct xfrm_flo *xflo)
 {
-	struct xfrm_flo *xflo = (struct xfrm_flo *)ctx;
 	struct xfrm_policy *pols[XFRM_POLICY_TYPE_MAX];
-	struct xfrm_dst *xdst, *new_xdst;
-	int num_pols = 0, num_xfrms = 0, i, err, pol_dead;
-
-	/* Check if the policies from old bundle are usable */
-	xdst = NULL;
-	if (oldflo) {
-		xdst = container_of(oldflo, struct xfrm_dst, flo);
-		num_pols = xdst->num_pols;
-		num_xfrms = xdst->num_xfrms;
-		pol_dead = 0;
-		for (i = 0; i < num_pols; i++) {
-			pols[i] = xdst->pols[i];
-			pol_dead |= pols[i]->walk.dead;
-		}
-		if (pol_dead) {
-			dst_free(&xdst->u.dst);
-			xdst = NULL;
-			num_pols = 0;
-			num_xfrms = 0;
-			oldflo = NULL;
-		}
-	}
+	struct xfrm_dst *xdst;
+	int num_pols = 0, num_xfrms = 0, err;
 
 	/* Resolve policies to use if we couldn't get them from
 	 * previous cache entry */
-	if (xdst == NULL) {
-		num_pols = 1;
-		pols[0] = __xfrm_policy_lookup(net, fl, family,
-					       flow_to_policy_dir(dir));
-		err = xfrm_expand_policies(fl, family, pols,
+	num_pols = 1;
+	pols[0] = __xfrm_policy_lookup(net, fl, family, dir);
+	err = xfrm_expand_policies(fl, family, pols,
 					   &num_pols, &num_xfrms);
-		if (err < 0)
-			goto inc_error;
-		if (num_pols == 0)
-			return NULL;
-		if (num_xfrms <= 0)
-			goto make_dummy_bundle;
-	}
+	if (err < 0)
+		goto inc_error;
+	if (num_pols == 0)
+		return NULL;
+	if (num_xfrms <= 0)
+		goto make_dummy_bundle;
 
-	new_xdst = xfrm_resolve_and_create_bundle(pols, num_pols, fl, family,
+	xdst = xfrm_resolve_and_create_bundle(pols, num_pols, fl, family,
 						  xflo->dst_orig);
-	if (IS_ERR(new_xdst)) {
-		err = PTR_ERR(new_xdst);
+	if (IS_ERR(xdst)) {
+		err = PTR_ERR(xdst);
 		if (err != -EAGAIN)
 			goto error;
-		if (oldflo == NULL)
-			goto make_dummy_bundle;
-		dst_hold(&xdst->u.dst);
-		return oldflo;
-	} else if (new_xdst == NULL) {
+		goto make_dummy_bundle;
+	} else if (xdst == NULL) {
 		num_xfrms = 0;
-		if (oldflo == NULL)
-			goto make_dummy_bundle;
-		xdst->num_xfrms = 0;
-		dst_hold(&xdst->u.dst);
-		return oldflo;
-	}
-
-	/* Kill the previous bundle */
-	if (xdst) {
-		/* The policies were stolen for newly generated bundle */
-		xdst->num_pols = 0;
-		dst_free(&xdst->u.dst);
+		goto make_dummy_bundle;
 	}
 
 	/* Flow cache does not have reference, it dst_free()'s,
 	 * but we do need to return one reference for original caller */
-	dst_hold(&new_xdst->u.dst);
-	return &new_xdst->flo;
+	dst_hold(&xdst->u.dst);
+
+	return xdst;
 
 make_dummy_bundle:
 	/* We found policies, but there's no bundles to instantiate:
@@ -2198,15 +2029,12 @@ make_dummy_bundle:
 	memcpy(xdst->pols, pols, sizeof(struct xfrm_policy *) * num_pols);
 
 	dst_hold(&xdst->u.dst);
-	return &xdst->flo;
+	return xdst;
 
 inc_error:
 	XFRM_INC_STATS(net, LINUX_MIB_XFRMOUTPOLERROR);
 error:
-	if (xdst != NULL)
-		dst_free(&xdst->u.dst);
-	else
-		xfrm_pols_put(pols, num_pols);
+	xfrm_pols_put(pols, num_pols);
 	return ERR_PTR(err);
 }
 
@@ -2237,11 +2065,10 @@ struct dst_entry *xfrm_lookup(struct net *net, struct dst_entry *dst_orig,
 			      const struct sock *sk, int flags)
 {
 	struct xfrm_policy *pols[XFRM_POLICY_TYPE_MAX];
-	struct flow_cache_object *flo;
 	struct xfrm_dst *xdst;
 	struct dst_entry *dst, *route;
 	u16 family = dst_orig->ops->family;
-	u8 dir = policy_to_flow_dir(XFRM_POLICY_OUT);
+	u8 dir = XFRM_POLICY_OUT;
 	int i, err, num_pols, num_xfrms = 0, drop_pols = 0;
 
 	dst = NULL;
@@ -2293,15 +2120,13 @@ struct dst_entry *xfrm_lookup(struct net *net, struct dst_entry *dst_orig,
 		    !net->xfrm.policy_count[XFRM_POLICY_OUT])
 			goto nopol;
 
-		flo = flow_cache_lookup(net, fl, family, dir,
-					xfrm_bundle_lookup, &xflo);
-		if (flo == NULL)
+		xdst = xfrm_bundle_lookup(net, fl, family, dir, &xflo);
+		if (xdst == NULL)
 			goto nopol;
-		if (IS_ERR(flo)) {
-			err = PTR_ERR(flo);
+		if (IS_ERR(xdst)) {
+			err = PTR_ERR(xdst);
 			goto dropdst;
 		}
-		xdst = container_of(flo, struct xfrm_dst, flo);
 
 		num_pols = xdst->num_pols;
 		num_xfrms = xdst->num_xfrms;
@@ -2500,12 +2325,10 @@ int __xfrm_policy_check(struct sock *sk, int dir, struct sk_buff *skb,
 	int pi;
 	int reverse;
 	struct flowi fl;
-	u8 fl_dir;
 	int xerr_idx = -1;
 
 	reverse = dir & ~XFRM_POLICY_MASK;
 	dir &= XFRM_POLICY_MASK;
-	fl_dir = policy_to_flow_dir(dir);
 
 	if (__xfrm_decode_session(skb, &fl, family, reverse) < 0) {
 		XFRM_INC_STATS(net, LINUX_MIB_XFRMINHDRERROR);
@@ -2537,16 +2360,8 @@ int __xfrm_policy_check(struct sock *sk, int dir, struct sk_buff *skb,
 		}
 	}
 
-	if (!pol) {
-		struct flow_cache_object *flo;
-
-		flo = flow_cache_lookup(net, &fl, family, fl_dir,
-					xfrm_policy_lookup, NULL);
-		if (IS_ERR_OR_NULL(flo))
-			pol = ERR_CAST(flo);
-		else
-			pol = container_of(flo, struct xfrm_policy, flo);
-	}
+	if (!pol)
+		pol = xfrm_policy_lookup(net, &fl, family, dir, NULL);
 
 	if (IS_ERR(pol)) {
 		XFRM_INC_STATS(net, LINUX_MIB_XFRMINPOLERROR);
@@ -2734,17 +2549,6 @@ static struct dst_entry *xfrm_negative_advice(struct dst_entry *dst)
 	return dst;
 }
 
-void xfrm_garbage_collect(struct net *net)
-{
-	flow_cache_flush(net);
-}
-EXPORT_SYMBOL(xfrm_garbage_collect);
-
-static void xfrm_garbage_collect_deferred(struct net *net)
-{
-	flow_cache_flush_deferred(net);
-}
-
 static void xfrm_init_pmtu(struct dst_entry *dst)
 {
 	do {
@@ -2880,8 +2684,6 @@ int xfrm_policy_register_afinfo(struct xfrm_policy_afinfo *afinfo)
 			dst_ops->link_failure = xfrm_link_failure;
 		if (likely(dst_ops->neigh_lookup == NULL))
 			dst_ops->neigh_lookup = xfrm_neigh_lookup;
-		if (likely(afinfo->garbage_collect == NULL))
-			afinfo->garbage_collect = xfrm_garbage_collect_deferred;
 		rcu_assign_pointer(xfrm_policy_afinfo[afinfo->family], afinfo);
 	}
 	spin_unlock(&xfrm_policy_afinfo_lock);
@@ -2915,27 +2717,11 @@ int xfrm_policy_unregister_afinfo(struct xfrm_policy_afinfo *afinfo)
 		dst_ops->check = NULL;
 		dst_ops->negative_advice = NULL;
 		dst_ops->link_failure = NULL;
-		afinfo->garbage_collect = NULL;
 	}
 	return err;
 }
 EXPORT_SYMBOL(xfrm_policy_unregister_afinfo);
 
-static int xfrm_dev_event(struct notifier_block *this, unsigned long event, void *ptr)
-{
-	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
-
-	switch (event) {
-	case NETDEV_DOWN:
-		xfrm_garbage_collect(dev_net(dev));
-	}
-	return NOTIFY_DONE;
-}
-
-static struct notifier_block xfrm_dev_notifier = {
-	.notifier_call	= xfrm_dev_event,
-};
-
 #ifdef CONFIG_XFRM_STATISTICS
 static int __net_init xfrm_statistics_init(struct net *net)
 {
@@ -3011,8 +2797,6 @@ static int __net_init xfrm_policy_init(struct net *net)
 	INIT_LIST_HEAD(&net->xfrm.policy_all);
 	INIT_WORK(&net->xfrm.policy_hash_work, xfrm_hash_resize);
 	INIT_WORK(&net->xfrm.policy_hthresh.work, xfrm_hash_rebuild);
-	if (net_eq(net, &init_net))
-		register_netdevice_notifier(&xfrm_dev_notifier);
 	return 0;
 
 out_bydst:
@@ -3072,9 +2856,6 @@ static int __net_init xfrm_net_init(struct net *net)
 	rv = xfrm_sysctl_init(net);
 	if (rv < 0)
 		goto out_sysctl;
-	rv = flow_cache_init(net);
-	if (rv < 0)
-		goto out;
 
 	/* Initialize the per-net locks here */
 	spin_lock_init(&net->xfrm.xfrm_state_lock);
@@ -3083,8 +2864,6 @@ static int __net_init xfrm_net_init(struct net *net)
 
 	return 0;
 
-out:
-	xfrm_sysctl_fini(net);
 out_sysctl:
 	xfrm_policy_fini(net);
 out_policy:
@@ -3097,7 +2876,6 @@ out_statistics:
 
 static void __net_exit xfrm_net_exit(struct net *net)
 {
-	flow_cache_fini(net);
 	xfrm_sysctl_fini(net);
 	xfrm_policy_fini(net);
 	xfrm_state_fini(net);
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 08892091cfe3..478545291a91 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -1780,8 +1780,6 @@ static int xfrm_get_policy(struct sk_buff *skb, struct nlmsghdr *nlh,
 
 out:
 	xfrm_pol_put(xp);
-	if (delete && err == 0)
-		xfrm_garbage_collect(net);
 	return err;
 }
 
-- 
2.7.3
