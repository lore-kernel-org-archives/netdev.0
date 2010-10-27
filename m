From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2 v4] xps: Transmit Packet Steering
Date: Wed, 27 Oct 2010 06:32:46 +0200
Message-ID: <1288153966.2652.62.camel@edumazet-laptop>
References: <alpine.DEB.1.00.1010262033520.2997@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:63110 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752908Ab0J0Ecw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Oct 2010 00:32:52 -0400
Received: by wyf28 with SMTP id 28so239315wyf.19
        for <netdev@vger.kernel.org>; Tue, 26 Oct 2010 21:32:51 -0700 (PDT)
In-Reply-To: <alpine.DEB.1.00.1010262033520.2997@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 26 octobre 2010 =C3=A0 20:38 -0700, Tom Herbert a =C3=A9crit :
> This patch implements transmit packet steering (XPS) for multiqueue
> devices.  XPS selects a transmit queue during packet transmission bas=
ed
> on configuration.  This is done by mapping the CPU transmitting the
> packet to a queue.  This is the transmit side analogue to RPS-- where
> RPS is selecting a CPU based on receive queue, XPS selects a queue
> based on the CPU (previously there was an XPS patch from Eric
> Dumazet, but that might more appropriately be called transmit complet=
ion
> steering).
>=20
> Each transmit queue can be associated with a number of CPUs which wil=
l
> use the queue to send packets.  This is configured as a CPU mask on a
> per queue basis in:
>=20
> /sys/class/net/eth<n>/queues/tx-<n>/xps_cpus
>=20
> The mappings are stored per device in an inverted data structure that
> maps CPUs to queues.  In the netdevice structure this is an array of
> num_possible_cpu structures where each structure holds and array of
> queue_indexes for queues which that CPU can use.
>=20
> The benefits of XPS are improved locality in the per queue data
> structures.  Also, transmit completions are more likely to be done
> nearer to the sending thread, so this should promote locality back
> to the socket on free (e.g. UDP).  The benefits of XPS are dependent =
on
> cache hierarchy, application load, and other factors.  XPS would
> nominally be configured so that a queue would only be shared by CPUs
> which are sharing a cache, the degenerative configuration woud be tha=
t
> each CPU has it's own queue.
>=20
> Below are some benchmark results which show the potential benfit of
> this patch.  The netperf test has 500 instances of netperf TCP_RR tes=
t
> with 1 byte req. and resp.
>=20
> bnx2x on 16 core AMD
>    XPS (16 queues, 1 TX queue per CPU)  1234K at 100% CPU
>    No XPS (16 queues)                   996K at 100% CPU
>=20
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
>  include/linux/netdevice.h |   27 ++++
>  net/core/dev.c            |   55 +++++++-
>  net/core/net-sysfs.c      |  367 +++++++++++++++++++++++++++++++++++=
+++++++++-
>  net/core/net-sysfs.h      |    3 +
>  4 files changed, 446 insertions(+), 6 deletions(-)
>=20
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index fcd3dda..f19b78b 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -503,6 +503,13 @@ struct netdev_queue {
>  	struct Qdisc		*qdisc;
>  	unsigned long		state;
>  	struct Qdisc		*qdisc_sleeping;
> +#ifdef CONFIG_RPS
> +	struct netdev_queue	*first;
> +	atomic_t		count;
> +	struct xps_dev_maps	*xps_maps;
> +	struct kobject		kobj;
> +#endif
> +
>  /*
>   * write mostly part
>   */
> @@ -530,6 +537,26 @@ struct rps_map {
>  #define RPS_MAP_SIZE(_num) (sizeof(struct rps_map) + (_num * sizeof(=
u16)))
> =20
>  /*
> + * This structure holds an XPS map which can be of variable length. =
 The
> + * map is an array of queues.
> + */
> +struct xps_map {
> +	unsigned int len;
> +	unsigned int alloc_len;
> +	struct rcu_head rcu;
> +	u16 queues[0];
> +};

OK, so its a 'small' structure. And we dont want it to share a cache
line with an other user in the kernel, or false sharing might happen.

Make sure you allocate big enough ones to fill a full cache line.

alloc_len =3D (L1_CACHE_BYTES - sizeof(struct xps_map)) / sizeof(u16);

