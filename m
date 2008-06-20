From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/2] net: Disable LRO on devices that are forwarding
Date: Fri, 20 Jun 2008 13:17:10 +0200
Message-ID: <485B91B6.6090303@trash.net>
References: <cover.1213898165.git.bhutchings@solarflare.com> <20080619180735.GT5350@solarflare.com> <20080620111139.GB29360@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com,
	Kieran Mansley <kmansley@solarflare.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:60175 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752489AbYFTLRO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2008 07:17:14 -0400
In-Reply-To: <20080620111139.GB29360@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings wrote:
> Ben Hutchings wrote:
> [...]
>> diff --git a/net/core/dev.c b/net/core/dev.c
>> index a495f71..f6944ec 100644
>> --- a/net/core/dev.c
>> +++ b/net/core/dev.c
> [...]
>> @@ -1123,6 +1124,29 @@ int dev_close(struct net_device *dev)
>>  }
>>  
>>  
>> +/**
>> + *	dev_disable_lro - disable Large Receive Offload on a device
>> + *	@dev: device
>> + *
>> + *	Disable Large Receive Offload (LRO) on a net device.  Must be
>> + *	called under RTNL.  This is needed if received packets may be
>> + *	forwarded to another interface.
>> + */
>> +void dev_disable_lro(struct net_device *dev)
>> +{
>> +	if (dev->ethtool_ops && dev->ethtool_ops->get_flags &&
>> +	    dev->ethtool_ops->set_flags) {
>> +		u32 flags = dev->ethtool_ops->get_flags(dev);
>> +		if (flags & ETH_FLAG_LRO) {
>> +			flags &= ~ETH_FLAG_LRO;
>> +			dev->ethtool_ops->set_flags(dev, flags);
>> +		}
>> +	}
>> +	WARN_ON(dev->features & NETIF_F_LRO);
>> +}
>> +EXPORT_SYMBOL(dev_disable_lro);
> [...]
> 
> Of course, this doesn't work where the device that's about to start
> forwarding is a VLAN device, bonding device or other device depending on
> the physical device which is doing LRO.
> 
> It might be worth separating out the offload control ops from ethtool ops
> since they could usefully be applied to other device types... particularly
> here.


You can propagate it to the real device. I have a patch queued
to add ethtool support to vlan, I can send it to Dave this
weekend. I guess for bonding etc. that would also be useful
for disabling offloading/checksumming/... globally or just
querying the state.
