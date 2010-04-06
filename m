From: Tom Herbert <therbert@google.com>
Subject: [PATCH v2] rfs: Receive Flow Steering
Date: Mon, 5 Apr 2010 22:56:50 -0700 (PDT)
Message-ID: <alpine.DEB.1.00.1004052248390.29212@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.com, netdev@vger.kernel.org, eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:56286 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750992Ab0DFF46 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Apr 2010 01:56:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Version 2:
- added a u16 filler to pad rps_dev_flow structure
- define RPS_NO_CPU as 0xffff
- add inet_rps_save_rxhash helper function to copy skb's rxhash into inet_sk
- add a "voidflow" which can be used get_rps_cpu does not return a flow (avoids some conditionals)
- use raw_smp_processor_id in rps_record_sock_flow, this is no requirement to pr
event preemption
---
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
---
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index a343a21..09c8658 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -530,14 +530,74 @@ struct rps_map {
 };
 #define RPS_MAP_SIZE(_num) (sizeof(struct rps_map) + (_num * sizeof(u16)))
 
+/*
+ * The rps_dev_flow structure contains the mapping of a flow to a CPU and the
+ * tail pointer for that CPU's input queue at the time of last enqueue.
+ */
+struct rps_dev_flow {
+	u16 cpu;
+	u16 fill;
+	unsigned int last_qtail;
+};
+
+/*
+ * The rps_dev_flow_table structure contains a table of flow mappings.
+ */
+struct rps_dev_flow_table {
+	unsigned int mask;
+	struct rcu_head rcu;
+	struct work_struct free_work;
+	struct rps_dev_flow flows[0];
+};
+#define RPS_DEV_FLOW_TABLE_SIZE(_num) (sizeof(struct rps_dev_flow_table) + \
+    (_num * sizeof(struct rps_dev_flow)))
+
+/*
+ * The rps_sock_flow_table contains mappings of flows to the last CPU
+ * on which they were processed by the application (set in recvmsg).
+ */
+struct rps_sock_flow_table {
+	unsigned int mask;
+	u16 *ents;
+};
+
+#define RPS_NO_CPU 0xffff
+
+static inline void rps_set_sock_flow(struct rps_sock_flow_table *table,
+				     u32 hash, int cpu)
+{
+	if (table->ents && hash) {
+		unsigned int index = hash & table->mask;
+
+		if (table->ents[index] != cpu)
+			table->ents[index] = cpu;
+	}
+}
+
+static inline void rps_record_sock_flow(struct rps_sock_flow_table *table,
+					u32 hash)
+{
+	/* We only give a hint, preemption can change our cpu under us */
+	rps_set_sock_flow(table, hash, raw_smp_processor_id());
+}
+
+static inline void rps_reset_sock_flow(struct rps_sock_flow_table *table,
+				       u32 hash)
+{
+	rps_set_sock_flow(table, hash, RPS_NO_CPU);
+}
+
+extern struct rps_sock_flow_table rps_sock_flow_table;
+
 /* This structure contains an instance of an RX queue. */
 struct netdev_rx_queue {
 	struct rps_map *rps_map;
+	struct rps_dev_flow_table *rps_flow_table;
 	struct kobject kobj;
 	struct netdev_rx_queue *first;
 	atomic_t count;
 } ____cacheline_aligned_in_smp;
-#endif
+#endif /* CONFIG_RPS */
 
 /*
  * This structure defines the management hooks for network devices.
@@ -1331,8 +1391,9 @@ struct softnet_data {
 	struct sk_buff		*completion_queue;
 
 	/* Elements below can be accessed between CPUs for RPS */
-#ifdef CONFIG_SMP
+#ifdef CONFIG_RPS
 	struct call_single_data	csd ____cacheline_aligned_in_smp;
+	unsigned int		input_queue_head;
 #endif
 	struct sk_buff_head	input_pkt_queue;
 	struct napi_struct	backlog;
diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index 83fd344..801cd63 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -21,6 +21,7 @@
 #include <linux/string.h>
 #include <linux/types.h>
 #include <linux/jhash.h>
+#include <linux/netdevice.h>
 
 #include <net/flow.h>
 #include <net/sock.h>
