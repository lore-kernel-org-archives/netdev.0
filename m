From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [RFC PATCH 1/2] net: Add new network device function to allow for
	MMIO batching
Date: Wed, 11 Jul 2012 17:26:03 -0700
Message-ID: <20120712002603.27846.23752.stgit@gitlad.jf.intel.com>
References: <20120712002103.27846.73812.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	edumazet@google.com, bhutchings@solarflare.com,
	therbert@google.com, alexander.duyck@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:50284 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756033Ab2GLAZn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jul 2012 20:25:43 -0400
In-Reply-To: <20120712002103.27846.73812.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change adds capabilities to the driver for batching the MMIO write
involved with transmits.  Most of the logic is based off of the code for
the qdisc scheduling.

What I did is break the transmit path into two parts.  We already had the
ndo_start_xmit function which has been there all along.  The part I added
was ndo_complete_xmit which is meant to handle notifying the hardware that
frames are ready for delivery.

To control all of this I added a net sysfs value for the Tx queues called
dispatch_limit.  When 0 it indicates that all frames will notify hardware
immediately.  When 1 or more the netdev_complete_xmit call will queue up to
that number of packets, and when the value is exceeded it will notify the
hardware and reset the pending frame dispatch count.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---

 include/linux/netdevice.h |   57 ++++++++++++++++++++++++++++++++++++++
 net/core/dev.c            |   67 +++++++++++++++++++++++++++++++++++++++++++++
 net/core/net-sysfs.c      |   36 ++++++++++++++++++++++++
 3 files changed, 160 insertions(+), 0 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 5a1a657..8d50fc4 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -522,6 +522,8 @@ enum netdev_queue_state_t {
 	__QUEUE_STATE_DRV_XOFF,
 	__QUEUE_STATE_STACK_XOFF,
 	__QUEUE_STATE_FROZEN,
+	__QUEUE_STATE_DELAYED,
+	__QUEUE_STATE_DISPATCH,
 #define QUEUE_STATE_ANY_XOFF ((1 << __QUEUE_STATE_DRV_XOFF)		| \
 			      (1 << __QUEUE_STATE_STACK_XOFF))
 #define QUEUE_STATE_ANY_XOFF_OR_FROZEN (QUEUE_STATE_ANY_XOFF		| \
