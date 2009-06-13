From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 03/07: conntrack: move event caching to conntrack extension infrastructure
Date: Sat, 13 Jun 2009 15:09:38 +0200 (MEST)
Message-ID: <20090613130938.2112.29295.sendpatchset@x2.localnet>
References: <20090613130934.2112.65299.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090613130934.2112.65299.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit a0891aa6a635f658f29bb061a00d6d3486941519
Author: Pablo Neira Ayuso <pablo@netfilter.org>
Date:   Sat Jun 13 12:26:29 2009 +0200

    netfilter: conntrack: move event caching to conntrack extension infrastructure
    
    This patch reworks the per-cpu event caching to use the conntrack
    extension infrastructure.
    
    The main drawback is that we consume more memory per conntrack
    if event delivery is enabled. This patch is required by the
    reliable event delivery that follows to this patch.
    
    BTW, this patch allows you to enable/disable event delivery via
    /proc/sys/net/netfilter/nf_conntrack_events in runtime, although
    you can still disable event caching as compilation option.
    
    Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/net/netfilter/nf_conntrack_ecache.h b/include/net/netfilter/nf_conntrack_ecache.h
index 1afb907..e7ae297 100644
--- a/include/net/netfilter/nf_conntrack_ecache.h
+++ b/include/net/netfilter/nf_conntrack_ecache.h
@@ -6,61 +6,52 @@
 #define _NF_CONNTRACK_ECACHE_H
 #include <net/netfilter/nf_conntrack.h>
 
-#include <linux/interrupt.h>
 #include <net/net_namespace.h>
 #include <net/netfilter/nf_conntrack_expect.h>
+#include <linux/netfilter/nf_conntrack_common.h>
+#include <linux/netfilter/nf_conntrack_tuple_common.h>
+#include <net/netfilter/nf_conntrack_extend.h>
 
-/* Connection tracking event bits */
+/* Connection tracking event types */
 enum ip_conntrack_events
 {
-	/* New conntrack */
-	IPCT_NEW_BIT = 0,
-	IPCT_NEW = (1 << IPCT_NEW_BIT),
-
-	/* Expected connection */
-	IPCT_RELATED_BIT = 1,
-	IPCT_RELATED = (1 << IPCT_RELATED_BIT),
-
-	/* Destroyed conntrack */
-	IPCT_DESTROY_BIT = 2,
-	IPCT_DESTROY = (1 << IPCT_DESTROY_BIT),
-
-	/* Status has changed */
-	IPCT_STATUS_BIT = 3,
-	IPCT_STATUS = (1 << IPCT_STATUS_BIT),
+	IPCT_NEW		= 0,	/* new conntrack */
+	IPCT_RELATED		= 1,	/* related conntrack */
+	IPCT_DESTROY		= 2,	/* destroyed conntrack */
+	IPCT_STATUS		= 3,	/* status has changed */
+	IPCT_PROTOINFO		= 4,	/* protocol information has changed */
+	IPCT_HELPER		= 5,	/* new helper has been set */
+	IPCT_MARK		= 6,	/* new mark has been set */
+	IPCT_NATSEQADJ		= 7,	/* NAT is doing sequence adjustment */
+	IPCT_SECMARK		= 8,	/* new security mark has been set */
+};
 
-	/* Update of protocol info */
-	IPCT_PROTOINFO_BIT = 4,
-	IPCT_PROTOINFO = (1 << IPCT_PROTOINFO_BIT),
+enum ip_conntrack_expect_events {
+	IPEXP_NEW		= 0,	/* new expectation */
+};
 
-	/* New helper for conntrack */
-	IPCT_HELPER_BIT = 5,
-	IPCT_HELPER = (1 << IPCT_HELPER_BIT),
+struct nf_conntrack_ecache {
+	unsigned long cache;		/* bitops want long */
+};
 
-	/* Mark is set */
-	IPCT_MARK_BIT = 6,
-	IPCT_MARK = (1 << IPCT_MARK_BIT),
+static inline struct nf_conntrack_ecache *
+nf_ct_ecache_find(const struct nf_conn *ct)
+{
+	return nf_ct_ext_find(ct, NF_CT_EXT_ECACHE);
+}
 
