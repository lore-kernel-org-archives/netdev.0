From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: atl1 warn_on_slowpath help
Date: Wed, 29 Oct 2008 13:03:13 +0000
Message-ID: <20081029130313.GA7256@ff.dom.local>
References: <20081029071549.GA4861@ff.dom.local> <49081AE4.9040301@trash.net> <49083825.3000601@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jay Cliburn <jcliburn@gmail.com>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:8104 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753361AbYJ2NDV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 09:03:21 -0400
Received: by ug-out-1314.google.com with SMTP id 39so594415ugf.37
        for <netdev@vger.kernel.org>; Wed, 29 Oct 2008 06:03:19 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <49083825.3000601@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 29, 2008 at 11:17:09AM +0100, Patrick McHardy wrote:
> Patrick McHardy wrote:
>> Jarek Poplawski wrote:
>>> On 29-10-2008 01:08, Jay Cliburn wrote:
>>>> [   27.779463] ------------[ cut here ]------------
>>>> [   27.779509] WARNING: at kernel/softirq.c:136  
>>>> local_bh_enable+0x37/0x81()
>>> ...
>>>> [   27.782520]  [<c0264755>] netif_nit_deliver+0x5b/0x75
>>>> [   27.782590]  [<c02bba83>] __vlan_hwaccel_rx+0x79/0x162
>>>> [   27.782664]  [<f8851c1d>] atl1_intr+0x9a9/0xa7c [atl1]
>>>>>
>>>> warn_on_slowpath stuff well enough to know what to look for. Can someone
>>>> please take a quick look at drivers/net/atlx/atl1.c around line 2017
>>>> and see if there's an obvious error?  I'd really appreciate it.
>>>
>>> It looks to me like vlan_hwaccel_rx() is to blame: I doubt we can do
>>> netif_nit_deliver() in hard irq context. (Patrick Cc-ed.)
>>
>> Crap, I didn't think of that, all drivers I tested with support
>> NAPI. I can't think of a clean way to fix it right now, but I'll
>> look into it.
>
> This is the best I could come up with, short of simply restoring
> the old behaviour for non-polling drivers.
>
> The __vlan_hwaccel_rx function only does the device lookup and
> stores it in the cb. The remaining processing is done in a new
> function that is invoked by netif_receive_skb(), in the proper
> context. Unfortunatly this needs vlan-specific handling in
> netif_receive_skb().
>

Unfortunately I'm not up-to-date with vlans and especially this
nit_deliver problem, but here is a little doubt: since this is
probably for stable, and skb->cb is rather tricky, I wonder why
vlan_group_get_device() couldn't be used directly in
vlan_hwaccel_do_receive()?

BTW: if we call netif_nit_deliver() from vlan_hwaccel_do_receive()
from netif_receive_skb() this comment about bypassing looks a bit
confusing to me:

/*
 *     netif_nit_deliver - deliver received packets to network taps
 *     @skb: buffer
 *
 *     This function is used to deliver incoming packets to network
 *     taps. It should be used when the normal netif_receive_skb path
 *     is bypassed, for example because of VLAN acceleration.
 */

As a matter of fact without this patch it's not so apparent why
netif_receive_skb() can't happen after netif_nit_deliver() in
__vlan_hwaccel_rx() too.

Jarek P.

> diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
> index 9e7b49b..a5cb0c3 100644
> --- a/include/linux/if_vlan.h
> +++ b/include/linux/if_vlan.h
> @@ -114,6 +114,8 @@ extern u16 vlan_dev_vlan_id(const struct net_device *dev);
>  
>  extern int __vlan_hwaccel_rx(struct sk_buff *skb, struct vlan_group *grp,
>  			     u16 vlan_tci, int polling);
> +extern int vlan_hwaccel_do_receive(struct sk_buff *skb);
> +
>  #else
>  static inline struct net_device *vlan_dev_real_dev(const struct net_device *dev)
>  {
> @@ -133,6 +135,11 @@ static inline int __vlan_hwaccel_rx(struct sk_buff *skb, struct vlan_group *grp,
>  	BUG();
>  	return NET_XMIT_SUCCESS;
>  }
> +
> +static inline int vlan_hwaccel_do_receive(struct sk_buff *skb)
> +{
> +	return 0;
> +}
>  #endif
>  
>  /**
> diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
> index 916061f..68ced4b 100644
> --- a/net/8021q/vlan_core.c
> +++ b/net/8021q/vlan_core.c
> @@ -3,11 +3,20 @@
>  #include <linux/if_vlan.h>
>  #include "vlan.h"
>  
> +struct vlan_hwaccel_cb {
> +	struct net_device	*dev;
> +};
> +
> +static inline struct vlan_hwaccel_cb *vlan_hwaccel_cb(struct sk_buff *skb)
> +{
> +	return (struct vlan_hwaccel_cb *)skb->cb;
> +}
> +
>  /* VLAN rx hw acceleration helper.  This acts like netif_{rx,receive_skb}(). */
>  int __vlan_hwaccel_rx(struct sk_buff *skb, struct vlan_group *grp,
>  		      u16 vlan_tci, int polling)
>  {
> -	struct net_device_stats *stats;
> +	struct vlan_hwaccel_cb *cb = vlan_hwaccel_cb(skb);
>  
>  	if (skb_bond_should_drop(skb)) {
>  		dev_kfree_skb_any(skb);
> @@ -15,23 +24,35 @@ int __vlan_hwaccel_rx(struct sk_buff *skb, struct vlan_group *grp,
>  	}
>  
>  	skb->vlan_tci = vlan_tci;
> +	cb->dev = vlan_group_get_device(grp, vlan_tci & VLAN_VID_MASK);
> +
> +	return (polling ? netif_receive_skb(skb) : netif_rx(skb));
> +}
> +EXPORT_SYMBOL(__vlan_hwaccel_rx);
> +
> +int vlan_hwaccel_do_receive(struct sk_buff *skb)
> +{
> +	struct vlan_hwaccel_cb *cb = vlan_hwaccel_cb(skb);
> +	struct net_device *dev = cb->dev;
> +	struct net_device_stats *stats;
> +
>  	netif_nit_deliver(skb);
>  
> -	skb->dev = vlan_group_get_device(grp, vlan_tci & VLAN_VID_MASK);
> -	if (skb->dev == NULL) {
> -		dev_kfree_skb_any(skb);
> -		/* Not NET_RX_DROP, this is not being dropped
> -		 * due to congestion. */
> -		return NET_RX_SUCCESS;
> +	if (dev == NULL) {
> +		kfree_skb(skb);
> +		return -1;
>  	}
> -	skb->dev->last_rx = jiffies;
> +
> +	skb->dev = dev;
> +	skb->priority = vlan_get_ingress_priority(dev, skb->vlan_tci);
>  	skb->vlan_tci = 0;
>  
> -	stats = &skb->dev->stats;
> +	dev->last_rx = jiffies;
> +
> +	stats = &dev->stats;
>  	stats->rx_packets++;
>  	stats->rx_bytes += skb->len;
>  
> -	skb->priority = vlan_get_ingress_priority(skb->dev, vlan_tci);
>  	switch (skb->pkt_type) {
>  	case PACKET_BROADCAST:
>  		break;
> @@ -43,13 +64,12 @@ int __vlan_hwaccel_rx(struct sk_buff *skb, struct vlan_group *grp,
>  		 * This allows the VLAN to have a different MAC than the
>  		 * underlying device, and still route correctly. */
>  		if (!compare_ether_addr(eth_hdr(skb)->h_dest,
> -					skb->dev->dev_addr))
> +					dev->dev_addr))
>  			skb->pkt_type = PACKET_HOST;
>  		break;
>  	};
> -	return (polling ? netif_receive_skb(skb) : netif_rx(skb));
> +	return 0;
>  }
> -EXPORT_SYMBOL(__vlan_hwaccel_rx);
>  
>  struct net_device *vlan_dev_real_dev(const struct net_device *dev)
>  {
> diff --git a/net/core/dev.c b/net/core/dev.c
> index d9038e3..9174c77 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2218,6 +2218,9 @@ int netif_receive_skb(struct sk_buff *skb)
>  	int ret = NET_RX_DROP;
>  	__be16 type;
>  
> +	if (skb->vlan_tci && vlan_hwaccel_do_receive(skb))
> +		return NET_RX_SUCCESS;
> +
>  	/* if we've gotten here through NAPI, check netpoll */
>  	if (netpoll_receive_skb(skb))
>  		return NET_RX_DROP;

