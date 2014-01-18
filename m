From: Fan Du <fan.du@windriver.com>
Subject: [PATCHv4 net-next 1/2] flowcache: Make flow cache name space aware
Date: Sat, 18 Jan 2014 09:55:27 +0800
Message-ID: <1390010128-15835-2-git-send-email-fan.du@windriver.com>
References: <1390010128-15835-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:63170 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753212AbaARBzd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jan 2014 20:55:33 -0500
In-Reply-To: <1390010128-15835-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Inserting a entry into flowcache, or flushing flowcache should be based
on per net scope. The reason to do so is flushing operation from fat
netns crammed with flow entries will also making the slim netns with only
a few flow cache entries go away in original implementation.

Since flowcache is tightly coupled with IPsec, so it would be easier to
put flow cache global parameters into xfrm namespace part. And one last
thing needs to do is bumping flow cache genid, and flush flow cache should
also be made in per net style.

Signed-off-by: Fan Du <fan.du@windriver.com>
---
 include/net/flow.h              |    5 +-
 include/net/flowcache.h         |   25 ++++++++
 include/net/netns/xfrm.h        |   11 ++++
 net/core/flow.c                 |  127 ++++++++++++++++++---------------------
 net/xfrm/xfrm_policy.c          |    7 ++-
 security/selinux/include/xfrm.h |    5 +-
 6 files changed, 103 insertions(+), 77 deletions(-)
 create mode 100644 include/net/flowcache.h

diff --git a/include/net/flow.h b/include/net/flow.h
index d23e7fa..bee3741 100644
--- a/include/net/flow.h
+++ b/include/net/flow.h
@@ -218,9 +218,10 @@ struct flow_cache_object *flow_cache_lookup(struct net *net,
 					    const struct flowi *key, u16 family,
 					    u8 dir, flow_resolve_t resolver,
 					    void *ctx);
+int flow_cache_init(struct net *net);
 
-void flow_cache_flush(void);
-void flow_cache_flush_deferred(void);
+void flow_cache_flush(struct net *net);
+void flow_cache_flush_deferred(struct net *net);
 extern atomic_t flow_cache_genid;
 
 #endif
diff --git a/include/net/flowcache.h b/include/net/flowcache.h
new file mode 100644
index 0000000..c8f665e
--- /dev/null
+++ b/include/net/flowcache.h
@@ -0,0 +1,25 @@
+#ifndef _NET_FLOWCACHE_H
+#define _NET_FLOWCACHE_H
+
+#include <linux/interrupt.h>
+#include <linux/types.h>
+#include <linux/timer.h>
+#include <linux/notifier.h>
+
+struct flow_cache_percpu {
+	struct hlist_head		*hash_table;
+	int				hash_count;
+	u32				hash_rnd;
+	int				hash_rnd_recalc;
+	struct tasklet_struct		flush_tasklet;
+};
+
+struct flow_cache {
+	u32				hash_shift;
+	struct flow_cache_percpu __percpu *percpu;
+	struct notifier_block		hotcpu_notifier;
+	int				low_watermark;
+	int				high_watermark;
+	struct timer_list		rnd_timer;
+};
+#endif	/* _NET_FLOWCACHE_H */
diff --git a/include/net/netns/xfrm.h b/include/net/netns/xfrm.h
index 1006a26..52d0086 100644
--- a/include/net/netns/xfrm.h
+++ b/include/net/netns/xfrm.h
@@ -6,6 +6,7 @@
 #include <linux/workqueue.h>
 #include <linux/xfrm.h>
 #include <net/dst_ops.h>
+#include <net/flowcache.h>
 
 struct ctl_table_header;
 
