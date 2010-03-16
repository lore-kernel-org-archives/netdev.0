From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH v7] rps: Receive Packet Steering
Date: Tue, 16 Mar 2010 11:03:29 -0700
Message-ID: <4B9FC7F1.5010507@google.com>
References: <alpine.DEB.1.00.1003121210050.25665@pokey.mtv.corp.google.com>	 <1268429319.2947.10.camel@edumazet-laptop> <65634d661003121508m3d348973k63a6ae9ca1f12f9f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:1553 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S937842Ab0CPSRi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Mar 2010 14:17:38 -0400
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id o2GI3ZCQ019692
	for <netdev@vger.kernel.org>; Tue, 16 Mar 2010 19:03:36 +0100
Received: from fxm20 (fxm20.prod.google.com [10.184.13.20])
	by wpaz1.hot.corp.google.com with ESMTP id o2GI2uhZ002529
	for <netdev@vger.kernel.org>; Tue, 16 Mar 2010 11:03:34 -0700
Received: by fxm20 with SMTP id 20so429598fxm.32
        for <netdev@vger.kernel.org>; Tue, 16 Mar 2010 11:03:34 -0700 (PDT)
In-Reply-To: <65634d661003121508m3d348973k63a6ae9ca1f12f9f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tom Herbert wrote:
>> One last point about placement of rxhash in struct sk_buff, that I
>> missed in my previous review, sorry...
>>
>> You put it right before cb[48] which is now aligned to 8 bytes (since
>> commit da3f5cf1 skbuff: align sk_buff::cb to 64 bit and close some
>> potential holes), so this adds a 4 bytes hole.
>>
>> Please put it elsewhere, possibly close to fields that are read in
>> get_rps_cpu() (skb->queue_mapping, skb->protocol, skb->data, ...) to
>> minimize number of cache lines that dispatcher cpu has to bring into its
>> cache, before giving skb to another cpu for IP/TCP processing.
>>
> Looks like it will fit right before queue_mapping, I'll put it there.
> 
> Tom


This patch implements software receive side packet steering (RPS).  RPS
distributes the load of received packet processing across multiple CPUs.

Problem statement: Protocol processing done in the NAPI context for received
packets is serialized per device queue and becomes a bottleneck under high
packet load.  This substantially limits pps that can be achieved on a single
queue NIC and provides no scaling with multiple cores.

This solution queues packets early on in the receive path on the backlog queues
of other CPUs.   This allows protocol processing (e.g. IP and TCP) to be
performed on packets in parallel.   For each device (or each receive queue in
a multi-queue device) a mask of CPUs is set to indicate the CPUs that can
process packets. A CPU is selected on a per packet basis by hashing contents
of the packet header (e.g. the TCP or UDP 4-tuple) and using the result to index
into the CPU mask.  The IPI mechanism is used to raise networking receive
softirqs between CPUs.  This effectively emulates in software what a multi-queue
NIC can provide, but is generic requiring no device support.

Many devices now provide a hash over the 4-tuple on a per packet basis
(e.g. the Toeplitz hash).  This patch allow drivers to set the HW reported hash
in an skb field, and that value in turn is used to index into the RPS maps.
Using the HW generated hash can avoid cache misses on the packet when
steering it to a remote CPU.

The CPU mask is set on a per device and per queue basis in the sysfs variable
/sys/class/net/<device>/queues/rx-<n>/rps_cpus.  This is a set of canonical
bit maps for receive queues in the device (numbered by <n>).  If a device
does not support multi-queue, a single variable is used for the device (rx-0).

Generally, we have found this technique increases pps capabilities of a single
queue device with good CPU utilization.  Optimal settings for the CPU mask
seem to depend on architectures and cache hierarcy.  Below are some results
running 500 instances of netperf TCP_RR test with 1 byte req. and resp.
Results show cumulative transaction rate and system CPU utilization.

e1000e on 8 core Intel
   Without RPS: 108K tps at 33% CPU
   With RPS:    311K tps at 64% CPU

forcedeth on 16 core AMD
   Without RPS: 156K tps at 15% CPU
   With RPS:    404K tps at 49% CPU
   
bnx2x on 16 core AMD
   Without RPS  567K tps at 61% CPU (4 HW RX queues)
   Without RPS  738K tps at 96% CPU (8 HW RX queues)
   With RPS:    854K tps at 76% CPU (4 HW RX queues)

