From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Possible regression: Packet drops during iptables calls
Date: Thu, 16 Dec 2010 15:12:13 +0100
Message-ID: <1292508733.2883.152.camel@edumazet-laptop>
References: <1292337974.9155.68.camel@firesoul.comx.local>
	 <1292340702.5934.5.camel@edumazet-laptop>
	 <1292342958.9155.91.camel@firesoul.comx.local>
	 <1292343855.5934.27.camel@edumazet-laptop>
	 <1292508266.31289.12.camel@firesoul.comx.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Arnaldo Carvalho de Melo <acme@infradead.org>,
	Steven Rostedt <srostedt@redhat.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: Jesper Dangaard Brouer <hawk@comx.dk>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1292508266.31289.12.camel@firesoul.comx.local>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 16 d=C3=A9cembre 2010 =C3=A0 15:04 +0100, Jesper Dangaard Brou=
er a
=C3=A9crit :
> On Tue, 2010-12-14 at 17:24 +0100, Eric Dumazet wrote:
> > Le mardi 14 d=C3=A9cembre 2010 =C3=A0 17:09 +0100, Jesper Dangaard =
Brouer a =C3=A9crit :
> > > On Tue, 2010-12-14 at 16:31 +0100, Eric Dumazet wrote:
> > > > Le mardi 14 d=C3=A9cembre 2010 =C3=A0 15:46 +0100, Jesper Danga=
ard Brouer a
> > > > =C3=A9crit :
> > > > > I'm experiencing RX packet drops during call to iptables, on =
my
> > > > > production servers.
> > > > >=20
> > > > > Further investigations showed, that its only the CPU executin=
g the
> > > > > iptables command that experience packet drops!?  Thus, a quic=
k fix was
> > > > > to force the iptables command to run on one of the idle CPUs =
(This can
> > > > > be achieved with the "taskset" command).
> > > > >=20
> > > > > I have a 2x Xeon 5550 CPU system, thus 16 CPUs (with HT enabl=
ed).  We
> > > > > only use 8 CPUs due to a multiqueue limitation of 8 queues in=
 the
> > > > > 1Gbit/s NICs (82576 chips).  CPUs 0 to 7 is assigned for pack=
et
> > > > > processing via smp_affinity.
> > > > >=20
> > > > > Can someone explain why the packet drops only occur on the CP=
U
> > > > > executing the iptables command?
> > > > >=20
> > > >=20
> > > > It blocks BH
> > > >=20
> > > > take a look at commits :
> > > >=20
> > > > 24b36f0193467fa727b85b4c004016a8dae999b9
> > > > netfilter: {ip,ip6,arp}_tables: dont block bottom half more tha=
n
> > > > necessary=20
> > > >=20
> > > > 001389b9581c13fe5fc357a0f89234f85af4215d
> > > > netfilter: {ip,ip6,arp}_tables: avoid lockdep false positiv
> <... cut ...>
> > >=20
> > > Looking closer at the two combined code change, I see that the co=
de path
> > > has been improved (a bit), as the local BH is only disabled insid=
e the
> > > for_each_possible_cpu(cpu).  Before local_bh was disabled for the=
 hole
> > > function.  Guess I need to reproduce this in my testlab.
>=20
>=20
> To do some further investigation into the unfortunate behavior of the
> iptables get_counters() function I started to use "ftrace".  This is =
a
> really useful tool (thanks Steven Rostedt).
>=20
>  # Select the tracer "function_graph"
>  echo function_graph > /sys/kernel/debug/tracing/current_tracer
>=20
>  # Limit the number of function we look at:
>  echo local_bh_\*  >   /sys/kernel/debug/tracing/set_ftrace_filter
>  echo get_counters >>  /sys/kernel/debug/tracing/set_ftrace_filter
>=20
>  # Enable tracing while calling iptables
>  cd /sys/kernel/debug/tracing
>  echo 0 > trace
>  echo 1 > tracing_enabled;
>    taskset 1 iptables -vnL > /dev/null ;
>  echo 0 > tracing_enabled
>  cat trace | less
>=20
>=20
> The reduced output:
>=20
> # tracer: function_graph
> #
> # CPU  DURATION                  FUNCTION CALLS
> # |     |   |                     |   |   |   |
>   2)   2.772 us    |  local_bh_disable();
> ....
>   0)   0.228 us    |  local_bh_enable();
>   0)               |  get_counters() {
>   0)   0.232 us    |    local_bh_disable();
>   0)   7.919 us    |    local_bh_enable();
>   0) ! 109467.1 us |  }
>   0)   2.344 us    |  local_bh_disable();
>=20
>=20
> The output show that we spend no less that 100 ms with local BH
> disabled.  So, no wonder that this causes packet drops in the NIC
> (attached to this CPU).
>=20
> My iptables rule set in question is also very large, it contains:
>  Chains: 20929
>  Rules: 81239
>=20
> The vmalloc size is approx 19 MB (19.820.544 bytes) (see
> /proc/vmallocinfo).  Looking through vmallocinfo I realized that
> even-though I only have 16 CPUs, there is 32 allocated rulesets
> "xt_alloc_table_info" (for the filter table). Thus, I have approx
> 634MB iptables filter rules in the kernel, half of which is totally
> unused.

Boot your machine with : "maxcpus=3D16 possible_cpus=3D16", it will be =
much
better ;)

>=20
> Guess this is because we use: "for_each_possible_cpu" instead of
> "for_each_online_cpu". (Feel free to fix this, or point me to some
> documentation of this CPU hotplug stuff... I see we are missing
> get_cpu() and put_cpu() a lot of places).

Are you really using cpu hotplug ? If not, the "maxcpus=3D16
possible_cpus=3D16" trick should be enough for you.

>=20
>=20
> The GOOD NEWS, is that moving the local BH disable section into the
> "for_each_possible_cpu" fixed the problem with packet drops during
> iptables calls.
>=20
> I wanted to profile with ftrace on the new code, but I cannot get the
> measurement I want. Perhaps Steven or Acme can help?
>=20
> Now I want to measure the time used between the local_bh_disable() an=
d
> local_bh_enable, within the loop.  I cannot figure out howto do that?
> The new trace looks almost the same as before, just a lot of
> local_bh_* inside the get_counters() function call.
>=20
>  Guess is that the time spend is: 100 ms / 32 =3D 3.125 ms.
>=20

yes, approximatly.

In order to accelerate, you could eventually pre-fill cpu cache before
the local_bh_disable() (just reading the table). So that critical
section is short, because mostly in your cpu cache.

> Now I just need to calculate, how large a NIC buffer I need to buffer
> 3.125 ms at 1Gbit/s.
>=20
>  3.125 ms *  1Gbit/s =3D 390625 bytes
>=20
> Can this be correct?
>=20
> How much buffer does each queue have in the 82576 NIC?
> (Hope Alexander Duyck can answer this one?)
>=20


--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