@@ -101,6 +102,7 @@ struct rtable;
  * @uc_ttl - Unicast TTL
  * @inet_sport - Source port
  * @inet_id - ID counter for DF pkts
+ * @rxhash - flow hash received from netif layer
  * @tos - TOS
  * @mc_ttl - Multicasting TTL
  * @is_icsk - is this an inet_connection_sock?
@@ -124,6 +126,9 @@ struct inet_sock {
 	__u16			cmsg_flags;
 	__be16			inet_sport;
 	__u16			inet_id;
+#ifdef CONFIG_RPS
+	__u32			rxhash;
+#endif
 
 	struct ip_options	*opt;
 	__u8			tos;
@@ -219,4 +224,27 @@ static inline __u8 inet_sk_flowi_flags(const struct sock *sk)
 	return inet_sk(sk)->transparent ? FLOWI_FLAG_ANYSRC : 0;
 }
 
+static inline void inet_rps_record_flow(const struct sock *sk)
+{
+#ifdef CONFIG_RPS
+	rps_record_sock_flow(&rps_sock_flow_table, inet_sk(sk)->rxhash);
+#endif
+}
+
+static inline void inet_rps_reset_flow(const struct sock *sk)
+{
+#ifdef CONFIG_RPS
+	rps_reset_sock_flow(&rps_sock_flow_table, inet_sk(sk)->rxhash);
+#endif
+}
+
+static inline void inet_rps_save_rxhash(const struct sock *sk, u32 rxhash)
+{
+#ifdef CONFIG_RPS
+	if (unlikely(inet_sk(sk)->rxhash != rxhash)) {
+		inet_rps_reset_flow(sk);
+		inet_sk(sk)->rxhash = rxhash;
+	}
+#endif
+}
 #endif	/* _INET_SOCK_H */
diff --git a/net/core/dev.c b/net/core/dev.c
index b98ddc6..8f4c625 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -130,6 +130,7 @@
 #include <linux/random.h>
 #include <trace/events/napi.h>
 #include <linux/pci.h>
+#include <linux/bootmem.h>
 
 #include "net-sysfs.h"
 
@@ -2202,22 +2203,28 @@ int weight_p __read_mostly = 64;            /* old backlog weight */
 DEFINE_PER_CPU(struct netif_rx_stats, netdev_rx_stat) = { 0, };
 
 #ifdef CONFIG_RPS
+/* One global table that all flow-based protocols share. */
+struct rps_sock_flow_table rps_sock_flow_table;
+EXPORT_SYMBOL(rps_sock_flow_table);
+
 /*
  * get_rps_cpu is called from netif_receive_skb and returns the target
  * CPU from the RPS map of the receiving queue for a given skb.
+ * rcu_read_lock must be held on entry.
  */
