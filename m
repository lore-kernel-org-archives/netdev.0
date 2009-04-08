From: Tom Herbert <therbert@google.com>
Subject: [PATCH] Software receive packet steering
Date: Wed, 8 Apr 2009 15:48:12 -0700
Message-ID: <65634d660904081548g7ea3e3bfn858f2336db9a671f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:2779 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752177AbZDHWsS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2009 18:48:18 -0400
Received: from zps38.corp.google.com (zps38.corp.google.com [172.25.146.38])
	by smtp-out.google.com with ESMTP id n38MmEHG001582
	for <netdev@vger.kernel.org>; Wed, 8 Apr 2009 23:48:15 +0100
Received: from qw-out-1920.google.com (qwf5.prod.google.com [10.241.194.69])
	by zps38.corp.google.com with ESMTP id n38MmCXm016372
	for <netdev@vger.kernel.org>; Wed, 8 Apr 2009 15:48:13 -0700
Received: by qw-out-1920.google.com with SMTP id 5so324388qwf.30
        for <netdev@vger.kernel.org>; Wed, 08 Apr 2009 15:48:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch implements software receive side packet steering (RPS).  RPS
distributes the load of received packet processing across multiple CPUs.

Problem statement: Protocol processing done in the NAPI context for received
packets is serialized per device queue and becomes a bottleneck under high
packet load.  This substantially limits pps that can be achieved on a single
queue NIC and provides no scaling with multiple cores.

This solution queues packets early on in the receive path on the backlog queues
of other CPUs.   This allows protocol processing (e.g. IP and TCP) to be
performed on packets in parallel.   For each device a mask of CPUs is set
to indicate the CPUs that can process packets for the device. A CPU is selected
on a per packet basis by hashing contents of the packet header (the TCP or UDP
4-tuple) and using the result to index into the CPU mask.  The IPI mechanism
is used to raise networking receive softirqs between CPUs.  This effectively
emulates in software what a multi-queue NIC can provide, but is generic
requiring no device support.

The CPU mask is set on a per device basis in the sysfs variable
/sys/class/net/<device>/soft_rps_cpus.  This is a canonical bit map.

Generally, we have found this technique increases pps capabilities of a single
queue device with good CPU utilization.  Optimal settings for the CPU mask
seems to depend on architectures and cache hierarchy.  Below are some results
running 700 instances of netperf TCP_RR test with 1 byte req. and resp.
Results show cumulative transaction rate and system CPU utilization.

tg3 on 8 core Intel
   Without RPS: 90K tps at 34% CPU
   With RPS:    285K tps at 70% CPU

e1000 on 8 core Intel
   Without RPS: 90K tps at 34% CPU
   With RPS:    292K tps at 66% CPU

foredeth on 16 core AMD
   Without RPS: 117K tps at 10% CPU
   With RPS:    327K tps at 29% CPU

bnx2x on 16 core AMD
   Single queue without RPS:        139K tps at 17% CPU
   Single queue with RPS:           352K tps at 30% CPU
   Multi queue (1 queues per CPU)   204K tps at 12% CPU

We have been running a variant of this patch on production servers for a while
with good results.  In some of our more networking intensive applications we
have seen 30-50% gains in end application performance.

Tom

Signed-off-by: Tom Herbert <therbert@google.com>
---

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index be3ebd7..ca52116 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -758,6 +758,9 @@ struct net_device
 	void			*ax25_ptr;	/* AX.25 specific data */
 	struct wireless_dev	*ieee80211_ptr;	/* IEEE 802.11 specific data,
 						   assign before registering */
