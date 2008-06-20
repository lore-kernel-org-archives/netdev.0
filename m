From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/2] net: Disable LRO on devices that are forwarding
Date: Fri, 20 Jun 2008 12:11:41 +0100
Message-ID: <20080620111139.GB29360@solarflare.com>
References: <cover.1213898165.git.bhutchings@solarflare.com> <20080619180735.GT5350@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	Kieran Mansley <kmansley@solarflare.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Stephen Hemminger <shemminger@vyatta.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.mbr-roch.zen.net.uk ([212.23.3.140]:60592 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752073AbYFTLLs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2008 07:11:48 -0400
Content-Disposition: inline
In-Reply-To: <20080619180735.GT5350@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings wrote:
[...]
> diff --git a/net/core/dev.c b/net/core/dev.c
> index a495f71..f6944ec 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
[...]
> @@ -1123,6 +1124,29 @@ int dev_close(struct net_device *dev)
>  }
>  
>  
> +/**
> + *	dev_disable_lro - disable Large Receive Offload on a device
> + *	@dev: device
> + *
> + *	Disable Large Receive Offload (LRO) on a net device.  Must be
> + *	called under RTNL.  This is needed if received packets may be
> + *	forwarded to another interface.
> + */
> +void dev_disable_lro(struct net_device *dev)
> +{
> +	if (dev->ethtool_ops && dev->ethtool_ops->get_flags &&
> +	    dev->ethtool_ops->set_flags) {
> +		u32 flags = dev->ethtool_ops->get_flags(dev);
> +		if (flags & ETH_FLAG_LRO) {
> +			flags &= ~ETH_FLAG_LRO;
> +			dev->ethtool_ops->set_flags(dev, flags);
> +		}
> +	}
> +	WARN_ON(dev->features & NETIF_F_LRO);
> +}
> +EXPORT_SYMBOL(dev_disable_lro);
[...]

Of course, this doesn't work where the device that's about to start
forwarding is a VLAN device, bonding device or other device depending on
the physical device which is doing LRO.

It might be worth separating out the offload control ops from ethtool ops
since they could usefully be applied to other device types... particularly
here.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
