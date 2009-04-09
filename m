From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Software receive packet steering
Date: Wed, 08 Apr 2009 17:36:07 -0700 (PDT)
Message-ID: <20090408.173607.177460759.davem@davemloft.net>
References: <65634d660904081548g7ea3e3bfn858f2336db9a671f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38421
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756070AbZDIAgR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2009 20:36:17 -0400
In-Reply-To: <65634d660904081548g7ea3e3bfn858f2336db9a671f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Wed, 8 Apr 2009 15:48:12 -0700

> +#ifdef CONFIG_NET_SOFTRPS
> +	int			rps_cpu;
> +	struct list_head	rps_poll_list;
> +	spinlock_t		rps_poll_list_lock;
> +	struct call_single_data	rps_csd;
> +	unsigned long		rps_flags;
> +#define RPS_SOFTIRQ_PENDING	0x1
> +#define RPS_SOFTIRQ_COMPLETING	0x2
> +#endif

Have you seen my patch that does this with remote softirqs?
Then you don't need a lock for the list, it can be lockless
since only the local processor ever accesses the list.

In fact, it kills the per-cpu backlog completely, everything
takes the netif_receive_skb() path and shoots the packet to
the remote cpu.

Here is that patch, for reference.  It won't apply to anything
recent but all the ideas are there.

Another thing I don't like about your patch is that the behavior is
controlled by a config option.  That's pretty worthless for upstream,
if the feature is useful every distribution on the planet is going to
enable the config option.  So better integration as a core and
always-enabled feature, as well as a way for it to play nice with
hardware RX multiqueue are pretty stern requirements.

net: Do software flow seperation on receive.

Push netif_receive_skb() work to remote cpus via flow
hashing and remote softirqs.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/interrupt.h |    1 +
 include/linux/netdevice.h |    2 -
 include/linux/skbuff.h    |    3 +
 net/core/dev.c            |  273 +++++++++++++++++++++++++--------------------
 4 files changed, 157 insertions(+), 122 deletions(-)

diff --git a/include/linux/interrupt.h b/include/linux/interrupt.h
index 806b38f..223e68f 100644
--- a/include/linux/interrupt.h
+++ b/include/linux/interrupt.h
@@ -247,6 +247,7 @@ enum
 	TIMER_SOFTIRQ,
 	NET_TX_SOFTIRQ,
 	NET_RX_SOFTIRQ,