+#ifdef CONFIG_NET_SOFTRPS
+	cpumask_t		soft_rps_cpus;	/* CPU Mask for RX processing */
+#endif

 /*
  * Cache line mostly used on receive path (including eth_type_trans())
@@ -1170,6 +1173,15 @@ struct softnet_data
 	struct Qdisc		*output_queue;
 	struct sk_buff_head	input_pkt_queue;
 	struct list_head	poll_list;
+#ifdef CONFIG_NET_SOFTRPS
+	int			rps_cpu;
+	struct list_head	rps_poll_list;
+	spinlock_t		rps_poll_list_lock;
+	struct call_single_data	rps_csd;
+	unsigned long		rps_flags;
+#define RPS_SOFTIRQ_PENDING	0x1
+#define RPS_SOFTIRQ_COMPLETING	0x2
+#endif
 	struct sk_buff		*completion_queue;

 	struct napi_struct	backlog;
@@ -1177,6 +1189,32 @@ struct softnet_data

 DECLARE_PER_CPU(struct softnet_data,softnet_data);

+static inline void lock_softnet_input_queue(struct softnet_data *queue,
+    unsigned long *flags)
+{
+	local_irq_save(*flags);
+#ifdef CONFIG_NET_SOFTRPS
+	spin_lock(&queue->input_pkt_queue.lock);
+#endif
+}
+
+static inline void lock_softnet_input_queue_noflags(struct softnet_data *queue)
+{
+#ifdef CONFIG_NET_SOFTRPS
+	spin_lock(&queue->input_pkt_queue.lock);
+#endif
+}
+
+static inline void unlock_softnet_input_queue(struct softnet_data *queue,
+    unsigned long *flags)
+{
+#ifdef CONFIG_NET_SOFTRPS
+	spin_unlock(&queue->input_pkt_queue.lock);
+#endif
+	local_irq_restore(*flags);
+}
+
+
 #define HAVE_NETIF_QUEUE

 extern void __netif_schedule(struct Qdisc *q);
@@ -1416,7 +1454,17 @@ extern void dev_kfree_skb_any(struct sk_buff *skb);
 extern int		netif_rx(struct sk_buff *skb);
 extern int		netif_rx_ni(struct sk_buff *skb);
 #define HAVE_NETIF_RECEIVE_SKB 1
-extern int		netif_receive_skb(struct sk_buff *skb);
+extern int            __netif_receive_skb(struct sk_buff *skb);
+
+static inline int netif_receive_skb(struct sk_buff *skb)
+{
+#ifdef CONFIG_NET_SOFTRPS
+	return netif_rx(skb);
+#else
+	return __netif_receive_skb(skb);
+#endif
+}
+
 extern void		napi_gro_flush(struct napi_struct *napi);
 extern int		dev_gro_receive(struct napi_struct *napi,
 					struct sk_buff *skb);
diff --git a/net/Kconfig b/net/Kconfig
index ec93e7e..75bdda0 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -25,6 +25,19 @@ if NET

 menu "Networking options"

+config NET_SOFTRPS
+	bool "Software RX packet steering"
+	depends on SMP
+	help
+	  Say Y here to enable a software implementation of receive path
+	  packet steering (RPS).  RPS distributes the load of received
+	  packet processing across multiple CPUs.  Packets are scheduled
+	  to different CPUs for protocol processing in the netif_rx function.
+	  A hash is performed on fields in packet headers (the four tuple
+	  in the case of TCP), this resulting value is used to index into a
+	  mask of CPUs.  The CPU masks are set on a per device basis
+	  in the sysfs variable /sys/class/net/<device>/soft_rps_cpus.
+
 source "net/packet/Kconfig"
 source "net/unix/Kconfig"
 source "net/xfrm/Kconfig"
diff --git a/net/core/dev.c b/net/core/dev.c
index 052dd47..df0507b 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1906,6 +1906,140 @@ int weight_p __read_mostly = 64;            /*
old backlog weight */

 DEFINE_PER_CPU(struct netif_rx_stats, netdev_rx_stat) = { 0, };