Caveats:
- The benefits of this patch are dependent on architecture and cache hierarchy.
Tuning the masks to get best performance is probably necessary.
- This patch adds overhead in the path for processing a single packet.  In
a lightly loaded server this overhead may eliminate the advantages of
increased parallelism, and possibly cause some relative performance degradation.
We have found that masks that are cache aware (share same caches with
the interrupting CPU) mitigate much of this.
- The RPS masks can be changed dynamically, however whenever the mask is changed
this introduces the possibility of generating out of order packets.  It's
probably best not change the masks too frequently.

Signed-off-by: Tom Herbert <therbert@google.com>

 include/linux/netdevice.h |   32 ++++-
 include/linux/skbuff.h    |    3 +
 net/core/dev.c            |  335 +++++++++++++++++++++++++++++++++++++--------
 net/core/net-sysfs.c      |  225 ++++++++++++++++++++++++++++++-
 net/core/skbuff.c         |    2 +
 5 files changed, 538 insertions(+), 59 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index c79a88b..de1a52b 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -223,6 +223,7 @@ struct netif_rx_stats {
 	unsigned dropped;
 	unsigned time_squeeze;
 	unsigned cpu_collision;
+	unsigned received_rps;
 };
 
 DECLARE_PER_CPU(struct netif_rx_stats, netdev_rx_stat);
@@ -530,6 +531,24 @@ struct netdev_queue {
 	unsigned long		tx_dropped;
 } ____cacheline_aligned_in_smp;
 
+/*
+ * This structure holds an RPS map which can be of variable length.  The
+ * map is an array of CPUs.
+ */
+struct rps_map {
+	unsigned int len;
+	struct rcu_head rcu;
+	u16 cpus[0];
+};
+#define RPS_MAP_SIZE(_num) (sizeof(struct rps_map) + (_num * sizeof(u16)))
+
+/* This structure contains an instance of an RX queue. */
+struct netdev_rx_queue {
+	struct rps_map *rps_map;
+	struct kobject kobj;
+	struct netdev_rx_queue *first;
+	atomic_t count;
+} ____cacheline_aligned_in_smp;
 
 /*
  * This structure defines the management hooks for network devices.
@@ -878,6 +897,13 @@ struct net_device {
 
 	unsigned char		broadcast[MAX_ADDR_LEN];	/* hw bcast add	*/
 
+	struct kset		*queues_kset;
+
+	struct netdev_rx_queue	*_rx;
+
+	/* Number of RX queues allocated at alloc_netdev_mq() time  */
+	unsigned int		num_rx_queues;
+
 	struct netdev_queue	rx_queue;
 
 	struct netdev_queue	*_tx ____cacheline_aligned_in_smp;
@@ -1311,14 +1337,16 @@ static inline int unregister_gifconf(unsigned int family)
  */
 struct softnet_data {
 	struct Qdisc		*output_queue;
-	struct sk_buff_head	input_pkt_queue;
 	struct list_head	poll_list;
 	struct sk_buff		*completion_queue;
 
+	/* Elements below can be accessed between CPUs for RPS */
+	struct call_single_data	csd ____cacheline_aligned_in_smp;
+	struct sk_buff_head	input_pkt_queue;
 	struct napi_struct	backlog;
 };
 
-DECLARE_PER_CPU(struct softnet_data,softnet_data);
+DECLARE_PER_CPU_ALIGNED(struct softnet_data, softnet_data);
 
 #define HAVE_NETIF_QUEUE
 
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 03f816a..def10b0 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -300,6 +300,7 @@ typedef unsigned char *sk_buff_data_t;
  *	@nfct_reasm: netfilter conntrack re-assembly pointer
  *	@nf_bridge: Saved data about a bridged frame - see br_netfilter.c
  *	@skb_iif: ifindex of device we arrived on
+ *	@rxhash: the packet hash computed on receive
  *	@queue_mapping: Queue mapping for multiqueue devices
  *	@tc_index: Traffic control index
  *	@tc_verd: traffic control verdict
@@ -375,6 +376,8 @@ struct sk_buff {
 #endif
 #endif
 
+	__u32			rxhash;
+
 	kmemcheck_bitfield_begin(flags2);
 	__u16			queue_mapping:16;
 #ifdef CONFIG_IPV6_NDISC_NODETYPE
diff --git a/net/core/dev.c b/net/core/dev.c
index bcc490c..17b1686 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1931,7 +1931,7 @@ out_kfree_skb:
 	return rc;
 }
 
