From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 03/18] netfilter: conntrack: remove timer from ecache extension
Date: Fri, 18 Jul 2014 13:00:57 +0200
Message-ID: <1405681272-4994-4-git-send-email-pablo@netfilter.org>
References: <1405681272-4994-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:46547 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756054AbaGRLBS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jul 2014 07:01:18 -0400
In-Reply-To: <1405681272-4994-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

This brings the (per-conntrack) ecache extension back to 24 bytes in size
(was 152 byte on x86_64 with lockdep on).

When event delivery fails, re-delivery is attempted via work queue.

Redelivery is attempted at least every 0.1 seconds, but can happen
more frequently if userspace is not congested.

The nf_ct_release_dying_list() function is removed.
With this patch, ownership of the to-be-redelivered conntracks
(on-dying-list-with-DYING-bit not yet set) is with the work queue,
which will release the references once event is out.

Joint work with Pablo Neira Ayuso.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack_ecache.h |   26 +++++++-
 include/net/netns/conntrack.h               |    6 +-
 net/netfilter/nf_conntrack_core.c           |   68 +++----------------
 net/netfilter/nf_conntrack_ecache.c         |   96 ++++++++++++++++++++++++---
 4 files changed, 124 insertions(+), 72 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_ecache.h b/include/net/netfilter/nf_conntrack_ecache.h
index 0e3d08e..57c8803 100644
--- a/include/net/netfilter/nf_conntrack_ecache.h
+++ b/include/net/netfilter/nf_conntrack_ecache.h
@@ -18,7 +18,6 @@ struct nf_conntrack_ecache {
 	u16 ctmask;		/* bitmask of ct events to be delivered */
 	u16 expmask;		/* bitmask of expect events to be delivered */
 	u32 portid;		/* netlink portid of destroyer */
-	struct timer_list timeout;
 };
 
 static inline struct nf_conntrack_ecache *
@@ -216,8 +215,23 @@ void nf_conntrack_ecache_pernet_fini(struct net *net);
 
 int nf_conntrack_ecache_init(void);
 void nf_conntrack_ecache_fini(void);
-#else /* CONFIG_NF_CONNTRACK_EVENTS */
 
