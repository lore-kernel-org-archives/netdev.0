From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: udp ping pong measurements from 2.6.22 to .30 with various cpu
 affinities
Date: Thu, 23 Apr 2009 19:04:04 +0200
Message-ID: <49F09F84.10108@cosmosbay.com>
References: <alpine.DEB.1.10.0904221604480.18138@qirst.com> <49EF85E3.8060703@cosmosbay.com> <alpine.DEB.1.10.0904221700030.32682@qirst.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Michael Chan <mchan@broadcom.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	netdev@vger.kernel.org
To: Christoph Lameter <cl@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:39435 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752547AbZDWRE5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2009 13:04:57 -0400
In-Reply-To: <alpine.DEB.1.10.0904221700030.32682@qirst.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Christoph Lameter a =E9crit :
> On Wed, 22 Apr 2009, Eric Dumazet wrote:
>=20
>> Check /proc/cpuinfo, and check it doesnt change between kernel versi=
on.
>=20
> Hmmm.... It does not since it depends on the way that the machine is
> configured by the firmware.
>=20
>>> Results follow (a nice diagram is available from
>>> http://gentwo.org/results/udpping-tests-2.pdf
>> Nice graphs, but lack of documentation of test conditions.
>=20
> What would you like to know?

=46or example, "cat /proc/cpuinfo", just to be sure you did not invert =
cpus,
since your results are not that logical.

"size vmlinux-2.6.2[2-9] vmlinux-2.6.30" to check how kernel text size =
increase.
We add new features, security knobs, fixes, ... and this probably incre=
ase number
of instructions taken in a particular workload, who knows ?

What was the size of packets used on this last test ?

iptables active or not ? conntrack ?

Overall, many unknown factors that mean we have to guess what really
is happening.

>=20
>> We already pointed it was probably scheduling. Since ICMP pings dont=
 use
>> processes and no regression here. Patching kernel to implement udppi=
ng
>> at softirq level should be quite easy if you really want to check UD=
P stack.
>>
>> Last network improvements focused on scalability more than latencies=
=2E
>> (multi-flows, not single flow !)
>=20
> Latencies have priority here. Multi-flows are secondary.

Amen :)

>=20
> So I guess this means that you are okay with the network stacks laten=
cy
> creep? Even if its only 1.5usec: In practice you tune the NIC to perf=
orm
> much better and this is a latency increase likely occurring in every
> packet transmission.

You keep mentioning "network latency" increases, while your test obviou=
sly
stress both network stack, scheduler, nic driver, memory allocator,=20
time infrastructure, and many kernel services.

1.5 us is about 4500 cycles, -> ~1000 instructions or so, not counting
hardware issues. Thats would not be a surprise given vmlinux text size.

number of cycles per network udpping round-trip can also be estimated w=
ith oprofile
(one NMI every 10000 CPU_CLK_UNHALTED events)

<target># egrep NMI|eth1 /proc/interrupts
 34:    6371754          0          0          0          0          0 =
         0          0   PCI-MSI-edge      eth1
NMI:    8831219     141645      96321     113255      26232      44575 =
     64762      23292   Non-maskable interrupts

<source># udpping -n 100000 192.168.20.110
udp ping 0.0.0.0:9001 -> 192.168.20.110:9000 100000 samples ....
10286138.24us (93.16us/102.86us/10896.49us)

<target># egrep "Non-maskable interrupts|eth1" /proc/interrupts
 34:    6581203          0          0          0          0          0 =
         0          0   PCI-MSI-edge      eth1
NMI:    9167306     150313      97909     119027      31965      46523 =
     68006      25070   Non-maskable interrupts

delta of eth1 irq =3D 6581203 - 6371754 =3D 209449   (2*100000 + residu=
al trafic on this host)
and delta of NMI on CPU0 =3D 336087

-> 336087*10000 CPU_CLK_UNHALTED / 100000 packets

-> 33608 cycles per packet (only on ring 0 : kernel)
Shouldnt it be about 10 us ?

BTW on my machines, latest linux-2.6.git, with bnx2.msi_disabled=3D1, I=
 have :

# udpping -l 40 -n 100000 192.168.20.110
udp ping 0.0.0.0:9001 -> 192.168.20.110:9000 100000 samples ...
7891442.22us (72.22us/78.91us/501.14us)

with bnx2.msi_disable=3D0 :
# udpping -l 40 -n 100000 192.168.20.110
udp ping 0.0.0.0:9001 -> 192.168.20.110:9000 100000 samples ....
7644318.91us (66.90us/76.44us/4036.34us)


So its quite a bit less than your numbers. (and I do use netfiler, bond=
ing, vlan...)

