From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next v2 5/6] vxlan: Add tx-vlan offload support.
Date: Tue, 23 Jul 2013 20:27:51 +0100
Message-ID: <1374607671.2072.16.camel@bwh-desktop.uk.level5networks.com>
References: <1374603770-15567-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <stephen@networkplumber.org>
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:8132 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933884Ab3GWT1z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jul 2013 15:27:55 -0400
In-Reply-To: <1374603770-15567-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-07-23 at 11:22 -0700, Pravin B Shelar wrote:
> Following patch allows transmit side vlan offload for vxlan
> devices.
> 
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
> ---
>  drivers/net/vxlan.c |   15 ++++++++++++++-
>  1 files changed, 14 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> index 1ca7ca3..f76c09c 100644
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
> @@ -27,6 +27,7 @@
>  #include <linux/igmp.h>
>  #include <linux/etherdevice.h>
>  #include <linux/if_ether.h>
> +#include <linux/if_vlan.h>
>  #include <linux/hash.h>
>  #include <linux/ethtool.h>
>  #include <net/arp.h>
> @@ -1076,13 +1077,23 @@ int vxlan_xmit_skb(struct net *net, struct vxlan_handler *vh,
>  	}
>  
>  	min_headroom = LL_RESERVED_SPACE(rt->dst.dev) + rt->dst.header_len
> -			+ VXLAN_HLEN + sizeof(struct iphdr);
> +			+ VXLAN_HLEN + sizeof(struct iphdr)
> +			+ (vlan_tx_tag_present(skb) ? VLAN_HLEN : 0);
>  
>  	/* Need space for new headers (invalidates iph ptr) */
>  	err = skb_cow_head(skb, min_headroom);
>  	if (unlikely(err))
>  		return err;
>  
> +	if (vlan_tx_tag_present(skb)) {
> +		if (unlikely(!__vlan_put_tag(skb,
> +					     skb->vlan_proto,
> +					     vlan_tx_tag_get(skb))))
> +			return -ENOMEM;

This can't fail since we already did skb_cow_head().  So a WARN_ON()
might be appropriate.

> +		skb->vlan_tci = 0;
> +	}
> +
>  	vxh = (struct vxlanhdr *) __skb_push(skb, sizeof(*vxh));
>  	vxh->vx_flags = htonl(VXLAN_FLAGS);
>  	vxh->vx_vni = vni;
> @@ -1486,6 +1497,8 @@ static void vxlan_setup(struct net_device *dev)
>  	dev->features   |= NETIF_F_RXCSUM;
>  	dev->features   |= NETIF_F_GSO_SOFTWARE;
>  
> +	dev->vlan_features = dev->features;
> +	dev->features |= NETIF_F_HW_VLAN_CTAG_TX;

You can also add NETIF_F_HW_VLAN_STAG_TX.

>  	dev->hw_features |= NETIF_F_SG | NETIF_F_HW_CSUM | NETIF_F_RXCSUM;
>  	dev->hw_features |= NETIF_F_GSO_SOFTWARE;

Should the VLAN TX features also be included in dev->hw_features?  (I'm
not sure why you'd want to turn them off, but they are usually made
optional.)

Ben.

>  	dev->priv_flags	&= ~IFF_XMIT_DST_RELEASE;

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
