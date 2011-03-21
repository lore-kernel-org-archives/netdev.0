From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: LRO disable warnings on kernel 2.6.38
Date: Mon, 21 Mar 2011 13:52:23 +0000
Message-ID: <1300715543.26693.349.camel@localhost>
References: <1300446743.11985.317.camel@firesoul.comx.local>
	 <4D8385CE.1060205@intel.com>
	 <1300699294.10934.63.camel@firesoul.comx.local>
	 <1300700708.2884.10.camel@edumazet-laptop>
	 <99737F4847ED0A48AECC9F4A1974A4B80FD10E8429@MNEXMB2.qlogic.org>
	 <20110321123406.GA2376@redhat.com>  <20110321134647.GA3126@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Amit Salecha <amit.salecha@qlogic.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jesper Dangaard Brouer <hawk@comx.dk>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev <netdev@vger.kernel.org>,
	Neil Horman <nhorman@tuxdriver.com>
To: Stanislaw Gruszka <sgruszka@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:30589 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751444Ab1CUNxg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2011 09:53:36 -0400
In-Reply-To: <20110321134647.GA3126@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-03-21 at 14:46 +0100, Stanislaw Gruszka wrote:
> On Mon, Mar 21, 2011 at 01:34:06PM +0100, Stanislaw Gruszka wrote:
[...]
> > I'm afraid some other drivers can have similar problem after
> > adding ETH_FLAG_{TX,RX}VLAN. I think we need to distinguish features
> > that are configurable at runtime from features that are hardcoded.
> > I'm going to look at that.
> 
> Other drivers have this bug too. I'm going to prepare patch with similar fix
> like Amit proposed, but also for other drivers. Something like below:

This may be useful temporarily, but the new netdev-features API seems to
make this easier to get right.  We should be moving drivers over to that
instead.

Ben.

> diff --git a/net/core/ethtool.c b/net/core/ethtool.c
> index c1a71bb..38fd0cb 100644
> --- a/net/core/ethtool.c
> +++ b/net/core/ethtool.c
> @@ -141,9 +141,17 @@ u32 ethtool_op_get_flags(struct net_device *dev)
>  }
>  EXPORT_SYMBOL(ethtool_op_get_flags);
>  
> +bool ethtool_invalid_flags(struct net_device *dev, u32 data, u32 supported)
> +{
> +	if ((dev->features & ~supported) != (data & ~supported))
> +		return true;
> +	else
> +		return false;
> +}
> +
>  int ethtool_op_set_flags(struct net_device *dev, u32 data, u32 supported)
>  {
> -	if (data & ~supported)
> +	if (ethtool_invalid_flags(dev, data, supported);
>  		return -EINVAL;
>  
>  	dev->features = ((dev->features & ~flags_dup_features) |
> diff --git a/drivers/net/vmxnet3/vmxnet3_ethtool.c b/drivers/net/vmxnet3/vmxnet3_ethtool.c
> index 81254be..7a662f1 100644
> --- a/drivers/net/vmxnet3/vmxnet3_ethtool.c
> +++ b/drivers/net/vmxnet3/vmxnet3_ethtool.c
> @@ -304,8 +304,8 @@ vmxnet3_set_flags(struct net_device *netdev, u32 data)
>  	u8 lro_present = (netdev->features & NETIF_F_LRO) == 0 ? 0 : 1;
>  	unsigned long flags;
>  
> -	if (data & ~ETH_FLAG_LRO)
> -		return -EOPNOTSUPP;
> +	if (ethtool_invalid_flags(netdev, data, ETH_FLAG_LRO))
> +		return -EINVAL;
>  
>  	if (lro_requested ^ lro_present) {
>  		/* toggle the LRO feature*/

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

