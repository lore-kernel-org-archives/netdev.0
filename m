From: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Subject: probably serious conntrack/netfilter panic, 4.8.14, timers and intel
 turbo
Date: Sat, 17 Dec 2016 21:48:13 +0200
Message-ID: <9be92e4dc7d83096cbcdaae1a3f77bd3@nuclearcat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        linux-kernel@vger.kernel.org,
        Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I posted recently several netfilter related crashes, didn't got any 
answers, one of them started to happen quite often on loaded NAT 
(17Gbps),
so after trying endless ways to make it stable, i found out that in 
backtrace i can often see timers, and this bug probably appearing on 
older releases,
i've seen such backtrace with timer fired for conntrack on them.
I disabled Intel turbo for cpus on this loaded NAT, and voila, panic 
disappeared for 2nd day!
* by wrmsr -a 0x1a0 0x4000850089
I am not sure timers is the reason, but probably turbo creating some 
condition for bug.



Here is examples of backtrace of last reboots (kernel 4.8.14), and same 
kernel worked perfectly without turbo.
Last one also one crash on 4.8.0 that looks painfully similar, on 
totally different workload, but with conntrack enabled. It happens there 
much less often,
so harder to crash and test by disabling turbo.

[28904.162607] BUG: unable to handle kernel
NULL pointer dereference
at 0000000000000008
[28904.163210] IP:
[<ffffffffa00ab07d>] nf_ct_add_to_dying_list+0x55/0x61 [nf_conntrack]
[28904.163745] PGD 0

