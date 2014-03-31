From: Neil Jerram <Neil.Jerram@metaswitch.com>
Subject: RE: [PATCH net] net: Account for all vlan headers in
 skb_mac_gso_segment
Date: Mon, 31 Mar 2014 21:22:20 +0000
Message-ID: <F6885DC5CBE92C4BB4D654841E63A30FD7DFC942@ENFIRHMBX1.datcon.co.uk>
References: <1395849071-15432-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
To: 'Vlad Yasevich' <vyasevic@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from enficsets1.metaswitch.com ([192.91.191.38]:1363 "EHLO
	ENFICSETS1.metaswitch.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750966AbaCaVWX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2014 17:22:23 -0400
In-Reply-To: <1395849071-15432-1-git-send-email-vyasevic@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Vlad,

> skb_network_protocol() already accounts for multiple vlan
> headers that may be present in the skb.  However, skb_mac_gso_segment()
> doesn't know anything about it and assumes that skb->mac_len
> is set correctly to skip all mac headers.  That may not
> always be the case.  If we are simply forwarding the packet (via
> bridge or macvtap), all vlan headers may not be accounted for.

When is it the case that skb->mac_len does not include all VLAN tags?  If you can clearly describe when this is true, and when not, it would be nice to add a comment above the mac_len field in skbuff.h, to explain.

> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index d855794..18b8c1b 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -3015,7 +3015,7 @@ struct sk_buff *skb_gso_segment(struct sk_buff *skb,
> netdev_features_t features)
>  {
>  	return __skb_gso_segment(skb, features, true);
>  }
> -__be16 skb_network_protocol(struct sk_buff *skb);
> +__be16 skb_network_protocol(struct sk_buff *skb, int *depth);

For me, eth_hdr_len or l2_hdr_len would be much clearer names than "depth".

>  static inline bool can_checksum_protocol(netdev_features_t features,
>  					 __be16 protocol)
> diff --git a/net/core/dev.c b/net/core/dev.c
> index a98f7fa..49c41e6 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2287,7 +2287,7 @@ out:
>  }
>  EXPORT_SYMBOL(skb_checksum_help);
> 
> -__be16 skb_network_protocol(struct sk_buff *skb)
> +__be16 skb_network_protocol(struct sk_buff *skb, int *depth)
>  {
>  	__be16 type = skb->protocol;
>  	int vlan_depth = ETH_HLEN;
> @@ -2314,6 +2314,9 @@ __be16 skb_network_protocol(struct sk_buff *skb)
>  		vlan_depth += VLAN_HLEN;
>  	}
> 
> +	if (depth)
> +		*depth = vlan_depth;
> +
>  	return type;
>  }

Similarly here ...

> @@ -2327,12 +2330,13 @@ struct sk_buff *skb_mac_gso_segment(struct sk_buff
> *skb,
>  {
>  	struct sk_buff *segs = ERR_PTR(-EPROTONOSUPPORT);
>  	struct packet_offload *ptype;
> -	__be16 type = skb_network_protocol(skb);
> +	int vlan_depth = 0;
> +	__be16 type = skb_network_protocol(skb, &vlan_depth);
> 
>  	if (unlikely(!type))
>  		return ERR_PTR(-EINVAL);
> 
> -	__skb_pull(skb, skb->mac_len);
> +	__skb_pull(skb, vlan_depth > skb->mac_len ? vlan_depth : skb->mac_len);

... and here (obviously).

Regards,
	Neil
