From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] xps-mq: Transmit Packet Steering for multiqueue
Date: Mon, 23 Aug 2010 10:59:33 -0700
Message-ID: <20100823105933.27cd0b80@nehalam>
References: <alpine.DEB.1.00.1008222233530.31382@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, eric.dumazet@gmail.com
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:42455 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751423Ab0HWR7h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Aug 2010 13:59:37 -0400
In-Reply-To: <alpine.DEB.1.00.1008222233530.31382@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 22 Aug 2010 22:39:57 -0700 (PDT)
Tom Herbert <therbert@google.com> wrote:

> This patch implements transmit packet steering (XPS) for multiqueue
> devices.  XPS selects a transmit queue during packet transmission based
> on configuration.  This is done by mapping the CPU transmitting the
> packet to a queue.  This is the transmit side analogue to RPS-- where
> RPS is selecting a CPU based on receive queue, XPS selects a queue
> based on the CPU (previously there was an XPS patch from Eric
> Dumazet, but that might more appropriately be called transmit completion
> steering).
> 
> Each transmit queue can be associated with a number of CPUs which will
> used the queue to send packets.  This is configured as a CPU mask on a
> per queue basis in:
> 
> /sys/class/net/eth<n>/queues/tx-<n>/xps_cpus
> 
> The mappings are stored per device in an inverted data structure that
> maps CPUs to queues.  In the netdevice structure this is an array of
> num_possible_cpu structures where each array entry contains a bit map
> of queues which that CPU can use.
> 
> We also allow the mapping of a socket to queue to be modified, for
> instance if a thread is scheduled on a different CPU the desired queue
> for transmitting packets would likely change.  To maintain in order
> packet transmission a flag (ooo_okay) has been added to the sk_buf
> structure.  If a transport layer sets this flag on a packet, the
> transmit queue can be changed for this socket.  Presumably, the
> transport would set this is there was no possbility of creating ooo
> packets (for instance there are no packets in flight for the socket).
> This patch includes the modification in TCP output for setting this
> flag.
> 
> The benefits of XPS are improved locality in the per queue data
> strutures.  Also, transmit completions are more likely to be done
> nearer to the sending thread so this should promote locality back 
> to the socket (e.g. UDP).  The benefits of XPS are dependent on
> cache hierarchy, application load, and other factors.  XPS would
> nominally be configured so that a queue would only be shared by CPUs
> which are sharing a cache, the degenerative configuration woud be that
> each CPU has it's own queue.
> 
> Below are some benchmark results which show the potential benfit of
> this patch.  The netperf test has 500 instances of netperf TCP_RR test
> with 1 byte req. and resp.
> 
> bnx2x on 16 core AMD
>    XPS (16 queues, 1 TX queue per CPU)	1015K at 99% CPU
>    No XPS (16 queues)			1127K at 98% CPU
> 
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 46c36ff..0ff6c9f 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -497,6 +497,12 @@ struct netdev_queue {
>  	struct Qdisc		*qdisc;
>  	unsigned long		state;
>  	struct Qdisc		*qdisc_sleeping;
> +#ifdef CONFIG_RPS
> +	struct kobject		kobj;
> +	struct netdev_queue	*first;
> +	atomic_t		count;
> +#endif
> +
>  /*
>   * write mostly part
>   */
> @@ -524,6 +530,22 @@ struct rps_map {
>  #define RPS_MAP_SIZE(_num) (sizeof(struct rps_map) + (_num * sizeof(u16)))
>  
>  /*
> + * This structure holds an XPS map which can be of variable length.  queues
> + * is an array of num_possible_cpus entries, where each entry is a mask of
> + * queues for that CPU (up to num_tx_queues bits for device).
> + */
> +struct xps_map {
> +	struct rcu_head rcu;
> +	unsigned long queues[0];
> +};
> +
> +#define QUEUE_MASK_SIZE(dev) (BITS_TO_LONGS(dev->num_tx_queues))
> +#define XPS_MAP_SIZE(dev) (sizeof(struct xps_map) + (num_possible_cpus() * \
> +    QUEUE_MASK_SIZE(dev) * sizeof(unsigned long)))
> +#define XPS_ENTRY(map, offset, dev) \
> +    (&map->queues[offset * QUEUE_MASK_SIZE(dev)])
> +
> +/*
>   * The rps_dev_flow structure contains the mapping of a flow to a CPU and the
>   * tail pointer for that CPU's input queue at the time of last enqueue.
>   */
> @@ -978,6 +1000,9 @@ struct net_device {
>  	void			*rx_handler_data;
>  
>  	struct netdev_queue	*_tx ____cacheline_aligned_in_smp;
> +#ifdef CONFIG_RPS
> +	struct xps_map		*xps_maps;
> +#endif
>  
>  	/* Number of TX queues allocated at alloc_netdev_mq() time  */
>  	unsigned int		num_tx_queues;
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index f067c95..146df6f 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -381,6 +381,7 @@ struct sk_buff {
>  #else
>  	__u8			deliver_no_wcard:1;
>  #endif
> +	__u8			ooo_okay:1;
>  	kmemcheck_bitfield_end(flags2);
>  
>  	/* 0/14 bit hole */
> diff --git a/net/core/dev.c b/net/core/dev.c
> index da584f5..d23f9c4 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2054,6 +2054,60 @@ static inline u16 dev_cap_txqueue(struct net_device *dev, u16 queue_index)
>  	return queue_index;
>  }
>  
> +static inline int get_xps_queue(struct net_device *dev, struct sk_buff *skb,
> +				int queue_index)
> +{
> +	struct xps_map *maps;
> +	int cpu = smp_processor_id();
> +	u32 hash;
> +	unsigned long *queues;
> +	int weight, select;
> +
> +	rcu_read_lock();
> +	maps = rcu_dereference(dev->xps_maps);
> +
> +	if (!maps) {
> +		rcu_read_unlock();
> +		return queue_index;
> +	}
> +
> +	queues = XPS_ENTRY(maps, cpu, dev);
> +
> +	if (queue_index >= 0) {
> +		if (test_bit(queue_index, queues)) {
> +			rcu_read_unlock();
> +			return queue_index;
> +		}
> +	}
> +
> +	weight = bitmap_weight(queues, dev->real_num_tx_queues);
> +	switch (weight) {
> +	case 0:
> +		break;
> +	case 1:
> +		queue_index =
> +		    find_first_bit(queues, dev->real_num_tx_queues);
> +		break;
> +	default:
> +		if (skb->sk && skb->sk->sk_hash)
> +			hash = skb->sk->sk_hash;
> +		else
> +			hash = (__force u16) skb->protocol ^ skb->rxhash;
> +		hash = jhash_1word(hash, hashrnd);
> +
> +		select = ((u64) hash * weight) >> 32;
> +		queue_index =
> +		    find_first_bit(queues, dev->real_num_tx_queues);
> +		while (select--)
> +			queue_index = find_next_bit(queues,
> +			    dev->real_num_tx_queues, queue_index);
> +		break;
> +	}
> +
> +	rcu_read_unlock();
> +	return queue_index;
> +}
> +
>  static struct netdev_queue *dev_pick_tx(struct net_device *dev,
>  					struct sk_buff *skb)
>  {
> @@ -2061,23 +2115,30 @@ static struct netdev_queue *dev_pick_tx(struct net_device *dev,
>  	struct sock *sk = skb->sk;
>  
>  	queue_index = sk_tx_queue_get(sk);
> -	if (queue_index < 0) {
> +
> +	if (queue_index < 0 || (skb->ooo_okay && dev->real_num_tx_queues > 1)) {
>  		const struct net_device_ops *ops = dev->netdev_ops;
> +		int old_index = queue_index;
>  
>  		if (ops->ndo_select_queue) {
>  			queue_index = ops->ndo_select_queue(dev, skb);
>  			queue_index = dev_cap_txqueue(dev, queue_index);
>  		} else {
> -			queue_index = 0;
> -			if (dev->real_num_tx_queues > 1)
> -				queue_index = skb_tx_hash(dev, skb);
> +			if (dev->real_num_tx_queues > 1) {
> +				queue_index = get_xps_queue(dev,
> +				    skb, queue_index);
> +				if (queue_index < 0)
> +					queue_index = skb_tx_hash(dev, skb);
> +			} else
> +				queue_index = 0;
> +		}
>  
> -			if (sk) {
> -				struct dst_entry *dst = rcu_dereference_check(sk->sk_dst_cache, 1);
> +		if ((queue_index != old_index) && sk) {
> +			struct dst_entry *dst =
> +			    rcu_dereference_check(sk->sk_dst_cache, 1);
>  
> -				if (dst && skb_dst(skb) == dst)
> -					sk_tx_queue_set(sk, queue_index);
> -			}
> +			if (dst && skb_dst(skb) == dst)
> +				sk_tx_queue_set(sk, queue_index);
>  		}
>  	}
>  
> @@ -5429,6 +5490,15 @@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
>  	}
>  
>  #ifdef CONFIG_RPS
> +	atomic_set(&tx->count, queue_count);
> +
> +	/*
> +	 * Set a pointer to first element in the array which holds the
> +	 * reference count.
> +	 */
> +	for (i = 0; i < queue_count; i++)
> +		tx[i].first = tx;
> +
>  	rx = kcalloc(queue_count, sizeof(struct netdev_rx_queue), GFP_KERNEL);
>  	if (!rx) {
>  		printk(KERN_ERR "alloc_netdev: Unable to allocate "
> @@ -5506,7 +5576,9 @@ void free_netdev(struct net_device *dev)
>  
>  	release_net(dev_net(dev));
>  
> +#ifndef CONFIG_RPS
>  	kfree(dev->_tx);
> +#endif
>  
>  	/* Flush device addresses */
>  	dev_addr_flush(dev);
> diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
> index af4dfba..661c481 100644
> --- a/net/core/net-sysfs.c
> +++ b/net/core/net-sysfs.c
> @@ -742,34 +742,295 @@ static int rx_queue_add_kobject(struct net_device *net, int index)
>  	return error;
>  }
>  
> -static int rx_queue_register_kobjects(struct net_device *net)
> +/*
> + * netdev_queue sysfs structures and functions.
> + */
> +struct netdev_queue_attribute {
> +	struct attribute attr;
> +	ssize_t (*show)(struct netdev_queue *queue,
> +	    struct netdev_queue_attribute *attr, char *buf);
> +	ssize_t (*store)(struct netdev_queue *queue,
> +	    struct netdev_queue_attribute *attr, const char *buf, size_t len);
> +};
> +#define to_netdev_queue_attr(_attr) container_of(_attr,		\
> +    struct netdev_queue_attribute, attr)
> +
> +#define to_netdev_queue(obj) container_of(obj, struct netdev_queue, kobj)
> +
> +static ssize_t netdev_queue_attr_show(struct kobject *kobj,
> +				      struct attribute *attr, char *buf)
> +{
> +	struct netdev_queue_attribute *attribute = to_netdev_queue_attr(attr);
> +	struct netdev_queue *queue = to_netdev_queue(kobj);
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
> +	struct netdev_queue_attribute *attribute = to_netdev_queue_attr(attr);
> +	struct netdev_queue *queue = to_netdev_queue(kobj);
> +
> +	if (!attribute->store)
> +		return -EIO;
> +
> +	return attribute->store(queue, attribute, buf, count);
> +}
> +
> +static struct sysfs_ops netdev_queue_sysfs_ops = {
> +	.show = netdev_queue_attr_show,
> +	.store = netdev_queue_attr_store,
> +};
> +
> +static inline unsigned int get_netdev_queue_index(struct netdev_queue *queue)
>  {
> +	struct net_device *dev = queue->dev;
> +	int i;
> +
> +	for (i = 0; i < dev->num_tx_queues; i++)
> +		if (queue == &dev->_tx[i])
> +			break;
> +
> +	BUG_ON(i >= dev->num_tx_queues);
> +
> +	return i;
> +}
> +
> +static ssize_t show_xps_map(struct netdev_queue *queue,
> +			    struct netdev_queue_attribute *attribute, char *buf)
> +{
> +	struct net_device *dev = queue->dev;
> +	struct xps_map *maps;
> +	cpumask_var_t mask;
> +	unsigned long *qmask, index;
> +	size_t len = 0;
>  	int i;
> +	unsigned int qmask_size = QUEUE_MASK_SIZE(dev);
> +
> +	if (!zalloc_cpumask_var(&mask, GFP_KERNEL))
> +		return -ENOMEM;
> +
> +	index = get_netdev_queue_index(queue);
> +
> +	rcu_read_lock();
> +	maps = rcu_dereference(dev->xps_maps);
> +	if (maps) {
> +		qmask = maps->queues;
> +		for (i = 0; i < num_possible_cpus(); i++) {
> +			if (test_bit(index, qmask))
> +				cpumask_set_cpu(i, mask);
> +			qmask += qmask_size;
> +		}
> +	}
> +	len += cpumask_scnprintf(buf + len, PAGE_SIZE, mask);
> +	if (PAGE_SIZE - len < 3) {
> +		rcu_read_unlock();
> +		free_cpumask_var(mask);
> +		return -EINVAL;
> +	}
> +	rcu_read_unlock();
> +
> +	free_cpumask_var(mask);
> +	len += sprintf(buf + len, "\n");
> +	return len;
> +}
> +
> +static void xps_map_release(struct rcu_head *rcu)
> +{
> +	struct xps_map *map = container_of(rcu, struct xps_map, rcu);
> +
> +	kfree(map);
> +}
> +
> +static DEFINE_MUTEX(xps_map_lock);
> +
> +static ssize_t store_xps_map(struct netdev_queue *queue,
> +		      struct netdev_queue_attribute *attribute,
> +		      const char *buf, size_t len)
> +{
> +	struct net_device *dev = queue->dev;
> +	struct xps_map *maps;
> +	cpumask_var_t mask;
> +	int err, i, nonempty = 0;
> +	unsigned long *qmask, index;
> +	unsigned int qmask_size = QUEUE_MASK_SIZE(dev);
> +
> +	if (!capable(CAP_NET_ADMIN))
> +		return -EPERM;
> +
> +	if (!alloc_cpumask_var(&mask, GFP_KERNEL))
> +		return -ENOMEM;
> +
> +	err = bitmap_parse(buf, len, cpumask_bits(mask), nr_cpumask_bits);
> +	if (err) {
> +		free_cpumask_var(mask);
> +		return err;
> +	}
> +
> +	mutex_lock(&xps_map_lock);
> +
> +	maps = dev->xps_maps;
> +	if (!maps) {
> +		if (!cpumask_weight(mask)) {
> +			mutex_unlock(&xps_map_lock);
> +			free_cpumask_var(mask);
> +			return 0;
> +		}
> +		maps = kzalloc(XPS_MAP_SIZE(dev), GFP_KERNEL);
> +		if (!maps) {
> +			mutex_unlock(&xps_map_lock);
> +			free_cpumask_var(mask);
> +			return -ENOMEM;
> +		}
> +		rcu_assign_pointer(dev->xps_maps, maps);
> +	}
> +
> +	index = get_netdev_queue_index(queue);
> +
> +	qmask = maps->queues;
> +	for (i = 0; i < num_possible_cpus(); i++) {
> +		if (cpu_isset(i, *mask) && cpu_online(i)) {
> +			set_bit(index, qmask);
> +			nonempty = 1;
> +		} else
> +			clear_bit(index, qmask);
> +		if (!nonempty &&
> +		    bitmap_weight(qmask, dev->real_num_tx_queues))
> +			nonempty = 1;
> +		qmask += qmask_size;
> +	}
> +
> +	if (!nonempty) {
> +		rcu_assign_pointer(dev->xps_maps, NULL);
> +		call_rcu(&maps->rcu, xps_map_release);
> +	}
> +
> +	mutex_unlock(&xps_map_lock);
> +
> +	free_cpumask_var(mask);
> +	return len;
> +}
> +
> +static struct netdev_queue_attribute xps_cpus_attribute =
> +    __ATTR(xps_cpus, S_IRUGO | S_IWUSR, show_xps_map, store_xps_map);
> +
> +static struct attribute *netdev_queue_default_attrs[] = {
> +	&xps_cpus_attribute.attr,
> +	NULL
> +};
> +
> +static void netdev_queue_release(struct kobject *kobj)
> +{
> +	struct netdev_queue *queue = to_netdev_queue(kobj);
> +	struct net_device *dev = queue->dev;
> +	struct netdev_queue *first = queue->first;
> +	struct xps_map *maps;
> +	unsigned long *qmask, index;
> +	int i, nonempty = 0;
> +	unsigned int qmask_size = QUEUE_MASK_SIZE(dev);
> +
> +	index = get_netdev_queue_index(queue);
> +
> +	mutex_lock(&xps_map_lock);
> +
> +	maps = dev->xps_maps;
> +
> +	if (maps) {
> +		qmask = maps->queues;
> +		for (i = 0; i < num_possible_cpus(); i++) {
> +			clear_bit(index, qmask);
> +			if (!nonempty &&
> +			    bitmap_weight(qmask, dev->real_num_tx_queues))
> +				nonempty = 1;
> +			qmask += qmask_size;
> +		}
> +
> +		if (!nonempty) {
> +			rcu_assign_pointer(dev->xps_maps, NULL);
> +			call_rcu(&maps->rcu, xps_map_release);
> +		}
> +	}
> +	mutex_unlock(&xps_map_lock);
> +
> +	if (atomic_dec_and_test(&first->count)) {
> +		kfree(first);
> +		dev_put(dev);
> +	}
> +}
> +
> +static struct kobj_type netdev_queue_ktype = {
> +	.sysfs_ops = &netdev_queue_sysfs_ops,
> +	.release = netdev_queue_release,
> +	.default_attrs = netdev_queue_default_attrs,
> +};
> +
> +static int netdev_queue_add_kobject(struct net_device *net, int index)
> +{
> +	struct netdev_queue *queue = net->_tx + index;
> +	struct kobject *kobj = &queue->kobj;
> +	int error = 0;
> +
> +	kobj->kset = net->queues_kset;
> +	error = kobject_init_and_add(kobj, &netdev_queue_ktype, NULL,
> +	    "tx-%u", index);
> +	if (error) {
> +		kobject_put(kobj);
> +		return error;
> +	}
> +
> +	kobject_uevent(kobj, KOBJ_ADD);
> +
> +	return error;
> +}
> +
> +static int register_queue_kobjects(struct net_device *net)
> +{
> +	int rx = 0, tx = 0;
>  	int error = 0;
>  
>  	net->queues_kset = kset_create_and_add("queues",
>  	    NULL, &net->dev.kobj);
>  	if (!net->queues_kset)
>  		return -ENOMEM;
> -	for (i = 0; i < net->num_rx_queues; i++) {
> -		error = rx_queue_add_kobject(net, i);
> +
> +	for (rx = 0; rx < net->num_rx_queues; rx++) {
> +		error = rx_queue_add_kobject(net, rx);
>  		if (error)
> -			break;
> +			goto error;
>  	}
>  
> -	if (error)
> -		while (--i >= 0)
> -			kobject_put(&net->_rx[i].kobj);
> +	for (tx = 0; tx < net->num_tx_queues; tx++) {
> +		error = netdev_queue_add_kobject(net, tx);
> +		if (error)
> +			goto error;
> +	}
> +	dev_hold(net);
> +
> +	return error;
> +
> +error:
> +	while (--rx >= 0)
> +		kobject_put(&net->_rx[rx].kobj);
> +
> +	while (--tx >= 0)
> +		kobject_put(&net->_tx[tx].kobj);
>  
>  	return error;
>  }
>  
> -static void rx_queue_remove_kobjects(struct net_device *net)
> +static void remove_queue_kobjects(struct net_device *net)
>  {
>  	int i;
>  
>  	for (i = 0; i < net->num_rx_queues; i++)
>  		kobject_put(&net->_rx[i].kobj);
> +	for (i = 0; i < net->num_tx_queues; i++)
> +		kobject_put(&net->_tx[i].kobj);
>  	kset_unregister(net->queues_kset);
>  }
>  #endif /* CONFIG_RPS */
> @@ -871,7 +1132,7 @@ void netdev_unregister_kobject(struct net_device * net)
>  	kobject_get(&dev->kobj);
>  
>  #ifdef CONFIG_RPS
> -	rx_queue_remove_kobjects(net);
> +	remove_queue_kobjects(net);
>  #endif
>  
>  	device_del(dev);
> @@ -912,7 +1173,7 @@ int netdev_register_kobject(struct net_device *net)
>  		return error;
>  
>  #ifdef CONFIG_RPS
> -	error = rx_queue_register_kobjects(net);
> +	error = register_queue_kobjects(net);
>  	if (error) {
>  		device_del(dev);
>  		return error;
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index de3bd84..80c1928 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -828,8 +828,10 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
>  							   &md5);
>  	tcp_header_size = tcp_options_size + sizeof(struct tcphdr);
>  
> -	if (tcp_packets_in_flight(tp) == 0)
> +	if (tcp_packets_in_flight(tp) == 0) {
>  		tcp_ca_event(sk, CA_EVENT_TX_START);
> +		skb->ooo_okay = 1;
> +	}
>  
>  	skb_push(skb, tcp_header_size);
>  	skb_reset_transport_header(skb);

Why don't we do this in the normal transmit processing.
There is already so much policy mechanism filters/actions/qdisc that
doing it in higher level is fighting against these.



-- 