-static u32 skb_tx_hashrnd;
+static u32 hashrnd __read_mostly;
 
 u16 skb_tx_hash(const struct net_device *dev, const struct sk_buff *skb)
 {
@@ -1949,7 +1949,7 @@ u16 skb_tx_hash(const struct net_device *dev, const struct sk_buff *skb)
 	else
 		hash = skb->protocol;
 
-	hash = jhash_1word(hash, skb_tx_hashrnd);
+	hash = jhash_1word(hash, hashrnd);
 
 	return (u16) (((u64) hash * dev->real_num_tx_queues) >> 32);
 }
@@ -1959,10 +1959,9 @@ static inline u16 dev_cap_txqueue(struct net_device *dev, u16 queue_index)
 {
 	if (unlikely(queue_index >= dev->real_num_tx_queues)) {
 		if (net_ratelimit()) {
-			WARN(1, "%s selects TX queue %d, but "
+			netdev_warn(dev, "selects TX queue %d, but "
 			     "real number of TX queues is %d\n",
-			     dev->name, queue_index,
-			     dev->real_num_tx_queues);
+			     queue_index, dev->real_num_tx_queues);
 		}
 		return 0;
 	}
@@ -2175,6 +2174,172 @@ int weight_p __read_mostly = 64;            /* old backlog weight */
 
 DEFINE_PER_CPU(struct netif_rx_stats, netdev_rx_stat) = { 0, };
 
+/*
+ * get_rps_cpu is called from netif_receive_skb and returns the target
+ * CPU from the RPS map of the receiving queue for a given skb.
+ */
+static int get_rps_cpu(struct net_device *dev, struct sk_buff *skb)
+{
+	struct ipv6hdr *ip6;
+	struct iphdr *ip;
+	struct netdev_rx_queue *rxqueue;
+	struct rps_map *map;
+	int cpu = -1;
+	u8 ip_proto;
+	u32 addr1, addr2, ports, ihl;
+
+	rcu_read_lock();
+
+	if (skb_rx_queue_recorded(skb)) {
+		u16 index = skb_get_rx_queue(skb);
+		if (unlikely(index >= dev->num_rx_queues)) {
+			if (net_ratelimit()) {
+				netdev_warn(dev, "received packet on queue "
+				    "%u, but number of RX queues is %u\n",
+				     index, dev->num_rx_queues);
+			}
+			goto done;
+		}
+		rxqueue = dev->_rx + index;
+	} else
+		rxqueue = dev->_rx;
+
+	if (!rxqueue->rps_map)
+		goto done;
+
+	if (skb->rxhash)
+		goto got_hash; /* Skip hash computation on packet header */
+
+	switch (skb->protocol) {
+	case __constant_htons(ETH_P_IP):
+		if (!pskb_may_pull(skb, sizeof(*ip)))
+			goto done;
+
+		ip = (struct iphdr *) skb->data;
+		ip_proto = ip->protocol;
+		addr1 = ip->saddr;
+		addr2 = ip->daddr;
+		ihl = ip->ihl;
+		break;
+	case __constant_htons(ETH_P_IPV6):
+		if (!pskb_may_pull(skb, sizeof(*ip6)))
+			goto done;
+
+		ip6 = (struct ipv6hdr *) skb->data;
+		ip_proto = ip6->nexthdr;
+		addr1 = ip6->saddr.s6_addr32[3];
+		addr2 = ip6->daddr.s6_addr32[3];
+		ihl = (40 >> 2);
+		break;
+	default:
+		goto done;
+	}
+	ports = 0;
+	switch (ip_proto) {
+	case IPPROTO_TCP:
+	case IPPROTO_UDP:
+	case IPPROTO_DCCP:
+	case IPPROTO_ESP:
+	case IPPROTO_AH:
+	case IPPROTO_SCTP:
+	case IPPROTO_UDPLITE:
+		if (pskb_may_pull(skb, (ihl * 4) + 4))
+			ports = *((u32 *) (skb->data + (ihl * 4)));
+		break;
+
+	default:
+		break;
+	}
+
+	skb->rxhash = jhash_3words(addr1, addr2, ports, hashrnd);
+	if (!skb->rxhash)
+		skb->rxhash = 1;
+
+got_hash:
+	map = rcu_dereference(rxqueue->rps_map);
+	if (map) {
+		u16 tcpu = map->cpus[((u64) skb->rxhash * map->len) >> 32];
+
+		if (cpu_online(tcpu)) {
+			cpu = tcpu;
+			goto done;
+		}
+	}
+
+done:
+	rcu_read_unlock();
+	return cpu;
+}
+
+/*
+ * This structure holds the per-CPU mask of CPUs for which IPIs are scheduled
+ * to be sent to kick remote softirq processing.  There are two masks since
+ * the sending of IPIs must be done with interrupts enabled.  The select field
+ * indicates the current mask that enqueue_backlog uses to schedule IPIs.
+ * select is flipped before net_rps_action is called while still under lock,
+ * net_rps_action then uses the non-selected mask to send the IPIs and clears
+ * it without conflicting with enqueue_backlog operation.
+ */
+struct rps_remote_softirq_cpus {
+	cpumask_t mask[2];
+	int select;
+};
+static DEFINE_PER_CPU(struct rps_remote_softirq_cpus, rps_remote_softirq_cpus);
+
+/* Called from hardirq (IPI) context */
+static void trigger_softirq(void *data)
+{
+	struct softnet_data *queue = data;
+	__napi_schedule(&queue->backlog);
+	__get_cpu_var(netdev_rx_stat).received_rps++;
+}
+
+/*
+ * enqueue_to_backlog is called to queue an skb to a per CPU backlog
+ * queue (may be a remote CPU queue).
+ */
+static int enqueue_to_backlog(struct sk_buff *skb, int cpu)
+{
+	struct softnet_data *queue;
+	unsigned long flags;
+
+	queue = &per_cpu(softnet_data, cpu);
+
+	local_irq_save(flags);
+	__get_cpu_var(netdev_rx_stat).total++;
+
+	spin_lock(&queue->input_pkt_queue.lock);
+	if (queue->input_pkt_queue.qlen <= netdev_max_backlog) {
+		if (queue->input_pkt_queue.qlen) {
+enqueue:
+			__skb_queue_tail(&queue->input_pkt_queue, skb);
+			spin_unlock_irqrestore(&queue->input_pkt_queue.lock,
+			    flags);
+			return NET_RX_SUCCESS;
+		}
+
+		/* Schedule NAPI for backlog device */
+		if (napi_schedule_prep(&queue->backlog)) {
+			if (cpu != smp_processor_id()) {
+				struct rps_remote_softirq_cpus *rcpus =
+				    &__get_cpu_var(rps_remote_softirq_cpus);
+
+				cpu_set(cpu, rcpus->mask[rcpus->select]);
+				__raise_softirq_irqoff(NET_RX_SOFTIRQ);
+			} else
+				__napi_schedule(&queue->backlog);
+		}
+		goto enqueue;
+	}
+
+	spin_unlock(&queue->input_pkt_queue.lock);
+
+	__get_cpu_var(netdev_rx_stat).dropped++;
+	local_irq_restore(flags);
+
+	kfree_skb(skb);
+	return NET_RX_DROP;
+}
 
 /**
  *	netif_rx	-	post buffer to the network code
@@ -2193,8 +2358,7 @@ DEFINE_PER_CPU(struct netif_rx_stats, netdev_rx_stat) = { 0, };
 
 int netif_rx(struct sk_buff *skb)
 {
-	struct softnet_data *queue;
-	unsigned long flags;
+	int cpu;
 
 	/* if netpoll wants it, pretend we never saw it */
 	if (netpoll_rx(skb))
@@ -2203,31 +2367,11 @@ int netif_rx(struct sk_buff *skb)
 	if (!skb->tstamp.tv64)
 		net_timestamp(skb);
 
-	/*
-	 * The code is rearranged so that the path is the most
-	 * short when CPU is congested, but is still operating.
-	 */
-	local_irq_save(flags);
-	queue = &__get_cpu_var(softnet_data);
-
-	__get_cpu_var(netdev_rx_stat).total++;
-	if (queue->input_pkt_queue.qlen <= netdev_max_backlog) {
-		if (queue->input_pkt_queue.qlen) {
-enqueue:
-			__skb_queue_tail(&queue->input_pkt_queue, skb);
-			local_irq_restore(flags);
-			return NET_RX_SUCCESS;
-		}
-
-		napi_schedule(&queue->backlog);
-		goto enqueue;
-	}
-
-	__get_cpu_var(netdev_rx_stat).dropped++;
-	local_irq_restore(flags);
+	cpu = get_rps_cpu(skb->dev, skb);
+	if (cpu < 0)
+		cpu = smp_processor_id();
 
-	kfree_skb(skb);
-	return NET_RX_DROP;
+	return enqueue_to_backlog(skb, cpu);
 }
 EXPORT_SYMBOL(netif_rx);
 
