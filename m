From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Possible regression: Packet drops during iptables calls
Date: Tue, 14 Dec 2010 17:24:15 +0100
Message-ID: <1292343855.5934.27.camel@edumazet-laptop>
References: <1292337974.9155.68.camel@firesoul.comx.local>
	 <1292340702.5934.5.camel@edumazet-laptop>
	 <1292342958.9155.91.camel@firesoul.comx.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Jesper Dangaard Brouer <hawk@comx.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:51421 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759488Ab0LNQYU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Dec 2010 11:24:20 -0500
In-Reply-To: <1292342958.9155.91.camel@firesoul.comx.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 14 d=C3=A9cembre 2010 =C3=A0 17:09 +0100, Jesper Dangaard Brou=
er a
=C3=A9crit :
> On Tue, 2010-12-14 at 16:31 +0100, Eric Dumazet wrote:
> > Le mardi 14 d=C3=A9cembre 2010 =C3=A0 15:46 +0100, Jesper Dangaard =
Brouer a
> > =C3=A9crit :
> > > I'm experiencing RX packet drops during call to iptables, on my
> > > production servers.
> > >=20
> > > Further investigations showed, that its only the CPU executing th=
e
> > > iptables command that experience packet drops!?  Thus, a quick fi=
x was
> > > to force the iptables command to run on one of the idle CPUs (Thi=
s can
> > > be achieved with the "taskset" command).
> > >=20
> > > I have a 2x Xeon 5550 CPU system, thus 16 CPUs (with HT enabled).=
  We
> > > only use 8 CPUs due to a multiqueue limitation of 8 queues in the
> > > 1Gbit/s NICs (82576 chips).  CPUs 0 to 7 is assigned for packet
> > > processing via smp_affinity.
> > >=20
> > > Can someone explain why the packet drops only occur on the CPU
> > > executing the iptables command?
> > >=20
> >=20
> > It blocks BH
> >=20
> > take a look at commits :
> >=20
> > 24b36f0193467fa727b85b4c004016a8dae999b9
> > netfilter: {ip,ip6,arp}_tables: dont block bottom half more than
> > necessary=20
> >=20
> > 001389b9581c13fe5fc357a0f89234f85af4215d
> > netfilter: {ip,ip6,arp}_tables: avoid lockdep false positive
> >=20
> > for attempts to let BH fly ...
> >=20
> > Unfortunately, lockdep rules :(
>=20
> Is the lockdep check a false positive?

Yes its a false positive.

> Could I run with 24b36f0193 in production, to fix my problem?
>=20

Yes, but you could also run a kernel with both commits:

We now block BH for each cpu we are "summing", instead of blocking BH
for the whole 16 possible cpus summation. (so BH should be blocked for
smaller amount of time)

> I forgot to mention I run kernel 2.6.35.8-comx01+ (based on Greg's st=
able kernel tree).
>=20
> $ git describe --contains 24b36f019346
> v2.6.36-rc1~571^2~46^2~7
> $ git describe --contains 001389b9581c1
> v2.6.36-rc3~2^2~42
>=20
>=20
> > > What can we do to solve this issue?
>=20
> Any ideas how we can proceed?
>=20
> Looking closer at the two combined code change, I see that the code p=
ath
> has been improved (a bit), as the local BH is only disabled inside th=
e
> for_each_possible_cpu(cpu).  Before local_bh was disabled for the hol=
e
> function.  Guess I need to reproduce this in my testlab.
>=20

Yes, so current kernel is a bit better.

Note that even with the 'false positive' problem, we had to blocks BH
for the current cpu sum, so the max BH latency is probably the same wit=
h
or without 001389b9581c13fe5



