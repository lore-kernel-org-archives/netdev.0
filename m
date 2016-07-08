From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: ipv6 issues after an DDoS for kernel 4.6.3
Date: Fri, 8 Jul 2016 11:43:14 -0400
Message-ID: <bd45b0ae-341f-09ed-18f9-fdebfcad733f@stressinduktion.org>
References: <577FAFFD.2020306@gmx.de>
 <1467987260.30694.2.camel@edumazet-glaptop3.roam.corp.google.com>
 <a8a7d2bc-1206-bcf5-3a15-5958728ff5a7@stressinduktion.org>
 <1467992314.30694.15.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?Q?Toralf_F=c3=b6rster?= <toralf.foerster@gmx.de>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:41690 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755664AbcGHPnQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2016 11:43:16 -0400
In-Reply-To: <1467992314.30694.15.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08.07.2016 11:38, Eric Dumazet wrote:
> On Fri, 2016-07-08 at 11:28 -0400, Hannes Frederic Sowa wrote:
>> On 08.07.2016 10:14, Eric Dumazet wrote:
>>> On Fri, 2016-07-08 at 15:51 +0200, Toralf F=C3=B6rster wrote:
>>>> I do run a 4.6.3 hardened Gentoo kernel at a commodity i7 server. =
A
>>>> DDoS with about 300 MBit/sec over 5 mins resulted an issue for ipv=
6 at
>>>> that system.
>>>>
>>>> The IPv6 monitoring from my ISP told my that the to be monitored
>>>> services (80, 443, 52222) weren't reachable any longer at ipv6 (at
>>>> ipv4 there was no issue). Restarting the NIC brought back green li=
ghts
>>>> for the services at the ipv6 ports too.
>>>
>>> Hard to tell without knowing DDOS details, but IPv6 lacks some
>>> scalability improvements found in IPv4.
>>>
>>> IPv4 no longer has a routing cache, but IPv6 still has one.
>>
>> The difference is that routing exceptions are stored in "the" trie
>> instead of hash tables in the fib nodes. IPv4 limits that by the siz=
e of
>> the hash tables, in IPv6 we grow to ipv6/route/max_size, which is pr=
etty
>> low.
>>
>> Only redirects and mtu updates could potentially increase its size.
>> Redirects are limited to the same L2 network, MTU updates must hit t=
he
>> socket to be acted upon appropriately. All limited to max_size, so I
>> currently see a major problem in the routing code.
>>
>> Unfortunately your report has not enough details to pinpoint a speci=
fic
>> problem in the kernel
>=20
> Well, the typical DDOS simply use SYN flood, right ? ;)

Exactly, I can very well imagine that the stack becomes unresponsive
during DDoS, but after the DDoS I don't see a reason why services shoul=
d
come up like in IPv4.

> With IPv4, a server can typically absorb 10 Mpps SYN without major
> disruption on linux-4.6
>=20
> With IPv6, kernel hits the route rwlock quite hard, at less than 2 Mp=
ps
>=20
>     30.44%  [kernel]  [k] ip6_pol_route.isra.49            =20
>     12.93%  [kernel]  [k] fib6_lookup                      =20
>     12.35%  [kernel]  [k] fib6_get_table                   =20
>     10.36%  [kernel]  [k] _raw_read_lock_bh                =20
>      8.29%  [kernel]  [k] _raw_read_unlock_bh              =20
>      2.02%  [kernel]  [k] dst_release                      =20
>      1.86%  [kernel]  [k] memcpy_erms      =20
>=20
> I guess that switching to plain spinlock could help a bit, before maj=
or
> surgery.

Hmm, interesting idea.
