From: therbert@google.com (Tom Herbert)
Subject: RFC [PATCH net-2.6 3/6] net: softRSS net changes
Date: Wed,  5 Mar 2008 12:51:16 -0800 (PST)
Message-ID: <20080305205116.5DF6541255B@localhost>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.45.13]:9591 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755013AbYCEUv0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2008 15:51:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for software RSS in the networking layer.

Signed-off-by: Tom Herbert <therbert@google.com>

---

diff -uprN -X /tmp/donts/rss_1 net-2.6/include/linux/netdevice.h net-2.6.patch/include/linux/netdevice.h
--- net-2.6/include/linux/netdevice.h	2008-03-05 09:03:21.742957000 -0800
+++ net-2.6.patch/include/linux/netdevice.h	2008-03-05 09:25:33.526752000 -0800
@@ -308,10 +308,15 @@ struct napi_struct {
 	unsigned long		state;
 	int			weight;
 	int			(*poll)(struct napi_struct *, int);
+#ifdef CONFIG_NET_NAPI_RSS
+	int			last_rx_cpu;
+#endif
+#if defined(CONFIG_NETPOLL) || defined(CONFIG_NET_NAPI_RSS)
+	struct net_device	*dev;
+#endif
 #ifdef CONFIG_NETPOLL
 	spinlock_t		poll_lock;
 	int			poll_owner;
-	struct net_device	*dev;
 	struct list_head	dev_list;
 #endif
 };
@@ -607,6 +612,12 @@ struct net_device
 	/* ingress path synchronizer */
 	spinlock_t		ingress_lock;
 	struct Qdisc		*qdisc_ingress;
