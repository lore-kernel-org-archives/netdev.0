From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Possible regression: Packet drops during iptables calls
Date: Tue, 14 Dec 2010 16:31:42 +0100
Message-ID: <1292340702.5934.5.camel@edumazet-laptop>
References: <1292337974.9155.68.camel@firesoul.comx.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Jesper Dangaard Brouer <hawk@comx.dk>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1292337974.9155.68.camel@firesoul.comx.local>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 14 d=C3=A9cembre 2010 =C3=A0 15:46 +0100, Jesper Dangaard Brou=
er a
=C3=A9crit :
> I'm experiencing RX packet drops during call to iptables, on my
> production servers.
>=20
> Further investigations showed, that its only the CPU executing the
> iptables command that experience packet drops!?  Thus, a quick fix wa=
s
> to force the iptables command to run on one of the idle CPUs (This ca=
n
> be achieved with the "taskset" command).
>=20
> I have a 2x Xeon 5550 CPU system, thus 16 CPUs (with HT enabled).  We
> only use 8 CPUs due to a multiqueue limitation of 8 queues in the
> 1Gbit/s NICs (82576 chips).  CPUs 0 to 7 is assigned for packet
> processing via smp_affinity.
>=20
> Can someone explain why the packet drops only occur on the CPU
> executing the iptables command?
>=20
>=20

It blocks BH

take a look at commits :

24b36f0193467fa727b85b4c004016a8dae999b9
netfilter: {ip,ip6,arp}_tables: dont block bottom half more than
necessary=20

001389b9581c13fe5fc357a0f89234f85af4215d
netfilter: {ip,ip6,arp}_tables: avoid lockdep false positive

for attempts to let BH fly ...

Unfortunately, lockdep rules :(


> What can we do to solve this issue?
>=20
>=20
> I should note that I have a very large ruleset on this machine, and
> the production machine is routing around 800 Mbit/s, in each
> direction.  The issue occurs on a simple iptables rule listing.
>=20
>=20
> I think (untested) the problem is related to kernel git commit:
>=20
>  commit 942e4a2bd680c606af0211e64eb216be2e19bf61
>  Author: Stephen Hemminger <shemminger@vyatta.com>
>  Date: Tue Apr 28 22:36:33 2009 -0700
>=20
>  netfilter: revised locking for x_tables
>=20
>  The x_tables are organized with a table structure and a per-cpu copi=
es
>  of the counters and rules. On older kernels there was a reader/write=
r
>  lock per table which was a performance bottleneck. In 2.6.30-rc, thi=
s
>  was converted to use RCU and the counters/rules which solved the per=
formance
>  problems for do_table but made replacing rules much slower because o=
f
>  the necessary RCU grace period.
>=20
>  This version uses a per-cpu set of spinlocks and counters to allow t=
o
>  table processing to proceed without the cache thrashing of a global
>  reader lock and keeps the same performance for table updates.
>=20
>  Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>  Acked-by: Linus Torvalds <torvalds@linux-foundation.org>
>  Signed-off-by: David S. Miller <davem@davemloft.net>
>=20


--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
