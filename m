From: Tom Herbert <therbert@google.com>
Subject: [PATCH v4] rfs: Receive Flow Steering
Date: Mon, 12 Apr 2010 17:03:39 -0700 (PDT)
Message-ID: <alpine.DEB.1.00.1004121651460.31468@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org, eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:9420 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754333Ab0DMADu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Apr 2010 20:03:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Version 4 of RFS:
- Use a mutex in rps_sock_flow_sysctl for mutual exclusion between
concurrent writers and allows calling vmalloc.
- Removed extra space before "rc = sock_queue_rcv_skb(sk, skb);"
- Make changelog < 70 chars
- Ensure calls to smp_processor_id in netif_rx are called in
non-preemptable region
---
This patch implements receive flow steering (RFS).  RFS steers
received packets for layer 3 and 4 processing to the CPU where
the application for the corresponding flow is running.  RFS is an
extension of Receive Packet Steering (RPS).

The basic idea of RFS is that when an application calls recvmsg
(or sendmsg) the application's running CPU is stored in a hash
table that is indexed by the connection's rxhash which is stored in
the socket structure.  The rxhash is passed in skb's received on
the connection from netif_receive_skb.  For each received packet,
the associated rxhash is used to look up the CPU in the hash table,
if a valid CPU is set then the packet is steered to that CPU using
the RPS mechanisms.

The convolution of the simple approach is that it would potentially
allow OOO packets.  If threads are thrashing around CPUs or multiple
threads are trying to read from the same sockets, a quickly changing
CPU value in the hash table could cause rampant OOO packets--
we consider this a non-starter.

To avoid OOO packets, this solution implements two types of hash
tables: rps_sock_flow_table and rps_dev_flow_table.

rps_sock_table is a global hash table.  Each entry is just a CPU
number and it is populated in recvmsg and sendmsg as described above.
This table contains the "desired" CPUs for flows.

rps_dev_flow_table is specific to each device queue.  Each entry
contains a CPU and a tail queue counter.  The CPU is the "current"
CPU for a matching flow.  The tail queue counter holds the value
of a tail queue counter for the associated CPU's backlog queue at
the time of last enqueue for a flow matching the entry.

Each backlog queue has a queue head counter which is incremented
on dequeue, and so a queue tail counter is computed as queue head
count + queue length.  When a packet is enqueued on a backlog queue,
the current value of the queue tail counter is saved in the hash
entry of the rps_dev_flow_table.

And now the trick: when selecting the CPU for RPS (get_rps_cpu)
the rps_sock_flow table and the rps_dev_flow table for the RX queue
are consulted.  When the desired CPU for the flow (found in the
rps_sock_flow table) does not match the current CPU (found in the
rps_dev_flow table), the current CPU is changed to the desired CPU
if one of the following is true:

- The current CPU is unset (equal to RPS_NO_CPU)
- Current CPU is offline
- The current CPU's queue head counter >= queue tail counter in the
rps_dev_flow table.  This checks if the queue tail has advanced
beyond the last packet that was enqueued using this table entry.
This guarantees that all packets queued using this entry have been
dequeued, thus preserving in order delivery.

Making each queue have its own rps_dev_flow table has two advantages:
1) the tail queue counters will be written on each receive, so
keeping the table local to interrupting CPU s good for locality.  2)
this allows lockless access to the table-- the CPU number and queue
tail counter need to be accessed together under mutual exclusion
from netif_receive_skb, we assume that this is only called from
device napi_poll which is non-reentrant.

This patch implements RFS for TCP and connected UDP sockets.
It should be usable for other flow oriented protocols.

There are two configuration parameters for RFS.  The
"rps_flow_entries" kernel init parameter sets the number of
entries in the rps_sock_flow_table, the per rxqueue sysfs entry
"rps_flow_cnt" contains the number of entries in the rps_dev_flow
table for the rxqueue.  Both are rounded to power of two.