+#ifdef CONFIG_NET_SOFTRSS
+	cpumask_t		soft_rss_cpus;
+#endif
+#ifdef CONFIG_NET_NAPI_RSS
+	cpumask_t		napi_rss_cpus;
+#endif
 
 /*
  * Cache line mostly used on queue transmit path (qdisc)
@@ -767,8 +778,10 @@ static inline void netif_napi_add(struct
 	INIT_LIST_HEAD(&napi->poll_list);
 	napi->poll = poll;
 	napi->weight = weight;
-#ifdef CONFIG_NETPOLL
+#if defined(CONFIG_NETPOLL) || defined(CONFIG_NET_NAPI_RSS)
 	napi->dev = dev;
+#endif
+#ifdef CONFIG_NETPOLL
 	list_add(&napi->dev_list, &dev->napi_list);
 	spin_lock_init(&napi->poll_lock);
 	napi->poll_owner = -1;
@@ -888,6 +901,10 @@ struct softnet_data
 	struct net_device	*output_queue;
 	struct sk_buff_head	input_pkt_queue;
 	struct list_head	poll_list;
+#if defined(CONFIG_NET_NAPI_RSS) || defined(CONFIG_NET_SOFTRSS)
+	struct list_head	rss_poll_list;
+	spinlock_t		rss_poll_list_lock;
+#endif
 	struct sk_buff		*completion_queue;
 
 	struct napi_struct	backlog;
@@ -1085,7 +1102,28 @@ extern void dev_kfree_skb_any(struct sk_
 extern int		netif_rx(struct sk_buff *skb);
 extern int		netif_rx_ni(struct sk_buff *skb);
 #define HAVE_NETIF_RECEIVE_SKB 1
-extern int		netif_receive_skb(struct sk_buff *skb);
+extern int		__netif_receive_skb(struct sk_buff *skb);
+
+#ifdef CONFIG_NET_NAPI_RSS
+extern int sysctl_napi_rss;
+#endif
+
+#ifdef CONFIG_NET_SOFTRSS
+extern int sysctl_soft_rss;
+static inline int netif_receive_skb(struct sk_buff *skb)
+{
+	if (sysctl_soft_rss)
+		return (netif_rx(skb));
+	else
+		return (__netif_receive_skb(skb));
+}
+#else
+static inline int netif_receive_skb(struct sk_buff *skb)
+{
+	return (__netif_receive_skb(skb));
+}
+#endif
+
 extern int		dev_valid_name(const char *name);
 extern int		dev_ioctl(struct net *net, unsigned int cmd, void __user *);
 extern int		dev_ethtool(struct net *net, struct ifreq *);
diff -uprN -X /tmp/donts/rss_1 net-2.6/net/Kconfig net-2.6.patch/net/Kconfig
--- net-2.6/net/Kconfig	2008-03-05 09:03:27.571549000 -0800
+++ net-2.6.patch/net/Kconfig	2008-03-05 09:31:03.526132000 -0800
@@ -35,6 +35,38 @@ config NET_NS
 	  Allow user space to create what appear to be multiple instances
 	  of the network stack.
 
+config NET_NAPI_RSS
+	bool "NAPI RSS"
+	help
+	  Say Y here to enable NAPI RSS.  In this mode the execution of the
+	  NAPI poll function for each device is spread across CPUs in a
+	  round robin fashion.  Each time the poll function runs it gets
+	  scheduled on the next CPU in the round robin.
+
+	  A mask of CPUs that can be used is set on a per device basis
+	  in the sysfs variable /sys/class/net/<device>/napi_rss_cpus. This
+	  feature needs to  be enabled at run-time by setting the
+	  net.core.napi_rss sysctl to "1".
+
+config NET_SOFTRSS
+	bool "Software RSS"
+	help
+	  Say Y here to enable a software implementation of receive side
+	  scaling (RSS).  RSS distributes the load of received
+	  packet processing across multiple CPUs.  In this software
+	  implementation of RSS, stack processing for each packet can be
+	  scheduled on a different CPU from that which handles the device
+	  interrupt or NAPI poll.  The scheduling is done by the netif_rx
+	  function which uses a hash over fields in the packet header into
+	  a CPU identifier. For example, in the case of a TCP packet, the
+	  four tuple is hashed to choose a CPU for processing all packets of
+	  that connection.
+
+	  A mask of CPUs that can be used is set on a per device basis
+	  in the sysfs variable /sys/class/net/<device>/soft_rss_cpus. This
+	  feature needs to  be enabled at run-time by setting the
+	  net.core.soft_rss sysctl to "1".
+
 source "net/packet/Kconfig"
 source "net/unix/Kconfig"
 source "net/xfrm/Kconfig"
diff -uprN -X /tmp/donts/rss_1 net-2.6/net/core/dev.c net-2.6.patch/net/core/dev.c
--- net-2.6/net/core/dev.c	2008-03-05 09:03:28.151549000 -0800
+++ net-2.6.patch/net/core/dev.c	2008-03-05 09:25:33.595757000 -0800
@@ -122,6 +122,10 @@
 
 #include "net-sysfs.h"
 
+#ifdef CONFIG_NET_SOFTRSS
+#include <net/ip.h>
+#endif
+
 /*
  *	The list of packet types we will receive (as opposed to discard)
  *	and the routines to invoke.
@@ -254,6 +258,16 @@ static RAW_NOTIFIER_HEAD(netdev_chain);
 
 DEFINE_PER_CPU(struct softnet_data, softnet_data);
 
+#ifdef CONFIG_NET_SOFTRSS
+int sysctl_soft_rss = 0;
+EXPORT_SYMBOL(sysctl_soft_rss);
+#endif
+
+#ifdef CONFIG_NET_NAPI_RSS
+int sysctl_napi_rss = 0;
+EXPORT_SYMBOL(sysctl_napi_rss);
+#endif
+
 #ifdef CONFIG_DEBUG_LOCK_ALLOC
 /*
  * register_netdevice() inits dev->_xmit_lock and sets lockdep class
@@ -1745,6 +1759,96 @@ int weight_p __read_mostly = 64;        
 
 DEFINE_PER_CPU(struct netif_rx_stats, netdev_rx_stat) = { 0, };
 
+#ifdef CONFIG_NET_NAPI_RSS
+static inline int napi_rss_next_cpu(struct napi_struct *n)
+{
+	cpumask_t mask;
+	int cpu;
+
+	if (!n->dev)
+		return get_cpu();
+
+	cpus_and(mask, n->dev->napi_rss_cpus, cpu_online_map);
+
+	if (cpus_empty(mask))
+		cpu = get_cpu();
+	else {
+		cpu = next_cpu(n->last_rx_cpu, mask);
+		if (cpu == NR_CPUS)
+			cpu = first_cpu(mask);
+	}
+	n->last_rx_cpu = cpu;
+	return (cpu);
+}
+#endif /* CONFIG_NET_NAPI_RSS */
+
+#if defined(CONFIG_NET_NAPI_RSS) || defined(CONFIG_NET_SOFTRSS)
+/*
+ * Schedule rx softirq on remote CPU.
+ */
+static inline void __napi_schedule_oncpu(struct napi_struct *n, int cpu)
+{
+	unsigned long flags;
+	struct softnet_data *queue = &per_cpu(softnet_data, cpu);
+
+	spin_lock_irqsave(&queue->rss_poll_list_lock, flags);
+	list_add_tail(&n->poll_list, &queue->rss_poll_list);
+	spin_unlock_irqrestore(&queue->rss_poll_list_lock, flags);
+
+	raise_softirq_oncpu(cpu, NET_RX_SOFTIRQ);
+}
+#endif /* CONFIG_NET_NAPI_RSS  || CONFIG_NET_SOFT_RSS*/
+
+/*
+ * Schedule rx softirq on local CPU.
+ */
+static inline void __napi_schedule_local(struct napi_struct *n)
+{
+	unsigned long flags;
+
+	local_irq_save(flags);
+	list_add_tail(&n->poll_list, &__get_cpu_var(softnet_data).poll_list);
+	__raise_softirq_irqoff(NET_RX_SOFTIRQ);
+	local_irq_restore(flags);
+}
+
+#ifdef CONFIG_NET_SOFTRSS
+static int netif_cpu_for_rss(struct net_device *dev, struct sk_buff *skb)
+{
+	int cpu;
+
+	/*
+	 * Hash the packet header to a CPU.  Code borrowed from bonding
+	 * driver
+	 */
+	if (skb->protocol == __constant_htons(ETH_P_IP)) {
+		struct iphdr *iph = (struct iphdr *)skb->data;
+		u16 *layer4hdr = (u16 *)((u32 *)iph + iph->ihl);
+		cpumask_t mask;
+		int index = 0, count = 0;
+
+		cpus_and(mask, dev->soft_rss_cpus, cpu_online_map);
+		if (cpus_empty(mask))
+			return (get_cpu());
+
+		if (!(iph->frag_off & __constant_htons(IP_MF|IP_OFFSET)) &&
+		    (iph->protocol == IPPROTO_TCP ||
+		     iph->protocol == IPPROTO_UDP)) {
+			index = htons((*layer4hdr ^ *(layer4hdr + 1)));
+		}
+
+		index = index ^ ((ntohl(iph->saddr ^ iph->daddr)) & 0xffff);
+		index %= cpus_weight(mask);
+
+		for_each_cpu_mask(cpu, mask) {
+			if (count++ == index)
+				break;
+		}
+		return (cpu);
+	} else
+		return (get_cpu());
+}
+#endif
 
 /**
  *	netif_rx	-	post buffer to the network code
@@ -1765,6 +1869,9 @@ int netif_rx(struct sk_buff *skb)
 {
 	struct softnet_data *queue;
 	unsigned long flags;
+#ifdef CONFIG_NET_SOFTRSS
+	int cpu;
+#endif
 
 	/* if netpoll wants it, pretend we never saw it */
 	if (netpoll_rx(skb))
