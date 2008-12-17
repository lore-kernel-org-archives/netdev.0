From: Rick Jones <rick.jones2@hp.com>
Subject: Soft Lockups on 2.6.28-rc8 under netperf bulk receive workload
Date: Tue, 16 Dec 2008 17:31:26 -0800
Message-ID: <4948566E.1050309@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Network Development list <netdev@vger.kernel.org>,
	"linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:39163 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751190AbYLQBb3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2008 20:31:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have a 32-core, 1.6 GHz Montvale hp rx8640 with 128 GB of RAM (64x2GB 
DIMMS) configured as ILM (interleave memory on a cacheline boundary) 
rather than cell local memory.  HyperThreading is disabled.  The system 
has four AD386A PCIe 10G Ethernet interfaces each in a separate PCIe x8 
slot.  The AD386A is a single-port card based on the Chelsio T3C chip. 
The interrupts of the 8 queues on each card are spread across the 32 
cores - 8 queues of card one to cores 0-7 one to one, those of card two 
to cores 8-15, etc etc.  The NICs are in turn connected to an HP 
ProCurve 5406 with a number of 10G modules, which then connect to four, 
4P/16C, 2.3 GHz Opteron 8356 HP DL585 G5's each with two AD386As also in 
x8 slots or better.  I configure four subnets - 192.168.[2345]/24, set 
arp_ignore to one (since they are all carried on the same switch) and 
all five systems are in all four subnets (two IP's per interface on the 
DL585s.

The MTU on all interfaces is 1500 bytes.  cxgb3 driver settings are 
default. net.core.[rw]mem_max is set to 4194304 and netperf is making 
explicit setsockopt calls asking for 1MB SO_[SND|RCV]BUF values.

I then launch 64 concurrent netperf TCP_MAERTS tests (actually the 
"omni" test equivalent which does the same thing) from the rx8640.  This 
causes each of the DL585 G5's to start sending data to the rx8640.

I was first running a not-yet-released distro based on an old 2.6 kernel 
and the 1.1.022 out-of-tree cxgb3 driver and saw soft lockups.  I then 
moved on to a Debian Lenny 2.6.26 kernel, still with the same 
out-of-tree driver and saw soft lockups.

Presently, the system is running a 2.6.28-rc8 kernel from kernel.org 
with the in-tree cxgb3 driver and I still see soft lockups which look like:

[ 1564.448850] BUG: soft lockup - CPU#31 stuck for 61s! [netperf:4094]
[ 1564.449062] Modules linked in: ipv6 loop evdev ext3 jbd mbcache 
dm_mirror dm_region_hash dm_log dm_snapshot dm_mod sg sr_mod cdrom 
sd_mod mptspi mptscsih mptbase cxgb3 scsi_transport_spi e1000 inet_lro 
tg3 scsi_mod libphy
[ 1564.449828] Modules linked in: ipv6 loop evdev ext3 jbd mbcache 
dm_mirror dm_region_hash dm_log dm_snapshot dm_mod sg sr_mod cdrom 
sd_mod mptspi mptscsih mptbase cxgb3 scsi_transport_spi e1000 inet_lro 
tg3 scsi_mod libphy
[ 1564.450575]
[ 1564.450576] Pid: 4094, CPU 31, comm:              netperf
[ 1564.450803] psr : 0000121008026018 ifs : 800000000000040b ip  : 
[<a000000100190121>]    Not tainted (2.6.28-rc8-raj)
[ 1564.451156] ip is at kmem_cache_alloc_node+0x201/0x280
[ 1564.451322] unat: 0000000000000000 pfs : 000000000000040b rsc : 
0000000000000003
[ 1564.451559] rnat: 0000000000003200 bsps: e000001e4f4a8008 pr  : 
a6144659159a6665
[ 1564.451796] ldrs: 0000000000000000 ccv : 0000000000000000 fpsr: 
0009804c8a70033f
[ 1564.452033] csd : 0000000000000000 ssd : 0000000000000000
[ 1564.452208] b0  : a0000001001900f0 b6  : a00000010060f240 b7  : 
a000000100494f40
[ 1564.452445] f6  : 1003e0000000000002c00 f7  : 1003e000000000000002c
[ 1564.452646] f8  : 1003e0000000000000100 f9  : 1003efffffffffffffa58
[ 1564.452848] f10 : 1003e0000000000000015 f11 : 1003ecf3cf3cf3cf3cf3d
[ 1564.453050] r1  : a000000100b377d0 r2  : 0000000000000691 r3  : 
0000000000000004
[ 1564.453287] r8  : e000001e4d8d2d80 r9  : 000000000000003e r10 : 
e00000408c243718
[ 1564.454333] r11 : 0000000000041200 r12 : e000001f803479b0 r13 : 
e000001f80340000
[ 1564.454570] r14 : 0000000000000000 r15 : e00000408c243508 r16 : 
0000000000002c00
[ 1564.454807] r17 : 0000000000002c00 r18 : e000001e8db6c000 r19 : 
e00000408d248490
[ 1564.455044] r20 : e000001e4d8d0000 r21 : e000001e4d8d0008 r22 : 
e000001e4d8d0180
[ 1564.455281] r23 : 0000000000000100 r24 : e000001e8db6c008 r25 : 
0000000000100100
[ 1564.455519] r26 : 0000000000004000 r27 : 0000000000004000 r28 : 
e000001e06408000
[ 1564.455755] r29 : 0000000000000bd2 r30 : e00000408d2484b0 r31 : 
0000000000000bd3
[ 1564.456002]
[ 1564.456003] Call Trace:
[ 1564.456148]  [<a000000100014c30>] show_stack+0x50/0xa0
[ 1564.456149]                                 sp=e000001f80347610 
bsp=e000001f80341bc8
[ 1564.456564]  [<a0000001000154a0>] show_regs+0x820/0x860
[ 1564.456566]                                 sp=e000001f803477e0 
bsp=e000001f80341b70
[ 1564.515003]  [<a000000100119710>] softlockup_tick+0x350/0x400
[ 1564.515004]                                 sp=e000001f803477e0 
bsp=e000001f80341b28
[ 1564.515445]  [<a0000001000ad040>] run_local_timers+0x40/0x60
[ 1564.515447]                                 sp=e000001f803477e0 
bsp=e000001f80341b10
[ 1564.516443]  [<a0000001000ad140>] update_process_times+0x40/0xc0
[ 1564.516445]                                 sp=e000001f803477e0 
bsp=e000001f80341ae0
[ 1564.516891]  [<a000000100039a60>] timer_interrupt+0x1c0/0x3e0
[ 1564.516892]                                 sp=e000001f803477e0 
bsp=e000001f80341a78
[ 1564.517325]  [<a00000010011a340>] handle_IRQ_event+0x80/0x120
[ 1564.517326]                                 sp=e000001f803477e0 
bsp=e000001f80341a40
[ 1564.517759]  [<a00000010011a560>] __do_IRQ+0x180/0x4c0
[ 1564.517760]                                 sp=e000001f803477e0 
bsp=e000001f803419d0
[ 1564.577929]  [<a000000100011130>] ia64_handle_irq+0x290/0x340
[ 1564.577931]                                 sp=e000001f803477e0 
bsp=e000001f80341958
[ 1564.578365]  [<a00000010000bf40>] ia64_native_leave_kernel+0x0/0x270
[ 1564.578366]                                 sp=e000001f803477e0 
bsp=e000001f80341958
[ 1564.579299]  [<a000000100190120>] kmem_cache_alloc_node+0x200/0x280
[ 1564.579300]                                 sp=e000001f803479b0 
bsp=e000001f80341900
[ 1564.579863]  [<a0000001004cd210>] __alloc_skb+0x50/0x220
[ 1564.579864]                                 sp=e000001f803479b0 
bsp=e000001f803418b0
[ 1564.581319]  [<a00000020ecc9850>] process_responses+0xc50/0x2080 [cxgb3]
[ 1564.581321]                                 sp=e000001f803479b0 
bsp=e000001f80341610
[ 1564.581793]  [<a00000020eccacc0>] napi_rx_handler+0x40/0x200 [cxgb3]
[ 1564.581794]                                 sp=e000001f803479f0 
bsp=e000001f803415d0
[ 1564.582250]  [<a0000001004d76f0>] net_rx_action+0x210/0x560
[ 1564.582251]                                 sp=e000001f803479f0 
bsp=e000001f80341538
[ 1564.642479]  [<a0000001000a1760>] __do_softirq+0x120/0x2e0
[ 1564.642481]                                 sp=e000001f803479f0 
bsp=e000001f80341498
[ 1564.643364]  [<a0000001000a1990>] do_softirq+0x70/0xc0
[ 1564.643366]                                 sp=e000001f803479f0 
bsp=e000001f80341438
[ 1564.643780]  [<a0000001000a1c50>] irq_exit+0x70/0xa0
[ 1564.643781]                                 sp=e000001f803479f0 
bsp=e000001f80341420
[ 1564.644190]  [<a0000001000111a0>] ia64_handle_irq+0x300/0x340
[ 1564.644191]                                 sp=e000001f803479f0 
bsp=e000001f803413a0
[ 1564.644623]  [<a00000010000bf40>] ia64_native_leave_kernel+0x0/0x270
[ 1564.644625]                                 sp=e000001f803479f0 
bsp=e000001f803413a0
[ 1564.645077]  [<a000000100192720>] kmem_cache_free+0x580/0x5c0
[ 1564.645079]                                 sp=e000001f80347bc0 
bsp=e000001f80341328
[ 1564.703103]  [<a0000001004cb0a0>] __kfree_skb+0x180/0x1a0
[ 1564.703104]                                 sp=e000001f80347bd0 
bsp=e000001f80341308
[ 1564.703537]  [<a000000100556150>] tcp_recvmsg+0xcd0/0x1180
[ 1564.703538]                                 sp=e000001f80347bd0 
bsp=e000001f80341180
[ 1564.704667]  [<a0000001004beab0>] sock_common_recvmsg+0x90/0xe0
[ 1564.704668]                                 sp=e000001f80347be0 
bsp=e000001f80341140
[ 1564.705112]  [<a0000001004bb090>] sock_recvmsg+0x1d0/0x220
[ 1564.705114]                                 sp=e000001f80347bf0 
bsp=e000001f80341108
[ 1564.705538]  [<a0000001004bd590>] sys_recvfrom+0x110/0x220
[ 1564.705540]                                 sp=e000001f80347d60 
bsp=e000001f80341088
[ 1564.705965]  [<a0000001004bd6e0>] sys_recv+0x40/0x60
[ 1564.705966]                                 sp=e000001f80347e30 
bsp=e000001f80341030
[ 1564.706376]  [<a00000010000bda0>] ia64_ret_from_syscall+0x0/0x20
[ 1564.706377]                                 sp=e000001f80347e30 
bsp=e000001f80341030
[ 1564.755966]  [<a000000000010720>] 
__start_ivt_text+0xffffffff00010720/0x400
[ 1564.755967]                                 sp=e000001f80348000 
bsp=e000001f80341030

I have also taken Caliper (http://www.hp.com/go/caliper - uses the 
perfmon interface present in ia64 kernels) cycles and scgprof profiles.

The cycles profile uses the Itanium PMU to gather samples via the PMU so 
interrupts on/off is a don't care.  The profile for one of the netperf 
processes looks like this:

----------------------------------------------------
Run Summary (50 of 50 for netperf, Collection Run 1)
----------------------------------------------------

Target Application
   Program:            /opt/netperf2/bin/netperf
   Invocation:         netperf -P 0 -t omni -c -C -H 192.168.5.3 -l 30 
-i 30 30 -- -o tmpfoo -H 192.168.5.3 -s 1M -S 1M -M  64K -u 
868b6602-cbd0-11dd-aa0c-45ce53e6b179
   Process ID:         4022 (unknown start)
   Start time:         12:20:36 AM
   End time:           12:27:16 AM
   Termination Status: n/a
   Last modified:      December 15, 2008 at 08:15 PM
   Memory model:       LP64
   Hyperthreading:     disabled in firmware

Sampling Specification
   Number of samples: 478
   Data sampled:      ETB

Load Module Summary
---------------------------------------------
% Total
      IP  Cumulat             IP
Samples    % of         Samples
  (ETB)     Total         (ETB)    Load Module
---------------------------------------------
   99.05    99.05        822136    vmlinux
    0.90    99.95          7447    cxgb3.ko
    0.04    99.98           296    libc-2.7.so
    0.01    99.99           108    netperf
    0.00   100.00            30    *kernel gateway*
    0.00   100.00            10    inet_lro.ko
    0.00   100.00             2    ld-2.7.so
    0.00   100.00             1    mptscsih.ko
---------------------------------------------
  100.00   100.00        830030    Total
---------------------------------------------

Function Summary
-----------------------------------------------------------------------
% Total
      IP  Cumulat             IP
Samples    % of         Samples
  (ETB)     Total         (ETB)   Function                          File
-----------------------------------------------------------------------
   75.45    75.45        626273   vmlinux::ia64_spinlock_contention
    4.42    79.87         36683   vmlinux::_spin_lock
    4.08    83.95         33848   vmlinux::free_block
    3.24    87.18         26856   vmlinux::____cache_alloc_node
    2.09    89.27         17334   vmlinux::__copy_user
    1.75    91.03         14554   vmlinux::fallback_alloc
    0.99    92.01          8180   vmlinux::kfree
    0.79    92.80          6540   vmlinux::kmem_cache_free
    0.61    93.41          5026   cxgb3.ko::process_responses
    0.41    93.82          3423   vmlinux::__alloc_skb
    0.36    94.18          2971   vmlinux::skb_pull
    0.26    94.43          2142   vmlinux::dst_release
    0.25    94.68          2034   vmlinux::tcp_v4_do_rcv
    0.24    94.92          2033   vmlinux::tcp_recvmsg
    0.23    95.15          1886   vmlinux::tcp_parse_md5sig_option
    0.22    95.37          1789   vmlinux::tcp_v4_rcv
    0.21    95.57          1729   vmlinux::cache_alloc_refill
    0.20    95.78          1699   vmlinux::ip_route_input
    0.20    95.98          1657   vmlinux::eth_type_trans
    0.20    96.18          1655   vmlinux::tcp_event_data_recv
    0.18    96.36          1476   vmlinux::skb_copy_datagram_iovec
    0.17    96.53          1425   vmlinux::__inet_lookup_established
    0.15    96.67          1217   vmlinux::tcp_rcv_established
    0.14    96.82          1196   cxgb3.ko::refill_fl
    0.13    96.95          1098   vmlinux::netif_receive_skb
    0.13    97.08          1040   vmlinux::cache_grow
    0.12    97.20          1036   cxgb3.ko::t3_eth_xmit
    0.11    97.31           942   vmlinux::memset

(being one of the cobbler's children I don't yet know how to use the 
tools to produce one combined cycles profile across the whole kernel, 
but each netperf looks pretty much like that).

The scgprof profile is a sampled call graph profile.  I believe that it 
will be sensitive to whether interrupts are enabled/disabled and that 
may be why it looks rather different.

All three - cycles, scgprof and dmesg output, along with the config for 
the kernel build can be found under:

ftp://ftp.netperf.org/lockup

At this point I'm open to suggestion for next steps.  My linux kernel 
debugging experience is close to epsilon but I can follow explicit 
direction pretty well.

FWIW an outbound test (from the rx8640 to the dl585's) does not appear 
to generate soft lockup messages.

rick jones
