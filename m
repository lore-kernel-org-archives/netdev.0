From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 0% cpu usasge after fresh boot or net restart but 10% CPU if
 kernel flush route cache
Date: Fri, 29 Jan 2010 10:06:37 +0100
Message-ID: <1264755997.3184.8.camel@edumazet-laptop>
References: <41ac0f9e1001260858o7d2a6a6dgb37ecfba5c325932@mail.gmail.com>
	 <1264605976.3197.8.camel@edumazet-laptop>
	 <41ac0f9e1001271153u333a5e2aq6f473ccc6e6d1e23@mail.gmail.com>
	 <1264627088.2892.7.camel@edumazet-laptop>
	 <41ac0f9e1001280114x17951046oda3fddcae4b8b9d3@mail.gmail.com>
	 <1264694957.2930.15.camel@edumazet-laptop>
	 <41ac0f9e1001280826j1a4e6caar47ccfd357b6feb37@mail.gmail.com>
	 <1264698380.2930.20.camel@edumazet-laptop>
	 <41ac0f9e1001281049g119d5b1bgbc47f78150cac6ee@mail.gmail.com>
	 <1264713387.3380.17.camel@edumazet-laptop>
	 <41ac0f9e1001282338n76217590u61877f181c05dc06@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: cold cold <nedkonedev@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:59089 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753295Ab0A2JGl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2010 04:06:41 -0500
Received: by bwz27 with SMTP id 27so1240934bwz.21
        for <netdev@vger.kernel.org>; Fri, 29 Jan 2010 01:06:40 -0800 (PST)
In-Reply-To: <41ac0f9e1001282338n76217590u61877f181c05dc06@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 29 janvier 2010 =C3=A0 09:38 +0200, cold cold a =C3=A9crit =
:

> I'm totally agree with you there must be some scheduler to release
> route cache over the time.
> So far i see garbage collector do this, but it cost a lot of CPU
> probably its is a bug or design problem don't know
> for this i make this 2 test to compare CPU usage with and without GC.
>=20
>=20
> / secret_interval 10 min,  1300000 route entries in cash ofter 10 min=
,
>  7k new route on empty cache 2k on 1300000  /
> all route cache parameters default. I try also with gc_elasticity fro=
m
> 8 to 2 and gc_interval from 60 to 1 but don't have
> too much difference.
>=20
> What I'm trying to say is that flush cash is almost instant ( less
> then second on 1 CPU) so releasing of cash is not so heavy job
>  ( you are right can have a big impact on dropped frames because of
> cpu/ram congestion ) but my point is why GC need 5-6min
> 10% no  4 CPU to do same job ?
> --

Once again, 'flushing cache' is immediate, it only increments a global
variable (aka a generation number)

Then, later, when ip routing hits an entry with an old generation
number, this entry is discarded. This slows down processing, and your
router might drop packets during 5 to 60 seconds, while stale entries
are eliminated.

This delays the real cost of 'flush cache' in a smooth way, depending
on trafic you have.

Releasing 1.300.000 dst entries is expensive, no matter how you trigger
the release, because it has to go through RCU queueing, spinlocks,
kernel memory allocator logic, and touch a lot of memory.

In your previous "perf top" results, we saw most of kernel cpu cycles
were consumed outside of network stack, you might investigate why.

Using HPET time keeping is probably not very good for your machine...


