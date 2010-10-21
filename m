From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH v2 04/14] vlan: Enable software emulation for vlan accleration.
Date: Wed, 20 Oct 2010 20:32:12 -0700
Message-ID: <4CBFB43C.6000501@intel.com>
References: <1287618974-4714-1-git-send-email-jesse@nicira.com> <1287618974-4714-5-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:10016 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757083Ab0JUDcM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Oct 2010 23:32:12 -0400
In-Reply-To: <1287618974-4714-5-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/20/2010 4:56 PM, Jesse Gross wrote:
> Currently users of hardware vlan accleration need to know whether
> the device supports it before generating packets.  However, vlan
> acceleration will soon be available in a more flexible manner so
> knowing ahead of time becomes much more difficult.  This adds
> a software fallback path for vlan packets on devices without the
> necessary offloading support, similar to other types of hardware
> accleration.
> 
> Signed-off-by: Jesse Gross <jesse@nicira.com>
> ---
>  include/linux/netdevice.h |   14 +++++++++++---
>  net/core/dev.c            |   36 +++++++++++++++++++++++++++++++++---
>  2 files changed, 44 insertions(+), 6 deletions(-)
> 
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 880d565..2861565 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -2248,9 +2248,17 @@ static inline int skb_gso_ok(struct sk_buff *skb, int features)
>  
>  static inline int netif_needs_gso(struct net_device *dev, struct sk_buff *skb)
>  {
> -	return skb_is_gso(skb) &&
> -	       (!skb_gso_ok(skb, dev->features) ||
> -		unlikely(skb->ip_summed != CHECKSUM_PARTIAL));
> +	if (skb_is_gso(skb)) {
> +		int features = dev->features;
> +
> +		if (skb->protocol == htons(ETH_P_8021Q) || skb->vlan_tci)
> +			features &= dev->vlan_features;
> +
> +		return (!skb_gso_ok(skb, features) ||
> +			unlikely(skb->ip_summed != CHECKSUM_PARTIAL));
> +	}
> +
> +	return 0;
>  }
>  
>  static inline void netif_set_gso_max_size(struct net_device *dev,
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 4c3ac53..1bfd96b 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1694,7 +1694,12 @@ static bool can_checksum_protocol(unsigned long features, __be16 protocol)
>  
>  static bool dev_can_checksum(struct net_device *dev, struct sk_buff *skb)
>  {
> -	if (can_checksum_protocol(dev->features, skb->protocol))
> +	int features = dev->features;
> +
> +	if (vlan_tx_tag_present(skb))
> +		features &= dev->vlan_features;
> +
> +	if (can_checksum_protocol(features, skb->protocol))
>  		return true;
>  
>  	if (skb->protocol == htons(ETH_P_8021Q)) {
> @@ -1793,6 +1798,16 @@ struct sk_buff *skb_gso_segment(struct sk_buff *skb, int features)
>  	__be16 type = skb->protocol;
>  	int err;
>  
> +	if (type == htons(ETH_P_8021Q)) {
> +		struct vlan_ethhdr *veh;
> +
> +		if (unlikely(!pskb_may_pull(skb, VLAN_ETH_HLEN)))
> +			return ERR_PTR(-EINVAL);
> +
> +		veh = (struct vlan_ethhdr *)skb->data;
> +		type = veh->h_vlan_encapsulated_proto;
> +	}
> +
>  	skb_reset_mac_header(skb);
>  	skb->mac_len = skb->network_header - skb->mac_header;
>  	__skb_pull(skb, skb->mac_len);
> @@ -1964,9 +1979,14 @@ static inline void skb_orphan_try(struct sk_buff *skb)
>  static inline int skb_needs_linearize(struct sk_buff *skb,
>  				      struct net_device *dev)
>  {
> +	int features = dev->features;
> +
> +	if (skb->protocol == htons(ETH_P_8021Q) || vlan_tx_tag_present(skb))
> +		features &= dev->vlan_features;
> +
>  	return skb_is_nonlinear(skb) &&
> -	       ((skb_has_frag_list(skb) && !(dev->features & NETIF_F_FRAGLIST)) ||
> -	        (skb_shinfo(skb)->nr_frags && (!(dev->features & NETIF_F_SG) ||
> +	       ((skb_has_frag_list(skb) && !(features & NETIF_F_FRAGLIST)) ||
> +		(skb_shinfo(skb)->nr_frags && (!(features & NETIF_F_SG) ||
>  					      illegal_highdma(dev, skb))));
>  }
>  
> @@ -1989,6 +2009,15 @@ int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
>  
>  		skb_orphan_try(skb);
>  
> +		if (vlan_tx_tag_present(skb) &&
> +		    !(dev->features & NETIF_F_HW_VLAN_TX)) {
> +			skb = __vlan_put_tag(skb, vlan_tx_tag_get(skb));
> +			if (unlikely(!skb))
> +				goto out;
> +
> +			skb->vlan_tci = 0;
> +		}
> +

Nice set of patches! If we tag frames in dev_hard_start_xmit() can we consolidate
the offload enabled and non-offloaded net_device_ops in 8021q. And then not tag in
vlan_dev_hard_start_xmit? I'll post an example thinking out loud here.

Thanks,
John.


>  		if (netif_needs_gso(dev, skb)) {
>  			if (unlikely(dev_gso_segment(skb)))
>  				goto out_kfree_skb;
> @@ -2050,6 +2079,7 @@ out_kfree_gso_skb:
>  		skb->destructor = DEV_GSO_CB(skb)->destructor;
>  out_kfree_skb:
>  	kfree_skb(skb);
> +out:
>  	return rc;
>  }
>  

