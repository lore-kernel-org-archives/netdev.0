From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] ifb: add multi-queue support
Date: Wed, 11 Nov 2009 16:59:32 +0100
Message-ID: <4AFADF64.8070601@trash.net>
References: <4AFA8911.7050204@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34052 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754149AbZKKP7c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2009 10:59:32 -0500
In-Reply-To: <4AFA8911.7050204@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changli Gao wrote:
> diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
> index 69c2566..ac04e85 100644
> --- a/drivers/net/ifb.c
> +++ b/drivers/net/ifb.c
> ...
> +/* Number of ifb devices to be set up by this module. */
>  static int numifbs = 2;
> +module_param(numifbs, int, 0444);
> +MODULE_PARM_DESC(numifbs, "Number of ifb devices");
>  
> -static void ri_tasklet(unsigned long dev);
> -static netdev_tx_t ifb_xmit(struct sk_buff *skb, struct net_device *dev);
> -static int ifb_open(struct net_device *dev);
> -static int ifb_close(struct net_device *dev);
> +/* Number of TX queues per ifb */
> +static int numtxqs = 1;
> +module_param(numtxqs, int, 0444);
> +MODULE_PARM_DESC(numtxqs, "Number of TX queues per ifb");

unsigned?

> +		while ((skb = skb_dequeue(&pq->tq)) != NULL) {
> +			u32 from = G_TC_FROM(skb->tc_verd);
> +	
> +			skb->tc_verd = 0;
> +			skb->tc_verd = SET_TC_NCLS(skb->tc_verd);
> +			txq->tx_packets++;
> +			txq->tx_bytes +=skb->len;
> +
> +			rcu_read_lock();
> +			skb->dev = dev_get_by_index_rcu(&init_net, skb->iif);
> +			if (!skb->dev) {
> +				rcu_read_unlock();
> +				dev_kfree_skb(skb);
> +				txq->tx_dropped++;
> +				break;
> +			}
> +			rcu_read_unlock();
> +			skb->iif = dev->ifindex;

What protects the device from disappearing here and below during
dev_queue_xmit() and netif_rx_ni()?

> +	
> +			if (from & AT_EGRESS) {
> +				dev_queue_xmit(skb);
> +			} else if (from & AT_INGRESS) {
> +				skb_pull(skb, skb->dev->hard_header_len);
> +				netif_rx_ni(skb);
> +			} else
> +				BUG();
>  		}

> +static u32 simple_tx_hashrnd;
> +
> +static u16 ifb_select_queue(struct net_device *dev, struct sk_buff *skb)
> +{
> +	u32 addr1, addr2;
> +	u32 hash, ihl;
> +	union {
> +		u16 in16[2];
> +		u32 in32;
> +	} ports;
> +	u8 ip_proto;
> +
> +	if ((hash = skb_rx_queue_recorded(skb))) {
> +		while (hash >= dev->real_num_tx_queues)
> +			hash -= dev->real_num_tx_queues;
> +		return hash;
> +	}
> +
> +	switch (skb->protocol) {
> +	case __constant_htons(ETH_P_IP):
> +		if (!(ip_hdr(skb)->frag_off & htons(IP_MF | IP_OFFSET)))
> +			ip_proto = ip_hdr(skb)->protocol;
> +		else
> +			ip_proto = 0;

So fragments will get reordered?

> +		addr1 = ip_hdr(skb)->saddr;
> +		addr2 = ip_hdr(skb)->daddr;
> +		ihl = ip_hdr(skb)->ihl << 2;

ip_hdrlen()?

> +		break;
> +	case __constant_htons(ETH_P_IPV6):
> +		ip_proto = ipv6_hdr(skb)->nexthdr;
> +		addr1 = ipv6_hdr(skb)->saddr.s6_addr32[3];
> +		addr2 = ipv6_hdr(skb)->daddr.s6_addr32[3];
> +		ihl = 10;

Where does 10 come from?

> +		break;
> +	default:
> +		return 0;

Perhaps hash on skb->protocol here.

> +	}
> +	if (addr1 > addr2)
> +		swap(addr1, addr2);
> +
> +	switch (ip_proto) {
> +	case IPPROTO_TCP:
> +	case IPPROTO_UDP:
> +	case IPPROTO_DCCP:
> +	case IPPROTO_ESP:
> +	case IPPROTO_AH:
> +	case IPPROTO_SCTP:
> +	case IPPROTO_UDPLITE:
> +		ports.in32 = *((u32 *) (skb_network_header(skb) + ihl));
> +		if (ports.in16[0] > ports.in16[1])
> +			swap(ports.in16[0], ports.in16[1]);
> +		break;
> +
> +	default:
> +		ports.in32 = 0;
> +		break;
> +	}
> +
> +	hash = jhash_3words(addr1, addr2, ports.in32,
> +			    simple_tx_hashrnd ^ ip_proto);
> +
> +	return (u16) (((u64) hash * dev->real_num_tx_queues) >> 32);
> +}
> +
> +static int ifb_init(struct net_device *dev)
> +{
> +	struct ifb_private *dp = netdev_priv(dev);
> +	struct ifb_private_q *pq = dp->pq;
> +	int i;
> +
> +	pq = kmalloc(sizeof(*pq) * dev->real_num_tx_queues, GFP_KERNEL);

kcalloc()?

> +	if (pq == NULL)
> +		return -ENOMEM;
> +	dp->pq = pq;
> +
> +	for (i = 0; i < dev->real_num_tx_queues; i++) {
> +		pq[i].dev = dev;
> +		skb_queue_head_init(&pq[i].rq);
> +		skb_queue_head_init(&pq[i].tq);
> +		init_waitqueue_head(&pq[i].wq);
> +		pq[i].rx_packets = 0;
> +		pq[i].rx_bytes = 0;
> +		pq[i].rx_dropped = 0;
> +	}
> +
> +	return 0;
> +}

> +static int ifb_get_tx_queues(struct net *net, struct nlattr *tb[],
> +			     unsigned int *num_tx_queues,
> +			     unsigned int *real_num_tx_queues)
> +{
> +	if (tb[IFLA_NTXQ]) {
> +		*num_tx_queues = nla_get_u16(tb[IFLA_NTXQ]);

We currently use unsigned ints for the queue number, so please
use an u32 for the attribute as well.

> +		*real_num_tx_queues = *num_tx_queues;
> +	} else {
> +		*num_tx_queues = numtxqs;
> +		*real_num_tx_queues = numtxqs;
> +	}
> +
> +	return 0;
> +}
> +
