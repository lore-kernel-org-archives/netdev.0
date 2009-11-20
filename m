From: Tom Herbert <therbert@google.com>
Subject: [PATCH v4 1/1] rps: core implementation
Date: Fri, 20 Nov 2009 15:28:58 -0800
Message-ID: <65634d660911201528k5a07135el471b65fff9dd7c9d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.45.13]:31821 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753214AbZKTX26 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2009 18:28:58 -0500
Received: from spaceape11.eur.corp.google.com (spaceape11.eur.corp.google.com [172.28.16.145])
	by smtp-out.google.com with ESMTP id nAKNT2rO019248
	for <netdev@vger.kernel.org>; Fri, 20 Nov 2009 15:29:02 -0800
Received: from pzk38 (pzk38.prod.google.com [10.243.19.166])
	by spaceape11.eur.corp.google.com with ESMTP id nAKNSwrm013007
	for <netdev@vger.kernel.org>; Fri, 20 Nov 2009 15:28:59 -0800
Received: by pzk38 with SMTP id 38so2787498pzk.9
        for <netdev@vger.kernel.org>; Fri, 20 Nov 2009 15:28:58 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Version 4 of RPS patch.  I think this addresses most of the comments
on the previous versions.  Thanks for all the insightful comments and
patience!

Changes from previous version:

- Added rxhash to kernel-doc for struct sk_buff
- Removed /** on comments not for kernel-doc
- Change get_token declaration to kernel style
- Added struct dev_rps_maps.  Each netdevice now has a pointer to this
structure which contains the array of per NAPI rps maps, the number of
this maps.  rcu is used to protect pointer
- In store_rps_cpus a new map set is allocated each call.
- Removed dev_isalive check and other locks since rps struct in
netdevice are protected by rcu
- Removed NET_RPS_SOFTIRQ and call net_rps_action from net_rx_action instead
- Queue to remote backlog queues only in NAPI case.  This means
rps_remote_softirq_cpus does not need to be accessed with interrupts
disabled and __smp_call_function_single will not be called with
interrupts disabled
- Limit the number of entries in an rps map to min(256, num_possible_cpus())
- Removed unnecessary irq_local_disable
- Renamed skb_tx_hashrnd to just hashrnd and use that for the rps hash as well
- Make index u16 in index=skb_get_rx_queue() and don't check index<0 now
- Replace spin_lock_irqsave with simpler spin_lock_irq in process_backlog

Signed-off-by: Tom Herbert <therbert@google.com>
---

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 97873e3..9b84a38 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -676,6 +676,29 @@ struct net_device_ops {
 };

 /*
+ * Structure for Receive Packet Steering.  Length of map and array of CPU ID's.
+ */
+struct rps_map {
+	int len;
+	u16 map[0];
+};
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
+/* Bound number of CPUs that can be in an rps map */
+#define MAX_RPS_CPUS (num_possible_cpus() < 256 ? num_possible_cpus() : 256)
+
+/* Maximum size of RPS map (for allocation) */
+#define RPS_MAP_SIZE (sizeof(struct rps_map) + (MAX_RPS_CPUS * sizeof(u16)))
+
+/*
  *	The DEVICE structure.
  *	Actually, this whole structure is a big mistake.  It mixes I/O
  *	data with strictly "high-level" data, and it has to know about
@@ -861,6 +884,9 @@ struct net_device {

 	struct netdev_queue	rx_queue;

+	struct dev_rps_maps	*dev_rps_maps;	/* Per-NAPI maps for
+						   receive packet steeing */
+
 	struct netdev_queue	*_tx ____cacheline_aligned_in_smp;

 	/* Number of TX queues allocated at alloc_netdev_mq() time  */
@@ -1276,6 +1302,9 @@ struct softnet_data {
 	struct Qdisc		*output_queue;
 	struct sk_buff_head	input_pkt_queue;
 	struct list_head	poll_list;
+
+	struct call_single_data	csd;
+
 	struct sk_buff		*completion_queue;

 	struct napi_struct	backlog;
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
index 9977288..f2c199c 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1834,7 +1834,7 @@ out_kfree_skb:
 	return rc;
 }