@@ -550,6 +552,7 @@ struct netdev_queue {
 #if defined(CONFIG_XPS) && defined(CONFIG_NUMA)
 	int			numa_node;
 #endif
+	unsigned int		dispatch_limit;
 /*
  * write mostly part
  */
@@ -561,6 +564,11 @@ struct netdev_queue {
 	unsigned long		trans_start;
 
 	/*
+	 * pointer to next Tx queue in dispatch_queue
+	 */
+	struct netdev_queue	*next_dispatch;
+
+	/*
 	 * Number of TX timeouts for this queue
 	 * (/sys/class/net/DEV/Q/trans_timeout)
 	 */
@@ -568,6 +576,8 @@ struct netdev_queue {
 
 	unsigned long		state;
 
+	unsigned int		dispatch_pending;
+
 #ifdef CONFIG_BQL
 	struct dql		dql;
 #endif
@@ -924,6 +934,8 @@ struct net_device_ops {
 	int			(*ndo_stop)(struct net_device *dev);
 	netdev_tx_t		(*ndo_start_xmit) (struct sk_buff *skb,
 						   struct net_device *dev);
+	void			(*ndo_complete_xmit) (struct net_device *dev,
+						      unsigned int queue);
 	u16			(*ndo_select_queue)(struct net_device *dev,
 						    struct sk_buff *skb);
 	void			(*ndo_change_rx_flags)(struct net_device *dev,
@@ -1760,6 +1772,9 @@ struct softnet_data {
 	unsigned int		dropped;
 	struct sk_buff_head	input_pkt_queue;
 	struct napi_struct	backlog;
+
+	struct netdev_queue	*dispatch_queue;
+	struct netdev_queue	**dispatch_queue_tailp;
 };
 
 static inline void input_queue_head_incr(struct softnet_data *sd)
@@ -1779,6 +1794,44 @@ static inline void input_queue_tail_incr_save(struct softnet_data *sd,
 
 DECLARE_PER_CPU_ALIGNED(struct softnet_data, softnet_data);
 
+static inline void netif_tx_delay_queue(struct netdev_queue *txq)
+{
+	set_bit(__QUEUE_STATE_DELAYED, &txq->state);
+}
+
+extern void __netif_tx_dispatch_queue(struct netdev_queue *txq);
+
+static inline void netif_tx_dispatch_queue(struct netdev_queue *txq)
+{
+	if (test_and_clear_bit(__QUEUE_STATE_DELAYED, &txq->state))
+		__netif_tx_dispatch_queue(txq);
+}
+
+static inline bool netif_tx_queue_delayed(const struct netdev_queue *txq)
+{
+	return test_bit(__QUEUE_STATE_DELAYED, &txq->state);
+}
+
+static inline void netdev_complete_xmit(struct netdev_queue *txq)
+{
+	struct net_device *dev = txq->dev;
+	const struct net_device_ops *ops = dev->netdev_ops;
+
+	if (txq->dispatch_pending < txq->dispatch_limit) {
+		if (netif_tx_queue_delayed(txq)) {
+			txq->dispatch_pending++;
+			return;
+		}
+
+		/* start of delayed write sequence */
+		netif_tx_delay_queue(txq);
+	}
+
+	txq->dispatch_pending = 0;
+
+	ops->ndo_complete_xmit(dev, txq - &dev->_tx[0]);
+}
+
 extern void __netif_schedule(struct Qdisc *q);
 
 static inline void netif_schedule_queue(struct netdev_queue *txq)
@@ -1973,6 +2026,7 @@ static inline void netdev_completed_queue(struct net_device *dev,
 
 static inline void netdev_tx_reset_queue(struct netdev_queue *q)
 {
+	clear_bit(__QUEUE_STATE_DELAYED, &q->state);
 #ifdef CONFIG_BQL
 	clear_bit(__QUEUE_STATE_STACK_XOFF, &q->state);
 	dql_reset(&q->dql);
@@ -2482,6 +2536,9 @@ static inline void netif_tx_unlock_bh(struct net_device *dev)
 	}						\
 }
 
+#define HARD_TX_TRYLOCK(dev, txq)			\
+	((dev->features & NETIF_F_LLTX) || __netif_tx_trylock(txq))
+
 static inline void netif_tx_disable(struct net_device *dev)
 {
 	unsigned int i;
diff --git a/net/core/dev.c b/net/core/dev.c
index 93af533..a72669a 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2032,6 +2032,27 @@ int netif_get_num_default_rss_queues(void)
 }
 EXPORT_SYMBOL(netif_get_num_default_rss_queues);
 
+static inline void __netif_tx_redispatch_queue(struct netdev_queue *txq)
+{
+	struct softnet_data *sd;
+	unsigned long flags;
+
+	local_irq_save(flags);
+	sd = &__get_cpu_var(softnet_data);
+	txq->next_dispatch = NULL;
+	sd->dispatch_queue = txq;
+	sd->dispatch_queue_tailp = &txq->next_dispatch;
+	raise_softirq_irqoff(NET_TX_SOFTIRQ);
+	local_irq_restore(flags);
+}
+
+void __netif_tx_dispatch_queue(struct netdev_queue *txq)
+{
+	if (!test_and_set_bit(__QUEUE_STATE_DISPATCH, &txq->state))
+		__netif_tx_redispatch_queue(txq);
+}
+EXPORT_SYMBOL(__netif_tx_dispatch_queue);
+
 static inline void __netif_reschedule(struct Qdisc *q)
 {
 	struct softnet_data *sd;
@@ -3268,6 +3289,41 @@ static void net_tx_action(struct softirq_action *h)
 			}
 		}
 	}
+
+	if (sd->dispatch_queue) {
+		struct netdev_queue *head;
+
+		local_irq_disable();
+		head = sd->dispatch_queue;
+		sd->dispatch_queue = NULL;
+		sd->dispatch_queue_tailp = &sd->dispatch_queue;
+		local_irq_enable();
+
+		while (head) {
+			struct netdev_queue *txq = head;
+			struct net_device *dev = txq->dev;
+			const struct net_device_ops *ops = dev->netdev_ops;
+
+			head = head->next_dispatch;
+
+			if (!HARD_TX_TRYLOCK(dev, txq)) {
+				__netif_tx_redispatch_queue(txq);
+				continue;
+			}
+
+			smp_mb__before_clear_bit();
+			clear_bit(__QUEUE_STATE_DISPATCH, &txq->state);
+
+			if (txq->dispatch_pending &&
+			    !netif_tx_queue_delayed(txq)) {
+				int index = txq - &dev->_tx[0];
+
+				ops->ndo_complete_xmit(dev, index);
+			}
+
+			HARD_TX_UNLOCK(dev, txq);
+		}
+	}
 }
 
 #if (defined(CONFIG_BRIDGE) || defined(CONFIG_BRIDGE_MODULE)) && \
@@ -6485,6 +6541,15 @@ static int dev_cpu_callback(struct notifier_block *nfb,
 		oldsd->output_queue = NULL;
 		oldsd->output_queue_tailp = &oldsd->output_queue;
 	}
+
+	/* Append delayed xmit queue from offline CPU */
+	if (oldsd->dispatch_queue) {
+		*sd->dispatch_queue_tailp = oldsd->dispatch_queue;
+		sd->dispatch_queue_tailp = oldsd->dispatch_queue_tailp;
+		oldsd->dispatch_queue = NULL;
+		oldsd->dispatch_queue_tailp = &oldsd->dispatch_queue;
+	}
+
 	/* Append NAPI poll list from offline CPU. */
 	if (!list_empty(&oldsd->poll_list)) {
 		list_splice_init(&oldsd->poll_list, &sd->poll_list);
@@ -6772,6 +6837,8 @@ static int __init net_dev_init(void)
 		INIT_LIST_HEAD(&sd->poll_list);
 		sd->output_queue = NULL;
 		sd->output_queue_tailp = &sd->output_queue;
+		sd->dispatch_queue = NULL;
+		sd->dispatch_queue_tailp = &sd->dispatch_queue;
 #ifdef CONFIG_RPS
 		sd->csd.func = rps_trigger_softirq;
 		sd->csd.info = sd;
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 42bb496..4f7eb58 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -997,11 +997,47 @@ static struct netdev_queue_attribute xps_cpus_attribute =
     __ATTR(xps_cpus, S_IRUGO | S_IWUSR, show_xps_map, store_xps_map);
 #endif /* CONFIG_XPS */
 
+static ssize_t show_dispatch_limit(struct netdev_queue *queue,
+				   struct netdev_queue_attribute *attribute,
+				   char *buf)
+{
+	unsigned int dispatch_limit;
+
+	spin_lock_irq(&queue->_xmit_lock);
+	dispatch_limit = queue->dispatch_limit;
+	spin_unlock_irq(&queue->_xmit_lock);
+
+	return sprintf(buf, "%u\n", dispatch_limit);
+}
+
+static ssize_t store_dispatch_limit(struct netdev_queue *queue,
+				    struct netdev_queue_attribute *attribute,
+				    const char *buf, size_t len)
+{
+	unsigned int dispatch_limit;
+	int err;
+
+	err = kstrtouint(buf, 10, &dispatch_limit);
+	if (err < 0)
+		return err;
+
+	spin_lock_irq(&queue->_xmit_lock);
+	queue->dispatch_limit = dispatch_limit;
+	spin_unlock_irq(&queue->_xmit_lock);
+
+	return len;
+}
+
+static struct netdev_queue_attribute dispatch_limit_attribute =
+	__ATTR(dispatch_limit, S_IRUGO | S_IWUSR,
+	       show_dispatch_limit, store_dispatch_limit);
+
 static struct attribute *netdev_queue_default_attrs[] = {
 	&queue_trans_timeout.attr,
 #ifdef CONFIG_XPS
 	&xps_cpus_attribute.attr,
 #endif
+	&dispatch_limit_attribute.attr,
 	NULL
 };
 