-static int get_rps_cpu(struct net_device *dev, struct sk_buff *skb)
+static int get_rps_cpu(struct net_device *dev, struct sk_buff *skb,
+		       struct rps_dev_flow **rflowp)
 {
 	struct ipv6hdr *ip6;
 	struct iphdr *ip;
 	struct netdev_rx_queue *rxqueue;
 	struct rps_map *map;
+	struct rps_dev_flow_table *flow_table;
 	int cpu = -1;
 	u8 ip_proto;
+	u16 tcpu;
 	u32 addr1, addr2, ports, ihl;
 
-	rcu_read_lock();
-
 	if (skb_rx_queue_recorded(skb)) {
 		u16 index = skb_get_rx_queue(skb);
 		if (unlikely(index >= dev->num_rx_queues)) {
@@ -2232,7 +2239,7 @@ static int get_rps_cpu(struct net_device *dev, struct sk_buff *skb)
 	} else
 		rxqueue = dev->_rx;
 
-	if (!rxqueue->rps_map)
+	if (!rxqueue->rps_map && !rxqueue->rps_flow_table)
 		goto done;
 
 	if (skb->rxhash)
@@ -2284,9 +2291,47 @@ static int get_rps_cpu(struct net_device *dev, struct sk_buff *skb)
 		skb->rxhash = 1;
 
 got_hash:
+	flow_table = rcu_dereference(rxqueue->rps_flow_table);
+	if (flow_table && rps_sock_flow_table.ents) {
+		u16 next_cpu;
+		struct rps_dev_flow *rflow;
+
+		rflow = &flow_table->flows[skb->rxhash & flow_table->mask];
+		tcpu = rflow->cpu;
+
+		next_cpu = rps_sock_flow_table.ents[skb->rxhash &
+		    rps_sock_flow_table.mask];
+
+		/*
+		 * If the desired CPU (where last recvmsg was done) is
+		 * different from current CPU (one in the rx-queue flow
+		 * table entry), switch if one of the following holds:
+		 *   - Current CPU is unset (equal to RPS_NO_CPU).
+		 *   - Current CPU is offline.
+		 *   - The current CPU's queue tail has advanced beyond the
+		 *     last packet that was enqueued using this table entry.
+		 *     This guarantees that all previous packets for the flow
+		 *     have been dequeued, thus preserving in order delivery.
+		 */
+		if (unlikely(tcpu != next_cpu) &&
+		    (tcpu == RPS_NO_CPU || !cpu_online(tcpu) ||
+		     ((int)(per_cpu(softnet_data, tcpu).input_queue_head -
+		      rflow->last_qtail)) >= 0)) {
+			tcpu = rflow->cpu = next_cpu;
+			if (tcpu != RPS_NO_CPU)
+				rflow->last_qtail = per_cpu(softnet_data,
+				    tcpu).input_queue_head;
+		}
+		if (tcpu != RPS_NO_CPU && cpu_online(tcpu)) {
+			*rflowp = rflow;
+			cpu = tcpu;
+			goto done;
+		}
+	}
+
 	map = rcu_dereference(rxqueue->rps_map);
 	if (map) {
-		u16 tcpu = map->cpus[((u64) skb->rxhash * map->len) >> 32];
+		tcpu = map->cpus[((u64) skb->rxhash * map->len) >> 32];
 
 		if (cpu_online(tcpu)) {
 			cpu = tcpu;
@@ -2295,7 +2340,6 @@ got_hash:
 	}
 
 done:
-	rcu_read_unlock();
 	return cpu;
 }
 
@@ -2321,13 +2365,14 @@ static void trigger_softirq(void *data)
 	__napi_schedule(&queue->backlog);
 	__get_cpu_var(netdev_rx_stat).received_rps++;
 }
-#endif /* CONFIG_SMP */
+#endif /* CONFIG_RPS */
 
 /*
  * enqueue_to_backlog is called to queue an skb to a per CPU backlog
  * queue (may be a remote CPU queue).
  */
-static int enqueue_to_backlog(struct sk_buff *skb, int cpu)
+static int enqueue_to_backlog(struct sk_buff *skb, int cpu,
+			      unsigned int *qtail)
 {
 	struct softnet_data *queue;
 	unsigned long flags;
@@ -2342,6 +2387,10 @@ static int enqueue_to_backlog(struct sk_buff *skb, int cpu)
 		if (queue->input_pkt_queue.qlen) {
 enqueue:
 			__skb_queue_tail(&queue->input_pkt_queue, skb);
+#ifdef CONFIG_RPS
+			*qtail = queue->input_queue_head +
+			    queue->input_pkt_queue.qlen;
+#endif
 			rps_unlock(queue);
 			local_irq_restore(flags);
 			return NET_RX_SUCCESS;
@@ -2356,11 +2405,10 @@ enqueue:
 
 				cpu_set(cpu, rcpus->mask[rcpus->select]);
 				__raise_softirq_irqoff(NET_RX_SOFTIRQ);
-			} else
-				__napi_schedule(&queue->backlog);
-#else
-			__napi_schedule(&queue->backlog);
+				goto enqueue;
+			}
 #endif
+			__napi_schedule(&queue->backlog);
 		}
 		goto enqueue;
 	}
