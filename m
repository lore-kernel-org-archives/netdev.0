From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: ECMP ipv6 vs ipv4
Date: Wed, 17 Apr 2013 16:14:18 +0200
Message-ID: <516EAE3A.8000201@6wind.com>
References: <1366012728.4975.13.camel@localhost>   <516C2212.4030502@6wind.com> <1366044816.4975.27.camel@localhost>  <516E6559.4070903@6wind.com> <1366204578.31353.88.camel@localhost>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Wilco Baan Hofman <wilco@baanhofman.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f52.google.com ([74.125.83.52]:36437 "EHLO
	mail-ee0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966321Ab3DQOOT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Apr 2013 10:14:19 -0400
Received: by mail-ee0-f52.google.com with SMTP id b57so627895eek.39
        for <netdev@vger.kernel.org>; Wed, 17 Apr 2013 07:14:18 -0700 (PDT)
In-Reply-To: <1366204578.31353.88.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 17/04/2013 15:16, Wilco Baan Hofman a =C3=A9crit :
> On Wed, 2013-04-17 at 11:03 +0200, Nicolas Dichtel wrote:
>
>>> Sure, but how do we add nexthop weights and algorithm selection (ha=
sh,
>>> random) to this API? I personally prefer to have the routing behavi=
our
>>> of ipv4 and ipv6 to be as similar as possible, as the basics are th=
e
>>> same anyway.
>> You can use something like this:
>>
>> $ ip -6 route add 3ffe:304:124:2306::/64 dev eth0 nexthop via
>> fe80::230:1bff:feb4:dd4f weight 1
>> $ ip -6 route append 3ffe:304:124:2306::/64 dev eth0 nexthop via
>> fe80::230:1bff:feb4:e05c weight 2
>>
>>>
>>>>>
>>>>> Another one of the flaws is that if I add nexthop weight or algor=
ithm
>>>>> (weighted hash or weighted random) I need to add this to the main=
 rt
>>>>> node, this seems like an inefficient memory structure, as this ne=
eds to
>>>>> be added to all the siblings as well.
>>>> Nexthop weight (rtnh->rtnh_hops) is not implemented.
>>>
>>> Yes it is... in my tree, but I want to extend it to also include su=
pport
>>> for algorithm for hash based, etc.. and to keep it as close to the
>>> existing APIs as possible I think the nexthop structure makes the m=
ost
>>> sense for this.
>>>
>>>>>
>>>>> I propose that we have a nexthop structure to an exclusive route,
>>>>> similar what we have for IPv4, where we store the gateway, device=
 and
>>>>> weight for all nexthops and the algorithm in the route. This woul=
d make
>>>>> the netlink API symmetrical again and fixes the n*n inefficiencie=
s when
>>>>> adding routes (all siblings need to know about all siblings).
>>>>>
>>>>> What are your thoughts on this?
>> The pro of the current implementation is that you can add or delete =
a nexthop
>> withtout removing the whole route. You don't need to list again all =
nexthops
>> each time you want to modify one.
>
> That would also be possible using ip -6 route change, it'll be more
> efficient for insertions and more consistent with the IPv4
> implementation. Remember that most code is in fact shared between IPv=
4
> and IPv6 implementations for routing protocol suites.
>
> For bird it would be much more convenient to have the same API work f=
or
> both as the code is shared (with minor differences).
>
> The memory structure like below would make sense and you can expand i=
t
> as well:
>
> struct ip6_nexthop {
> 	int               flags; /* algorithm per packet or hash, etc */
> 	struct list_head  *hops; /* nh_via */
> };
> struct ip6_nh {
> 	int              ifindex;
> 	struct in6_addr  rt6i_gateway;
> 	char             weight;
> 	int              flags; /* pervasive, onlink */
> };
>
> I'm not sure how to make this map correctly to the append API.. I thi=
nk
> we need to make sure that all APIs either are consistent and symmetri=
cal
> or don't work from day 1.
Maybe the error was to propose two API to insert ECMPv6 routes, but as =
soon as=20
there is two API, one will not be symetric with what is returned by the=
 kernel ;-)

>
> I am willing to implement this, including algorithm support using the
> netlink nexthop API, like the IPv4 implementation.. or change the IPv=
4
> implementation, but either way I feel they need to be consistent.
I'm not sure that this is a major argument. There is already difference=
s between=20
IPv4 and IPv6 (for example, IPv4 addresses are kept when an interface i=
s down,=20
not IPv6 addresses, netlink messages are sent when routes are removed a=
fter=20
putting down an interface in IPv6 but not in IPv4). But I let other spe=
ak about=20
this.
What is important is to avoid breaking existing API.

Regards,
Nicolas
