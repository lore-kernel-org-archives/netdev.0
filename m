From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 3/5] net: RPS: Enable hardware acceleration of
 RFS
Date: Wed, 19 Jan 2011 21:03:53 +0000
Message-ID: <1295471033.11126.87.camel@bwh-desktop>
References: <1295470787.11126.82.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	Tom Herbert <therbert@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:15265 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754751Ab1ASVD4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jan 2011 16:03:56 -0500
In-Reply-To: <1295470787.11126.82.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow drivers for multiqueue hardware with flow filter tables to
accelerate RFS.  The driver must:

1. Set net_device::rx_cpu_rmap to a cpu_rmap of the RX completion
IRQs (in queue order).  This will provide a mapping from CPUs to the
queues for which completions are handled nearest to them.

2. Implement net_device_ops::ndo_rx_flow_steer.  This operation adds
or replaces a filter steering the given flow to the given RX queue, if
possible.

3. Periodically remove filters for which rps_may_expire_flow() returns
true.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 include/linux/netdevice.h |   33 ++++++++++++++-
 net/Kconfig               |    6 +++
 net/core/dev.c            |   97 ++++++++++++++++++++++++++++++++++++++++++---
 3 files changed, 127 insertions(+), 9 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index d971346..abe8b2d 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -551,14 +551,16 @@ struct rps_map {
 #define RPS_MAP_SIZE(_num) (sizeof(struct rps_map) + (_num * sizeof(u16)))
 
 /*
- * The rps_dev_flow structure contains the mapping of a flow to a CPU and the
- * tail pointer for that CPU's input queue at the time of last enqueue.
+ * The rps_dev_flow structure contains the mapping of a flow to a CPU, the
+ * tail pointer for that CPU's input queue at the time of last enqueue, and
+ * a hardware filter index.
  */
 struct rps_dev_flow {
 	u16 cpu;
-	u16 fill;
+	u16 filter;
 	unsigned int last_qtail;
 };
+#define RPS_NO_FILTER 0xffff
 
 /*
  * The rps_dev_flow_table structure contains a table of flow mappings.
@@ -608,6 +610,11 @@ static inline void rps_reset_sock_flow(struct rps_sock_flow_table *table,
 
 extern struct rps_sock_flow_table __rcu *rps_sock_flow_table;
 
+#ifdef CONFIG_RFS_ACCEL
+extern bool rps_may_expire_flow(struct net_device *dev, u16 rxq_index,
+				u32 flow_id, u16 filter_id);
+#endif
+
 /* This structure contains an instance of an RX queue. */
 struct netdev_rx_queue {
 	struct rps_map __rcu		*rps_map;
@@ -753,6 +760,13 @@ struct xps_dev_maps {
  * int (*ndo_set_vf_port)(struct net_device *dev, int vf,
  *			  struct nlattr *port[]);
  * int (*ndo_get_vf_port)(struct net_device *dev, int vf, struct sk_buff *skb);
+ *
+ *	RFS acceleration.
+ * int (*ndo_rx_flow_steer)(struct net_device *dev, const struct sk_buff *skb,
+ *			    u16 rxq_index, u32 flow_id);
+ *	Set hardware filter for RFS.  rxq_index is the target queue index;
+ *	flow_id is a flow ID to be passed to rps_may_expire_flow() later.
+ *	Return the filter ID on success, or a negative error code.
  */
 #define HAVE_NET_DEVICE_OPS
 struct net_device_ops {
@@ -825,6 +839,12 @@ struct net_device_ops {
 	int			(*ndo_fcoe_get_wwn)(struct net_device *dev,
 						    u64 *wwn, int type);
 #endif
+#ifdef CONFIG_RFS_ACCEL
+	int			(*ndo_rx_flow_steer)(struct net_device *dev,
+						     const struct sk_buff *skb,
+						     u16 rxq_index,
+						     u32 flow_id);
+#endif
 };
 
 /*
@@ -1039,6 +1059,13 @@ struct net_device {
 
 	/* Number of RX queues currently active in device */
 	unsigned int		real_num_rx_queues;
+
+#ifdef CONFIG_RFS_ACCEL
+	/* CPU reverse-mapping for RX completion interrupts, indexed
+	 * by RX queue number.  Assigned by driver.  This must only be
+	 * set if the ndo_rx_flow_steer operation is defined. */
+	struct cpu_rmap		*rx_cpu_rmap;
+#endif
 #endif
 
 	rx_handler_func_t __rcu	*rx_handler;
diff --git a/net/Kconfig b/net/Kconfig
index 7284062..79cabf1 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -221,6 +221,12 @@ config RPS
 	depends on SMP && SYSFS && USE_GENERIC_SMP_HELPERS
 	default y
 
+config RFS_ACCEL
+	boolean
+	depends on RPS && GENERIC_HARDIRQS
+	select CPU_RMAP
+	default y
+
 config XPS
 	boolean
 	depends on SMP && SYSFS && USE_GENERIC_SMP_HELPERS
diff --git a/net/core/dev.c b/net/core/dev.c
index 7741507..3c18d9c 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -132,6 +132,7 @@
 #include <trace/events/skb.h>
 #include <linux/pci.h>
 #include <linux/inetdevice.h>
+#include <linux/cpu_rmap.h>
 
 #include "net-sysfs.h"
 
@@ -2532,6 +2533,53 @@ EXPORT_SYMBOL(__skb_get_rxhash);
 struct rps_sock_flow_table __rcu *rps_sock_flow_table __read_mostly;
 EXPORT_SYMBOL(rps_sock_flow_table);
 
+static struct rps_dev_flow *
+set_rps_cpu(struct net_device *dev, struct sk_buff *skb,
+	    struct rps_dev_flow *rflow, u16 next_cpu)
+{
+	u16 tcpu;
+
+	tcpu = rflow->cpu = next_cpu;
+	if (tcpu != RPS_NO_CPU) {
+#ifdef CONFIG_RFS_ACCEL
+		struct netdev_rx_queue *rxqueue;
+		struct rps_dev_flow_table *flow_table;
+		struct rps_dev_flow *old_rflow;
+		u32 flow_id;
+		u16 rxq_index;
+		int rc;
+
+		/* Should we steer this flow to a different hardware queue? */
+		if (!skb_rx_queue_recorded(skb) || !dev->rx_cpu_rmap)
+			goto out;
+		rxq_index = cpu_rmap_lookup_index(dev->rx_cpu_rmap, next_cpu);
+		if (rxq_index == skb_get_rx_queue(skb))
+			goto out;
+
+		rxqueue = dev->_rx + rxq_index;
+		flow_table = rcu_dereference(rxqueue->rps_flow_table);
+		if (!flow_table)
+			goto out;
+		flow_id = skb->rxhash & flow_table->mask;
+		rc = dev->netdev_ops->ndo_rx_flow_steer(dev, skb,
+							rxq_index, flow_id);
+		if (rc < 0)
+			goto out;
+		old_rflow = rflow;
+		rflow = &flow_table->flows[flow_id];
+		rflow->cpu = next_cpu;
+		rflow->filter = rc;
+		if (old_rflow->filter == rflow->filter)
+			old_rflow->filter = RPS_NO_FILTER;
+	out:
+#endif
+		rflow->last_qtail =
+			per_cpu(softnet_data, tcpu).input_queue_head;
+	}
+
+	return rflow;
+}
+
 /*
  * get_rps_cpu is called from netif_receive_skb and returns the target
  * CPU from the RPS map of the receiving queue for a given skb.
@@ -2602,12 +2650,9 @@ static int get_rps_cpu(struct net_device *dev, struct sk_buff *skb,
 		if (unlikely(tcpu != next_cpu) &&
 		    (tcpu == RPS_NO_CPU || !cpu_online(tcpu) ||
 		     ((int)(per_cpu(softnet_data, tcpu).input_queue_head -
-		      rflow->last_qtail)) >= 0)) {
-			tcpu = rflow->cpu = next_cpu;
-			if (tcpu != RPS_NO_CPU)
-				rflow->last_qtail = per_cpu(softnet_data,
-				    tcpu).input_queue_head;
-		}
+		      rflow->last_qtail)) >= 0))
+			rflow = set_rps_cpu(dev, skb, rflow, next_cpu);
+
 		if (tcpu != RPS_NO_CPU && cpu_online(tcpu)) {
 			*rflowp = rflow;
 			cpu = tcpu;
@@ -2628,6 +2673,46 @@ done:
 	return cpu;
 }
 
+#ifdef CONFIG_RFS_ACCEL
+
+/**
+ * rps_may_expire_flow - check whether an RFS hardware filter may be removed
+ * @dev: Device on which the filter was set
+ * @rxq_index: RX queue index
+ * @flow_id: Flow ID passed to ndo_rx_flow_steer()
+ * @filter_id: Filter ID returned by ndo_rx_flow_steer()
+ *
+ * Drivers that implement ndo_rx_flow_steer() should periodically call
+ * this function for each installed filter and remove the filters for
+ * which it returns %true.
+ */
+bool rps_may_expire_flow(struct net_device *dev, u16 rxq_index,
+			 u32 flow_id, u16 filter_id)
+{
+	struct netdev_rx_queue *rxqueue = dev->_rx + rxq_index;
+	struct rps_dev_flow_table *flow_table;
+	struct rps_dev_flow *rflow;
+	bool expire = true;
+	int cpu;
+
+	rcu_read_lock();
+	flow_table = rcu_dereference(rxqueue->rps_flow_table);
+	if (flow_table && flow_id <= flow_table->mask) {
+		rflow = &flow_table->flows[flow_id];
+		cpu = ACCESS_ONCE(rflow->cpu);
+		if (rflow->filter == filter_id && cpu != RPS_NO_CPU &&
+		    ((int)(per_cpu(softnet_data, cpu).input_queue_head -
+			   rflow->last_qtail) <
+		     (int)(10 * flow_table->mask)))
+			expire = false;
+	}
+	rcu_read_unlock();
+	return expire;
+}
+EXPORT_SYMBOL(rps_may_expire_flow);
+
+#endif /* CONFIG_RFS_ACCEL */
+
 /* Called from hardirq (IPI) context */
 static void rps_trigger_softirq(void *data)
 {
-- 
1.7.3.4



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