# opreport -la vmlinux-2.6.30-rc3 | head -n 50
CPU: Core 2, speed 3000.36 MHz (estimated)
Counted CPU_CLK_UNHALTED events (Clock cycles when not halted) with a u=
nit mask of 0x00 (Unhalted core cycles) count 100000
samples  cum. samples  %        cum. %     symbol name
294498   294498        18.5543  18.5543    mwait_idle
63149    357647         3.9786  22.5329    __schedule
50071    407718         3.1546  25.6875    irq_entries_start
49798    457516         3.1374  28.8249    bnx2_poll_work
38037    495553         2.3964  31.2214    apic_timer_interrupt
36896    532449         2.3246  33.5459    sched_clock_cpu
27671    560120         1.7434  35.2893    find_busiest_group
25694    585814         1.6188  36.9081    bnx2_start_xmit
25516    611330         1.6076  38.5157    ipt_do_table
24312    635642         1.5317  40.0474    scheduler_tick
22728    658370         1.4319  41.4794    __switch_to
21672    680042         1.3654  42.8448    bnx2_msi
20957    700999         1.3204  44.1651    native_sched_clock
20156    721155         1.2699  45.4350    read_tsc
18813    739968         1.1853  46.6203    handle_edge_irq
17396    757364         1.0960  47.7163    __skb_recv_datagram
15010    772374         0.9457  48.6620    copy_to_user
14954    787328         0.9421  49.6041    udp_recvmsg
14557    801885         0.9171  50.5213    dev_queue_xmit
13727    815612         0.8648  51.3861    udp_sendmsg
12849    828461         0.8095  52.1956    cpu_idle
12632    841093         0.7959  52.9915    dequeue_task_fair
12145    853238         0.7652  53.7567    __alloc_skb
12135    865373         0.7645  54.5212    __qdisc_run
11528    876901         0.7263  55.2475    ip_append_data
10847    887748         0.6834  55.9309    getnstimeofday
10733    898481         0.6762  56.6071    netif_receive_skb
10598    909079         0.6677  57.2748    sysenter_past_esp
10557    919636         0.6651  57.9399    prepare_to_wait_exclusive
10162    929798         0.6402  58.5802    finish_task_switch
10120    939918         0.6376  59.2178    __do_softirq
9778     949696         0.6160  59.8338    ip_push_pending_frames
9594     959290         0.6045  60.4383    hrtimer_interrupt
9199     968489         0.5796  61.0178    csum_partial_copy_generic
9181     977670         0.5784  61.5963    copy_from_user
8641     986311         0.5444  62.1407    ktime_get_ts
8513     994824         0.5363  62.6770    __udp4_lib_rcv
8479     1003303        0.5342  63.2112    tick_sched_timer
8445     1011748        0.5321  63.7433    tick_check_oneshot_broadcast
8319     1020067        0.5241  64.2674    ip_rcv
8267     1028334        0.5208  64.7882    enqueue_task_fair
8010     1036344        0.5047  65.2929    rb_erase
7937     1044281        0.5001  65.7930    kfree
7923     1052204        0.4992  66.2921    ktime_get
7891     1060095        0.4972  66.7893    bnx2_poll
7702     1067797        0.4853  67.2745    update_curr
7629     1075426        0.4807  67.7552    try_to_wake_up



opannotate extracts :

c0202f40 <irq_entries_start>: /* irq_entries_start total:  55704  3.146=
7 */
=2E..
 55361  3.1273 :c0203000:       push   $0x35
   251  0.0142 :c0203002:       jmp    c020301a <irq_entries_start+0xda=
>
=2E..
    80  0.0045 :c020301a:       jmp    c0203340 <common_interrupt>

Using NO_HZ mode gives higher latencies

[root@svivoipvnx002 ~]# udpping -n 1000000 192.168.20.110
udp ping 0.0.0.0:9001 -> 192.168.20.110:9000 1000000 samples ....
101270858.22us (88.74us/101.27us/18833.35us)

and in this NO_HZ case, 'network part' is obviously not the more consum=
ing area



Using opcontrol -p=3Dcpu to separate events for each cpu, and giving he=
re CPU0 only events :

CPU: Core 2, speed 3000.03 MHz (estimated)
Counted CPU_CLK_UNHALTED events (Clock cycles when not halted) with a u=
nit mask of 0x00 (Unhalted core cycles) count 10000
Samples on CPU 0

