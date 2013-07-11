From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH RFC] ipv6: fix route selection if kernel is not compiled
 with CONFIG_IPV6_ROUTER_PREF
Date: Thu, 11 Jul 2013 10:07:52 +0200
Message-ID: <51DE67D8.9060904@6wind.com>
References: <20130707173031.GC9625@order.stressinduktion.org> <20130709215701.GD9763@order.stressinduktion.org> <51DD1352.8000705@6wind.com> <51DD2959.9060206@6wind.com> <20130710105316.GA5735@order.stressinduktion.org> <51DD521F.1000905@6wind.com> <20130710132122.GD15411@order.stressinduktion.org> <51DD6B72.1050700@6wind.com> <20130710152001.GH15411@order.stressinduktion.org> <20130710155904.GI15411@order.stressinduktion.org> <20130710163537.GJ15411@order.stressinduktion.org>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	petrus.lt@gmail.com, davem@davemloft.net
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f180.google.com ([74.125.82.180]:43899 "EHLO
	mail-we0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755611Ab3GKIHz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jul 2013 04:07:55 -0400
Received: by mail-we0-f180.google.com with SMTP id w56so6664570wes.39
        for <netdev@vger.kernel.org>; Thu, 11 Jul 2013 01:07:54 -0700 (PDT)
In-Reply-To: <20130710163537.GJ15411@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 10/07/2013 18:35, Hannes Frederic Sowa a =C3=A9crit :
> On Wed, Jul 10, 2013 at 05:59:04PM +0200, Hannes Frederic Sowa wrote:
>> On Wed, Jul 10, 2013 at 05:20:01PM +0200, Hannes Frederic Sowa wrote=
:
>>> On Wed, Jul 10, 2013 at 04:10:58PM +0200, Nicolas Dichtel wrote:
>>>> Le 10/07/2013 15:21, Hannes Frederic Sowa a =C3=A9crit :
>>>>> On Wed, Jul 10, 2013 at 02:22:55PM +0200, Nicolas Dichtel wrote:
>>>>>> Le 10/07/2013 12:53, Hannes Frederic Sowa a =C3=A9crit :
>>>>> The route with rt6i_gateway does actually expire because I got it=
 from
>>>>> autoconf and ip -6 r l confirms this, too. It seems this is only =
the cached
>>>>> route (I will confirm shortly). Is this still ok?
>>>> I wonder why expires is 0. Even if this route is cached, the flag
>>>> RTF_EXPIRES should be set. Am I wrong?
>>>
>>> It seems it is possible cached route gets its expiration updated. A=
s
>>> such it is not counted in the iteration but it is found as a siblin=
g and its
>>> nsiblings count is updated again.
>>
>> ip6_link_failure is the problem. We need to remove the route directl=
y instead
>> of calling rt6_update_expires:
>>
>> static void ip6_link_failure(struct sk_buff *skb)
>> {
>>          struct rt6_info *rt;
>>
>>          icmpv6_send(skb, ICMPV6_DEST_UNREACH, ICMPV6_ADDR_UNREACH, =
0);
>>
>>          rt =3D (struct rt6_info *) skb_dst(skb);
>>          if (rt) {
>>                  if (rt->rt6i_flags & RTF_CACHE)
>>                          rt6_update_expires(rt, 0);
>>                  else if (rt->rt6i_node && (rt->rt6i_flags & RTF_DEF=
AULT))
>>                          rt->rt6i_node->fn_sernum =3D -1;
>>          }
>> }
>
> With this patch I do not get the panic any more and the routing table
> stabilizes and discarded all NUD nonavailable routes. I'll need to re=
view
> it myself, first. Thanks for your help!

Good catch!
Thank you.
