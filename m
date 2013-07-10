From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH RFC] ipv6: fix route selection if kernel is not compiled
 with CONFIG_IPV6_ROUTER_PREF
Date: Wed, 10 Jul 2013 14:08:42 +0200
Message-ID: <51DD4ECA.1080506@6wind.com>
References: <20130707173031.GC9625@order.stressinduktion.org> <20130709215701.GD9763@order.stressinduktion.org> <51DD1352.8000705@6wind.com> <20130710111504.GA15411@order.stressinduktion.org>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	petrus.lt@gmail.com, davem@davemloft.net
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f41.google.com ([74.125.82.41]:44730 "EHLO
	mail-wg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753545Ab3GJMIq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jul 2013 08:08:46 -0400
Received: by mail-wg0-f41.google.com with SMTP id y10so10869207wgg.2
        for <netdev@vger.kernel.org>; Wed, 10 Jul 2013 05:08:44 -0700 (PDT)
In-Reply-To: <20130710111504.GA15411@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 10/07/2013 13:15, Hannes Frederic Sowa a =C3=A9crit :
> On Wed, Jul 10, 2013 at 09:54:58AM +0200, Nicolas Dichtel wrote:
>> Le 09/07/2013 23:57, Hannes Frederic Sowa a =C3=A9crit :
>>> Are we sure we decrement all sibling's rt6i_nsiblings? Shouldn't we
>>> start iterating from fn->leaf? But this does not seem to cause it,
>>> because my trace does not report any calls to fib6_del_route.
>> Note sure to follow you, but all siblings are listed in rt6i_sibling=
s, so
>> it must be enough.
>
> My hunch was to iterate over fn->leaf->rt_next and compare the metric=
s like we
> do when adding a new route. Then take that rt6_info->rt6i_siblings li=
st_head
> to iterate over the remaining siblings. But I did not review that par=
t
> carefully, need to check later.
>
>>> You could try reproduce it by having an interface autoconfigured wi=
th
>>> a default router with NUD_VALID neighbour. I then added an unused v=
lan
>>> interface (vid 100 in my case) and added the following ip addresses=
:
>>>
>>> ip -6 a a 2001:ffff::1/64 dev eth0.100
>>> ip -6 r a 2000::/3 nexthop via 2001:ffff::30 nexthop via 2001:ffff:=
:31
>>> nexthop via 2001:ffff::32 nexthop via 2001:ffff::33
>>>
>>> (all nexthops should not be reachable)
>>>
>>> After starting a ping6 2000::1 the box should panic soon, after the
>>> first nexthop entry times out.
>>>
>>> Perhaps you could give me a hint?
>> I will run some tests with your patch. Will see.
>>
>> I assume you didn't reproduce this without your patch.
>
> Current kernel does not correctly select more specific routes, so the=
se routes
> are not even tried and the logic should not be excercised.
>
> Ah, sorry, you should also compile your kernel without
> CONFIG_IPV6_ROUTER_PREF, too, if you try to reproduce it.
I've done this.

My conf (eth1 autoconfigured, I use net-next + your patch):
vconfig add eth1 100
ifconfig eth1.100 up
ip -6 a a 2001:ffff::1/64 dev eth1.100
ip -6 r a 2000::/3 nexthop via 2001:ffff::30 nexthop via 2001:ffff::31 =
nexthop=20
via 2001:ffff::32 nexthop via 2001:ffff::33
ping6 2000::1
