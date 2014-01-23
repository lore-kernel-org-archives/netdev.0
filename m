From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [RFC PATCH net] IPv6: Fix broken IPv6 routing table after loopback
 down-up
Date: Thu, 23 Jan 2014 14:23:27 +0800
Message-ID: <52E0B55F.4070501@cn.fujitsu.com>
References: <1390404908-3914-1-git-send-email-sd@queasysnail.net> <20140122213446.GD7269@order.stressinduktion.org> <52E068C5.2050405@cn.fujitsu.com> <20140123010123.GF7269@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: Sabrina Dubroca <sd@queasysnail.net>, netdev@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:15767 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750969AbaAWGWn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Jan 2014 01:22:43 -0500
In-Reply-To: <20140123010123.GF7269@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/23/2014 09:01 AM, Hannes Frederic Sowa wrote:
> On Thu, Jan 23, 2014 at 08:56:37AM +0800, Gao feng wrote:
>> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
>> index 1a341f7..4dca886 100644
>> --- a/net/ipv6/addrconf.c
>> +++ b/net/ipv6/addrconf.c
>> @@ -2610,8 +2610,16 @@ static void init_loopback(struct net_device *dev)
>>                         if (sp_ifa->flags & (IFA_F_DADFAILED | IFA_F_TENTATIVE))
>>                                 continue;
>>
>> -                       if (sp_ifa->rt)
>> -                               continue;
>> +                       if (sp_ifa->rt) {
>> +                               /* This dst has been added to garbage list when
>> +                                * lo device down, delete this obsolete dst and
>> +                                * reallocate new router for ifa. */
>> +                               if (sp_ifa->rt->dst.obsolete > 0) {
>> +                                       ip6_del_rt(sp_ifa->rt);
>> +                                       sp_ifa->rt = NULL;
>> +                               } else
>> +                                       continue;
>> +                       }
>>
>>                         sp_rt = addrconf_dst_alloc(idev, &sp_ifa->addr, false);
> 
> I agree, this seems a lot simpler. 

I will post a official version.

> In the end I would like to replace this
> conditional loopback up/down thing with something like below. I haven't done
> the correct hookups into the relevant places, but I hope you get the idea:
> 

The code explains everything. the routers will be invalid when device is down
and be enabled when device is up.

look forward to your patch.

> diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
> index 017badb..1648a59a 100644
> --- a/include/net/ip6_route.h
> +++ b/include/net/ip6_route.h

[...]
>  
> -static int fib6_ifdown(struct rt6_info *rt, void *arg)
> +static int __fib6_match_or_update_if(struct rt6_info *rt, void *arg)
>  {
>  	const struct arg_dev_net *adn = arg;
>  	const struct net_device *dev = adn->dev;
>  
>  	if ((rt->dst.dev == dev || !dev) &&
> -	    rt != adn->net->ipv6.ip6_null_entry)
> -		return -1;
> +	    rt != adn->net->ipv6.ip6_null_entry) {
> +		switch (adn->action) {
> +		case ARG_DEV_NET_REMOVE:
> +			/* remove rt */
> +			return -1;
> +		case ARG_DEV_NET_DISABLE:
> +			WARN_ON(rt->rt6i_flags & RTF_DEAD);
> +			rt->rt6i_flags |= RTF_DEAD;
> +			return 0;
> +		case ARG_DEV_NET_ENABLE:
> +			WARN_ON(!(rt->rt6i_flags & RTF_DEAD));

I think this may happen, think a new router is cloned from this rt but hasn't been inserted
into the router tree on other CPU at the same time.
