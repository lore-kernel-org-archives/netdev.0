From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [PATCH net-next v2 02/12] net: dsa: add Broadcom tag hook
Date: Wed, 06 Aug 2014 13:16:23 -0700
Message-ID: <53E28D17.8080406@intel.com>
References: <1407277906-19989-1-git-send-email-f.fainelli@gmail.com> <1407277906-19989-3-git-send-email-f.fainelli@gmail.com> <53E23FFE.2090707@intel.com> <53E27607.8030301@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, linville@tuxdriver.com
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:22167 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753805AbaHFUQb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Aug 2014 16:16:31 -0400
In-Reply-To: <53E27607.8030301@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/06/2014 11:37 AM, Florian Fainelli wrote:
> On 08/06/2014 07:47 AM, Alexander Duyck wrote:
>> On 08/05/2014 03:31 PM, Florian Fainelli wrote:
>>> Register a fake Ethertype for the Broadcom tag to allow us to hook into
>>> a given Ethernet device receive path and parse this Broadcom tag.
>>>
>>> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> 
> [snip]
> 
>>> diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
>>> index f405e0592407..6b67653d5283 100644
>>> --- a/net/ethernet/eth.c
>>> +++ b/net/ethernet/eth.c
>>> @@ -186,6 +186,8 @@ __be16 eth_type_trans(struct sk_buff *skb, struct net_device *dev)
>>>  
>>>  	if (unlikely(netdev_uses_trailer_tags(dev)))
>>>  		return htons(ETH_P_TRAILER);
>>> +	if (netdev_uses_brcm_tags(dev))
>>> +		return htons(ETH_P_BRCMTAG);
>>>  
>>>  	if (likely(ntohs(eth->h_proto) >= ETH_P_802_3_MIN))
>>>  		return eth->h_proto;
>>>
>>
>> Maybe we should consider some change to this logic.  Maybe a bit flag in
>> the dsa_switch_tree structure that indicates if eth_type_trans should
>> override the protocol or not.
> 
> I just tested something like this, which becomes protocol agnostic:
> 
> if (unlikely(netdev_uses_dsa(dev)))
> 	return dsa_tag_protocol(dev);
> 
> include/linux/netdevice.h:
> static inline bool netdev_uses_dsa(struct net_device *dev)
> {
> #ifdef CONFIG_NET_DSA
> 	return dev->dsa_ptr != NULL;
> #else
> 	return false;
> #endif
> }
> 
> include/net/dsa.h:
> static __be16 netdev_dsa_protocol(struct net_device *dev)
> {
> #ifdef CONFIG_NET_DSA
> 	struct dsa_switch_tree *dst = dev->dsa_ptr;
> 	return dst->tag_protocol;
> #endif
> }
> 
>> Otherwise this is going to start becoming
>> a rather large conditional statement if we have to add a new if every
>> time a new switch is added.
> 
> Agreed.
> 

I think EDSA does not have same logic for inserting the tags.  You may
want to look into that to determine if this is acceptable for that case
or not.

Thanks,

Alex