@@ -2391,7 +2439,7 @@ enqueue:
 
 int netif_rx(struct sk_buff *skb)
 {
-	int cpu;
+	unsigned int qtail;
 
 	/* if netpoll wants it, pretend we never saw it */
 	if (netpoll_rx(skb))
@@ -2401,14 +2449,24 @@ int netif_rx(struct sk_buff *skb)
 		net_timestamp(skb);
 
 #ifdef CONFIG_RPS
-	cpu = get_rps_cpu(skb->dev, skb);
-	if (cpu < 0)
-		cpu = smp_processor_id();
-#else
-	cpu = smp_processor_id();
+	{
+		struct rps_dev_flow voidflow, *rflow = &voidflow;
+		int cpu, err;
+
+		rcu_read_lock();
+
+		cpu = get_rps_cpu(skb->dev, skb, &rflow);
+		if (cpu >= 0) {
+			err = enqueue_to_backlog(skb, cpu, &rflow->last_qtail);
+			rcu_read_unlock();
+			return err;
+		}
+
+		rcu_read_unlock();
+	}
 #endif
 
-	return enqueue_to_backlog(skb, cpu);
+	return enqueue_to_backlog(skb, smp_processor_id(), &qtail);
 }
 EXPORT_SYMBOL(netif_rx);
 
@@ -2775,17 +2833,22 @@ out:
 int netif_receive_skb(struct sk_buff *skb)
 {
 #ifdef CONFIG_RPS
-	int cpu;
+	struct rps_dev_flow voidflow, *rflow = &voidflow;
+	int cpu, err;
 
-	cpu = get_rps_cpu(skb->dev, skb);
+	rcu_read_lock();
 
-	if (cpu < 0)
-		return __netif_receive_skb(skb);
-	else
-		return enqueue_to_backlog(skb, cpu);
-#else
-	return __netif_receive_skb(skb);
+	cpu = get_rps_cpu(skb->dev, skb, &rflow);
+
+	if (cpu >= 0) {
+		err = enqueue_to_backlog(skb, cpu, &rflow->last_qtail);
+		rcu_read_unlock();
+		return err;
+	}
+
+	rcu_read_unlock();
 #endif
+	return __netif_receive_skb(skb);
 }
 EXPORT_SYMBOL(netif_receive_skb);
 
@@ -2801,6 +2864,9 @@ static void flush_backlog(void *arg)
 		if (skb->dev == dev) {
 			__skb_unlink(skb, &queue->input_pkt_queue);
 			kfree_skb(skb);
+#ifdef CONFIG_RPS
+			queue->input_queue_head++;
+#endif
 		}
 	rps_unlock(queue);
 }
@@ -3124,6 +3190,9 @@ static int process_backlog(struct napi_struct *napi, int quota)
 			local_irq_enable();
 			break;
 		}
+#ifdef CONFIG_RPS
+		queue->input_queue_head++;
+#endif
 		rps_unlock(queue);
 		local_irq_enable();
 
@@ -5487,8 +5556,12 @@ static int dev_cpu_callback(struct notifier_block *nfb,
 	local_irq_enable();
 
 	/* Process offline CPU's input_pkt_queue */
-	while ((skb = __skb_dequeue(&oldsd->input_pkt_queue)))
+	while ((skb = __skb_dequeue(&oldsd->input_pkt_queue))) {
 		netif_rx(skb);
+#ifdef CONFIG_RPS
+		oldsd->input_queue_head++;
+#endif
+	}
 
 	return NOTIFY_OK;
 }
@@ -5669,6 +5742,42 @@ static struct pernet_operations __net_initdata default_device_ops = {
 	.exit_batch = default_device_exit_batch,
 };
 
