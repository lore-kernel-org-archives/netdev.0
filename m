From: Rusty Russell <rusty@rustcorp.com.au>
Subject: [PATCH, untested] Support for PPPOE on SMP
Date: Wed, 25 Jun 2003 17:24:22 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030625072602.529AF2C0B9@lists.samba.org>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, paulus@samba.org
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Paul Mackerras says PPPoE relies on receiving packets in wire order,
and he has bug reports caused by packet reordering.

This is icky.  Example code below:
1) Extract core queuing part of netif_rx into __netif_rx.

2) If the protocol is requires serialization, packets are put on a
   global "serial" queue instead of the local queue.  (Which protocols
   currently hardcoded).

3) One cpu (boot cpu as it happens) drains this serial queue, so it
   stays ordered.

4) Fix bug in cpu_raise_softirq: need to wake softirqd if it's a
   different cpu.

Another option would simply be to stamp a serialization number into
the skb if the proto needs serialization, and drop packets if serial
number goes backwards.  But since this is actually happening to
people, that would suck, too.

I don't understand the unbalanced dev_put in net_rx_action(), BTW.

Cheers,
Rusty.

diff -urpN --exclude TAGS -X /home/rusty/devel/kernel/kernel-patches/current-dontdiff --minimal linux-2.5.72-bk2/kernel/softirq.c working-2.5.72-bk2-serial-protocols/kernel/softirq.c
--- linux-2.5.72-bk2/kernel/softirq.c	2003-06-25 17:17:19.000000000 +1000
+++ working-2.5.72-bk2-serial-protocols/kernel/softirq.c	2003-06-25 14:55:15.000000000 +1000
@@ -130,7 +130,7 @@ inline void cpu_raise_softirq(unsigned i
 	 * Otherwise we wake up ksoftirqd to make sure we
 	 * schedule the softirq soon.
 	 */
-	if (!in_interrupt())
+	if (!in_interrupt() || cpu != smp_processor_id())
 		wakeup_softirqd(cpu);
 }
 
diff -urpN --exclude TAGS -X /home/rusty/devel/kernel/kernel-patches/current-dontdiff --minimal linux-2.5.72-bk2/net/core/dev.c working-2.5.72-bk2-serial-protocols/net/core/dev.c
--- linux-2.5.72-bk2/net/core/dev.c	2003-06-20 11:53:36.000000000 +1000
+++ working-2.5.72-bk2-serial-protocols/net/core/dev.c	2003-06-25 17:11:36.000000000 +1000
@@ -1323,42 +1323,11 @@ static void sample_queue(unsigned long d
 }
 #endif
 