+	NET_RECEIVE_SOFTIRQ,
 	BLOCK_SOFTIRQ,
 	TASKLET_SOFTIRQ,
 	SCHED_SOFTIRQ,
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 488c56e..a044caa 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -965,11 +965,9 @@ static inline int unregister_gifconf(unsigned int family)
 struct softnet_data
 {
 	struct Qdisc		*output_queue;
-	struct sk_buff_head	input_pkt_queue;
 	struct list_head	poll_list;
 	struct sk_buff		*completion_queue;
 
-	struct napi_struct	backlog;
 #ifdef CONFIG_NET_DMA
 	struct dma_chan		*net_dma;
 #endif
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 9099237..e36bc86 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -18,6 +18,7 @@
 #include <linux/compiler.h>
 #include <linux/time.h>
 #include <linux/cache.h>
+#include <linux/smp.h>
 
 #include <asm/atomic.h>
 #include <asm/types.h>
@@ -255,6 +256,8 @@ struct sk_buff {
 	struct sk_buff		*next;
 	struct sk_buff		*prev;
 
+	struct call_single_data	csd;
+
 	struct sock		*sk;
 	ktime_t			tstamp;
 	struct net_device	*dev;
diff --git a/net/core/dev.c b/net/core/dev.c
index e719ed2..09827c7 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1660,8 +1660,8 @@ out_kfree_skb:
 	return 0;
 }
 
-static u32 simple_tx_hashrnd;
-static int simple_tx_hashrnd_initialized = 0;
+static u32 simple_hashrnd;
+static int simple_hashrnd_initialized = 0;
 
 static u16 simple_tx_hash(struct net_device *dev, struct sk_buff *skb)
 {
@@ -1669,9 +1669,9 @@ static u16 simple_tx_hash(struct net_device *dev, struct sk_buff *skb)
 	u32 hash, ihl;
 	u8 ip_proto;
 
-	if (unlikely(!simple_tx_hashrnd_initialized)) {
-		get_random_bytes(&simple_tx_hashrnd, 4);
-		simple_tx_hashrnd_initialized = 1;
+	if (unlikely(!simple_hashrnd_initialized)) {
+		get_random_bytes(&simple_hashrnd, 4);
+		simple_hashrnd_initialized = 1;
 	}
 
 	switch (skb->protocol) {
@@ -1708,7 +1708,7 @@ static u16 simple_tx_hash(struct net_device *dev, struct sk_buff *skb)
 		break;
 	}
 
-	hash = jhash_3words(addr1, addr2, ports, simple_tx_hashrnd);
+	hash = jhash_3words(addr1, addr2, ports, simple_hashrnd);
 
 	return (u16) (((u64) hash * dev->real_num_tx_queues) >> 32);
 }
@@ -1878,75 +1878,6 @@ int weight_p __read_mostly = 64;            /* old backlog weight */
 DEFINE_PER_CPU(struct netif_rx_stats, netdev_rx_stat) = { 0, };
 
 
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
- *	NET_RX_DROP     (packet was dropped)
- *
- */
-
-int netif_rx(struct sk_buff *skb)
-{
-	struct softnet_data *queue;
-	unsigned long flags;
-
-	/* if netpoll wants it, pretend we never saw it */
-	if (netpoll_rx(skb))
-		return NET_RX_DROP;
-
-	if (!skb->tstamp.tv64)
-		net_timestamp(skb);
-
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
-
-	kfree_skb(skb);
-	return NET_RX_DROP;
-}
-
-int netif_rx_ni(struct sk_buff *skb)
-{
-	int err;
-
-	preempt_disable();
-	err = netif_rx(skb);
-	if (local_softirq_pending())
-		do_softirq();
-	preempt_enable();
-
-	return err;
-}
-
-EXPORT_SYMBOL(netif_rx_ni);
-
 static void net_tx_action(struct softirq_action *h)
 {
 	struct softnet_data *sd = &__get_cpu_var(softnet_data);
@@ -2177,7 +2108,7 @@ void netif_nit_deliver(struct sk_buff *skb)
  *	NET_RX_SUCCESS: no congestion
  *	NET_RX_DROP: packet was dropped
  */
-int netif_receive_skb(struct sk_buff *skb)
+static int __netif_receive_skb(struct sk_buff *skb)
 {
 	struct packet_type *ptype, *pt_prev;
 	struct net_device *orig_dev;
@@ -2185,10 +2116,6 @@ int netif_receive_skb(struct sk_buff *skb)
 	int ret = NET_RX_DROP;
 	__be16 type;
 
-	/* if we've gotten here through NAPI, check netpoll */
-	if (netpoll_receive_skb(skb))
-		return NET_RX_DROP;
-
 	if (!skb->tstamp.tv64)
 		net_timestamp(skb);
 
@@ -2275,45 +2202,152 @@ out:
 	return ret;
 }
 
-/* Network device is going away, flush any packets still pending  */
-static void flush_backlog(void *arg)
+static void net_receive_action(struct softirq_action *h)
 {
-	struct net_device *dev = arg;
-	struct softnet_data *queue = &__get_cpu_var(softnet_data);
-	struct sk_buff *skb, *tmp;
+	struct list_head *cpu_list, local_list;
 
-	skb_queue_walk_safe(&queue->input_pkt_queue, skb, tmp)
-		if (skb->dev == dev) {
-			__skb_unlink(skb, &queue->input_pkt_queue);
-			kfree_skb(skb);
-		}
+	local_irq_disable();
+	cpu_list = &__get_cpu_var(softirq_work_list[NET_RECEIVE_SOFTIRQ]);
+	list_replace_init(cpu_list, &local_list);
+	local_irq_enable();
+
+	while (!list_empty(&local_list)) {
+		struct sk_buff *skb;
+
+		skb = list_entry(local_list.next, struct sk_buff, csd.list);
+		list_del_init(&skb->csd.list);
+		__netif_receive_skb(skb);
+	}
 }
 
-static int process_backlog(struct napi_struct *napi, int quota)
+static u16 *rxflow_cpu_map;
+static int rxflow_num_cpus;
+
+/* skb->data points at the network header, but that is the only thing
+ * we can rely upon.
+ */
+static u16 simple_rx_hash(struct sk_buff *skb)
 {
-	int work = 0;
-	struct softnet_data *queue = &__get_cpu_var(softnet_data);
-	unsigned long start_time = jiffies;
+	u32 addr1, addr2, ports;
+	struct ipv6hdr *ip6;
+	struct iphdr *ip;
+	u32 hash, ihl;
+	u8 ip_proto;
 
-	napi->weight = weight_p;
-	do {
-		struct sk_buff *skb;
+	if (unlikely(!simple_hashrnd_initialized)) {
+		get_random_bytes(&simple_hashrnd, 4);
+		simple_hashrnd_initialized = 1;
+	}
 
-		local_irq_disable();
-		skb = __skb_dequeue(&queue->input_pkt_queue);
-		if (!skb) {
-			__napi_complete(napi);
-			local_irq_enable();
-			break;
-		}
-		local_irq_enable();
+	switch (skb->protocol) {
+	case __constant_htons(ETH_P_IP):
+		if (!pskb_may_pull(skb, sizeof(*ip)))
+			return 0;
 
-		netif_receive_skb(skb);
-	} while (++work < quota && jiffies == start_time);
+		ip = (struct iphdr *) skb->data;
+		ip_proto = ip->protocol;
+		addr1 = ip->saddr;
+		addr2 = ip->daddr;
+		ihl = ip->ihl;
+		break;
+	case __constant_htons(ETH_P_IPV6):
+		if (!pskb_may_pull(skb, sizeof(*ip6)))
+			return 0;
+
+		ip6 = (struct ipv6hdr *) skb->data;
+		ip_proto = ip6->nexthdr;
+		addr1 = ip6->saddr.s6_addr32[3];
+		addr2 = ip6->daddr.s6_addr32[3];
+		ihl = (40 >> 2);
+		break;
+	default:
+		return 0;
+	}
+
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
 
-	return work;
+	default:
+		break;
+	}
+
+	hash = jhash_3words(addr1, addr2, ports, simple_hashrnd);
+
+	return (u16) (((u64) hash * rxflow_num_cpus) >> 32);
 }
 
+/* Since we are already in softirq context via NAPI, it makes no
+ * sense to reschedule a softirq locally, so we optimize that case.
+ */
+int netif_receive_skb(struct sk_buff *skb)
+{
+	int target_cpu, this_cpu, do_direct;
+	unsigned long flags;
+
+	/* If we've gotten here through NAPI, check netpoll.  This part
+	 * has to be synchronous and not get pushed to remote softirq
+	 * receive packet processing.
+	 */
+	if (netpoll_receive_skb(skb))
+		return NET_RX_DROP;
+
+	target_cpu = rxflow_cpu_map[simple_rx_hash(skb)];
+
+	local_irq_save(flags);
+	this_cpu = smp_processor_id();
+	do_direct = 0;
+	if (target_cpu != this_cpu)
+		__send_remote_softirq(&skb->csd, target_cpu, this_cpu, NET_RECEIVE_SOFTIRQ);
+	else
+		do_direct = 1;
+
+	local_irq_restore(flags);
+
+	if (do_direct)
+		return __netif_receive_skb(skb);
+
+	return NET_RX_SUCCESS;
+}
+
+int netif_rx(struct sk_buff *skb)
+{
+	int target_cpu;
+
+	/* if netpoll wants it, pretend we never saw it */
+	if (netpoll_rx(skb))
+		return NET_RX_DROP;
+
+	target_cpu = rxflow_cpu_map[simple_rx_hash(skb)];
+	send_remote_softirq(&skb->csd, target_cpu, NET_RECEIVE_SOFTIRQ);
+
+	return NET_RX_SUCCESS;
+}
+
+int netif_rx_ni(struct sk_buff *skb)
+{
+	int err;
+
+	preempt_disable();
+	err = netif_rx(skb);
+	if (local_softirq_pending())
+		do_softirq();
+	preempt_enable();
+
+	return err;
+}
+
+EXPORT_SYMBOL(netif_rx_ni);
+
 /**
  * __napi_schedule - schedule for receive
  * @n: entry to schedule
@@ -4182,8 +4216,6 @@ void netdev_run_todo(void)
 
 		dev->reg_state = NETREG_UNREGISTERED;
 
-		on_each_cpu(flush_backlog, dev, 1);
-
 		netdev_wait_allrefs(dev);
 
 		/* paranoia */
@@ -4489,7 +4521,6 @@ static int dev_cpu_callback(struct notifier_block *nfb,
 {
 	struct sk_buff **list_skb;
 	struct Qdisc **list_net;
-	struct sk_buff *skb;
 	unsigned int cpu, oldcpu = (unsigned long)ocpu;
 	struct softnet_data *sd, *oldsd;
 
@@ -4520,10 +4551,6 @@ static int dev_cpu_callback(struct notifier_block *nfb,
 	raise_softirq_irqoff(NET_TX_SOFTIRQ);
 	local_irq_enable();
 
-	/* Process offline CPU's input_pkt_queue */
-	while ((skb = __skb_dequeue(&oldsd->input_pkt_queue)))
-		netif_rx(skb);
-
 	return NOTIFY_OK;
 }
 
@@ -4793,7 +4820,7 @@ static struct pernet_operations __net_initdata default_device_ops = {
  */
 static int __init net_dev_init(void)
 {
-	int i, rc = -ENOMEM;
+	int i, index, rc = -ENOMEM;
 
 	BUG_ON(!dev_boot_phase);
 
@@ -4813,6 +4840,15 @@ static int __init net_dev_init(void)
 	if (register_pernet_device(&default_device_ops))
 		goto out;
 
+	rxflow_cpu_map = kzalloc(sizeof(u16) * num_possible_cpus(), GFP_KERNEL);
+	if (!rxflow_cpu_map)
+		goto out;
+	rxflow_num_cpus = num_online_cpus();
+
+	index = 0;
+	for_each_online_cpu(i)
+		rxflow_cpu_map[index++] = i;
+
 	/*
 	 *	Initialise the packet receive queues.
 	 */
@@ -4821,12 +4857,8 @@ static int __init net_dev_init(void)
 		struct softnet_data *queue;
 
 		queue = &per_cpu(softnet_data, i);
-		skb_queue_head_init(&queue->input_pkt_queue);
 		queue->completion_queue = NULL;
 		INIT_LIST_HEAD(&queue->poll_list);
-
-		queue->backlog.poll = process_backlog;
-		queue->backlog.weight = weight_p;
 	}
 
 	netdev_dma_register();
@@ -4835,6 +4867,7 @@ static int __init net_dev_init(void)
 
 	open_softirq(NET_TX_SOFTIRQ, net_tx_action);
 	open_softirq(NET_RX_SOFTIRQ, net_rx_action);
+	open_softirq(NET_RECEIVE_SOFTIRQ, net_receive_action);
 
 	hotcpu_notifier(dev_cpu_callback, 0);
 	dst_init();
-- 
1.5.6.5

