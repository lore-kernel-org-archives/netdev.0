From: Patrick McHardy <kaber@trash.net>
Subject: Re: [net-next-2.6 V7 PATCH 1/2] Add netlink support for virtual port
 management (was iovnl)
Date: Fri, 14 May 2010 18:42:12 +0200
Message-ID: <4BED7D64.3070500@trash.net>
References: <20100514013144.1816.31191.stgit@savbu-pc100.cisco.com> <20100514013526.1816.45104.stgit@savbu-pc100.cisco.com> <4BED2CD8.4020209@trash.net> <201005141412.01578.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Scott Feldman <scofeldm@cisco.com>, davem@davemloft.net,
	netdev@vger.kernel.org, chrisw@redhat.com
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:48582 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751422Ab0ENQmN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 May 2010 12:42:13 -0400
In-Reply-To: <201005141412.01578.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Arnd Bergmann wrote:
> On Friday 14 May 2010, Patrick McHardy wrote:
>>> +static int rtnl_vf_port_fill_nest(struct sk_buff *skb, struct net_device *dev,
>>> +				  int vf)
>>> +{
>>> +	struct nlattr *data;
>>> +	int err;
>>> +
>>> +	data = nla_nest_start(skb, IFLA_VF_PORT);
>> We usually use a top-level attribute to encapsulate lists of identical
>> attributes. The other iflink attributes may only occur once and are
>> usually parsed using nla_parse_nested(), which will parse all
>> IFLA_VF_PORT attributes, but only return the last one.
>>
>> Something like:
>>
>> iflink message:
>> ...
>> [IFLA_VF_PORTS]
>>   [IFLA_VF_PORT]
>>     [IFLA_VF_PORT_*], ...
>>   [IFLA_VF_PORT]
>>     [IFLA_VF_PORT_*], ...
>>   ...
> 
> Ah, I was wondering about this already. Does this mean that IFLA_VFINFO
> does this incorrectly as well?

Yes.

>>>  static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
>>>  			    int type, u32 pid, u32 seq, u32 change,
>>>  			    unsigned int flags)
>>> @@ -747,17 +819,23 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
>>>  		goto nla_put_failure;
>>>  	copy_rtnl_link_stats64(nla_data(attr), stats);
>>>  
>>> +	if (dev->dev.parent)
>>> +		NLA_PUT_U32(skb, IFLA_NUM_VF, dev_num_vf(dev->dev.parent));
>> Just wondering, is the only case where dev.parent is non-NULL
>> really when virtual ports are present?
> 
> No, but if parent is NULL, we must not call dev_num_vf(). The way that enic
> needs the attributes, they can be either for the VF of dev->dev.parent (the
> PCI PF), or for the PF itself, even if it does not have VFs, in which case
> it would be interesting to have IFLA_NUM_VF = 0 in the output.

I see. I was mainly wondering about completely different types of
devices.

> Maybe a better structure would be to separate the two cases, also allowing
> a port profile to be associated with both the PF and with each of its VFs?
> 
> Something like this:
> 
> [IFLA_NUM_VF]
> [IFLA_VF_PORTS]
>   [IFLA_VF_PORT]
>     [IFLA_VF_PORT_*], ...
>   [IFLA_VF_PORT]
>     [IFLA_VF_PORT_*], ...
> [IFLA_PORT_SELF]
>   [IFLA_VF_PORT_*], ...

That would also be fine.
