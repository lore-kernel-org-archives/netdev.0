From: Tom Herbert <therbert@google.com>
Subject: [PATCH 1/2] rps: core implementation
Date: Tue, 10 Nov 2009 22:53:17 -0800
Message-ID: <65634d660911102253o2b4f7a19kfed5849e5c88bfe1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.45.13]:50531 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753560AbZKKGxQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2009 01:53:16 -0500
Received: from spaceape24.eur.corp.google.com (spaceape24.eur.corp.google.com [172.28.16.76])
	by smtp-out.google.com with ESMTP id nAB6rK7r029300
	for <netdev@vger.kernel.org>; Tue, 10 Nov 2009 22:53:21 -0800
Received: from iwn26 (iwn26.prod.google.com [10.241.68.90])
	by spaceape24.eur.corp.google.com with ESMTP id nAB6r9W8007134
	for <netdev@vger.kernel.org>; Tue, 10 Nov 2009 22:53:18 -0800
Received: by iwn26 with SMTP id 26so737458iwn.5
        for <netdev@vger.kernel.org>; Tue, 10 Nov 2009 22:53:17 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Third version of RPS.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/linux/interrupt.h |    1 +
 include/linux/netdevice.h |   18 ++++
 include/linux/skbuff.h    |    2 +
 net/core/dev.c            |  227 ++++++++++++++++++++++++++++++++++++++-------
 net/core/net-sysfs.c      |  135 +++++++++++++++++++++++++++
 5 files changed, 348 insertions(+), 35 deletions(-)

diff --git a/include/linux/interrupt.h b/include/linux/interrupt.h
index b78cf81..fa91194 100644
--- a/include/linux/interrupt.h
+++ b/include/linux/interrupt.h
@@ -345,6 +345,7 @@ enum
 	TIMER_SOFTIRQ,
 	NET_TX_SOFTIRQ,
 	NET_RX_SOFTIRQ,
+	NET_RPS_SOFTIRQ,
 	BLOCK_SOFTIRQ,
 	BLOCK_IOPOLL_SOFTIRQ,
 	TASKLET_SOFTIRQ,
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 8380009..c1b1bbb 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -639,6 +639,18 @@ struct net_device_ops {
 };

 /*
+ * Structure for Receive Packet Steering.  Length of map and array of CPU ID's.
+ */
+struct rps_map {
+	int len;
+	u16 map[0];
+};
+
+/* Maximum size of RPS map (for allocation) */
+#define RPS_MAP_SIZE (sizeof(struct rps_map) + \
+    (num_possible_cpus() * sizeof(u16)))
+
+/*
  *	The DEVICE structure.
  *	Actually, this whole structure is a big mistake.  It mixes I/O
  *	data with strictly "high-level" data, and it has to know about
@@ -807,6 +819,9 @@ struct net_device
 	void			*ax25_ptr;	/* AX.25 specific data */
 	struct wireless_dev	*ieee80211_ptr;	/* IEEE 802.11 specific data,
 						   assign before registering */
+	void			*rps_maps;	/* Array of per-NAPI maps for
+						   receive packet steeing */
+	int			rps_num_maps;	/* Number of RPS maps */

 /*
  * Cache line mostly used on receive path (including eth_type_trans())
@@ -1217,6 +1232,9 @@ struct softnet_data
 	struct Qdisc		*output_queue;
 	struct sk_buff_head	input_pkt_queue;
 	struct list_head	poll_list;
+
+	struct call_single_data	csd;
+
 	struct sk_buff		*completion_queue;

 	struct napi_struct	backlog;
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 0c68fbd..95feac7 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -396,6 +396,8 @@ struct sk_buff {

 	__u16			vlan_tci;

+	__u32			rxhash;
+
 	sk_buff_data_t		transport_header;
 	sk_buff_data_t		network_header;
 	sk_buff_data_t		mac_header;
diff --git a/net/core/dev.c b/net/core/dev.c
index 28b0b9e..735e7e3 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1976,6 +1976,162 @@ int weight_p __read_mostly = 64;            /*
old backlog weight */

 DEFINE_PER_CPU(struct netif_rx_stats, netdev_rx_stat) = { 0, };

