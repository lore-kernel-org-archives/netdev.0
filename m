From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: Re: [PATCH] Can not send icmp netunreach packet
Date: Tue, 26 Feb 2008 18:59:08 +0900
Message-ID: <47C3E2EC.1020402@cn.fujitsu.com>
References: <20080226073538.GA4101@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Li Yewang <lyw@cn.fujitsu.com>, davem@davemloft.net,
	swhiteho@redhat.com, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail5.fujitsu.co.jp ([192.51.44.35]:39853 "EHLO
	fgwmail5.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752195AbYBZKAJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Feb 2008 05:00:09 -0500
In-Reply-To: <20080226073538.GA4101@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:

Maybe ip_error() does not handle the ESRCH error. In this place ESRCH eq 
to ENETUNREACH?

static int ip_error(struct sk_buff *skb)
{
	struct rtable *rt = (struct rtable*)skb->dst;
	unsigned long now;
	int code;

	switch (rt->u.dst.error) {
		case EINVAL:
		default:
			goto out;
		case EHOSTUNREACH:
			code = ICMP_HOST_UNREACH;
			break;
		case ENETUNREACH:
			code = ICMP_NET_UNREACH;
			break;
		case EACCES:
			code = ICMP_PKT_FILTERED;
			break;
	}
...............snip....................
}



> On 26-02-2008 07:34, Li Yewang wrote:
>   
>> Hi All
>>
>>    There is a bug about icmp netunreach.
>>    If the kernel does not find a route for a packet, 
>>    it must send a icmp netunreach packet to the source host, 
>>    and  discard  the packet. But the  kernel  does not send 
>>    a icmp netunreach packet because of the  fib_lookup
>>    return value  of -ESRCH when a route  is not found. 
>>     
>
> ...or because some function doesn't handle -ESRCH return from
> fib_lookup? It seems changing this to -ESRCH was needed in some cases.
> And you don't explain enough why it can't be handled later (like in
> ipv4/route.c: ip_route_input_slow)?
>   


> Regards,
> Jarek P.
>
>   
>> Signed-off-by: Li Yewang <lyw@cn.fujitsu.com>
>>
>> diff -Nurp net/core_back/fib_rules.c net/core/fib_rules.c
>> --- net/core_back/fib_rules.c   2008-02-25 13:15:37.000000000 +0800
>> +++ net/core/fib_rules.c        2008-02-25 13:16:01.000000000 +0800
>> @@ -188,7 +188,7 @@ jumped:
>>  		}
>>  	}
>>  
>> -	err = -ESRCH;
>> +	err = -ENETUNREACH;
>>  out:
>>  	rcu_read_unlock();
>>
>>     

