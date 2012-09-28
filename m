From: Chris Clayton <chris2553@googlemail.com>
Subject: Re: Possible networking regression in 3.6.0
Date: Fri, 28 Sep 2012 10:14:56 +0100
Message-ID: <50656A90.5030503@googlemail.com>
References: <50649567.2010704@googlemail.com> <1348779826.5093.1750.camel@edumazet-glaptop> <1348780624.5093.1767.camel@edumazet-glaptop> <20120928.025351.156118608293844465.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, gpiez@web.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:65144 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754680Ab2I1JPA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2012 05:15:00 -0400
Received: by bkcjk13 with SMTP id jk13so3052416bkc.19
        for <netdev@vger.kernel.org>; Fri, 28 Sep 2012 02:14:59 -0700 (PDT)
In-Reply-To: <20120928.025351.156118608293844465.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 09/28/12 07:53, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 27 Sep 2012 23:17:04 +0200
>
>> Yes it seems the problem. On the host I tried :
>>
>> # ip ro get 8.8.8.8 from 192.168.200.1 iif tap1
>> 8.8.8.8 from 192.168.200.1 via 172.30.42.1 dev eth0
>>      cache  iif *
>>
>> So if the guest tries to send a frame to 8.8.8.8 we are going to forward
>> the packet to eth0
>>
>> But if the guest tries to send to 255.255.255.255, we try to deliver the
>> packet to the host itself, instead of broadcasting to eth0
>>
>> # ip ro get 255.255.255.255 from 192.168.200.1 iif tap1
>> broadcast 255.255.255.255 from 192.168.200.1 dev lo
>>      cache <local,brd>  iif *
>>
>> David, maybe you'll have an idea ?
>
> Perhaps this was introduced by:

Thanks, David.

Unfortunately, reversing that patch does not fix the problem. The pings 
from the KVM client to the router still time out.

I have bisected this (see 
http://marc.info/?l=linux-netdev&m=134797809611847&w=2) and that rendered:

$ git bisect bad
d2d68ba9fe8b38eb03124b3176a013bb8aa2b5e5 is the first bad commit
commit d2d68ba9fe8b38eb03124b3176a013bb8aa2b5e5
Author: David S. Miller <davem@davemloft.net>
Date:   Tue Jul 17 12:58:50 2012 -0700

     ipv4: Cache input routes in fib_info nexthops.

     Caching input routes is slightly simpler than output routes, since we
     don't need to be concerned with nexthop exceptions.  (locally
     destined, and routed packets, never trigger PMTU events or redirects
     that will be processed by us).

     However, we have to elide caching for the DIRECTSRC and non-zero itag
     cases.

     Signed-off-by: David S. Miller <davem@davemloft.net>

:040000 040000 6bbc75c1cbe62bf84ea412d3b98adf2b614779cd 
3ad7256b4a71e63ca4530977c0550121ea803d35 M      include
:040000 040000 18c2a950a53c4eec9bfa12185d1e382dfed74af8 
a2ab6157d6cd54930da395758c6ded3a225d1f04 M      net

Unfortunately, the related patches don't reverse cleanly, but a kernel 
built from a git checkout of the parent commit ( 
f2bb4bedf35d5167a073dcdddf16543f351ef3ae) works fine.

>
> commit 7bd86cc282a458b66c41e3f6676de6656c99b8db
> Author: Yan, Zheng <zheng.z.yan@intel.com>
> Date:   Sun Aug 12 20:09:59 2012 +0000
>
>      ipv4: Cache local output routes
>
>      Commit caacf05e5ad1abf causes big drop of UDP loop back performance.
>      The cause of the regression is that we do not cache the local output
>      routes. Each time we send a datagram from unconnected UDP socket,
>      the kernel allocates a dst_entry and adds it to the rt_uncached_list.
>      It creates lock contention on the rt_uncached_lock.
>
>      Reported-by: Alex Shi <alex.shi@intel.com>
>      Signed-off-by: Yan, Zheng <zheng.z.yan@intel.com>
>      Signed-off-by: David S. Miller <davem@davemloft.net>
>
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index e4ba974..fd9ecb5 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -2028,7 +2028,6 @@ struct rtable *__ip_route_output_key(struct net *net, struct flowi4 *fl4)
>   		}
>   		dev_out = net->loopback_dev;
>   		fl4->flowi4_oif = dev_out->ifindex;
> -		res.fi = NULL;
>   		flags |= RTCF_LOCAL;
>   		goto make_route;
>   	}
>