I see you allocate ones with alloc_len =3D 1. Thats not good.

> +
> +/*
> + * This structure holds all XPS maps for device.  Maps are indexed b=
y CPU.
> + */
> +struct xps_dev_maps {
> +	struct rcu_head rcu;
> +	struct xps_map *cpu_map[0];

Hmm... per_cpu maybe, instead of an array ?

Also make sure this xps_dev_maps use a full cache line, to avoid false
sharing.

> +};
> +#define netdev_get_xps_maps(dev) ((dev)->_tx[0].xps_maps)
> +
> +/*
>   * The rps_dev_flow structure contains the mapping of a flow to a CP=
U and the
>   * tail pointer for that CPU's input queue at the time of last enque=
ue.
>   */
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 4df783c..12426a6 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2119,6 +2119,44 @@ static inline u16 dev_cap_txqueue(struct net_d=
evice *dev, u16 queue_index)
>  	return queue_index;
>  }
> =20
> +static inline int get_xps_queue(struct net_device *dev, struct sk_bu=
ff *skb)
> +{
> +#ifdef CONFIG_RPS
> +	struct xps_dev_maps *dev_maps;
> +	struct xps_map *map;
> +	int queue_index =3D -1;
> +
> +	preempt_disable();
> +	rcu_read_lock();
> +	dev_maps =3D rcu_dereference(netdev_get_xps_maps(dev));
> +	if (dev_maps) {
> +		map =3D rcu_dereference(dev_maps->cpu_map[smp_processor_id()]);

Really I am not sure we need this array and smp_processor_id().
Please consider alloc_percpu().
Then, use __this_cpu_ptr() and avoid the preempt_disable()/enable()
thing. Its a hint we want to use, because as soon as we leave
get_xps_queue() we might migrate to another cpu ?


> +		if (map) {
> +			if (map->len =3D=3D 1)
> +				queue_index =3D map->queues[0];
> +			else {
> +				u32 hash;
> +				if (skb->sk && skb->sk->sk_hash)
> +					hash =3D skb->sk->sk_hash;
> +				else
> +					hash =3D (__force u16) skb->protocol ^
> +					    skb->rxhash;
> +				hash =3D jhash_1word(hash, hashrnd);
> +				queue_index =3D map->queues[
> +				    ((u64)hash * map->len) >> 32];
> +			}
> +			if (unlikely(queue_index >=3D dev->real_num_tx_queues))
> +				queue_index =3D -1;
> +		}
> +	}
> +	rcu_read_unlock();
> +	preempt_enable();
> +
> +	return queue_index;
> +#endif
> +	return -1;
> +}
> +
>  static struct netdev_queue *dev_pick_tx(struct net_device *dev,
>  					struct sk_buff *skb)
>  {
> @@ -2138,7 +2176,9 @@ static struct netdev_queue *dev_pick_tx(struct =
net_device *dev,
>  		    queue_index >=3D dev->real_num_tx_queues) {
>  			int old_index =3D queue_index;
> =20
> -			queue_index =3D skb_tx_hash(dev, skb);
> +			queue_index =3D get_xps_queue(dev, skb);
> +			if (queue_index < 0)
> +				queue_index =3D skb_tx_hash(dev, skb);
> =20
>  			if (queue_index !=3D old_index && sk) {
>  				struct dst_entry *dst =3D
> @@ -5052,6 +5092,17 @@ static int netif_alloc_netdev_queues(struct ne=
t_device *dev)
>  		return -ENOMEM;
>  	}
>  	dev->_tx =3D tx;
> +#ifdef CONFIG_RPS
> +	/*
> +	 * Set a pointer to first element in the array which holds the
> +	 * reference count.
> +	 */
> +	{
> +		int i;
> +		for (i =3D 0; i < count; i++)
> +			tx[i].first =3D tx;
> +	}
> +#endif
>  	return 0;
>  }
> =20
> @@ -5616,7 +5667,9 @@ void free_netdev(struct net_device *dev)
> =20
>  	release_net(dev_net(dev));
> =20
> +#ifndef CONFIG_RPS
>  	kfree(dev->_tx);
> +#endif
> =20
>  	kfree(rcu_dereference_raw(dev->ingress_queue));
> =20
> diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
> index b143173..e193cf2 100644
> --- a/net/core/net-sysfs.c
> +++ b/net/core/net-sysfs.c
> @@ -764,18 +764,375 @@ net_rx_queue_update_kobjects(struct net_device=
 *net, int old_num, int new_num)
>  	return error;
>  }
> =20
> -static int rx_queue_register_kobjects(struct net_device *net)
> +/*
> + * netdev_queue sysfs structures and functions.
> + */
> +struct netdev_queue_attribute {
> +	struct attribute attr;
> +	ssize_t (*show)(struct netdev_queue *queue,
> +	    struct netdev_queue_attribute *attr, char *buf);
> +	ssize_t (*store)(struct netdev_queue *queue,
> +	    struct netdev_queue_attribute *attr, const char *buf, size_t le=
n);
> +};
> +#define to_netdev_queue_attr(_attr) container_of(_attr,		\
> +    struct netdev_queue_attribute, attr)
> +
> +#define to_netdev_queue(obj) container_of(obj, struct netdev_queue, =
kobj)
> +
> +static ssize_t netdev_queue_attr_show(struct kobject *kobj,
> +				      struct attribute *attr, char *buf)
> +{
> +	struct netdev_queue_attribute *attribute =3D to_netdev_queue_attr(a=
ttr);
> +	struct netdev_queue *queue =3D to_netdev_queue(kobj);
> +
> +	if (!attribute->show)
> +		return -EIO;
> +
> +	return attribute->show(queue, attribute, buf);
> +}
> +
> +static ssize_t netdev_queue_attr_store(struct kobject *kobj,
> +				       struct attribute *attr,
> +				       const char *buf, size_t count)
> +{
> +	struct netdev_queue_attribute *attribute =3D to_netdev_queue_attr(a=
ttr);
> +	struct netdev_queue *queue =3D to_netdev_queue(kobj);
> +
> +	if (!attribute->store)
> +		return -EIO;
> +
> +	return attribute->store(queue, attribute, buf, count);
> +}
> +
> +static const struct sysfs_ops netdev_queue_sysfs_ops =3D {
> +	.show =3D netdev_queue_attr_show,
> +	.store =3D netdev_queue_attr_store,
> +};
> +
> +static inline unsigned int get_netdev_queue_index(struct netdev_queu=
e *queue)
> +{
> +	struct net_device *dev =3D queue->dev;
> +	int i;
> +
> +	for (i =3D 0; i < dev->num_tx_queues; i++)
> +		if (queue =3D=3D &dev->_tx[i])
> +			break;
> +
> +	BUG_ON(i >=3D dev->num_tx_queues);
> +
> +	return i;
> +}
> +
> +
> +static ssize_t show_xps_map(struct netdev_queue *queue,
> +			    struct netdev_queue_attribute *attribute, char *buf)
> +{
> +	struct netdev_queue *first =3D queue->first;
> +	struct xps_dev_maps *dev_maps;
> +	cpumask_var_t mask;
> +	unsigned long index;
> +	size_t len =3D 0;
> +	int i;
> +
> +	if (!zalloc_cpumask_var(&mask, GFP_KERNEL))
> +		return -ENOMEM;
> +
> +	index =3D get_netdev_queue_index(queue);
> +
> +	rcu_read_lock();
> +	dev_maps =3D rcu_dereference(first->xps_maps);
> +	if (dev_maps) {
> +		for (i =3D 0; i < num_possible_cpus(); i++) {

The use of num_possible_cpus() seems wrong to me.
Dont you meant nr_cpu_ids ?

Some machines have two possible cpus, numbered 0 and 8 :
num_possible_cpus =3D 2
nr_cpu_ids =3D 8


anyway, using a per_cpu var, this loop becomes more friendly :

for_each_possible_cpu(i) {

and you use less ram, and you also use NUMA friendly allocations as
well.

> +			struct xps_map *map =3D
> +			    rcu_dereference(dev_maps->cpu_map[i]);
> +			if (map) {
> +				int j;
> +				for (j =3D 0; j < map->len; j++) {
> +					if (map->queues[j] =3D=3D index) {
> +						cpumask_set_cpu(i, mask);
> +						break;
> +					}
> +				}
> +			}
> +		}
> +	}
> +	len +=3D cpumask_scnprintf(buf + len, PAGE_SIZE, mask);
> +	if (PAGE_SIZE - len < 3) {
> +		rcu_read_unlock();
> +		free_cpumask_var(mask);
> +		return -EINVAL;
> +	}
> +	rcu_read_unlock();
> +
> +	free_cpumask_var(mask);
> +	len +=3D sprintf(buf + len, "\n");
> +	return len;
> +}
> +
> +static void xps_map_release(struct rcu_head *rcu)
> +{
> +	struct xps_map *map =3D container_of(rcu, struct xps_map, rcu);
> +
> +	kfree(map);
> +}
> +
> +static void xps_dev_maps_release(struct rcu_head *rcu)
>  {
> +	struct xps_dev_maps *dev_maps =3D
> +	    container_of(rcu, struct xps_dev_maps, rcu);
> +
> +	kfree(dev_maps);
> +}
> +
> +static DEFINE_MUTEX(xps_map_mutex);
> +
> +static ssize_t store_xps_map(struct netdev_queue *queue,
> +		      struct netdev_queue_attribute *attribute,
> +		      const char *buf, size_t len)
> +{
> +	struct netdev_queue *first =3D queue->first;
> +	cpumask_var_t mask;
> +	int err, i, cpu, pos, map_len, alloc_len, need_set;
> +	unsigned long index;
> +	struct xps_map *map, *new_map;
> +	struct xps_dev_maps *dev_maps, *new_dev_maps;
> +	int nonempty =3D 0;
> +
> +	if (!capable(CAP_NET_ADMIN))
> +		return -EPERM;
> +
> +	if (!alloc_cpumask_var(&mask, GFP_KERNEL))
> +		return -ENOMEM;
> +
> +	index =3D get_netdev_queue_index(queue);
> +
> +	err =3D bitmap_parse(buf, len, cpumask_bits(mask), nr_cpumask_bits)=
;
> +	if (err) {
> +		free_cpumask_var(mask);
> +		return err;
> +	}
> +
> +	new_dev_maps =3D kzalloc(sizeof(struct xps_dev_maps) +
> +	    (num_possible_cpus() * sizeof(struct xps_map *)), GFP_KERNEL);
> +	if (!new_dev_maps) {
> +		free_cpumask_var(mask);
> +		return err;
> +	}
> +
> +	mutex_lock(&xps_map_mutex);
> +
> +	dev_maps =3D first->xps_maps;
> +
> +	for (cpu =3D 0; cpu < num_possible_cpus(); cpu++) {
> +		new_map =3D map =3D dev_maps ? dev_maps->cpu_map[cpu] : NULL;
> +
> +		if (map) {
> +			for (pos =3D 0; pos < map->len; pos++)
> +				if (map->queues[pos] =3D=3D index)
> +					break;
> +			map_len =3D map->len;
> +			alloc_len =3D map->alloc_len;
> +		} else
> +			pos =3D map_len =3D alloc_len =3D 0;
> +
> +		need_set =3D cpu_isset(cpu, *mask) && cpu_online(cpu);
> +
> +		if (need_set && pos >=3D map_len) {
> +			/* Need to add queue to this CPU's map */
> +			if (map_len >=3D alloc_len) {
> +				alloc_len =3D alloc_len ?  2 * alloc_len : 1;

See my first comment : Please reserve use a full cache line here
Also please use kzalloc_node() to get better NUMA affinity.

> +				new_map =3D kzalloc(sizeof(struct xps_map) +
> +				    (alloc_len * sizeof(u16)), GFP_KERNEL);
> +				if (!new_map)
> +					goto error;
> +				new_map->alloc_len =3D alloc_len;
> +				for (i =3D 0; i < map_len; i++)
> +					new_map->queues[i] =3D map->queues[i];
> +				new_map->len =3D map_len;
> +			}
> +			new_map->queues[new_map->len++] =3D index;
> +		} else if (!need_set && pos < map_len) {
> +			/* Need to remove queue from this CPU's map */
> +			if (map_len > 1)
> +				new_map->queues[pos] =3D
> +				    new_map->queues[--new_map->len];
> +			else
> +				new_map =3D NULL;
> +		}
> +		new_dev_maps->cpu_map[cpu] =3D new_map;
> +	}