+
+#ifdef CONFIG_RPS
+static __initdata unsigned long rps_sock_flow_entries;
+
+static int __init set_rps_sock_flow_entries(char *str)
+{
+	if (str)
+		rps_sock_flow_entries = simple_strtoul(str, &str, 0);
+
+	return 0;
+}
+
+__setup("rps_flow_entries=", set_rps_sock_flow_entries);
+
+static int alloc_rps_sock_flow_entries(void)
+{
+	unsigned int i, hash_size;
+
+	if (!rps_sock_flow_entries)
+		return 0;
+
+	rps_sock_flow_table.ents =
+	    alloc_large_system_hash("RPS flow table", sizeof(u16),
+	    rps_sock_flow_entries, 0, 0, &hash_size, NULL, 0);
+	hash_size = 1 << hash_size;
+	rps_sock_flow_table.mask = hash_size - 1;
+	for (i = 0; i < hash_size; i++)
+		rps_sock_flow_table.ents[i] = RPS_NO_CPU;
+
+	printk(KERN_INFO "RPS: flow table configured with %d entries\n",
+	    hash_size);
+
+	return 0;
+}
+#endif
+
 /*
  *	Initialize the DEV module. At boot time this walks the device list and
  *	unhooks any devices that fail to initialise (normally hardware not
@@ -5689,6 +5798,11 @@ static int __init net_dev_init(void)
 	if (dev_proc_init())
 		goto out;
 
+#ifdef CONFIG_RPS
+	if (alloc_rps_sock_flow_entries())
+		goto out;
+#endif
+
 	if (netdev_kobject_init())
 		goto out;
 
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 1e7fdd6..95863b2 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -600,22 +600,105 @@ ssize_t store_rps_map(struct netdev_rx_queue *queue,
 	return len;
 }
 
+static ssize_t show_rps_dev_flow_table_cnt(struct netdev_rx_queue *queue,
+					   struct rx_queue_attribute *attr,
+					   char *buf)
+{
+	struct rps_dev_flow_table *flow_table;
+	unsigned int val = 0;
+
+	rcu_read_lock();
+	flow_table = rcu_dereference(queue->rps_flow_table);
+	if (flow_table)
+		val = flow_table->mask + 1;
+	rcu_read_unlock();
+
+	return sprintf(buf, "%u\n", val);
+}
+
+static void rps_dev_flow_table_release_work(struct work_struct *work)
+{
+	struct rps_dev_flow_table *table = container_of(work,
+	    struct rps_dev_flow_table, free_work);
+
+	vfree(table);
+}
+
+static void rps_dev_flow_table_release(struct rcu_head *rcu)
+{
+	struct rps_dev_flow_table *table = container_of(rcu,
+	    struct rps_dev_flow_table, rcu);
+
+	INIT_WORK(&table->free_work, rps_dev_flow_table_release_work);
+	schedule_work(&table->free_work);
+}
+
+ssize_t store_rps_dev_flow_table_cnt(struct netdev_rx_queue *queue,
+				     struct rx_queue_attribute *attr,
+				     const char *buf, size_t len)
+{
+	unsigned int count;
+	char *endp;
+	struct rps_dev_flow_table *table, *old_table;
+	static DEFINE_SPINLOCK(rps_dev_flow_lock);
+
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
+	count = simple_strtoul(buf, &endp, 0);
+	if (endp == buf)
+		return -EINVAL;
+
+	if (count) {
+		int i;
+
+		count = roundup_pow_of_two(count);
+		table = vmalloc(RPS_DEV_FLOW_TABLE_SIZE(count));
+		if (!table)
+			return -ENOMEM;
+
+		table->mask = count - 1;
+		for (i = 0; i < count; i++)
+			table->flows[i].cpu = RPS_NO_CPU;
+	} else
+		table = NULL;
+
+	spin_lock(&rps_dev_flow_lock);
+	old_table = queue->rps_flow_table;
+	rcu_assign_pointer(queue->rps_flow_table, table);
+	spin_unlock(&rps_dev_flow_lock);
+
+	if (old_table)
+		call_rcu(&old_table->rcu, rps_dev_flow_table_release);
+
+	return len;
+}
+
 static struct rx_queue_attribute rps_cpus_attribute =
 	__ATTR(rps_cpus, S_IRUGO | S_IWUSR, show_rps_map, store_rps_map);
 
+
+static struct rx_queue_attribute rps_dev_flow_table_cnt_attribute =
+	__ATTR(rps_flow_cnt, S_IRUGO | S_IWUSR,
+	    show_rps_dev_flow_table_cnt, store_rps_dev_flow_table_cnt);
+
 static struct attribute *rx_queue_default_attrs[] = {
 	&rps_cpus_attribute.attr,
+	&rps_dev_flow_table_cnt_attribute.attr,
 	NULL
 };
 
 static void rx_queue_release(struct kobject *kobj)
 {
 	struct netdev_rx_queue *queue = to_rx_queue(kobj);
-	struct rps_map *map = queue->rps_map;
 	struct netdev_rx_queue *first = queue->first;
 
-	if (map)
-		call_rcu(&map->rcu, rps_map_release);
+	if (queue->rps_map)
+		call_rcu(&queue->rps_map->rcu, rps_map_release);
+
+	if (queue->rps_flow_table)
+		call_rcu(&queue->rps_flow_table->rcu,
+		    rps_dev_flow_table_release);
 
 	if (atomic_dec_and_test(&first->count))
 		kfree(first);
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 55e1190..eb6155a 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -418,6 +418,8 @@ int inet_release(struct socket *sock)
 	if (sk) {
 		long timeout;
 
+		inet_rps_reset_flow(sk);
+
 		/* Applications forget to leave groups before exiting */
 		ip_mc_drop_socket(sk);
 