+static u32 simple_hashrnd;
+
+/**
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
+	int cpu;
+	struct rps_map *map = NULL;
+
+	if (dev->rps_num_maps) {
+		/*
+		 * Locate the map corresponding to the NAPI queue that
+		 * the packet was received on.
+		 */
+		int index = skb_get_rx_queue(skb);
+		if (index < 0 || index >= dev->rps_num_maps)
+			index = 0;
+
+		map = (struct rps_map *)
+		    (dev->rps_maps + (RPS_MAP_SIZE * index));
+		if (!map->len)
+			map = NULL;
+	}
+
+	if (!map)
+		return -1;
+
+	hash = skb->rxhash;
+	if (hash)
+		goto got_hash; /* Skip hash computation on packet header */
+
+	switch (skb->protocol) {
+	case __constant_htons(ETH_P_IP):
+		if (!pskb_may_pull(skb, sizeof(*ip)))
+			return -1;
+
+		ip = (struct iphdr *) skb->data;
+		ip_proto = ip->protocol;
+		addr1 = ip->saddr;
+		addr2 = ip->daddr;
+		ihl = ip->ihl;
+		break;
+	case __constant_htons(ETH_P_IPV6):
+		if (!pskb_may_pull(skb, sizeof(*ip6)))
+			return -1;
+
+		ip6 = (struct ipv6hdr *) skb->data;
+		ip_proto = ip6->nexthdr;
+		addr1 = ip6->saddr.s6_addr32[3];
+		addr2 = ip6->daddr.s6_addr32[3];
+		ihl = (40 >> 2);
+		break;
+	default:
+		return -1;
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
+	hash = jhash_3words(addr1, addr2, ports, simple_hashrnd);
+
+got_hash:
+	cpu = map->map[((u64) hash * map->len) >> 32];
+
+	return cpu_online(cpu) ? cpu : -1;
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
+/**
+ * net_rps_action is called from NET_RPS_SOFTIRQ to do IPIs to schedule RX
+ * softirq on remote CPUs.  Called in a separate softirq to allow for
+ * coalescing.
+ */
+static void net_rps_action(struct softirq_action *h)
+{
+	int cpu;
+
+	local_irq_disable();
+
+	for_each_cpu_mask_nr(cpu, __get_cpu_var(rps_remote_softirq_cpus)) {
+		struct softnet_data *queue = &per_cpu(softnet_data, cpu);
+		__smp_call_function_single(cpu, &queue->csd, 0);
+	}
+	cpus_clear(__get_cpu_var(rps_remote_softirq_cpus));
+
+	local_irq_enable();
+}
+
+/**
+ * enqueue_to_backlog is called to queue an skb to a per CPU backlog
+ * queue (may be a remote CPU queue).
+ */
+static int enqueue_to_backlog(struct sk_buff *skb, int cpu)
+{
+	struct softnet_data *queue;
+	unsigned long flags;
+
+	queue = &per_cpu(softnet_data, cpu);
+	spin_lock_irqsave(&queue->input_pkt_queue.lock, flags);
+
+	__get_cpu_var(netdev_rx_stat).total++;
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
+				__raise_softirq_irqoff(NET_RPS_SOFTIRQ);
+			} else
+				__napi_schedule(&queue->backlog);
+		}
+		goto enqueue;
+	}
+
+	__get_cpu_var(netdev_rx_stat).dropped++;
+	spin_unlock_irqrestore(&queue->input_pkt_queue.lock, flags);
+
+	kfree_skb(skb);
+	return NET_RX_DROP;
+}

 /**
  *	netif_rx	-	post buffer to the network code
@@ -1994,8 +2150,7 @@ DEFINE_PER_CPU(struct netif_rx_stats,
netdev_rx_stat) = { 0, };

 int netif_rx(struct sk_buff *skb)
 {
-	struct softnet_data *queue;
-	unsigned long flags;
+	int cpu;

 	/* if netpoll wants it, pretend we never saw it */
 	if (netpoll_rx(skb))
@@ -2004,31 +2159,11 @@ int netif_rx(struct sk_buff *skb)
 	if (!skb->tstamp.tv64)
 		net_timestamp(skb);

