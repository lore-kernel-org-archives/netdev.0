From: Tom Herbert <therbert@google.com>
Subject: [PATCH v6] rps: Receive Packet Steering
Date: Wed, 10 Mar 2010 23:00:20 -0800 (PST)
Message-ID: <alpine.DEB.1.00.1003102249380.21248@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: bhutchings@solarflare.com, shemminger@vyatta.com,
	eric.dumazet@gmail.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:60453 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752449Ab0CKHBG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Mar 2010 02:01:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added explicit entries entries in sysfs to set RPS cpus for each device queue.  This includes:

- Create RX queue instances which are attached to each netdevice (netdev_rx_queue).  These are analogous to the netdev_queue structures which are used for transmit.  RX queue instances hold an rps_map.
- RX queues are allocated in alloc_netdev_mq for the given queue_count (basically we're assuming #RX queues == #TX queues).  If a driver does not call alloc_netdev_mq, a single instance is created in register_netdevice.
- Added subdrectories in sysfs for per-queue RPS settings.  These are in /sys/class/net/eth<n>/queues/rx-<n>.  The "queues" directory is not necessary, but keeps the eth<n> directory clean (I don't have a stong opinion on this).  Presumably, if TX queues needed entries that could go under tx-<n>

Also addessed some previous issues raised:
- Copy rxhash in skb_clone
- Took __netif_receive_skb out of kernel-doc
- Removed VLA containing VLA ugliness (rx queues above fixed that)
- Copy and clear rps_mask before calling net_rps_action


diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index c79a88b..468da0a 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -223,6 +223,7 @@ struct netif_rx_stats {
 	unsigned dropped;
 	unsigned time_squeeze;
 	unsigned cpu_collision;
+	unsigned received_rps;
 };
 
 DECLARE_PER_CPU(struct netif_rx_stats, netdev_rx_stat);
@@ -530,6 +531,22 @@ struct netdev_queue {
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
+	struct kobject kobj;
+	struct rps_map *rps_map;
+} ____cacheline_aligned_in_smp;
 
 /*
  * This structure defines the management hooks for network devices.
@@ -878,6 +895,13 @@ struct net_device {
 
 	unsigned char		broadcast[MAX_ADDR_LEN];	/* hw bcast add	*/
 
+	struct kset		*queues_kset;
+
+	struct netdev_rx_queue	**_rx;
+
+	/* Number of RX queues allocated at alloc_netdev_mq() time  */
+	unsigned int		num_rx_queues;
+
 	struct netdev_queue	rx_queue;
 
 	struct netdev_queue	*_tx ____cacheline_aligned_in_smp;
@@ -1311,14 +1335,16 @@ static inline int unregister_gifconf(unsigned int family)
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
index 03f816a..58e1dda 100644
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
@@ -320,6 +321,8 @@ struct sk_buff {
 	struct sock		*sk;
 	struct net_device	*dev;
 
+	__u32			rxhash;
+
 	/*
 	 * This is the control buffer. It is free to use for every
 	 * layer. Please put your private variables there. If you
diff --git a/net/core/dev.c b/net/core/dev.c
index bcc490c..939b1a2 100644
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
@@ -2175,6 +2175,157 @@ int weight_p __read_mostly = 64;            /* old backlog weight */
 
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
+				WARN(1, "Recieved packet on %s for queue %u, "
+				    "but number of RX queues is %u\n",
+				     dev->name, index, dev->num_rx_queues);
+			}
+			goto done;
+		}
+		rxqueue = dev->_rx[index];
+	} else
+		rxqueue = dev->_rx[0];
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
@@ -2193,8 +2344,7 @@ DEFINE_PER_CPU(struct netif_rx_stats, netdev_rx_stat) = { 0, };
 
 int netif_rx(struct sk_buff *skb)
 {
-	struct softnet_data *queue;
-	unsigned long flags;
+	int cpu;
 
 	/* if netpoll wants it, pretend we never saw it */
 	if (netpoll_rx(skb))
@@ -2203,31 +2353,11 @@ int netif_rx(struct sk_buff *skb)
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
 
@@ -2464,22 +2594,7 @@ void netif_nit_deliver(struct sk_buff *skb)
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
@@ -2588,6 +2703,33 @@ out:
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
@@ -2914,16 +3056,16 @@ static int process_backlog(struct napi_struct *napi, int quota)
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
@@ -3012,6 +3154,21 @@ void netif_napi_del(struct napi_struct *napi)
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
+}
 
 static void net_rx_action(struct softirq_action *h)
 {
@@ -3019,6 +3176,7 @@ static void net_rx_action(struct softirq_action *h)
 	unsigned long time_limit = jiffies + 2;
 	int budget = netdev_budget;
 	void *have;
+	cpumask_t rps_mask;
 
 	local_irq_disable();
 
@@ -3081,8 +3239,13 @@ static void net_rx_action(struct softirq_action *h)
 		netpoll_poll_unlock(have);
 	}
 out:
+	cpumask_copy(&rps_mask, &__get_cpu_var(rps_remote_softirq_cpus));
+	cpus_clear(__get_cpu_var(rps_remote_softirq_cpus));
+
 	local_irq_enable();
 
+	net_rps_action(&rps_mask);
+
 #ifdef CONFIG_NET_DMA
 	/*
 	 * There may not be any more sk_buffs coming right now, so push
@@ -3327,10 +3490,10 @@ static int softnet_seq_show(struct seq_file *seq, void *v)
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
 
@@ -5067,6 +5230,29 @@ int register_netdevice(struct net_device *dev)
 
 	dev->iflink = -1;
 
+	if (!dev->num_rx_queues) {
+		/*
+		 * Allocate a single RX queue if driver never called
+		 * alloc_netdev_mq
+		 */
+
+		dev->_rx = kzalloc(sizeof(struct netdev_rx_queue *),
+		    GFP_KERNEL);
+		if (!dev->_rx) {
+			ret = -ENOMEM;
+			goto out;
+		}
+
+		dev->_rx[0] = kzalloc(sizeof(struct netdev_rx_queue),
+		    GFP_KERNEL);
+		if (!dev->_rx[0]) {
+			kfree(dev->_rx);
+			ret = -ENOMEM;
+			goto out;
+		}
+		dev->num_rx_queues = 1;
+	}
+
 	/* Init, if this function is available */
 	if (dev->netdev_ops->ndo_init) {
 		ret = dev->netdev_ops->ndo_init(dev);
@@ -5424,9 +5610,11 @@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 		void (*setup)(struct net_device *), unsigned int queue_count)
 {
 	struct netdev_queue *tx;
+	struct netdev_rx_queue **rx;
 	struct net_device *dev;
 	size_t alloc_size;
 	struct net_device *p;
+	int i;
 
 	BUG_ON(strlen(name) >= sizeof(dev->name));
 
@@ -5452,6 +5640,27 @@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 		goto free_p;
 	}
 
+	/*
+	 * Allocate RX queue structures, this includes an array of pointers
+	 * and netdev_queue_rx stuctures (individually allocated since
+	 * each has a kobject).
+	 */
+	rx = kzalloc(queue_count *
+	    sizeof(struct netdev_rx_queue *), GFP_KERNEL);
+	if (!rx) {
+		printk(KERN_ERR "alloc_netdev: Unable to allocate "
+		       "rx queues array.\n");
+		goto free_tx;
+	}
+	for (i = 0; i < queue_count; i++) {
+		rx[i] = kzalloc(sizeof(struct netdev_rx_queue), GFP_KERNEL);
+		if (!rx[i]) {
+			printk(KERN_ERR "alloc_netdev: Unable to allocate "
+			    "rx queues.\n");
+			goto free_rx;
+		}
+	}
+
 	dev = PTR_ALIGN(p, NETDEV_ALIGN);
 	dev->padded = (char *)dev - (char *)p;
 
@@ -5466,6 +5675,9 @@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 	dev->num_tx_queues = queue_count;
 	dev->real_num_tx_queues = queue_count;
 
+	dev->_rx = rx;
+	dev->num_rx_queues = queue_count;
+
 	dev->gso_max_size = GSO_MAX_SIZE;
 
 	netdev_init_queues(dev);
@@ -5480,9 +5692,12 @@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 	strcpy(dev->name, name);
 	return dev;
 
+free_rx:
+	for (i = 0; i < queue_count; i++)
+		kfree(rx[i]);
+	kfree(rx);
 free_tx:
 	kfree(tx);
-
 free_p:
 	kfree(p);
 	return NULL;
@@ -5505,6 +5720,12 @@ void free_netdev(struct net_device *dev)
 
 	kfree(dev->_tx);
 
