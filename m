From: Tom Herbert <therbert@google.com>
Subject: [PATCH v5] rps: Receive Packet Steering
Date: Thu, 14 Jan 2010 13:56:23 -0800 (PST)
Message-ID: <alpine.DEB.1.00.1001141353140.19018@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:26529 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752312Ab0ANV4c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jan 2010 16:56:32 -0500
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
performed on packets in parallel.   For each device (or NAPI instance for
a multi-queue device) a mask of CPUs is set to indicate the CPUs that can
process packets for the device. A CPU is selected on a per packet basis by
hashing contents of the packet header (the TCP or UDP 4-tuple) and using the
result to index into the CPU mask.  The IPI mechanism is used to raise
networking receive softirqs between CPUs.  This effectively emulates in
software what a multi-queue NIC can provide, but is generic requiring no device
support.

Many devices now provide a hash over the 4-tuple on a per packet basis
(Toeplitz is popular).  This patch allow drivers to set the HW reported hash
in an skb field, and that value in turn is used to index into the RPS maps.
Using the HW generated hash can avoid cache misses on the packet when
steering the packet to a remote CPU.

The CPU masks is set on a per device basis in the sysfs variable
/sys/class/net/<device>/rps_cpus.  This is a set of canonical bit maps for
each NAPI nstance of the device.  For example:

echo "0b 0b0 0b00 0b000" > /sys/class/net/eth0/rps_cpus

would set maps for four NAPI instances on eth0.

Generally, we have found this technique increases pps capabilities of a single
queue device with good CPU utilization.  Optimal settings for the CPU mask
seems to depend on architectures and cache hierarcy.  Below are some results
running 500 instances of netperf TCP_RR test with 1 byte req. and resp.
Results show cumulative transaction rate and system CPU utilization.

e1000e on 8 core Intel
    Without RPS: 90K tps at 33% CPU
    With RPS:    239K tps at 60% CPU

foredeth on 16 core AMD
    Without RPS: 103K tps at 15% CPU
    With RPS:    285K tps at 49% CPU

Caveats:
- The benefits of this patch are dependent on architecture and cache hierarchy.
Tuning the masks to get best performance is probably necessary.
- This patch adds overhead in the path for processing a single packet.  In
a lightly loaded server this overhead may eliminate the advantages of
increased parallelism, and possibly cause some relative performance degradation.
We have found that RPS masks that are cache aware (share same caches with
the interrupting CPU) mitigate much of this.
- The RPS masks can be changed dynamically, however whenever the mask is changed
this introduces the possbility of generating out of order packets.  It's
probably best not change the masks too frequently.

Signed-off-by: Tom Herbert <therbert@google.com>

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 97873e3..8b33522 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -222,6 +222,7 @@ struct netif_rx_stats {
  	unsigned dropped;
  	unsigned time_squeeze;
  	unsigned cpu_collision;
+	unsigned received_rps;
  };

  DECLARE_PER_CPU(struct netif_rx_stats, netdev_rx_stat);
@@ -676,6 +677,27 @@ struct net_device_ops {
  };

  /*
+ * Structure for Receive Packet Steering.  Length of map and array of CPU ID's.
+ */
+struct rps_map {
+	int len;
+	u16 map[0];
+};
+
+#define MAX_RPS_CPUS 256 /* Limit maximum number of CPUs in a map */
+extern int rps_map_size; /* Size of an RPS map */
+extern int rps_cpus_in_map; /* Number of CPUs in a map */
+
+/*
+ * Structure that contains the rps maps for various NAPI instances of a device.
+ */
+struct dev_rps_maps {
+	int num_maps;
+	struct rcu_head rcu;
+	struct rps_map maps[0];
+};
+
+/*
   *	The DEVICE structure.
   *	Actually, this whole structure is a big mistake.  It mixes I/O
   *	data with strictly "high-level" data, and it has to know about
@@ -861,6 +883,9 @@ struct net_device {

  	struct netdev_queue	rx_queue;

+	struct dev_rps_maps	*dev_rps_maps;	/* Per-NAPI maps for
+						   receive packet steering */
+
  	struct netdev_queue	*_tx ____cacheline_aligned_in_smp;

  	/* Number of TX queues allocated at alloc_netdev_mq() time  */
