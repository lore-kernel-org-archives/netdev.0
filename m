From: Patrick McHardy <kaber@trash.net>
Subject: Re: IGMP sent to Foreign VLAN
Date: Wed, 08 Oct 2008 01:53:27 +0200
Message-ID: <48EBF677.1060602@trash.net>
References: <1223322707.24688.46.camel@deepthought.nh.local> <20081007.160702.189194318.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: j.neuner@networkharbor.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:63511 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750983AbYJGXyw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2008 19:54:52 -0400
In-Reply-To: <20081007.160702.189194318.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Jarod Neuner <j.neuner@networkharbor.com>
> Date: Mon, 6 Oct 2008 14:51:47 -0500
>
>   
>> I noticed a problem where the kernel is not responding to IGMP Queries
>> from several Level-3 network switches.  This behavior is caused by these
>> switches using VLAN tags on IGMP messages.  At first I thought the
>> switches were out of spec, but every other network stack I've checked
>> delivers packets with unconfigured VLAN assignments directly to the
>> incoming interface.  
>>
>> This patch corrects my problem, but I'm still interested in discussion
>> about whether or not this should be a parameter in /proc/sys/net or even
>> if this policy change should be applied elsewhere in the the network
>> stack.
>>     
>
> Interesting.
>   

Indeed.
> Patrick, any opinion?
>   

I don't like a /proc flag very much, but I believe it should be
configurable. To make this behaviour consistent there also needs
to be some indication to drivers to disable hardware filters, so
we really should have an explicit action from the user first.

We've been talking about an IFF_ALLVLAN flag on netdev a while
ago, which would disable VLAN hardware filters, similar to
IFF_ALLMULTI. An additional flag on the ethernet device could
indicate that it should receive unknown VLANs directly. That
would introduce some possible inconsistencies however since the
flag could be set without the VLAN code even loaded, in which
case it would not have any effect.

Another possibility would be to use a catch-all VLAN device with
VID 0xfff (reserved for implementation use). This would allow
to configure priority mappings, header reordering etc. and have
separate statistics. The drivers could just use the magic VID
as an indication to disable filtering, but I would still suggest
to add the IFF_ALLVLAN flag because its useful on its own.

>> diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
>> index 4bf014e..b65a8fd 100644
>> --- a/net/8021q/vlan_dev.c
>> +++ b/net/8021q/vlan_dev.c
>> @@ -158,9 +158,13 @@ int vlan_skb_recv(struct sk_buff *skb, struct net_device *dev,
>>         rcu_read_lock();
>>         skb->dev = __find_vlan_dev(dev, vlan_id);
>>         if (!skb->dev) {
>> -               pr_debug("%s: ERROR: No net_device for VID: %u on dev: %s\n",
>> +               pr_debug("%s: WARNING: Forwarding VID: %u to dev: %s\n",
>>                          __func__, vlan_id, dev->name);
>> -               goto err_unlock;
>> +               skb->dev = dev;
>> +               skb_pull_rcsum(skb, VLAN_HLEN);
>> +               vlan_set_encap_proto(skb, vhdr);
>> +               rcu_read_lock();
>> +               return 0;
>>     

This can't be right though, the packet needs to be passed
up the stack. The same change will also be needed in
__vlan_hwaccel_rx().