+#ifdef CONFIG_NET_SOFTRPS
+/**
+ *	netif_cpu_for_rps - return the appropriate CPU for protocol
+ *	processing of a packet when doing receive packet steering.
+ *	@dev: receiving device
+ *	@skb: buffer with packet
+ *
+ *	Fields in packet headers are hashed to be used as an index into a
+ *	per device CPU mask (IP packets).  For TCP and UDP packets
+ *	a simple hash is done on the 4-tuple, for other IP packets a hash
+ *	is done on the source and destination addresses.
+ *
+ *	Called with irq's disabled.
+ */
+static int netif_cpu_for_rps(struct net_device *dev, struct sk_buff *skb)
+{
+	cpumask_t mask;
+	unsigned int hash;
+	int cpu, count = 0;
+
+	cpus_and(mask, dev->soft_rps_cpus, cpu_online_map);
+	if (cpus_empty(mask))
+		return smp_processor_id();
+
+	if (skb->protocol == __constant_htons(ETH_P_IP)) {
+		struct iphdr *iph = (struct iphdr *)skb->data;
+		__be16 *layer4hdr = (__be16 *)((u32 *)iph + iph->ihl);
+
+		hash = 0;
+		if (!(iph->frag_off &
+		      __constant_htons(IP_MF|IP_OFFSET)) &&
+		    ((iph->protocol == IPPROTO_TCP) ||
+		     (iph->protocol == IPPROTO_UDP)))
+			hash = ntohs(*layer4hdr ^ *(layer4hdr + 1));
+
+		hash ^= (ntohl(iph->saddr ^ iph->daddr)) & 0xffff;
+		goto got_hash;
+	}
+
+	return smp_processor_id();
+
+got_hash:
+	hash %= cpus_weight_nr(mask);
+
+	for_each_cpu_mask(cpu, mask) {
+		if (count++ == hash)
+			break;
+	}
+	return cpu;
+}
+
+static DEFINE_PER_CPU(cpumask_t, rps_remote_softirq_cpus);
+
+/* Called from hardirq (IPI) context */
+static void trigger_softirq(void *data)
+{
+	struct softnet_data *queue = data;
+	set_bit(RPS_SOFTIRQ_COMPLETING, &queue->rps_flags);
+	raise_softirq(NET_RX_SOFTIRQ);
+}
+
+/**
+ * net_rx_action_rps is called from net_rx_action to do the softirq
+ * functions related to receive packet steering.
+ *
+ * Called with irq's disable.
+ */
+static void net_rx_action_rps(struct softnet_data *queue)
+{
+	int cpu;
+
+	/* Finish remote softirq invocation for this CPU. */
+	if (test_bit(RPS_SOFTIRQ_COMPLETING, &queue->rps_flags)) {
+		clear_bit(RPS_SOFTIRQ_COMPLETING, &queue->rps_flags);
+		clear_bit(RPS_SOFTIRQ_PENDING, &queue->rps_flags);
+		smp_mb__after_clear_bit();
+	}
+
+	/* Send any pending remote softirqs, allows for coalescing */
+	for_each_cpu_mask_nr(cpu, __get_cpu_var(rps_remote_softirq_cpus)) {
+		struct softnet_data *queue = &per_cpu(softnet_data, cpu);
+		if (!test_and_set_bit(RPS_SOFTIRQ_PENDING,
+		    &queue->rps_flags))
+			__smp_call_function_single(cpu, &queue->rps_csd);
+	}
+	cpus_clear(__get_cpu_var(rps_remote_softirq_cpus));
+
+	/* Splice devices that were remotely scheduled for processing */
+	if (!list_empty(&queue->rps_poll_list)) {
+		spin_lock(&queue->rps_poll_list_lock);
+		list_splice_init(&queue->rps_poll_list, &queue->poll_list);
+		spin_unlock(&queue->rps_poll_list_lock);
+	}
+}
+
+static void net_rps_init_queue(struct softnet_data *queue, int cpu)
+{
+	INIT_LIST_HEAD(&queue->rps_poll_list);
+	spin_lock_init(&queue->rps_poll_list_lock);
+	queue->rps_cpu = cpu;
+	queue->rps_csd.func = trigger_softirq;
+	queue->rps_csd.info = queue;
+	queue->rps_csd.flags = 0;
+}
+
+#endif /* CONFIG_NET_SOFT_RPS*/
+
+/**
+ * schedule_backlog_napi is called to schedule backlog processing.
+ *
+ * Called with irq's disabled.
+ */
+static void schedule_backlog_napi(struct softnet_data *queue)
+{
+	if (napi_schedule_prep(&queue->backlog)) {
+#ifdef CONFIG_NET_SOFTRPS
+		if (queue->rps_cpu != smp_processor_id()) {
+			 /* Sheduling the backlog queue for a  different
+			  * CPU, a remote softirq is performed accordingly.
+			  */
+			spin_lock(&queue->rps_poll_list_lock);
+			list_add_tail(&queue->backlog.poll_list,
+			    &queue->rps_poll_list);
+			spin_unlock(&queue->rps_poll_list_lock);
+
+			cpu_set(queue->rps_cpu,
+			    get_cpu_var(rps_remote_softirq_cpus));
+			raise_softirq_irqoff(NET_RX_SOFTIRQ);
+			return;
+		}
+#endif
+		__napi_schedule(&queue->backlog);
+	}
+}

 /**
  *	netif_rx	-	post buffer to the network code
@@ -1939,23 +2073,28 @@ int netif_rx(struct sk_buff *skb)
 	 * short when CPU is congested, but is still operating.
 	 */
 	local_irq_save(flags);
