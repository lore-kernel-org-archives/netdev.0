From: Alex Gartrell <agartrell@fb.com>
Subject: Re: [RFC PATCH net-next] ip6: Do not expire uncached routes for mtu
 invalidation
Date: Mon, 8 Sep 2014 10:12:32 -0700
Message-ID: <540DE380.1000302@fb.com>
References: <1410165283-29337-1-git-send-email-agartrell@fb.com> <1410172253.11872.87.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <edumazet@google.com>,
	<netdev@vger.kernel.org>, <kernel-team@fb.com>, <ps@fb.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:64082 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754224AbaIHRMa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2014 13:12:30 -0400
In-Reply-To: <1410172253.11872.87.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thank you for taking a look, Eric.

I'll admit that I have a distinct lack of confidence that I've got the 
right solution to the problem here, but I've made it about as far as I 
can without getting your collective comments, so it's much appreciated.

On 9/8/14 3:30 AM, Eric Dumazet wrote:
> On Mon, 2014-09-08 at 01:34 -0700, Alex Gartrell wrote:
>> diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
>> index 9bcb220..2f0d4d0 100644
>> --- a/include/net/ip6_fib.h
>> +++ b/include/net/ip6_fib.h
>> @@ -184,7 +184,8 @@ static inline void rt6_update_expires(struct rt6_info *rt0, int timeout)
>>   		rt0->dst.expires = rt->dst.expires;
>>
>>   	dst_set_expires(&rt0->dst, timeout);
>> -	rt0->rt6i_flags |= RTF_EXPIRES;
>> +	if (rt0->rt6i_flags & (RTF_CACHE | RTF_EXPIRES))
>> +		rt0->rt6i_flags |= RTF_EXPIRES;
>
> This looks wrong. What could be the point of settinf RTF_EXPIRES if its
> already set ?
>

This is a good point.  It was clearer to me at the time to include it 
(more similar to the old implementation which set the bit 
unconditionally), but I don't really care.

>>   }
>>
>>   static inline void rt6_set_from(struct rt6_info *rt, struct rt6_info *from)
>> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
>> index f74b041..a509a06 100644
>> --- a/net/ipv6/route.c
>> +++ b/net/ipv6/route.c
>> @@ -947,8 +947,19 @@ restart:
>>   		nrt = rt6_alloc_cow(rt, &fl6->daddr, &fl6->saddr);
>>   	else if (!(rt->dst.flags & DST_HOST))
>>   		nrt = rt6_alloc_clone(rt, &fl6->daddr);
>> -	else
>> +	else {
>> +		if (!(rt->rt6i_flags & RTF_EXPIRES) && rt->dst.expires &&
>> +		    time_after(jiffies, rt->dst.expires)) {
>> +			/* Uncached routes may have expires set if we
>> +			 * intend to expire the MTU but not the dest
>> +			 * itself.  In that case, we should reset the mtu
>> +			 * before handing it back */
>> +			dst_metric_set(&rt->dst, RTAX_MTU, 0);
>> +			rt6_clean_expires(rt);
>> +			rt->rt6i_flags &= ~RTF_MODIFIED;
>
> Many cpus can perform this at the same time on same route, this looks
> racy.

Initially I was just going to agree with you here, but taking another 
look at ip_vs_xmit at least, there doesn't appear to be any special 
locking before invoking ->update_pmtu, which is playing with rt6i_flags 
and dst.expires as well.  Is that racy as well or is there something 
else I'm missing here?

There are other ways to skin this particular cat though, and I've got no 
specific attachment to any of them.  The most logical thing to do IMO is 
clone the route when it may be necessary to do so, but given the fact 
that that was very deliberately undone in 7343ff3 "ipv6: Don't create 
clones of host routes," I'm not sure that it's the right thing to do or 
that it won't require major surgery.

Thanks again,

-- 
Alex Gartrell <agartrell@fb.com>
