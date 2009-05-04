From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH v2] Receive Packet Steering
Date: Mon, 04 May 2009 07:30:11 +0200
Message-ID: <49FE7D63.6050102@cosmosbay.com>
References: <65634d660905032103h614225dbg9911e290f5537fbf@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:45841 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751346AbZEDFa1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2009 01:30:27 -0400
In-Reply-To: <65634d660905032103h614225dbg9911e290f5537fbf@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tom Herbert a =E9crit :
> This is an update of the receive packet steering patch (RPS) based on=
 received
> comments (thanks for all the comments).  Improvements are:
>=20
> 1) Removed config option for the feature.
> 2) Made scheduling of backlog NAPI devices between CPUs lockless and =
much
> simpler.
> 3) Added new softirq to do defer sending IPIs for coalescing.
> 4) Imported hash from simple_rx_hash.  Eliminates modulo operation to=
 convert
> hash to index.
> 5) If no cpu is found for packet steering, then netif_receive_skb pro=
cesses
> packet inline as before without queueing.  In paritcular if RPS is no=
t
> configured on a device the receive path is unchanged from current for
> NAPI devices (one additional conditional).
>=20
> Tom

Seems cool, but I found two errors this morning before my cofee ;)

Is it a working patch or an RFC ?

Its also not clear from ChangeLog how this is working, and even
after reading your patch, its not yet very clear. Please provide
more documentation, on every submission.

What about latencies ? I really do think that if cpu handling=20
device is lightly loaded, it should handle packet itself, without
giving it to another cpu, incurring many cache lines bounces.

