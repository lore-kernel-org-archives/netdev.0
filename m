From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Kernel forwarding performance test regressions
Date: Tue, 25 Aug 2009 09:04:59 -0700
Message-ID: <20090825090459.3a821298@nehalam>
References: <20090819110010.53b630cd@nehalam>
	<4A93B34E.1040100@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Robert Olsson <robert.olsson@its.uu.se>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:35630 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752237AbZHYQFE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2009 12:05:04 -0400
In-Reply-To: <4A93B34E.1040100@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 25 Aug 2009 11:47:58 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Stephen Hemminger a =C3=A9crit :
> > Vyatta regularly runs RFC2544 performance tests as part of
> > the QA release regression tests. These tests are run using
> > a Spirent analyzer that sends packets at maximum rate and
> > measures the number of packets received.
> >=20
> > The interesting (worst case) number is the forwarding percentage fo=
r
> > minimum size Ethernet packets.  For packets 1K and above all the pa=
ckets
> > get through but for smaller sizes the system can't keep up.
> >=20
> > The hardware is Dell based
> > CPU is Intel Dual Core E2220 @ 2.40GHz (or 2.2GHz)
> > NIC's are internal Broadcom (tg3).
> >=20
> > Size	2.6.23	2.6.24	2.6.26	2.6.29	2.6.30
> > 64	 14.%	 20%	 21%	 17%	 19%
> > 128	 22	 33	 34	 28	 32
> > 256	 37	 52	 58	 49	 54
> > 512	 67	 85	 83	 85	 85
> > 1024	100	100	100	100	100
> > 1280	100	100	100	100	100
> > 1518	100	100	100	100	100
> >=20
> >=20
> > Some other details:=20
> >   * Hardware change between 2.6.24 -> 2.6.26 numbers
> >     went from 2.2 to 2.4Ghz
> >=20
> >   * no SMP affinity (or irqbalance) is done,
> >     numbers are significantly better if IRQ's are pinned.
> >     2.6.26 goes from 20% to 32%
>=20
> Thats strange, because at Giga flood level, we should be on NAPI mode=
,
> ksoftirqd using 100% of one cpu. SMP affinities should not matter at =
all...

The transmit completions are still kicking off some interrupts.

> >=20
> >   * unidirectional numbers are 2X the bidirectional numbers:
> >     2.6.26 goes from 20% to 40%
> >=20
> >   * this is single stream (doesn't help/use multiqueue)
> >=20
> >   * system loads iptables but does not use it, so each packet
> >     sees the overhead of null rules.
> >=20
> > So kernel 2.6.29 had an observable dip in performance
> > which seems to be mostly recovered in 2.6.30.
> >=20
> > These are from our QA, not me so please don't ask me for
> > "please rerun with XX enabled", go run the same test
> > yourself with pktgen.
> >=20
>=20
> Unfortunatly I cannot reach line-rate with pktgen and small packets.
> (Limit ~1012333pps 485Mb/sec on my test machine, 3GHz E5450 cpu)

Things that help:
  * make sure flow control is off
  * increase transmit ring size
  * sometimes tx IRQ coalescing
Using an old SMP Opteron box for pktgen right now.

> It seems timestamping is too expensive on pktgen, even for "delay 0"=20
> and only one device setup (next_to_run() doesnt have to select the 'b=
est' device)
> We probably can improve pktgen a litle bit, or use a faster timestamp=
ing...

I have a patch that might help, I haven't tested it or used it.
It converts the pktgen calls from gettimeofday to using sched_clock()
this saves the math overhead since pktgen only cares about comparison
and delta's. It also prevents problems with kernel deciding clock
source is not stable.  Still need to test and review this to make
sure pktgen only uses value on same cpu.

> oprofile results on pktgen machine (linux 2.6.30.5) :
> CPU: Core 2, speed 3000.08 MHz (estimated)
> Counted CPU_CLK_UNHALTED events (Clock cycles when not halted) with a=
 unit mask of 0x00 (Unhalted core cycles) count 100000
> samples  cum. samples  %        cum. %     symbol name
> 58137    58137         27.9549  27.9549    read_tsc
> 51487    109624        24.7573  52.7122    pktgen_thread_worker
> 33079    142703        15.9059  68.6181    getnstimeofday
> 15694    158397         7.5464  76.1645    getCurUs
> 11806    170203         5.6769  81.8413    do_gettimeofday
> 5852     176055         2.8139  84.6553    kthread_should_stop
> 5244     181299         2.5216  87.1768    kthread
> 4181     185480         2.0104  89.1872    mwait_idle
> 3837     189317         1.8450  91.0322    consume_skb
> 2217     191534         1.0660  92.0983    skb_dma_unmap
> 1599     193133         0.7689  92.8671    skb_dma_map
> 1389     194522         0.6679  93.5350    local_bh_enable_ip
> 1350     195872         0.6491  94.1842    nommu_map_page
> 1086     196958         0.5222  94.7064    mix_pool_bytes_extract
> 835      197793         0.4015  95.1079    apic_timer_interrupt
> 774      198567         0.3722  95.4801    irq_entries_start
> 450      199017         0.2164  95.6964    timer_stats_update_stats
> 404      199421         0.1943  95.8907    scheduler_tick
> 403      199824         0.1938  96.0845    find_busiest_group
> 336      200160         0.1616  96.2460    local_bh_disable
> 332      200492         0.1596  96.4057    rb_get_reader_page
> 329      200821         0.1582  96.5639    ring_buffer_consume
> 267      201088         0.1284  96.6923    add_timer_randomness

The profile of pktgen will favor the tsc because it spins and looks
at TSC during the spin. Not sure why tg3 driver overhead isn't showing =
up.


> I experiment 0.1% drops around 635085pps 284Mb/sec, on my dev machine
> (using vlan and bonding, bi-directional , output device =3D input dev=
ice)
>=20
> Some notes :
>=20
> - Small packets hit the copybreak (mis)feature (that tg3 and other dr=
ivers use),
>  and we know this slow down forwarding. No real differences on small
> packets anyway since we need to read packet to process it (one cache =
line)

Good point: we disable copybreak on some devices (with modprobe options=
) in
the Vyatta distro.
=20
> - neigh_resolve_output() has a cost  because
> of atomic ops of read_lock_bh(&neigh->lock)/read_unlock_bh(&neigh->lo=
ck)
> This might be a candidate for RCU conversion ?

yes

> - ip_rt_send_redirect() is quite expensive, even if send_redirect is =
set to 0, because
> of in_dev_get()/in_dev_put() (two atomic ops that could be avoided : =
I submitted a patch)
>=20


--=20
