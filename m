From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v4 1/1] rps: core implementation
Date: Thu, 07 Jan 2010 10:15:15 +0100
Message-ID: <4B45A623.7070507@gmail.com>
References: <65634d660911201528k5a07135el471b65fff9dd7c9d@mail.gmail.com>	 <20091120154046.67252d23@nehalam>	 <65634d660912171304p751e1698mbc9de50dade4317d@mail.gmail.com>	 <65634d661001051732qd64e79dt37e6247f8b0dc863@mail.gmail.com>	 <4B44258C.2050302@gmail.com> <4B44D89B.8070006@gmail.com> <65634d661001061454v389d311fjb245de21e0ab8092@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:55864 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932824Ab0AGJPY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2010 04:15:24 -0500
In-Reply-To: <65634d661001061454v389d311fjb245de21e0ab8092@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 06/01/2010 23:54, Tom Herbert a =E9crit :
> Eric, thanks again for your good comments. Here is my patch that
> addresses them, including:
>=20
> - Added softnet counter for number of rps softirq triggers
> - Force at least one map entry for devices with no napi's
> - Replace rcu_read_lock_bh with rtnl_lock when assigning dev_rps_maps
> pointer in store_rps_cpus
> - Replaced get_cpu_var with __get_cpu_var in enqueue_to_backlog (fix
> unmatched preempt_disable)

Ah good :)

> - Restored calling napi_receive_skb in napi_gro_complete,
> napi_skb_finish, and napi_frags_finish.  This fixes the problem with
> GRO that I had described previously.  Patch should now work with
> drivers that call napi_gro_receive (verified with e1000e)

Seems your v4/v5 patches are mangled by your mailer, I had to apply the=
m manually...

>=20
>  	/* Number of TX queues allocated at alloc_netdev_mq() time  */
> @@ -1274,10 +1301,12 @@ static inline int unregister_gifconf(unsigned
> int family)

(line wrap above, and some others later...)


> @@ -2091,8 +2234,7 @@ DEFINE_PER_CPU(struct netif_rx_stats,
> netdev_rx_stat) =3D { 0, };

>=20
>  /**
> - *	netif_receive_skb - process receive buffer from network
> + *	__netif_receive_skb - process receive buffer from network
>   *	@skb: buffer to process
>   *
> - *	netif_receive_skb() is the main receive data processing function.
> + *	__netif__napireceive_skb() is the main receive data processing fu=
nction.

Please remove '_napi' from __netif__napireceive_skb(), this is a leftov=
er ...


+	rtnl_lock();
+	old_drmap =3D rcu_dereference(net->dev_rps_maps);
+	rcu_assign_pointer(net->dev_rps_maps, drmap);
+	rtnl_unlock();

You dont need the rcu_dereference() ->

+	rtnl_lock();
+	old_drmap =3D net->dev_rps_maps;
+	rcu_assign_pointer(net->dev_rps_maps, drmap);
+	rtnl_unlock();

I wonder if a small spinlock would be better than rtnl here (rtnl is so=
 overloaded these days... :) )

in show_rps_cpus(), I dont believe you need to disable BH.

rcu_read_lock_bh() -> rcu_read_lock()


Patch works very well on my machine (original soft irqs handled by CPU =
0, and RPS
distributes packets to eight cpus). This is an RTP server (many UDP mes=
sages on many sockets)

# grep eth /proc/interrupts ; cat /proc/net/softnet_stat
 34:     589363          0          0          0          0          0 =
         0          0   PCI-MSI-edge      eth0
 35:         63          0          0          0          0          0 =
         0          0   PCI-MSI-edge      eth1
 36:    1267129          0          0          0          0          0 =
         0          0   PCI-MSI-edge      eth2
001ceff8 00000000 00000000 00000000 00000000 00000000 00000000 00000000=
 00000000 0000000e
0001eeee 00000000 00000000 00000000 00000000 00000000 00000000 00000000=
 00000000 0001ed70
0002ab18 00000000 00000000 00000000 00000000 00000000 00000000 00000000=
 00000000 0002a768
00041cb7 00000000 00000000 00000000 00000000 00000000 00000000 00000000=
 00000000 000415d1
0003d79b 00000000 00000000 00000000 00000000 00000000 00000000 00000000=
 00000000 0003d459
00031ea5 00000000 00000000 00000000 00000000 00000000 00000000 00000000=
 00000000 00031c36
0003705f 00000000 00000000 00000000 00000000 00000000 00000000 00000000=
 00000000 00036e5b
00026010 00000000 00000000 00000000 00000000 00000000 00000000 00000000=
 00000000 00025d94

# grep . ` find /sys -name rps_cpus`=20
/sys/class/net/eth0/rps_cpus:ff ff ff ff ff ff ff ff 00=20
/sys/class/net/eth1/rps_cpus:ff ff ff ff ff ff ff ff 00=20
/sys/class/net/bond0/rps_cpus:ff=20
/sys/class/net/eth2/rps_cpus:ff=20
/sys/class/net/eth3/rps_cpus:ff=20
/sys/class/net/vlan.103/rps_cpus:ff=20
/sys/class/net/vlan.825/rps_cpus:ff=20



If somebody wants to play with RPS, here is the patch I use on top of n=
et-next-2.6
(plus last patch from Andy Gospodarek)

Many thanks Tom !

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index a3fccc8..6d79458 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -222,6 +222,7 @@ struct netif_rx_stats {
 	unsigned dropped;
 	unsigned time_squeeze;
 	unsigned cpu_collision;
+	unsigned received_rps;
 };
=20
 DECLARE_PER_CPU(struct netif_rx_stats, netdev_rx_stat);
@@ -676,6 +677,29 @@ struct net_device_ops {
 };
=20
 /*
+ * Structure for Receive Packet Steering.  Length of map and array of =
CPU ID's.
+ */
+struct rps_map {
+	int len;
+	u16 map[0];
+};
+
+/*
+ * Structure that contains the rps maps for various NAPI instances of =
a device.
+ */
+struct dev_rps_maps {
+	int num_maps;
+	struct rcu_head rcu;
+	struct rps_map maps[0];
+};
+
+/* Bound number of CPUs that can be in an rps map */
+#define MAX_RPS_CPUS (num_possible_cpus() < 256 ? num_possible_cpus() =
: 256)
+
+/* Maximum size of RPS map (for allocation) */
+#define RPS_MAP_SIZE (sizeof(struct rps_map) + (MAX_RPS_CPUS * sizeof(=
u16)))
+
+/*
  *	The DEVICE structure.
  *	Actually, this whole structure is a big mistake.  It mixes I/O
  *	data with strictly "high-level" data, and it has to know about
@@ -861,6 +885,9 @@ struct net_device {
=20
 	struct netdev_queue	rx_queue;
=20
+	struct dev_rps_maps	*dev_rps_maps;	/* Per-NAPI maps for
+						   receive packet steeing */
+
 	struct netdev_queue	*_tx ____cacheline_aligned_in_smp;
