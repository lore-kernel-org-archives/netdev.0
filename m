From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v2] vlan: allow TSO setting on vlan interfaces
Date: Thu, 08 Jul 2010 16:43:24 +0100
Message-ID: <1278603804.16013.24.camel@achroite.uk.solarflarecom.com>
References: <1278522874.5906.9.camel@edumazet-laptop>
	 <1278523511.2080.3.camel@achroite.uk.solarflarecom.com>
	 <1278571587.2543.9.camel@edumazet-laptop>
	 <1278581971.2651.10.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:50408 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755616Ab0GHPn1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jul 2010 11:43:27 -0400
In-Reply-To: <1278581971.2651.10.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-07-08 at 11:39 +0200, Eric Dumazet wrote:
> When we need to shape traffic with low speeds, we need to disable tso on
> network interface :
> 
> ethtool -K eth0.2240 tso off
> 
> It seems vlan interfaces miss the set_tso() ethtool method.
> Propagating tso changes from lower device is not always wanted, some
> vlans want TSO on, others want TSO off.
> 
> Before enabling TSO, we must check real device supports it.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
>  net/8021q/vlan_dev.c |   13 +++++++++++++
>  1 file changed, 13 insertions(+)
> 
> diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
> index c6456cb..870bc53 100644
> --- a/net/8021q/vlan_dev.c
> +++ b/net/8021q/vlan_dev.c
> @@ -838,12 +838,25 @@ static struct rtnl_link_stats64 *vlan_dev_get_stats64(struct net_device *dev)
>  	return stats;
>  }
>  
> +static int vlan_ethtool_set_tso(struct net_device *dev, u32 data)
> +{
> +	if (data) {
> +		struct net_device *real_dev = vlan_dev_info(dev)->real_dev;
> +		unsigned long rdev_vfeatures = real_dev->features & real_dev->vlan_features;
> +
> +		dev->features |= (NETIF_F_TSO & rdev_vfeatures);
> +	} else
> +		dev->features &= ~NETIF_F_TSO;
> +	return 0;
> +}
[...]

This should not silently ignore attempts to enable TSO.  I think it
should be something like:

static int vlan_ethtool_set_tso(struct net_device *dev, u32 data)
{
	if (data) {
		struct net_device *real_dev = vlan_dev_info(dev)->real_dev;

		/* Underlying device must support TSO for VLAN-tagged packets
		 * and must have TSO enabled now. */
		if (!(real_dev->vlan_features & NETIF_F_TSO))
			return -EOPNOTSUPP;
		if (!(real_dev->features & NETIF_F_TSO))
			return -EINVAL;

		dev->features |= NETIF_F_TSO;
	} else {
		dev->features &= ~NETIF_F_TSO;
	}

	return 0;
}

I think the vlan driver should also have a netdev notifier to handle
feature changes on the underlying device.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

