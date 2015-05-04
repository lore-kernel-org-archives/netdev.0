From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 1/4] net: add minimalistic ingress filter hook and port sch_ingress on top of it
Date: Mon,  4 May 2015 12:50:46 +0200
Message-ID: <1430736649-3546-2-git-send-email-pablo@netfilter.org>
References: <1430736649-3546-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org, kaber@trash.net,
	jhs@mojatatu.com
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:58252 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753156AbbEDKq1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 May 2015 06:46:27 -0400
In-Reply-To: <1430736649-3546-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a minimalistic hook infrastructure in netif_receive_core() that
allows you to attach one hook function at a time. In case that is already in
use, you will hit -EBUSY. The first client of this is sch_ingress that has been
ported on top of it. The abstraction is lightweight to avoid performance
concerns, and it is ruled by a global static key.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netdevice.h |   13 ++++++++
 net/Kconfig               |    3 ++
 net/core/dev.c            |   79 +++++++++++++++++++++------------------------
 net/sched/Kconfig         |    1 +
 net/sched/sch_ingress.c   |   38 ++++++++++++++++++++--
 5 files changed, 89 insertions(+), 45 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 1899c74..18e1500 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -770,6 +770,15 @@ struct netdev_phys_item_id {
 typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
 				       struct sk_buff *skb);
 
+/* This allows you to register and to unregister a function the hook for
+ * ingress filtering.
+ */
+typedef struct sk_buff *ingress_hook_func_t(struct sk_buff *skb);
+
+int dev_ingress_hook_register(struct net_device *dev,
+			      ingress_hook_func_t *hookfn);
+void dev_ingress_hook_unregister(struct net_device *dev);
+
 /*
  * This structure defines the management hooks for network devices.
  * The following hooks can be defined; unless noted otherwise, they are
@@ -1655,7 +1664,11 @@ struct net_device {
 	rx_handler_func_t __rcu	*rx_handler;
 	void __rcu		*rx_handler_data;
 
+#ifdef CONFIG_NET_INGRESS_HOOK
+	ingress_hook_func_t __rcu *ingress_hook;
+#endif
 	struct netdev_queue __rcu *ingress_queue;
+
 	unsigned char		broadcast[MAX_ADDR_LEN];
 #ifdef CONFIG_RFS_ACCEL
 	struct cpu_rmap		*rx_cpu_rmap;
diff --git a/net/Kconfig b/net/Kconfig
index 44dd578..f0e2f3f 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -230,6 +230,9 @@ source "net/mpls/Kconfig"
 source "net/hsr/Kconfig"
 source "net/switchdev/Kconfig"
 
+config NET_INGRESS_HOOK
+	bool
+
 config RPS
 	bool
 	depends on SMP && SYSFS
diff --git a/net/core/dev.c b/net/core/dev.c
index 862875e..126d0b1 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1630,20 +1630,41 @@ int call_netdevice_notifiers(unsigned long val, struct net_device *dev)
 }
 EXPORT_SYMBOL(call_netdevice_notifiers);
 
-#ifdef CONFIG_NET_CLS_ACT
+#ifdef CONFIG_NET_INGRESS_HOOK
 static struct static_key ingress_needed __read_mostly;
 
-void net_inc_ingress_queue(void)
+static DEFINE_MUTEX(ingress_hook_mutex);
+
+int dev_ingress_hook_register(struct net_device *dev,
+			      ingress_hook_func_t *hookfn)
 {
+	int ret = 0;
+
+	mutex_lock(&ingress_hook_mutex);
+	if (dev->ingress_hook != NULL) {
+		ret = -EBUSY;
+		goto err1;
+	}
+	rcu_assign_pointer(dev->ingress_hook, hookfn);
+	mutex_unlock(&ingress_hook_mutex);
+
 	static_key_slow_inc(&ingress_needed);
+	return 0;
+err1:
+	mutex_unlock(&ingress_hook_mutex);
+	return ret;
 }
-EXPORT_SYMBOL_GPL(net_inc_ingress_queue);
+EXPORT_SYMBOL_GPL(dev_ingress_hook_register);
 
-void net_dec_ingress_queue(void)
+void dev_ingress_hook_unregister(struct net_device *dev)
 {
+	mutex_lock(&ingress_hook_mutex);
+	rcu_assign_pointer(dev->ingress_hook, NULL);
+	mutex_unlock(&ingress_hook_mutex);
 	static_key_slow_dec(&ingress_needed);
+	synchronize_rcu();
 }
-EXPORT_SYMBOL_GPL(net_dec_ingress_queue);
+EXPORT_SYMBOL_GPL(dev_ingress_hook_unregister);
 #endif
 
 static struct static_key netstamp_needed __read_mostly;
@@ -3520,38 +3541,15 @@ int (*br_fdb_test_addr_hook)(struct net_device *dev,
 EXPORT_SYMBOL_GPL(br_fdb_test_addr_hook);
 #endif
 
-#ifdef CONFIG_NET_CLS_ACT
-/* TODO: Maybe we should just force sch_ingress to be compiled in
- * when CONFIG_NET_CLS_ACT is? otherwise some useless instructions
- * a compare and 2 stores extra right now if we dont have it on
- * but have CONFIG_NET_CLS_ACT
- * NOTE: This doesn't stop any functionality; if you dont have
- * the ingress scheduler, you just can't add policies on ingress.
- *
- */
-static int ing_filter(struct sk_buff *skb, struct netdev_queue *rxq)
-{
-	int result = TC_ACT_OK;
-	struct Qdisc *q;
-
-	skb->tc_verd = SET_TC_AT(skb->tc_verd, AT_INGRESS);
-
-	q = rcu_dereference(rxq->qdisc);
-	if (q != &noop_qdisc) {
-		if (likely(!test_bit(__QDISC_STATE_DEACTIVATED, &q->state)))
-			result = qdisc_enqueue_root(skb, q);
-	}
-
-	return result;
-}
-
+#ifdef CONFIG_NET_INGRESS_HOOK
 static inline struct sk_buff *handle_ing(struct sk_buff *skb,
 					 struct packet_type **pt_prev,
 					 int *ret, struct net_device *orig_dev)
 {
-	struct netdev_queue *rxq = rcu_dereference(skb->dev->ingress_queue);
+	ingress_hook_func_t *ingress_hook;
 
-	if (!rxq || rcu_access_pointer(rxq->qdisc) == &noop_qdisc)
+	ingress_hook = rcu_dereference(skb->dev->ingress_hook);
+	if (ingress_hook == NULL)
 		return skb;
 
 	if (*pt_prev) {
@@ -3559,14 +3557,7 @@ static inline struct sk_buff *handle_ing(struct sk_buff *skb,
 		*pt_prev = NULL;
 	}
 
-	switch (ing_filter(skb, rxq)) {
-	case TC_ACT_SHOT:
-	case TC_ACT_STOLEN:
-		kfree_skb(skb);
-		return NULL;
-	}
-
-	return skb;
+	return ingress_hook(skb);
 }
 #endif
 
@@ -3700,13 +3691,14 @@ another_round:
 	}
 
 skip_taps:
