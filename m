From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 1/2] rps: core implementation
Date: Wed, 11 Nov 2009 22:43:05 +0100
Message-ID: <87hbt0kaae.fsf@basil.nowhere.org>
References: <65634d660911102253o2b4f7a19kfed5849e5c88bfe1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:46097 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759219AbZKKVnD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2009 16:43:03 -0500
In-Reply-To: <65634d660911102253o2b4f7a19kfed5849e5c88bfe1@mail.gmail.com> (Tom Herbert's message of "Tue, 10 Nov 2009 22:53:17 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tom Herbert <therbert@google.com> writes:

> Third version of RPS.

This really needs the text from 0/2 here as git changelog, otherwise
you make David's life hard if he wants to merge this.

> +
> +/*
>   *	The DEVICE structure.
>   *	Actually, this whole structure is a big mistake.  It mixes I/O
>   *	data with strictly "high-level" data, and it has to know about
> @@ -807,6 +819,9 @@ struct net_device
>  	void			*ax25_ptr;	/* AX.25 specific data */
>  	struct wireless_dev	*ieee80211_ptr;	/* IEEE 802.11 specific data,
>  						   assign before registering */
> +	void			*rps_maps;	/* Array of per-NAPI maps for
> +						   receive packet steeing */

Why is this void * here? This should be a real type.



> +	int			rps_num_maps;	/* Number of RPS maps */

This has a 4 byte hole on 64bit. Better move it somewhere else
where that isn't the case.

>
>  /*
>   * Cache line mostly used on receive path (including eth_type_trans())

Also make sure you you don't destroy these cache line optimizations.


> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index 0c68fbd..95feac7 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -396,6 +396,8 @@ struct sk_buff {
>
>  	__u16			vlan_tci;
>
> +	__u32			rxhash;

Similarly here.


> + * get_rps_cpu is called from netif_receive_skb and returns the target
> + * CPU from the RPS map of the receiving NAPI instance for a given skb.
> + */
> +static int get_rps_cpu(struct net_device *dev, struct sk_buff *skb)
> +{
> +	u32 addr1, addr2, ports;
> +	struct ipv6hdr *ip6;
> +	struct iphdr *ip;
> +	u32 hash, ihl;
> +	u8 ip_proto;
> +	int cpu;
> +	struct rps_map *map = NULL;
> +
> +	if (dev->rps_num_maps) {
> +		/*
> +		 * Locate the map corresponding to the NAPI queue that
> +		 * the packet was received on.
> +		 */
> +		int index = skb_get_rx_queue(skb);
> +		if (index < 0 || index >= dev->rps_num_maps)
> +			index = 0;
> +
> +		map = (struct rps_map *)
> +		    (dev->rps_maps + (RPS_MAP_SIZE * index));
> +		if (!map->len)
> +			map = NULL;

Can this really happen? Better might be to move this out of the fast path.

> +	switch (skb->protocol) {
> +	case __constant_htons(ETH_P_IP):
> +		if (!pskb_may_pull(skb, sizeof(*ip)))
> +			return -1;
> +
> +		ip = (struct iphdr *) skb->data;
> +		ip_proto = ip->protocol;
> +		addr1 = ip->saddr;
> +		addr2 = ip->daddr;
> +		ihl = ip->ihl;
> +		break;
> +	case __constant_htons(ETH_P_IPV6):
> +		if (!pskb_may_pull(skb, sizeof(*ip6)))
> +			return -1;
> +
> +		ip6 = (struct ipv6hdr *) skb->data;
> +		ip_proto = ip6->nexthdr;
> +		addr1 = ip6->saddr.s6_addr32[3];
> +		addr2 = ip6->daddr.s6_addr32[3];

Why only [3] ? Is this future proof?

> +/**
> + * net_rps_action is called from NET_RPS_SOFTIRQ to do IPIs to schedule RX
> + * softirq on remote CPUs.  Called in a separate softirq to allow for
> + * coalescing.
> + */
> +static void net_rps_action(struct softirq_action *h)
> +{
> +	int cpu;
> +
> +	local_irq_disable();
> +
> +	for_each_cpu_mask_nr(cpu, __get_cpu_var(rps_remote_softirq_cpus)) {
> +		struct softnet_data *queue = &per_cpu(softnet_data, cpu);
> +		__smp_call_function_single(cpu, &queue->csd, 0);

How do you get around the standard deadlocks with IPI called from
irq disabled section?

And why are the interrupts are disabled here anyways?

> @@ -2696,21 +2842,24 @@ static int process_backlog(struct napi_struct
> *napi, int quota)
>  	int work = 0;
>  	struct softnet_data *queue = &__get_cpu_var(softnet_data);
>  	unsigned long start_time = jiffies;
> +	unsigned long flags;
>
>  	napi->weight = weight_p;
>  	do {
>  		struct sk_buff *skb;
>
>  		local_irq_disable();
> +		spin_lock_irqsave(&queue->input_pkt_queue.lock, flags);

When you just disabled the irqs you obviously don't need a irqsave
in the next line.

>  		skb = __skb_dequeue(&queue->input_pkt_queue);
>  		if (!skb) {
>  			__napi_complete(napi);
> -			local_irq_enable();
> +			spin_unlock_irqrestore(&queue->input_pkt_queue.lock,
> +			    flags);
>  			break;

This will actually not turn on interrupts again because you only
saved them after disabling them.

>  		}
> -		local_irq_enable();
> +		spin_unlock_irqrestore(&queue->input_pkt_queue.lock, flags);

Same

>
> -		netif_receive_skb(skb);
> +		__netif_receive_skb(skb);
>  	} while (++work < quota && jiffies == start_time);
>
>  	return work;
> @@ -5205,6 +5354,8 @@ void free_netdev(struct net_device *dev)
>  	/* Flush device addresses */
>  	dev_addr_flush(dev);
>
> +	kfree(dev->rps_maps);
> +
>  	list_for_each_entry_safe(p, n, &dev->napi_list, dev_list)
>  		netif_napi_del(p);
>
> @@ -5644,6 +5795,10 @@ static int __init net_dev_init(void)
>  		queue->completion_queue = NULL;
>  		INIT_LIST_HEAD(&queue->poll_list);
>
> +		queue->csd.func = trigger_softirq;
> +		queue->csd.info = queue;
> +		queue->csd.flags = 0;
> +
>  		queue->backlog.poll = process_backlog;
>  		queue->backlog.weight = weight_p;
>  		queue->backlog.gro_list = NULL;
> @@ -5669,7 +5824,9 @@ static int __init net_dev_init(void)
>
>  	open_softirq(NET_TX_SOFTIRQ, net_tx_action);
>  	open_softirq(NET_RX_SOFTIRQ, net_rx_action);
> +	open_softirq(NET_RPS_SOFTIRQ, net_rps_action);
>
> +	get_random_bytes(&simple_hashrnd, 4);

It's a standard pet peeve of me, but it's quite unlikely you'll
get any useful entropy at this time of kernel startup.

Normally it's always the same.


> +static char *
> +get_token(const char **cp, size_t *len)
> +{
> +	const char *bp = *cp, *start;
> +
> +	while (isspace(*bp))
> +		bp++;
> +
> +	start = bp;
> +	while (!isspace(*bp) && *bp != '\0')
> +		bp++;
> +
> +	if (start != bp)
> +		*len = bp - start;
> +	else
> +		start = NULL;
> +
> +	*cp = bp;
> +	return start;
> +}
> +
> +static ssize_t store_rps_cpus(struct device *dev,
> +    struct device_attribute *attr, const char *buf, size_t len)
> +{
> +	struct net_device *net = to_net_dev(dev);
> +	struct napi_struct *napi;
> +	cpumask_t mask;
> +	int err, cpu, index, i;
> +	int cnt = 0;
> +	char *token;
> +	const char *cp = buf;
> +	size_t tlen;
> +
> +	if (!capable(CAP_NET_ADMIN))
> +		return -EPERM;
> +
> +	/*
> +	 * Pre-check that tokens parse properly before we commit to making
> +	 * any changes.
> +	 */
> +	while ((token = get_token(&cp, &tlen)))
> +		err = bitmap_parse(token, tlen, cpumask_bits(&mask),
> +		    nr_cpumask_bits);
> +
> +	if (err)
> +		return err;
> +
> +	rtnl_lock();

It seems weird to do user parsing while holding that lock.
Better first set up and allocate and then finally initialize global state.

> +	if (dev_isalive(net)) {

Especially since the device is alive. So what happens to interrupts
coming in in parallel? That seems racy.

+
+	queue = &per_cpu(softnet_data, cpu);
+	spin_lock_irqsave(&queue->input_pkt_queue.lock, flags);
+
+	__get_cpu_var(netdev_rx_stat).total++;
+	if (queue->input_pkt_queue.qlen <= netdev_max_backlog) {


It seems weird to do the local counter increase after grabbing 
the global lock. Also does someone count on the real receiver anyways?
That might be better, right now the count would be a bit 
misleading.

-Andi


-- 
ak@linux.intel.com -- Speaking for myself only.