-	queue = &__get_cpu_var(softnet_data);

+#ifdef CONFIG_NET_SOFTRPS
+	queue = &per_cpu(softnet_data, netif_cpu_for_rps(skb->dev, skb));
+	lock_softnet_input_queue_noflags(queue);
+#else
+	queue = &__get_cpu_var(softnet_data);
+#endif
 	__get_cpu_var(netdev_rx_stat).total++;
 	if (queue->input_pkt_queue.qlen <= netdev_max_backlog) {
 		if (queue->input_pkt_queue.qlen) {
 enqueue:
 			__skb_queue_tail(&queue->input_pkt_queue, skb);
-			local_irq_restore(flags);
+			unlock_softnet_input_queue(queue, &flags);
 			return NET_RX_SUCCESS;
 		}

-		napi_schedule(&queue->backlog);
+		schedule_backlog_napi(queue);
 		goto enqueue;
 	}

 	__get_cpu_var(netdev_rx_stat).dropped++;
-	local_irq_restore(flags);
+	unlock_softnet_input_queue(queue, &flags);

 	kfree_skb(skb);
 	return NET_RX_DROP;
@@ -2192,10 +2331,10 @@ void netif_nit_deliver(struct sk_buff *skb)
 }

 /**
- *	netif_receive_skb - process receive buffer from network
+ *	__netif_receive_skb - process receive buffer from network
  *	@skb: buffer to process
  *
- *	netif_receive_skb() is the main receive data processing function.
+ *	__netif_receive_skb() is the main receive data processing function.
  *	It always succeeds. The buffer may be dropped during processing
  *	for congestion control or by the protocol layers.
  *
@@ -2206,7 +2345,7 @@ void netif_nit_deliver(struct sk_buff *skb)
  *	NET_RX_SUCCESS: no congestion
  *	NET_RX_DROP: packet was dropped
  */
-int netif_receive_skb(struct sk_buff *skb)
+int __netif_receive_skb(struct sk_buff *skb)
 {
 	struct packet_type *ptype, *pt_prev;
 	struct net_device *orig_dev;
@@ -2347,7 +2486,7 @@ static int napi_gro_complete(struct sk_buff *skb)

 out:
 	skb_shinfo(skb)->gso_size = 0;
-	return netif_receive_skb(skb);
+	return __netif_receive_skb(skb);
 }

 void napi_gro_flush(struct napi_struct *napi)