=20
 	/* Number of TX queues allocated at alloc_netdev_mq() time  */
@@ -1276,10 +1303,12 @@ static inline int unregister_gifconf(unsigned i=
nt family)
  */
 struct softnet_data {
 	struct Qdisc		*output_queue;
-	struct sk_buff_head	input_pkt_queue;
 	struct list_head	poll_list;
 	struct sk_buff		*completion_queue;
=20
+	/* Elements below can be accessed between CPUs for RPS */
+	struct call_single_data	csd ____cacheline_aligned_in_smp;
+	struct sk_buff_head	input_pkt_queue;
 	struct napi_struct	backlog;
 };
=20
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index ae836fd..8ed3f66 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -267,6 +267,7 @@ typedef unsigned char *sk_buff_data_t;
  *	@mac_header: Link layer header
  *	@_skb_dst: destination entry
  *	@sp: the security path, used for xfrm
+ *	@rxhash: the packet hash computed on receive
  *	@cb: Control buffer. Free for use by every layer. Put private vars =
here
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
index d9ab9be..6260fd8 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1882,7 +1882,7 @@ out_kfree_skb:
 	return rc;
 }
=20
-static u32 skb_tx_hashrnd;
+static u32 hashrnd __read_mostly;
=20
 u16 skb_tx_hash(const struct net_device *dev, const struct sk_buff *sk=
b)
 {
@@ -1900,7 +1900,7 @@ u16 skb_tx_hash(const struct net_device *dev, con=
st struct sk_buff *skb)
 	else
 		hash =3D skb->protocol;
=20
-	hash =3D jhash_1word(hash, skb_tx_hashrnd);
+	hash =3D jhash_1word(hash, hashrnd);
=20
 	return (u16) (((u64) hash * dev->real_num_tx_queues) >> 32);
 }
@@ -2121,6 +2121,149 @@ int weight_p __read_mostly =3D 64;            /=
* old backlog weight */
=20
 DEFINE_PER_CPU(struct netif_rx_stats, netdev_rx_stat) =3D { 0, };