-	/* NAT sequence adjustment */
-	IPCT_NATSEQADJ_BIT = 7,
-	IPCT_NATSEQADJ = (1 << IPCT_NATSEQADJ_BIT),
+static inline struct nf_conntrack_ecache *
+nf_ct_ecache_ext_add(struct nf_conn *ct, gfp_t gfp)
+{
+	struct net *net = nf_ct_net(ct);
 
-	/* Secmark is set */
-	IPCT_SECMARK_BIT = 8,
-	IPCT_SECMARK = (1 << IPCT_SECMARK_BIT),
-};
+	if (!net->ct.sysctl_events)
+		return NULL;
 
-enum ip_conntrack_expect_events {
-	IPEXP_NEW_BIT = 0,
-	IPEXP_NEW = (1 << IPEXP_NEW_BIT),
+	return nf_ct_ext_add(ct, NF_CT_EXT_ECACHE, gfp);
 };
 
 #ifdef CONFIG_NF_CONNTRACK_EVENTS
-struct nf_conntrack_ecache {
-	struct nf_conn *ct;
-	unsigned int events;
-};
-
 /* This structure is passed to event handler */
 struct nf_ct_event {
 	struct nf_conn *ct;
@@ -76,30 +67,30 @@ extern struct nf_ct_event_notifier *nf_conntrack_event_cb;
 extern int nf_conntrack_register_notifier(struct nf_ct_event_notifier *nb);
 extern void nf_conntrack_unregister_notifier(struct nf_ct_event_notifier *nb);
 
-extern void nf_ct_deliver_cached_events(const struct nf_conn *ct);
-extern void __nf_ct_event_cache_init(struct nf_conn *ct);
-extern void nf_ct_event_cache_flush(struct net *net);
+extern void nf_ct_deliver_cached_events(struct nf_conn *ct);
 
 static inline void
 nf_conntrack_event_cache(enum ip_conntrack_events event, struct nf_conn *ct)
 {
-	struct net *net = nf_ct_net(ct);
-	struct nf_conntrack_ecache *ecache;
-
-	local_bh_disable();
-	ecache = per_cpu_ptr(net->ct.ecache, raw_smp_processor_id());
-	if (ct != ecache->ct)
-		__nf_ct_event_cache_init(ct);
-	ecache->events |= event;
-	local_bh_enable();
+	struct nf_conntrack_ecache *e;
+
+	if (nf_conntrack_event_cb == NULL)
+		return;
+
+	e = nf_ct_ecache_find(ct);
+	if (e == NULL)
+		return;
+
+	set_bit(event, &e->cache);
 }
 
 static inline void
-nf_conntrack_event_report(enum ip_conntrack_events event,
-			  struct nf_conn *ct,
-			  u32 pid,
-			  int report)
+nf_conntrack_eventmask_report(unsigned int eventmask,
+			      struct nf_conn *ct,
+			      u32 pid,
+			      int report)
 {
+	struct net *net = nf_ct_net(ct);
 	struct nf_ct_event_notifier *notify;
 
 	rcu_read_lock();
@@ -107,22 +98,32 @@ nf_conntrack_event_report(enum ip_conntrack_events event,
 	if (notify == NULL)
 		goto out_unlock;
 
+	if (!net->ct.sysctl_events)
+		goto out_unlock;
+
 	if (nf_ct_is_confirmed(ct) && !nf_ct_is_dying(ct)) {
 		struct nf_ct_event item = {
 			.ct 	= ct,
 			.pid	= pid,
 			.report = report
 		};
-		notify->fcn(event, &item);
+		notify->fcn(eventmask, &item);
 	}
 out_unlock:
 	rcu_read_unlock();
 }
 
 static inline void
+nf_conntrack_event_report(enum ip_conntrack_events event, struct nf_conn *ct,
+			  u32 pid, int report)
+{
+	nf_conntrack_eventmask_report(1 << event, ct, pid, report);
+}
+
+static inline void
 nf_conntrack_event(enum ip_conntrack_events event, struct nf_conn *ct)
 {
-	nf_conntrack_event_report(event, ct, 0, 0);
+	nf_conntrack_eventmask_report(1 << event, ct, 0, 0);
 }
 
 struct nf_exp_event {
@@ -145,6 +146,7 @@ nf_ct_expect_event_report(enum ip_conntrack_expect_events event,
 			  u32 pid,
 			  int report)
 {
+	struct net *net = nf_ct_exp_net(exp);
 	struct nf_exp_event_notifier *notify;
 
 	rcu_read_lock();
@@ -152,13 +154,16 @@ nf_ct_expect_event_report(enum ip_conntrack_expect_events event,
 	if (notify == NULL)
 		goto out_unlock;
 
+	if (!net->ct.sysctl_events)
+		goto out_unlock;
+
 	{
 		struct nf_exp_event item = {
 			.exp	= exp,
 			.pid	= pid,
 			.report = report
 		};
-		notify->fcn(event, &item);
+		notify->fcn(1 << event, &item);
 	}
 out_unlock:
 	rcu_read_unlock();
@@ -178,6 +183,10 @@ extern void nf_conntrack_ecache_fini(struct net *net);
 
 static inline void nf_conntrack_event_cache(enum ip_conntrack_events event,
 					    struct nf_conn *ct) {}
+static inline void nf_conntrack_eventmask_report(unsigned int eventmask,
+						 struct nf_conn *ct,
+						 u32 pid,
+						 int report) {}
 static inline void nf_conntrack_event(enum ip_conntrack_events event,
 				      struct nf_conn *ct) {}
 static inline void nf_conntrack_event_report(enum ip_conntrack_events event,
@@ -191,7 +200,6 @@ static inline void nf_ct_expect_event_report(enum ip_conntrack_expect_events e,
 					     struct nf_conntrack_expect *exp,
  					     u32 pid,
  					     int report) {}
-static inline void nf_ct_event_cache_flush(struct net *net) {}
 
 static inline int nf_conntrack_ecache_init(struct net *net)
 {
diff --git a/include/net/netfilter/nf_conntrack_extend.h b/include/net/netfilter/nf_conntrack_extend.h
index da8ee52..7f8fc5d 100644
--- a/include/net/netfilter/nf_conntrack_extend.h
+++ b/include/net/netfilter/nf_conntrack_extend.h
@@ -8,12 +8,14 @@ enum nf_ct_ext_id
 	NF_CT_EXT_HELPER,
 	NF_CT_EXT_NAT,
 	NF_CT_EXT_ACCT,
+	NF_CT_EXT_ECACHE,
 	NF_CT_EXT_NUM,
 };
 
 #define NF_CT_EXT_HELPER_TYPE struct nf_conn_help
 #define NF_CT_EXT_NAT_TYPE struct nf_conn_nat
 #define NF_CT_EXT_ACCT_TYPE struct nf_conn_counter
+#define NF_CT_EXT_ECACHE_TYPE struct nf_conntrack_ecache
 
 /* Extensions: optional stuff which isn't permanently in struct. */
 struct nf_ct_ext {
diff --git a/include/net/netns/conntrack.h b/include/net/netns/conntrack.h
index 9dc5840..505a51c 100644
--- a/include/net/netns/conntrack.h
+++ b/include/net/netns/conntrack.h
@@ -15,15 +15,14 @@ struct netns_ct {
 	struct hlist_head	*expect_hash;
 	struct hlist_nulls_head	unconfirmed;
 	struct ip_conntrack_stat *stat;
-#ifdef CONFIG_NF_CONNTRACK_EVENTS
-	struct nf_conntrack_ecache *ecache;
-#endif
+	int			sysctl_events;
 	int			sysctl_acct;
 	int			sysctl_checksum;
 	unsigned int		sysctl_log_invalid; /* Log invalid packets */
 #ifdef CONFIG_SYSCTL
 	struct ctl_table_header	*sysctl_header;
 	struct ctl_table_header	*acct_sysctl_header;
+	struct ctl_table_header	*event_sysctl_header;
 #endif
 	int			hash_vmalloc;
 	int			expect_vmalloc;
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index d8dffe7..bcacbb5 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -39,6 +39,7 @@
 #include <net/netfilter/nf_conntrack_core.h>
 #include <net/netfilter/nf_conntrack_extend.h>
 #include <net/netfilter/nf_conntrack_acct.h>
+#include <net/netfilter/nf_conntrack_ecache.h>
 #include <net/netfilter/nf_nat.h>
 #include <net/netfilter/nf_nat_core.h>
 
@@ -577,6 +578,7 @@ init_conntrack(struct net *net,
 	}
 
 	nf_ct_acct_ext_add(ct, GFP_ATOMIC);
+	nf_ct_ecache_ext_add(ct, GFP_ATOMIC);
 
 	spin_lock_bh(&nf_conntrack_lock);
 	exp = nf_ct_find_expectation(net, tuple);
@@ -1031,8 +1033,6 @@ static void nf_conntrack_cleanup_init_net(void)
 
 static void nf_conntrack_cleanup_net(struct net *net)
 {
-	nf_ct_event_cache_flush(net);
-	nf_conntrack_ecache_fini(net);
  i_see_dead_people:
 	nf_ct_iterate_cleanup(net, kill_all, NULL);
 	if (atomic_read(&net->ct.count) != 0) {
@@ -1045,6 +1045,7 @@ static void nf_conntrack_cleanup_net(struct net *net)
 
 	nf_ct_free_hashtable(net->ct.hash, net->ct.hash_vmalloc,
 			     nf_conntrack_htable_size);
+	nf_conntrack_ecache_fini(net);
 	nf_conntrack_acct_fini(net);
 	nf_conntrack_expect_fini(net);
 	free_percpu(net->ct.stat);
@@ -1220,9 +1221,6 @@ static int nf_conntrack_init_net(struct net *net)
 		ret = -ENOMEM;
 		goto err_stat;
 	}
-	ret = nf_conntrack_ecache_init(net);
-	if (ret < 0)
-		goto err_ecache;
 	net->ct.hash = nf_ct_alloc_hashtable(&nf_conntrack_htable_size,
 					     &net->ct.hash_vmalloc, 1);
 	if (!net->ct.hash) {
@@ -1236,6 +1234,9 @@ static int nf_conntrack_init_net(struct net *net)
 	ret = nf_conntrack_acct_init(net);
 	if (ret < 0)
 		goto err_acct;
+	ret = nf_conntrack_ecache_init(net);
+	if (ret < 0)
+		goto err_ecache;
 
 	/* Set up fake conntrack:
 	    - to never be deleted, not in any hashes */
@@ -1248,14 +1249,14 @@ static int nf_conntrack_init_net(struct net *net)
 
 	return 0;
 
+err_ecache:
+	nf_conntrack_acct_fini(net);
 err_acct:
 	nf_conntrack_expect_fini(net);
 err_expect:
 	nf_ct_free_hashtable(net->ct.hash, net->ct.hash_vmalloc,
 			     nf_conntrack_htable_size);
 err_hash:
-	nf_conntrack_ecache_fini(net);
-err_ecache:
 	free_percpu(net->ct.stat);
 err_stat:
 	return ret;
diff --git a/net/netfilter/nf_conntrack_ecache.c b/net/netfilter/nf_conntrack_ecache.c
index 5516b3e..683281b 100644
--- a/net/netfilter/nf_conntrack_ecache.c
+++ b/net/netfilter/nf_conntrack_ecache.c
@@ -21,6 +21,7 @@
 
 #include <net/netfilter/nf_conntrack.h>
 #include <net/netfilter/nf_conntrack_core.h>
+#include <net/netfilter/nf_conntrack_extend.h>
 
 static DEFINE_MUTEX(nf_ct_ecache_mutex);
 
@@ -32,94 +33,38 @@ EXPORT_SYMBOL_GPL(nf_expect_event_cb);
 
 /* deliver cached events and clear cache entry - must be called with locally
  * disabled softirqs */
-static inline void
-__nf_ct_deliver_cached_events(struct nf_conntrack_ecache *ecache)
+void nf_ct_deliver_cached_events(struct nf_conn *ct)
 {
+	unsigned long events;
 	struct nf_ct_event_notifier *notify;
+	struct nf_conntrack_ecache *e;
 
 	rcu_read_lock();
 	notify = rcu_dereference(nf_conntrack_event_cb);
 	if (notify == NULL)
 		goto out_unlock;
 
-	if (nf_ct_is_confirmed(ecache->ct) && !nf_ct_is_dying(ecache->ct)
-	    && ecache->events) {
+	e = nf_ct_ecache_find(ct);
+	if (e == NULL)
+		goto out_unlock;
+
+	events = xchg(&e->cache, 0);
+
+	if (nf_ct_is_confirmed(ct) && !nf_ct_is_dying(ct) && events) {
 		struct nf_ct_event item = {
-			.ct 	= ecache->ct,
+			.ct	= ct,
 			.pid	= 0,
 			.report	= 0
 		};
 
-		notify->fcn(ecache->events, &item);
+		notify->fcn(events, &item);
 	}
 
-	ecache->events = 0;
-	nf_ct_put(ecache->ct);
-	ecache->ct = NULL;
-
 out_unlock:
 	rcu_read_unlock();
 }
-
-/* Deliver all cached events for a particular conntrack. This is called
- * by code prior to async packet handling for freeing the skb */
-void nf_ct_deliver_cached_events(const struct nf_conn *ct)
-{
-	struct net *net = nf_ct_net(ct);
-	struct nf_conntrack_ecache *ecache;
-
-	local_bh_disable();
-	ecache = per_cpu_ptr(net->ct.ecache, raw_smp_processor_id());
-	if (ecache->ct == ct)
-		__nf_ct_deliver_cached_events(ecache);
-	local_bh_enable();
-}
 EXPORT_SYMBOL_GPL(nf_ct_deliver_cached_events);
 
-/* Deliver cached events for old pending events, if current conntrack != old */
-void __nf_ct_event_cache_init(struct nf_conn *ct)
-{
-	struct net *net = nf_ct_net(ct);
-	struct nf_conntrack_ecache *ecache;
-
-	/* take care of delivering potentially old events */
-	ecache = per_cpu_ptr(net->ct.ecache, raw_smp_processor_id());
-	BUG_ON(ecache->ct == ct);
-	if (ecache->ct)
-		__nf_ct_deliver_cached_events(ecache);
-	/* initialize for this conntrack/packet */
-	ecache->ct = ct;
-	nf_conntrack_get(&ct->ct_general);
-}
-EXPORT_SYMBOL_GPL(__nf_ct_event_cache_init);
-
-/* flush the event cache - touches other CPU's data and must not be called
- * while packets are still passing through the code */
-void nf_ct_event_cache_flush(struct net *net)
-{
-	struct nf_conntrack_ecache *ecache;
-	int cpu;
-
-	for_each_possible_cpu(cpu) {
-		ecache = per_cpu_ptr(net->ct.ecache, cpu);
-		if (ecache->ct)
-			nf_ct_put(ecache->ct);
-	}
-}
-
-int nf_conntrack_ecache_init(struct net *net)
-{
-	net->ct.ecache = alloc_percpu(struct nf_conntrack_ecache);
-	if (!net->ct.ecache)
-		return -ENOMEM;
-	return 0;
-}
-
-void nf_conntrack_ecache_fini(struct net *net)
-{
-	free_percpu(net->ct.ecache);
-}
-
 int nf_conntrack_register_notifier(struct nf_ct_event_notifier *new)
 {
 	int ret = 0;
@@ -185,3 +130,107 @@ void nf_ct_expect_unregister_notifier(struct nf_exp_event_notifier *new)
 	mutex_unlock(&nf_ct_ecache_mutex);
 }
 EXPORT_SYMBOL_GPL(nf_ct_expect_unregister_notifier);
+
+#define NF_CT_EVENTS_DEFAULT 1
+static int nf_ct_events __read_mostly = NF_CT_EVENTS_DEFAULT;
+
+#ifdef CONFIG_SYSCTL
+static struct ctl_table event_sysctl_table[] = {
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "nf_conntrack_events",
+		.data		= &init_net.ct.sysctl_events,
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+	{}
+};
+#endif /* CONFIG_SYSCTL */
+
+static struct nf_ct_ext_type event_extend __read_mostly = {
+	.len	= sizeof(struct nf_conntrack_ecache),
+	.align	= __alignof__(struct nf_conntrack_ecache),
+	.id	= NF_CT_EXT_ECACHE,
+};
+
+#ifdef CONFIG_SYSCTL
+static int nf_conntrack_event_init_sysctl(struct net *net)
+{
+	struct ctl_table *table;
+
+	table = kmemdup(event_sysctl_table, sizeof(event_sysctl_table),
+			GFP_KERNEL);
+	if (!table)
+		goto out;
+
+	table[0].data = &net->ct.sysctl_events;
+
+	net->ct.event_sysctl_header =
+		register_net_sysctl_table(net,
+					  nf_net_netfilter_sysctl_path, table);
+	if (!net->ct.event_sysctl_header) {
+		printk(KERN_ERR "nf_ct_event: can't register to sysctl.\n");
+		goto out_register;
+	}
+	return 0;
+
+out_register:
+	kfree(table);
+out:
+	return -ENOMEM;
+}
+
+static void nf_conntrack_event_fini_sysctl(struct net *net)
+{
+	struct ctl_table *table;
+
+	table = net->ct.event_sysctl_header->ctl_table_arg;
+	unregister_net_sysctl_table(net->ct.event_sysctl_header);
+	kfree(table);
+}
+#else
+static int nf_conntrack_event_init_sysctl(struct net *net)
+{
+	return 0;
+}
+
+static void nf_conntrack_event_fini_sysctl(struct net *net)
+{
+}
+#endif /* CONFIG_SYSCTL */
+
+int nf_conntrack_ecache_init(struct net *net)
+{
+	int ret;
+
+	net->ct.sysctl_events = nf_ct_events;
+
+	if (net_eq(net, &init_net)) {
+		ret = nf_ct_extend_register(&event_extend);
+		if (ret < 0) {
+			printk(KERN_ERR "nf_ct_event: Unable to register "
+					"event extension.\n");
+			goto out_extend_register;
+		}
+	}
+
+	ret = nf_conntrack_event_init_sysctl(net);
+	if (ret < 0)
+		goto out_sysctl;
+
+	return 0;
+
+out_sysctl:
+	if (net_eq(net, &init_net))
+		nf_ct_extend_unregister(&event_extend);
+out_extend_register:
+	return ret;
+}
+
+void nf_conntrack_ecache_fini(struct net *net)
+{
+	nf_conntrack_event_fini_sysctl(net);
+	if (net_eq(net, &init_net))
+		nf_ct_extend_unregister(&event_extend);
+}
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 4e503ad..19706ef 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -468,10 +468,10 @@ ctnetlink_conntrack_event(unsigned int events, struct nf_ct_event *item)
 	if (ct == &nf_conntrack_untracked)
 		return 0;
 
-	if (events & IPCT_DESTROY) {
+	if (events & (1 << IPCT_DESTROY)) {
 		type = IPCTNL_MSG_CT_DELETE;
 		group = NFNLGRP_CONNTRACK_DESTROY;
-	} else  if (events & (IPCT_NEW | IPCT_RELATED)) {
+	} else  if (events & ((1 << IPCT_NEW) | (1 << IPCT_RELATED))) {
 		type = IPCTNL_MSG_CT_NEW;
 		flags = NLM_F_CREATE|NLM_F_EXCL;
 		group = NFNLGRP_CONNTRACK_NEW;
@@ -519,7 +519,7 @@ ctnetlink_conntrack_event(unsigned int events, struct nf_ct_event *item)
 	if (ctnetlink_dump_status(skb, ct) < 0)
 		goto nla_put_failure;
 
-	if (events & IPCT_DESTROY) {
+	if (events & (1 << IPCT_DESTROY)) {
 		if (ctnetlink_dump_counters(skb, ct, IP_CT_DIR_ORIGINAL) < 0 ||
 		    ctnetlink_dump_counters(skb, ct, IP_CT_DIR_REPLY) < 0)
 			goto nla_put_failure;
@@ -527,31 +527,31 @@ ctnetlink_conntrack_event(unsigned int events, struct nf_ct_event *item)
 		if (ctnetlink_dump_timeout(skb, ct) < 0)
 			goto nla_put_failure;
 
-		if (events & IPCT_PROTOINFO
+		if (events & (1 << IPCT_PROTOINFO)
 		    && ctnetlink_dump_protoinfo(skb, ct) < 0)
 			goto nla_put_failure;
 
-		if ((events & IPCT_HELPER || nfct_help(ct))
+		if ((events & (1 << IPCT_HELPER) || nfct_help(ct))
 		    && ctnetlink_dump_helpinfo(skb, ct) < 0)
 			goto nla_put_failure;
 
 #ifdef CONFIG_NF_CONNTRACK_SECMARK
-		if ((events & IPCT_SECMARK || ct->secmark)
+		if ((events & (1 << IPCT_SECMARK) || ct->secmark)
 		    && ctnetlink_dump_secmark(skb, ct) < 0)
 			goto nla_put_failure;
 #endif
 
-		if (events & IPCT_RELATED &&
+		if (events & (1 << IPCT_RELATED) &&
 		    ctnetlink_dump_master(skb, ct) < 0)
 			goto nla_put_failure;
 
-		if (events & IPCT_NATSEQADJ &&
+		if (events & (1 << IPCT_NATSEQADJ) &&
 		    ctnetlink_dump_nat_seq_adj(skb, ct) < 0)
 			goto nla_put_failure;
 	}
 
 #ifdef CONFIG_NF_CONNTRACK_MARK
-	if ((events & IPCT_MARK || ct->mark)
+	if ((events & (1 << IPCT_MARK) || ct->mark)
 	    && ctnetlink_dump_mark(skb, ct) < 0)
 		goto nla_put_failure;
 #endif
@@ -1253,6 +1253,7 @@ ctnetlink_create_conntrack(struct nlattr *cda[],
 	}
 
 	nf_ct_acct_ext_add(ct, GFP_ATOMIC);
+	nf_ct_ecache_ext_add(ct, GFP_ATOMIC);
 
 #if defined(CONFIG_NF_CONNTRACK_MARK)
 	if (cda[CTA_MARK])
@@ -1340,13 +1341,13 @@ ctnetlink_new_conntrack(struct sock *ctnl, struct sk_buff *skb,
 			else
 				events = IPCT_NEW;
 
-			nf_conntrack_event_report(IPCT_STATUS |
-						  IPCT_HELPER |
-						  IPCT_PROTOINFO |
-						  IPCT_NATSEQADJ |
-						  IPCT_MARK | events,
-						  ct, NETLINK_CB(skb).pid,
-						  nlmsg_report(nlh));
+			nf_conntrack_eventmask_report((1 << IPCT_STATUS) |
+						      (1 << IPCT_HELPER) |
+						      (1 << IPCT_PROTOINFO) |
+						      (1 << IPCT_NATSEQADJ) |
+						      (1 << IPCT_MARK) | events,
+						      ct, NETLINK_CB(skb).pid,
+						      nlmsg_report(nlh));
 			nf_ct_put(ct);
 		} else
 			spin_unlock_bh(&nf_conntrack_lock);
@@ -1365,13 +1366,13 @@ ctnetlink_new_conntrack(struct sock *ctnl, struct sk_buff *skb,
 		if (err == 0) {
 			nf_conntrack_get(&ct->ct_general);
 			spin_unlock_bh(&nf_conntrack_lock);
-			nf_conntrack_event_report(IPCT_STATUS |
-						  IPCT_HELPER |
-						  IPCT_PROTOINFO |
-						  IPCT_NATSEQADJ |
-						  IPCT_MARK,
-						  ct, NETLINK_CB(skb).pid,
-						  nlmsg_report(nlh));
+			nf_conntrack_eventmask_report((1 << IPCT_STATUS) |
+						      (1 << IPCT_HELPER) |
+						      (1 << IPCT_PROTOINFO) |
+						      (1 << IPCT_NATSEQADJ) |
+						      (1 << IPCT_MARK),
+						      ct, NETLINK_CB(skb).pid,
+						      nlmsg_report(nlh));
 			nf_ct_put(ct);
 		} else
 			spin_unlock_bh(&nf_conntrack_lock);
@@ -1515,7 +1516,7 @@ ctnetlink_expect_event(unsigned int events, struct nf_exp_event *item)
 	unsigned int type;
 	int flags = 0;
 
-	if (events & IPEXP_NEW) {
+	if (events & (1 << IPEXP_NEW)) {
 		type = IPCTNL_MSG_EXP_NEW;
 		flags = NLM_F_CREATE|NLM_F_EXCL;
 	} else
