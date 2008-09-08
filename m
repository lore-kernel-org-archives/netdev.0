From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 16/33] netns ct: per-netns event cache
Date: Mon,  8 Sep 2008 07:02:53 +0400
Message-ID: <1220842990-30500-16-git-send-email-adobriyan@gmail.com>
References: <48C01046.2070704@trash.net>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	containers@lists.linux-foundation.org
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <48C01046.2070704@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Heh, last minute proof-reading of this patch made me think,
that this is actually unneeded, simply because "ct" pointers will be
different for different conntracks in different netns, just like they
are different in one netns.

Not so sure anymore.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

diff --git a/include/net/netfilter/nf_conntrack_ecache.h b/include/net/netfilter/nf_conntrack_ecache.h
index c1b406c..35f814c 100644
--- a/include/net/netfilter/nf_conntrack_ecache.h
+++ b/include/net/netfilter/nf_conntrack_ecache.h
@@ -8,6 +8,7 @@
 
 #include <linux/notifier.h>
 #include <linux/interrupt.h>
+#include <net/net_namespace.h>
 #include <net/netfilter/nf_conntrack_expect.h>
 
 #ifdef CONFIG_NF_CONNTRACK_EVENTS
@@ -15,9 +16,6 @@ struct nf_conntrack_ecache {
 	struct nf_conn *ct;
 	unsigned int events;
 };
-DECLARE_PER_CPU(struct nf_conntrack_ecache, nf_conntrack_ecache);
-
-#define CONNTRACK_ECACHE(x)	(__get_cpu_var(nf_conntrack_ecache).x)
 
 extern struct atomic_notifier_head nf_conntrack_chain;
 extern int nf_conntrack_register_notifier(struct notifier_block *nb);
@@ -25,15 +23,16 @@ extern int nf_conntrack_unregister_notifier(struct notifier_block *nb);
 
 extern void nf_ct_deliver_cached_events(const struct nf_conn *ct);
 extern void __nf_ct_event_cache_init(struct nf_conn *ct);
