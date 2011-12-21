From: Michael Wang <wangyun@linux.vnet.ibm.com>
Subject: Re: [PATCH] Avoid extra calculation in ip_route_input_common
Date: Wed, 21 Dec 2011 13:39:01 +0800
Message-ID: <4EF170F5.5040900@linux.vnet.ibm.com>
References: <4EF16AA3.2070303@linux.vnet.ibm.com> <1324445033.20505.2.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp07.in.ibm.com ([122.248.162.7]:33363 "EHLO
	e28smtp07.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750924Ab1LUFji (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2011 00:39:38 -0500
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <wangyun@linux.vnet.ibm.com>;
	Wed, 21 Dec 2011 11:09:35 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pBL5d5al4300862
	for <netdev@vger.kernel.org>; Wed, 21 Dec 2011 11:09:06 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pBL5d4rp004133
	for <netdev@vger.kernel.org>; Wed, 21 Dec 2011 11:09:05 +0530
In-Reply-To: <1324445033.20505.2.camel@joe2Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/21/2011 01:23 PM, Joe Perches wrote:

> On Wed, 2011-12-21 at 13:12 +0800, Michael Wang wrote:
>> From: Michael Wang <wangyun@linux.vnet.ibm.com>
>>
>> If previous condition doesn't meet, the later check will be cancelled.
>> So we don't need to do all the calculation.
> 
> Not sure about that.
> 

Hi, Joe

Thanks for your reply :)

>> Signed-off-by: Michael Wang <wangyun@linux.vnet.ibm.com>
>> ---
>>  net/ipv4/route.c |    8 ++++----
>>  1 files changed, 4 insertions(+), 4 deletions(-)
>>
>> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
>> index f30112f..2872bfb 100644
>> --- a/net/ipv4/route.c
>> +++ b/net/ipv4/route.c
>> @@ -2362,10 +2362,10 @@ int ip_route_input_common(struct sk_buff *skb, __be32 daddr, __be32 saddr,
>>  
>>  	for (rth = rcu_dereference(rt_hash_table[hash].chain); rth;
>>  	     rth = rcu_dereference(rth->dst.rt_next)) {
>> -		if ((((__force u32)rth->rt_key_dst ^ (__force u32)daddr) |
>> -		     ((__force u32)rth->rt_key_src ^ (__force u32)saddr) |
>> -		     (rth->rt_route_iif ^ iif) |
>> -		     (rth->rt_key_tos ^ tos)) == 0 &&
>> +		if (((__force u32)rth->rt_key_dst ^ (__force u32)daddr) == 0 &&
>> +		    ((__force u32)rth->rt_key_src ^ (__force u32)saddr) == 0 &&
>> +		    rth->rt_route_iif == iif &&
>> +		    rth->rt_key_tos == tos &&
>>  		    rth->rt_mark == skb->mark &&
>>  		    net_eq(dev_net(rth->dst.dev), net) &&
>>  		    !rt_is_expired(rth)) {
> 
> See:
> 
> commit c0b8c32b1c96afc9b32b717927330025cc1c501e
> Author: Stephen Hemminger <shemminger@vyatta.com>
> Date:   Thu Apr 10 04:00:28 2008 -0700
> 
>     IPV4: use xor rather than multiple ands for route compare
>     
>     The comparison in ip_route_input is a hot path, by recoding the C
>     "and" as bit operations, fewer conditional branches get generated
>     so the code should be faster. Maybe someday Gcc will be smart
>     enough to do this?


This is what confused me, why "fewer conditional branches get generated"
will make code faster?
In this example, I think the best condition when daddr is different, we
only need to go to one branch do compare then quit, won't this be faster?

Thanks,
Michael Wang

>     
>     Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>     Acked-by: Eric Dumazet <dada1@cosmosbay.com>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> 