-#ifdef CONFIG_NET_CLS_ACT
+#ifdef CONFIG_NET_INGRESS_HOOK
 	if (static_key_false(&ingress_needed)) {
 		skb = handle_ing(skb, &pt_prev, &ret, orig_dev);
 		if (!skb)
 			goto unlock;
 	}
-
+#endif
+#ifdef CONFIG_NET_CLS_ACT
 	skb->tc_verd = 0;
 ncls:
 #endif
@@ -6846,6 +6838,9 @@ struct net_device *alloc_netdev_mqs(int sizeof_priv, const char *name,
 	if (netif_alloc_netdev_queues(dev))
 		goto free_all;
 
+#ifdef CONFIG_NET_INGRESS_HOOK
+	RCU_INIT_POINTER(dev->ingress_hook, NULL);
+#endif
 #ifdef CONFIG_SYSFS
 	dev->num_rx_queues = rxqs;
 	dev->real_num_rx_queues = rxqs;
diff --git a/net/sched/Kconfig b/net/sched/Kconfig
index 2274e72..3cef39e 100644
--- a/net/sched/Kconfig
+++ b/net/sched/Kconfig
@@ -312,6 +312,7 @@ config NET_SCH_PIE
 config NET_SCH_INGRESS
 	tristate "Ingress Qdisc"
 	depends on NET_CLS_ACT
+	select NET_INGRESS_HOOK
 	---help---
 	  Say Y here if you want to use classifiers for incoming packets.
 	  If unsure, say Y.
diff --git a/net/sched/sch_ingress.c b/net/sched/sch_ingress.c
index a89cc32..38ddef7 100644
--- a/net/sched/sch_ingress.c
+++ b/net/sched/sch_ingress.c
@@ -88,12 +88,44 @@ static int ingress_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 
 /* ------------------------------------------------------------- */
 
+static int ingress_filter(struct sk_buff *skb, struct netdev_queue *rxq)
+{
+	int result = TC_ACT_OK;
+	struct Qdisc *q;
+
+	skb->tc_verd = SET_TC_AT(skb->tc_verd, AT_INGRESS);
+
+	q = rcu_dereference(rxq->qdisc);
+	if (q != &noop_qdisc) {
+		if (likely(!test_bit(__QDISC_STATE_DEACTIVATED, &q->state)))
+			result = qdisc_enqueue_root(skb, q);
+	}
+
+	return result;
+}
+
+static struct sk_buff *qdisc_ingress_hook(struct sk_buff *skb)
+{
+	struct netdev_queue *rxq = rcu_dereference(skb->dev->ingress_queue);
+
+	if (!rxq || rcu_access_pointer(rxq->qdisc) == &noop_qdisc)
+		return skb;
+
+	switch (ingress_filter(skb, rxq)) {
+	case TC_ACT_SHOT:
+	case TC_ACT_STOLEN:
+		kfree_skb(skb);
+		return 0;
+	}
+
+	return skb;
+}
+
 static int ingress_init(struct Qdisc *sch, struct nlattr *opt)
 {
-	net_inc_ingress_queue();
 	sch->flags |= TCQ_F_CPUSTATS;
 
-	return 0;
+	return dev_ingress_hook_register(qdisc_dev(sch), qdisc_ingress_hook);
 }
 
 static void ingress_destroy(struct Qdisc *sch)
@@ -101,7 +133,7 @@ static void ingress_destroy(struct Qdisc *sch)
 	struct ingress_qdisc_data *p = qdisc_priv(sch);
 
 	tcf_destroy_chain(&p->filter_list);
-	net_dec_ingress_queue();
+	dev_ingress_hook_unregister(qdisc_dev(sch));
 }
 
 static int ingress_dump(struct Qdisc *sch, struct sk_buff *skb)
-- 
1.7.10.4