-	/*
-	 * The code is rearranged so that the path is the most
-	 * short when CPU is congested, but is still operating.
-	 */
-	local_irq_save(flags);
-	queue = &__get_cpu_var(softnet_data);
+	cpu = get_rps_cpu(skb->dev, skb);
+	if (cpu < 0)
+		cpu = smp_processor_id();

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
+	return enqueue_to_backlog(skb, cpu);
 }
 EXPORT_SYMBOL(netif_rx);

@@ -2266,10 +2401,10 @@ void netif_nit_deliver(struct sk_buff *skb)
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
@@ -2280,7 +2415,8 @@ void netif_nit_deliver(struct sk_buff *skb)
  *	NET_RX_SUCCESS: no congestion
  *	NET_RX_DROP: packet was dropped
  */
-int netif_receive_skb(struct sk_buff *skb)
+
+int __netif_receive_skb(struct sk_buff *skb)
 {
 	struct packet_type *ptype, *pt_prev;
 	struct net_device *orig_dev;
@@ -2378,6 +2514,16 @@ out:
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
@@ -2421,7 +2567,7 @@ static int napi_gro_complete(struct sk_buff *skb)
 	}

 out:
-	return netif_receive_skb(skb);
+	return __netif_receive_skb(skb);
 }

 void napi_gro_flush(struct napi_struct *napi)