=20
+/*
+ * get_rps_cpu is called from netif_receive_skb and returns the target
+ * CPU from the RPS map of the receiving NAPI instance for a given skb=
=2E
+ */
+static int get_rps_cpu(struct net_device *dev, struct sk_buff *skb)
+{
+	u32 addr1, addr2, ports;
+	struct ipv6hdr *ip6;
+	struct iphdr *ip;
+	u32 ihl;
+	u8 ip_proto;
+	int cpu =3D -1;
+	struct dev_rps_maps *drmap;
+	struct rps_map *map =3D NULL;
+	u16 index;
+
+	rcu_read_lock();
+
+	drmap =3D rcu_dereference(dev->dev_rps_maps);
+	if (!drmap)
+		goto done;
+
+	index =3D skb_get_rx_queue(skb);
+	if (index >=3D drmap->num_maps)
+		index =3D 0;
+
+	map =3D (struct rps_map *)
+	    ((void *)drmap->maps + (RPS_MAP_SIZE * index));
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
+		ip =3D (struct iphdr *) skb->data;
+		ip_proto =3D ip->protocol;
+		addr1 =3D ip->saddr;
+		addr2 =3D ip->daddr;
+		ihl =3D ip->ihl;
+		break;
+	case __constant_htons(ETH_P_IPV6):
+		if (!pskb_may_pull(skb, sizeof(*ip6)))
+			goto done;
+
+		ip6 =3D (struct ipv6hdr *) skb->data;
+		ip_proto =3D ip6->nexthdr;
+		addr1 =3D ip6->saddr.s6_addr32[3];
+		addr2 =3D ip6->daddr.s6_addr32[3];
+		ihl =3D (40 >> 2);
+		break;
+	default:
+		goto done;
+	}
+	ports =3D 0;
+	switch (ip_proto) {
+	case IPPROTO_TCP:
+	case IPPROTO_UDP:
+	case IPPROTO_DCCP:
+	case IPPROTO_ESP:
+	case IPPROTO_AH:
+	case IPPROTO_SCTP:
+	case IPPROTO_UDPLITE:
+		if (pskb_may_pull(skb, (ihl * 4) + 4))
+			ports =3D *((u32 *) (skb->data + (ihl * 4)));
+		break;
+
+	default:
+		break;
+	}
+
+	skb->rxhash =3D jhash_3words(addr1, addr2, ports, hashrnd);
+	if (!skb->rxhash)
+		skb->rxhash =3D 1;
+
+got_hash:
+	cpu =3D map->map[((u64) skb->rxhash * map->len) >> 32];
+
+	if (!cpu_online(cpu))
+		cpu =3D -1;
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
+	struct softnet_data *queue =3D data;
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
+	queue =3D &per_cpu(softnet_data, cpu);
+
+	local_irq_save(flags);
+	__get_cpu_var(netdev_rx_stat).total++;
+
+	spin_lock(&queue->input_pkt_queue.lock);
+	if (queue->input_pkt_queue.qlen <=3D netdev_max_backlog) {
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
+			if (cpu !=3D smp_processor_id()) {
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
=20
 /**
  *	netif_rx	-	post buffer to the network code
@@ -2139,8 +2282,7 @@ DEFINE_PER_CPU(struct netif_rx_stats, netdev_rx_s=
tat) =3D { 0, };
=20
 int netif_rx(struct sk_buff *skb)
 {
-	struct softnet_data *queue;
-	unsigned long flags;
+	int cpu;
=20
 	/* if netpoll wants it, pretend we never saw it */
 	if (netpoll_rx(skb))
@@ -2149,31 +2291,12 @@ int netif_rx(struct sk_buff *skb)
 	if (!skb->tstamp.tv64)
 		net_timestamp(skb);
=20
-	/*
-	 * The code is rearranged so that the path is the most
-	 * short when CPU is congested, but is still operating.
-	 */
-	local_irq_save(flags);
-	queue =3D &__get_cpu_var(softnet_data);
-
-	__get_cpu_var(netdev_rx_stat).total++;
-	if (queue->input_pkt_queue.qlen <=3D netdev_max_backlog) {
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
=20
-	__get_cpu_var(netdev_rx_stat).dropped++;
-	local_irq_restore(flags);
+	cpu =3D get_rps_cpu(skb->dev, skb);
+	if (cpu < 0)
+		cpu =3D smp_processor_id();
=20
-	kfree_skb(skb);
-	return NET_RX_DROP;
+	return enqueue_to_backlog(skb, cpu);
 }
 EXPORT_SYMBOL(netif_rx);
=20
@@ -2411,10 +2534,10 @@ void netif_nit_deliver(struct sk_buff *skb)
 }
=20
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
@@ -2425,7 +2548,8 @@ void netif_nit_deliver(struct sk_buff *skb)
  *	NET_RX_SUCCESS: no congestion
  *	NET_RX_DROP: packet was dropped
  */
-int netif_receive_skb(struct sk_buff *skb)
+
+int __netif_receive_skb(struct sk_buff *skb)
 {
 	struct packet_type *ptype, *pt_prev;
 	struct net_device *orig_dev;
@@ -2536,6 +2660,16 @@ out:
 }
 EXPORT_SYMBOL(netif_receive_skb);
=20
+int netif_receive_skb(struct sk_buff *skb)
+{
+	int cpu =3D get_rps_cpu(skb->dev, skb);
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
@@ -2861,16 +2995,16 @@ static int process_backlog(struct napi_struct *=
napi, int quota)
 	do {
 		struct sk_buff *skb;
=20
-		local_irq_disable();
+		spin_lock_irq(&queue->input_pkt_queue.lock);
 		skb =3D __skb_dequeue(&queue->input_pkt_queue);
 		if (!skb) {
 			__napi_complete(napi);
-			local_irq_enable();
+			spin_unlock_irq(&queue->input_pkt_queue.lock);
 			break;
 		}
-		local_irq_enable();
+		spin_unlock_irq(&queue->input_pkt_queue.lock);
=20
-		netif_receive_skb(skb);
+		__netif_receive_skb(skb);
 	} while (++work < quota && jiffies =3D=3D start_time);
=20
 	return work;
@@ -2959,6 +3093,21 @@ void netif_napi_del(struct napi_struct *napi)
 }
 EXPORT_SYMBOL(netif_napi_del);
=20
+/*
+ * net_rps_action sends any pending IPI's for rps.  This is only calle=
d from
+ * softirq and interrupts must be enabled.
+ */
+static void net_rps_action(void)
+{
+	int cpu;
+
+	/* Send pending IPI's to kick RPS processing on remote cpus. */
+	for_each_cpu_mask_nr(cpu, __get_cpu_var(rps_remote_softirq_cpus)) {
+		struct softnet_data *queue =3D &per_cpu(softnet_data, cpu);
+		cpu_clear(cpu, __get_cpu_var(rps_remote_softirq_cpus));
+		__smp_call_function_single(cpu, &queue->csd, 0);
+	}
+}
=20
 static void net_rx_action(struct softirq_action *h)
 {
@@ -3030,6 +3179,8 @@ static void net_rx_action(struct softirq_action *=
h)
 out:
 	local_irq_enable();
=20
+	net_rps_action();
+
 #ifdef CONFIG_NET_DMA
 	/*
 	 * There may not be any more sk_buffs coming right now, so push
@@ -3274,10 +3425,10 @@ static int softnet_seq_show(struct seq_file *se=
q, void *v)
 {
 	struct netif_rx_stats *s =3D v;
=20
-	seq_printf(seq, "%08x %08x %08x %08x %08x %08x %08x %08x %08x\n",
+	seq_printf(seq, "%08x %08x %08x %08x %08x %08x %08x %08x %08x %08x\n"=
,
 		   s->total, s->dropped, s->time_squeeze, 0,
 		   0, 0, 0, 0, /* was fastroute */
-		   s->cpu_collision);
+		   s->cpu_collision, s->received_rps);
 	return 0;
 }
