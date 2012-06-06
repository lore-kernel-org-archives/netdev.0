From: Vladimir Davydov <VDavydov@parallels.com>
Subject: Re: Possible deadlock in ipv6?
Date: Wed, 6 Jun 2012 20:01:38 +0400
Message-ID: <D0983DA9-2545-4007-8A69-31DDCB9B7CCF@parallels.com>
References: <4FCF6DF4.2090304@parallels.com>
 <1338998019.26966.10.camel@edumazet-glaptop>
 <1338998314.26966.12.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.parallels.com ([195.214.232.42]:34635 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757048Ab2FFQBn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2012 12:01:43 -0400
In-Reply-To: <1338998314.26966.12.camel@edumazet-glaptop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Jun 6, 2012, at 7:58 PM, Eric Dumazet wrote:

> On Wed, 2012-06-06 at 17:53 +0200, Eric Dumazet wrote:
>> On Wed, 2012-06-06 at 18:49 +0400, Vladimir Davydov wrote:
>>> I'm not familiar with the linux net subsystem, so I would appreciate if 
>>> someone could clarify if the following call chain is possible:
>>> 
>>> addrconf_ifdown() calls neigh_ifdown(nd_tbl) which locks nd_tbl.lock for 
>>> writing and calls
>>> 
>>>     pneigh_ifdown
>>>     pndisc_destructor
>>>     ipv6_dev_mc_dec
>>>     __ipv6_dev_mc_dec
>>>     igmp6_group_dropped
>>>     igmp6_leave_group
>>>     igmp6_send
>>>     icmp6_dst_alloc
>>>     ip6_neigh_lookup
>>>     neigh_create
>>> 
>>> and neigh_create() locks nd_tbl.lock for writing again resulting in a 
>>> deadlock.
>> 
>> It seems a deadlock is possible indeed, good catch !
>> 
>> 
> 
> And it seems this neigh_down() can be removed, its called later
> (after dev->ip6_ptr is cleared)
> 

BTW, commit d1ed113f1669390da9898da3beddcc058d938587 did exactly the same, but it was reverted along with a bundle of other commits by 73a8bd74e2618990dbb218c3d82f53e60acd9af0.

> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 8f6411c..62c4c00 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -2750,7 +2750,6 @@ static int addrconf_ifdown(struct net_device *dev, int how)
> 	ASSERT_RTNL();
> 
> 	rt6_ifdown(net, dev);
> -	neigh_ifdown(&nd_tbl, dev);
> 
> 	idev = __in6_dev_get(dev);
> 	if (idev == NULL)
> 
> 
