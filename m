From: Jesper Dangaard Brouer <hawk@comx.dk>
Subject: Re: Possible regression: Packet drops during iptables calls
Date: Thu, 16 Dec 2010 15:04:26 +0100
Message-ID: <1292508266.31289.12.camel@firesoul.comx.local>
References: <1292337974.9155.68.camel@firesoul.comx.local>
	 <1292340702.5934.5.camel@edumazet-laptop>
	 <1292342958.9155.91.camel@firesoul.comx.local>
	 <1292343855.5934.27.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: Arnaldo Carvalho de Melo <acme@infradead.org>,
	Steven Rostedt <srostedt@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1292343855.5934.27.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Tue, 2010-12-14 at 17:24 +0100, Eric Dumazet wrote:
> Le mardi 14 d=C3=A9cembre 2010 =C3=A0 17:09 +0100, Jesper Dangaard Br=
ouer a =C3=A9crit :
> > On Tue, 2010-12-14 at 16:31 +0100, Eric Dumazet wrote:
> > > Le mardi 14 d=C3=A9cembre 2010 =C3=A0 15:46 +0100, Jesper Dangaar=
d Brouer a
> > > =C3=A9crit :
> > > > I'm experiencing RX packet drops during call to iptables, on my
> > > > production servers.
> > > >=20
> > > > Further investigations showed, that its only the CPU executing =
the
> > > > iptables command that experience packet drops!?  Thus, a quick =
fix was
> > > > to force the iptables command to run on one of the idle CPUs (T=
his can
> > > > be achieved with the "taskset" command).
> > > >=20
> > > > I have a 2x Xeon 5550 CPU system, thus 16 CPUs (with HT enabled=
).  We
> > > > only use 8 CPUs due to a multiqueue limitation of 8 queues in t=
he
> > > > 1Gbit/s NICs (82576 chips).  CPUs 0 to 7 is assigned for packet
> > > > processing via smp_affinity.
> > > >=20
> > > > Can someone explain why the packet drops only occur on the CPU
> > > > executing the iptables command?
> > > >=20
> > >=20
> > > It blocks BH
> > >=20
> > > take a look at commits :
> > >=20
> > > 24b36f0193467fa727b85b4c004016a8dae999b9
> > > netfilter: {ip,ip6,arp}_tables: dont block bottom half more than
> > > necessary=20
> > >=20
> > > 001389b9581c13fe5fc357a0f89234f85af4215d
> > > netfilter: {ip,ip6,arp}_tables: avoid lockdep false positiv
<... cut ...>
> >=20
> > Looking closer at the two combined code change, I see that the code=
 path
> > has been improved (a bit), as the local BH is only disabled inside =
the
> > for_each_possible_cpu(cpu).  Before local_bh was disabled for the h=
ole
> > function.  Guess I need to reproduce this in my testlab.


To do some further investigation into the unfortunate behavior of the
iptables get_counters() function I started to use "ftrace".  This is a
really useful tool (thanks Steven Rostedt).

 # Select the tracer "function_graph"
 echo function_graph > /sys/kernel/debug/tracing/current_tracer

 # Limit the number of function we look at:
 echo local_bh_\*  >   /sys/kernel/debug/tracing/set_ftrace_filter
 echo get_counters >>  /sys/kernel/debug/tracing/set_ftrace_filter

 # Enable tracing while calling iptables
 cd /sys/kernel/debug/tracing
 echo 0 > trace
 echo 1 > tracing_enabled;
   taskset 1 iptables -vnL > /dev/null ;
 echo 0 > tracing_enabled
 cat trace | less


The reduced output:

# tracer: function_graph
#
# CPU  DURATION                  FUNCTION CALLS
# |     |   |                     |   |   |   |
  2)   2.772 us    |  local_bh_disable();
=2E...
  0)   0.228 us    |  local_bh_enable();
  0)               |  get_counters() {
  0)   0.232 us    |    local_bh_disable();
  0)   7.919 us    |    local_bh_enable();
  0) ! 109467.1 us |  }
  0)   2.344 us    |  local_bh_disable();


The output show that we spend no less that 100 ms with local BH
disabled.  So, no wonder that this causes packet drops in the NIC
(attached to this CPU).

My iptables rule set in question is also very large, it contains:
 Chains: 20929
 Rules: 81239

The vmalloc size is approx 19 MB (19.820.544 bytes) (see
/proc/vmallocinfo).  Looking through vmallocinfo I realized that
even-though I only have 16 CPUs, there is 32 allocated rulesets
"xt_alloc_table_info" (for the filter table). Thus, I have approx
634MB iptables filter rules in the kernel, half of which is totally
unused.

Guess this is because we use: "for_each_possible_cpu" instead of
"for_each_online_cpu". (Feel free to fix this, or point me to some
documentation of this CPU hotplug stuff... I see we are missing
get_cpu() and put_cpu() a lot of places).


The GOOD NEWS, is that moving the local BH disable section into the
"for_each_possible_cpu" fixed the problem with packet drops during
iptables calls.

I wanted to profile with ftrace on the new code, but I cannot get the
measurement I want. Perhaps Steven or Acme can help?

Now I want to measure the time used between the local_bh_disable() and
local_bh_enable, within the loop.  I cannot figure out howto do that?
The new trace looks almost the same as before, just a lot of
local_bh_* inside the get_counters() function call.

 Guess is that the time spend is: 100 ms / 32 =3D 3.125 ms.

Now I just need to calculate, how large a NIC buffer I need to buffer
3.125 ms at 1Gbit/s.

 3.125 ms *  1Gbit/s =3D 390625 bytes

Can this be correct?

How much buffer does each queue have in the 82576 NIC?
(Hope Alexander Duyck can answer this one?)

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
