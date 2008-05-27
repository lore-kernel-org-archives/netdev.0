From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/5] [VLAN]: Unclassified vlan packet
Date: Tue, 27 May 2008 07:40:14 +0200
Message-ID: <483B9EBE.5030703@trash.net>
References: <20080411135714.GA8137@tp64>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Joonwoo Park <joonwpark81@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42927 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752200AbYE0FkQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2008 01:40:16 -0400
In-Reply-To: <20080411135714.GA8137@tp64>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joonwoo Park wrote:
> To be polite to the PACKET,
> Don't kill the unclassified & hardware accelerated vlan packets if netdev
> is in promiscuous, set packet type with PACKET_OTHERHOST. 
> Put the vlan tag into skb->cb for all hardware accelerated vlan packets.

Conceptually I think this patch goes in the right direction,
one question remaining is when to invalidate the VLAN tag again.

The only solution I could come up with is invalidating it in
netif_receive_skb() when the receiving device is not a VLAN
device and additionally invalidating it in all callers of
dev_queue_xmit except VLAN itself, but I would really prefer
something less error prone without touching netif_receive_skb().

BTW, I already have a patch queued to move the VLAN tag from
skb->cb to a seperate skb member to fix the the conflict with
qdiscs (this should also allow to use vlan accel through virtual
network devices later on). So please don't resend, I'll integrate
the patch on top of this change once we find a good spot for
invalidation.

> 
> Signed-off-by: Joonwoo Park <joonwpark81@gmail.com>
> ---
>  include/linux/if_vlan.h |   56 +++++++++++++++++++++++++++++-----------------
>  1 files changed, 35 insertions(+), 21 deletions(-)
> 
> diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
> index 79504b2..e400141 100644
> --- a/include/linux/if_vlan.h
> +++ b/include/linux/if_vlan.h
> @@ -62,6 +62,9 @@ struct vlan_ethhdr {
>  
>  #include <linux/skbuff.h>
>  
> +static inline struct sk_buff *__vlan_hwaccel_put_tag(struct sk_buff *skb,
> +						     unsigned short tag);
> +
>  static inline struct vlan_ethhdr *vlan_eth_hdr(const struct sk_buff *skb)
>  {
>  	return (struct vlan_ethhdr *)skb_mac_header(skb);
> @@ -175,14 +178,19 @@ static inline int __vlan_hwaccel_rx(struct sk_buff *skb,
>  				    unsigned short vlan_tag, int polling)
>  {
>  	struct net_device_stats *stats;
> +	struct net_device *vlan_dev;
>  
>  	if (skb_bond_should_drop(skb)) {
>  		dev_kfree_skb_any(skb);
>  		return NET_RX_DROP;
>  	}
>  
> -	skb->dev = vlan_group_get_device(grp, vlan_tag & VLAN_VID_MASK);
> -	if (skb->dev == NULL) {
> +	vlan_dev = vlan_group_get_device(grp, vlan_tag & VLAN_VID_MASK);
> +	if (vlan_dev)
> +		skb->dev = vlan_dev;
> +	else if (skb->dev->flags & IFF_PROMISC)
> +		skb->pkt_type = PACKET_OTHERHOST;
> +	else {
>  		dev_kfree_skb_any(skb);
>  
>  		/* Not NET_RX_DROP, this is not being dropped
> @@ -191,31 +199,37 @@ static inline int __vlan_hwaccel_rx(struct sk_buff *skb,
>  		return 0;
>  	}
>  
> +	/* Deliever vlan_tag to PACKET */
> +	__vlan_hwaccel_put_tag(skb, vlan_tag);
> +
>  	skb->dev->last_rx = jiffies;
>  
>  	stats = &skb->dev->stats;
>  	stats->rx_packets++;
>  	stats->rx_bytes += skb->len;
>  
> -	skb->priority = vlan_get_ingress_priority(skb->dev, vlan_tag);
> -	switch (skb->pkt_type) {
> -	case PACKET_BROADCAST:
> -		break;
> -
> -	case PACKET_MULTICAST:
> -		stats->multicast++;
> -		break;
> -
> -	case PACKET_OTHERHOST:
> -		/* Our lower layer thinks this is not local, let's make sure.
> -		 * This allows the VLAN to have a different MAC than the underlying
> -		 * device, and still route correctly.
> -		 */
> -		if (!compare_ether_addr(eth_hdr(skb)->h_dest,
> -				       	skb->dev->dev_addr))
> -			skb->pkt_type = PACKET_HOST;
> -		break;
> -	};
> +	if (vlan_dev) {
> +		skb->priority = vlan_get_ingress_priority(skb->dev, vlan_tag);
> +		switch (skb->pkt_type) {
> +		case PACKET_BROADCAST:
> +			break;
> +
> +		case PACKET_MULTICAST:
> +			stats->multicast++;
> +			break;
> +
> +		case PACKET_OTHERHOST:
> +			/* Our lower layer thinks this is not local, let's
> +			 * make sure.
> +			 * This allows the VLAN to have a different MAC than
> +			 * the underlying device, and still route correctly.
> +			 */
> +			if (!compare_ether_addr(eth_hdr(skb)->h_dest,
> +							skb->dev->dev_addr))
> +				skb->pkt_type = PACKET_HOST;
> +			break;
> +		};
> +	}
>  
>  	return (polling ? netif_receive_skb(skb) : netif_rx(skb));
>  }

