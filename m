From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v3] vlan: allow TSO setting on vlan interfaces
Date: Thu, 08 Jul 2010 19:25:48 +0100
Message-ID: <1278613548.16013.193.camel@achroite.uk.solarflarecom.com>
References: <1278522874.5906.9.camel@edumazet-laptop>
	 <1278523511.2080.3.camel@achroite.uk.solarflarecom.com>
	 <1278571587.2543.9.camel@edumazet-laptop>
	 <1278581971.2651.10.camel@edumazet-laptop>
	 <1278603804.16013.24.camel@achroite.uk.solarflarecom.com>
	 <1278604985.2651.35.camel@edumazet-laptop>
	 <1278607037.2651.57.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:5188 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754075Ab0GHSZw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jul 2010 14:25:52 -0400
In-Reply-To: <1278607037.2651.57.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-07-08 at 18:37 +0200, Eric Dumazet wrote:
> When we need to shape traffic using low speeds, we need to
> disable tso on network interface :
> 
> ethtool -K eth0.2240 tso off
> 
> It seems vlan interfaces miss the set_tso() ethtool method.
> 
> Before enabling TSO, we must check real device supports 
> TSO for VLAN-tagged packets and enables TSO.
> 
> Note that a TSO change on real device propagates TSO setting
> on all vlans, even if admin selected a different TSO setting.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

> ---
>  net/8021q/vlan_dev.c |   20 ++++++++++++++++++++
>  1 file changed, 20 insertions(+)
> 
> diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
> index 7865a4c..a1b8171 100644
> --- a/net/8021q/vlan_dev.c
> +++ b/net/8021q/vlan_dev.c
> @@ -836,12 +836,32 @@ static struct rtnl_link_stats64 *vlan_dev_get_stats64(struct net_device *dev, st
>  	return stats;
>  }
>  
> +static int vlan_ethtool_set_tso(struct net_device *dev, u32 data)
> +{
> +       if (data) {
> +		struct net_device *real_dev = vlan_dev_info(dev)->real_dev;
> +
> +		/* Underlying device must support TSO for VLAN-tagged packets
> +		 * and must have TSO enabled now.
> +		 */
> +		if (!(real_dev->vlan_features & NETIF_F_TSO))
> +			return -EOPNOTSUPP;
> +		if (!(real_dev->features & NETIF_F_TSO))
> +			return -EINVAL;
> +		dev->features |= NETIF_F_TSO;
> +	} else {
> +		dev->features &= ~NETIF_F_TSO;
> +	}
> +	return 0;
> +}
> +
>  static const struct ethtool_ops vlan_ethtool_ops = {
>  	.get_settings	        = vlan_ethtool_get_settings,
>  	.get_drvinfo	        = vlan_ethtool_get_drvinfo,
>  	.get_link		= ethtool_op_get_link,
>  	.get_rx_csum		= vlan_ethtool_get_rx_csum,
>  	.get_flags		= vlan_ethtool_get_flags,
> +	.set_tso                = vlan_ethtool_set_tso,
>  };
>  
>  static const struct net_device_ops vlan_netdev_ops = {
> 
> 
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

