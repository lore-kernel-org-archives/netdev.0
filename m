From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v4 1/1] rps: core implementation
Date: Sat, 21 Nov 2009 09:07:59 +0100
Message-ID: <4B079FDF.9040809@gmail.com>
References: <65634d660911201528k5a07135el471b65fff9dd7c9d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Andi Kleen <andi@firstfloor.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:53878 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751114AbZKUIII (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Nov 2009 03:08:08 -0500
In-Reply-To: <65634d660911201528k5a07135el471b65fff9dd7c9d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tom Herbert a =E9crit :
> Version 4 of RPS patch.  I think this addresses most of the comments
> on the previous versions.  Thanks for all the insightful comments and
> patience!
>=20
> Changes from previous version:
>=20
> - Added rxhash to kernel-doc for struct sk_buff
> - Removed /** on comments not for kernel-doc
> - Change get_token declaration to kernel style
> - Added struct dev_rps_maps.  Each netdevice now has a pointer to thi=
s
> structure which contains the array of per NAPI rps maps, the number o=
f
> this maps.  rcu is used to protect pointer
> - In store_rps_cpus a new map set is allocated each call.
> - Removed dev_isalive check and other locks since rps struct in
> netdevice are protected by rcu
> - Removed NET_RPS_SOFTIRQ and call net_rps_action from net_rx_action =
instead
> - Queue to remote backlog queues only in NAPI case.  This means
> rps_remote_softirq_cpus does not need to be accessed with interrupts
> disabled and __smp_call_function_single will not be called with
> interrupts disabled
> - Limit the number of entries in an rps map to min(256, num_possible_=
cpus())
> - Removed unnecessary irq_local_disable
> - Renamed skb_tx_hashrnd to just hashrnd and use that for the rps has=
h as well
> - Make index u16 in index=3Dskb_get_rx_queue() and don't check index<=
0 now
> - Replace spin_lock_irqsave with simpler spin_lock_irq in process_bac=
klog

Excellent !

>   *	The DEVICE structure.
>   *	Actually, this whole structure is a big mistake.  It mixes I/O
>   *	data with strictly "high-level" data, and it has to know about
> @@ -861,6 +884,9 @@ struct net_device {
>=20
>  	struct netdev_queue	rx_queue;
>=20
> +	struct dev_rps_maps	*dev_rps_maps;	/* Per-NAPI maps for
> +						   receive packet steeing */
> +
>  	struct netdev_queue	*_tx ____cacheline_aligned_in_smp;
>=20
>  	/* Number of TX queues allocated at alloc_netdev_mq() time  */
> @@ -1276,6 +1302,9 @@ struct softnet_data {
>  	struct Qdisc		*output_queue;
>  	struct sk_buff_head	input_pkt_queue;
>  	struct list_head	poll_list;
> +
> +	struct call_single_data	csd;

This is problematic. softnet_data used to be only used by local cpu.
With RPS, other cpus are going to access csd, input_pkt_queue, backlog
and dirty cache lines.

Maybe we should split sofnet_data in two cache lines, one private,
one chared, and=20
DEFINE_PER_CPU(struct softnet_data, softnet_data);
->=20
DEFINE_PER_CPU_ALIGNED(struct softnet_data, softnet_data);

Also you need to change comment at start of struct softnet_data,
since it is wrong after RPS.

/*
 * Incoming packets are placed on per-cpu queues so that
 * no locking is needed.
 */

> +
>  	struct sk_buff		*completion_queue;
>=20
>  	struct napi_struct	backlog;
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index 63f4742..f188301 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -267,6 +267,7 @@ typedef unsigned char *sk_buff_data_t;
>   *	@mac_header: Link layer header
>   *	@_skb_dst: destination entry
>   *	@sp: the security path, used for xfrm
> + *	@rxhash: the packet hash computed on receive
>   *	@cb: Control buffer. Free for use by every layer. Put private var=
s here
>   *	@len: Length of actual data
>   *	@data_len: Data length
> @@ -323,6 +324,8 @@ struct sk_buff {
>  #ifdef CONFIG_XFRM
>  	struct	sec_path	*sp;
>  #endif
> +	__u32			rxhash;
> +
>  	/*
>  	 * This is the control buffer. It is free to use for every
>  	 * layer. Please put your private variables there. If you
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 9977288..f2c199c 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1834,7 +1834,7 @@ out_kfree_skb:
>  	return rc;
>  }
>=20
> -static u32 skb_tx_hashrnd;
> +static u32 hashrnd;
adding a __read_mostly here could help :)

>=20
>  u16 skb_tx_hash(const struct net_device *dev, const struct sk_buff *=
skb)
>  {
> @@ -1852,7 +1852,7 @@ u16 skb_tx_hash(const struct net_device *dev,
> const struct sk_buff *skb)
>  	else
>  		hash =3D skb->protocol;
>=20
> -	hash =3D jhash_1word(hash, skb_tx_hashrnd);
> +	hash =3D jhash_1word(hash, hashrnd);
>=20
>  	return (u16) (((u64) hash * dev->real_num_tx_queues) >> 32);
>  }
> @@ -2073,6 +2073,146 @@ int weight_p __read_mostly =3D 64;           =
 /*
> old backlog weight */
>=20
>  DEFINE_PER_CPU(struct netif_rx_stats, netdev_rx_stat) =3D { 0, };
>=20
> +/*
> + * get_rps_cpu is called from netif_receive_skb and returns the targ=
et
> + * CPU from the RPS map of the receiving NAPI instance for a given s=
kb.
> + */
> +static int get_rps_cpu(struct net_device *dev, struct sk_buff *skb)
> +{
> +	u32 addr1, addr2, ports;
> +	struct ipv6hdr *ip6;
> +	struct iphdr *ip;
> +	u32 hash, ihl;
> +	u8 ip_proto;
> +	int cpu =3D -1;
> +	struct dev_rps_maps *drmap;
> +	struct rps_map *map =3D NULL;
> +	u16 index;
> +

> +	rcu_read_lock();
If called from netif_receive_skb(), we already are in a rcu protected s=
ection,
but this could be a cleanup patch, because many other parts in stack co=
uld
be changed as well.


> +/*
> + * enqueue_to_backlog is called to queue an skb to a per CPU backlog
> + * queue (may be a remote CPU queue).
> + */
> +static int enqueue_to_backlog(struct sk_buff *skb, int cpu)
> +{
> +	struct softnet_data *queue;
> +	unsigned long flags;
> +
> +	queue =3D &per_cpu(softnet_data, cpu);
> +


> +	local_irq_save(flags);
> +	__get_cpu_var(netdev_rx_stat).total++;
> +
> +	spin_lock(&queue->input_pkt_queue.lock);

could reduce to :
	percpu_add(netdev_rx_stat.total, 1);
	spin_lock_irqsave(&queue->input_pkt_queue.lock, flags);

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

  Is it legal (or wanter at all) to call napi_schedule_prep() on remote=
 cpu backlog ?

> +			if (cpu !=3D smp_processor_id()) {
> +				cpu_set(cpu,
> +				    get_cpu_var(rps_remote_softirq_cpus));
> +				__raise_softirq_irqoff(NET_RX_SOFTIRQ);
> +			} else
> +				__napi_schedule(&queue->backlog);

Why not the more easy :
	if (cpu !=3D smp_processor_id())
		cpu_set(cpu, get_cpu_var(rps_remote_softirq_cpus));
	else
		napi_schedule(&queue->backlog);

This way we dont touch to remote backlog (and this backlog could stay i=
n the private
cache line of remote cpu)

> +		}
> +		goto enqueue;
> +	}
> +

> +	spin_unlock(&queue->input_pkt_queue.lock);
> +
> +	__get_cpu_var(netdev_rx_stat).dropped++;
> +	local_irq_restore(flags);

->=20
	spin_unlock_irqrestore(&queue->input_pkt_queue.lock, flags);
	percpu_add(netdev_rx_stat.dropped, 1);


+/*
+ * net_rps_action sends any pending IPI's for rps.  This is only calle=
d from
+ * softirq and interrupts must be enabled.
+ */
+static void net_rps_action(void)
+{
+       int cpu;
+
+       /* Send pending IPI's to kick RPS processing on remote cpus. */
+       for_each_cpu_mask_nr(cpu, __get_cpu_var(rps_remote_softirq_cpus=
)) {
+               struct softnet_data *queue =3D &per_cpu(softnet_data, c=
pu);
+               __smp_call_function_single(cpu, &queue->csd, 0);
+       }
+       cpus_clear(__get_cpu_var(rps_remote_softirq_cpus));
+}


net_rps_action() might be not very descriptive name and bit expensive..=
=2E

Did you tried smp_call_function_many() ?
(I suspect you did, but found it was not that optimized ?)

CC Andi to get feedback from him :)

static void net_rps_remcpus_fire(void)
{
	smp_call_function_many(__get_cpu_var(rps_remote_softirq_cpus),
			       trigger_softirq, NULL, 0);
}

Of course you would have to use following code as well :
(eg ignore void *data argument)

static void trigger_softirq(void *data)
{
/* kind of :
 * __napi_schedule(__get_cpu_var(softnet_data).backlog);
 * without local_irq_save(flags);/local_irq_restore(flags);
 */
	list_add_tail(&n->poll_list, &__get_cpu_var(softnet_data).poll_list);
	__raise_softirq_irqoff(NET_RX_SOFTIRQ);
}

Thanks Herbert

