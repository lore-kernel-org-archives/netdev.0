From: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Subject: Re: 4.6.3, pppoe + shaper workload, skb_panic / skb_push /
 ppp_start_xmit
Date: Thu, 28 Jul 2016 14:28:23 +0300
Message-ID: <e6cb92be01af6190350b9b3765bee6e3@nuclearcat.com>
References: <c72d23549eaa7aadee1a66a6bb788a4a@nuclearcat.com>
 <CAM_iQpWuCw6Bgm=1BWMkoFkuav5xV+FyKPq0Ef+3N_qpQqv=AA@mail.gmail.com>
 <20160728110948.GA3046@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Guillaume Nault <g.nault@alphalink.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nuclearcat.com ([144.76.183.226]:35834 "EHLO nuclearcat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757007AbcG1L20 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Jul 2016 07:28:26 -0400
In-Reply-To: <20160728110948.GA3046@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2016-07-28 14:09, Guillaume Nault wrote:
> On Tue, Jul 12, 2016 at 10:31:18AM -0700, Cong Wang wrote:
>> On Mon, Jul 11, 2016 at 12:45 PM,  <nuclearcat@nuclearcat.com> wrote:
>> > Hi
>> >
>> > On latest kernel i noticed kernel panic happening 1-2 times per day. It is
>> > also happening on older kernel (at least 4.5.3).
>> >
>> ...
>> >  [42916.426463] Call Trace:
>> >  [42916.426658]  <IRQ>
>> >
>> >  [42916.426719]  [<ffffffff81843786>] skb_push+0x36/0x37
>> >  [42916.427111]  [<ffffffffa00e8ce5>] ppp_start_xmit+0x10f/0x150
>> > [ppp_generic]
>> >  [42916.427314]  [<ffffffff81853467>] dev_hard_start_xmit+0x25a/0x2d3
>> >  [42916.427516]  [<ffffffff818530f2>] ?
>> > validate_xmit_skb.isra.107.part.108+0x11d/0x238
>> >  [42916.427858]  [<ffffffff8186dee3>] sch_direct_xmit+0x89/0x1b5
>> >  [42916.428060]  [<ffffffff8186e142>] __qdisc_run+0x133/0x170
>> >  [42916.428261]  [<ffffffff81850034>] net_tx_action+0xe3/0x148
>> >  [42916.428462]  [<ffffffff810c401a>] __do_softirq+0xb9/0x1a9
>> >  [42916.428663]  [<ffffffff810c4251>] irq_exit+0x37/0x7c
>> >  [42916.428862]  [<ffffffff8102b8f7>] smp_apic_timer_interrupt+0x3d/0x48
>> >  [42916.429063]  [<ffffffff818cb15c>] apic_timer_interrupt+0x7c/0x90
>> 
>> Interesting, we call a skb_cow_head() before skb_push() in 
>> ppp_start_xmit(),
>> I have no idea why this could happen.
>> 
> The skb is corrupted: head is at ffff8800b0bf2800 while data is at
> ffa00500b0bf284c.
> 
> Figuring out how this corruption happened is going to be hard without a
> way to reproduce the problem.
> 
> Denys, can you confirm you're using a vanilla kernel?
> Also I guess the ppp devices and tc settings are handled by accel-ppp.
> If so, can you share more info about your setup (accel-ppp.conf, radius
> attributes, iptables...) so that I can try to reproduce it on my
> machines?

I have slight modification from vanilla:

--- linux/net/sched/sch_htb.c	2016-06-08 01:23:53.000000000 +0000
+++ linux-new/net/sched/sch_htb.c	2016-06-21 14:03:08.398486593 +0000
@@ -1495,10 +1495,10 @@
  				cl->common.classid);
  			cl->quantum = 1000;
  		}