-extern void nf_ct_event_cache_flush(void);
+extern void nf_ct_event_cache_flush(struct net *net);
 
 static inline void
 nf_conntrack_event_cache(enum ip_conntrack_events event, struct nf_conn *ct)
 {
+	struct net *net = nf_ct_net(ct);
 	struct nf_conntrack_ecache *ecache;
 
 	local_bh_disable();
-	ecache = &__get_cpu_var(nf_conntrack_ecache);
+	ecache = per_cpu_ptr(net->ct.ecache, raw_smp_processor_id());
 	if (ct != ecache->ct)
 		__nf_ct_event_cache_init(ct);
 	ecache->events |= event;
@@ -58,6 +57,9 @@ nf_ct_expect_event(enum ip_conntrack_expect_events event,
 	atomic_notifier_call_chain(&nf_ct_expect_chain, event, exp);
 }
 
+extern int nf_conntrack_ecache_init(struct net *net);
+extern void nf_conntrack_ecache_fini(struct net *net);
+
 #else /* CONFIG_NF_CONNTRACK_EVENTS */
 
 static inline void nf_conntrack_event_cache(enum ip_conntrack_events event,
@@ -67,7 +69,15 @@ static inline void nf_conntrack_event(enum ip_conntrack_events event,
 static inline void nf_ct_deliver_cached_events(const struct nf_conn *ct) {}
 static inline void nf_ct_expect_event(enum ip_conntrack_expect_events event,
 				      struct nf_conntrack_expect *exp) {}
-static inline void nf_ct_event_cache_flush(void) {}
+static inline void nf_ct_event_cache_flush(struct net *net) {}
+
+static inline int nf_conntrack_ecache_init(struct net *net)
+{
+	return 0;
+
+static inline void nf_conntrack_ecache_fini(struct net *net)
+{
+}
 #endif /* CONFIG_NF_CONNTRACK_EVENTS */
 
 #endif /*_NF_CONNTRACK_ECACHE_H*/
diff --git a/include/net/netns/conntrack.h b/include/net/netns/conntrack.h
index 6ddf58e..9d5c162 100644
--- a/include/net/netns/conntrack.h
+++ b/include/net/netns/conntrack.h
@@ -4,12 +4,17 @@
 #include <linux/list.h>
 #include <asm/atomic.h>
 
+struct nf_conntrack_ecache;
+
 struct netns_ct {
 	atomic_t		count;
 	unsigned int		expect_count;
 	struct hlist_head	*hash;
 	struct hlist_head	*expect_hash;
 	struct hlist_head	unconfirmed;
+#ifdef CONFIG_NF_CONNTRACK_EVENTS
+	struct nf_conntrack_ecache *ecache;
+#endif
 	int			hash_vmalloc;
 	int			expect_vmalloc;
 };
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 01f59c5..b55944e 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1023,7 +1023,8 @@ void nf_conntrack_cleanup(struct net *net)
 	   delete... */
 	synchronize_net();
 
-	nf_ct_event_cache_flush();
+	nf_ct_event_cache_flush(net);
+	nf_conntrack_ecache_fini(net);
  i_see_dead_people:
 	nf_conntrack_flush(net);
 	if (atomic_read(&net->ct.count) != 0) {
@@ -1151,11 +1152,14 @@ int nf_conntrack_init(struct net *net)
 		max_factor = 4;
 	}
 	atomic_set(&net->ct.count, 0);
+	ret = nf_conntrack_ecache_init(net);
+	if (ret < 0)
+		goto err_ecache;
 	net->ct.hash = nf_ct_alloc_hashtable(&nf_conntrack_htable_size,
 						  &net->ct.hash_vmalloc);
 	if (!net->ct.hash) {
 		printk(KERN_ERR "Unable to create nf_conntrack_hash\n");
-		goto err_out;
+		goto err_hash;
 	}
 	INIT_HLIST_HEAD(&net->ct.unconfirmed);
 
@@ -1215,6 +1219,8 @@ err_free_conntrack_slab:
 err_free_hash:
 	nf_ct_free_hashtable(net->ct.hash, net->ct.hash_vmalloc,
 			     nf_conntrack_htable_size);
-err_out:
+err_hash:
+	nf_conntrack_ecache_fini(net);
+err_ecache:
 	return -ENOMEM;
 }
diff --git a/net/netfilter/nf_conntrack_ecache.c b/net/netfilter/nf_conntrack_ecache.c
index 83c41ac..a5f5e2e 100644
--- a/net/netfilter/nf_conntrack_ecache.c
+++ b/net/netfilter/nf_conntrack_ecache.c
@@ -29,9 +29,6 @@ EXPORT_SYMBOL_GPL(nf_conntrack_chain);
 ATOMIC_NOTIFIER_HEAD(nf_ct_expect_chain);
 EXPORT_SYMBOL_GPL(nf_ct_expect_chain);
 
-DEFINE_PER_CPU(struct nf_conntrack_ecache, nf_conntrack_ecache);
-EXPORT_PER_CPU_SYMBOL_GPL(nf_conntrack_ecache);
-
 /* deliver cached events and clear cache entry - must be called with locally
  * disabled softirqs */
 static inline void
@@ -51,10 +48,11 @@ __nf_ct_deliver_cached_events(struct nf_conntrack_ecache *ecache)
  * by code prior to async packet handling for freeing the skb */
 void nf_ct_deliver_cached_events(const struct nf_conn *ct)
 {
+	struct net *net = nf_ct_net(ct);
 	struct nf_conntrack_ecache *ecache;
 
 	local_bh_disable();
-	ecache = &__get_cpu_var(nf_conntrack_ecache);
+	ecache = per_cpu_ptr(net->ct.ecache, raw_smp_processor_id());
 	if (ecache->ct == ct)
 		__nf_ct_deliver_cached_events(ecache);
 	local_bh_enable();
@@ -64,10 +62,11 @@ EXPORT_SYMBOL_GPL(nf_ct_deliver_cached_events);
 /* Deliver cached events for old pending events, if current conntrack != old */
 void __nf_ct_event_cache_init(struct nf_conn *ct)
 {
+	struct net *net = nf_ct_net(ct);
 	struct nf_conntrack_ecache *ecache;
 
 	/* take care of delivering potentially old events */
-	ecache = &__get_cpu_var(nf_conntrack_ecache);
+	ecache = per_cpu_ptr(net->ct.ecache, raw_smp_processor_id());
 	BUG_ON(ecache->ct == ct);
 	if (ecache->ct)
 		__nf_ct_deliver_cached_events(ecache);
@@ -79,18 +78,31 @@ EXPORT_SYMBOL_GPL(__nf_ct_event_cache_init);
 
 /* flush the event cache - touches other CPU's data and must not be called
  * while packets are still passing through the code */
-void nf_ct_event_cache_flush(void)
+void nf_ct_event_cache_flush(struct net *net)
 {
 	struct nf_conntrack_ecache *ecache;
 	int cpu;
 
 	for_each_possible_cpu(cpu) {
-		ecache = &per_cpu(nf_conntrack_ecache, cpu);
+		ecache = per_cpu_ptr(net->ct.ecache, cpu);
 		if (ecache->ct)
 			nf_ct_put(ecache->ct);
 	}
 }
 
+int nf_conntrack_ecache_init(struct net *net)
+{
+	net->ct.ecache = alloc_percpu(struct nf_conntrack_ecache);
+	if (!net->ct.ecache)
+		return -ENOMEM;
+	return 0;
+}
+
+void nf_conntrack_ecache_fini(struct net *net)
+{
+	free_percpu(net->ct.ecache);
+}
+
 int nf_conntrack_register_notifier(struct notifier_block *nb)
 {
 	return atomic_notifier_chain_register(&nf_conntrack_chain, nb);
