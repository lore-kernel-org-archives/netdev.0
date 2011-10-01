From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: big picture UDP/IP performance question re 2.6.18 -> 2.6.32
Date: Sat, 01 Oct 2011 08:44:02 +0200
Message-ID: <1317451442.3802.18.camel@edumazet-laptop>
References: <6.2.5.6.2.20111001012019.05c05b80@flumedata.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>
To: starlight@binnacle.cx
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:46234 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752865Ab1JAGoI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Oct 2011 02:44:08 -0400
In-Reply-To: <6.2.5.6.2.20111001012019.05c05b80@flumedata.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 01 octobre 2011 =C3=A0 01:30 -0400, starlight@binnacle.cx a =C3=
=A9crit :
> Hello,
>=20
> I'm hoping someone can provide a brief big-picture
> perspective on the dramatic UDP/IP multicast
> receive performance reduction from 2.6.18 to
> 2.6.32 that I just benchmarked.
>=20
> Have helped out in the past, mainly by identifying
> a bug in hugepage handling and providing a solid
> testcase that helped in quickly identifying and
> correcting the problem.
>=20
> Have a very-high-volume UDP multicast receiver
> application.  Just finished benchmarking latest RH
> variant of 2.6.18 against latest RH 2.6.32 and
> vanilla 2.6.32.27 on the same 12 core Opteron
> 6174 processor system, one CPU.
>=20
> Application reads on 250 sockets with large socket
> buffer maximums.  Zero data loss.  Four Intel
> 'e1000e' 82571 gigabit NICs, or two Intel 'igb'
> 82571 gigabit NICs or two Intel 82599 10 gigabit
> NICs.  Results similar on all.
>=20
> With 2.6.18, system CPU is reported in
> /proc/<pid>/stat as 25% of total.  With 2.6.32,
> system consumption is 45% with the same exact data
> playback test.  Jiffy count for user CPU is same
> for both kernels, but .32 system CPU is double
> .18 system CPU.
>=20
> Overall maximum performance capacity is reduced in
> proportion to the increased system overhead.
>=20
> ------
>=20
> My question is why is the performance significantly
> worse in the more recent kernels?  Apparently
> network performance is worse for TCP by about the
> same amount--double the system overhead for the
> same amount of work.
>=20
> http://www.phoronix.com/scan.php?page=3Darticle&item=3Dlinux_2612_263=
7&num=3D6
>=20
> Is there any chance that network performance will
> improve in future kernels?  Or is the situation
> a permanent trade-off for security, reliability
> or scalability reasons?
>=20

CC netdev

Since you have 2.6.32, you could use perf tool and provide us a
performance report.

In my experience, I have the exact opposite : performance greatly
improved in recent kernels. Unless you compile your kernel to include
new features that might reduce performance (namespaces, cgroup, ...)

It can vary a lot depending on many parameters, like cpu affinities,
device parameters (coalescing, interrupt mitigation...).

You cant expect switching from 2.6.18 to 2.6.32 and have exactly same
system behavior.

If your app is performance sensitive, you'll have to make some analysis
to find out what needs to be tuned.

One known problem of old kernels and UDP is that they was no memory
accouting, so an application could easily consume all kernel memory and
crash the machine.

So in 2.6.25, Hideo Aoki added memory limiting to UDP, slowing down a
lot of UDP operations because of added socket locking, both on transmit
and receive path.

If your application is multithreaded and use a single socket, you can
hit lock contention since 2.6.25.

Step by step, we tried to remove part of the scalability problems
introduced in 2.6.25

In 2.6.35, we speedup receive path a bit (avoiding backlog processing)

In 2.6.39, transmit path became lockless again, thanks to Herbert Xu.

I advise you to try a recent kernel if you need UDP performance, 2.6.32
is quite old

Multicast is quite a stress for process scheduler, so we experimented a
way to group all wakeups at the end of softirq handler.

Work is in progress in this area : Peter Zijlstra named this "delayed
wakeup". A further idea would be to be able to delegate the wakeups to
another cpu, since I suspect you have one CPU busy in softirq
processing, and other cpus are ile.