@@ -2484,7 +2623,7 @@ int napi_skb_finish(int ret, struct sk_buff *skb)

 	switch (ret) {
 	case GRO_NORMAL:
-		return netif_receive_skb(skb);
+		return __netif_receive_skb(skb);

 	case GRO_DROP:
 		err = NET_RX_DROP;
@@ -2585,7 +2724,7 @@ int napi_frags_finish(struct napi_struct *napi,
struct sk_buff *skb, int ret)
 		skb->protocol = eth_type_trans(skb, napi->dev);

 		if (ret == GRO_NORMAL)
-			return netif_receive_skb(skb);
+			return __netif_receive_skb(skb);

 		skb_gro_pull(skb, -ETH_HLEN);
 		break;
@@ -2619,19 +2758,24 @@ static int process_backlog(struct napi_struct
*napi, int quota)
 	int work = 0;
 	struct softnet_data *queue = &__get_cpu_var(softnet_data);
 	unsigned long start_time = jiffies;
+	unsigned long flags;

 	napi->weight = weight_p;
 	do {
 		struct sk_buff *skb;

-		local_irq_disable();
+		lock_softnet_input_queue(queue, &flags);
 		skb = __skb_dequeue(&queue->input_pkt_queue);
 		if (!skb) {
-			local_irq_enable();
-			napi_complete(napi);
+			unlock_softnet_input_queue(queue, &flags);
+			napi_gro_flush(napi);
+			lock_softnet_input_queue(queue, &flags);
+			if (skb_queue_empty(&queue->input_pkt_queue))
+				__napi_complete(napi);
+			unlock_softnet_input_queue(queue, &flags);
 			goto out;
 		}
-		local_irq_enable();
+		unlock_softnet_input_queue(queue, &flags);

 		napi_gro_receive(napi, skb);
 	} while (++work < quota && jiffies == start_time);
@@ -2728,13 +2872,18 @@ EXPORT_SYMBOL(netif_napi_del);

 static void net_rx_action(struct softirq_action *h)
 {
-	struct list_head *list = &__get_cpu_var(softnet_data).poll_list;
+	struct softnet_data *queue = &__get_cpu_var(softnet_data);
+	struct list_head *list = &queue->poll_list;
 	unsigned long time_limit = jiffies + 2;
 	int budget = netdev_budget;
 	void *have;

 	local_irq_disable();

+#ifdef CONFIG_NET_SOFTRPS
+	net_rx_action_rps(queue);
+#endif
+
 	while (!list_empty(list)) {
 		struct napi_struct *n;
 		int work, weight;
@@ -5239,6 +5388,9 @@ static int __init net_dev_init(void)
 		queue->completion_queue = NULL;
 		INIT_LIST_HEAD(&queue->poll_list);

+#ifdef CONFIG_NET_SOFTRPS
+		net_rps_init_queue(queue, i);
+#endif
 		queue->backlog.poll = process_backlog;
 		queue->backlog.weight = weight_p;
 		queue->backlog.gro_list = NULL;
@@ -5305,7 +5457,7 @@ EXPORT_SYMBOL(free_netdev);
 EXPORT_SYMBOL(netdev_boot_setup_check);
 EXPORT_SYMBOL(netdev_set_master);
 EXPORT_SYMBOL(netdev_state_change);
-EXPORT_SYMBOL(netif_receive_skb);
+EXPORT_SYMBOL(__netif_receive_skb);
 EXPORT_SYMBOL(netif_rx);
 EXPORT_SYMBOL(register_gifconf);
 EXPORT_SYMBOL(register_netdevice);
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 2da59a0..b12ae88 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -211,6 +211,64 @@ static ssize_t store_tx_queue_len(struct device *dev,
 	return netdev_store(dev, attr, buf, len, change_tx_queue_len);
 }

+#ifdef CONFIG_NET_SOFTRPS
+static ssize_t netdev_store_cpumask(struct net_device *net, const char *buf,
+    size_t len, cpumask_t *maskp)
+{
+	cpumask_t new_value;
+	int err;
+
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
+	err = bitmap_parse(buf, len, cpumask_bits(&new_value), nr_cpumask_bits);
+	if (err)
+		return err;
+
+	rtnl_lock();
+	if (dev_isalive(net))
+		*maskp = new_value;
+	rtnl_unlock();
+
+	return len;
+}
+
+static ssize_t netdev_show_cpumask(struct net_device *net, char *buf,
+    cpumask_t *maskp)
+{
+	size_t len;
+	cpumask_t tmp;
+
+	read_lock(&dev_base_lock);
+	if (dev_isalive(net))
+		cpus_and(tmp, *maskp, cpu_online_map);
+	else
+		cpus_clear(tmp);
+	read_unlock(&dev_base_lock);
+
+	len = cpumask_scnprintf(buf, PAGE_SIZE, &tmp);
+	if (PAGE_SIZE - len < 2)
+		return -EINVAL;
+
+	len += sprintf(buf + len, "\n");
+	return len;
+}
+
+static ssize_t show_soft_rps_cpus(struct device *dev,
+			    struct device_attribute *attr, char *buf)
+{
+	struct net_device *net = to_net_dev(dev);
+	return netdev_show_cpumask(net, buf, &net->soft_rps_cpus);
+}
+
+static ssize_t store_soft_rps_cpus(struct device *dev,
+    struct device_attribute *attr, const char *buf, size_t len)
+{
+	struct net_device *net = to_net_dev(dev);
+	return netdev_store_cpumask(net, buf, len, &net->soft_rps_cpus);
+}
+#endif
+
 static ssize_t store_ifalias(struct device *dev, struct device_attribute *attr,
 			     const char *buf, size_t len)
 {
@@ -263,6 +321,10 @@ static struct device_attribute net_class_attributes[] = {
 	__ATTR(flags, S_IRUGO | S_IWUSR, show_flags, store_flags),
 	__ATTR(tx_queue_len, S_IRUGO | S_IWUSR, show_tx_queue_len,
 	       store_tx_queue_len),
+#ifdef CONFIG_NET_SOFTRPS
+	__ATTR(soft_rps_cpus, S_IRUGO | S_IWUSR, show_soft_rps_cpus,
+	       store_soft_rps_cpus),
+#endif
 	{}
 };