@@ -2464,22 +2608,7 @@ void netif_nit_deliver(struct sk_buff *skb)
 	rcu_read_unlock();
 }
 
-/**
- *	netif_receive_skb - process receive buffer from network
- *	@skb: buffer to process
- *
- *	netif_receive_skb() is the main receive data processing function.
- *	It always succeeds. The buffer may be dropped during processing
- *	for congestion control or by the protocol layers.
- *
- *	This function may only be called from softirq context and interrupts
- *	should be enabled.
- *
- *	Return values (usually ignored):
- *	NET_RX_SUCCESS: no congestion
- *	NET_RX_DROP: packet was dropped
- */
-int netif_receive_skb(struct sk_buff *skb)
+int __netif_receive_skb(struct sk_buff *skb)
 {
 	struct packet_type *ptype, *pt_prev;
 	struct net_device *orig_dev;
@@ -2588,6 +2717,33 @@ out:
 	rcu_read_unlock();
 	return ret;
 }
+
+/**
+ *	netif_receive_skb - process receive buffer from network
+ *	@skb: buffer to process
+ *
+ *	netif_receive_skb() is the main receive data processing function.
+ *	It always succeeds. The buffer may be dropped during processing
+ *	for congestion control or by the protocol layers.
+ *
+ *	This function may only be called from softirq context and interrupts
+ *	should be enabled.
+ *
+ *	Return values (usually ignored):
+ *	NET_RX_SUCCESS: no congestion
+ *	NET_RX_DROP: packet was dropped
+ */
+int netif_receive_skb(struct sk_buff *skb)
+{
+	int cpu;
+
+	cpu = get_rps_cpu(skb->dev, skb);
+
+	if (cpu < 0)
+		return __netif_receive_skb(skb);
+	else
+		return enqueue_to_backlog(skb, cpu);
+}
 EXPORT_SYMBOL(netif_receive_skb);
 
 /* Network device is going away, flush any packets still pending  */
