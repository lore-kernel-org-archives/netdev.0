From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: DDoS attack causing bad effect on conntrack searches
Date: Sat, 24 Apr 2010 22:11:01 +0200
Message-ID: <1272139861.20714.525.camel@edumazet-laptop>
References: <1271941082.14501.189.camel@jdb-workstation>
	 <q2h412e6f7f1004220613m488c2ee4r6d24a8d1e65997d4@mail.gmail.com>
	 <4BD04C74.9020402@trash.net> <1271946961.7895.5665.camel@edumazet-laptop>
	 <1271948029.7895.5707.camel@edumazet-laptop>
	 <20100422155123.GA2524@linux.vnet.ibm.com>
	 <1271952128.7895.5851.camel@edumazet-laptop>
	 <Pine.LNX.4.64.1004222213290.10919@ask.diku.dk>
	 <1272056237.4599.7.camel@edumazet-laptop>
	 <Pine.LNX.4.64.1004241219280.32071@ask.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: paulmck@linux.vnet.ibm.com, Patrick McHardy <kaber@trash.net>,
	Changli Gao <xiaosuo@gmail.com>, hawk@comx.dk,
	Linux Kernel Network Hackers <netdev@vger.kernel.org>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>
To: Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.1004241219280.32071@ask.diku.dk>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le samedi 24 avril 2010 =C3=A0 13:11 +0200, Jesper Dangaard Brouer a =C3=
=A9crit :
> On Fri, 23 Apr 2010, Eric Dumazet wrote:
>=20
> > Le jeudi 22 avril 2010 =C3=A0 22:38 +0200, Jesper Dangaard Brouer a=
 =C3=A9crit :
> >
> >>
> >> I think its plausable, there is a lot of modification going on.
> >> Approx 40.000 deletes/sec and 40.000 inserts/sec.
> >> The hash bucket size is 300032, and with 80000 modifications/sec, =
we are
> >> (potentially) changing 26.6% of the hash chains each second.
> >>
> >> As can be seen from the graphs:
> >>   http://people.netfilter.org/hawk/DDoS/2010-04-12__001/list.html
> >>
> >> Notice that primarily CPU2 is doing the 40k deletes/sec, while CPU=
1 is
> >> caught searching...
> >>
> >>
> >>> maybe hash table has one slot :)
> >>
> >> Guess I have to reproduce the DoS attack in a testlab (I will firs=
t have
> >> time Tuesday).  So we can determine if its bad hashing or restart =
of the
> >> search loop.
> >>
> >>
> >> The traffic pattern was fairly simple:
> >>
> >> 200 bytes UDP packets, comming from approx 60 source IPs, going to=
 one
> >> destination IP.  The UDP destination port number was varied in the=
 range
> >> of 1 to 6000.   The source UDP port was varied a bit more, some ra=
nging
> >> from 32768 to 61000, and some from 1028 to 5000.
> >>
> >>
> >
> > Re-reading this, I am not sure there is a real problem on RCU as yo=
u
> > pointed out.
> >
> > With 800.000 entries, in a 300.032 buckets hash table, each lookup =
hit
> > about 3 entries (aka searches in conntrack stats)
> >
> > 300.000 packets/second -> 900.000 'searches' per second.
>=20
> The machine is not getting 300.000 pps, its only getting 40.000 pps (=
the=20
> rest is stopped by the NIC by sending Ethernet flowcontrol pause fram=
es)
>=20
>   http://people.netfilter.org/hawk/DDoS/2010-04-12__001/eth0-rx.png
>=20
> We are doing 700.000 'searches' per second, with 40.000 pps, thus on=20
> average the list lenght (in each hash bucket) just need to be 17.5=20
> elements.  Is this an acceptable has distribution, with 900.000 eleme=
nts=20
> in a 300.032 buckets hash table?
>=20
>=20
> > If you have four cpus all trying to insert/delete entries in //, th=
ey
> > all hit the central conntrack lock.
>=20
> This machine only have two CPUs, or rather one physical CPU and one=20
> hyperthreaded.  The server is a old HP380 G4, with an old Xeon type C=
PU=20
> 3.4 GHz (1MB cache).  If remember correctly its based on Pentium-4=20
> technologi, which had a pretty bad hyperthreading.
>=20
>=20
> > On a DDOS scenario, every packet needs to take this lock twice,
> > once to free an old conntrack (early drop), once to insert a new en=
try.
>=20
> I was worried about if the "early drop" e.g. free an old conntrack wo=
uld=20
> disturbe the conntrack searching?
>=20
>=20
> > To scale this, only way would be to have an array of locks, like we=
 have
> > for TCP/UDP hash tables.
> >
> > I did some tests here, with a multiqueue card, flooded with 300.000
> > pack/second, 65.536 source IP, millions of flows, and nothing wrong
> > happened (but packets drops, of course)
>=20
> A small hint when testing, use Haralds tool 'lnstat' to see the stats=
 on=20
> the command line, thus you don't need to RRDtool graphe every thing:
>=20
> Command:
>   lnstat -f nf_conntrack -i 1 -c 1000
>=20
> I don't have a multiqueue NIC in this old machine.
>=20
> I also ran some tests on my 10G testlab, but it didn't go wrong.=20
> Tweeking the pktgen DDoS I could get the system to do 4.500.000 'sear=
ches'=20
> per sec with a 1.500.000 packets/sec. (Have not reloaded the kernel w=
ith=20
> the new failed lookup stats).  Guess my 10G machines are too fast to =
hit=20
> the issues.
>=20
>=20
> > My two cpus were busy 100%, after tweaking smp_affinities, because =
on
> > first try, irqbalance put "01" mask on both queues, so only one kso=
ftirq
> > was working, other cpu was idle :(
>=20
> Think my machine is some what slower than yours, perhaps its simply n=
ot=20
> fast enough for this kind of workload (pretty sure that the cache is =
the=20
> CPU is getting f*ked in this case).
>=20
> On my machine one CPU in stuck in softirq:
>   http://people.netfilter.org/hawk/DDoS/2010-04-12__001/cpu_softirq00=
1.png
>=20
> And another observation is that the CPUs are disturbing each other on=
 the=20
> RX softirq code path.
> http://people.netfilter.org/hawk/DDoS/2010-04-12__001/softnet_time_sq=
ueeze_rx-softirq001.png
> (/proc/net/softnet_stat column 3)
>=20
> Monday or Tuesdag I'll do a test setup with some old HP380 G4 machine=
s to=20
> see if I can reproduce the DDoS attack senario.  And see if I can get=
=20
> it into to lookup loop.

Theorically a loop is very unlikely, given a single retry is very
unlikly too.

Unless a cpu gets in its cache a corrupted value of a 'next' pointer.

Maybe a hardware problem ?

My test machine is a fairly low end one, an AMD Athlon Dual core 5050e,
2.6 GHz

I used an igb card for ease of setup, and to make sure my two cores
would handle packets in parallel, without RPS.

With same hash bucket size (300.032) and max conntracks (800.000), and
after more than 10 hours of test, not a single lookup was restarted
because of a nulls with wrong value.

I can setup a test on a 16 cpu machine, multiqueue card too.

Hmm, I forgot to say I am using net-next-2.6, not your kernel version..=
=2E



--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