samples  cum. samples  %        cum. %     symbol name
34593    34593          7.3643   7.3643    mwait_idle
21077    55670          4.4870  11.8513    __schedule
17648    73318          3.7570  15.6083    irq_entries_start
14354    87672          3.0557  18.6640    bnx2_poll_work
13873    101545         2.9533  21.6174    getnstimeofday
12146    113691         2.5857  24.2031    rb_get_reader_page
11810    125501         2.5142  26.7172    get_next_timer_interrupt
11062    136563         2.3549  29.0722    copy_to_user             (ud=
pping recvfrom())
9980     146543         2.1246  31.1968    __switch_to
9011     155554         1.9183  33.1151    sched_clock_cpu
8081     163635         1.7203  34.8354    ring_buffer_consume    (opro=
file)
8045     171680         1.7127  36.5480    read_tsc
6717     178397         1.4299  37.9780    tick_nohz_stop_sched_tick
6696     185093         1.4255  39.4035    udp_recvmsg
6679     191772         1.4219  40.8253    __skb_recv_datagram
6322     198094         1.3459  42.1712    bnx2_msi
5821     203915         1.2392  43.4104    native_sched_clock
5269     209184         1.1217  44.5321    udp_sendmsg
4584     213768         0.9759  45.5079    dev_queue_xmit
3918     217686         0.8341  46.3420    copy_from_user
3887     221573         0.8275  47.1695    ip_append_data
3838     225411         0.8171  47.9865    sched_clock_tick
3806     229217         0.8102  48.7968    __alloc_skb
3680     232897         0.7834  49.5802    dequeue_task_fair
3635     236532         0.7738  50.3540    rb_erase
3330     239862         0.7089  51.0629    ipt_do_table
3300     243162         0.7025  51.7655    pick_next_task_fair
3259     246421         0.6938  52.4592    __hrtimer_start_range_ns
3164     249585         0.6736  53.1328    tick_check_idle
3107     252692         0.6614  53.7942    bnx2_start_xmit
3088     255780         0.6574  54.4516    prepare_to_wait_exclusive
3046     258826         0.6484  55.1001    sysenter_past_esp
2940     261766         0.6259  55.7260    finish_task_switch
2903     264669         0.6180  56.3440    handle_edge_irq
2848     267517         0.6063  56.9503    netif_receive_skb
2747     270264         0.5848  57.5351    __qdisc_run
2714     272978         0.5778  58.1128    rb_advance_reader
2649     275627         0.5639  58.6768    update_curr
2481     278108         0.5282  59.2049    sys_socketcall
2467     280575         0.5252  59.7301    ktime_get
2396     282971         0.5101  60.2402    kfree
2372     285343         0.5050  60.7451    enqueue_task_fair

If using INST_RETIRED_ANY_P (number of instructions retired) oprofiling=
 :

CPU: Core 2, speed 3000.03 MHz (estimated)
Counted INST_RETIRED_ANY_P events (number of instructions retired) with=
 a unit mask of 0x00 (No unit mask) count 10000
Samples on CPU 0
samples  cum. samples  %        cum. %     symbol name
45654    45654         12.6972  12.6972    get_next_timer_interrupt  (!=
!!)
14583    60237          4.0558  16.7530    ipt_do_table
11819    72056          3.2871  20.0400    getnstimeofday
9096     81152          2.5298  22.5698    sched_clock_cpu
7534     88686          2.0953  24.6651    bnx2_poll_work
7163     95849          1.9922  26.6573    ring_buffer_consume
7089     102938         1.9716  28.6289    read_tsc
7006     109944         1.9485  30.5774    __schedule
6012     115956         1.6720  32.2494    csum_partial_copy_generic
5870     121826         1.6326  33.8820    rb_get_reader_page
5718     127544         1.5903  35.4722    tick_nohz_stop_sched_tick
5373     132917         1.4943  36.9666    ktime_get
5003     137920         1.3914  38.3580    dev_queue_xmit
4402     142322         1.2243  39.5823    set_normalized_timespec
4332     146654         1.2048  40.7871    clockevents_program_event
4263     150917         1.1856  41.9727    udp_sendmsg
4175     155092         1.1611  43.1338    copy_to_user
4113     159205         1.1439  44.2777    native_sched_clock
3920     163125         1.0902  45.3679    ip_append_data
3710     166835         1.0318  46.3998    tick_check_idle
3541     170376         0.9848  47.3846    handle_edge_irq
3335     173711         0.9275  48.3121    __hrtimer_start_range_ns
3319     177030         0.9231  49.2352    sched_clock_tick
3296     180326         0.9167  50.1519    nf_iterate
3225     183551         0.8969  51.0488    ktime_get_ts
3041     186592         0.8458  51.8945    rb_event_length
2954     189546         0.8216  52.7161    __qdisc_run
2840     192386         0.7899  53.5060    udp_recvmsg
2838     195224         0.7893  54.2952    copy_from_user
2780     198004         0.7732  55.0684    bnx2_start_xmit
2778     200782         0.7726  55.8410    ip_push_pending_frames
2672     203454         0.7431  56.5842    __switch_to
2423     205877         0.6739  57.2580    native_apic_mem_write
2349     208226         0.6533  57.9113    __do_softirq
2344     210570         0.6519  58.5632    net_rx_action
2309     212879         0.6422  59.2054    kfree
2226     215105         0.6191  59.8245    udp_push_pending_frames
2212     217317         0.6152  60.4397    __ip_route_output_key
2081     219398         0.5788  61.0185    __kmalloc_track_caller
2071     221469         0.5760  61.5944    dequeue_task_fair
2068     223537         0.5751  62.1696    ip_finish_output
2044     225581         0.5685  62.7381    __alloc_skb

I believe all this *time* services seem really expensive.

