From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] flow: better memory management
Date: Fri, 10 Sep 2010 19:00:25 +0200
Message-ID: <1284138025.24675.100.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:61860 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755078Ab0IJRAa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Sep 2010 13:00:30 -0400
Received: by fxm16 with SMTP id 16so1888987fxm.19
        for <netdev@vger.kernel.org>; Fri, 10 Sep 2010 10:00:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allocate hash tables for every online cpus, not every possible ones.

NUMA aware allocations.

Dont use a full page on arches where PAGE_SIZE > 1024*sizeof(void *)

misc:
  __percpu , __read_mostly, __cpuinit annotations
  flow_compare_t is just an "unsigned long"

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/flow.c |   78 ++++++++++++++++++++++++----------------------
 1 files changed, 42 insertions(+), 36 deletions(-)

diff --git a/net/core/flow.c b/net/core/flow.c
index f67dcbf..a092b9c 100644
--- a/net/core/flow.c
+++ b/net/core/flow.c
@@ -53,8 +53,7 @@ struct flow_flush_info {
 
 struct flow_cache {
 	u32				hash_shift;
-	unsigned long			order;
-	struct flow_cache_percpu	*percpu;
+	struct flow_cache_percpu __percpu *percpu;
 	struct notifier_block		hotcpu_notifier;
 	int				low_watermark;
 	int				high_watermark;
@@ -64,7 +63,7 @@ struct flow_cache {
 atomic_t flow_cache_genid = ATOMIC_INIT(0);
 EXPORT_SYMBOL(flow_cache_genid);
 static struct flow_cache flow_cache_global;
-static struct kmem_cache *flow_cachep;
+static struct kmem_cache *flow_cachep __read_mostly;
 
 static DEFINE_SPINLOCK(flow_cache_gc_lock);
 static LIST_HEAD(flow_cache_gc_list);
@@ -181,11 +180,7 @@ static u32 flow_hash_code(struct flow_cache *fc,
 		& (flow_cache_hash_size(fc) - 1));
 }
 
-#if (BITS_PER_LONG == 64)
-typedef u64 flow_compare_t;
-#else
-typedef u32 flow_compare_t;
-#endif
+typedef unsigned long flow_compare_t;
 
 /* I hear what you're saying, use memcmp.  But memcmp cannot make
  * important assumptions that we can here, such as alignment and
@@ -357,62 +352,73 @@ void flow_cache_flush(void)
 	put_online_cpus();
 }
 
-static void __init flow_cache_cpu_prepare(struct flow_cache *fc,
-					  struct flow_cache_percpu *fcp)
+static int __cpuinit flow_cache_cpu_prepare(struct flow_cache *fc, int cpu)
 {
-	fcp->hash_table = (struct hlist_head *)
-		__get_free_pages(GFP_KERNEL|__GFP_ZERO, fc->order);
-	if (!fcp->hash_table)
-		panic("NET: failed to allocate flow cache order %lu\n", fc->order);
+	struct flow_cache_percpu *fcp = per_cpu_ptr(fc->percpu, cpu);
+	size_t sz = sizeof(struct hlist_head) * flow_cache_hash_size(fc);
 
-	fcp->hash_rnd_recalc = 1;
-	fcp->hash_count = 0;
-	tasklet_init(&fcp->flush_tasklet, flow_cache_flush_tasklet, 0);
+	if (!fcp->hash_table) {
+		fcp->hash_table = kzalloc_node(sz, GFP_KERNEL, cpu_to_node(cpu));
+		if (!fcp->hash_table) {
+			pr_err("NET: failed to allocate flow cache sz %zu\n", sz);
+			return -ENOMEM;
+		}
+		fcp->hash_rnd_recalc = 1;
+		fcp->hash_count = 0;
+		tasklet_init(&fcp->flush_tasklet, flow_cache_flush_tasklet, 0);
+	}
+	return 0;
 }
 
-static int flow_cache_cpu(struct notifier_block *nfb,
+static int __cpuinit flow_cache_cpu(struct notifier_block *nfb,
 			  unsigned long action,
 			  void *hcpu)
 {
 	struct flow_cache *fc = container_of(nfb, struct flow_cache, hotcpu_notifier);
-	int cpu = (unsigned long) hcpu;
+	int res, cpu = (unsigned long) hcpu;
 	struct flow_cache_percpu *fcp = per_cpu_ptr(fc->percpu, cpu);
 
-	if (action == CPU_DEAD || action == CPU_DEAD_FROZEN)
+	switch (action) {
+	case CPU_UP_PREPARE:
+	case CPU_UP_PREPARE_FROZEN:
+		res = flow_cache_cpu_prepare(fc, cpu);
+		if (res)
+			return notifier_from_errno(res);	
+		break;
+	case CPU_DEAD:
+	case CPU_DEAD_FROZEN:
 		__flow_cache_shrink(fc, fcp, 0);
+		break;
+	}
 	return NOTIFY_OK;
 }
 
-static int flow_cache_init(struct flow_cache *fc)
+static int __init flow_cache_init(struct flow_cache *fc)
 {
-	unsigned long order;
 	int i;
 
 	fc->hash_shift = 10;
 	fc->low_watermark = 2 * flow_cache_hash_size(fc);
 	fc->high_watermark = 4 * flow_cache_hash_size(fc);
 
-	for (order = 0;
-	     (PAGE_SIZE << order) <
-		     (sizeof(struct hlist_head)*flow_cache_hash_size(fc));
-	     order++)
-		/* NOTHING */;
-	fc->order = order;
 	fc->percpu = alloc_percpu(struct flow_cache_percpu);
+	if (!fc->percpu)
+		return -ENOMEM;
 
-	setup_timer(&fc->rnd_timer, flow_cache_new_hashrnd,
-		    (unsigned long) fc);
-	fc->rnd_timer.expires = jiffies + FLOW_HASH_RND_PERIOD;
-	add_timer(&fc->rnd_timer);
-
-	for_each_possible_cpu(i)
-		flow_cache_cpu_prepare(fc, per_cpu_ptr(fc->percpu, i));
-
+	for_each_online_cpu(i) {
+		if (flow_cache_cpu_prepare(fc, i))
+			return -ENOMEM;
+	}
 	fc->hotcpu_notifier = (struct notifier_block){
 		.notifier_call = flow_cache_cpu,
 	};
 	register_hotcpu_notifier(&fc->hotcpu_notifier);
 
+	setup_timer(&fc->rnd_timer, flow_cache_new_hashrnd,
+		    (unsigned long) fc);
+	fc->rnd_timer.expires = jiffies + FLOW_HASH_RND_PERIOD;
+	add_timer(&fc->rnd_timer);
+
 	return 0;
 }
 