-		if (!hopt->quantum && cl->quantum > 200000) {
+		if (!hopt->quantum && cl->quantum > 2000000) {
  			pr_warn("HTB: quantum of class %X is big. Consider r2q change.\n",
  				cl->common.classid);
-			cl->quantum = 200000;
+			cl->quantum = 2000000;
  		}
  		if (hopt->quantum)
  			cl->quantum = hopt->quantum;

But i guess it should not be reason of crash (it is related to another 
system,  without it i was unable to shape over 7Gbps, maybe with latest 
kernel i will not need this patch).

I'm trying to make reproducible conditions of crash, because right now 
it happens only on some servers in large networks (completely different 
ISPs, so i excluded possible hardware fault of specific server). It is 
complex config, i have accel-ppp, plus my own "shaping daemon" that 
apply several shapers on ppp interfaces. Wost thing it happens only on 
live customers, i am unable to reproduce same on stress tests. Also 
until recent kernel i was getting different panic messages (but all 
related to ppp).

I think also at least one reason of crash also was fixed by "ppp: defer 
netns reference release for ppp channel" in 4.7.0 (maybe thats why i am 
getting less crashes recently).
I tried also various kernel debug options that doesn't cause major 
performance degradation (locks checking, freed memory poisoning and 
etc), without any luck yet. Is it useful if i will post panics that at 
least occurs twice? (I will post below example, got recently)
Sure if i will be able to reproducible conditions i will send them 
immediately.


