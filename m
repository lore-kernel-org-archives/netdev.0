From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] Can not send icmp netunreach packet
Date: Tue, 26 Feb 2008 10:55:38 +0000
Message-ID: <20080226105538.GA13016@ff.dom.local>
References: <20080226073538.GA4101@ff.dom.local> <47C3E2EC.1020402@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Li Yewang <lyw@cn.fujitsu.com>, davem@davemloft.net,
	swhiteho@redhat.com, netdev@vger.kernel.org
To: Wei Yongjun <yjwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:10541 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751529AbYBZKyh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Feb 2008 05:54:37 -0500
Received: by ug-out-1314.google.com with SMTP id z38so1203481ugc.16
        for <netdev@vger.kernel.org>; Tue, 26 Feb 2008 02:54:35 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <47C3E2EC.1020402@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 26, 2008 at 06:59:08PM +0900, Wei Yongjun wrote:
> Jarek Poplawski wrote:
>
> Maybe ip_error() does not handle the ESRCH error. In this place ESRCH eq  
> to ENETUNREACH?

It doesn't handle ESRCH for sure... Current solution seems to expect
it is changed earlier to ENETUNREACH. It looks reasonable because
otherwise all other places checking for this should be updated too.

But, IMHO, it could be tested if such a change here helps in current
problem, and then maybe found where it was skipped? On the other hand,
probably checking with grep for all such ENETUNREACH cases, and adding
ESRCH where needed could be much simpler and safer...

Jarek P.

>
> static int ip_error(struct sk_buff *skb)
> {
> 	struct rtable *rt = (struct rtable*)skb->dst;
> 	unsigned long now;
> 	int code;
>
> 	switch (rt->u.dst.error) {
> 		case EINVAL:
> 		default:
> 			goto out;
> 		case EHOSTUNREACH:
> 			code = ICMP_HOST_UNREACH;
> 			break;
> 		case ENETUNREACH:
> 			code = ICMP_NET_UNREACH;
> 			break;
> 		case EACCES:
> 			code = ICMP_PKT_FILTERED;
> 			break;
> 	}
> ...............snip....................
> }
>
>
>
>> On 26-02-2008 07:34, Li Yewang wrote:
>>   
>>> Hi All
>>>
>>>    There is a bug about icmp netunreach.
>>>    If the kernel does not find a route for a packet,    it must send 
>>> a icmp netunreach packet to the source host,    and  discard  the 
>>> packet. But the  kernel  does not send    a icmp netunreach packet 
>>> because of the  fib_lookup
>>>    return value  of -ESRCH when a route  is not found.     
>>
>> ...or because some function doesn't handle -ESRCH return from
>> fib_lookup? It seems changing this to -ESRCH was needed in some cases.
>> And you don't explain enough why it can't be handled later (like in
>> ipv4/route.c: ip_route_input_slow)?
>>   
>
>
>> Regards,
>> Jarek P.
>>
>>   
>>> Signed-off-by: Li Yewang <lyw@cn.fujitsu.com>
>>>
>>> diff -Nurp net/core_back/fib_rules.c net/core/fib_rules.c
>>> --- net/core_back/fib_rules.c   2008-02-25 13:15:37.000000000 +0800
>>> +++ net/core/fib_rules.c        2008-02-25 13:16:01.000000000 +0800
>>> @@ -188,7 +188,7 @@ jumped:
>>>  		}
>>>  	}
>>>  -	err = -ESRCH;
>>> +	err = -ENETUNREACH;
>>>  out:
>>>  	rcu_read_unlock();
>>>
>>>     
>