[28904.164058] Oops: 0002 [#1] SMP
[28904.164323] Modules linked in:
nf_nat_pptp
nf_nat_proto_gre
xt_TCPMSS
xt_connmark
ipt_MASQUERADE
nf_nat_masquerade_ipv4
xt_nat
xt_rateest
xt_RATEEST
nf_conntrack_pptp
nf_conntrack_proto_gre
xt_CT
xt_set
xt_hl
xt_tcpudp
ip_set_hash_net
ip_set
nfnetlink
iptable_raw
iptable_mangle
iptable_nat
nf_conntrack_ipv4
nf_defrag_ipv4
nf_nat_ipv4
nf_nat
nf_conntrack
iptable_filter
ip_tables
x_tables
netconsole
configfs
8021q
garp
mrp
stp
llc
bonding
ixgbe
dca

[28904.168132] CPU: 27 PID: 0 Comm: swapper/27 Not tainted 
4.8.14-build-0124 #2
[28904.168398] Hardware name: Intel Corporation S2600WTT/S2600WTT, BIOS 
SE5C610.86B.01.01.1008.031920151331 03/19/2015
[28904.168853] task: ffff885fa42e8c40 task.stack: ffff885fa42f0000
[28904.169114] RIP: 0010:[<ffffffffa00ab07d>]
[<ffffffffa00ab07d>] nf_ct_add_to_dying_list+0x55/0x61 [nf_conntrack]
[28904.169643] RSP: 0018:ffff885fbccc3dd8 EFLAGS: 00010246
[28904.169901] RAX: 0000000000000000 RBX: ffff885fbccc0000 RCX: 
ffff885fbccc0010
[28904.170169] RDX: ffff885f87a1c150 RSI: 0000000000000142 RDI: 
ffff885fbccc0000
[28904.170437] RBP: ffff885fbccc3de8 R08: 00000000cbdee177 R09: 
0000000000000100
[28904.170704] R10: ffff885fbccc3dd0 R11: ffffffff820050c0 R12: 
ffff885f87a1c140
[28904.170971] R13: 000000000005d948 R14: 00000000000ea942 R15: 
ffff885f87a1c160
[28904.171237] FS: 0000000000000000(0000) GS:ffff885fbccc0000(0000) 
knlGS:0000000000000000
[28904.171688] CS: 0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[28904.171964] CR2: 0000000000000008 CR3: 000000607f006000 CR4: 
00000000001406e0
[28904.172231] Stack:
[28904.172482] ffff885f87a1c140
ffffffff820a1405
ffff885fbccc3e28
ffffffffa00abb30

[28904.173182] 00000002820a1405
ffff885f87a1c140
ffff885f99a28201
0000000000000000

[28904.173884] 0000000000000000
ffffffff820050c8
ffff885fbccc3e58
ffffffffa00abc62

[28904.174585] Call Trace:
[28904.174835] <IRQ>

[28904.174912] [<ffffffffa00abb30>] nf_ct_delete_from_lists+0xc9/0xf2 
[nf_conntrack]
[28904.175613] [<ffffffffa00abc62>] nf_ct_delete+0x109/0x12c 
[nf_conntrack]
[28904.175894] [<ffffffffa00abc85>] ? nf_ct_delete+0x12c/0x12c 
[nf_conntrack]
[28904.176169] [<ffffffffa00abc92>] death_by_timeout+0xd/0xf 
[nf_conntrack]
[28904.176443] [<ffffffff81109922>] call_timer_fn.isra.5+0x17/0x6b
[28904.176714] [<ffffffff811099e5>] expire_timers+0x6f/0x7e
[28904.176975] [<ffffffff81109add>] run_timer_softirq+0x69/0x8b
[28904.177238] [<ffffffff811141bb>] ? 
clockevents_program_event+0xd0/0xe8
[28904.177504] [<ffffffff810d000c>] __do_softirq+0xbd/0x1aa
[28904.177765] [<ffffffff810d0240>] irq_exit+0x37/0x7c
[28904.178026] [<ffffffff8102c519>] 
smp_trace_apic_timer_interrupt+0x7b/0x88
[28904.178300] [<ffffffff8102c52f>] smp_apic_timer_interrupt+0x9/0xb
[28904.178565] [<ffffffff818f4f1c>] apic_timer_interrupt+0x7c/0x90
[28904.178835] <EOI>

[28904.178907] [<ffffffff8101b929>] ? mwait_idle+0x64/0x7a
[28904.179436] [<ffffffff810e3d8f>] ? 
atomic_notifier_call_chain+0x13/0x15
[28904.179712] [<ffffffff8101bd04>] arch_cpu_idle+0xa/0xc
[28904.179976] [<ffffffff810f7c3d>] default_idle_call+0x27/0x29
[28904.180244] [<ffffffff810f7d5c>] cpu_startup_entry+0x11d/0x1c7
[28904.180508] [<ffffffff8102af13>] start_secondary+0xe8/0xeb
[28904.180767] Code:
80
2f
0b
82
48
89
df
e8
da
90
84
e1
48
8b
43
10
49
8d
54
24
10
48
8d
4b
10
49
89
4c
24
18
a8
01
49
89
44
24
10
48
89
53
10
75
04

89
50
08
c6
03
00
5b
41
5c
5d
c3
48
8b
05
10
be
00
00
89
f6

[28904.185546] RIP
[<ffffffffa00ab07d>] nf_ct_add_to_dying_list+0x55/0x61 [nf_conntrack]
[28904.186065] RSP <ffff885fbccc3dd8>
[28904.186319] CR2: 0000000000000008
[28904.186593] ---[ end trace 35cbc6c885a5c2d8 ]---
[28904.186860] Kernel panic - not syncing: Fatal exception in interrupt
[28904.187155] Kernel Offset: disabled
[28904.187419] Rebooting in 5 seconds..

[28909.193662] ACPI MEMORY or I/O RESET_REG.



[14125.227611] BUG: unable to handle kernel
NULL pointer dereference
at (null)
[14125.228215] IP:
[<ffffffffa00cbd89>] nf_nat_setup_info+0x6d8/0x755 [nf_nat]
[14125.228564] PGD 0

[14125.228882] Oops: 0000 [#1] SMP
[14125.229146] Modules linked in:
nf_nat_pptp
nf_nat_proto_gre
xt_TCPMSS
xt_connmark
ipt_MASQUERADE
nf_nat_masquerade_ipv4
xt_nat
xt_rateest
xt_RATEEST
nf_conntrack_pptp
nf_conntrack_proto_gre
xt_CT
xt_set
xt_hl
xt_tcpudp
ip_set_hash_net
ip_set
nfnetlink
iptable_raw
iptable_mangle
iptable_nat
nf_conntrack_ipv4
nf_defrag_ipv4
nf_nat_ipv4
nf_nat
nf_conntrack
iptable_filter
ip_tables
x_tables
netconsole
configfs
8021q
garp
mrp
stp
llc
bonding
ixgbe
dca

[14125.232998] CPU: 30 PID: 0 Comm: swapper/30 Not tainted 
4.8.14-build-0124 #2
[14125.233274] Hardware name: Intel Corporation S2600WTT/S2600WTT, BIOS 
SE5C610.86B.01.01.1008.031920151331 03/19/2015
[14125.233736] task: ffff885fa5edb100 task.stack: ffff885fa5ef0000
[14125.234009] RIP: 0010:[<ffffffffa00cbd89>]
[<ffffffffa00cbd89>] nf_nat_setup_info+0x6d8/0x755 [nf_nat]
[14125.234540] RSP: 0018:ffff885fbe783920 EFLAGS: 00010202
[14125.234806] RAX: 00000000001461e5 RBX: ffffc90037f28794 RCX: 
000000000000000e
[14125.235075] RDX: 0000000000000000 RSI: ffff881405040218 RDI: 
ffffc90037f28794
[14125.235345] RBP: ffff885fbe7839f8 R08: 000000008b605951 R09: 
0000000000000001
[14125.235615] R10: ffff885f93ecab4e R11: ffff882fa5eb0c20 R12: 
0000000000000000
[14125.235885] R13: ffff885f9f1bedd8 R14: ffff885f9f1bed00 R15: 
ffffc90036f1c000
[14125.236154] FS: 0000000000000000(0000) GS:ffff885fbe780000(0000) 
knlGS:0000000000000000
[14125.236604] CS: 0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[14125.236870] CR2: 0000000000000000 CR3: 0000000002006000 CR4: 
00000000001406e0
[14125.237139] Stack:
[14125.237391] ffff885fbe7839a0
ffffffffa00cb0cd
ffffffffa00ccb90
ffffffff001461e5

[14125.238098] 0000000000000000
ffffffffa00cb01d
000000000a19000a
0000000000000000

[14125.238808] a6c3fbcd0002ad8e
0000000000000000
0011350000000000
00000000015459b9

[14125.239520] Call Trace:
[14125.239776] <IRQ>

[14125.239851] [<ffffffffa00cb0cd>] ? nf_nat_bysource_hash+0xb0/0xb0 
[nf_nat]
[14125.240373] [<ffffffffa00cb01d>] ? __nf_nat_l4proto_find+0x1d/0x1d 
[nf_nat]
[14125.240651] [<ffffffffa012d092>] xt_snat_target_v0+0x65/0x67 [xt_nat]
[14125.240931] [<ffffffffa009f3d3>] ipt_do_table+0x28e/0x5a2 [ip_tables]
[14125.241199] [<ffffffffa009f6cb>] ? ipt_do_table+0x586/0x5a2 
[ip_tables]
[14125.241474] [<ffffffffa0042800>] ? bond_dev_queue_xmit+0x52/0x57 
[bonding]
[14125.241752] [<ffffffffa00e4040>] ? iptable_nat_ipv4_fn+0x12/0x12 
[iptable_nat]
[14125.242210] [<ffffffffa00e405a>] iptable_nat_do_chain+0x1a/0x1c 
[iptable_nat]
[14125.242661] [<ffffffffa00d34e3>] nf_nat_ipv4_fn+0xeb/0x17c 
[nf_nat_ipv4]
[14125.242930] [<ffffffffa00d3618>] nf_nat_ipv4_out+0x35/0x37 
[nf_nat_ipv4]
[14125.243198] [<ffffffffa00e407e>] iptable_nat_ipv4_out+0x10/0x12 
[iptable_nat]
[14125.243655] [<ffffffff818a1985>] nf_iterate+0x41/0x66
[14125.243925] [<ffffffff818a19d5>] nf_hook_slow+0x2b/0x94
[14125.244199] [<ffffffff818ab740>] ip_output+0xa0/0xbd
[14125.244471] [<ffffffff818aad25>] ? ip_fragment.constprop.5+0x77/0x77
[14125.244739] [<ffffffff818a867c>] ip_forward_finish+0x53/0x58
[14125.245007] [<ffffffff818a89b4>] ip_forward+0x333/0x340
[14125.245279] [<ffffffff818a8629>] ? ip_frag_mem+0x3e/0x3e
[14125.245542] [<ffffffff818a7007>] ip_rcv_finish+0x32f/0x33a
[14125.245809] [<ffffffff818a74f2>] ip_rcv+0x320/0x32d
[14125.246078] [<ffffffff818a6cd8>] ? 
ip_local_deliver_finish+0x109/0x109
[14125.246349] [<ffffffff818764bf>] __netif_receive_skb_core+0x623/0x80a
[14125.246629] [<ffffffffa000a201>] ? ixgbe_poll+0x5cf/0x679 [ixgbe]
[14125.246905] [<ffffffff81876f14>] __netif_receive_skb+0x13/0x55
[14125.247178] [<ffffffff81877e6d>] process_backlog+0x8e/0x110
[14125.247443] [<ffffffff81877c69>] net_rx_action+0x107/0x27d
[14125.247709] [<ffffffff810d000c>] __do_softirq+0xbd/0x1aa
[14125.247982] [<ffffffff810d0240>] irq_exit+0x37/0x7c
[14125.248248] [<ffffffff8102a7ac>] 
smp_trace_call_function_single_interrupt+0x2e/0x30
[14125.248710] [<ffffffff8102a7b7>] 
smp_call_function_single_interrupt+0x9/0xb
[14125.248990] [<ffffffff818f527c>] 
call_function_single_interrupt+0x7c/0x90
[14125.249259] <EOI>

[14125.249333] [<ffffffff8101b929>] ? mwait_idle+0x64/0x7a
[14125.249850] [<ffffffff810e3d8f>] ? 
atomic_notifier_call_chain+0x13/0x15
[14125.250127] [<ffffffff8101bd04>] arch_cpu_idle+0xa/0xc
[14125.250394] [<ffffffff810f7c3d>] default_idle_call+0x27/0x29
[14125.250667] [<ffffffff810f7d5c>] cpu_startup_entry+0x11d/0x1c7
[14125.250939] [<ffffffff8102af13>] start_secondary+0xe8/0xeb
[14125.251202] Code:
ff
ff
00
39
c2
0f
84
1a
fe
ff
ff
e9
ae
fd
ff
ff
49
8b
74
c7
40
8b
0d
17
16
00
00
48
89
f2
f6
c2
01
75
0d
ff
c9
0f
84
21
ff
ff
ff

8b
12
eb
ee
49
89
b6
d8
00
00
00
49
8d
44
c7
40
4c
89
28
f0

[14125.256035] RIP
[<ffffffffa00cbd89>] nf_nat_setup_info+0x6d8/0x755 [nf_nat]
[14125.256368] RSP <ffff885fbe783920>
[14125.256623] CR2: 0000000000000000
[14125.256902] ---[ end trace dbad9b5a1e1b7632 ]---
[14125.257173] Kernel panic - not syncing: Fatal exception in interrupt
[14125.257461] Kernel Offset: disabled
[14125.257726] Rebooting in 5 seconds..

[14130.264058] ACPI MEMORY or I/O RESET_REG.



[10916.690366] BUG: unable to handle kernel
NULL pointer dereference
at 0000000000000008
[10916.690939] IP:
[<ffffffffa00ab07d>] nf_ct_add_to_dying_list+0x55/0x61 [nf_conntrack]
[10916.691461] PGD 5fa11a6067
PUD 5fa11a0067
PMD 0

[10916.691900] Oops: 0002 [#1] SMP
[10916.692156] Modules linked in:
nf_nat_pptp
nf_nat_proto_gre
xt_TCPMSS
xt_connmark
ipt_MASQUERADE
nf_nat_masquerade_ipv4
xt_nat
xt_rateest
xt_RATEEST
nf_conntrack_pptp
nf_conntrack_proto_gre
xt_CT
xt_set
xt_hl
xt_tcpudp
ip_set_hash_net
ip_set
nfnetlink
iptable_raw
iptable_mangle
iptable_nat
nf_conntrack_ipv4
nf_defrag_ipv4
nf_nat_ipv4
nf_nat
nf_conntrack
iptable_filter
ip_tables
x_tables
netconsole
configfs
8021q
garp
mrp
stp
llc
bonding
ixgbe
dca

[10916.695863] CPU: 6 PID: 0 Comm: swapper/6 Not tainted 
4.8.14-build-0124 #2
[10916.696129] Hardware name: Intel Corporation S2600WTT/S2600WTT, BIOS 
SE5C610.86B.01.01.1008.031920151331 03/19/2015
[10916.696576] task: ffff882fa5ea3d40 task.stack: ffff882fa5ec4000
[10916.696834] RIP: 0010:[<ffffffffa00ab07d>]
[<ffffffffa00ab07d>] nf_ct_add_to_dying_list+0x55/0x61 [nf_conntrack]
[10916.697351] RSP: 0018:ffff882fbed83de8 EFLAGS: 00010246
[10916.697604] RAX: 0000000000000000 RBX: ffff882fbed80000 RCX: 
ffff882fbed80010
[10916.697863] RDX: ffff882f8b836450 RSI: 000000000000019b RDI: 
ffff882fbed80000
[10916.698124] RBP: ffff882fbed83df8 R08: 00000000c236df5a R09: 
0000000000000100
[10916.698382] R10: ffff882fbed83de0 R11: ffffffff820050c0 R12: 
ffff882f8b836440
[10916.698642] R13: 0000000000004d8a R14: 000000000007099b R15: 
ffff882f8b836460
[10916.698904] FS: 0000000000000000(0000) GS:ffff882fbed80000(0000) 
knlGS:0000000000000000
[10916.699343] CS: 0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[10916.699601] CR2: 0000000000000008 CR3: 0000005fa3e68000 CR4: 
00000000001406e0
[10916.699862] Stack:
[10916.700105] ffff882f8b836440
ffffffff820a1405
ffff882fbed83e38
ffffffffa00abb30

[10916.700793] 00000002820a1405
ffff882f8b836440
ffff882f92f48401
0000000000000000

[10916.701479] 0000000000000000
ffffffff820050c8
ffff882fbed83e68
ffffffffa00abc62

[10916.702161] Call Trace:
[10916.702406] <IRQ>

[10916.702478] [<ffffffffa00abb30>] nf_ct_delete_from_lists+0xc9/0xf2 
[nf_conntrack]
[10916.703151] [<ffffffffa00abc62>] nf_ct_delete+0x109/0x12c 
[nf_conntrack]
[10916.703416] [<ffffffffa00abc85>] ? nf_ct_delete+0x12c/0x12c 
[nf_conntrack]
[10916.703680] [<ffffffffa00abc92>] death_by_timeout+0xd/0xf 
[nf_conntrack]
[10916.703945] [<ffffffff81109922>] call_timer_fn.isra.5+0x17/0x6b
[10916.704206] [<ffffffff811099e5>] expire_timers+0x6f/0x7e
[10916.704457] [<ffffffff81109add>] run_timer_softirq+0x69/0x8b
[10916.704709] [<ffffffff810d000c>] __do_softirq+0xbd/0x1aa
[10916.704959] [<ffffffff810d0240>] irq_exit+0x37/0x7c
[10916.705208] [<ffffffff8102a7ac>] 
smp_trace_call_function_single_interrupt+0x2e/0x30
[10916.705637] [<ffffffff8102a7b7>] 
smp_call_function_single_interrupt+0x9/0xb
[10916.705893] [<ffffffff818f527c>] 
call_function_single_interrupt+0x7c/0x90
[10916.706148] <EOI>

[10916.706217] [<ffffffff8101b929>] ? mwait_idle+0x64/0x7a
[10916.706702] [<ffffffff810e3d8f>] ? 
atomic_notifier_call_chain+0x13/0x15
[10916.706958] [<ffffffff8101bd04>] arch_cpu_idle+0xa/0xc
[10916.707210] [<ffffffff810f7c3d>] default_idle_call+0x27/0x29
[10916.707463] [<ffffffff810f7d5c>] cpu_startup_entry+0x11d/0x1c7
[10916.707715] [<ffffffff8102af13>] start_secondary+0xe8/0xeb
[10916.707965] Code:
80
2f
0b
82
48
89
df
e8
da
90
84
e1
48
8b
43
10
49
8d
54
24
10
48
8d
4b
10
49
89
4c
24
18
a8
01
49
89
44
24
10
48
89
53
10
75
04

89
50
08
c6
03
00
5b
41
5c
5d
c3
48
8b
05
10
be
00
00
89
f6

[10916.712535] RIP
[<ffffffffa00ab07d>] nf_ct_add_to_dying_list+0x55/0x61 [nf_conntrack]
[10916.713038] RSP <ffff882fbed83de8>
[10916.713282] CR2: 0000000000000008
[10916.713544] ---[ end trace cdc0d7fd100b7f79 ]---
[10916.713800] Kernel panic - not syncing: Fatal exception in interrupt
[10916.714070] Kernel Offset: disabled
[10916.714326] Rebooting in 5 seconds..

[10921.718433] ACPI MEMORY or I/O RESET_REG.

------- This one for old kernel, 4.8.0 !!!

[744605.128307] BUG: unable to handle kernel
paging request
at ffff88a005040218
[744605.128550] IP:
[<ffffffffa00a1d89>] nf_nat_setup_info+0x6d8/0x755 [nf_nat]
[744605.128788] PGD 0

[744605.129004] Oops: 0000 [#1] SMP
[744605.129223] Modules linked in:
sch_sfq
cls_fw
act_police
cls_u32
sch_ingress
sch_htb
pppoe
pppox
ppp_generic
slhc
xt_nat
ts_bm
xt_string
xt_connmark
xt_TCPMSS
xt_tcpudp
xt_mark
iptable_filter
iptable_nat
nf_conntrack_ipv4
nf_defrag_ipv4
nf_nat_ipv4
nf_nat
nf_conntrack
iptable_mangle
ip_tables
x_tables
netconsole
configfs
8021q
garp
mrp
stp
llc
ixgbe
dca

[744605.130523] CPU: 4 PID: 10559 Comm: accel-pppd Not tainted 
4.8.0-build-0117 #1
[744605.130959] Hardware name: Intel Corporation S2600GZ/S2600GZ, BIOS 
SE5C600.86B.02.04.0003.102320141138 10/23/2014
[744605.131401] task: ffff8817d06cd240 task.stack: ffff8817c9610000
[744605.131630] RIP: 0010:[<ffffffffa00a1d89>]
[<ffffffffa00a1d89>] nf_nat_setup_info+0x6d8/0x755 [nf_nat]
[744605.132104] RSP: 0018:ffff8817c96139c0 EFLAGS: 00010216
[744605.132397] RAX: 00000000000014ce RBX: ffffc9001953c338 RCX: 
000000000000000f
[744605.132831] RDX: ffff88a005040218 RSI: ffff88a005040218 RDI: 
ffffc9001953c338
[744605.133262] RBP: ffff8817c9613a98 R08: 0000000063bf9e56 R09: 
0000000000000001
[744605.133692] R10: 0000000000000000 R11: ffff88177b8a7010 R12: 
0000000000000000
[744605.134124] R13: ffff88177fd32518 R14: ffff88177fd32440 R15: 
ffffc90034b30000
[744605.134553] FS: 00007f7d6ee4c700(0000) GS:ffff8817df700000(0000) 
knlGS:0000000000000000
[744605.135000] CS: 0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[744605.135231] CR2: ffff88a005040218 CR3: 0000002fcc4d1000 CR4: 
00000000001406e0
[744605.135664] Stack:
[744605.135881] ffff8817ca0323e8
ffff8817c9613ad8
ffffffffa00a31d0
ffffffff000014ce

[744605.136331] 0000000000000000
ffffffffa00a101d
0000000015fd000a
0000000000000000

[744605.136784] 12fd000a0002a895
0000000000000000
0011150700000000
0000000015fd000a

[744605.137241] Call Trace:
[744605.137459] [<ffffffffa00a101d>] ? __nf_nat_l4proto_find+0x1d/0x1d 
[nf_nat]
[744605.137691] [<ffffffffa00b4040>] ? iptable_nat_ipv4_fn+0x12/0x12 
[iptable_nat]
[744605.138127] [<ffffffffa00a1e5b>] 
__nf_nat_alloc_null_binding+0x55/0x5d [nf_nat]
[744605.138569] [<ffffffffa00a1e7e>] nf_nat_alloc_null_binding+0x1b/0x1d 
[nf_nat]
[744605.138998] [<ffffffffa009752d>] nf_nat_ipv4_fn+0x135/0x17c 
[nf_nat_ipv4]
[744605.139230] [<ffffffffa0097618>] nf_nat_ipv4_out+0x35/0x37 
[nf_nat_ipv4]
[744605.139459] [<ffffffffa00b407e>] iptable_nat_ipv4_out+0x10/0x12 
[iptable_nat]
[744605.139892] [<ffffffff8189ebd2>] nf_iterate+0x41/0x66
[744605.140117] [<ffffffff8189ec22>] nf_hook_slow+0x2b/0x94
[744605.140343] [<ffffffff818a88d9>] ip_output+0xa0/0xbd
[744605.140570] [<ffffffff818a7ebd>] ? ip_fragment.constprop.5+0x77/0x77
[744605.140795] [<ffffffff818a8185>] ip_local_out+0x30/0x37
[744605.141022] [<ffffffff818a90df>] ip_send_skb+0x14/0x38
[744605.141257] [<ffffffff818c904c>] udp_send_skb+0x183/0x1e0
[744605.141480] [<ffffffff818ca9f1>] udp_sendmsg+0x543/0x71f
[744605.141705] [<ffffffff818a74a0>] ? ip_reply_glue_bits+0x4a/0x4a
[744605.141933] [<ffffffff818a18ce>] ? 
__ip_route_output_key_hash+0x4f7/0x602
[744605.142165] [<ffffffff818d25f1>] inet_sendmsg+0x54/0x89
[744605.142392] [<ffffffff8185e5de>] sock_sendmsg+0x12/0x1d
[744605.142620] [<ffffffff8185e65e>] sock_write_iter+0x75/0x8d
[744605.142844] [<ffffffff811880d7>] __vfs_write+0xd0/0xf9
[744605.143066] [<ffffffff81188b82>] vfs_write+0xcd/0x177
[744605.143289] [<ffffffff81189c0d>] SyS_write+0x49/0x83
[744605.143514] [<ffffffff818f13df>] entry_SYSCALL_64_fastpath+0x17/0x93
[744605.143741] Code:
ff
ff
00
39
c2
0f
84
1a
fe
ff
ff
e9
ae
fd
ff
ff
49
8b
74
c7
40
8b
0d
d7
27
00
00
48
89
f2
f6
c2
01
75
0d
ff
c9
0f
84
21
ff
ff
ff

8b
12
eb
ee
49
89
b6
d8
00
00
00
49
8d
44
c7
40
4c
89
28
f0

[744605.146860] RIP
[<ffffffffa00a1d89>] nf_nat_setup_info+0x6d8/0x755 [nf_nat]
[744605.147206] RSP <ffff8817c96139c0>
[744605.147477] CR2: ffff88a005040218
[744605.148299] ---[ end trace 99c51f3aaa6204f3 ]---
[744605.152407] Kernel panic - not syncing: Fatal exception in interrupt
[744605.152770] Kernel Offset: disabled
[744605.156643] Rebooting in 5 seconds..
