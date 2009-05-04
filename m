From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH v2] Receive Packet Steering
Date: Mon, 04 May 2009 09:59:07 +0200
Message-ID: <873abli9is.fsf@basil.nowhere.org>
References: <65634d660905032103h614225dbg9911e290f5537fbf@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:46407 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753942AbZEDH7J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2009 03:59:09 -0400
In-Reply-To: <65634d660905032103h614225dbg9911e290f5537fbf@mail.gmail.com> (Tom Herbert's message of "Sun, 3 May 2009 21:03:01 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tom Herbert <therbert@google.com> writes:

> diff --git a/net/core/dev.c b/net/core/dev.c
> index 052dd47..3107544 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1906,6 +1906,142 @@ int weight_p __read_mostly = 64;            /*
> old backlog weight */
>
>  DEFINE_PER_CPU(struct netif_rx_stats, netdev_rx_stat) = { 0, };
>
> +static u32 simple_hashrnd;

This should be __read_mostly

> +static int simple_hashrnd_initialized;

Also I suspect you can just use 0 as uninitialized 
and avoid one variable. If the RNG reports 0 you get
worst case another initialization.

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
> +		simple_hashrnd_initialized = 1;
> +	}

The usual problem of this is that if the kernel gets a packet sufficiently
early the random state will be always the default state, which is not
very random.

So either you use a timeout to reinit regularly (like other subsystems
do) or just use a fixed value for reproducibility. I suspect the
later would be nicer for benchmakers.

+	case __constant_htons(ETH_P_IPV6):
+		if (!pskb_may_pull(skb, sizeof(*ip6)))
+			return -1;
+
+		ip6 = (struct ipv6hdr *) skb->data;
+		ip_proto = ip6->nexthdr;
+		addr1 = ip6->saddr.s6_addr32[3];
+		addr2 = ip6->daddr.s6_addr32[3];

Wouldn't it be better to hash in everything in the ipv6 address in this case? 

> +
> +	hash = jhash_3words(addr1, addr2, ports, simple_hashrnd);
> +
> +	cpu = skb->dev->rps_map[((u64) hash * dev->rps_map_len) >> 32];

For 32bit systems it would be nice to avoid the u64 cast. gcc doesn't
generate very good code for that.

> +	return cpu_online(cpu) ? cpu : -1;

I suspect this is still racy with cpu hotunplug.

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
> +	queue = &per_cpu(softnet_data, cpu);

Are you sure preemption is disabled here? Otherwise this must be 
one line below (can be tested by enabling preempt & preempt debug)

> +
> +	if (!capable(CAP_NET_ADMIN))
> +		return -EPERM;
> +
> +	err = bitmap_parse(buf, len, cpumask_bits(&mask), nr_cpumask_bits);
> +	if (err)
> +		return err;
> +
> +	rtnl_lock();
> +	if (dev_isalive(net)) {
> +		if (!net->rps_map) {
> +			net->rps_map = kzalloc(sizeof(u16) *
> +			    num_possible_cpus(), GFP_KERNEL);
> +			if (!net->rps_map)
> +				return -ENOMEM;

You don't unlock rtnl_lock here.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