@@ -2914,16 +3070,16 @@ static int process_backlog(struct napi_struct *napi, int quota)
 	do {
 		struct sk_buff *skb;
 
-		local_irq_disable();
+		spin_lock_irq(&queue->input_pkt_queue.lock);
 		skb = __skb_dequeue(&queue->input_pkt_queue);
 		if (!skb) {
 			__napi_complete(napi);
-			local_irq_enable();
+			spin_unlock_irq(&queue->input_pkt_queue.lock);
 			break;
 		}
-		local_irq_enable();
+		spin_unlock_irq(&queue->input_pkt_queue.lock);
 
-		netif_receive_skb(skb);
+		__netif_receive_skb(skb);
 	} while (++work < quota && jiffies == start_time);
 
 	return work;
@@ -3012,6 +3168,22 @@ void netif_napi_del(struct napi_struct *napi)
 }
 EXPORT_SYMBOL(netif_napi_del);
 
+/*
+ * net_rps_action sends any pending IPI's for rps.  This is only called from
+ * softirq and interrupts must be enabled.
+ */
+static void net_rps_action(cpumask_t *mask)
+{
+	int cpu;
+
+	/* Send pending IPI's to kick RPS processing on remote cpus. */
+	for_each_cpu_mask_nr(cpu, *mask) {
+		struct softnet_data *queue = &per_cpu(softnet_data, cpu);
+		if (cpu_online(cpu))
+			__smp_call_function_single(cpu, &queue->csd, 0);
+	}
+	cpus_clear(*mask);
+}
 
 static void net_rx_action(struct softirq_action *h)
 {
@@ -3019,6 +3191,8 @@ static void net_rx_action(struct softirq_action *h)
 	unsigned long time_limit = jiffies + 2;
 	int budget = netdev_budget;
 	void *have;
+	int select;
+	struct rps_remote_softirq_cpus *rcpus;
 
 	local_irq_disable();
 
@@ -3081,8 +3255,14 @@ static void net_rx_action(struct softirq_action *h)
 		netpoll_poll_unlock(have);
 	}
 out:
+	rcpus = &__get_cpu_var(rps_remote_softirq_cpus);
+	select = rcpus->select;
+	rcpus->select ^= 1;
+
 	local_irq_enable();
 
+	net_rps_action(&rcpus->mask[select]);
+
 #ifdef CONFIG_NET_DMA
 	/*
 	 * There may not be any more sk_buffs coming right now, so push
@@ -3327,10 +3507,10 @@ static int softnet_seq_show(struct seq_file *seq, void *v)
 {
 	struct netif_rx_stats *s = v;
 
-	seq_printf(seq, "%08x %08x %08x %08x %08x %08x %08x %08x %08x\n",
+	seq_printf(seq, "%08x %08x %08x %08x %08x %08x %08x %08x %08x %08x\n",
 		   s->total, s->dropped, s->time_squeeze, 0,
 		   0, 0, 0, 0, /* was fastroute */
-		   s->cpu_collision);
+		   s->cpu_collision, s->received_rps);
 	return 0;
 }
 
@@ -5067,6 +5247,23 @@ int register_netdevice(struct net_device *dev)
 
 	dev->iflink = -1;
 
+	if (!dev->num_rx_queues) {
+		/*
+		 * Allocate a single RX queue if driver never called
+		 * alloc_netdev_mq
+		 */
+
+		dev->_rx = kzalloc(sizeof(struct netdev_rx_queue), GFP_KERNEL);
+		if (!dev->_rx) {
+			ret = -ENOMEM;
+			goto out;
+		}
+
+		dev->_rx->first = dev->_rx;
+		atomic_set(&dev->_rx->count, 1);
+		dev->num_rx_queues = 1;
+	}
+
 	/* Init, if this function is available */
 	if (dev->netdev_ops->ndo_init) {
 		ret = dev->netdev_ops->ndo_init(dev);
@@ -5424,9 +5621,11 @@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 		void (*setup)(struct net_device *), unsigned int queue_count)
 {
 	struct netdev_queue *tx;
+	struct netdev_rx_queue *rx;
 	struct net_device *dev;
 	size_t alloc_size;
 	struct net_device *p;
+	int i;
 
 	BUG_ON(strlen(name) >= sizeof(dev->name));
 
@@ -5452,11 +5651,27 @@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 		goto free_p;
 	}
 
+	rx = kcalloc(queue_count, sizeof(struct netdev_rx_queue), GFP_KERNEL);
+	if (!rx) {
+		printk(KERN_ERR "alloc_netdev: Unable to allocate "
+		       "rx queues.\n");
+		goto free_tx;
+	}
+
+	atomic_set(&rx->count, queue_count);
+
+	/*
+	 * Set a pointer to first element in the array which holds the
+	 * reference count.
+	 */
+	for (i = 0; i < queue_count; i++)
+		rx[i].first = rx;
+
 	dev = PTR_ALIGN(p, NETDEV_ALIGN);
 	dev->padded = (char *)dev - (char *)p;
 
 	if (dev_addr_init(dev))
-		goto free_tx;
+		goto free_rx;
 
 	dev_unicast_init(dev);
 
@@ -5466,6 +5681,9 @@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 	dev->num_tx_queues = queue_count;
 	dev->real_num_tx_queues = queue_count;
 
+	dev->_rx = rx;
+	dev->num_rx_queues = queue_count;
+
 	dev->gso_max_size = GSO_MAX_SIZE;
 
 	netdev_init_queues(dev);
@@ -5480,9 +5698,10 @@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 	strcpy(dev->name, name);
 	return dev;
 
+free_rx:
+	kfree(rx);
 free_tx:
 	kfree(tx);
-
 free_p:
 	kfree(p);
 	return NULL;
@@ -5985,6 +6204,10 @@ static int __init net_dev_init(void)
 		queue->completion_queue = NULL;
 		INIT_LIST_HEAD(&queue->poll_list);
 
+		queue->csd.func = trigger_softirq;
+		queue->csd.info = queue;
+		queue->csd.flags = 0;
+
 		queue->backlog.poll = process_backlog;
 		queue->backlog.weight = weight_p;
 		queue->backlog.gro_list = NULL;
@@ -6023,7 +6246,7 @@ subsys_initcall(net_dev_init);
 
 static int __init initialize_hashrnd(void)
 {
-	get_random_bytes(&skb_tx_hashrnd, sizeof(skb_tx_hashrnd));
+	get_random_bytes(&hashrnd, sizeof(hashrnd));
 	return 0;
 }
 
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 099c753..7a46343 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -466,6 +466,216 @@ static struct attribute_group wireless_group = {
 };
 #endif
 