>=20
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
>=20
> diff --git a/include/linux/interrupt.h b/include/linux/interrupt.h
> index 91658d0..32ec04b 100644
> --- a/include/linux/interrupt.h
> +++ b/include/linux/interrupt.h
> @@ -260,6 +260,7 @@ enum
>  	TIMER_SOFTIRQ,
>  	NET_TX_SOFTIRQ,
>  	NET_RX_SOFTIRQ,
> +	NET_RPS_SOFTIRQ,
>  	BLOCK_SOFTIRQ,
>  	TASKLET_SOFTIRQ,
>  	SCHED_SOFTIRQ,
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index be3ebd7..f94ee96 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -758,6 +758,8 @@ struct net_device
>  	void			*ax25_ptr;	/* AX.25 specific data */
>  	struct wireless_dev	*ieee80211_ptr;	/* IEEE 802.11 specific data,
>  						   assign before registering */
> +	u16			*rps_map;
> +	int			rps_map_len;
>=20
>  /*
>   * Cache line mostly used on receive path (including eth_type_trans(=
))
> @@ -1170,6 +1172,9 @@ struct softnet_data
>  	struct Qdisc		*output_queue;
>  	struct sk_buff_head	input_pkt_queue;
>  	struct list_head	poll_list;
> +
> +	struct call_single_data	csd;
> +
>  	struct sk_buff		*completion_queue;
>=20
>  	struct napi_struct	backlog;
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 052dd47..3107544 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1906,6 +1906,142 @@ int weight_p __read_mostly =3D 64;           =
 /*
> old backlog weight */
>=20
>  DEFINE_PER_CPU(struct netif_rx_stats, netdev_rx_stat) =3D { 0, };
>=20
> +static u32 simple_hashrnd;
> +static int simple_hashrnd_initialized;
> +
> +static int get_rps_cpu(struct net_device *dev, struct sk_buff *skb)
> +{
> +	u32 addr1, addr2, ports;
> +	struct ipv6hdr *ip6;
> +	struct iphdr *ip;
> +	u32 hash, ihl;
> +	u8 ip_proto;
> +	int cpu;
> +
> +	if (!dev->rps_map_len)
> +		return -1;
> +
> +	if (unlikely(!simple_hashrnd_initialized)) {
> +		get_random_bytes(&simple_hashrnd, 4);
> +		simple_hashrnd_initialized =3D 1;
> +	}
> +
> +	switch (skb->protocol) {
> +	case __constant_htons(ETH_P_IP):
> +		if (!pskb_may_pull(skb, sizeof(*ip)))
> +			return -1;
> +
> +		ip =3D (struct iphdr *) skb->data;
> +		ip_proto =3D ip->protocol;
> +		addr1 =3D ip->saddr;
> +		addr2 =3D ip->daddr;
> +		ihl =3D ip->ihl;
> +		break;
> +	case __constant_htons(ETH_P_IPV6):
> +		if (!pskb_may_pull(skb, sizeof(*ip6)))
> +			return -1;
> +
> +		ip6 =3D (struct ipv6hdr *) skb->data;
> +		ip_proto =3D ip6->nexthdr;
> +		addr1 =3D ip6->saddr.s6_addr32[3];
> +		addr2 =3D ip6->daddr.s6_addr32[3];
> +		ihl =3D (40 >> 2);
> +		break;
> +	default:
> +		return -1;
> +	}
> +	ports =3D 0;
> +	switch (ip_proto) {
> +	case IPPROTO_TCP:
> +	case IPPROTO_UDP:
> +	case IPPROTO_DCCP:
> +	case IPPROTO_ESP:
> +	case IPPROTO_AH:
> +	case IPPROTO_SCTP:
> +	case IPPROTO_UDPLITE:
> +		if (pskb_may_pull(skb, (ihl * 4) + 4))
> +			ports =3D *((u32 *) (skb->data + (ihl * 4)));
> +		break;
> +
> +	default:
> +		break;
> +	}
> +
> +	hash =3D jhash_3words(addr1, addr2, ports, simple_hashrnd);
> +
> +	cpu =3D skb->dev->rps_map[((u64) hash * dev->rps_map_len) >> 32];
> +	return cpu_online(cpu) ? cpu : -1;
> +}
> +
> +static DEFINE_PER_CPU(cpumask_t, rps_remote_softirq_cpus);
> +
> +/* Called from hardirq (IPI) context */
> +static void trigger_softirq(void *data)
> +{
> +	struct softnet_data *queue =3D data;
> +	__napi_schedule(&queue->backlog);
> +}
> +
> +/**
> + * net_rps_action is called from NET_RPS_SOFTIRQ to do IPIs to sched=
ule RX
> + * softirq on remote CPUs.  Called in a separate softirq to allow fo=
r
> + * coalescing.
> + */
> +static void net_rps_action(struct softirq_action *h)
> +{
> +	int cpu;
> +
> +	local_irq_disable();
> +
> +	for_each_cpu_mask_nr(cpu, __get_cpu_var(rps_remote_softirq_cpus)) {
> +		struct softnet_data *queue =3D &per_cpu(softnet_data, cpu);
> +		__smp_call_function_single(cpu, &queue->csd);
> +	}
> +	cpus_clear(__get_cpu_var(rps_remote_softirq_cpus));
> +
> +	local_irq_enable();
> +}
> +
> +/**
> + * enqueue_to_backlog is called to queue an skb to a per CPU backlog
> + * queue (may be a remote CPU queue).
> + */
> +static int enqueue_to_backlog(struct sk_buff *skb, int cpu)
> +{
> +	struct softnet_data *queue;
> +	unsigned long flags;
> +
> +	queue =3D &per_cpu(softnet_data, cpu);
> +	spin_lock_irqsave(&queue->input_pkt_queue.lock, flags);

I wonder... isnt it going to really hurt with cache line ping pongs ?

> +
> +	__get_cpu_var(netdev_rx_stat).total++;
> +	if (queue->input_pkt_queue.qlen <=3D netdev_max_backlog) {
> +		if (queue->input_pkt_queue.qlen) {
> +enqueue:
> +			__skb_queue_tail(&queue->input_pkt_queue, skb);
> +			spin_unlock_irqrestore(&queue->input_pkt_queue.lock,
> +			    flags);
> +			return NET_RX_SUCCESS;
> +		}
> +
> +		/* Schedule NAPI for backlog device */
> +		if (napi_schedule_prep(&queue->backlog)) {
> +			if (cpu !=3D smp_processor_id()) {
> +				cpu_set(cpu,
> +				    get_cpu_var(rps_remote_softirq_cpus));

get_cpu_var() increases preempt_count (preempt_disable), where is the o=
pposite decrease ?

> +				__raise_softirq_irqoff(NET_RPS_SOFTIRQ);
> +			} else
> +				__napi_schedule(&queue->backlog);
> +		}
> +		goto enqueue;
> +	}
> +
> +	__get_cpu_var(netdev_rx_stat).dropped++;
> +	spin_unlock_irqrestore(&queue->input_pkt_queue.lock, flags);
> +
> +	kfree_skb(skb);
> +	return NET_RX_DROP;
> +}
>=20
>  /**
>   *	netif_rx	-	post buffer to the network code
> @@ -1924,8 +2060,7 @@ DEFINE_PER_CPU(struct netif_rx_stats,
> netdev_rx_stat) =3D { 0, };
>=20
>  int netif_rx(struct sk_buff *skb)
>  {
> -	struct softnet_data *queue;
> -	unsigned long flags;
> +	int cpu;
>=20
>  	/* if netpoll wants it, pretend we never saw it */
>  	if (netpoll_rx(skb))
> @@ -1934,31 +2069,11 @@ int netif_rx(struct sk_buff *skb)
>  	if (!skb->tstamp.tv64)
>  		net_timestamp(skb);
>=20
> -	/*
> -	 * The code is rearranged so that the path is the most
> -	 * short when CPU is congested, but is still operating.
> -	 */
> -	local_irq_save(flags);
> -	queue =3D &__get_cpu_var(softnet_data);
> +	cpu =3D get_rps_cpu(skb->dev, skb);
> +	if (cpu < 0)
> +		cpu =3D smp_processor_id();
>=20
> -	__get_cpu_var(netdev_rx_stat).total++;
> -	if (queue->input_pkt_queue.qlen <=3D netdev_max_backlog) {
> -		if (queue->input_pkt_queue.qlen) {
> -enqueue:
> -			__skb_queue_tail(&queue->input_pkt_queue, skb);
> -			local_irq_restore(flags);
> -			return NET_RX_SUCCESS;
> -		}
> -
> -		napi_schedule(&queue->backlog);
> -		goto enqueue;
> -	}
> -
> -	__get_cpu_var(netdev_rx_stat).dropped++;
> -	local_irq_restore(flags);
> -
> -	kfree_skb(skb);
> -	return NET_RX_DROP;
> +	return enqueue_to_backlog(skb, cpu);
>  }
>=20
>  int netif_rx_ni(struct sk_buff *skb)
> @@ -2192,10 +2307,10 @@ void netif_nit_deliver(struct sk_buff *skb)
>  }
>=20
>  /**
> - *	netif_receive_skb - process receive buffer from network
> + *	__netif_receive_skb - process receive buffer from network
>   *	@skb: buffer to process
>   *
> - *	netif_receive_skb() is the main receive data processing function.
> + *	__netif_receive_skb() is the main receive data processing functio=
n.
>   *	It always succeeds. The buffer may be dropped during processing
>   *	for congestion control or by the protocol layers.
>   *
> @@ -2206,7 +2321,7 @@ void netif_nit_deliver(struct sk_buff *skb)
>   *	NET_RX_SUCCESS: no congestion
>   *	NET_RX_DROP: packet was dropped
>   */
> -int netif_receive_skb(struct sk_buff *skb)
> +int __netif_receive_skb(struct sk_buff *skb)
>  {
>  	struct packet_type *ptype, *pt_prev;
>  	struct net_device *orig_dev;
> @@ -2305,6 +2420,16 @@ out:
>  	return ret;
>  }
>=20
> +int netif_receive_skb(struct sk_buff *skb)
> +{
> +	int cpu =3D get_rps_cpu(skb->dev, skb);
> +
> +	if (cpu < 0)
> +		return __netif_receive_skb(skb);
> +	else
> +		return enqueue_to_backlog(skb, cpu);
> +}
> +
>  /* Network device is going away, flush any packets still pending  */
>  static void flush_backlog(void *arg)
>  {
> @@ -2347,7 +2472,7 @@ static int napi_gro_complete(struct sk_buff *sk=
b)
>=20
>  out:
>  	skb_shinfo(skb)->gso_size =3D 0;
> -	return netif_receive_skb(skb);
> +	return __netif_receive_skb(skb);
>  }
>=20
>  void napi_gro_flush(struct napi_struct *napi)
> @@ -2484,7 +2609,7 @@ int napi_skb_finish(int ret, struct sk_buff *sk=
b)
>=20
>  	switch (ret) {
>  	case GRO_NORMAL:
> -		return netif_receive_skb(skb);
> +		return __netif_receive_skb(skb);
>=20
>  	case GRO_DROP:
>  		err =3D NET_RX_DROP;
> @@ -2585,7 +2710,7 @@ int napi_frags_finish(struct napi_struct *napi,
> struct sk_buff *skb, int ret)
>  		skb->protocol =3D eth_type_trans(skb, napi->dev);
>=20
>  		if (ret =3D=3D GRO_NORMAL)
> -			return netif_receive_skb(skb);
> +			return __netif_receive_skb(skb);
>=20
>  		skb_gro_pull(skb, -ETH_HLEN);
>  		break;
> @@ -2619,19 +2744,26 @@ static int process_backlog(struct napi_struct
> *napi, int quota)
>  	int work =3D 0;
>  	struct softnet_data *queue =3D &__get_cpu_var(softnet_data);
>  	unsigned long start_time =3D jiffies;
> +	unsigned long flags;
>=20
>  	napi->weight =3D weight_p;
>  	do {
>  		struct sk_buff *skb;
>=20
> -		local_irq_disable();
> +		spin_lock_irqsave(&queue->input_pkt_queue.lock, flags);
>  		skb =3D __skb_dequeue(&queue->input_pkt_queue);
>  		if (!skb) {
> -			local_irq_enable();
> -			napi_complete(napi);
> +			spin_unlock_irqrestore(&queue->input_pkt_queue.lock,
> +			    flags);
> +			napi_gro_flush(napi);
> +			spin_lock_irqsave(&queue->input_pkt_queue.lock, flags);
> +			if (skb_queue_empty(&queue->input_pkt_queue))
> +				__napi_complete(napi);
> +			spin_unlock_irqrestore(&queue->input_pkt_queue.lock,
> +			    flags);
>  			goto out;
>  		}
> -		local_irq_enable();
> +		spin_unlock_irqrestore(&queue->input_pkt_queue.lock, flags);
>=20
>  		napi_gro_receive(napi, skb);
>  	} while (++work < quota && jiffies =3D=3D start_time);
> @@ -4804,6 +4936,8 @@ void free_netdev(struct net_device *dev)
>=20
>  	kfree(dev->_tx);
>=20
> +	kfree(dev->rps_map);
> +
>  	list_for_each_entry_safe(p, n, &dev->napi_list, dev_list)
>  		netif_napi_del(p);
>=20
> @@ -5239,6 +5373,10 @@ static int __init net_dev_init(void)
>  		queue->completion_queue =3D NULL;
>  		INIT_LIST_HEAD(&queue->poll_list);
>=20
> +		queue->csd.func =3D trigger_softirq;
> +		queue->csd.info =3D queue;
> +		queue->csd.flags =3D 0;
> +
>  		queue->backlog.poll =3D process_backlog;
>  		queue->backlog.weight =3D weight_p;
>  		queue->backlog.gro_list =3D NULL;
> @@ -5264,6 +5402,7 @@ static int __init net_dev_init(void)
>=20
>  	open_softirq(NET_TX_SOFTIRQ, net_tx_action);
>  	open_softirq(NET_RX_SOFTIRQ, net_rx_action);
> +	open_softirq(NET_RPS_SOFTIRQ, net_rps_action);
>=20
>  	hotcpu_notifier(dev_cpu_callback, 0);
>  	dst_init();
> diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
> index 2da59a0..073a407 100644
> --- a/net/core/net-sysfs.c
> +++ b/net/core/net-sysfs.c
> @@ -211,6 +211,63 @@ static ssize_t store_tx_queue_len(struct device =
*dev,
>  	return netdev_store(dev, attr, buf, len, change_tx_queue_len);
>  }
>=20
> +static ssize_t store_rps_cpus(struct device *dev,
> +			      struct device_attribute *attr,
> +			      const char *buf, size_t len)
> +{
> +	struct net_device *net =3D to_net_dev(dev);
> +	cpumask_t mask;
> +	int err, cpu;
> +	int i =3D 0;
> +
> +	if (!capable(CAP_NET_ADMIN))
> +		return -EPERM;
> +
> +	err =3D bitmap_parse(buf, len, cpumask_bits(&mask), nr_cpumask_bits=
);
> +	if (err)
> +		return err;
> +
> +	rtnl_lock();
> +	if (dev_isalive(net)) {
> +		if (!net->rps_map) {
> +			net->rps_map =3D kzalloc(sizeof(u16) *
> +			    num_possible_cpus(), GFP_KERNEL);

num_possible_cpus() is not the max index of a cpu, but the number of po=
ssible cpus.
it can be for example 2, but cpu0 being index 0, and second cpu at inde=
x 511

So I believe you want nr_cpu_ids here

(num_possible_cpus() <=3D nr_cpu_ids), not necessarly equal.=20


> +			if (!net->rps_map)
> +				return -ENOMEM;
> +		}
> +		cpus_and(mask, mask, cpu_online_map);
> +		for_each_cpu_mask(cpu, mask)
> +			net->rps_map[i++] =3D  cpu;
> +		net->rps_map_len =3D i;
> +	}
> +	rtnl_unlock();
> +
> +	return len;
> +}
> +
> +static ssize_t show_rps_cpus(struct device *dev,
> +			     struct device_attribute *attr,
> +			     char *buf)
> +{
> +	struct net_device *net =3D to_net_dev(dev);
> +	size_t len;
> +	cpumask_t mask;
> +	int i;
> +
> +	read_lock(&dev_base_lock);
> +	if (dev_isalive(net))
> +		for (i =3D 0; i < net->rps_map_len; i++)
> +			cpu_set(net->rps_map[i], mask);
> +	read_unlock(&dev_base_lock);
> +
> +	len =3D cpumask_scnprintf(buf, PAGE_SIZE, &mask);
> +	if (PAGE_SIZE - len < 2)
> +		return -EINVAL;
> +
> +	len +=3D sprintf(buf + len, "\n");
> +	return len;
> +}
> +
>  static ssize_t store_ifalias(struct device *dev, struct device_attri=
bute *attr,
>  			     const char *buf, size_t len)
>  {
> @@ -263,6 +320,8 @@ static struct device_attribute net_class_attribut=
es[] =3D {
>  	__ATTR(flags, S_IRUGO | S_IWUSR, show_flags, store_flags),
>  	__ATTR(tx_queue_len, S_IRUGO | S_IWUSR, show_tx_queue_len,
>  	       store_tx_queue_len),
> +	__ATTR(soft_rps_cpus, S_IRUGO | S_IWUSR, show_rps_cpus,
> +	       store_rps_cpus),
>  	{}
>  };