-static u32 skb_tx_hashrnd;
+static u32 hashrnd;

 u16 skb_tx_hash(const struct net_device *dev, const struct sk_buff *skb)
 {
@@ -1852,7 +1852,7 @@ u16 skb_tx_hash(const struct net_device *dev,
const struct sk_buff *skb)
 	else
 		hash = skb->protocol;

-	hash = jhash_1word(hash, skb_tx_hashrnd);
+	hash = jhash_1word(hash, hashrnd);

 	return (u16) (((u64) hash * dev->real_num_tx_queues) >> 32);
 }
@@ -2073,6 +2073,146 @@ int weight_p __read_mostly = 64;            /*
old backlog weight */

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
+	u32 hash, ihl;
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
+	    ((void *)drmap->maps + (RPS_MAP_SIZE * index));
+	if (!map->len)
+		goto done;
+
+	hash = skb->rxhash;
+	if (hash)
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
+	hash = jhash_3words(addr1, addr2, ports, hashrnd);
+
+got_hash:
+	cpu = map->map[((u64) hash * map->len) >> 32];
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
+				    get_cpu_var(rps_remote_softirq_cpus));
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
@@ -2091,9 +2231,6 @@ DEFINE_PER_CPU(struct netif_rx_stats,
netdev_rx_stat) = { 0, };

 int netif_rx(struct sk_buff *skb)
 {
-	struct softnet_data *queue;
-	unsigned long flags;
-
 	/* if netpoll wants it, pretend we never saw it */
 	if (netpoll_rx(skb))
 		return NET_RX_DROP;
@@ -2101,31 +2238,8 @@ int netif_rx(struct sk_buff *skb)
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
-
-	kfree_skb(skb);
-	return NET_RX_DROP;
+	/* Always send to local backlog, no RPS for non NAPI */
+	return enqueue_to_backlog(skb, smp_processor_id());
 }
 EXPORT_SYMBOL(netif_rx);

@@ -2363,10 +2477,10 @@ void netif_nit_deliver(struct sk_buff *skb)
 }

 /**
- *	netif_receive_skb - process receive buffer from network
+ *	__netif_receive_skb - process receive buffer from network
  *	@skb: buffer to process
  *
- *	netif_receive_skb() is the main receive data processing function.
+ *	__netif__napireceive_skb() is the main receive data processing function.
  *	It always succeeds. The buffer may be dropped during processing
  *	for congestion control or by the protocol layers.
  *
@@ -2377,7 +2491,8 @@ void netif_nit_deliver(struct sk_buff *skb)
  *	NET_RX_SUCCESS: no congestion
  *	NET_RX_DROP: packet was dropped
  */
-int netif_receive_skb(struct sk_buff *skb)
+
+int __netif_receive_skb(struct sk_buff *skb)
 {
 	struct packet_type *ptype, *pt_prev;
 	struct net_device *orig_dev;
@@ -2475,6 +2590,16 @@ out:
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
@@ -2518,7 +2643,7 @@ static int napi_gro_complete(struct sk_buff *skb)
 	}

 out:
-	return netif_receive_skb(skb);
+	return __netif_receive_skb(skb);
 }

 void napi_gro_flush(struct napi_struct *napi)
