From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH] ipv6: don't call addrconf_dst_alloc again when enable
 lo
Date: Wed, 08 Jan 2014 16:42:46 +0800
Message-ID: <52CD0F86.30605@cn.fujitsu.com>
References: <1371352470-3226-1-git-send-email-gaofeng@cn.fujitsu.com> <20130619.230532.1329281330568271336.davem@davemloft.net> <20131231035718.GB27636@order.stressinduktion.org> <52C4FDBE.5030607@huawei.com> <20140102065429.GB22494@order.stressinduktion.org> <52C51C1E.9040603@huawei.com> <20140102082325.GC22494@order.stressinduktion.org> <52C5325B.8020900@huawei.com> <20140103065349.GK22494@order.stressinduktion.org> <52CD0331.8040204@cn.fujitsu.com> <20140108080528.GD9007@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: chenweilong <chenweilong@huawei.com>,
	David Miller <davem@davemloft.net>, kumaran.4353@gmail.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:49514 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751456AbaAHIlw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jan 2014 03:41:52 -0500
In-Reply-To: <20140108080528.GD9007@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/08/2014 04:05 PM, Hannes Frederic Sowa wrote:
> On Wed, Jan 08, 2014 at 03:50:09PM +0800, Gao feng wrote:
>> On 01/03/2014 02:53 PM, Hannes Frederic Sowa wrote:
>>> On Thu, Jan 02, 2014 at 05:33:15PM +0800, chenweilong wrote:
>>>> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
>>>> index 62d1799..d2f8c0a 100644
>>>> --- a/net/ipv6/addrconf.c
>>>> +++ b/net/ipv6/addrconf.c
>>>> @@ -2422,8 +2422,9 @@ static void init_loopback(struct net_device *dev)
>>>>  			if (sp_ifa->flags & (IFA_F_DADFAILED | IFA_F_TENTATIVE))
>>>>  				continue;
>>>>
>>>> -			if (sp_ifa->rt)
>>>> -				continue;
>>>> +			if (sp_ifa->rt && sp_ifa->rt->dst.dev == dev) {
>>>> +				ip6_del_rt(sp_ifa->rt);
>>>> +			}
>>>>
>>>>  			sp_rt = addrconf_dst_alloc(idev, &sp_ifa->addr, 0);
>>>>
>>>
>>> Maybe this change would not be that bad after all, as those ifa attached dsts
>>> are already dead and queued up for gc and should not get inserted back.
>>
>> I like this idea, maybe the below patch is better. we only need to delete this
>> route when it has been added to garbage list.
>>
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
> It looks like it can work but I don't know if we should just fix this the
> clean way (see below).
> 
>>> I'll try to just disable routes without removing them at all when we set an
>>> interface to down at the weekend.
>>>
>>
>> How do you decide which route should be disabled?  use rt6_flags? I don't know
>> if your way will cause miscarriage.
> 
> What I did so far is that I added a new function next to rt6_ifdown that
> only gets called if interface gets shutdown but not unregistered (from
> addrconf_ifdown).
> 

rt6_ifdown has alreay put this device related routes to the garbage list.

> fib6_clean_all then iterates over the whole routing table with a new predicate
> function which checks in the same way like fib6_ifdown, if it is a matching route
> (the interfaces match up) and if so, toggles a new "DEAD" flag in rt6i_flags.
> 
> When bringing up the interface I distinguish between up and register and just
> clear this death flag from the routes on bringing it up.
> 
> fib lookup code then does not honour those routes.
> 
> I had no time to test this thoroughly at the weekend and still have some code
> paths were I am unsure. Do you see any problems with this so far? We could
> then delete the special cases on loopback interface init.

So you add a special case in the general network interface down logic. I think this
is more complex...

Thanks!