=20
@@ -5424,6 +5575,8 @@ void free_netdev(struct net_device *dev)
 	/* Flush device addresses */
 	dev_addr_flush(dev);
=20
+	kfree(dev->dev_rps_maps);
+
 	list_for_each_entry_safe(p, n, &dev->napi_list, dev_list)
 		netif_napi_del(p);
=20
@@ -5898,6 +6051,10 @@ static int __init net_dev_init(void)
 		queue->completion_queue =3D NULL;
 		INIT_LIST_HEAD(&queue->poll_list);
=20
+		queue->csd.func =3D trigger_softirq;
+		queue->csd.info =3D queue;
+		queue->csd.flags =3D 0;
+
 		queue->backlog.poll =3D process_backlog;
 		queue->backlog.weight =3D weight_p;
 		queue->backlog.gro_list =3D NULL;
@@ -5936,7 +6093,7 @@ subsys_initcall(net_dev_init);
=20
 static int __init initialize_hashrnd(void)
 {
-	get_random_bytes(&skb_tx_hashrnd, sizeof(skb_tx_hashrnd));
+	get_random_bytes(&hashrnd, sizeof(hashrnd));
 	return 0;
 }
=20
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index fbc1c74..a7e4db3 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -18,6 +18,9 @@
 #include <linux/wireless.h>
 #include <net/wext.h>
