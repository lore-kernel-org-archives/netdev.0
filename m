From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v2 04/14] vlan: Enable software emulation for vlan
 accleration.
Date: Thu, 21 Oct 2010 16:30:08 +0100
Message-ID: <1287675008.2235.8.camel@achroite.uk.solarflarecom.com>
References: <1287618974-4714-1-git-send-email-jesse@nicira.com>
	 <1287618974-4714-5-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:8439 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751884Ab0JUPaM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 11:30:12 -0400
In-Reply-To: <1287618974-4714-5-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-10-20 at 16:56 -0700, Jesse Gross wrote:
> Currently users of hardware vlan accleration need to know whether
> the device supports it before generating packets.  However, vlan
> acceleration will soon be available in a more flexible manner so
> knowing ahead of time becomes much more difficult.  This adds
> a software fallback path for vlan packets on devices without the
> necessary offloading support, similar to other types of hardware
> accleration.
[...]
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
[...]

Additional context:

		struct vlan_ethhdr *veh = (struct vlan_ethhdr *)skb->data;
		if (can_checksum_protocol(dev->features & dev->vlan_features,
					  veh->h_vlan_encapsulated_proto))
			return true;
	}

	return false;
}

I don't think this will do the right thing if the NIC does VLAN tag
insertion and checksum offload with only one layer of VLAN
encapsulation, but the skb has two layers of VLAN encapsulation.

I think we actually want something like:

static bool dev_can_checksum(struct net_device *dev, struct sk_buff *skb)
{
	__be16 protocol = skb->protocol;
	int features = dev->features;

	if (vlan_tx_tag_present(skb)) {
		features &= dev->vlan_features;
	} else if (skb->protocol == htons(ETH_P_8021Q)) {
		struct vlan_ethhdr *veh = (struct vlan_ethhdr *)skb->data;
		protocol = veh->h_vlan_encapsulated_proto;
		features &= dev->vlan_features;
	}

	return can_checksum_protocol(features, protocol);
}

Does that look right?

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

