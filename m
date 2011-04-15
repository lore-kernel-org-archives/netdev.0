From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH 2/3] net: Add net device irq siloing feature
Date: Fri, 15 Apr 2011 16:17:56 -0400
Message-ID: <1302898677-3833-3-git-send-email-nhorman@tuxdriver.com>
References: <1302898677-3833-1-git-send-email-nhorman@tuxdriver.com>
Cc: davem@davemloft.net, Neil Horman <nhorman@tuxdriver.com>,
	Dimitris Michailidis <dm@chelsio.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	David Howells <dhowells@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:51333 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753200Ab1DOUTK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2011 16:19:10 -0400
In-Reply-To: <1302898677-3833-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using the irq affinity infrastrucuture, we can now allow net devices to call
request_irq using a new wrapper function (request_net_irq), which will attach a
common affinty_update handler to each requested irq.  This affinty update
mechanism correlates each tracked irq to the flow(s) that said irq processes
most frequently.  The highest traffic flow is noted, marked and exported to user
space via the affinity_hint proc file for each irq. In this way, utilities like
irqbalance are able to determine  which cpu is recieving the most data from each
rx queue on a given NIC, and set irq affinity accordingly.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

CC: Dimitris Michailidis <dm@chelsio.com>
CC: "David S. Miller" <davem@davemloft.net>
CC: Thomas Gleixner <tglx@linutronix.de>
CC: David Howells <dhowells@redhat.com>
CC: Eric Dumazet <eric.dumazet@gmail.com>
CC: Tom Herbert <therbert@google.com>
---
 include/linux/netdevice.h  |   18 +++++++
 kernel/irq/proc.c          |    2 +-
 net/Kconfig                |   12 +++++
 net/core/dev.c             |  107 ++++++++++++++++++++++++++++++++++++++++++++
 net/core/sysctl_net_core.c |    9 ++++
 5 files changed, 147 insertions(+), 1 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 5eeb2cd..ba6191f 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -609,6 +609,9 @@ struct rps_map {
 struct rps_dev_flow {
 	u16 cpu;
 	u16 filter;
+#ifdef CONFIG_RFS_SILOING
+	u32 weight;
+#endif
 	unsigned int last_qtail;
 };
 #define RPS_NO_FILTER 0xffff
@@ -1631,6 +1634,21 @@ static inline void unregister_netdevice(struct net_device *dev)
 	unregister_netdevice_queue(dev, NULL);
 }
 
+#ifdef CONFIG_RFS_SILOING
+extern int netdev_rxq_silo_init(int irq, struct affin_data *afd, void *priv);
+extern int sysctl_irq_siloing_period;
+
+static inline int __must_check
+request_net_irq(unsigned int irq, irq_handler_t handler, unsigned long flags,
+		const char *name, void *dev, struct net_device *ndev, int rxq)
+{
+	return request_affinity_irq(irq, handler, NULL, flags, name, dev,
+				    netdev_rxq_silo_init, &ndev->_rx[rxq]);
+}
+#else
+#define request_net_irq(i, h, f, n, d, nd, r) request_irq(i, h, NULL, f, n, d)
+#endif
+
 extern int 		netdev_refcnt_read(const struct net_device *dev);
 extern void		free_netdev(struct net_device *dev);
 extern void		synchronize_net(void);
diff --git a/kernel/irq/proc.c b/kernel/irq/proc.c
index 8fecb05..d5a7e4d 100644
--- a/kernel/irq/proc.c
+++ b/kernel/irq/proc.c
@@ -65,7 +65,7 @@ static int irq_affinity_alg_proc_show(struct seq_file *m, void *v)
 #ifdef CONFIG_AFFINITY_UPDATE
 	struct irq_desc *desc = irq_to_desc((long)m->private);
 
-	if (desc->af_data->affinity_alg)
+	if (desc->af_data && desc->af_data->affinity_alg)
 		alg = desc->af_data->affinity_alg;
 #endif
 	seq_printf(m, "%s\n", alg);
diff --git a/net/Kconfig b/net/Kconfig
index 79cabf1..d6ef6f5 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -232,6 +232,18 @@ config XPS
 	depends on SMP && SYSFS && USE_GENERIC_SMP_HELPERS
 	default y
 
+config RFS_SILOING
+	boolean
+	depends on RFS_ACCEL && AFFINITY_UPDATE
+	default y
+	---help---
+	 This feature allows appropriately enabled network drivers to
+	 export affinity_hint data to user space based on the RFS flow hash
+	 table for the rx queue associated with a given interrupt.  This allows
+	 userspace to optimize irq affinity such that a given rx queue has its
+	 interrupt serviced on the same cpu/l2 cache/numa node running the process
+	 that consumes most of its data.
+
 menu "Network testing"
 
 config NET_PKTGEN
diff --git a/net/core/dev.c b/net/core/dev.c
index 0b88eba..4d86137 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -173,6 +173,9 @@
 #define PTYPE_HASH_SIZE	(16)
 #define PTYPE_HASH_MASK	(PTYPE_HASH_SIZE - 1)
 
