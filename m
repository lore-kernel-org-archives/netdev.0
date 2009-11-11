From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/2] rps: core implementation
Date: Wed, 11 Nov 2009 09:20:42 +0100
Message-ID: <4AFA73DA.30308@gmail.com>
References: <65634d660911102253o2b4f7a19kfed5849e5c88bfe1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:45158 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757147AbZKKIUr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2009 03:20:47 -0500
In-Reply-To: <65634d660911102253o2b4f7a19kfed5849e5c88bfe1@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tom Herbert a =E9crit :
> Third version of RPS.
>=20
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
>  include/linux/interrupt.h |    1 +
>  include/linux/netdevice.h |   18 ++++
>  include/linux/skbuff.h    |    2 +
>  net/core/dev.c            |  227 +++++++++++++++++++++++++++++++++++=
+++-------
>  net/core/net-sysfs.c      |  135 +++++++++++++++++++++++++++
>  5 files changed, 348 insertions(+), 35 deletions(-)
>=20

I must say this is really exciting :)

> diff --git a/include/linux/interrupt.h b/include/linux/interrupt.h
> index b78cf81..fa91194 100644
> --- a/include/linux/interrupt.h
> +++ b/include/linux/interrupt.h
> @@ -345,6 +345,7 @@ enum
>  	TIMER_SOFTIRQ,
>  	NET_TX_SOFTIRQ,
>  	NET_RX_SOFTIRQ,
> +	NET_RPS_SOFTIRQ,
>  	BLOCK_SOFTIRQ,
>  	BLOCK_IOPOLL_SOFTIRQ,
>  	TASKLET_SOFTIRQ,
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 8380009..c1b1bbb 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -639,6 +639,18 @@ struct net_device_ops {
>  };
>=20
>  /*
> + * Structure for Receive Packet Steering.  Length of map and array o=
f CPU ID's.
> + */
> +struct rps_map {
> +	int len;
> +	u16 map[0];
> +};
> +
> +/* Maximum size of RPS map (for allocation) */
> +#define RPS_MAP_SIZE (sizeof(struct rps_map) + \
> +    (num_possible_cpus() * sizeof(u16)))
> +

Problem of possible cpus is the number can be very large on some arches=
,
but yet few cpus online....

In this kind of situation, get_rps_cpu() will return -1 most of the tim=
e,
defeating goal of RPS ?


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
> +	int			rps_num_maps;	/* Number of RPS maps */
>=20
>  /*
>   * Cache line mostly used on receive path (including eth_type_trans(=
))
> @@ -1217,6 +1232,9 @@ struct softnet_data
>  	struct Qdisc		*output_queue;
>  	struct sk_buff_head	input_pkt_queue;
>  	struct list_head	poll_list;
> +
> +	struct call_single_data	csd;
> +
>  	struct sk_buff		*completion_queue;
>=20
>  	struct napi_struct	backlog;
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index 0c68fbd..95feac7 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -396,6 +396,8 @@ struct sk_buff {
>=20
>  	__u16			vlan_tci;
>=20
> +	__u32			rxhash;
> +
>  	sk_buff_data_t		transport_header;
>  	sk_buff_data_t		network_header;
>  	sk_buff_data_t		mac_header;
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 28b0b9e..735e7e3 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1976,6 +1976,162 @@ int weight_p __read_mostly =3D 64;           =
 /*
> old backlog weight */
>=20
>  DEFINE_PER_CPU(struct netif_rx_stats, netdev_rx_stat) =3D { 0, };
>=20
> +static u32 simple_hashrnd;
> +
> +/**
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
> +	int cpu;
> +	struct rps_map *map =3D NULL;
> +
> +	if (dev->rps_num_maps) {
> +		/*
> +		 * Locate the map corresponding to the NAPI queue that
> +		 * the packet was received on.
> +		 */
> +		int index =3D skb_get_rx_queue(skb);
> +		if (index < 0 || index >=3D dev->rps_num_maps)
> +			index =3D 0;
> +
> +		map =3D (struct rps_map *)
> +		    (dev->rps_maps + (RPS_MAP_SIZE * index));
> +		if (!map->len)
> +			map =3D NULL;
> +	}
> +
> +	if (!map)
> +		return -1;
> +
> +	hash =3D skb->rxhash;
> +	if (hash)
> +		goto got_hash; /* Skip hash computation on packet header */
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

I wonder if you tried to exchange addr1/addr2  port1/port2 so that conn=
tracking/routing
is also speedup ...

ie make sure hash will be the same regardless of the direction of packe=
t.

union {
	u32 port;
	u16 ports[2];
} p;

if (addr1 < addr2)
	swap(addr1, addr2);

if (p.ports[0] < p.ports[1]);
	swap(p.ports[0], p.ports[1]);

hash =3D jhash_3words(addr1, addr2, ports, simple_hashrnd);


I think I'll try to extend your patches with TX completion recycling to=
o.

Ie record in skb the cpu number of original sender, and queue skb to
remote queue for destruction (sock_wfree() call and expensive scheduler=
 calls...)

(This probably needs driver cooperation, instead of calling consume_skb=
(),
use a different function)

Thanks
