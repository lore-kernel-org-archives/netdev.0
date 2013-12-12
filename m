From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH] net: Cache route in IP tunnels
Date: Thu, 12 Dec 2013 12:19:41 -0800
Message-ID: <CA+mtBx9GNG3XuyczBAJT4o2FnRBbHTV5U6PYnAJA1gf84ExeNQ@mail.gmail.com>
References: <alpine.DEB.2.02.1312112207400.27914@tomh.mtv.corp.google.com>
	<1386833838.19078.45.camel@edumazet-glaptop2.roam.corp.google.com>
	<20131212.135433.87781160683841713.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f180.google.com ([209.85.223.180]:49709 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751708Ab3LLUTl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 15:19:41 -0500
Received: by mail-ie0-f180.google.com with SMTP id tp5so1456154ieb.39
        for <netdev@vger.kernel.org>; Thu, 12 Dec 2013 12:19:41 -0800 (PST)
In-Reply-To: <20131212.135433.87781160683841713.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 12, 2013 at 10:54 AM, David Miller <davem@davemloft.net> wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 11 Dec 2013 23:37:18 -0800
>
>> On Wed, 2013-12-11 at 22:17 -0800, Tom Herbert wrote:
>>> Avoid doing a route lookup on every packet being tunneled.
>>>
>>> In ip_tunnel.c cache the route returned from ip_route_output if
>>> the tunnel is "connected", that is all the routing parameters are
>>> taken from tunnel parms for a packet. Specifically, not NBMA tunnel
>>> and tos is from tunnel parms (not inner packet).
>>>
>>> Signed-off-by: Tom Herbert <therbert@google.com>
>>> ---
>>
>> Replacing per cpu dst (nh_pcpu_rth_output) with a single shared dst is
>> not going to be better on SMP.
>>
>> Do you have any performance data using multiqueue NIC, with say 32 cpus
>> and 32 TX queues ?
>>
>> I suspect a high false sharing on dst refcount.
>
> First off I'm glad someone looked into this, I've been meaning to play
> with this for a while.
>
> Secondly, Eric's concern is valid but we should keep in mind that IPV6
> tunnels do this kind of caching already so if it's undesirable we
> should perhaps undo the caching there too.
>
We could also use a per CPU dst cache in the tunnel. Might be
reasonable if people aren't configuring thousands of tunnels.

> But honestly I suspect that doing a lookup every packet is more
> expensive than false sharing on a cache entry, but I'm happy to be
> proven wrong :)

My performance runs were inconclusive, but I assumed that caching in
the tunnel would scale better with larger numbers of routes.

btw, I needed to disable gro on the tun interface. With it enabled,
performance in TCP_RR is abysmal. Looking into that.