@@ -2650,7 +2775,7 @@ gro_result_t napi_skb_finish(gro_result_t ret,
struct sk_buff *skb)
 {
 	switch (ret) {
 	case GRO_NORMAL:
-		if (netif_receive_skb(skb))
+		if (__netif_receive_skb(skb))
 			ret = GRO_DROP;
 		break;

@@ -2724,7 +2849,7 @@ gro_result_t napi_frags_finish(struct
napi_struct *napi, struct sk_buff *skb,

 		if (ret == GRO_HELD)
 			skb_gro_pull(skb, -ETH_HLEN);
-		else if (netif_receive_skb(skb))
+		else if (__netif_receive_skb(skb))
 			ret = GRO_DROP;
 		break;

@@ -2799,16 +2924,16 @@ static int process_backlog(struct napi_struct
*napi, int quota)
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
@@ -2897,6 +3022,21 @@ void netif_napi_del(struct napi_struct *napi)
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
+		__smp_call_function_single(cpu, &queue->csd, 0);
+	}
+	cpus_clear(__get_cpu_var(rps_remote_softirq_cpus));
+}

 static void net_rx_action(struct softirq_action *h)
 {
@@ -2968,6 +3108,8 @@ static void net_rx_action(struct softirq_action *h)
 out:
 	local_irq_enable();

+	net_rps_action();
+
 #ifdef CONFIG_NET_DMA
 	/*
 	 * There may not be any more sk_buffs coming right now, so push
@@ -5341,6 +5483,8 @@ void free_netdev(struct net_device *dev)
 	/* Flush device addresses */
 	dev_addr_flush(dev);

+	kfree(dev->dev_rps_maps);
+
 	list_for_each_entry_safe(p, n, &dev->napi_list, dev_list)
 		netif_napi_del(p);

@@ -5793,6 +5937,10 @@ static int __init net_dev_init(void)
 		queue->completion_queue = NULL;
 		INIT_LIST_HEAD(&queue->poll_list);

+		queue->csd.func = trigger_softirq;
+		queue->csd.info = queue;
+		queue->csd.flags = 0;
+
 		queue->backlog.poll = process_backlog;
 		queue->backlog.weight = weight_p;
 		queue->backlog.gro_list = NULL;
@@ -5831,7 +5979,7 @@ subsys_initcall(net_dev_init);

 static int __init initialize_hashrnd(void)
 {
-	get_random_bytes(&skb_tx_hashrnd, sizeof(skb_tx_hashrnd));
+	get_random_bytes(&hashrnd, sizeof(hashrnd));
 	return 0;
 }

diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 157645c..be78dfb 100644
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
@@ -253,6 +256,132 @@ static ssize_t store_tx_queue_len(struct device *dev,
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
+
+	drmap = kzalloc(sizeof (struct dev_rps_maps) +
+	    RPS_MAP_SIZE * cnt, GFP_KERNEL);
+	if (!drmap)
+		return -ENOMEM;
+
+	drmap->num_maps = cnt;
+
+	cp = buf;
+	for (index = 0; index < cnt &&
+	   (token = get_token(&cp, &tlen)); index++) {
+		struct rps_map *map = (struct rps_map *)
+		    ((void *)drmap->maps + (RPS_MAP_SIZE * index));
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
+			if (i >= MAX_RPS_CPUS)
+				break;
+			map->map[i++] =  cpu;
+		}
+		map->len = i;
+	}
+
+	rcu_read_lock_bh();
+	old_drmap = rcu_dereference(net->dev_rps_maps);
+	rcu_assign_pointer(net->dev_rps_maps, drmap);
+	rcu_read_unlock_bh();
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
+	rcu_read_lock_bh();
+	drmap = rcu_dereference(net->dev_rps_maps);
+
+	if (drmap) {
+		for (j = 0; j < drmap->num_maps; j++) {
+			struct rps_map *map = (struct rps_map *)
+			    ((void *)drmap->maps + (RPS_MAP_SIZE * j));
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
+	rcu_read_unlock_bh();
+
+	len += sprintf(buf + len, "\n");
+	return len;
+}
+
 static ssize_t store_ifalias(struct device *dev, struct device_attribute *attr,
 			     const char *buf, size_t len)
 {
@@ -309,6 +438,7 @@ static struct device_attribute net_class_attributes[] = {
 	__ATTR(flags, S_IRUGO | S_IWUSR, show_flags, store_flags),
 	__ATTR(tx_queue_len, S_IRUGO | S_IWUSR, show_tx_queue_len,
 	       store_tx_queue_len),
+	__ATTR(rps_cpus, S_IRUGO | S_IWUSR, show_rps_cpus, store_rps_cpus),
 	{}
 };