+static inline void nf_conntrack_ecache_delayed_work(struct net *net)
+{
+	if (!delayed_work_pending(&net->ct.ecache_dwork)) {
+		schedule_delayed_work(&net->ct.ecache_dwork, HZ);
+		net->ct.ecache_dwork_pending = true;
+	}
+}
+
+static inline void nf_conntrack_ecache_work(struct net *net)
+{
+	if (net->ct.ecache_dwork_pending) {
+		net->ct.ecache_dwork_pending = false;
+		mod_delayed_work(system_wq, &net->ct.ecache_dwork, 0);
+	}
+}
+#else /* CONFIG_NF_CONNTRACK_EVENTS */
 static inline void nf_conntrack_event_cache(enum ip_conntrack_events event,
 					    struct nf_conn *ct) {}
 static inline int nf_conntrack_eventmask_report(unsigned int eventmask,
@@ -255,6 +269,14 @@ static inline int nf_conntrack_ecache_init(void)
 static inline void nf_conntrack_ecache_fini(void)
 {
 }
+
+static inline void nf_conntrack_ecache_delayed_work(struct net *net)
+{
+}
+
+static inline void nf_conntrack_ecache_work(struct net *net)
+{
+}
 #endif /* CONFIG_NF_CONNTRACK_EVENTS */
 
 #endif /*_NF_CONNTRACK_ECACHE_H*/
diff --git a/include/net/netns/conntrack.h b/include/net/netns/conntrack.h
index 773cce3..29d6a94 100644
--- a/include/net/netns/conntrack.h
+++ b/include/net/netns/conntrack.h
@@ -4,6 +4,7 @@
 #include <linux/list.h>
 #include <linux/list_nulls.h>
 #include <linux/atomic.h>
+#include <linux/workqueue.h>
 #include <linux/netfilter/nf_conntrack_tcp.h>
 #include <linux/seqlock.h>
 
@@ -73,6 +74,10 @@ struct ct_pcpu {
 struct netns_ct {
 	atomic_t		count;
 	unsigned int		expect_count;
+#ifdef CONFIG_NF_CONNTRACK_EVENTS
+	struct delayed_work ecache_dwork;
+	bool ecache_dwork_pending;
+#endif
 #ifdef CONFIG_SYSCTL
 	struct ctl_table_header	*sysctl_header;
 	struct ctl_table_header	*acct_sysctl_header;
@@ -82,7 +87,6 @@ struct netns_ct {
 #endif
 	char			*slabname;
 	unsigned int		sysctl_log_invalid; /* Log invalid packets */
-	unsigned int		sysctl_events_retry_timeout;
 	int			sysctl_events;
 	int			sysctl_acct;
 	int			sysctl_auto_assign_helper;
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 1f4f954..de88c4a 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -352,40 +352,6 @@ static void nf_ct_delete_from_lists(struct nf_conn *ct)
 	local_bh_enable();
 }
 
-static void death_by_event(unsigned long ul_conntrack)
-{
-	struct nf_conn *ct = (void *)ul_conntrack;
-	struct net *net = nf_ct_net(ct);
-	struct nf_conntrack_ecache *ecache = nf_ct_ecache_find(ct);
-
-	BUG_ON(ecache == NULL);
-
-	if (nf_conntrack_event(IPCT_DESTROY, ct) < 0) {
-		/* bad luck, let's retry again */
-		ecache->timeout.expires = jiffies +
-			(prandom_u32() % net->ct.sysctl_events_retry_timeout);
-		add_timer(&ecache->timeout);
-		return;
-	}
-	/* we've got the event delivered, now it's dying */
-	set_bit(IPS_DYING_BIT, &ct->status);
-	nf_ct_put(ct);
-}
-
-static void nf_ct_dying_timeout(struct nf_conn *ct)
-{
-	struct net *net = nf_ct_net(ct);
-	struct nf_conntrack_ecache *ecache = nf_ct_ecache_find(ct);
-
-	BUG_ON(ecache == NULL);
-
-	/* set a new timer to retry event delivery */
-	setup_timer(&ecache->timeout, death_by_event, (unsigned long)ct);
-	ecache->timeout.expires = jiffies +
-		(prandom_u32() % net->ct.sysctl_events_retry_timeout);
-	add_timer(&ecache->timeout);
-}
-
 bool nf_ct_delete(struct nf_conn *ct, u32 portid, int report)
 {
 	struct nf_conn_tstamp *tstamp;
@@ -394,15 +360,20 @@ bool nf_ct_delete(struct nf_conn *ct, u32 portid, int report)
 	if (tstamp && tstamp->stop == 0)
 		tstamp->stop = ktime_to_ns(ktime_get_real());
 
-	if (!nf_ct_is_dying(ct) &&
-	    unlikely(nf_conntrack_event_report(IPCT_DESTROY, ct,
-	    portid, report) < 0)) {
+	if (nf_ct_is_dying(ct))
+		goto delete;
+
+	if (nf_conntrack_event_report(IPCT_DESTROY, ct,
+				    portid, report) < 0) {
 		/* destroy event was not delivered */
 		nf_ct_delete_from_lists(ct);
-		nf_ct_dying_timeout(ct);
+		nf_conntrack_ecache_delayed_work(nf_ct_net(ct));
 		return false;
 	}
+
+	nf_conntrack_ecache_work(nf_ct_net(ct));
 	set_bit(IPS_DYING_BIT, &ct->status);
+ delete:
 	nf_ct_delete_from_lists(ct);
 	nf_ct_put(ct);
 	return true;
@@ -1464,26 +1435,6 @@ void nf_conntrack_flush_report(struct net *net, u32 portid, int report)
 }
 EXPORT_SYMBOL_GPL(nf_conntrack_flush_report);
 
-static void nf_ct_release_dying_list(struct net *net)
-{
-	struct nf_conntrack_tuple_hash *h;
-	struct nf_conn *ct;
-	struct hlist_nulls_node *n;
-	int cpu;
-
-	for_each_possible_cpu(cpu) {
-		struct ct_pcpu *pcpu = per_cpu_ptr(net->ct.pcpu_lists, cpu);
-
-		spin_lock_bh(&pcpu->lock);
-		hlist_nulls_for_each_entry(h, n, &pcpu->dying, hnnode) {
-			ct = nf_ct_tuplehash_to_ctrack(h);
-			/* never fails to remove them, no listeners at this point */
-			nf_ct_kill(ct);
-		}
-		spin_unlock_bh(&pcpu->lock);
-	}
-}
-
 static int untrack_refs(void)
 {
 	int cnt = 0, cpu;
@@ -1548,7 +1499,6 @@ i_see_dead_people:
 	busy = 0;
 	list_for_each_entry(net, net_exit_list, exit_list) {
 		nf_ct_iterate_cleanup(net, kill_all, NULL, 0, 0);
-		nf_ct_release_dying_list(net);
 		if (atomic_read(&net->ct.count) != 0)
 			busy = 1;
 	}
diff --git a/net/netfilter/nf_conntrack_ecache.c b/net/netfilter/nf_conntrack_ecache.c
index 1df1761..4e78c57 100644
--- a/net/netfilter/nf_conntrack_ecache.c
+++ b/net/netfilter/nf_conntrack_ecache.c
@@ -29,6 +29,90 @@
 
 static DEFINE_MUTEX(nf_ct_ecache_mutex);
 
+#define ECACHE_RETRY_WAIT (HZ/10)
+
+enum retry_state {
+	STATE_CONGESTED,
+	STATE_RESTART,
+	STATE_DONE,
+};
+
+static enum retry_state ecache_work_evict_list(struct ct_pcpu *pcpu)
+{
+	struct nf_conn *refs[16];
+	struct nf_conntrack_tuple_hash *h;
+	struct hlist_nulls_node *n;
+	unsigned int evicted = 0;
+	enum retry_state ret = STATE_DONE;
+
+	spin_lock(&pcpu->lock);
+
+	hlist_nulls_for_each_entry(h, n, &pcpu->dying, hnnode) {
+		struct nf_conn *ct = nf_ct_tuplehash_to_ctrack(h);
+
+		if (nf_ct_is_dying(ct))
+			continue;
+
+		if (nf_conntrack_event(IPCT_DESTROY, ct)) {
+			ret = STATE_CONGESTED;
+			break;
+		}
+
+		/* we've got the event delivered, now it's dying */
+		set_bit(IPS_DYING_BIT, &ct->status);
+		refs[evicted] = ct;
+
+		if (++evicted >= ARRAY_SIZE(refs)) {
+			ret = STATE_RESTART;
+			break;
+		}
+	}
+
+	spin_unlock(&pcpu->lock);
+
+	/* can't _put while holding lock */
+	while (evicted)
+		nf_ct_put(refs[--evicted]);
+
+	return ret;
+}
+
+static void ecache_work(struct work_struct *work)
+{
+	struct netns_ct *ctnet =
+		container_of(work, struct netns_ct, ecache_dwork.work);
+	int cpu, delay = -1;
+	struct ct_pcpu *pcpu;
+
+	local_bh_disable();
+
+	for_each_possible_cpu(cpu) {
+		enum retry_state ret;
+
+		pcpu = per_cpu_ptr(ctnet->pcpu_lists, cpu);
+
+		ret = ecache_work_evict_list(pcpu);
+
+		switch (ret) {
+		case STATE_CONGESTED:
+			delay = ECACHE_RETRY_WAIT;
+			goto out;
+		case STATE_RESTART:
+			delay = 0;
+			break;
+		case STATE_DONE:
+			break;
+		}
+	}
+
+ out:
+	local_bh_enable();
+
+	ctnet->ecache_dwork_pending = delay > 0;
+	if (delay >= 0)
+		schedule_delayed_work(&ctnet->ecache_dwork, delay);
+}
+
 /* deliver cached events and clear cache entry - must be called with locally
  * disabled softirqs */
 void nf_ct_deliver_cached_events(struct nf_conn *ct)
@@ -157,7 +241,6 @@ EXPORT_SYMBOL_GPL(nf_ct_expect_unregister_notifier);
 
 #define NF_CT_EVENTS_DEFAULT 1
 static int nf_ct_events __read_mostly = NF_CT_EVENTS_DEFAULT;
-static int nf_ct_events_retry_timeout __read_mostly = 15*HZ;
 
 #ifdef CONFIG_SYSCTL
 static struct ctl_table event_sysctl_table[] = {
@@ -168,13 +251,6 @@ static struct ctl_table event_sysctl_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
 	},
-	{
-		.procname	= "nf_conntrack_events_retry_timeout",
-		.data		= &init_net.ct.sysctl_events_retry_timeout,
-		.maxlen		= sizeof(unsigned int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_jiffies,
-	},
 	{}
 };
 #endif /* CONFIG_SYSCTL */
@@ -196,7 +272,6 @@ static int nf_conntrack_event_init_sysctl(struct net *net)
 		goto out;
 
 	table[0].data = &net->ct.sysctl_events;
-	table[1].data = &net->ct.sysctl_events_retry_timeout;
 
 	/* Don't export sysctls to unprivileged users */
 	if (net->user_ns != &init_user_ns)
@@ -238,12 +313,13 @@ static void nf_conntrack_event_fini_sysctl(struct net *net)
 int nf_conntrack_ecache_pernet_init(struct net *net)
 {
 	net->ct.sysctl_events = nf_ct_events;
-	net->ct.sysctl_events_retry_timeout = nf_ct_events_retry_timeout;
+	INIT_DELAYED_WORK(&net->ct.ecache_dwork, ecache_work);
 	return nf_conntrack_event_init_sysctl(net);
 }
 
 void nf_conntrack_ecache_pernet_fini(struct net *net)
 {
+	cancel_delayed_work_sync(&net->ct.ecache_dwork);
 	nf_conntrack_event_fini_sysctl(net);
 }
 
-- 
1.7.10.4