+#ifdef CONFIG_RFS_SILOING
+int sysctl_irq_siloing_period;
+#endif
 static DEFINE_SPINLOCK(ptype_lock);
 static struct list_head ptype_base[PTYPE_HASH_SIZE] __read_mostly;
 static struct list_head ptype_all __read_mostly;	/* Taps */
@@ -2640,6 +2643,9 @@ set_rps_cpu(struct net_device *dev, struct sk_buff *skb,
 		rflow->filter = rc;
 		if (old_rflow->filter == rflow->filter)
 			old_rflow->filter = RPS_NO_FILTER;
+#ifdef CONFIG_RFS_SILOING
+		old_rflow->weight = rflow->weight = 0;
+#endif
 	out:
 #endif
 		rflow->last_qtail =
@@ -2723,6 +2729,10 @@ static int get_rps_cpu(struct net_device *dev, struct sk_buff *skb,
 		      rflow->last_qtail)) >= 0))
 			rflow = set_rps_cpu(dev, skb, rflow, next_cpu);
 
+#ifdef CONFIG_RFS_SILOING
+		rflow->weight += skb->len;
+#endif
+
 		if (tcpu != RPS_NO_CPU && cpu_online(tcpu)) {
 			*rflowp = rflow;
 			cpu = tcpu;
@@ -6224,6 +6234,103 @@ static struct hlist_head *netdev_create_hash(void)
 	return hash;
 }
 
+#ifdef CONFIG_RFS_SILOING
+struct netdev_rxq_affin_data {
+	struct netdev_rx_queue *q;
+	unsigned long last_update;
+	cpumask_var_t affinity_mask;
+};
+
+static void netdev_rxq_silo_affin_update(int irq, struct affin_data *afd)
+{
+	struct netdev_rxq_affin_data *afdp = afd->priv;
+	struct netdev_rx_queue *q = afdp->q;
+	struct rps_dev_flow_table *flow_table;
+	int i;
+	u16 tcpu;
+	u32 mw;
+	unsigned long next_update;
+
+	mw = tcpu = 0;
+
+	next_update = afdp->last_update + (sysctl_irq_siloing_period * HZ);
+
+	if (time_after(next_update, jiffies))
+		return;
+
+	afdp->last_update = jiffies;
+
+	irq_set_affinity_hint(irq, NULL);
+	cpumask_clear(afdp->affinity_mask);
+	rcu_read_lock();
+	flow_table = rcu_dereference(q->rps_flow_table);
+
+	if (!flow_table)
+		goto out;
+
+	for (i = 0; (i & flow_table->mask) == i; i++) {
+		if (mw < flow_table->flows[i].weight) {
+			tcpu = ACCESS_ONCE(flow_table->flows[i].cpu);
+			if (tcpu == RPS_NO_CPU)
+				continue;
+			mw = flow_table->flows[i].weight;
+		}
+	}
+
+
+	if (mw) {
+		cpumask_set_cpu(tcpu, afdp->affinity_mask);
+		irq_set_affinity_hint(irq, afdp->affinity_mask);
+	}
+out:
+	rcu_read_unlock();
+	return;
+}
+
+static void netdev_rxq_silo_cleanup(int irq, struct affin_data *afd)
+{
+	struct netdev_rxq_affin_data *afdp = afd->priv;
+
+	free_cpumask_var(afdp->affinity_mask);
+	kfree(afdp);
+	afd->priv = NULL;
+}
+
+/**
+ *	netdev_rxq_silo_init - setup an irq to be siloed
+ *
+ *	initalizes the irq data required to allow the networking
+ *	subsystem to determine which cpu is best suited to
+ *      service the passed in irq, and then export that data
+ *	via the affinity_hint proc interface
+ */
+int netdev_rxq_silo_init(int irq, struct affin_data *afd, void *priv)
+{
+	struct netdev_rxq_affin_data *afdp;
+
+	afd->priv = afdp = kzalloc(sizeof(struct netdev_rxq_affin_data),
+				   GFP_KERNEL);
+	if (!afdp)
+		return -ENOMEM;
+
+	if (!alloc_cpumask_var(&afdp->affinity_mask, GFP_KERNEL)) {
+		kfree(afdp);
+		return -ENOMEM;
+	}
+
+	cpumask_clear(afdp->affinity_mask);
+
+	afdp->q = priv;
+	afdp->last_update = jiffies;
+	afd->affin_update = netdev_rxq_silo_affin_update;
+	afd->affin_cleanup = netdev_rxq_silo_cleanup;
+	afd->affinity_alg = "net:rfs max weight";
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(netdev_rxq_silo_init);
+#endif
+
 /* Initialize per network namespace state */
 static int __net_init netdev_init(struct net *net)
 {
diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
index 385b609..b5c733e 100644
--- a/net/core/sysctl_net_core.c
+++ b/net/core/sysctl_net_core.c
@@ -158,6 +158,15 @@ static struct ctl_table net_core_table[] = {
 		.proc_handler	= rps_sock_flow_sysctl
 	},
 #endif
+#ifdef CONFIG_RFS_SILOING
+	{
+		.procname	= "irq_siloing_period",
+		.data		= &sysctl_irq_siloing_period,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
+#endif
 #endif /* CONFIG_NET */
 	{
 		.procname	= "netdev_budget",
-- 
1.7.4.2