@@ -61,6 +62,16 @@ struct netns_xfrm {
 	spinlock_t xfrm_policy_sk_bundle_lock;
 	rwlock_t xfrm_policy_lock;
 	struct mutex xfrm_cfg_mutex;
+
+	/* flow cache part */
+	struct flow_cache	flow_cache_global;
+	struct kmem_cache	*flow_cachep;
+	atomic_t		flow_cache_genid;
+	struct list_head	flow_cache_gc_list;
+	spinlock_t		flow_cache_gc_lock;
+	struct work_struct	flow_cache_gc_work;
+	struct work_struct	flow_cache_flush_work;
+	struct mutex		flow_flush_sem;
 };
 
 #endif
diff --git a/net/core/flow.c b/net/core/flow.c
index dfa602c..344a184 100644
--- a/net/core/flow.c
+++ b/net/core/flow.c
@@ -24,6 +24,7 @@
 #include <net/flow.h>
 #include <linux/atomic.h>
 #include <linux/security.h>
+#include <net/net_namespace.h>
 
 struct flow_cache_entry {
 	union {
@@ -38,37 +39,12 @@ struct flow_cache_entry {
 	struct flow_cache_object	*object;
 };
 
-struct flow_cache_percpu {
-	struct hlist_head		*hash_table;
-	int				hash_count;
-	u32				hash_rnd;
-	int				hash_rnd_recalc;
-	struct tasklet_struct		flush_tasklet;
-};
-
 struct flow_flush_info {
 	struct flow_cache		*cache;
 	atomic_t			cpuleft;
 	struct completion		completion;
 };
 
-struct flow_cache {
-	u32				hash_shift;
-	struct flow_cache_percpu __percpu *percpu;
-	struct notifier_block		hotcpu_notifier;
-	int				low_watermark;
-	int				high_watermark;
-	struct timer_list		rnd_timer;
-};
-
-atomic_t flow_cache_genid = ATOMIC_INIT(0);
-EXPORT_SYMBOL(flow_cache_genid);
-static struct flow_cache flow_cache_global;
-static struct kmem_cache *flow_cachep __read_mostly;
-
-static DEFINE_SPINLOCK(flow_cache_gc_lock);
-static LIST_HEAD(flow_cache_gc_list);
-
 #define flow_cache_hash_size(cache)	(1 << (cache)->hash_shift)
 #define FLOW_HASH_RND_PERIOD		(10 * 60 * HZ)
 
@@ -84,46 +60,50 @@ static void flow_cache_new_hashrnd(unsigned long arg)
 	add_timer(&fc->rnd_timer);
 }
 
-static int flow_entry_valid(struct flow_cache_entry *fle)
+static int flow_entry_valid(struct flow_cache_entry *fle,
+				struct netns_xfrm *xfrm)
 {
-	if (atomic_read(&flow_cache_genid) != fle->genid)
+	if (atomic_read(&xfrm->flow_cache_genid) != fle->genid)
 		return 0;
 	if (fle->object && !fle->object->ops->check(fle->object))
 		return 0;
 	return 1;
 }
 
-static void flow_entry_kill(struct flow_cache_entry *fle)
+static void flow_entry_kill(struct flow_cache_entry *fle,
+				struct netns_xfrm *xfrm)
 {
 	if (fle->object)
 		fle->object->ops->delete(fle->object);
-	kmem_cache_free(flow_cachep, fle);
+	kmem_cache_free(xfrm->flow_cachep, fle);
 }
 
 static void flow_cache_gc_task(struct work_struct *work)
 {
 	struct list_head gc_list;
 	struct flow_cache_entry *fce, *n;
+	struct netns_xfrm *xfrm = container_of(work, struct netns_xfrm,
+						flow_cache_gc_work);
 
 	INIT_LIST_HEAD(&gc_list);
-	spin_lock_bh(&flow_cache_gc_lock);
-	list_splice_tail_init(&flow_cache_gc_list, &gc_list);
-	spin_unlock_bh(&flow_cache_gc_lock);
+	spin_lock_bh(&xfrm->flow_cache_gc_lock);
+	list_splice_tail_init(&xfrm->flow_cache_gc_list, &gc_list);
+	spin_unlock_bh(&xfrm->flow_cache_gc_lock);
 
 	list_for_each_entry_safe(fce, n, &gc_list, u.gc_list)
-		flow_entry_kill(fce);
+		flow_entry_kill(fce, xfrm);
 }
-static DECLARE_WORK(flow_cache_gc_work, flow_cache_gc_task);
 
 static void flow_cache_queue_garbage(struct flow_cache_percpu *fcp,
-				     int deleted, struct list_head *gc_list)
+				     int deleted, struct list_head *gc_list,
+				     struct netns_xfrm *xfrm)
 {
 	if (deleted) {
 		fcp->hash_count -= deleted;
-		spin_lock_bh(&flow_cache_gc_lock);
-		list_splice_tail(gc_list, &flow_cache_gc_list);
-		spin_unlock_bh(&flow_cache_gc_lock);
-		schedule_work(&flow_cache_gc_work);
+		spin_lock_bh(&xfrm->flow_cache_gc_lock);
+		list_splice_tail(gc_list, &xfrm->flow_cache_gc_list);
+		spin_unlock_bh(&xfrm->flow_cache_gc_lock);
+		schedule_work(&xfrm->flow_cache_gc_work);
 	}
 }
 
