From: nuclearcat@nuclearcat.com
Subject: Re: 4.6.3 panic on nf_ct_delete (nf_conntrack)
Date: Wed, 13 Jul 2016 23:37:02 +0300
Message-ID: <36a4dadcd64430dc5ee3f25478dc3c9a@nuclearcat.com>
References: <df376f88504cb0f20b20acf42962c16d@nuclearcat.com>
 <20160713202113.GA4198@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nuclearcat.com ([144.76.183.226]:37998 "EHLO nuclearcat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750897AbcGMUhL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jul 2016 16:37:11 -0400
In-Reply-To: <20160713202113.GA4198@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2016-07-13 23:21, Florian Westphal wrote:
> nuclearcat@nuclearcat.com <nuclearcat@nuclearcat.com> wrote:
>> Workload: pppoe server, 5k users on ppp interfaces. No actual 
>> SNAT/DNAT, but
>> using connmark and REDIRECT
>> 
>> [176412.990104] general protection fault: 0000 [#1]
>> SMP
> 
> I assume that you did not see this before.
> 
> What was the last kernel version where you did not run into this?
> 
> Might help to narrow things down.
Difficult to say, because it was triggered also on 4.5.3 at 10 Jun, 
while i was running this kernel since May 10, and never had such issue 
before. Maybe some new traffic pattern caused this, or because 
interfaces saturated now, and might reach full bandwidth (800Mbps in 
bursts might reach 1G, and traffic will be dropped?).

Here is panic from 4.5.3:

[85867.255619] general protection fault: 0000 [#1]
SMP

[85867.255939] Modules linked in:
cls_fw
act_police
cls_u32
sch_ingress
sch_sfq
sch_htb
netconsole
configfs
coretemp
nf_nat_pptp
nf_nat_proto_gre
nf_conntrack_pptp
nf_conntrack_proto_gre
pppoe
pppox
ppp_generic
slhc
tun
xt_REDIRECT
nf_nat_redirect
xt_TCPMSS
ipt_REJECT
nf_reject_ipv4
xt_set
ts_bm
xt_string
xt_connmark
xt_DSCP
xt_mark
xt_tcpudp
ip_set_hash_net
ip_set_hash_ip
ip_set
nfnetlink
iptable_mangle
iptable_filter
iptable_nat
nf_conntrack_ipv4
nf_defrag_ipv4
nf_nat_ipv4
nf_nat
nf_conntrack
ip_tables
x_tables
8021q
garp
mrp
stp
llc

[85867.263194] CPU: 7 PID: 0 Comm: swapper/7 Not tainted 
4.5.3-build-0100 #4
[85867.263397] Hardware name: HP ProLiant DL320e Gen8 v2, BIOS P80 
04/02/2015
[85867.263598] task: ffff880435584680 ti: ffff8804355a8000 task.ti: 
ffff8804355a8000
[85867.263936] RIP: 0010:[<ffffffffa003d0ef>]
[<ffffffffa003d0ef>] nf_ct_delete+0x1a/0x1dc [nf_conntrack]
[85867.264343] RSP: 0018:ffff8804474e3e80  EFLAGS: 00010282
[85867.264545] RAX: ffff8804021b3738 RBX: 0000000080000100 RCX: 
dead000000000200
[85867.264749] RDX: 0000000000000000 RSI: 0000000000000000 RDI: 
ffa00504021b36b0
[85867.264950] RBP: ffff8804474e3ec8 R08: ffff8804474e3f08 R09: 
0000000000000000
[85867.265151] R10: ffffffff820090c0 R11: 0000000000000002 R12: 
ffa00504021b36b0
[85867.265351] R13: 0000000000000000 R14: 0000000000000000 R15: 
ffffffff820090c8
[85867.265553] FS:  0000000000000000(0000) GS:ffff8804474e0000(0000) 
knlGS:0000000000000000
[85867.265892] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[85867.266092] CR2: 00007fb170542dc8 CR3: 000000000200a000 CR4: 
00000000001406e0
[85867.266295] Stack:
[85867.266490]  ffff8804474e3ec0
ffffffff810f996a
ffff880435584680
ffff8804474edc40

[85867.267057]  0000000080000100
ffffffffa003d2b1
00000000000000fa
ffff8804355ac000

[85867.267624]  ffffffff820090c8
ffff8804474e3ed8
ffffffffa003d2be
ffff8804474e3ef8

[85867.268192] Call Trace:
[85867.268392]  <IRQ>

[85867.268456]  [<ffffffff810f996a>] ? hrtimer_forward+0xd5/0xeb
[85867.268857]  [<ffffffffa003d2b1>] ? nf_ct_delete+0x1dc/0x1dc 
[nf_conntrack]
[85867.269062]  [<ffffffffa003d2be>] death_by_timeout+0xd/0xf 
[nf_conntrack]
[85867.269265]  [<ffffffff810f9157>] call_timer_fn.isra.26+0x17/0x6d
[85867.269468]  [<ffffffff810f9323>] run_timer_softirq+0x176/0x197
[85867.269672]  [<ffffffff810c2fb9>] __do_softirq+0xb9/0x1a9
[85867.269873]  [<ffffffff810c31f0>] irq_exit+0x37/0x7c
[85867.270077]  [<ffffffff8102af09>] smp_apic_timer_interrupt+0x3d/0x48
[85867.270282]  [<ffffffff818d27dc>] apic_timer_interrupt+0x7c/0x90
[85867.270484]  <EOI>

[85867.270546]  [<ffffffff8100ad6f>] ? mwait_idle+0x64/0x7a
[85867.270943]  [<ffffffff8100b16f>] arch_cpu_idle+0xa/0xc
[85867.271144]  [<ffffffff810e8c99>] default_idle_call+0x27/0x29
[85867.271345]  [<ffffffff810e8dba>] cpu_startup_entry+0x11f/0x1c9
[85867.271548]  [<ffffffff8102989b>] start_secondary+0xf1/0xf4
[85867.271750] Code:
e8
35
60
08
e1
58
5b
41
5c
41
5d
41
5e
41
5f
5d
c3
55
48
89
e5
41
57
41
56
41
55
41
54
41
89
f5
53
49
89
fc
41
89
d6
48
83
ec
20

8b
9f
c8
00
00
00
48
85
db
74
20
0f
b7
43
1c
66
85
c0
74
17

[85867.275937] RIP
[<ffffffffa003d0ef>] nf_ct_delete+0x1a/0x1dc [nf_conntrack]
[85867.276200]  RSP <ffff8804474e3e80>
[85867.276423] ---[ end trace 7be551057bff38cd ]---
[85867.285767] Kernel panic - not syncing: Fatal exception in interrupt
[85867.285973] Kernel Offset: disabled
[85867.319076] Rebooting in 5 seconds..