@@ -2554,7 +2700,7 @@ int napi_skb_finish(int ret, struct sk_buff *skb)

 	switch (ret) {
 	case GRO_NORMAL:
-		return netif_receive_skb(skb);
+		return __netif_receive_skb(skb);

 	case GRO_DROP:
 		err = NET_RX_DROP;
@@ -2625,7 +2771,7 @@ int napi_frags_finish(struct napi_struct *napi,
struct sk_buff *skb, int ret)
 		skb->protocol = eth_type_trans(skb, napi->dev);

 		if (ret == GRO_NORMAL)
-			return netif_receive_skb(skb);
+			return __netif_receive_skb(skb);

 		skb_gro_pull(skb, -ETH_HLEN);
 		break;
@@ -2696,21 +2842,24 @@ static int process_backlog(struct napi_struct
*napi, int quota)
 	int work = 0;
 	struct softnet_data *queue = &__get_cpu_var(softnet_data);
 	unsigned long start_time = jiffies;
+	unsigned long flags;

 	napi->weight = weight_p;
 	do {
 		struct sk_buff *skb;

 		local_irq_disable();
+		spin_lock_irqsave(&queue->input_pkt_queue.lock, flags);
 		skb = __skb_dequeue(&queue->input_pkt_queue);
 		if (!skb) {
 			__napi_complete(napi);
-			local_irq_enable();
+			spin_unlock_irqrestore(&queue->input_pkt_queue.lock,
+			    flags);
 			break;
 		}
-		local_irq_enable();
+		spin_unlock_irqrestore(&queue->input_pkt_queue.lock, flags);

-		netif_receive_skb(skb);
+		__netif_receive_skb(skb);
 	} while (++work < quota && jiffies == start_time);

 	return work;
@@ -5205,6 +5354,8 @@ void free_netdev(struct net_device *dev)
 	/* Flush device addresses */
 	dev_addr_flush(dev);

+	kfree(dev->rps_maps);
+
 	list_for_each_entry_safe(p, n, &dev->napi_list, dev_list)
 		netif_napi_del(p);

@@ -5644,6 +5795,10 @@ static int __init net_dev_init(void)
 		queue->completion_queue = NULL;
 		INIT_LIST_HEAD(&queue->poll_list);

+		queue->csd.func = trigger_softirq;
+		queue->csd.info = queue;
+		queue->csd.flags = 0;
+
 		queue->backlog.poll = process_backlog;
 		queue->backlog.weight = weight_p;
 		queue->backlog.gro_list = NULL;
@@ -5669,7 +5824,9 @@ static int __init net_dev_init(void)

 	open_softirq(NET_TX_SOFTIRQ, net_tx_action);
 	open_softirq(NET_RX_SOFTIRQ, net_rx_action);
+	open_softirq(NET_RPS_SOFTIRQ, net_rps_action);

+	get_random_bytes(&simple_hashrnd, 4);
 	hotcpu_notifier(dev_cpu_callback, 0);
 	dst_init();
 	dev_mcast_init();
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 753c420..ca250f6 100644
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
@@ -249,6 +252,137 @@ static ssize_t store_tx_queue_len(struct device *dev,
 	return netdev_store(dev, attr, buf, len, change_tx_queue_len);
 }

+static char *
+get_token(const char **cp, size_t *len)
+{
+	const char *bp = *cp, *start;
+
+	while (isspace(*bp))
+		bp++;
+
+	start = bp;
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
+
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
+	/*
+	 * Pre-check that tokens parse properly before we commit to making
+	 * any changes.
+	 */
+	while ((token = get_token(&cp, &tlen)))
+		err = bitmap_parse(token, tlen, cpumask_bits(&mask),
+		    nr_cpumask_bits);
+
+	if (err)
+		return err;
+
+	rtnl_lock();
+	if (dev_isalive(net)) {
+		if (!net->rps_maps) {
+			/*
+			 * Need to allocate the array of RPS maps, one map
+			 * for each NAPI instance on the device.
+			 */
+			list_for_each_entry(napi, &net->napi_list, dev_list)
+				cnt++;
+			net->rps_maps = kzalloc(RPS_MAP_SIZE * cnt, GFP_KERNEL);
+			if (!net->rps_maps) {
+				rtnl_unlock();
+				return -ENOMEM;
+			}
+			net->rps_num_maps = cnt;
+		}
+
+		cp = buf;
+		for (index = 0; index < net->rps_num_maps &&
+		   (token = get_token(&cp, &tlen)); index++) {
+			struct rps_map *map = (struct rps_map *)
+			    (net->rps_maps + (RPS_MAP_SIZE * index));
+			err = bitmap_parse(token, tlen, cpumask_bits(&mask),
+			    nr_cpumask_bits);
+			if (!err) {
+				cpus_and(mask, mask, cpu_online_map);
+				i = 0;
+				for_each_cpu_mask(cpu, mask)
+					map->map[i++] =  cpu;
+				map->len = i;
+			} else {
+				rtnl_unlock();
+				return err;
+			}
+		}
+
+		/*
+		 * Any per NAPI maps not being set are "zeroed" by setting
+		 * map length length to zero.
+		 */
+		for (; index < net->rps_num_maps; index++) {
+			struct rps_map *map = (struct rps_map *)
+			    (net->rps_maps + (RPS_MAP_SIZE * index));
+			map->len = 0;
+		}
+	}
+	rtnl_unlock();
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
+
+	read_lock(&dev_base_lock);
+	if (dev_isalive(net)) {
+		for (j = 0; j < net->rps_num_maps; j++) {
+			struct rps_map *map = (struct rps_map *)
+			    (net->rps_maps + (RPS_MAP_SIZE * j));
+			cpus_clear(mask);
+			for (i = 0; i < map->len; i++)
+				cpu_set(map->map[i], mask);
+
+			len += cpumask_scnprintf(buf + len, PAGE_SIZE, &mask);
+			if (PAGE_SIZE - len < 3) {
+				read_unlock(&dev_base_lock);
+				return -EINVAL;
+			}
+			if (j < net->rps_num_maps)
+				len += sprintf(buf + len, " ");
+		}
+	}
+
+	read_unlock(&dev_base_lock);
+
+	len += sprintf(buf + len, "\n");
+	return len;
+}
+
 static ssize_t store_ifalias(struct device *dev, struct device_attribute *attr,
 			     const char *buf, size_t len)
 {
@@ -305,6 +439,7 @@ static struct device_attribute net_class_attributes[] = {
 	__ATTR(flags, S_IRUGO | S_IWUSR, show_flags, store_flags),
 	__ATTR(tx_queue_len, S_IRUGO | S_IWUSR, show_tx_queue_len,
 	       store_tx_queue_len),
+	__ATTR(rps_cpus, S_IRUGO | S_IWUSR, show_rps_cpus, store_rps_cpus),
 	{}
 };

-- 
1.5.4.3