<server19> [ 5449.900988] general protection fault: 0000 [#1] SMP
<server19> [ 5449.901263] Modules linked in:
<server19> cls_fw
<server19> act_police
<server19> cls_u32
<server19> sch_ingress
<server19> sch_sfq
<server19> sch_htb
<server19> pppoe
<server19> pppox
<server19> ppp_generic
<server19> slhc
<server19> netconsole
<server19> configfs
<server19> xt_nat
<server19> ts_bm
<server19> xt_string
<server19> xt_connmark
<server19> xt_TCPMSS
<server19> xt_tcpudp
<server19> xt_mark
<server19> iptable_filter
<server19> iptable_nat
<server19> nf_conntrack_ipv4
<server19> nf_defrag_ipv4
<server19> nf_nat_ipv4
<server19> nf_nat
<server19> nf_conntrack
<server19> iptable_mangle
<server19> ip_tables
<server19> x_tables
<server19> 8021q
<server19> garp
<server19> mrp
<server19> stp
<server19> llc
<server19> ixgbe
<server19> dca
<server19>
<server19> [ 5449.904989] CPU: 1 PID: 6359 Comm: ip Not tainted 
4.7.0-build-0109 #2
<server19> [ 5449.905255] Hardware name: Supermicro 
X10SLM+-LN4F/X10SLM+-LN4F, BIOS 3.0 04/24/2015
<server19> [ 5449.905712] task: ffff8803eef40000 ti: ffff8803fd754000 
task.ti: ffff8803fd754000
<server19> [ 5449.906168] RIP: 0010:[<ffffffff818a994d>]
<server19> [<ffffffff818a994d>] inet_fill_ifaddr+0x5a/0x264
<server19> [ 5449.906710] RSP: 0018:ffff8803fd757b98  EFLAGS: 00010286
<server19> [ 5449.906976] RAX: ffff8803ef65cb90 RBX: ffff8803f7d2cd00 
RCX: 0000000000000000
<server19> [ 5449.907248] RDX: 0000000800000002 RSI: ffff8803ef65cb90 
RDI: ffff8803ef65cba8
<server19> [ 5449.907519] RBP: ffff8803fd757be0 R08: 0000000000000008 
R09: 0000000000000002
<server19> [ 5449.907792] R10: ffa005040269f480 R11: ffffffff820a1c00 
R12: ffa005040269f480
<server19> [ 5449.908067] R13: ffff8803ef65cb90 R14: 0000000000000000 
R15: ffff8803f7d2cd00
<server19> [ 5449.908339] FS:  00007f660674d700(0000) 
GS:ffff88041fc40000(0000) knlGS:0000000000000000
<server19> [ 5449.908796] CS:  0010 DS: 0000 ES: 0000 CR0: 
0000000080050033
<server19> [ 5449.909067] CR2: 00000000008b9018 CR3: 00000003f2a11000 
CR4: 00000000001406e0
<server19> [ 5449.909339] Stack:
<server19> [ 5449.909598]  0163a8c0869711ac
<server19> 0000008000000000
<server19> ffffffffffffffff
<server19> 0003e1d50003e1d5
<server19>
<server19> [ 5449.910329]  ffff8800d54c0ac8
<server19> ffff8803f0d90000
<server19> 0000000000000005
<server19> 0000000000000000
<server19>
<server19> [ 5449.911066]  ffff8803f7d2cd00
<server19> ffff8803fd757c40
<server19> ffffffff818a9f73
<server19> ffffffff820a1c00
<server19>
<server19> [ 5449.911803] Call Trace:
<server19> [ 5449.912061]  [<ffffffff818a9f73>] 
inet_dump_ifaddr+0xfb/0x185
<server19> [ 5449.912332]  [<ffffffff8185de4b>] rtnl_dump_all+0xa9/0xc2
<server19> [ 5449.912601]  [<ffffffff818756d8>] netlink_dump+0xf0/0x25c
<server19> [ 5449.912873]  [<ffffffff818759ed>] 
netlink_recvmsg+0x1a9/0x2d3
<server19> [ 5449.913142]  [<ffffffff81838412>] sock_recvmsg+0x14/0x16
<server19> [ 5449.913407]  [<ffffffff8183a743>] 
___sys_recvmsg+0xea/0x1a1
<server19> [ 5449.913675]  [<ffffffff811658e6>] ? 
alloc_pages_vma+0x167/0x1a0
<server19> [ 5449.913945]  [<ffffffff81159a8b>] ? 
page_add_new_anon_rmap+0xb4/0xbd
<server19> [ 5449.914212]  [<ffffffff8113b0d0>] ? 
lru_cache_add_active_or_unevictable+0x31/0x9d
<server19> [ 5449.914664]  [<ffffffff81151762>] ? 
handle_mm_fault+0x632/0x112d
<server19> [ 5449.914940]  [<ffffffff811550fe>] ? vma_merge+0x27e/0x2b1
<server19> [ 5449.915208]  [<ffffffff8183b4db>] __sys_recvmsg+0x3d/0x5e
<server19> [ 5449.915478]  [<ffffffff8183b4db>] ? 
__sys_recvmsg+0x3d/0x5e
<server19> [ 5449.915747]  [<ffffffff8183b509>] SyS_recvmsg+0xd/0x17
<server19> [ 5449.916017]  [<ffffffff818cb85f>] 
entry_SYSCALL_64_fastpath+0x17/0x93
<server19> [ 5449.916287] Code:
<server19> e5
<server19> 41
<server19> 57
<server19> 41
<server19> 56
<server19> 41
<server19> 55
<server19> 41
<server19> 54
<server19> 49
<server19> 89
<server19> f4
<server19> 53
<server19> 89
<server19> c6
<server19> 48
<server19> 89
<server19> fb
<server19> 48
<server19> 83
<server19> ec
<server19> 20
<server19> e8
<server19> be
<server19> b0
<server19> fc
<server19> ff
<server19> 48
<server19> 85
<server19> c0
<server19> 49
<server19> 89
<server19> c5
<server19> 0f
<server19> 84
<server19> f4
<server19> 01
<server19> 00
<server19> 00
<server19> c6
<server19> 40
<server19> 10
<server19> 02
<server19>
<server19> 8a
<server19> 44
<server19> 24
<server19> 41
<server19> 41
<server19> 83
<server19> ce
<server19> ff
<server19> 45
<server19> 89
<server19> f7
<server19> 41
<server19> 88
<server19> 45
<server19> 11
<server19> 41
<server19> 8b
<server19> 44
<server19> 24
<server19> 44
<server19>
<server19> [ 5449.921684] RIP
<server19> [<ffffffff818a994d>] inet_fill_ifaddr+0x5a/0x264
<server19> [ 5449.922028]  RSP <ffff8803fd757b98>
<server19> [ 5449.922547] ---[ end trace 18580d58f51e3038 ]---
<server19> [ 5449.923705] Kernel panic - not syncing: Fatal exception
<server19> [ 5449.923979] Kernel Offset: disabled
<server19> [ 5449.925873] Rebooting in 5 seconds..



<server19> [43221.432450] general protection fault: 0000 [#1] SMP
<server19> [43221.432656] Modules linked in:
<server19> intel_ips
<server19> intel_smartconnect
<server19> intel_rst
<server19> cls_fw
<server19> act_police
<server19> cls_u32
<server19> sch_ingress
<server19> sch_sfq
<server19> sch_htb
<server19> pppoe
<server19> pppox
<server19> ppp_generic
<server19> slhc
<server19> netconsole
<server19> configfs
<server19> xt_nat
<server19> ts_bm
<server19> xt_string
<server19> xt_connmark
<server19> xt_TCPMSS
<server19> xt_tcpudp
<server19> xt_mark
<server19> iptable_filter
<server19> iptable_nat
<server19> nf_conntrack_ipv4
<server19> nf_defrag_ipv4
<server19> nf_nat_ipv4
<server19> nf_nat
<server19> nf_conntrack
<server19> iptable_mangle
<server19> ip_tables
<server19> x_tables
<server19> 8021q
<server19> garp
<server19> mrp
<server19> stp
<server19> llc
<server19> ixgbe
<server19> dca
<server19>
<server19> [43221.433815] CPU: 3 PID: 29196 Comm: accel-cmd Not tainted 
4.7.0-build-0110 #2
<server19> [43221.434024] Hardware name: Supermicro 
X10SLM+-LN4F/X10SLM+-LN4F, BIOS 3.0 04/24/2015
<server19> [43221.434414] task: ffff8803dcc39780 ti: ffff8800cdb18000 
task.ti: ffff8800cdb18000
<server19> [43221.434805] RIP: 0010:[<ffffffff818a7fd0>]
<server19> [<ffffffff818a7fd0>] inet_fill_ifaddr+0x5a/0x264
<server19> [43221.435202] RSP: 0018:ffff8800cdb1bb98  EFLAGS: 00010282
<server19> [43221.435406] RAX: ffff8803fe89efb0 RBX: ffff8803de661500 
RCX: 0000000000000000
<server19> [43221.435616] RDX: 0000000800000002 RSI: ffff8803fe89efb0 
RDI: ffff8803fe89efc8
<server19> [43221.435823] RBP: ffff8800cdb1bbe0 R08: 0000000000000008 
R09: 0000000000000002
<server19> [43221.436030] R10: ffa0050402880f80 R11: ffffffff820a1680 
R12: ffa0050402880f80
<server19> [43221.436234] R13: ffff8803fe89efb0 R14: 0000000000000000 
R15: ffff8803de661500
<server19> [43221.436436] FS:  00007f25a2539700(0000) 
GS:ffff88041fcc0000(0000) knlGS:0000000000000000
<server19> [43221.436821] CS:  0010 DS: 0000 ES: 0000 CR0: 
0000000080050033
<server19> [43221.437023] CR2: 000000000060f000 CR3: 00000000cd2e8000 
CR4: 00000000001406e0
<server19> [43221.437227] Stack:
<server19> [43221.437419]  0163a8c0818411ac
<server19> 0000008000000000
<server19> ffffffffffffffff
<server19> 003a44db003a44db
<server19>
<server19> [43221.437827]  ffff8803fe5992c8
<server19> ffff8803f5b04000
<server19> 0000000000000003
<server19> 0000000000000000
<server19>
<server19> [43221.438230]  ffff8803de661500
<server19> ffff8800cdb1bc40
<server19> ffffffff818a85f6
<server19> ffffffff820a1680
<server19>
<server19> [43221.438636] Call Trace:
<server19> [43221.438834]  [<ffffffff818a85f6>] 
inet_dump_ifaddr+0xfb/0x185
<server19> [43221.439035]  [<ffffffff8185c4ce>] rtnl_dump_all+0xa9/0xc2
<server19> [43221.439241]  [<ffffffff81873d5b>] netlink_dump+0xf0/0x25c
<server19> [43221.439441]  [<ffffffff81874070>] 
netlink_recvmsg+0x1a9/0x2d3
<server19> [43221.439641]  [<ffffffff81836a95>] sock_recvmsg+0x14/0x16
<server19> [43221.439841]  [<ffffffff81838dc6>] 
___sys_recvmsg+0xea/0x1a1
<server19> [43221.440043]  [<ffffffff8116765f>] ? 
alloc_pages_vma+0x167/0x1a0
<server19> [43221.440247]  [<ffffffff8115b804>] ? 
page_add_new_anon_rmap+0xb4/0xbd
<server19> [43221.440449]  [<ffffffff8113ce49>] ? 
lru_cache_add_active_or_unevictable+0x31/0x9d
<server19> [43221.440837]  [<ffffffff811534db>] ? 
handle_mm_fault+0x632/0x112d
<server19> [43221.441038]  [<ffffffff81839636>] ? SyS_sendto+0xef/0x120
<server19> [43221.441241]  [<ffffffff81839b5e>] __sys_recvmsg+0x3d/0x5e
<server19> [43221.441443]  [<ffffffff81839b5e>] ? 
__sys_recvmsg+0x3d/0x5e
<server19> [43221.441644]  [<ffffffff81839b8c>] SyS_recvmsg+0xd/0x17
<server19> [43221.441849]  [<ffffffff818c9edf>] 
entry_SYSCALL_64_fastpath+0x17/0x93
<server19> [43221.442055] Code:
<server19> e5
<server19> 41
<server19> 57
<server19> 41
<server19> 56
<server19> 41
<server19> 55
<server19> 41
<server19> 54
<server19> 49
<server19> 89
<server19> f4
<server19> 53
<server19> 89
<server19> c6
<server19> 48
<server19> 89
<server19> fb
<server19> 48
<server19> 83
<server19> ec
<server19> 20
<server19> e8
<server19> be
<server19> b0
<server19> fc
<server19> ff
<server19> 48
<server19> 85
<server19> c0
<server19> 49
<server19> 89
<server19> c5
<server19> 0f
<server19> 84
<server19> f4
<server19> 01
<server19> 00
<server19> 00
<server19> c6
<server19> 40
<server19> 10
<server19> 02
<server19>
<server19> 8a
<server19> 44
<server19> 24
<server19> 41
<server19> 41
<server19> 83
<server19> ce
<server19> ff
<server19> 45
<server19> 89
<server19> f7
<server19> 41
<server19> 88
<server19> 45
<server19> 11
<server19> 41
<server19> 8b
<server19> 44
<server19> 24
<server19> 44
<server19>
<server19> [43221.442945] RIP
<server19> [<ffffffff818a7fd0>] inet_fill_ifaddr+0x5a/0x264
<server19> [43221.443151]  RSP <ffff8800cdb1bb98>
<server19> [43221.445125] ---[ end trace 99273d413e56a193 ]---
<server19> [43221.446262] Kernel panic - not syncing: Fatal exception
<server19> [43221.446536] Kernel Offset: disabled
<server19> [43221.448446] Rebooting in 5 seconds..
Jul 27 23:41:44 10.0.253.19
Jul 27 23:41:44 10.0.253.19 [43226.451328] ACPI MEMORY or I/O RESET_REG.
