From: Varun Chandramohan <varunc@linux.vnet.ibm.com>
Subject: Re: [PATCH 4/4] Initialize and fill IPv6 route age
Date: Tue, 24 Jul 2007 14:49:17 +0530
Message-ID: <46A5C415.7060302@linux.vnet.ibm.com>
References: <20070723101318.c773f600.varunc@linux.vnet.ibm.com> <20070723123429.15715972@oldman.hamilton.local> <46A57E29.9040404@linux.vnet.ibm.com> <20070724082646.4cbd1ede@oldman>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sri@us.ibm.com, dlstevens@us.ibm.com,
	varuncha@in.ibm.com
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:43170 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763345AbXGXJTH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jul 2007 05:19:07 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l6O9J7g5002408
	for <netdev@vger.kernel.org>; Tue, 24 Jul 2007 05:19:07 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l6O9J7XH450244
	for <netdev@vger.kernel.org>; Tue, 24 Jul 2007 05:19:07 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l6O9J6oM016581
	for <netdev@vger.kernel.org>; Tue, 24 Jul 2007 05:19:07 -0400
In-Reply-To: <20070724082646.4cbd1ede@oldman>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> On Tue, 24 Jul 2007 09:50:57 +0530
> Varun Chandramohan <varunc@linux.vnet.ibm.com> wrote:
>
>   
>> Stephen Hemminger wrote:
>>     
>>> On Mon, 23 Jul 2007 10:13:18 +0530
>>> Varun Chandramohan <varunc@linux.vnet.ibm.com> wrote:
>>>
>>>   
>>>       
>>>> The age field of the ipv6 route structures are initilized with the current timeval at the time of route       creation. When the route dump is called the route age value stored in the structure is subtracted from the     present timeval and the difference is passed on as the route age.
>>>>
>>>> Signed-off-by: Varun Chandramohan <varunc@linux.vnet.ibm.com>
>>>> ---
>>>>  include/net/ip6_fib.h   |    1 +
>>>>  include/net/ip6_route.h |    3 +++
>>>>  net/ipv6/addrconf.c     |    5 +++++
>>>>  net/ipv6/route.c        |   23 +++++++++++++++++++----
>>>>  4 files changed, 28 insertions(+), 4 deletions(-)
>>>>
>>>> diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
>>>> index c48ea87..e30a1cf 100644
>>>> --- a/include/net/ip6_fib.h
>>>> +++ b/include/net/ip6_fib.h
>>>> @@ -98,6 +98,7 @@ struct rt6_info
>>>>  	
>>>>  	u32				rt6i_flags;
>>>>  	u32				rt6i_metric;
>>>> +	time_t				rt6i_age;
>>>>  	atomic_t			rt6i_ref;
>>>>  	struct fib6_table		*rt6i_table;
>>>>  
>>>> diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
>>>> index 5456fdd..fc9716c 100644
>>>> --- a/include/net/ip6_route.h
>>>> +++ b/include/net/ip6_route.h
>>>> @@ -36,6 +36,9 @@ struct route_info {
>>>>  #define RT6_LOOKUP_F_REACHABLE	0x2
>>>>  #define RT6_LOOKUP_F_HAS_SADDR	0x4
>>>>  
>>>> +#define RT6_SET_ROUTE_INFO 0x0
>>>> +#define RT6_GET_ROUTE_INFO 0x1
>>>> +
>>>>  extern struct rt6_info	ip6_null_entry;
>>>>  
>>>>  #ifdef CONFIG_IPV6_MULTIPLE_TABLES
>>>> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
>>>> index 5a5f8bd..715c766 100644
>>>> --- a/net/ipv6/addrconf.c
>>>> +++ b/net/ipv6/addrconf.c
>>>> @@ -4187,6 +4187,7 @@ EXPORT_SYMBOL(unregister_inet6addr_notif
>>>>  
>>>>  int __init addrconf_init(void)
>>>>  {
>>>> +	struct timeval tv;
>>>>  	int err = 0;
>>>>  
>>>>  	/* The addrconf netdev notifier requires that loopback_dev
>>>> @@ -4214,10 +4215,14 @@ int __init addrconf_init(void)
>>>>  	if (err)
>>>>  		return err;
>>>>  
>>>> +	do_gettimeofday(&tv);
>>>>     
>>>>         
>>> Better to use ktime_t or timespec in new code.
>>>   
>>>       
>> You are saying not to use timeval as its going to be removed sometime in
>> future? If not, may i know why should we use timespec or ktime?
>> I need only seconds granularity so i was wondering if that matters.
>>
>>     
>
> Timeval isn't going away, but ktime is easier for basic maths.
> If all you need is seconds resolution,  just use jiffies. Gettimeofday
>   
Thanks stephen for the review. As far as using jiffies (which is my
original implementation) i got a  comment saying that on 32bit platform
jiffies wrap every 49 days.  That's the reason for the do_gettimeofday()
implementation. However i understand that such calls require expensive
h/w accesses. Considering the fact that jiffies wrap around rather
quickly, can you suggest any other way of doing it?
> (and ktime_get) both require expensive hardware accesses on
> some platforms.
>
> For the specific case IPV6 route ageing, this isn't a big deal it is just
> that people tend to copy code. 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>   

