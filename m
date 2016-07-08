From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: ipv6 issues after an DDoS for kernel 4.6.3
Date: Fri, 08 Jul 2016 17:38:34 +0200
Message-ID: <1467992314.30694.15.camel@edumazet-glaptop3.roam.corp.google.com>
References: <577FAFFD.2020306@gmx.de>
	 <1467987260.30694.2.camel@edumazet-glaptop3.roam.corp.google.com>
	 <a8a7d2bc-1206-bcf5-3a15-5958728ff5a7@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Toralf =?ISO-8859-1?Q?F=F6rster?= <toralf.foerster@gmx.de>,
	netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:33743 "EHLO
	mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754983AbcGHPih (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2016 11:38:37 -0400
Received: by mail-qt0-f194.google.com with SMTP id f89so8087557qtd.0
        for <netdev@vger.kernel.org>; Fri, 08 Jul 2016 08:38:36 -0700 (PDT)
In-Reply-To: <a8a7d2bc-1206-bcf5-3a15-5958728ff5a7@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-07-08 at 11:28 -0400, Hannes Frederic Sowa wrote:
> On 08.07.2016 10:14, Eric Dumazet wrote:
> > On Fri, 2016-07-08 at 15:51 +0200, Toralf F=C3=B6rster wrote:
> >> I do run a 4.6.3 hardened Gentoo kernel at a commodity i7 server. =
A
> >> DDoS with about 300 MBit/sec over 5 mins resulted an issue for ipv=
6 at
> >> that system.
> >>
> >> The IPv6 monitoring from my ISP told my that the to be monitored
> >> services (80, 443, 52222) weren't reachable any longer at ipv6 (at
> >> ipv4 there was no issue). Restarting the NIC brought back green li=
ghts
> >> for the services at the ipv6 ports too.
> >=20
> > Hard to tell without knowing DDOS details, but IPv6 lacks some
> > scalability improvements found in IPv4.
> >=20
> > IPv4 no longer has a routing cache, but IPv6 still has one.
>=20
> The difference is that routing exceptions are stored in "the" trie
> instead of hash tables in the fib nodes. IPv4 limits that by the size=
 of
> the hash tables, in IPv6 we grow to ipv6/route/max_size, which is pre=
tty
> low.
>=20
> Only redirects and mtu updates could potentially increase its size.
> Redirects are limited to the same L2 network, MTU updates must hit th=
e
> socket to be acted upon appropriately. All limited to max_size, so I
> currently see a major problem in the routing code.
>=20
> Unfortunately your report has not enough details to pinpoint a specif=
ic
> problem in the kernel

Well, the typical DDOS simply use SYN flood, right ? ;)

With IPv4, a server can typically absorb 10 Mpps SYN without major
disruption on linux-4.6

With IPv6, kernel hits the route rwlock quite hard, at less than 2 Mpps

    30.44%  [kernel]  [k] ip6_pol_route.isra.49            =20
    12.93%  [kernel]  [k] fib6_lookup                      =20
    12.35%  [kernel]  [k] fib6_get_table                   =20
    10.36%  [kernel]  [k] _raw_read_lock_bh                =20
     8.29%  [kernel]  [k] _raw_read_unlock_bh              =20
     2.02%  [kernel]  [k] dst_release                      =20
     1.86%  [kernel]  [k] memcpy_erms      =20

I guess that switching to plain spinlock could help a bit, before major
surgery.