@@ -135,6 +115,8 @@ static void __flow_cache_shrink(struct flow_cache *fc,
 	struct hlist_node *tmp;
 	LIST_HEAD(gc_list);
 	int i, deleted = 0;
+	struct netns_xfrm *xfrm = container_of(fc, struct netns_xfrm,
+						flow_cache_global);
 
 	for (i = 0; i < flow_cache_hash_size(fc); i++) {
 		int saved = 0;
@@ -142,7 +124,7 @@ static void __flow_cache_shrink(struct flow_cache *fc,
 		hlist_for_each_entry_safe(fle, tmp,
 					  &fcp->hash_table[i], u.hlist) {
 			if (saved < shrink_to &&
-			    flow_entry_valid(fle)) {
+			    flow_entry_valid(fle, xfrm)) {
 				saved++;
 			} else {
 				deleted++;
@@ -152,7 +134,7 @@ static void __flow_cache_shrink(struct flow_cache *fc,
 		}
 	}
 
-	flow_cache_queue_garbage(fcp, deleted, &gc_list);
+	flow_cache_queue_garbage(fcp, deleted, &gc_list, xfrm);
 }
 
 static void flow_cache_shrink(struct flow_cache *fc,
@@ -208,7 +190,7 @@ struct flow_cache_object *
 flow_cache_lookup(struct net *net, const struct flowi *key, u16 family, u8 dir,
 		  flow_resolve_t resolver, void *ctx)
 {
-	struct flow_cache *fc = &flow_cache_global;
+	struct flow_cache *fc = &net->xfrm.flow_cache_global;
 	struct flow_cache_percpu *fcp;
 	struct flow_cache_entry *fle, *tfle;
 	struct flow_cache_object *flo;
@@ -248,7 +230,7 @@ flow_cache_lookup(struct net *net, const struct flowi *key, u16 family, u8 dir,
 		if (fcp->hash_count > fc->high_watermark)
 			flow_cache_shrink(fc, fcp);
 
-		fle = kmem_cache_alloc(flow_cachep, GFP_ATOMIC);
+		fle = kmem_cache_alloc(net->xfrm.flow_cachep, GFP_ATOMIC);
 		if (fle) {
 			fle->net = net;
 			fle->family = family;
@@ -258,7 +240,7 @@ flow_cache_lookup(struct net *net, const struct flowi *key, u16 family, u8 dir,
 			hlist_add_head(&fle->u.hlist, &fcp->hash_table[hash]);
 			fcp->hash_count++;
 		}
-	} else if (likely(fle->genid == atomic_read(&flow_cache_genid))) {
+	} else if (likely(fle->genid == atomic_read(&net->xfrm.flow_cache_genid))) {
 		flo = fle->object;
 		if (!flo)
 			goto ret_object;
@@ -279,7 +261,7 @@ nocache:
 	}
 	flo = resolver(net, key, family, dir, flo, ctx);
 	if (fle) {
-		fle->genid = atomic_read(&flow_cache_genid);
+		fle->genid = atomic_read(&net->xfrm.flow_cache_genid);
 		if (!IS_ERR(flo))
 			fle->object = flo;
 		else
@@ -303,12 +285,14 @@ static void flow_cache_flush_tasklet(unsigned long data)
 	struct hlist_node *tmp;
 	LIST_HEAD(gc_list);
 	int i, deleted = 0;
+	struct netns_xfrm *xfrm = container_of(fc, struct netns_xfrm,
+						flow_cache_global);
 
 	fcp = this_cpu_ptr(fc->percpu);
 	for (i = 0; i < flow_cache_hash_size(fc); i++) {
 		hlist_for_each_entry_safe(fle, tmp,
 					  &fcp->hash_table[i], u.hlist) {
-			if (flow_entry_valid(fle))
+			if (flow_entry_valid(fle, xfrm))
 				continue;
 
 			deleted++;
@@ -317,7 +301,7 @@ static void flow_cache_flush_tasklet(unsigned long data)
 		}
 	}
 
-	flow_cache_queue_garbage(fcp, deleted, &gc_list);
+	flow_cache_queue_garbage(fcp, deleted, &gc_list, xfrm);
 
 	if (atomic_dec_and_test(&info->cpuleft))
 		complete(&info->completion);
@@ -351,10 +335,9 @@ static void flow_cache_flush_per_cpu(void *data)
 	tasklet_schedule(tasklet);
 }
 
-void flow_cache_flush(void)
+void flow_cache_flush(struct net *net)
 {
 	struct flow_flush_info info;
-	static DEFINE_MUTEX(flow_flush_sem);
 	cpumask_var_t mask;
 	int i, self;
 
@@ -365,8 +348,8 @@ void flow_cache_flush(void)
 
 	/* Don't want cpus going down or up during this. */
 	get_online_cpus();
-	mutex_lock(&flow_flush_sem);
-	info.cache = &flow_cache_global;
+	mutex_lock(&net->xfrm.flow_flush_sem);
+	info.cache = &net->xfrm.flow_cache_global;
 	for_each_online_cpu(i)
 		if (!flow_cache_percpu_empty(info.cache, i))
 			cpumask_set_cpu(i, mask);
@@ -386,21 +369,23 @@ void flow_cache_flush(void)
 	wait_for_completion(&info.completion);
 
 done:
-	mutex_unlock(&flow_flush_sem);
+	mutex_unlock(&net->xfrm.flow_flush_sem);
 	put_online_cpus();
 	free_cpumask_var(mask);
 }
 
 static void flow_cache_flush_task(struct work_struct *work)
 {
-	flow_cache_flush();
-}
+	struct netns_xfrm *xfrm = container_of(work, struct netns_xfrm,
+						flow_cache_gc_work);
+	struct net *net = container_of(xfrm, struct net, xfrm);
 
-static DECLARE_WORK(flow_cache_flush_work, flow_cache_flush_task);
+	flow_cache_flush(net);
+}
 
-void flow_cache_flush_deferred(void)
+void flow_cache_flush_deferred(struct net *net)
 {
-	schedule_work(&flow_cache_flush_work);
+	schedule_work(&net->xfrm.flow_cache_flush_work);
 }
 
 static int flow_cache_cpu_prepare(struct flow_cache *fc, int cpu)
@@ -425,7 +410,8 @@ static int flow_cache_cpu(struct notifier_block *nfb,
 			  unsigned long action,
 			  void *hcpu)
 {
-	struct flow_cache *fc = container_of(nfb, struct flow_cache, hotcpu_notifier);
+	struct flow_cache *fc = container_of(nfb, struct flow_cache,
+						hotcpu_notifier);
 	int res, cpu = (unsigned long) hcpu;
 	struct flow_cache_percpu *fcp = per_cpu_ptr(fc->percpu, cpu);
 
@@ -444,9 +430,20 @@ static int flow_cache_cpu(struct notifier_block *nfb,
 	return NOTIFY_OK;
 }
 
-static int __init flow_cache_init(struct flow_cache *fc)
+int flow_cache_init(struct net *net)
 {
 	int i;
+	struct flow_cache *fc = &net->xfrm.flow_cache_global;
+
+	/* Initialize per-net flow cache global variables here */
+	net->xfrm.flow_cachep = kmem_cache_create("flow_cache",
+					sizeof(struct flow_cache_entry),
+					0, SLAB_PANIC, NULL);
+	spin_lock_init(&net->xfrm.flow_cache_gc_lock);
+	INIT_LIST_HEAD(&net->xfrm.flow_cache_gc_list);
+	INIT_WORK(&net->xfrm.flow_cache_gc_work, flow_cache_gc_task);
+	INIT_WORK(&net->xfrm.flow_cache_flush_work, flow_cache_flush_task);
+	mutex_init(&net->xfrm.flow_flush_sem);
 
 	fc->hash_shift = 10;
 	fc->low_watermark = 2 * flow_cache_hash_size(fc);
@@ -484,14 +481,4 @@ err:
 
 	return -ENOMEM;
 }
-
-static int __init flow_cache_init_global(void)
-{
-	flow_cachep = kmem_cache_create("flow_cache",
-					sizeof(struct flow_cache_entry),
-					0, SLAB_PANIC, NULL);
-
-	return flow_cache_init(&flow_cache_global);
-}
-
-module_init(flow_cache_init_global);
+EXPORT_SYMBOL(flow_cache_init);
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 0177082..9d60590 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -661,7 +661,7 @@ int xfrm_policy_insert(int dir, struct xfrm_policy *policy, int excl)
 		hlist_add_head(&policy->bydst, chain);
 	xfrm_pol_hold(policy);
 	net->xfrm.policy_count[dir]++;
-	atomic_inc(&flow_cache_genid);
+	atomic_inc(&net->xfrm.flow_cache_genid);
 
 	/* After previous checking, family can either be AF_INET or AF_INET6 */
 	if (policy->family == AF_INET)
@@ -2567,14 +2567,14 @@ static void __xfrm_garbage_collect(struct net *net)
 
 void xfrm_garbage_collect(struct net *net)
 {
-	flow_cache_flush();
+	flow_cache_flush(net);
 	__xfrm_garbage_collect(net);
 }
 EXPORT_SYMBOL(xfrm_garbage_collect);
 
 static void xfrm_garbage_collect_deferred(struct net *net)
 {
-	flow_cache_flush_deferred();
+	flow_cache_flush_deferred(net);
 	__xfrm_garbage_collect(net);
 }
 
@@ -2947,6 +2947,7 @@ static int __net_init xfrm_net_init(struct net *net)
 	spin_lock_init(&net->xfrm.xfrm_policy_sk_bundle_lock);
 	mutex_init(&net->xfrm.xfrm_cfg_mutex);
 
+	flow_cache_init(net);
 	return 0;
 
 out_sysctl:
diff --git a/security/selinux/include/xfrm.h b/security/selinux/include/xfrm.h
index 48c3cc9..dfe3fda 100644
--- a/security/selinux/include/xfrm.h
+++ b/security/selinux/include/xfrm.h
@@ -45,10 +45,11 @@ static inline void selinux_xfrm_notify_policyload(void)
 {
 	struct net *net;
 
-	atomic_inc(&flow_cache_genid);
 	rtnl_lock();
-	for_each_net(net)
+	for_each_net(net) {
+		atomic_inc(&net->xfrm.flow_cache_genid);
 		rt_genid_bump_all(net);
+	}
 	rtnl_unlock();
 }
 #else
-- 
1.7.9.5