@@ -1274,14 +1299,16 @@ static inline int unregister_gifconf(unsigned int family)
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
index 63f4742..f188301 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -267,6 +267,7 @@ typedef unsigned char *sk_buff_data_t;
   *	@mac_header: Link layer header
   *	@_skb_dst: destination entry
   *	@sp: the security path, used for xfrm
+ *	@rxhash: the packet hash computed on receive
   *	@cb: Control buffer. Free for use by every layer. Put private vars here
   *	@len: Length of actual data
   *	@data_len: Data length
@@ -323,6 +324,8 @@ struct sk_buff {
  #ifdef CONFIG_XFRM
  	struct	sec_path	*sp;
  #endif
+	__u32			rxhash;
+
  	/*
  	 * This is the control buffer. It is free to use for every
  	 * layer. Please put your private variables there. If you
diff --git a/net/core/dev.c b/net/core/dev.c
index 9977288..b7ad07d 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1834,7 +1834,7 @@ out_kfree_skb:
  	return rc;
  }

-static u32 skb_tx_hashrnd;
+static u32 hashrnd __read_mostly;

  u16 skb_tx_hash(const struct net_device *dev, const struct sk_buff *skb)
  {
@@ -1852,7 +1852,7 @@ u16 skb_tx_hash(const struct net_device *dev, const struct sk_buff *skb)
  	else
  		hash = skb->protocol;

-	hash = jhash_1word(hash, skb_tx_hashrnd);
+	hash = jhash_1word(hash, hashrnd);

  	return (u16) (((u64) hash * dev->real_num_tx_queues) >> 32);
  }
@@ -2070,9 +2070,154 @@ EXPORT_SYMBOL(dev_queue_xmit);
  int netdev_max_backlog __read_mostly = 1000;
  int netdev_budget __read_mostly = 300;
  int weight_p __read_mostly = 64;            /* old backlog weight */
+int rps_cpus_in_map __read_mostly;
+int rps_map_size __read_mostly;

  DEFINE_PER_CPU(struct netif_rx_stats, netdev_rx_stat) = { 0, };

+/*
+ * get_rps_cpu is called from netif_receive_skb and returns the target
+ * CPU from the RPS map of the receiving NAPI instance for a given skb.
+ */
+static int get_rps_cpu(struct net_device *dev, struct sk_buff *skb)
+{
+	u32 addr1, addr2, ports;
+	struct ipv6hdr *ip6;
+	struct iphdr *ip;
+	u32 ihl;
+	u8 ip_proto;
+	int cpu = -1;
+	struct dev_rps_maps *drmap;
+	struct rps_map *map = NULL;
+	u16 index;
+
+	rcu_read_lock();
+
+	drmap = rcu_dereference(dev->dev_rps_maps);
+	if (!drmap)
+		goto done;
+
+	index = skb_get_rx_queue(skb);
+	if (index >= drmap->num_maps)
+		index = 0;
+
+	map = (struct rps_map *)
+	    ((void *)drmap->maps + (rps_map_size * index));
+	if (!map->len)
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
+	cpu = map->map[((u64) skb->rxhash * map->len) >> 32];
+
+	if (!cpu_online(cpu))
+		cpu = -1;
+done:
+	rcu_read_unlock();
+	return cpu;
+}
+
+static DEFINE_PER_CPU(cpumask_t, rps_remote_softirq_cpus);
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
+				cpu_set(cpu,
+				    __get_cpu_var(rps_remote_softirq_cpus));
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
@@ -2091,8 +2236,7 @@ DEFINE_PER_CPU(struct netif_rx_stats, netdev_rx_stat) = { 0, };

  int netif_rx(struct sk_buff *skb)
  {
-	struct softnet_data *queue;
-	unsigned long flags;
+	int cpu;

  	/* if netpoll wants it, pretend we never saw it */
  	if (netpoll_rx(skb))
@@ -2101,31 +2245,11 @@ int netif_rx(struct sk_buff *skb)
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
+	cpu = get_rps_cpu(skb->dev, skb);
+	if (cpu < 0)
+		cpu = smp_processor_id();

-	__get_cpu_var(netdev_rx_stat).dropped++;
-	local_irq_restore(flags);
-
-	kfree_skb(skb);
-	return NET_RX_DROP;
+	return enqueue_to_backlog(skb, cpu);
  }
  EXPORT_SYMBOL(netif_rx);

@@ -2363,10 +2487,10 @@ void netif_nit_deliver(struct sk_buff *skb)
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
@@ -2377,7 +2501,7 @@ void netif_nit_deliver(struct sk_buff *skb)
   *	NET_RX_SUCCESS: no congestion
   *	NET_RX_DROP: packet was dropped
   */
-int netif_receive_skb(struct sk_buff *skb)
+int __netif_receive_skb(struct sk_buff *skb)
  {
  	struct packet_type *ptype, *pt_prev;
  	struct net_device *orig_dev;
@@ -2475,6 +2599,16 @@ out:
  }
  EXPORT_SYMBOL(netif_receive_skb);

+int netif_receive_skb(struct sk_buff *skb)
+{
+	int cpu = get_rps_cpu(skb->dev, skb);
+
+	if (cpu < 0)
+		return __netif_receive_skb(skb);
+	else
+		return enqueue_to_backlog(skb, cpu);
+}
+
  /* Network device is going away, flush any packets still pending  */
  static void flush_backlog(void *arg)
  {
@@ -2799,16 +2933,16 @@ static int process_backlog(struct napi_struct *napi, int quota)
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
@@ -2897,6 +3031,22 @@ void netif_napi_del(struct napi_struct *napi)
  }
  EXPORT_SYMBOL(netif_napi_del);

+/*
+ * net_rps_action sends any pending IPI's for rps.  This is only called from
+ * softirq and interrupts must be enabled.
+ */
+static void net_rps_action(void)
+{
+	int cpu;
+
+	/* Send pending IPI's to kick RPS processing on remote cpus. */
+	for_each_cpu_mask_nr(cpu, __get_cpu_var(rps_remote_softirq_cpus)) {
+		struct softnet_data *queue = &per_cpu(softnet_data, cpu);
+		cpu_clear(cpu, __get_cpu_var(rps_remote_softirq_cpus));
+		if (cpu_online(cpu))
+			__smp_call_function_single(cpu, &queue->csd, 0);
+	}
+}

  static void net_rx_action(struct softirq_action *h)
  {
@@ -2968,6 +3118,8 @@ static void net_rx_action(struct softirq_action *h)
  out:
  	local_irq_enable();

+	net_rps_action();
+
  #ifdef CONFIG_NET_DMA
  	/*
  	 * There may not be any more sk_buffs coming right now, so push
@@ -3212,10 +3364,10 @@ static int softnet_seq_show(struct seq_file *seq, void *v)
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

@@ -5341,6 +5493,8 @@ void free_netdev(struct net_device *dev)
  	/* Flush device addresses */
  	dev_addr_flush(dev);

+	kfree(dev->dev_rps_maps);
+
  	list_for_each_entry_safe(p, n, &dev->napi_list, dev_list)
  		netif_napi_del(p);

@@ -5793,12 +5947,20 @@ static int __init net_dev_init(void)
  		queue->completion_queue = NULL;
  		INIT_LIST_HEAD(&queue->poll_list);

+		queue->csd.func = trigger_softirq;
+		queue->csd.info = queue;
+		queue->csd.flags = 0;
+
  		queue->backlog.poll = process_backlog;
  		queue->backlog.weight = weight_p;
  		queue->backlog.gro_list = NULL;
  		queue->backlog.gro_count = 0;
  	}

+	rps_cpus_in_map = num_possible_cpus() < MAX_RPS_CPUS ?
+	    num_possible_cpus() : MAX_RPS_CPUS;
+	rps_map_size = sizeof(struct rps_map) + (rps_cpus_in_map * sizeof(u16));
+
  	dev_boot_phase = 0;

  	/* The loopback device is special if any other network devices
@@ -5831,7 +5993,7 @@ subsys_initcall(net_dev_init);

  static int __init initialize_hashrnd(void)
  {
-	get_random_bytes(&skb_tx_hashrnd, sizeof(skb_tx_hashrnd));
+	get_random_bytes(&hashrnd, sizeof(hashrnd));
  	return 0;
  }

diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 157645c..a390c07 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -18,6 +18,9 @@
  #include <linux/wireless.h>
  #include <net/wext.h>

+#include <linux/string.h>
+#include <linux/ctype.h>
+
  #include "net-sysfs.h"

  #ifdef CONFIG_SYSFS
@@ -253,6 +256,134 @@ static ssize_t store_tx_queue_len(struct device *dev,
  	return netdev_store(dev, attr, buf, len, change_tx_queue_len);
  }

+static char *get_token(const char **cp, size_t *len)
+{
+	const char *bp = *cp;
+	char *start;
+
+	while (isspace(*bp))
+		bp++;
+
+	start = (char *)bp;
+	while (!isspace(*bp) && *bp != '\0')
+		bp++;
+
+	if (start != bp)
+		*len = bp - start;
+	else
+		start = NULL;
+
+	*cp = bp;
+	return start;
+}
+
+static void dev_map_release(struct rcu_head *rcu)
+{
+	struct dev_rps_maps *drmap =
+	    container_of(rcu, struct dev_rps_maps, rcu);
+
+	kfree(drmap);
+}
+
+static ssize_t store_rps_cpus(struct device *dev,
+    struct device_attribute *attr, const char *buf, size_t len)
+{
+	struct net_device *net = to_net_dev(dev);
+	struct napi_struct *napi;
+	cpumask_t mask;
+	int err, cpu, index, i;
+	int cnt = 0;
+	char *token;
+	const char *cp = buf;
+	size_t tlen;
+	struct dev_rps_maps *drmap, *old_drmap;
+
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
+	cnt = 0;
+	list_for_each_entry(napi, &net->napi_list, dev_list)
+		cnt++;
+	if (cnt == 0)
+		cnt = 1; /* For devices with no napi instances */
+
+	drmap = kzalloc(sizeof(struct dev_rps_maps) +
+	    rps_map_size * cnt, GFP_KERNEL);
+	if (!drmap)
+		return -ENOMEM;
+
+	drmap->num_maps = cnt;
+
+	cp = buf;
+	for (index = 0; index < cnt &&
+	   (token = get_token(&cp, &tlen)); index++) {
+		struct rps_map *map = (struct rps_map *)
+		    ((void *)drmap->maps + (rps_map_size * index));
+		err = bitmap_parse(token, tlen, cpumask_bits(&mask),
+		    nr_cpumask_bits);
+
+		if (err) {
+			kfree(drmap);
+			return err;
+		}
+
+		cpus_and(mask, mask, cpu_online_map);
+		i = 0;
+		for_each_cpu_mask(cpu, mask) {
+			if (i >= rps_cpus_in_map)
+				break;
+			map->map[i++] =  cpu;
+		}
+		map->len = i;
+	}
+
+	rtnl_lock();
+	old_drmap = net->dev_rps_maps;
+	rcu_assign_pointer(net->dev_rps_maps, drmap);
+	rtnl_unlock();
+
+	if (old_drmap)
+		call_rcu(&old_drmap->rcu, dev_map_release);
+
+	return len;
+}
+
+static ssize_t show_rps_cpus(struct device *dev,
+			    struct device_attribute *attr, char *buf)
+{
+	struct net_device *net = to_net_dev(dev);
+	size_t len = 0;
+	cpumask_t mask;
+	int i, j;
+	struct dev_rps_maps *drmap;
+
+	rcu_read_lock();
+	drmap = rcu_dereference(net->dev_rps_maps);
+
+	if (drmap) {
+		for (j = 0; j < drmap->num_maps; j++) {
+			struct rps_map *map = (struct rps_map *)
+			    ((void *)drmap->maps + (rps_map_size * j));
+			cpus_clear(mask);
+			for (i = 0; i < map->len; i++)
+				cpu_set(map->map[i], mask);
+
+			len += cpumask_scnprintf(buf + len, PAGE_SIZE, &mask);
+			if (PAGE_SIZE - len < 3) {
+				rcu_read_unlock();
+				return -EINVAL;
+			}
+			if (j < drmap->num_maps)
+				len += sprintf(buf + len, " ");
+		}
+	}
+
+	rcu_read_unlock();
+
+	len += sprintf(buf + len, "\n");
+	return len;
+}
+
  static ssize_t store_ifalias(struct device *dev, struct device_attribute *attr,
  			     const char *buf, size_t len)
  {
@@ -309,6 +440,7 @@ static struct device_attribute net_class_attributes[] = {
  	__ATTR(flags, S_IRUGO | S_IWUSR, show_flags, store_flags),
  	__ATTR(tx_queue_len, S_IRUGO | S_IWUSR, show_tx_queue_len,
  	       store_tx_queue_len),
+	__ATTR(rps_cpus, S_IRUGO | S_IWUSR, show_rps_cpus, store_rps_cpus),
  	{}
  };

