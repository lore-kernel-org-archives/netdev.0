From: Jesper Dangaard Brouer <hawk@comx.dk>
Subject: Re: Possible regression: Packet drops during iptables calls
Date: Tue, 14 Dec 2010 17:09:18 +0100
Message-ID: <1292342958.9155.91.camel@firesoul.comx.local>
References: <1292337974.9155.68.camel@firesoul.comx.local>
	 <1292340702.5934.5.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1292340702.5934.5.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2010-12-14 at 16:31 +0100, Eric Dumazet wrote:
> Le mardi 14 d=C3=A9cembre 2010 =C3=A0 15:46 +0100, Jesper Dangaard Br=
ouer a
> =C3=A9crit :
> > I'm experiencing RX packet drops during call to iptables, on my
> > production servers.
> >=20
> > Further investigations showed, that its only the CPU executing the
> > iptables command that experience packet drops!?  Thus, a quick fix =
was
> > to force the iptables command to run on one of the idle CPUs (This =
can
> > be achieved with the "taskset" command).
> >=20
> > I have a 2x Xeon 5550 CPU system, thus 16 CPUs (with HT enabled).  =
We
> > only use 8 CPUs due to a multiqueue limitation of 8 queues in the
> > 1Gbit/s NICs (82576 chips).  CPUs 0 to 7 is assigned for packet
> > processing via smp_affinity.
> >=20
> > Can someone explain why the packet drops only occur on the CPU
> > executing the iptables command?
> >=20
>=20
> It blocks BH
>=20
> take a look at commits :
>=20
> 24b36f0193467fa727b85b4c004016a8dae999b9
> netfilter: {ip,ip6,arp}_tables: dont block bottom half more than
> necessary=20
>=20
> 001389b9581c13fe5fc357a0f89234f85af4215d
> netfilter: {ip,ip6,arp}_tables: avoid lockdep false positive
>=20
> for attempts to let BH fly ...
>=20
> Unfortunately, lockdep rules :(

Is the lockdep check a false positive?
Could I run with 24b36f0193 in production, to fix my problem?

I forgot to mention I run kernel 2.6.35.8-comx01+ (based on Greg's stab=
le kernel tree).

$ git describe --contains 24b36f019346
v2.6.36-rc1~571^2~46^2~7
$ git describe --contains 001389b9581c1
v2.6.36-rc3~2^2~42


> > What can we do to solve this issue?

Any ideas how we can proceed?

Looking closer at the two combined code change, I see that the code pat=
h
has been improved (a bit), as the local BH is only disabled inside the
for_each_possible_cpu(cpu).  Before local_bh was disabled for the hole
function.  Guess I need to reproduce this in my testlab.

Thanks for your 'ninja' input ;-)
--=20
Med venlig hilsen / Best regards
  Jesper Brouer
  ComX Networks A/S
  Linux Network Kernel Developer
  Cand. Scient Datalog / MSc.CS
  Author of http://adsl-optimizer.dk
  LinkedIn: http://www.linkedin.com/in/brouer


--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
