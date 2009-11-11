From: Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: [PATCH 1/2] rps: core implementation
Date: Wed, 11 Nov 2009 08:49:48 -0800
Message-ID: <20091111084948.6e66d60e.rdunlap@xenotime.net>
References: <65634d660911102253o2b4f7a19kfed5849e5c88bfe1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenotime.net ([72.52.64.118]:57774 "HELO xenotime.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1757816AbZKKQtn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Nov 2009 11:49:43 -0500
Received: from chimera.site ([96.253.169.185]) by xenotime.net for <netdev@vger.kernel.org>; Wed, 11 Nov 2009 08:49:48 -0800
In-Reply-To: <65634d660911102253o2b4f7a19kfed5849e5c88bfe1@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 10 Nov 2009 22:53:17 -0800 Tom Herbert wrote:

> Third version of RPS.
> 
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
>  include/linux/interrupt.h |    1 +
>  include/linux/netdevice.h |   18 ++++
>  include/linux/skbuff.h    |    2 +
>  net/core/dev.c            |  227 ++++++++++++++++++++++++++++++++++++++-------
>  net/core/net-sysfs.c      |  135 +++++++++++++++++++++++++++
>  5 files changed, 348 insertions(+), 35 deletions(-)
> 

> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index 0c68fbd..95feac7 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -396,6 +396,8 @@ struct sk_buff {
> 
>  	__u16			vlan_tci;
> 
> +	__u32			rxhash;
> +

@rxhash needs to be added to the kernel-doc for struct sk_buff.

>  	sk_buff_data_t		transport_header;
>  	sk_buff_data_t		network_header;
>  	sk_buff_data_t		mac_header;

> diff --git a/net/core/dev.c b/net/core/dev.c
> index 28b0b9e..735e7e3 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1976,6 +1976,162 @@ int weight_p __read_mostly = 64;            /*
> old backlog weight */
> 
>  DEFINE_PER_CPU(struct netif_rx_stats, netdev_rx_stat) = { 0, };
> 
> +static u32 simple_hashrnd;
> +
> +/**
> + * get_rps_cpu is called from netif_receive_skb and returns the target
> + * CPU from the RPS map of the receiving NAPI instance for a given skb.
> + */

"/**" in kernel source code means "begin kernel-doc notation", but that
is not kernel-doc notation, so please make it be kernel-doc, or don't
use "/**" to begin comment blocks.

(in several functions here...)

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
> +	}
> +
> +	if (!map)
> +		return -1;
> +
> +	hash = skb->rxhash;
> +	if (hash)
> +		goto got_hash; /* Skip hash computation on packet header */
> +
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
> +		ihl = (40 >> 2);
> +		break;
> +	default:
> +		return -1;
> +	}
> +	ports = 0;
> +	switch (ip_proto) {
> +	case IPPROTO_TCP:
> +	case IPPROTO_UDP:
> +	case IPPROTO_DCCP:
> +	case IPPROTO_ESP:
> +	case IPPROTO_AH:
> +	case IPPROTO_SCTP:
> +	case IPPROTO_UDPLITE:
> +		if (pskb_may_pull(skb, (ihl * 4) + 4))
> +			ports = *((u32 *) (skb->data + (ihl * 4)));
> +		break;
> +
> +	default:
> +		break;
> +	}
> +
> +	hash = jhash_3words(addr1, addr2, ports, simple_hashrnd);
> +
> +got_hash:
> +	cpu = map->map[((u64) hash * map->len) >> 32];
> +
> +	return cpu_online(cpu) ? cpu : -1;
> +}

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


> diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
> index 753c420..ca250f6 100644
> --- a/net/core/net-sysfs.c
> +++ b/net/core/net-sysfs.c
> @@ -18,6 +18,9 @@
>  #include <linux/wireless.h>
>  #include <net/wext.h>
> 
> +#include <linux/string.h>
> +#include <linux/ctype.h>
> +
>  #include "net-sysfs.h"
> 
>  #ifdef CONFIG_SYSFS
> @@ -249,6 +252,137 @@ static ssize_t store_tx_queue_len(struct device *dev,
>  	return netdev_store(dev, attr, buf, len, change_tx_queue_len);
>  }
> 
> +static char *
> +get_token(const char **cp, size_t *len)
> +{

nit: not kernel style.

---
~Randy