=20
+#include <linux/string.h>
+#include <linux/ctype.h>
+
 #include "net-sysfs.h"
=20
 #ifdef CONFIG_SYSFS
@@ -253,6 +256,134 @@ static ssize_t store_tx_queue_len(struct device *=
dev,
 	return netdev_store(dev, attr, buf, len, change_tx_queue_len);
 }
=20
+static char *get_token(const char **cp, size_t *len)
+{
+	const char *bp =3D *cp;
+	char *start;
+
+	while (isspace(*bp))
+		bp++;
+
+	start =3D (char *)bp;
+	while (!isspace(*bp) && *bp !=3D '\0')
+		bp++;
+
+	if (start !=3D bp)
+		*len =3D bp - start;
+	else
+		start =3D NULL;
+
+	*cp =3D bp;
+	return start;
+}
+
+static void dev_map_release(struct rcu_head *rcu)
+{
+	struct dev_rps_maps *drmap =3D
+	    container_of(rcu, struct dev_rps_maps, rcu);
+
+	kfree(drmap);
+}
+
+static ssize_t store_rps_cpus(struct device *dev,
+    struct device_attribute *attr, const char *buf, size_t len)
+{
+	struct net_device *net =3D to_net_dev(dev);
+	struct napi_struct *napi;
+	cpumask_t mask;
+	int err, cpu, index, i;
+	int cnt =3D 0;
+	char *token;
+	const char *cp =3D buf;
+	size_t tlen;
+	struct dev_rps_maps *drmap, *old_drmap;
+
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
+	cnt =3D 0;
+	list_for_each_entry(napi, &net->napi_list, dev_list)
+		cnt++;
+	if (cnt =3D=3D 0)
+		cnt =3D 1; /* For devices with no napi instances */
+
+	drmap =3D kzalloc(sizeof(struct dev_rps_maps) +
+	    RPS_MAP_SIZE * cnt, GFP_KERNEL);
+	if (!drmap)
+		return -ENOMEM;
+
+	drmap->num_maps =3D cnt;
+
+	cp =3D buf;
+	for (index =3D 0; index < cnt &&
+	   (token =3D get_token(&cp, &tlen)); index++) {
+		struct rps_map *map =3D (struct rps_map *)
+		    ((void *)drmap->maps + (RPS_MAP_SIZE * index));
+		err =3D bitmap_parse(token, tlen, cpumask_bits(&mask),
+		    nr_cpumask_bits);
+
+		if (err) {
+			kfree(drmap);
+			return err;
+		}
+
+		cpus_and(mask, mask, cpu_online_map);
+		i =3D 0;
+		for_each_cpu_mask(cpu, mask) {
+			if (i >=3D MAX_RPS_CPUS)
+				break;
+			map->map[i++] =3D  cpu;
+		}
+		map->len =3D i;
+	}
+
+	rtnl_lock();
+	old_drmap =3D net->dev_rps_maps;
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
+	struct net_device *net =3D to_net_dev(dev);
+	size_t len =3D 0;
+	cpumask_t mask;
+	int i, j;
+	struct dev_rps_maps *drmap;
+
+	rcu_read_lock_bh();
+	drmap =3D rcu_dereference(net->dev_rps_maps);
+
+	if (drmap) {
+		for (j =3D 0; j < drmap->num_maps; j++) {
+			struct rps_map *map =3D (struct rps_map *)
+			    ((void *)drmap->maps + (RPS_MAP_SIZE * j));
+			cpus_clear(mask);
+			for (i =3D 0; i < map->len; i++)
+				cpu_set(map->map[i], mask);
+
+			len +=3D cpumask_scnprintf(buf + len, PAGE_SIZE, &mask);
+			if (PAGE_SIZE - len < 3) {
+				rcu_read_unlock();
+				return -EINVAL;
+			}
+			if (j < drmap->num_maps)
+				len +=3D sprintf(buf + len, " ");
+		}
+	}
+
+	rcu_read_unlock_bh();
+
+	len +=3D sprintf(buf + len, "\n");
+	return len;
+}
+
 static ssize_t store_ifalias(struct device *dev, struct device_attribu=
te *attr,
 			     const char *buf, size_t len)
 {
@@ -309,6 +440,7 @@ static struct device_attribute net_class_attributes=
[] =3D {
 	__ATTR(flags, S_IRUGO | S_IWUSR, show_flags, store_flags),
 	__ATTR(tx_queue_len, S_IRUGO | S_IWUSR, show_tx_queue_len,
 	       store_tx_queue_len),
+	__ATTR(rps_cpus, S_IRUGO | S_IWUSR, show_rps_cpus, store_rps_cpus),
 	{}
 };
=20