@@ -1778,23 +1885,51 @@ int netif_rx(struct sk_buff *skb)
 	 * short when CPU is congested, but is still operating.
 	 */
 	local_irq_save(flags);
-	queue = &__get_cpu_var(softnet_data);
 
 	__get_cpu_var(netdev_rx_stat).total++;
+
+#ifdef CONFIG_NET_SOFTRSS
+	cpu = sysctl_soft_rss ? netif_cpu_for_rss(skb->dev, skb) : get_cpu();
+	queue = &per_cpu(softnet_data, cpu);
+	spin_lock(&queue->input_pkt_queue.lock);
+#else
+	queue = &__get_cpu_var(softnet_data);
+#endif
+
 	if (queue->input_pkt_queue.qlen <= netdev_max_backlog) {
 		if (queue->input_pkt_queue.qlen) {
 enqueue:
 			dev_hold(skb->dev);
 			__skb_queue_tail(&queue->input_pkt_queue, skb);
+#ifdef CONFIG_NET_SOFTRSS
+			spin_unlock(&queue->input_pkt_queue.lock);
+#endif
 			local_irq_restore(flags);
 			return NET_RX_SUCCESS;
 		}
 
+
+#ifdef CONFIG_NET_SOFTRSS
+		/*
+		 * Schedule backlog poll function (possibly on another CPU).
+		 */
+		if (napi_schedule_prep(&queue->backlog)) {
+			if (cpu != get_cpu())
+				__napi_schedule_oncpu(&queue->backlog, cpu);
+			else
+				__napi_schedule_local(&queue->backlog);
+		}
+#else
 		napi_schedule(&queue->backlog);
+#endif
 		goto enqueue;
 	}
 
 	__get_cpu_var(netdev_rx_stat).dropped++;
+
+#ifdef CONFIG_NET_SOFTRSS
+	spin_unlock(&queue->input_pkt_queue.lock);
+#endif
 	local_irq_restore(flags);
 
 	kfree_skb(skb);
@@ -2005,7 +2140,7 @@ out:
 #endif
 
 /**
- *	netif_receive_skb - process receive buffer from network
+ *	__netif_receive_skb - process receive buffer from network
  *	@skb: buffer to process
  *
  *	netif_receive_skb() is the main receive data processing function.
@@ -2019,7 +2154,7 @@ out:
  *	NET_RX_SUCCESS: no congestion
  *	NET_RX_DROP: packet was dropped
  */