+/*
+ * RX queue sysfs structures and functions.
+ */
+struct rx_queue_attribute {
+	struct attribute attr;
+	ssize_t (*show)(struct netdev_rx_queue *queue,
+	    struct rx_queue_attribute *attr, char *buf);
+	ssize_t (*store)(struct netdev_rx_queue *queue,
+	    struct rx_queue_attribute *attr, const char *buf, size_t len);
+};
+#define to_rx_queue_attr(_attr) container_of(_attr,		\
+    struct rx_queue_attribute, attr)
+
+#define to_rx_queue(obj) container_of(obj, struct netdev_rx_queue, kobj)
+
+static ssize_t rx_queue_attr_show(struct kobject *kobj, struct attribute *attr,
+				  char *buf)
+{
+	struct rx_queue_attribute *attribute = to_rx_queue_attr(attr);
+	struct netdev_rx_queue *queue = to_rx_queue(kobj);
+
+	if (!attribute->show)
+		return -EIO;
+
+	return attribute->show(queue, attribute, buf);
+}
+
+static ssize_t rx_queue_attr_store(struct kobject *kobj, struct attribute *attr,
+				   const char *buf, size_t count)
+{
+	struct rx_queue_attribute *attribute = to_rx_queue_attr(attr);
+	struct netdev_rx_queue *queue = to_rx_queue(kobj);
+
+	if (!attribute->store)
+		return -EIO;
+
+	return attribute->store(queue, attribute, buf, count);
+}
+
+static struct sysfs_ops rx_queue_sysfs_ops = {
+	.show = rx_queue_attr_show,
+	.store = rx_queue_attr_store,
+};
+
+static ssize_t show_rps_map(struct netdev_rx_queue *queue,
+			    struct rx_queue_attribute *attribute, char *buf)
+{
+	struct rps_map *map;
+	cpumask_var_t mask;
+	size_t len = 0;
+	int i;
+
+	if (!zalloc_cpumask_var(&mask, GFP_KERNEL))
+		return -ENOMEM;
+
+	rcu_read_lock();
+	map = rcu_dereference(queue->rps_map);
+	if (map)
+		for (i = 0; i < map->len; i++)
+			cpumask_set_cpu(map->cpus[i], mask);
+
+	len += cpumask_scnprintf(buf + len, PAGE_SIZE, mask);
+	if (PAGE_SIZE - len < 3) {
+		rcu_read_unlock();
+		free_cpumask_var(mask);
+		return -EINVAL;
+	}
+	rcu_read_unlock();
+
+	free_cpumask_var(mask);
+	len += sprintf(buf + len, "\n");
+	return len;
+}
+
+static void rps_map_release(struct rcu_head *rcu)
+{
+	struct rps_map *map = container_of(rcu, struct rps_map, rcu);
+
+	kfree(map);
+}
+
+ssize_t store_rps_map(struct netdev_rx_queue *queue,
+		      struct rx_queue_attribute *attribute,
+		      const char *buf, size_t len)
+{
+	struct rps_map *old_map, *map;
+	cpumask_var_t mask;
+	int err, cpu, i;
+	static DEFINE_SPINLOCK(rps_map_lock);
+
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
+	if (!alloc_cpumask_var(&mask, GFP_KERNEL))
+		return -ENOMEM;
+
+	err = bitmap_parse(buf, len, cpumask_bits(mask), nr_cpumask_bits);
+	if (err) {
+		free_cpumask_var(mask);
+		return err;
+	}
+
+	map = kzalloc(max_t(unsigned,
+	    RPS_MAP_SIZE(cpumask_weight(mask)), L1_CACHE_BYTES),
+	    GFP_KERNEL);
+	if (!map) {
+		free_cpumask_var(mask);
+		return -ENOMEM;
+	}
+
+	i = 0;
+	for_each_cpu_and(cpu, mask, cpu_online_mask)
+		map->cpus[i++] = cpu;
+
+	if (i)
+		map->len = i;
+	else {
+		kfree(map);
+		map = NULL;
+	}
+
+	spin_lock(&rps_map_lock);
+	old_map = queue->rps_map;
+	rcu_assign_pointer(queue->rps_map, map);
+	spin_unlock(&rps_map_lock);
+
+	if (old_map)
+		call_rcu(&old_map->rcu, rps_map_release);
+
+	free_cpumask_var(mask);
+	return len;
+}
+
+static struct rx_queue_attribute rps_cpus_attribute =
+	__ATTR(rps_cpus, S_IRUGO | S_IWUSR, show_rps_map, store_rps_map);
+
+static struct attribute *rx_queue_default_attrs[] = {
+	&rps_cpus_attribute.attr,
+	NULL
+};
+
+static void rx_queue_release(struct kobject *kobj)
+{
+	struct netdev_rx_queue *queue = to_rx_queue(kobj);
+	struct rps_map *map = queue->rps_map;
+	struct netdev_rx_queue *first = queue->first;
+
+	if (map)
+		call_rcu(&map->rcu, rps_map_release);
+
+	if (atomic_dec_and_test(&first->count))
+		kfree(first);
+}
+
+static struct kobj_type rx_queue_ktype = {
+	.sysfs_ops = &rx_queue_sysfs_ops,
+	.release = rx_queue_release,
+	.default_attrs = rx_queue_default_attrs,
+};
+
+static int rx_queue_add_kobject(struct net_device *net, int index)
+{
+	struct netdev_rx_queue *queue = net->_rx + index;
+	struct kobject *kobj = &queue->kobj;
+	int error = 0;
+
+	kobj->kset = net->queues_kset;
+	error = kobject_init_and_add(kobj, &rx_queue_ktype, NULL,
+	    "rx-%u", index);
+	if (error) {
+		kobject_put(kobj);
+		return error;
+	}
+
+	kobject_uevent(kobj, KOBJ_ADD);
+
+	return error;
+}
+
+static int rx_queue_register_kobjects(struct net_device *net)
+{
+	int i;
+	int error = 0;
+
+	net->queues_kset = kset_create_and_add("queues",
+	    NULL, &net->dev.kobj);
+	if (!net->queues_kset)
+		return -ENOMEM;
+	for (i = 0; i < net->num_rx_queues; i++) {
+		error = rx_queue_add_kobject(net, i);
+		if (error)
+			break;
+	}
+
+	if (error)
+		while (--i >= 0)
+			kobject_put(&net->_rx[i].kobj);
+
+	return error;
+}
+
+static void rx_queue_remove_kobjects(struct net_device *net)
+{
+	int i;
+
+	for (i = 0; i < net->num_rx_queues; i++)
+		kobject_put(&net->_rx[i].kobj);
+	kset_unregister(net->queues_kset);
+}
+
 #endif /* CONFIG_SYSFS */
 
 #ifdef CONFIG_HOTPLUG