The obvious benefit of RFS (over just RPS) is that it achieves
CPU locality between the receive processing for a flow and the
applications processing; this can result in increased performance
(higher pps, lower latency).

The benefits of RFS are dependent on cache hierarchy, application
load, and other factors.  On simple benchmarks, we don't necessarily
see improvement and sometimes see degradation.  However, for more
complex benchmarks and for applications where cache pressure is
much higher this technique seems to perform very well.

Below are some benchmark results which show the potential benfit of
this patch.  The netperf test has 500 instances of netperf TCP_RR
test with 1 byte req. and resp.  The RPC test is an request/response
test similar in structure to netperf RR test ith 100 threads on
each host, but does more work in userspace that netperf.

e1000e on 8 core Intel
   No RFS or RPS		104K tps at 30% CPU
   No RFS (best RPS config):    290K tps at 63% CPU
   RFS				303K tps at 61% CPU

RPC test	tps	CPU%	50/90/99% usec latency	Latency StdDev
  No RFS/RPS	103K	48%	757/900/3185		4472.35
  RPS only:	174K	73%	415/993/2468		491.66
  RFS		223K	73%	379/651/1382		315.61

Signed-off-by: Tom Herbert <therbert@google.com> ---
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index d1a21b5..573e775 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -530,14 +530,77 @@ struct rps_map {
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
+	u16 ents[0];
+};
+#define	RPS_SOCK_FLOW_TABLE_SIZE(_num) (sizeof(struct rps_sock_flow_table) + \
+    (_num * sizeof(u16)))
+
+extern int rps_sock_flow_sysctl(ctl_table *table, int write,
+				void __user *buffer, size_t *lenp,
+				loff_t *ppos);
+
+#define RPS_NO_CPU 0xffff
+
+static inline void rps_record_sock_flow(struct rps_sock_flow_table *table,
+					u32 hash)
+{
+	if (table && hash) {
+		unsigned int cpu, index = hash & table->mask;
+
+		/* We only give a hint, preemption can change cpu under us */
+		cpu = raw_smp_processor_id();
+
+		if (table->ents[index] != cpu)
+			table->ents[index] = cpu;
+	}
+}
+
+static inline void rps_reset_sock_flow(struct rps_sock_flow_table *table,
+				       u32 hash)
+{
+	if (table && hash)
+		table->ents[hash & table->mask] = RPS_NO_CPU;
+}
+
+extern struct rps_sock_flow_table *rps_sock_flow_table;
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
@@ -1331,13 +1394,21 @@ struct softnet_data {
 	struct sk_buff		*completion_queue;
 
 	/* Elements below can be accessed between CPUs for RPS */
-#ifdef CONFIG_SMP
+#ifdef CONFIG_RPS
 	struct call_single_data	csd ____cacheline_aligned_in_smp;
+	unsigned int		input_queue_head;
 #endif
 	struct sk_buff_head	input_pkt_queue;
 	struct napi_struct	backlog;
 };
 
+static inline void incr_input_queue_head(struct softnet_data *queue)
+{
+#ifdef CONFIG_RPS
+	queue->input_queue_head++;
+#endif
+}
+
 DECLARE_PER_CPU_ALIGNED(struct softnet_data, softnet_data);
 
 #define HAVE_NETIF_QUEUE
diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index 83fd344..b487bc1 100644
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
@@ -219,4 +224,37 @@ static inline __u8 inet_sk_flowi_flags(const struct sock *sk)
 	return inet_sk(sk)->transparent ? FLOWI_FLAG_ANYSRC : 0;
 }
 