@@ -714,6 +716,8 @@ int inet_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
 {
 	struct sock *sk = sock->sk;
 
+	inet_rps_record_flow(sk);
+
 	/* We may need to bind the socket. */
 	if (!inet_sk(sk)->inet_num && inet_autobind(sk))
 		return -EAGAIN;
@@ -722,12 +726,13 @@ int inet_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
 }
 EXPORT_SYMBOL(inet_sendmsg);
 
-
 static ssize_t inet_sendpage(struct socket *sock, struct page *page, int offset,
 			     size_t size, int flags)
 {
 	struct sock *sk = sock->sk;
 
+	inet_rps_record_flow(sk);
+
 	/* We may need to bind the socket. */
 	if (!inet_sk(sk)->inet_num && inet_autobind(sk))
 		return -EAGAIN;
@@ -737,6 +742,22 @@ static ssize_t inet_sendpage(struct socket *sock, struct page *page, int offset,
 	return sock_no_sendpage(sock, page, offset, size, flags);
 }
 
+int inet_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
+		 size_t size, int flags)
+{
+	struct sock *sk = sock->sk;
+	int addr_len = 0;
+	int err;
+
+	inet_rps_record_flow(sk);
+
+	err = sk->sk_prot->recvmsg(iocb, sk, msg, size, flags & MSG_DONTWAIT,
+				   flags & ~MSG_DONTWAIT, &addr_len);
+	if (err >= 0)
+		msg->msg_namelen = addr_len;
+	return err;
+}
+EXPORT_SYMBOL(inet_recvmsg);
 
 int inet_shutdown(struct socket *sock, int how)
 {
@@ -866,7 +887,7 @@ const struct proto_ops inet_stream_ops = {
 	.setsockopt	   = sock_common_setsockopt,
 	.getsockopt	   = sock_common_getsockopt,
 	.sendmsg	   = tcp_sendmsg,
-	.recvmsg	   = sock_common_recvmsg,
+	.recvmsg	   = inet_recvmsg,
 	.mmap		   = sock_no_mmap,
 	.sendpage	   = tcp_sendpage,
 	.splice_read	   = tcp_splice_read,
@@ -893,7 +914,7 @@ const struct proto_ops inet_dgram_ops = {
 	.setsockopt	   = sock_common_setsockopt,
 	.getsockopt	   = sock_common_getsockopt,
 	.sendmsg	   = inet_sendmsg,
-	.recvmsg	   = sock_common_recvmsg,
+	.recvmsg	   = inet_recvmsg,
 	.mmap		   = sock_no_mmap,
 	.sendpage	   = inet_sendpage,
 #ifdef CONFIG_COMPAT
@@ -923,7 +944,7 @@ static const struct proto_ops inet_sockraw_ops = {
 	.setsockopt	   = sock_common_setsockopt,
 	.getsockopt	   = sock_common_getsockopt,
 	.sendmsg	   = inet_sendmsg,
-	.recvmsg	   = sock_common_recvmsg,
+	.recvmsg	   = inet_recvmsg,
 	.mmap		   = sock_no_mmap,
 	.sendpage	   = inet_sendpage,
 #ifdef CONFIG_COMPAT
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index f4df5f9..2f40fe0 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1674,6 +1674,8 @@ process:
 
 	skb->dev = NULL;
 
+	inet_rps_save_rxhash(sk, skb->rxhash);
+
 	bh_lock_sock_nested(sk);
 	ret = 0;
 	if (!sock_owned_by_user(sk)) {