@@ -529,6 +739,8 @@ void netdev_unregister_kobject(struct net_device * net)
 	if (!net_eq(dev_net(net), &init_net))
 		return;
 
+	rx_queue_remove_kobjects(net);
+
 	device_del(dev);
 }
 
@@ -537,6 +749,7 @@ int netdev_register_kobject(struct net_device *net)
 {
 	struct device *dev = &(net->dev);
 	const struct attribute_group **groups = net->sysfs_groups;
+	int error = 0;
 
 	dev->class = &net_class;
 	dev->platform_data = net;
@@ -563,7 +776,17 @@ int netdev_register_kobject(struct net_device *net)
 	if (!net_eq(dev_net(net), &init_net))
 		return 0;
 
-	return device_add(dev);
+	error = device_add(dev);
+	if (error)
+		return error;
+
+	error = rx_queue_register_kobjects(net);
+	if (error) {
+		device_del(dev);
+		return error;
+	}
+
+	return error;
 }
 
 int netdev_class_create_file(struct class_attribute *class_attr)
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 93c4e06..bdea0ef 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -534,6 +534,7 @@ static void __copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
 	new->network_header	= old->network_header;
 	new->mac_header		= old->mac_header;
 	skb_dst_set(new, dst_clone(skb_dst(old)));
+	new->rxhash		= old->rxhash;
 #ifdef CONFIG_XFRM
 	new->sp			= secpath_get(old->sp);
 #endif
@@ -581,6 +582,7 @@ static struct sk_buff *__skb_clone(struct sk_buff *n, struct sk_buff *skb)
 	C(len);
 	C(data_len);
 	C(mac_len);
+	C(rxhash);
 	n->hdr_len = skb->nohdr ? skb_headroom(skb) : skb->hdr_len;
 	n->cloned = 1;
 	n->nohdr = 0;