-int netif_receive_skb(struct sk_buff *skb)
+int __netif_receive_skb(struct sk_buff *skb)
 {
 	struct packet_type *ptype, *pt_prev;
 	struct net_device *orig_dev;
@@ -2118,13 +2253,22 @@ static int process_backlog(struct napi_s
 		struct net_device *dev;
 
 		local_irq_disable();
+#ifdef CONFIG_NET_SOFTRSS
+		spin_lock(&queue->input_pkt_queue.lock);
+#endif
 		skb = __skb_dequeue(&queue->input_pkt_queue);
 		if (!skb) {
 			__napi_complete(napi);
+#ifdef CONFIG_NET_SOFTRSS
+			spin_unlock(&queue->input_pkt_queue.lock);
+#endif
 			local_irq_enable();
 			break;
 		}
 
+#ifdef CONFIG_NET_SOFTRSS
+		spin_unlock(&queue->input_pkt_queue.lock);
+#endif
 		local_irq_enable();
 
 		dev = skb->dev;
@@ -2145,25 +2289,38 @@ static int process_backlog(struct napi_s
  */
 void __napi_schedule(struct napi_struct *n)
 {
-	unsigned long flags;
-
-	local_irq_save(flags);
-	list_add_tail(&n->poll_list, &__get_cpu_var(softnet_data).poll_list);
-	__raise_softirq_irqoff(NET_RX_SOFTIRQ);
-	local_irq_restore(flags);
+#ifdef CONFIG_NET_NAPI_RSS
+	if (sysctl_napi_rss) {
+		int cpu = napi_rss_next_cpu(n);
+		if (cpu != get_cpu()) {
+			__napi_schedule_oncpu(n, cpu);
+			return;
+		}
+	}
+#endif
+	__napi_schedule_local(n);
 }
 EXPORT_SYMBOL(__napi_schedule);
 
 
 static void net_rx_action(struct softirq_action *h)
 {
-	struct list_head *list = &__get_cpu_var(softnet_data).poll_list;
+	struct softnet_data *queue = &__get_cpu_var(softnet_data);
+	struct list_head *list = &queue->poll_list;
 	unsigned long start_time = jiffies;
 	int budget = netdev_budget;
 	void *have;
 
 	local_irq_disable();
 
+#if defined(CONFIG_NET_NAPI_RSS) || defined(CONFIG_NET_SOFTRSS)
+	if (!list_empty(&queue->rss_poll_list)) {
+		spin_lock(&queue->rss_poll_list_lock);
+		list_splice_init(&queue->rss_poll_list, queue->poll_list.prev);
+		spin_unlock(&queue->rss_poll_list_lock);
+	}
+#endif
+
 	while (!list_empty(list)) {
 		struct napi_struct *n;
 		int work, weight;
@@ -2215,8 +2372,23 @@ static void net_rx_action(struct softirq
 		if (unlikely(work == weight)) {
 			if (unlikely(napi_disable_pending(n)))
 				__napi_complete(n);
-			else
+			else {
+#ifdef CONFIG_NET_NAPI_RSS
+				int cpu;
+				if (sysctl_napi_rss)
+					cpu = napi_rss_next_cpu(n);
+				else
+					cpu = get_cpu();
+
+				if (cpu != get_cpu()) {
+					list_del(&n->poll_list);
+					__napi_schedule_oncpu(n, cpu);
+				} else
+					list_move_tail(&n->poll_list, list);
+#else
 				list_move_tail(&n->poll_list, list);
+#endif
+			}
 		}
 
 		netpoll_poll_unlock(have);
@@ -4527,6 +4699,10 @@ static int __init net_dev_init(void)
 		skb_queue_head_init(&queue->input_pkt_queue);
 		queue->completion_queue = NULL;
 		INIT_LIST_HEAD(&queue->poll_list);
+#if defined(CONFIG_NET_NAPI_RSS) || defined(CONFIG_NET_SOFTRSS)
+		INIT_LIST_HEAD(&queue->rss_poll_list);
+		spin_lock_init(&queue->rss_poll_list_lock);
+#endif
 
 		queue->backlog.poll = process_backlog;
 		queue->backlog.weight = weight_p;
@@ -4571,7 +4747,7 @@ EXPORT_SYMBOL(free_netdev);
 EXPORT_SYMBOL(netdev_boot_setup_check);
 EXPORT_SYMBOL(netdev_set_master);
 EXPORT_SYMBOL(netdev_state_change);
-EXPORT_SYMBOL(netif_receive_skb);
+EXPORT_SYMBOL(__netif_receive_skb);
 EXPORT_SYMBOL(netif_rx);
 EXPORT_SYMBOL(register_gifconf);
 EXPORT_SYMBOL(register_netdevice);