+static inline void inet_rps_record_flow(const struct sock *sk)
+{
+#ifdef CONFIG_RPS
+	struct rps_sock_flow_table *sock_flow_table;
+
+	rcu_read_lock();
+	sock_flow_table = rcu_dereference(rps_sock_flow_table);
+	rps_record_sock_flow(sock_flow_table, inet_sk(sk)->rxhash);
+	rcu_read_unlock();
+#endif
+}
+
+static inline void inet_rps_reset_flow(const struct sock *sk)
+{
+#ifdef CONFIG_RPS
+	struct rps_sock_flow_table *sock_flow_table;
+
+	rcu_read_lock();
+	sock_flow_table = rcu_dereference(rps_sock_flow_table);
+	rps_reset_sock_flow(sock_flow_table, inet_sk(sk)->rxhash);
+	rcu_read_unlock();
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
index a10a216..7dbe64e 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2203,22 +2203,81 @@ int weight_p __read_mostly = 64;            /* old backlog weight */
 DEFINE_PER_CPU(struct netif_rx_stats, netdev_rx_stat) = { 0, };
 
 #ifdef CONFIG_RPS
+/* One global table that all flow-based protocols share. */
+struct rps_sock_flow_table *rps_sock_flow_table;
+EXPORT_SYMBOL(rps_sock_flow_table);
+
+int rps_sock_flow_sysctl(ctl_table *table, int write, void __user *buffer,
+			 size_t *lenp, loff_t *ppos)
+{
+	unsigned int orig_size, size;
+	int ret, i;
+	ctl_table tmp = {
+		.data = &size,
+		.maxlen = sizeof(size),
+		.mode = table->mode
+	};
+	struct rps_sock_flow_table *orig_sock_table, *sock_table;
+	static DEFINE_MUTEX(sock_flow_mutex);
+
+	mutex_lock(&sock_flow_mutex);
+
+	orig_sock_table = rps_sock_flow_table;
+	size = orig_size = orig_sock_table ? orig_sock_table->mask + 1 : 0;
+
+	ret = proc_dointvec(&tmp, write, buffer, lenp, ppos);
+
+	if (write) {
+		if (size) {
+			size = roundup_pow_of_two(size);
+			if (size != orig_size) {
+				sock_table =
+				    vmalloc(RPS_SOCK_FLOW_TABLE_SIZE(size));
+				if (!sock_table) {
+					mutex_unlock(&sock_flow_mutex);
+					return -ENOMEM;
+				}
+
+				sock_table->mask = size - 1;
+			} else
+				sock_table = orig_sock_table;
+
+			for (i = 0; i < size; i++)
+				sock_table->ents[i] = RPS_NO_CPU;
+		} else
+			sock_table = NULL;
+
+		if (sock_table != orig_sock_table) {
+			rcu_assign_pointer(rps_sock_flow_table, sock_table);
+			synchronize_rcu();
+			vfree(orig_sock_table);
+		}
+	}
+
+	mutex_unlock(&sock_flow_mutex);
+
+	return ret;
+}
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
+	struct rps_sock_flow_table *sock_flow_table;
 	int cpu = -1;
 	u8 ip_proto;
+	u16 tcpu;
 	u32 addr1, addr2, ports, ihl;
 
-	rcu_read_lock();
-
 	if (skb_rx_queue_recorded(skb)) {
 		u16 index = skb_get_rx_queue(skb);
 		if (unlikely(index >= dev->num_rx_queues)) {
@@ -2233,7 +2292,7 @@ static int get_rps_cpu(struct net_device *dev, struct sk_buff *skb)
 	} else
 		rxqueue = dev->_rx;
 
-	if (!rxqueue->rps_map)
+	if (!rxqueue->rps_map && !rxqueue->rps_flow_table)
 		goto done;
 
 	if (skb->rxhash)
@@ -2285,9 +2344,48 @@ static int get_rps_cpu(struct net_device *dev, struct sk_buff *skb)
 		skb->rxhash = 1;
 
 got_hash:
+	flow_table = rcu_dereference(rxqueue->rps_flow_table);
+	sock_flow_table = rcu_dereference(rps_sock_flow_table);
+	if (flow_table && sock_flow_table) {
+		u16 next_cpu;
+		struct rps_dev_flow *rflow;
+
+		rflow = &flow_table->flows[skb->rxhash & flow_table->mask];
+		tcpu = rflow->cpu;
+
+		next_cpu = sock_flow_table->ents[skb->rxhash &
+		    sock_flow_table->mask];
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
@@ -2296,7 +2394,6 @@ got_hash:
 	}
 
 done:
-	rcu_read_unlock();
 	return cpu;
 }
 
@@ -2322,13 +2419,14 @@ static void trigger_softirq(void *data)
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
@@ -2343,6 +2441,10 @@ static int enqueue_to_backlog(struct sk_buff *skb, int cpu)
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
@@ -2357,11 +2459,10 @@ enqueue:
 
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
@@ -2392,7 +2493,8 @@ enqueue:
 
 int netif_rx(struct sk_buff *skb)
 {
-	int cpu;
+	unsigned int qtail;
+	int err;
 
 	/* if netpoll wants it, pretend we never saw it */
 	if (netpoll_rx(skb))
@@ -2402,14 +2504,26 @@ int netif_rx(struct sk_buff *skb)
 		net_timestamp(skb);
 
 #ifdef CONFIG_RPS
-	cpu = get_rps_cpu(skb->dev, skb);
-	if (cpu < 0)
-		cpu = smp_processor_id();
+	{
+		struct rps_dev_flow voidflow, *rflow = &voidflow;
+		int cpu;
+
+		rcu_read_lock();
+
+		cpu = get_rps_cpu(skb->dev, skb, &rflow);
+		if (cpu < 0)
+			cpu = smp_processor_id();
+
+		err = enqueue_to_backlog(skb, cpu, &rflow->last_qtail);
+
+		rcu_read_unlock();
+	}
 #else
-	cpu = smp_processor_id();
+	preempt_disable();
+	err = enqueue_to_backlog(skb, smp_processor_id(), &qtail);
+	preempt_enable();
 #endif
-
-	return enqueue_to_backlog(skb, cpu);
+	return err;
 }
 EXPORT_SYMBOL(netif_rx);
 
@@ -2776,17 +2890,22 @@ out:
 int netif_receive_skb(struct sk_buff *skb)
 {
 #ifdef CONFIG_RPS
-	int cpu;
+	struct rps_dev_flow voidflow, *rflow = &voidflow;
+	int cpu, err;
+
+	rcu_read_lock();
 
-	cpu = get_rps_cpu(skb->dev, skb);
+	cpu = get_rps_cpu(skb->dev, skb, &rflow);
 
-	if (cpu < 0)
-		return __netif_receive_skb(skb);
-	else
-		return enqueue_to_backlog(skb, cpu);
-#else
-	return __netif_receive_skb(skb);
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
 
@@ -2802,6 +2921,7 @@ static void flush_backlog(void *arg)
 		if (skb->dev == dev) {
 			__skb_unlink(skb, &queue->input_pkt_queue);
 			kfree_skb(skb);
+			incr_input_queue_head(queue);
 		}
 	rps_unlock(queue);
 }
@@ -3125,6 +3245,7 @@ static int process_backlog(struct napi_struct *napi, int quota)
 			local_irq_enable();
 			break;
 		}