-
-/**
- *	netif_rx	-	post buffer to the network code
- *	@skb: buffer to post
- *
- *	This function receives a packet from a device driver and queues it for
- *	the upper (protocol) levels to process.  It always succeeds. The buffer
- *	may be dropped during processing for congestion control or by the
- *	protocol layers.
- *
- *	return values:
- *	NET_RX_SUCCESS	(no congestion)
- *	NET_RX_CN_LOW   (low congestion)
- *	NET_RX_CN_MOD   (moderate congestion)
- *	NET_RX_CN_HIGH  (high congestion)
- *	NET_RX_DROP     (packet was dropped)
- *
- */
-
-int netif_rx(struct sk_buff *skb)
+/* Called with IRQs disabled. */
+static inline int __netif_rx(int this_cpu,
+			     struct softnet_data *queue,
+			     struct sk_buff *skb)
 {
-	int this_cpu;
-	struct softnet_data *queue;
-	unsigned long flags;
-
-	if (!skb->stamp.tv_sec)
-		do_gettimeofday(&skb->stamp);
-
-	/*
-	 * The code is rearranged so that the path is the most
-	 * short when CPU is congested, but is still operating.
-	 */
-	local_irq_save(flags);
-	this_cpu = smp_processor_id();
-	queue = &softnet_data[this_cpu];
-
 	netdev_rx_stat[this_cpu].total++;
 	if (queue->input_pkt_queue.qlen <= netdev_max_backlog) {
 		if (queue->input_pkt_queue.qlen) {
@@ -1371,7 +1340,6 @@ enqueue:
 #ifndef OFFLINE_SAMPLE
 			get_sample_stats(this_cpu);
 #endif
-			local_irq_restore(flags);
 			return queue->cng_level;
 		}
 
@@ -1397,12 +1365,116 @@ enqueue:
 
 drop:
 	netdev_rx_stat[this_cpu].dropped++;
-	local_irq_restore(flags);
 
 	kfree_skb(skb);
 	return NET_RX_DROP;
 }
 
+#ifdef CONFIG_SMP
+/* Queue for serial protocols (eg PPPoe).  All handled by one CPU. */
+static spinlock_t serial_queue_lock = SPIN_LOCK_UNLOCKED;
+static struct softnet_data serial_queue;
+
+/* Which cpu does serial queue. */
+static int serial_cpu;
+
+static inline int net_proto_serialize(struct sk_buff *skb,
+				      int this_cpu, 
+				      int *ret)
+{
+	if (likely(skb->protocol != ETH_P_PPP_DISC 
+		   && skb->protocol != ETH_P_PPP_SES))
+		return 0;
+
+	spin_lock(&serial_queue_lock);
+	*ret = __netif_rx(this_cpu, &serial_queue, skb);
+	spin_unlock(&serial_queue_lock);
+	if (this_cpu != serial_cpu)
+		cpu_raise_softirq(serial_cpu, NET_RX_SOFTIRQ);
+	return 1;
+}
+
+static void init_queue(struct softnet_data *queue);
+
+static void init_serial(void)
+{
+	init_queue(&serial_queue);
+	serial_cpu = smp_processor_id();
+}
+
+static inline void drain_serial_queue(int this_cpu)
+{
+	if (this_cpu != serial_cpu)
+		return;
+
+	spin_lock(&serial_queue_lock);
+	while (!list_empty(&serial_queue.poll_list)) {
+		struct net_device *dev;
+
+		dev = list_entry(serial_queue.poll_list.next,
+				 struct net_device, poll_list);
+
+		list_del(&dev->poll_list);
+		list_add_tail(&dev->poll_list, &serial_queue.poll_list);
+	}
+	spin_unlock(&serial_queue_lock);
+}
+#else
+static inline int net_proto_serialize(struct sk_buff *skb,
+				      int this_cpu,
+				      int *ret)
+{
+	return 0;
+}
+
+static void init_serial(void)
+{
+}
+
+static inline void drain_serial_queue(int this_cpu)
+{
+}
+#endif /* CONFIG_SMP */
+
+/**
+ *	netif_rx	-	post buffer to the network code
+ *	@skb: buffer to post
+ *
+ *	This function receives a packet from a device driver and queues it for
+ *	the upper (protocol) levels to process.  It always succeeds. The buffer
+ *	may be dropped during processing for congestion control or by the
+ *	protocol layers.
+ *
+ *	return values:
+ *	NET_RX_SUCCESS	(no congestion)
+ *	NET_RX_CN_LOW   (low congestion)
+ *	NET_RX_CN_MOD   (moderate congestion)
+ *	NET_RX_CN_HIGH  (high congestion)
+ *	NET_RX_DROP     (packet was dropped)
+ *
+ */
+
+int netif_rx(struct sk_buff *skb)
+{
+	int ret, this_cpu;
+	unsigned long flags;
+
+	if (!skb->stamp.tv_sec)
+		do_gettimeofday(&skb->stamp);
+
+	/*
+	 * The code is rearranged so that the path is the most
+	 * short when CPU is congested, but is still operating.
+	 */
+	local_irq_save(flags);
+	this_cpu = smp_processor_id();
+
+	if (!net_proto_serialize(skb, this_cpu, &ret))
+		ret = __netif_rx(this_cpu, &softnet_data[this_cpu], skb);
+	local_irq_restore(flags);
+	return ret;
+}
+
 /* Deliver skb to an old protocol, which is not threaded well
    or which do not understand shared skbs.
  */
@@ -1705,6 +1777,8 @@ static void net_rx_action(struct softirq
 			local_irq_disable();
 		}
 	}
+
+	drain_serial_queue(this_cpu);
 out:
 	local_irq_enable();
 	preempt_enable();
@@ -2944,6 +3018,20 @@ int unregister_netdevice(struct net_devi
 }
 
 
+static void init_queue(struct softnet_data *queue)
+{
+	skb_queue_head_init(&queue->input_pkt_queue);
+	queue->throttle = 0;
+	queue->cng_level = 0;
+	queue->avg_blog = 10; /* arbitrary non-zero */
+	queue->completion_queue = NULL;
+	INIT_LIST_HEAD(&queue->poll_list);
+	set_bit(__LINK_STATE_START, &queue->backlog_dev.state);
+	queue->backlog_dev.weight = weight_p;
+	queue->backlog_dev.poll = process_backlog;
+	atomic_set(&queue->backlog_dev.refcnt, 1);
+}
+
 /*
  *	Initialize the DEV module. At boot time this walks the device list and
  *	unhooks any devices that fail to initialise (normally hardware not
@@ -2976,21 +3064,9 @@ static int __init net_dev_init(void)
 	 *	Initialise the packet receive queues.
 	 */
 
-	for (i = 0; i < NR_CPUS; i++) {
-		struct softnet_data *queue;
-
-		queue = &softnet_data[i];
-		skb_queue_head_init(&queue->input_pkt_queue);
-		queue->throttle = 0;
-		queue->cng_level = 0;
-		queue->avg_blog = 10; /* arbitrary non-zero */
-		queue->completion_queue = NULL;
-		INIT_LIST_HEAD(&queue->poll_list);
-		set_bit(__LINK_STATE_START, &queue->backlog_dev.state);
-		queue->backlog_dev.weight = weight_p;
-		queue->backlog_dev.poll = process_backlog;
-		atomic_set(&queue->backlog_dev.refcnt, 1);
-	}
+	for (i = 0; i < NR_CPUS; i++)
+		init_queue(&softnet_data[i]);
+	init_serial();
 
 #ifdef CONFIG_NET_PROFILE
 	net_profile_init();
--
  Anyone who quotes me in their sig is an idiot. -- Rusty Russell.
