From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: kernel panic when using netns+bridges+tc(netem)
Date: Thu, 06 May 2010 08:47:09 +0200
Message-ID: <1273128429.2304.5.camel@edumazet-laptop>
References: <o2wb9800b71005051801uc575c6abp5bad3bd50d54ef96@mail.gmail.com>
	 <1273128002.2304.4.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Mathieu Lacage <mathieu.lacage@sophia.inria.fr>,
	David Miller <davem@davemloft.net>
To: =?ISO-8859-1?Q?Mart=EDn?= Ferrari <martin.ferrari@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:50103 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751191Ab0EFGrP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 May 2010 02:47:15 -0400
Received: by bwz19 with SMTP id 19so297849bwz.21
        for <netdev@vger.kernel.org>; Wed, 05 May 2010 23:47:13 -0700 (PDT)
In-Reply-To: <1273128002.2304.4.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 06 mai 2010 =C3=A0 08:40 +0200, Eric Dumazet a =C3=A9crit :
> Le jeudi 06 mai 2010 =C3=A0 03:01 +0200, Mart=C3=ADn Ferrari a =C3=A9=
crit :
> > Hi there,
> >=20
> > While working on my project that uses netns, I found another bug. T=
his
> > one causes a "Kernel panic - not syncing: Fatal exception in
> > interrupt", and I can reproduce it in 2.6.33 and 2.6.34-rc5, but no=
t
> > in 2.6.32. It dies during a call to __free_skb.
> > I tested this on my x86_64 laptop (2 cores) and on qemu. In qemu it
> > was not triggered until I asked it to emulate 2 cpus instead of one=
,
> > so it is probably a SMP-only issue.
> >=20
> > Scenario:
> >=20
> > I set up a number of network namespaces, each with two veths to net=
ns
> > 1. In the main namespace I take those veths and bridge them in pair=
s,
> > to configure a linear topology; also I configure the netem qdisc to
> > simulate link delay.
> >=20
> > Once the network is set up, I run a client/server program to send U=
DP
> > packets from one end of the topology to the other. After a few seco=
nds
> > of sending packets (not really deterministic) it panics.
> >=20
> > Note that I didn't experience this problem when using only 2
> > namespaces (so, no routing)
> >=20
> > below the dumps. These all come from the qemu, as I couldn't use
> > netconsole in the network at work, but I checked and the backtraces
> > were essentially the same
> >=20
> > First, two panics with 2.6.34, each one with a slightly different b=
acktrace
> >=20
> > [   65.272131] ------------[ cut here ]------------
> > [   65.272135] kernel BUG at mm/slub.c:2846!
> > [   65.272135] invalid opcode: 0000 [#1] SMP
> > [   65.272135] last sysfs file: /sys/devices/virtual/net/lo/opersta=
te
> > [   65.272135] CPU 1
> > [   65.272135] Modules linked in: sch_netem veth bridge stp netcons=
ole
> > configfs loop parport_pc parport evdev tpm_tis tpm snd_pcm tpm_bios
> > snd_timer snd soundcore snd_page_alloc pcspkr psmouse serio_raw
> > i2c_piix4 button i2c_core processor ext3 jbd mbcache ide_cd_mod cdr=
om
> > ide_gd_mod ata_generic ata_piix libata 8139too scsi_mod floppy piix
> > 8139cp mii ide_core thermal thermal_sys [last unloaded: configfs]
> > [   65.272135]
> > [   65.272135] Pid: 1518, comm: udp-perf Not tainted 2.6.34-rc5 #1 =
/
> > [   65.272135] RIP: 0010:[<ffffffff810e0d6b>]  [<ffffffff810e0d6b>]
> > kfree+0x55/0xc6
> > [   65.272135] RSP: 0018:ffff880001a23d90  EFLAGS: 00010246
> > [   65.272135] RAX: 0100000000000000 RBX: ffff88007d6bc600 RCX: 000=
0000000012850
> > [   65.272135] RDX: ffff88007d6bc600 RSI: 000000000000000e RDI: fff=
fea0001b6f610
> > [   65.272135] RBP: ffff88007d6ae200 R08: ffff88007d6bc600 R09: fff=
fffffa0280690
> > [   65.272135] R10: 0000000000000002 R11: ffff88007d6bc500 R12: fff=
fffff8123a77f
> > [   65.272135] R13: 000000000000002b R14: ffff88007d39b600 R15: fff=
f88007d6bc600
> > [   65.272135] FS:  00007f637c9dd6f0(0000) GS:ffff880001a20000(0000=
)
> > knlGS:0000000000000000
> > [   65.272135] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> > [   65.272135] CR2: 00000000009deaa0 CR3: 000000007d82d000 CR4: 000=
00000000006e0
> > [   65.272135] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 000=
0000000000000
> > [   65.272135] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 000=
0000000000400
> > [   65.272135] Process udp-perf (pid: 1518, threadinfo
> > ffff88007d92a000, task ffff88007e7ff810)
> > [   65.272135] Stack:
> > [   65.272135]  ffff88007d6bc600 ffff88007d6bc600 0000000000000246
> > ffffffff8123a77f
> > [   65.272135] <0> ffff880001a32860 ffffffff81241e01 ffffe8ffff6232=
80
> > ffffe8ffff83ffc0
> > [   65.272135] <0> ffff88007d6bc600 ffffffffa028057d 000000027d4c06=
c8
> > ffff88007d4c0600
> > [   65.272135] Call Trace:
> > [   65.272135]  <IRQ>
> > [   65.272135]  [<ffffffff8123a77f>] ? __kfree_skb+0x11/0x7d
> > [   65.272135]  [<ffffffff81241e01>] ? netif_rx+0xe2/0xee
> > [   65.272135]  [<ffffffffa028057d>] ? veth_xmit+0x6e/0xad [veth]
> > [   65.272135]  [<ffffffff8124301f>] ? dev_hard_start_xmit+0x221/0x=
301
> > [   65.272135]  [<ffffffff81256d9a>] ? sch_direct_xmit+0x5b/0x15d
> > [   65.272135]  [<ffffffff81256f55>] ? __qdisc_run+0xb9/0xd8
> > [   65.272135]  [<ffffffff81240511>] ? net_tx_action+0xd6/0x149
> > [   65.272135]  [<ffffffff8104ba02>] ? __do_softirq+0xdd/0x19f
> > [   65.272135]  [<ffffffff8101e515>] ? lapic_next_event+0x18/0x1d
> > [   65.272135]  [<ffffffff810099dc>] ? call_softirq+0x1c/0x30
> > [   65.272135]  [<ffffffff8100b863>] ? do_softirq+0x3f/0x79
> > [   65.272135]  [<ffffffff8104b88e>] ? irq_exit+0x36/0x76
> > [   65.272135]  [<ffffffff8101f000>] ? smp_apic_timer_interrupt+0x8=
6/0x94
> > [   65.272135]  [<ffffffff81009493>] ? apic_timer_interrupt+0x13/0x=
20
> > [   65.272135]  <EOI>
> > [   65.272135]  [<ffffffff8114c1ea>] ? cap_sk_getsecid+0x0/0x1
> > [   65.272135]  [<ffffffff812a0b0f>] ? __xfrm_lookup+0x2/0xb04
> > [   65.272135]  [<ffffffff81264b8d>] ? ip_route_output_flow+0x77/0x=
1cc
> > [   65.272135]  [<ffffffff812887c6>] ? udp_sendmsg+0x32d/0x5f3
> > [   65.272135]  [<ffffffff81009400>] ? irq_entries_start+0x3c0/0x40=
0
> > [   65.272135]  [<ffffffff8128e112>] ? inet_sendmsg+0x53/0x58
> > [   65.272135]  [<ffffffff8123388d>] ? sock_sendmsg+0x83/0x9b
> > [   65.272135]  [<ffffffff8103a042>] ? pick_next_task_fair+0xca/0xd=
6
> > [   65.272135]  [<ffffffff812ef74a>] ? schedule+0x52b/0x593
> > [   65.272135]  [<ffffffff8100948e>] ? apic_timer_interrupt+0xe/0x2=
0
> > [   65.272135]  [<ffffffff8100948e>] ? apic_timer_interrupt+0xe/0x2=
0
> > [   65.272135]  [<ffffffff81185d4b>] ? _copy_from_user+0x1b/0x30
> > [   65.272135]  [<ffffffff8100765f>] ? __switch_to+0x1b5/0x2a6
> > [   65.272135]  [<ffffffff81232227>] ? copy_from_user+0x13/0x25
> > [   65.272135]  [<ffffffff812353cb>] ? sys_sendto+0xd7/0x117
> > [   65.272135]  [<ffffffff8103f7b1>] ? finish_task_switch+0x34/0xa1
> > [   65.272135]  [<ffffffff812ef74a>] ? schedule+0x52b/0x593
> > [   65.272135]  [<ffffffff8100948e>] ? apic_timer_interrupt+0xe/0x2=
0
> > [   65.272135]  [<ffffffff81008ac2>] ? system_call_fastpath+0x16/0x=
1b
> > [   65.272135] Code: 83 c3 08 48 83 3b 00 eb ec 48 83 fd 10 0f 86 8=
4
> > 00 00 00 48 89 ef e8 f4 e2 ff ff 48 89 c7 48 8b 00 84 c0 78 13 66 a=
9
> > 00 c0 75 04 <0f> 0b eb fe 5b 5d 41 5c e9 fb 57 fd ff 48 8b 4c 24 18=
 4c
> > 8b 47
> > [   65.272135] RIP  [<ffffffff810e0d6b>] kfree+0x55/0xc6
> > [   65.272135]  RSP <ffff880001a23d90>
> > [   65.385803] ---[ end trace 42d2fb5b94980ab5 ]---
> > [   65.386337] Kernel panic - not syncing: Fatal exception in inter=
rupt
> > [   65.386943] Pid: 1518, comm: udp-perf Tainted: G      D    2.6.3=
4-rc5 #1
> > [   65.387557] Call Trace:
> > [   65.388011]  <IRQ>  [<ffffffff812eef9b>] ? panic+0x77/0xf7
> > [   65.388729]  [<ffffffff81046b88>] ? kmsg_dump+0xa6/0x13e
> > [   65.389292]  [<ffffffff8100c8c2>] ? oops_end+0xa7/0xb4
> > [   65.389871]  [<ffffffff8123a77f>] ? __kfree_skb+0x11/0x7d
> > [   65.390441]  [<ffffffff8100a695>] ? do_invalid_op+0x8b/0x95
> > [   65.391032]  [<ffffffff810e0d6b>] ? kfree+0x55/0xc6
> > [   65.391587]  [<ffffffffa026f301>] ?
> > br_nf_pre_routing_finish+0x0/0x25e [bridge]
> > [   65.392512]  [<ffffffffa026f301>] ?
> > br_nf_pre_routing_finish+0x0/0x25e [bridge]
> > [   65.393399]  [<ffffffff8100975b>] ? invalid_op+0x1b/0x20
> > [   65.393978]  [<ffffffff8123a77f>] ? __kfree_skb+0x11/0x7d
> > [   65.394547]  [<ffffffff810e0d6b>] ? kfree+0x55/0xc6
> > [   65.395091]  [<ffffffff8123a77f>] ? __kfree_skb+0x11/0x7d
> > [   65.395668]  [<ffffffff81241e01>] ? netif_rx+0xe2/0xee
> > [   65.396438]  [<ffffffffa028057d>] ? veth_xmit+0x6e/0xad [veth]
> > [   65.397026]  [<ffffffff8124301f>] ? dev_hard_start_xmit+0x221/0x=
301
> > [   65.397640]  [<ffffffff81256d9a>] ? sch_direct_xmit+0x5b/0x15d
> > [   65.398222]  [<ffffffff81256f55>] ? __qdisc_run+0xb9/0xd8
> > [   65.398788]  [<ffffffff81240511>] ? net_tx_action+0xd6/0x149
> > [   65.399365]  [<ffffffff8104ba02>] ? __do_softirq+0xdd/0x19f
> > [   65.399935]  [<ffffffff8101e515>] ? lapic_next_event+0x18/0x1d
> > [   65.400560]  [<ffffffff810099dc>] ? call_softirq+0x1c/0x30
> > [   65.401125]  [<ffffffff8100b863>] ? do_softirq+0x3f/0x79
> > [   65.401708]  [<ffffffff8104b88e>] ? irq_exit+0x36/0x76
> > [   65.402267]  [<ffffffff8101f000>] ? smp_apic_timer_interrupt+0x8=
6/0x94
> > [   65.402869]  [<ffffffff81009493>] ? apic_timer_interrupt+0x13/0x=
20
> > [   65.403463]  <EOI>  [<ffffffff8114c1ea>] ? cap_sk_getsecid+0x0/0=
x1
> > [   65.404210]  [<ffffffff812a0b0f>] ? __xfrm_lookup+0x2/0xb04
> > [   65.404779]  [<ffffffff81264b8d>] ? ip_route_output_flow+0x77/0x=
1cc
> > [   65.405375]  [<ffffffff812887c6>] ? udp_sendmsg+0x32d/0x5f3
> > [   65.405945]  [<ffffffff81009400>] ? irq_entries_start+0x3c0/0x40=
0
> > [   65.406534]  [<ffffffff8128e112>] ? inet_sendmsg+0x53/0x58
> > [   65.407102]  [<ffffffff8123388d>] ? sock_sendmsg+0x83/0x9b
> > [   65.407674]  [<ffffffff8103a042>] ? pick_next_task_fair+0xca/0xd=
6
> > [   65.408296]  [<ffffffff812ef74a>] ? schedule+0x52b/0x593
> > [   65.408854]  [<ffffffff8100948e>] ? apic_timer_interrupt+0xe/0x2=
0
> > [   65.409468]  [<ffffffff8100948e>] ? apic_timer_interrupt+0xe/0x2=
0
> > [   65.410084]  [<ffffffff81185d4b>] ? _copy_from_user+0x1b/0x30
> > [   65.410667]  [<ffffffff8100765f>] ? __switch_to+0x1b5/0x2a6
> > [   65.510031]  [<ffffffff81232227>] ? copy_from_user+0x13/0x25
> > [   65.510818]  [<ffffffff812353cb>] ? sys_sendto+0xd7/0x117
> > [   65.511608]  [<ffffffff8103f7b1>] ? finish_task_switch+0x34/0xa1
> > [   65.512465]  [<ffffffff812ef74a>] ? schedule+0x52b/0x593
> > [   65.513229]  [<ffffffff8100948e>] ? apic_timer_interrupt+0xe/0x2=
0
> > [   65.514040]  [<ffffffff81008ac2>] ? system_call_fastpath+0x16/0x=
1b
> >=20
> > [ 1438.042568] ------------[ cut here ]------------
> > [ 1438.043170] kernel BUG at mm/slub.c:2846!
> > [ 1438.043711] invalid opcode: 0000 [#1] SMP
> > [ 1438.044531] last sysfs file: /sys/devices/virtual/net/lo/opersta=
te
> > [ 1438.045148] CPU 1
> > [ 1438.045350] Modules linked in: sch_netem veth bridge stp netcons=
ole
> > configfs loop parport_pc tpm_tis tpm snd_pcm psmouse parport tpm_bi=
os
> > snd_timer snd soundcore snd_page_alloc evdev pcspkr serio_raw
> > i2c_piix4 i2c_core button processor ext3 jbd mbcache ide_cd_mod cdr=
om
> > ide_gd_mod ata_generic ata_piix 8139too libata scsi_mod floppy 8139=
cp
> > mii thermal thermal_sys piix ide_core [last unloaded: scsi_wait_sca=
n]
> > [ 1438.046215]
> > [ 1438.046215] Pid: 1476, comm: udp-perf Not tainted 2.6.34-rc5 #1 =
/
> > [ 1438.046215] RIP: 0010:[<ffffffff810e0d6b>]  [<ffffffff810e0d6b>]
> > kfree+0x55/0xc6
> > [ 1438.046215] RSP: 0018:ffff880001a23d90  EFLAGS: 00010246
> > [ 1438.046215] RAX: 0100000000000000 RBX: ffff88007d882200 RCX: 000=
0000000012850
> > [ 1438.046215] RDX: ffff88007d882200 RSI: 000000000000000e RDI: fff=
fea0001b972a0
> > [ 1438.046215] RBP: ffff88007e20c000 R08: ffff88007d882200 R09: fff=
fffffa026c690
> > [ 1438.046215] R10: 0000000000000002 R11: ffff88007d882100 R12: fff=
fffff8123a77f
> > [ 1438.046215] R13: 0000000000000032 R14: ffff8800378e0700 R15: fff=
f88007d882200
> > [ 1438.046215] FS:  00007f1c1d07f6f0(0000) GS:ffff880001a20000(0000=
)
> > knlGS:0000000000000000
> > [ 1438.046215] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> > [ 1438.046215] CR2: 00007f6ea9e07310 CR3: 0000000037834000 CR4: 000=
00000000006e0
> > [ 1438.046215] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 000=
0000000000000
> > [ 1438.046215] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 000=
0000000000400
> > [ 1438.046215] Process udp-perf (pid: 1476, threadinfo
> > ffff88007db0e000, task ffff8800379a2350)
> > [ 1438.046215] Stack:
> > [ 1438.046215]  ffff88007d882200 ffff88007d882200 0000000000000246
> > ffffffff8123a77f
> > [ 1438.046215] <0> ffff880001a32860 ffffffff81241e01 ffffe8ffffa3f4=
30
> > ffffe8ffffa3d180
> > [ 1438.046215] <0> ffff88007d882200 ffffffffa026c57d 0000000201a305=
00
> > ffff88007d171200
> > [ 1438.046215] Call Trace:
> > [ 1438.046215]  <IRQ>
> > [ 1438.046215]  [<ffffffff8123a77f>] ? __kfree_skb+0x11/0x7d
> > [ 1438.046215]  [<ffffffff81241e01>] ? netif_rx+0xe2/0xee
> > [ 1438.046215]  [<ffffffffa026c57d>] ? veth_xmit+0x6e/0xad [veth]
> > [ 1438.046215]  [<ffffffff8124301f>] ? dev_hard_start_xmit+0x221/0x=
301
> > [ 1438.046215]  [<ffffffff81256d9a>] ? sch_direct_xmit+0x5b/0x15d
> > [ 1438.046215]  [<ffffffff81256f55>] ? __qdisc_run+0xb9/0xd8
> > [ 1438.046215]  [<ffffffff81240511>] ? net_tx_action+0xd6/0x149
> > [ 1438.046215]  [<ffffffff8104ba02>] ? __do_softirq+0xdd/0x19f
> > [ 1438.046215]  [<ffffffff8101e515>] ? lapic_next_event+0x18/0x1d
> > [ 1438.046215]  [<ffffffff810099dc>] ? call_softirq+0x1c/0x30
> > [ 1438.046215]  [<ffffffff8100b863>] ? do_softirq+0x3f/0x79
> > [ 1438.046215]  [<ffffffff8104b88e>] ? irq_exit+0x36/0x76
> > [ 1438.046215]  [<ffffffff8101f000>] ? smp_apic_timer_interrupt+0x8=
6/0x94
> > [ 1438.046215]  [<ffffffff81009493>] ? apic_timer_interrupt+0x13/0x=
20
> > [ 1438.046215]  <EOI>
> > [ 1438.046215]  [<ffffffff81288499>] ? udp_sendmsg+0x0/0x5f3
> > [ 1438.046215]  [<ffffffff8128850f>] ? udp_sendmsg+0x76/0x5f3
> > [ 1438.046215]  [<ffffffff812889a7>] ? udp_sendmsg+0x50e/0x5f3
> > [ 1438.046215]  [<ffffffff8123388d>] ? sock_sendmsg+0x83/0x9b
> > [ 1438.046215]  [<ffffffff8103a042>] ? pick_next_task_fair+0xca/0xd=
6
> > [ 1438.046215]  [<ffffffff812ef74a>] ? schedule+0x52b/0x593
> > [ 1438.046215]  [<ffffffff8100948e>] ? apic_timer_interrupt+0xe/0x2=
0
> > [ 1438.046215]  [<ffffffff8100948e>] ? apic_timer_interrupt+0xe/0x2=
0
> > [ 1438.046215]  [<ffffffff8100948e>] ? apic_timer_interrupt+0xe/0x2=
0
> > [ 1438.046215]  [<ffffffff810e93ed>] ? fget_light+0x0/0xa1
> > [ 1438.046215]  [<ffffffff81185e40>] ? copy_user_generic_string+0x3=
0/0x40
> > [ 1438.046215]  [<ffffffff81232227>] ? copy_from_user+0x13/0x25
> > [ 1438.046215]  [<ffffffff812353cb>] ? sys_sendto+0xd7/0x117
> > [ 1438.046215]  [<ffffffff8103f7b1>] ? finish_task_switch+0x34/0xa1
> > [ 1438.046215]  [<ffffffff812ef74a>] ? schedule+0x52b/0x593
> > [ 1438.046215]  [<ffffffff8100948e>] ? apic_timer_interrupt+0xe/0x2=
0
> > [ 1438.046215]  [<ffffffff81008ac2>] ? system_call_fastpath+0x16/0x=
1b
> > [ 1438.046215] Code: 83 c3 08 48 83 3b 00 eb ec 48 83 fd 10 0f 86 8=
4
> > 00 00 00 48 89 ef e8 f4 e2 ff ff 48 89 c7 48 8b 00 84 c0 78 13 66 a=
9
> > 00 c0 75 04 <0f> 0b eb fe 5b 5d 41 5c e9 fb 57 fd ff 48 8b 4c 24 18=
 4c
> > 8b 47
> > [ 1438.046215] RIP  [<ffffffff810e0d6b>] kfree+0x55/0xc6
> > [ 1438.046215]  RSP <ffff880001a23d90>
> > [ 1438.102706] ---[ end trace ab36062dcf233d6a ]---
> > [ 1438.103251] Kernel panic - not syncing: Fatal exception in inter=
rupt
> > [ 1438.103912] Pid: 1476, comm: udp-perf Tainted: G      D    2.6.3=
4-rc5 #1
> > [ 1438.104563] Call Trace:
> > [ 1438.105017]  <IRQ>  [<ffffffff812eef9b>] ? panic+0x77/0xf7
> > [ 1438.105718]  [<ffffffff81046b88>] ? kmsg_dump+0xa6/0x13e
> > [ 1438.106293]  [<ffffffff8100c8c2>] ? oops_end+0xa7/0xb4
> > [ 1438.106866]  [<ffffffff8123a77f>] ? __kfree_skb+0x11/0x7d
> > [ 1438.107451]  [<ffffffff8100a695>] ? do_invalid_op+0x8b/0x95
> > [ 1438.108036]  [<ffffffff810e0d6b>] ? kfree+0x55/0xc6
> > [ 1438.108799]  [<ffffffffa025b301>] ?
> > br_nf_pre_routing_finish+0x0/0x25e [bridge]
> > [ 1438.109699]  [<ffffffffa025b301>] ?
> > br_nf_pre_routing_finish+0x0/0x25e [bridge]
> > [ 1438.110604]  [<ffffffff8100975b>] ? invalid_op+0x1b/0x20
> > [ 1438.111172]  [<ffffffff8123a77f>] ? __kfree_skb+0x11/0x7d
> > [ 1438.111753]  [<ffffffff810e0d6b>] ? kfree+0x55/0xc6
> > [ 1438.112359]  [<ffffffff8123a77f>] ? __kfree_skb+0x11/0x7d
> > [ 1438.112952]  [<ffffffff81241e01>] ? netif_rx+0xe2/0xee
> > [ 1438.113527]  [<ffffffffa026c57d>] ? veth_xmit+0x6e/0xad [veth]
> > [ 1438.114123]  [<ffffffff8124301f>] ? dev_hard_start_xmit+0x221/0x=
301
> > [ 1438.114734]  [<ffffffff81256d9a>] ? sch_direct_xmit+0x5b/0x15d
> > [ 1438.115334]  [<ffffffff81256f55>] ? __qdisc_run+0xb9/0xd8
> > [ 1438.115912]  [<ffffffff81240511>] ? net_tx_action+0xd6/0x149
> > [ 1438.116544]  [<ffffffff8104ba02>] ? __do_softirq+0xdd/0x19f
> > [ 1438.117128]  [<ffffffff8101e515>] ? lapic_next_event+0x18/0x1d
> > [ 1438.117732]  [<ffffffff810099dc>] ? call_softirq+0x1c/0x30
> > [ 1438.118420]  [<ffffffff8100b863>] ? do_softirq+0x3f/0x79
> > [ 1438.119066]  [<ffffffff8104b88e>] ? irq_exit+0x36/0x76
> > [ 1438.147879]  [<ffffffff8101f000>] ? smp_apic_timer_interrupt+0x8=
6/0x94
> > [ 1438.148615]  [<ffffffff81009493>] ? apic_timer_interrupt+0x13/0x=
20
> > [ 1438.149294]  <EOI>  [<ffffffff81288499>] ? udp_sendmsg+0x0/0x5f3
> > [ 1438.150101]  [<ffffffff8128850f>] ? udp_sendmsg+0x76/0x5f3
> > [ 1438.150681]  [<ffffffff812889a7>] ? udp_sendmsg+0x50e/0x5f3
> > [ 1438.151276]  [<ffffffff8123388d>] ? sock_sendmsg+0x83/0x9b
> > [ 1438.151853]  [<ffffffff8103a042>] ? pick_next_task_fair+0xca/0xd=
6
> > [ 1438.152508]  [<ffffffff812ef74a>] ? schedule+0x52b/0x593
> > [ 1438.153078]  [<ffffffff8100948e>] ? apic_timer_interrupt+0xe/0x2=
0
> > [ 1438.153687]  [<ffffffff8100948e>] ? apic_timer_interrupt+0xe/0x2=
0
> > [ 1438.154295]  [<ffffffff8100948e>] ? apic_timer_interrupt+0xe/0x2=
0
> > [ 1438.154902]  [<ffffffff810e93ed>] ? fget_light+0x0/0xa1
> > [ 1438.155477]  [<ffffffff81185e40>] ? copy_user_generic_string+0x3=
0/0x40
> > [ 1438.156097]  [<ffffffff81232227>] ? copy_from_user+0x13/0x25
> > [ 1438.156720]  [<ffffffff812353cb>] ? sys_sendto+0xd7/0x117
> > [ 1438.157376]  [<ffffffff8103f7b1>] ? finish_task_switch+0x34/0xa1
> > [ 1438.157970]  [<ffffffff812ef74a>] ? schedule+0x52b/0x593
> > [ 1438.158557]  [<ffffffff8100948e>] ? apic_timer_interrupt+0xe/0x2=
0
> > [ 1438.159153]  [<ffffffff81008ac2>] ? system_call_fastpath+0x16/0x=
1b
> >=20
> > ------------
> >=20
> > Finally, a panic in 2.6.33. Note that the line in wioch BUG is
> > triggered is different
> >=20
> > [  102.442815] ------------[ cut here ]------------
> > [  102.443433] kernel BUG at
> > /build/mattems-linux-2.6_2.6.33-1~experimental.4-amd64-ieqSsa/linux=
-2.6-2.6.33-1~experimental.4/debian/build/source_amd64_none/mm/slub.c:2=
969!
> > [  102.444874] invalid opcode: 0000 [#1] SMP
> > [  102.444958] last sysfs file: /sys/devices/virtual/net/lo/opersta=
te
> > [  102.444958] CPU 0
> > [  102.444958] Pid: 4, comm: ksoftirqd/0 Not tainted 2.6.33-2-amd64=
 #1 /
> > [  102.444958] RIP: 0010:[<ffffffff810e1e2c>]  [<ffffffff810e1e2c>]
> > kfree+0x55/0xcb
> > [  102.444958] RSP: 0018:ffff880001a03df8  EFLAGS: 00010246
> > [  102.444958] RAX: 0100000000000000 RBX: ffff88007e439000 RCX: 000=
0000000012d70
> > [  102.444958] RDX: 000000000000006a RSI: ffffea0001b76a70 RDI: fff=
fea0000c1a328
> > [  102.444958] RBP: ffff880037533c00 R08: ffff88007e21e500 R09: fff=
fffff8162bbe0
> > [  102.444958] R10: 000000037e439e00 R11: ffff88007e439e00 R12: fff=
fffff81239cf2
> > [  102.444958] R13: 000000000000006a R14: ffff88007efb3000 R15: fff=
f88007e21e500
> > [  102.444958] FS:  0000000000000000(0000) GS:ffff880001a00000(0000=
)
> > knlGS:0000000000000000
> > [  102.444958] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> > [  102.444958] CR2: 00007fc8e25cd0f0 CR3: 000000007d088000 CR4: 000=
00000000006f0
> > [  102.444958] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 000=
0000000000000
> > [  102.444958] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 000=
0000000000400
> > [  102.444958] Process ksoftirqd/0 (pid: 4, threadinfo
> > ffff88007fb78000, task ffff88007fb61500)
> > [  102.444958] Stack:
> > [  102.444958]  ffff88007e439000 ffff88007e439000 0000000000000246
> > ffffffff81239cf2
> > [  102.444958] <0> ffff880001a12d80 ffffffff8124125d ffffe8ffff8181=
90
> > ffffe8ffff815ee0
> > [  102.444958] <0> ffff88007e439000 ffffffffa025254b ffff880001a100=
10
> > ffff88007ef95200
> > [  102.444958] Call Trace:
> > [  102.444958]  <IRQ>
> > [  102.444958]  [<ffffffff81239cf2>] ? __kfree_skb+0x11/0x7d
> > [  102.444958]  [<ffffffff8124125d>] ? netif_rx+0xe2/0xee
> > [  102.444958]  [<ffffffffa025254b>] ? veth_xmit+0x6e/0xad [veth]
> > [  102.444958]  [<ffffffff8124243a>] ? dev_hard_start_xmit+0x221/0x=
2dc
> > [  102.444958]  [<ffffffff81255514>] ? sch_direct_xmit+0x5b/0x15d
> > [  102.444958]  [<ffffffff812556cf>] ? __qdisc_run+0xb9/0xda
> > [  102.444958]  [<ffffffff8123fa99>] ? net_tx_action+0xd6/0x149
> > [  102.444958]  [<ffffffff8104c918>] ? __do_softirq+0xdd/0x1a1
> > [  102.444958]  [<ffffffff810099dc>] ? call_softirq+0x1c/0x30
> > [  102.444958]  <EOI>
> > [  102.444958]  [<ffffffff8100b85f>] ? do_softirq+0x3f/0x79
> > [  102.444958]  [<ffffffff8104c504>] ? run_ksoftirqd+0x6a/0x118
> > [  102.444958]  [<ffffffff8104c49a>] ? run_ksoftirqd+0x0/0x118
> > [  102.444958]  [<ffffffff8105ee99>] ? kthread+0x79/0x81
> > [  102.444958]  [<ffffffff810098e4>] ? kernel_thread_helper+0x4/0x1=
0
> > [  102.444958]  [<ffffffff8105ee20>] ? kthread+0x0/0x81
> > [  102.444958]  [<ffffffff810098e0>] ? kernel_thread_helper+0x0/0x1=
0
> > [  102.444958] Code: 83 c3 08 48 83 3b 00 eb ec 48 83 fd 10 0f 86 8=
9
> > 00 00 00 48 89 ef e8 f0 e6 ff ff 48 89 c7 48 8b 00 84 c0 78 13 66 a=
9
> > 00 c0 75 04 <0f> 0b eb fe 5b 5d 41 5c e9 45 5a fd ff 48 8b 4c 24 18=
 4c
> > 8b 4f
> > [  102.444958] RIP  [<ffffffff810e1e2c>] kfree+0x55/0xcb
> > [  102.444958]  RSP <ffff880001a03df8>
> > [  102.484000] ---[ end trace b1157390d40df1cb ]---
> > [  102.485018] Kernel panic - not syncing: Fatal exception in inter=
rupt
> > [  102.485647] Pid: 4, comm: ksoftirqd/0 Tainted: G      D    2.6.3=
3-2-amd64 #1
> > [  102.486630] Call Trace:
> > [  102.487112]  <IRQ>  [<ffffffff812ec605>] ? panic+0x86/0x14b
> > [  102.487870]  [<ffffffff8104c799>] ? irq_exit+0x48/0x76
> > [  102.488474]  [<ffffffff812ee893>] ? ret_from_intr+0x0/0x11
> > [  102.489068]  [<ffffffff810478c0>] ? kmsg_dump+0xa6/0x13e
> > [  102.489661]  [<ffffffff8100c89a>] ? oops_end+0xa7/0xb4
> > [  102.490245]  [<ffffffff81239cf2>] ? __kfree_skb+0x11/0x7d
> > [  102.490836]  [<ffffffff8100a690>] ? do_invalid_op+0x8b/0x95
> > [  102.491436]  [<ffffffff810e1e2c>] ? kfree+0x55/0xcb
> > [  102.492020]  [<ffffffffa0244aee>] ?
> > br_nf_pre_routing_finish+0x284/0x2a6 [bridge]
> > [  102.492942]  [<ffffffffa024486a>] ?
> > br_nf_pre_routing_finish+0x0/0x2a6 [bridge]
> > [  102.493857]  [<ffffffff8125f204>] ? nf_hook_slow+0x62/0xc3
> > [  102.523082]  [<ffffffffa024486a>] ?
> > br_nf_pre_routing_finish+0x0/0x2a6 [bridge]
> > [  102.524008]  [<ffffffff8100975b>] ? invalid_op+0x1b/0x20
> > [  102.524631]  [<ffffffff81239cf2>] ? __kfree_skb+0x11/0x7d
> > [  102.525225]  [<ffffffff810e1e2c>] ? kfree+0x55/0xcb
> > [  102.525795]  [<ffffffff810e1e1c>] ? kfree+0x45/0xcb
> > [  102.526402]  [<ffffffff81239cf2>] ? __kfree_skb+0x11/0x7d
> > [  102.526992]  [<ffffffff8124125d>] ? netif_rx+0xe2/0xee
> > [  102.527576]  [<ffffffffa025254b>] ? veth_xmit+0x6e/0xad [veth]
> > [  102.528199]  [<ffffffff8124243a>] ? dev_hard_start_xmit+0x221/0x=
2dc
> > [  102.528821]  [<ffffffff81255514>] ? sch_direct_xmit+0x5b/0x15d
> > [  102.529429]  [<ffffffff812556cf>] ? __qdisc_run+0xb9/0xda
> > [  102.530018]  [<ffffffff8123fa99>] ? net_tx_action+0xd6/0x149
> > [  102.530618]  [<ffffffff8104c918>] ? __do_softirq+0xdd/0x1a1
> > [  102.531214]  [<ffffffff810099dc>] ? call_softirq+0x1c/0x30
> > [  102.531804]  <EOI>  [<ffffffff8100b85f>] ? do_softirq+0x3f/0x79
> > [  102.532572]  [<ffffffff8104c504>] ? run_ksoftirqd+0x6a/0x118
> > [  102.533169]  [<ffffffff8104c49a>] ? run_ksoftirqd+0x0/0x118
> > [  102.533764]  [<ffffffff8105ee99>] ? kthread+0x79/0x81
> > [  102.534340]  [<ffffffff810098e4>] ? kernel_thread_helper+0x4/0x1=
0
> > [  102.534954]  [<ffffffff8105ee20>] ? kthread+0x0/0x81
> > [  102.535526]  [<ffffffff810098e0>] ? kernel_thread_helper+0x0/0x1=
0
> >=20
>=20
> Could you please try following patch ?
>=20
> Thanks
>=20
> [PATCH] veth: Dont kfree_skb() after dev_forward_skb()
>=20
> In case of congestion, dev_forward_skb() already free the skb
>=20
> Reported-by: Mart=C3=ADn Ferrari <martin.ferrari@gmail.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
> diff --git a/drivers/net/veth.c b/drivers/net/veth.c
> index f9f0730..5ec542d 100644
> --- a/drivers/net/veth.c
> +++ b/drivers/net/veth.c
> @@ -187,7 +187,6 @@ tx_drop:
>  	return NETDEV_TX_OK;
> =20
>  rx_drop:
> -	kfree_skb(skb);
>  	rcv_stats->rx_dropped++;
>  	return NETDEV_TX_OK;
>  }
>=20

Hmm, scratch that one, I'll resubmit a proper fix in few minutes

(We must change dev_forward_skb() too)