+		incr_input_queue_head(queue);
 		rps_unlock(queue);
 		local_irq_enable();
 
@@ -5488,8 +5609,10 @@ static int dev_cpu_callback(struct notifier_block *nfb,
 	local_irq_enable();
 
 	/* Process offline CPU's input_pkt_queue */
-	while ((skb = __skb_dequeue(&oldsd->input_pkt_queue)))
+	while ((skb = __skb_dequeue(&oldsd->input_pkt_queue))) {
 		netif_rx(skb);
+		incr_input_queue_head(oldsd);
+	}
 
 	return NOTIFY_OK;
 }
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 96ed690..e518bee 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -601,22 +601,105 @@ ssize_t store_rps_map(struct netdev_rx_queue *queue,
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
diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
index b7b6b82..9eb2f67 100644
--- a/net/core/sysctl_net_core.c
+++ b/net/core/sysctl_net_core.c
@@ -82,6 +82,14 @@ static struct ctl_table net_core_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
+#ifdef CONFIG_RPS
+	{
+		.procname	= "rps_sock_flow_entries",
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= rps_sock_flow_sysctl
+	},
+#endif
 #endif /* CONFIG_NET */
 	{
 		.procname	= "netdev_budget",
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index a0beb32..3703b5e 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -419,6 +419,8 @@ int inet_release(struct socket *sock)
 	if (sk) {
 		long timeout;
 
+		inet_rps_reset_flow(sk);
+
 		/* Applications forget to leave groups before exiting */
 		ip_mc_drop_socket(sk);
 
@@ -720,6 +722,8 @@ int inet_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
 {
 	struct sock *sk = sock->sk;
 
+	inet_rps_record_flow(sk);
+
 	/* We may need to bind the socket. */
 	if (!inet_sk(sk)->inet_num && inet_autobind(sk))
 		return -EAGAIN;
@@ -728,12 +732,13 @@ int inet_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
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
@@ -743,6 +748,22 @@ static ssize_t inet_sendpage(struct socket *sock, struct page *page, int offset,
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
@@ -872,7 +893,7 @@ const struct proto_ops inet_stream_ops = {
 	.setsockopt	   = sock_common_setsockopt,
 	.getsockopt	   = sock_common_getsockopt,
 	.sendmsg	   = tcp_sendmsg,
-	.recvmsg	   = sock_common_recvmsg,
+	.recvmsg	   = inet_recvmsg,
 	.mmap		   = sock_no_mmap,
 	.sendpage	   = tcp_sendpage,
 	.splice_read	   = tcp_splice_read,
@@ -899,7 +920,7 @@ const struct proto_ops inet_dgram_ops = {
 	.setsockopt	   = sock_common_setsockopt,
 	.getsockopt	   = sock_common_getsockopt,
 	.sendmsg	   = inet_sendmsg,
-	.recvmsg	   = sock_common_recvmsg,
+	.recvmsg	   = inet_recvmsg,
 	.mmap		   = sock_no_mmap,
 	.sendpage	   = inet_sendpage,
 #ifdef CONFIG_COMPAT
@@ -929,7 +950,7 @@ static const struct proto_ops inet_sockraw_ops = {
 	.setsockopt	   = sock_common_setsockopt,
 	.getsockopt	   = sock_common_getsockopt,
 	.sendmsg	   = inet_sendmsg,
-	.recvmsg	   = sock_common_recvmsg,
+	.recvmsg	   = inet_recvmsg,
 	.mmap		   = sock_no_mmap,
 	.sendpage	   = inet_sendpage,
 #ifdef CONFIG_COMPAT
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index a24995c..ad08392 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1672,6 +1672,8 @@ process:
 
 	skb->dev = NULL;
 
+	inet_rps_save_rxhash(sk, skb->rxhash);
+
 	bh_lock_sock_nested(sk);
 	ret = 0;
 	if (!sock_owned_by_user(sk)) {
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 8fef859..666b963 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1217,6 +1217,7 @@ int udp_disconnect(struct sock *sk, int flags)
 	sk->sk_state = TCP_CLOSE;
 	inet->inet_daddr = 0;
 	inet->inet_dport = 0;
+	inet_rps_save_rxhash(sk, 0);
 	sk->sk_bound_dev_if = 0;
 	if (!(sk->sk_userlocks & SOCK_BINDADDR_LOCK))
 		inet_reset_saddr(sk);
@@ -1258,8 +1259,12 @@ EXPORT_SYMBOL(udp_lib_unhash);
 
 static int __udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 {
-	int rc = sock_queue_rcv_skb(sk, skb);
+	int rc;
+
+	if (inet_sk(sk)->inet_daddr)
+		inet_rps_save_rxhash(sk, skb->rxhash);
 
+	rc = sock_queue_rcv_skb(sk, skb);
 	if (rc < 0) {
 		int is_udplite = IS_UDPLITE(sk);
 