+	/*
+	 * Free RX queue pointer array.  Actual netdev_rx_queue objects are
+	 * freed by kobject release.
+	 */
+	kfree(dev->_rx);
+
 	/* Flush device addresses */
 	dev_addr_flush(dev);
 
@@ -5985,6 +6206,10 @@ static int __init net_dev_init(void)
 		queue->completion_queue = NULL;
 		INIT_LIST_HEAD(&queue->poll_list);
 
+		queue->csd.func = trigger_softirq;
+		queue->csd.info = queue;
+		queue->csd.flags = 0;
+
 		queue->backlog.poll = process_backlog;
 		queue->backlog.weight = weight_p;
 		queue->backlog.gro_list = NULL;
@@ -6023,7 +6248,7 @@ subsys_initcall(net_dev_init);
 
 static int __init initialize_hashrnd(void)
 {
-	get_random_bytes(&skb_tx_hashrnd, sizeof(skb_tx_hashrnd));
+	get_random_bytes(&hashrnd, sizeof(hashrnd));
 	return 0;
 }
 
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 099c753..a07d6ec 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -466,6 +466,196 @@ static struct attribute_group wireless_group = {
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
+	size_t len = 0;
+	struct rps_map *map;
+	int i;
+	cpumask_t mask;
+
+	cpus_clear(mask);
+
+	rcu_read_lock();
+	map = rcu_dereference(queue->rps_map);
+	if (map) {
+		for (i = 0; i < map->len; i++)
+			cpu_set(map->cpus[i], mask);
+
+		len += cpumask_scnprintf(buf + len, PAGE_SIZE, &mask);
+		if (PAGE_SIZE - len < 3) {
+			rcu_read_unlock();
+			return -EINVAL;
+		}
+	}
+	rcu_read_unlock();
+
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
+	cpumask_t mask;
+	int err, cpu, i, weight;
+
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
+	err = bitmap_parse(buf, len, cpumask_bits(&mask), nr_cpumask_bits);
+	if (err)
+		return err;
+
+	weight = cpumask_weight(&mask);
+	if (weight) {
+		map = kzalloc(RPS_MAP_SIZE(weight), GFP_KERNEL);
+		if (!map)
+			return -ENOMEM;
+
+		cpus_and(mask, mask, cpu_online_map);
+		i = 0;
+		for_each_cpu_mask(cpu, mask)
+			map->cpus[i++] = cpu;
+		map->len = i;
+	} else
+		map = NULL;
+
+	rtnl_lock();
+	old_map = queue->rps_map;
+	rcu_assign_pointer(queue->rps_map, map);
+	rtnl_unlock();
+
+	if (old_map)
+		call_rcu(&old_map->rcu, rps_map_release);
+
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
+
+	kfree(queue);
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
+	int error = 0;
+	struct netdev_rx_queue *queue = net->_rx[index];
+	struct kobject *kobj = &queue->kobj;
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
+	int error = 0;
+	int i;
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
+			kobject_put(&net->_rx[i]->kobj);
+
+	return error;
+}
+
+static void rx_queue_remove_kobjects(struct net_device *net)
+{
+	int i;
+
+	for (i = 0; i < net->num_rx_queues; i++)
+		kobject_put(&net->_rx[i]->kobj);
+	kset_unregister(net->queues_kset);
+}
+
 #endif /* CONFIG_SYSFS */
 
 #ifdef CONFIG_HOTPLUG
@@ -529,12 +719,15 @@ void netdev_unregister_kobject(struct net_device * net)
 	if (!net_eq(dev_net(net), &init_net))
 		return;
 
+	rx_queue_remove_kobjects(net);
+
 	device_del(dev);
 }
 
 /* Create sysfs entries for network device. */
 int netdev_register_kobject(struct net_device *net)
 {
+	int error = 0;
 	struct device *dev = &(net->dev);
 	const struct attribute_group **groups = net->sysfs_groups;
 
@@ -563,7 +756,17 @@ int netdev_register_kobject(struct net_device *net)
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
index 93c4e06..472c767 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -581,6 +581,7 @@ static struct sk_buff *__skb_clone(struct sk_buff *n, struct sk_buff *skb)
 	C(len);
 	C(data_len);
 	C(mac_len);
+	C(rxhash);
 	n->hdr_len = skb->nohdr ? skb_headroom(skb) : skb->hdr_len;
 	n->cloned = 1;
 	n->nohdr = 0;
