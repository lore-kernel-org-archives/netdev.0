From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Kernel forwarding performance test regressions
Date: Tue, 25 Aug 2009 18:25:31 +0200
Message-ID: <4A94107B.2070402@gmail.com>
References: <20090819110010.53b630cd@nehalam>	<4A93B34E.1040100@gmail.com> <20090825090459.3a821298@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Robert Olsson <robert.olsson@its.uu.se>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:32998 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751690AbZHYQZe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2009 12:25:34 -0400
In-Reply-To: <20090825090459.3a821298@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger a =C3=A9crit :
> On Tue, 25 Aug 2009 11:47:58 +0200
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> Thats strange, because at Giga flood level, we should be on NAPI mod=
e,
>> ksoftirqd using 100% of one cpu. SMP affinities should not matter at=
 all...
>=20
> The transmit completions are still kicking off some interrupts.

Ah, yes, in my case, as I use same device for transmit, I had no addtio=
nal interrupts

>=20
>>>   * unidirectional numbers are 2X the bidirectional numbers:
>>>     2.6.26 goes from 20% to 40%
>>>
>>>   * this is single stream (doesn't help/use multiqueue)
>>>
>>>   * system loads iptables but does not use it, so each packet
>>>     sees the overhead of null rules.
>>>
>>> So kernel 2.6.29 had an observable dip in performance
>>> which seems to be mostly recovered in 2.6.30.
>>>
>>> These are from our QA, not me so please don't ask me for
>>> "please rerun with XX enabled", go run the same test
>>> yourself with pktgen.
>>>
>> Unfortunatly I cannot reach line-rate with pktgen and small packets.
>> (Limit ~1012333pps 485Mb/sec on my test machine, 3GHz E5450 cpu)
>=20
> Things that help:
>   * make sure flow control is off
it is
>   * increase transmit ring size
already at max 511 value
>   * sometimes tx IRQ coalescing
yep
> Using an old SMP Opteron box for pktgen right now.
>=20
>> It seems timestamping is too expensive on pktgen, even for "delay 0"=
=20
>> and only one device setup (next_to_run() doesnt have to select the '=
best' device)
>> We probably can improve pktgen a litle bit, or use a faster timestam=
ping...
>=20
> I have a patch that might help, I haven't tested it or used it.
> It converts the pktgen calls from gettimeofday to using sched_clock()
> this saves the math overhead since pktgen only cares about comparison
> and delta's. It also prevents problems with kernel deciding clock
> source is not stable.  Still need to test and review this to make
> sure pktgen only uses value on same cpu.

Well, I tried using two adapters and got more bandwidth from same CPU0,=
 so it seems
tg3 on my machine is not able to go past 1012333pps (and BTW, bnx2 is m=
uch
 slower, I dont know why...)

Configuring /proc/net/pktgen/eth3  (tg3)
Configuring /proc/net/pktgen/eth1  (bnx2)
Running... ctrl^C to stop
Done
Params: count 100000  min_pkt_size: 56  max_pkt_size: 56
     frags: 0  delay: 0  clone_skb: 1000  ifname: eth3
     flows: 0 flowlen: 0
     queue_map_min: 0  queue_map_max: 0
     dst_min: 192.168.20.120  dst_max: 192.168.20.121
     src_min:   src_max:
     src_mac: 00:1e:0b:92:78:51 dst_mac: 00:1f:29:6b:86:15
     udp_src_min: 9  udp_src_max: 9  udp_dst_min: 9  udp_dst_max: 9
     src_mac_count: 0  dst_mac_count: 0
     Flags:
Current:
     pkts-sofar: 100000  errors: 0
     started: 1251217024743446us  stopped: 1251217024842450us idle: 253=
us
     seq_num: 100001  cur_dst_mac_offset: 0  cur_src_mac_offset: 0
     cur_saddr: 0x200a8c0  cur_daddr: 0x7814a8c0
     cur_udp_dst: 9  cur_udp_src: 9
     cur_queue_map: 0
     flows: 0
Result: OK: 99004(c98751+d253) usec, 100000 (56byte,0frags)
  1010060pps 452Mb/sec (452506880bps) errors: 0
Params: count 100000  min_pkt_size: 56  max_pkt_size: 56
     frags: 0  delay: 0  clone_skb: 1000  ifname: eth1
     flows: 0 flowlen: 0
     queue_map_min: 0  queue_map_max: 0
     dst_min: 192.168.20.120  dst_max: 192.168.20.121
     src_min:   src_max:
     src_mac: 00:1e:0b:ec:d3:d2 dst_mac: 00:1f:29:6b:86:15
     udp_src_min: 9  udp_src_max: 9  udp_dst_min: 9  udp_dst_max: 9
     src_mac_count: 0  dst_mac_count: 0
     Flags:
Current:
     pkts-sofar: 100000  errors: 0
     started: 1251217024743445us  stopped: 1251217024888749us idle: 329=
us
     seq_num: 100001  cur_dst_mac_offset: 0  cur_src_mac_offset: 0
     cur_saddr: 0x0  cur_daddr: 0x7814a8c0
     cur_udp_dst: 9  cur_udp_src: 9
     cur_queue_map: 0
     flows: 0
Result: OK: 145304(c144975+d329) usec, 100000 (56byte,0frags)
  688212pps 308Mb/sec (308318976bps) errors: 0

07:00.0 Ethernet controller: Broadcom Corporation NetXtreme II BCM5708S=
 Gigabit Ethernet (rev 12)
        Subsystem: Hewlett-Packard Company NC373i Integrated Multifunct=
ion Gigabit Server Adapter
        Flags: bus master, 66MHz, medium devsel, latency 64, IRQ 34
        Memory at fa000000 (64-bit, non-prefetchable) [size=3D32M]
        [virtual] Expansion ROM at d0000000 [disabled] [size=3D16K]
        Capabilities: [40] PCI-X non-bridge device
        Capabilities: [48] Power Management version 2
        Capabilities: [50] Vital Product Data
        Capabilities: [58] MSI: Enable+ Count=3D1/1 Maskable- 64bit+
        Kernel driver in use: bnx2 (eth1)

14:04.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5715S Gi=
gabit Ethernet (rev a3)
        Subsystem: Hewlett-Packard Company NC326m PCIe Dual Port Adapte=
r
        Flags: bus master, 66MHz, medium devsel, latency 64, IRQ 35
        Memory at fdff0000 (64-bit, non-prefetchable) [size=3D64K]
        Memory at fdfe0000 (64-bit, non-prefetchable) [size=3D64K]
        [virtual] Expansion ROM at d0200000 [disabled] [size=3D128K]
        Capabilities: [40] PCI-X non-bridge device
        Capabilities: [48] Power Management version 2
        Capabilities: [50] Vital Product Data
        Capabilities: [58] MSI: Enable+ Count=3D1/8 Maskable- 64bit+
        Kernel driver in use: tg3
        Kernel modules: tg3 (eth2, not used in my pktgen setup)



14:04.1 Ethernet controller: Broadcom Corporation NetXtreme BCM5715S Gi=
gabit Ethernet (rev a3)
        Subsystem: Hewlett-Packard Company NC326m PCIe Dual Port Adapte=
r
        Flags: bus master, 66MHz, medium devsel, latency 64, IRQ 37
        Memory at fdfd0000 (64-bit, non-prefetchable) [size=3D64K]
        Memory at fdfc0000 (64-bit, non-prefetchable) [size=3D64K]
        [virtual] Expansion ROM at d0220000 [disabled] [size=3D128K]
        Capabilities: [40] PCI-X non-bridge device
        Capabilities: [48] Power Management version 2
        Capabilities: [50] Vital Product Data
        Capabilities: [58] MSI: Enable+ Count=3D1/8 Maskable- 64bit+
        Kernel driver in use: tg3
        Kernel modules: tg3 (eth3)

>=20
>> oprofile results on pktgen machine (linux 2.6.30.5) :
>> CPU: Core 2, speed 3000.08 MHz (estimated)
>> Counted CPU_CLK_UNHALTED events (Clock cycles when not halted) with =
a unit mask of 0x00 (Unhalted core cycles) count 100000
>> samples  cum. samples  %        cum. %     symbol name
>> 58137    58137         27.9549  27.9549    read_tsc
>> 51487    109624        24.7573  52.7122    pktgen_thread_worker
>> 33079    142703        15.9059  68.6181    getnstimeofday
>> 15694    158397         7.5464  76.1645    getCurUs
>> 11806    170203         5.6769  81.8413    do_gettimeofday
>> 5852     176055         2.8139  84.6553    kthread_should_stop
>> 5244     181299         2.5216  87.1768    kthread
>> 4181     185480         2.0104  89.1872    mwait_idle
>> 3837     189317         1.8450  91.0322    consume_skb
>> 2217     191534         1.0660  92.0983    skb_dma_unmap
>> 1599     193133         0.7689  92.8671    skb_dma_map
>> 1389     194522         0.6679  93.5350    local_bh_enable_ip
>> 1350     195872         0.6491  94.1842    nommu_map_page
>> 1086     196958         0.5222  94.7064    mix_pool_bytes_extract
>> 835      197793         0.4015  95.1079    apic_timer_interrupt
>> 774      198567         0.3722  95.4801    irq_entries_start
>> 450      199017         0.2164  95.6964    timer_stats_update_stats
>> 404      199421         0.1943  95.8907    scheduler_tick
>> 403      199824         0.1938  96.0845    find_busiest_group
>> 336      200160         0.1616  96.2460    local_bh_disable
>> 332      200492         0.1596  96.4057    rb_get_reader_page
>> 329      200821         0.1582  96.5639    ring_buffer_consume
>> 267      201088         0.1284  96.6923    add_timer_randomness
>=20
> The profile of pktgen will favor the tsc because it spins and looks
> at TSC during the spin. Not sure why tg3 driver overhead isn't showin=
g up.

Sorry, for a strange reason, I have to load tg3 as a module (all other =
things are in static in vmlinux)
