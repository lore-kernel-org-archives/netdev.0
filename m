From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [3.1] Divide by zero in __tcp_select_window()
Date: Tue, 08 Nov 2011 22:23:25 +0100
Message-ID: <1320787405.26025.10.camel@edumazet-laptop>
References: <20111108205411.GA23642@hostway.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Thomas Gleixner <tglx@linutronix.de>,
	Network Development <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Dave Jones <davej@redhat.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Ingo Molnar <mingo@elte.hu>
To: Simon Kirby <sim@hostway.ca>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111108205411.GA23642@hostway.ca>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 08 novembre 2011 =C3=A0 12:54 -0800, Simon Kirby a =C3=A9crit =
:
> Hello!
>=20
> We've seen a few more hang traces with tcp_keeaplive_timer() since we
> fixed the socket unlocking, so I was thinking that I must have borked
> the patching, but we finally caught it on a box with a serial console=
,
> and it turned out to be a different problem (pasted below).
>=20
> This is on the same boxes as before (random web loads), running
> 3.1+Thomas and Eric's socket locking fixes, still with some anti-abus=
e
> scripts that use blackhole routes.
>=20
> By the way, Greg seems to have only pulled Thomas' patch into queue-3=
=2E1,
> not Eric's, so I think that may have been missed.
>=20
> The only divide in __tcp_select_window is the one that lines up the
> window to a multiple of the mss:
>=20
> 		/* Get the largest window that is a nice multiple of mss.
> 		 * Window clamp already applied above.
> 		 * If our current window offering is within 1 mss of the
> 		 * free space we just keep it. This prevents the divide
> 		 * and multiply from happening most of the time.
> 		 * We also don't do any window rounding when the free space
> 		 * is too small.
> 		 */
> 		if (window <=3D free_space - mss || window > free_space)
> 			window =3D (free_space / mss) * mss;
> 		else if (mss =3D=3D full_space &&
> 			 free_space > window + (full_space >> 1))
> 			window =3D free_space;
>=20
> None of that code has changed for years, so I suspect something else =
has
> changed to cause mss to be zero by the time it got here.
>=20
> Simon-
>=20
> divide error: 0000 [#1] SMP=20
> CPU 2=20
> Modules linked in: ipmi_devintf ipmi_si ipmi_msghandler xt_recent nf_=
conntrack_ftp xt_state xt_owner nf_conntrack_ipv4 nf_conntrack nf_defra=
g_ipv4 bnx2
>=20
> Pid: 25125, comm: php4 Not tainted 3.1.0-hw-lockdep+ #57 Dell Inc. Po=
werEdge 1950/0UR033
> RIP: 0010:[<ffffffff81660199>]  [<ffffffff81660199>] __tcp_select_win=
dow+0xe9/0x130
> RSP: 0000:ffff88022fc83cd0  EFLAGS: 00010246
> RAX: 0000000000003908 RBX: ffff88005032eccc RCX: 000000000000ffff
> RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000000003908
> RBP: ffff88022fc83cd0 R08: 0000000000003908 R09: 0000000000007fff
> R10: 0000000000000014 R11: 0000000000000000 R12: ffff88006a1f9200
> R13: ffff880101757f00 R14: 0000000000003908 R15: 0000000000000014
> FS:  00007f7634433720(0000) GS:ffff88022fc80000(0000) knlGS:000000000=
0000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 000000000478c0a8 CR3: 000000013cbd0000 CR4: 00000000000006e0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Process php4 (pid: 25125, threadinfo ffff88016249a000, task ffff88003=
b243e40)
> Stack:
>  ffff88022fc83d50 ffffffff816606e9 ffffffff81660de2 ffff880101757f28
>  0000000000000100 0000000000000100 0000000000000000 0000000000000000
>  0000000000000000 0000000000000000 0000000000000000 0000000000000000
> Call Trace:
>  <IRQ>=20
>  [<ffffffff816606e9>] tcp_transmit_skb+0x209/0x8e0
>  [<ffffffff81660de2>] ? tcp_xmit_probe_skb+0x22/0xe0
>  [<ffffffff81660e8e>] tcp_xmit_probe_skb+0xce/0xe0
>  [<ffffffff8166252e>] tcp_write_wakeup+0x6e/0x180
>  [<ffffffff81664897>] tcp_keepalive_timer+0x247/0x270
>  [<ffffffff8106cd8d>] run_timer_softirq+0x26d/0x410
>  [<ffffffff8106ccb8>] ? run_timer_softirq+0x198/0x410
>  [<ffffffff81664650>] ? tcp_init_xmit_timers+0x20/0x20
>  [<ffffffff810640e8>] __do_softirq+0x138/0x250
>  [<ffffffff817030fc>] call_softirq+0x1c/0x30
>  [<ffffffff810153c5>] do_softirq+0x95/0xd0
>  [<ffffffff81063cbd>] irq_exit+0xdd/0x110
>  [<ffffffff810310c9>] smp_apic_timer_interrupt+0x69/0xa0
>  [<ffffffff81701973>] apic_timer_interrupt+0x73/0x80
>  <EOI>=20
>  [<ffffffff81700eca>] ? sysret_check+0x2e/0x69
> Code: 89 d0 d3 e0 41 39 c0 74 56 8d 7a 01 d3 e7 89 f8 c9 c3 89 c7 44 =
89 c0 29 f0 39 f8 7d 05 44 39 c7 7e 30 44 89 c2 44 89 c0 c1 fa 1f <f7> =
fe 89 c7 0f af fe 89 f8 eb da 0f 1f 40 00 f7 d9 41 89 d0 89=20
> RIP  [<ffffffff81660199>] __tcp_select_window+0xe9/0x130
>  RSP <ffff88022fc83cd0>
> divide error: 0000 [#2]=20
> ---[ end trace b3f46c09a69a2efe ]---
> Kernel panic - not syncing: Fatal exception in interrupt
> Pid: 25125, comm: php4 Tainted: G      D     3.1.0-hw-lockdep+ #57
> Call Trace:
>  <IRQ>  [<ffffffff816f4364>] panic+0xca/0x210
>  [<ffffffff8105cd24>] ? kmsg_dump+0x104/0x160
>  [<ffffffff8105cd3c>] ? kmsg_dump+0x11c/0x160
>  [<ffffffff8105cc9c>] ? kmsg_dump+0x7c/0x160
>  [<ffffffff816fa25c>] oops_end+0xdc/0xf0
>  [<ffffffff810166d6>] die+0x56/0x90
>  [<ffffffff816f9b8e>] do_trap+0x14e/0x170
>  [<ffffffff8101474a>] do_divide_error+0x8a/0xb0
>  [<ffffffff81660199>] ? __tcp_select_window+0xe9/0x130
>  [<ffffffff81613a53>] ? __netif_receive_skb+0x383/0x560
>  [<ffffffff81613835>] ? __netif_receive_skb+0x165/0x560
>  [<ffffffff813a614d>] ? trace_hardirqs_off_thunk+0x3a/0x3c
>  [<ffffffff816f91a4>] ? restore_args+0x30/0x30
>  [<ffffffff81702e1b>] divide_error+0x1b/0x20
>  [<ffffffff81660199>] ? __tcp_select_window+0xe9/0x130
>  [<ffffffff816606e9>] tcp_transmit_skb+0x209/0x8e0
>  [<ffffffff81660de2>] ? tcp_xmit_probe_skb+0x22/0xe0
>  [<ffffffff81660e8e>] tcp_xmit_probe_skb+0xce/0xe0
>  [<ffffffff8166252e>] tcp_write_wakeup+0x6e/0x180
>  [<ffffffff81664897>] tcp_keepalive_timer+0x247/0x270
>  [<ffffffff8106cd8d>] run_timer_softirq+0x26d/0x410
>  [<ffffffff8106ccb8>] ? run_timer_softirq+0x198/0x410
>  [<ffffffff81664650>] ? tcp_init_xmit_timers+0x20/0x20
>  [<ffffffff810640e8>] __do_softirq+0x138/0x250
>  [<ffffffff817030fc>] call_softirq+0x1c/0x30
>  [<ffffffff810153c5>] do_softirq+0x95/0xd0
>  [<ffffffff81063cbd>] irq_exit+0xdd/0x110
>  [<ffffffff810310c9>] smp_apic_timer_interrupt+0x69/0xa0
>  [<ffffffff81701973>] apic_timer_interrupt+0x73/0x80
>  <EOI>  [<ffffffff81700eca>] ? sysret_check+0x2e/0x69
> SMP=20
> CPU 3=20
> Modules linked in: ipmi_devintf ipmi_si ipmi_msghandler xt_recent nf_=
conntrack_ftp xt_state xt_owner nf_conntrack_ipv4 nf_conntrack nf_defra=
g_ipv4 bnx2
>=20
> Pid: 0, comm: kworker/0:1 Tainted: G      D     3.1.0-hw-lockdep+ #57=
 Dell Inc. PowerEdge 1950/0UR033
> RIP: 0010:[<ffffffff81660199>]  [<ffffffff81660199>] __tcp_select_win=
dow+0xe9/0x130
> RSP: 0018:ffff88022fcc3cd0  EFLAGS: 00010246
> RAX: 0000000000003908 RBX: ffff880010ce80cc RCX: 000000000000ffff
> RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000000003908
> RBP: ffff88022fcc3cd0 R08: 0000000000003908 R09: 0000000000007fff
> R10: 0000000000000014 R11: 0000000000000000 R12: ffff88006636a400
> R13: ffff88000afb0300 R14: 0000000000003908 R15: 0000000000000014
> FS:  0000000000000000(0000) GS:ffff88022fcc0000(0000) knlGS:000000000=
0000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> CR2: 00007fc220c14000 CR3: 000000013cbd0000 CR4: 00000000000006e0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Process kworker/0:1 (pid: 0, threadinfo ffff880226980000, task ffff88=
0226959f20)
> Stack:
>  ffff88022fcc3d50 ffffffff816606e9 ffffffff81660de2 ffff88000afb0328
>  0000000000000100 0000000000000100 0000000000000000 0000000000000000
>  0000000000000000 0000000000000000 0000000000000000 0000000000000000
> Call Trace:
>  <IRQ>=20
>  [<ffffffff816606e9>] tcp_transmit_skb+0x209/0x8e0
>  [<ffffffff81660de2>] ? tcp_xmit_probe_skb+0x22/0xe0
>  [<ffffffff81660e8e>] tcp_xmit_probe_skb+0xce/0xe0
>  [<ffffffff8166252e>] tcp_write_wakeup+0x6e/0x180
>  [<ffffffff81664897>] tcp_keepalive_timer+0x247/0x270
>  [<ffffffff8106cd8d>] run_timer_softirq+0x26d/0x410
>  [<ffffffff8106ccb8>] ? run_timer_softirq+0x198/0x410
>  [<ffffffff81664650>] ? tcp_init_xmit_timers+0x20/0x20
>  [<ffffffff810640e8>] __do_softirq+0x138/0x250
>  [<ffffffff817030fc>] call_softirq+0x1c/0x30
>  [<ffffffff810153c5>] do_softirq+0x95/0xd0
>  [<ffffffff81063cbd>] irq_exit+0xdd/0x110
>  [<ffffffff810310c9>] smp_apic_timer_interrupt+0x69/0xa0
>  [<ffffffff81701973>] apic_timer_interrupt+0x73/0x80
>  <EOI>=20
>  [<ffffffff8101b80e>] ? mwait_idle+0x14e/0x170
>  [<ffffffff8101b805>] ? mwait_idle+0x145/0x170
>  [<ffffffff81013156>] cpu_idle+0x96/0xf0
>  [<ffffffff816ef30b>] start_secondary+0x1ca/0x1ff
> Code: 89 d0 d3 e0 41 39 c0 74 56 8d 7a 01 d3 e7 89 f8 c9 c3 89 c7 44 =
89 c0 29 f0 39 f8 7d 05 44 39 c7 7e 30 44 89 c2 44 89 c0 c1 fa 1f <f7> =
fe 89 c7 0f af fe 89 f8 eb da 0f 1f 40 00 f7 d9 41 89 d0 89=20
> RIP  [<ffffffff81660199>] __tcp_select_window+0xe9/0x130
>  RSP <ffff88022fcc3cd0>
> divide error: 0000 [#3] SMP=20
> CPU 1=20
> Modules linked in: ipmi_devintf ipmi_si ipmi_msghandler xt_recent nf_=
conntrack_ftp xt_state xt_owner nf_conntrack_ipv4 nf_conntrack nf_defra=
g_ipv4 bnx2
>=20
> Pid: 25118, comm: search.pl Tainted: G      D     3.1.0-hw-lockdep+ #=
57 Dell Inc. PowerEdge 1950/0UR033
> RIP: 0010:[<ffffffff81660199>]  [<ffffffff81660199>] __tcp_select_win=
dow+0xe9/0x130
> RSP: 0018:ffff88022fc43cd0  EFLAGS: 00010246
> RAX: 0000000000003908 RBX: ffff88003d808ccc RCX: 000000000000ffff
> RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000000003908
> RBP: ffff88022fc43cd0 R08: 0000000000003908 R09: 0000000000007fff
> R10: 0000000000000014 R11: 0000000000000000 R12: ffff88001966da00
> R13: ffff8800a4665500 R14: 0000000000003908 R15: 0000000000000014
> FS:  00007f0872f48700(0000) GS:ffff88022fc40000(0000) knlGS:000000000=
0000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 0000000003f0f470 CR3: 000000015e1ad000 CR4: 00000000000006e0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Process search.pl (pid: 25118, threadinfo ffff880109992000, task ffff=
880214f40000)
> Stack:
>  ffff88022fc43d50 ffffffff816606e9 ffffffff81660de2 ffff8800a4665528
>  0000000000000100 0000000000000100 0000000000000000 0000000000000000
>  0000000000000000 0000000000000000 0000000000000000 0000000000000000
> Call Trace:
>  <IRQ>=20
>  [<ffffffff816606e9>] tcp_transmit_skb+0x209/0x8e0
>  [<ffffffff81660de2>] ? tcp_xmit_probe_skb+0x22/0xe0
>  [<ffffffff81660e8e>] tcp_xmit_probe_skb+0xce/0xe0
>  [<ffffffff8166252e>] tcp_write_wakeup+0x6e/0x180
>  [<ffffffff81664897>] tcp_keepalive_timer+0x247/0x270
>  [<ffffffff8106cd8d>] run_timer_softirq+0x26d/0x410
>  [<ffffffff8106ccb8>] ? run_timer_softirq+0x198/0x410
>  [<ffffffff81664650>] ? tcp_init_xmit_timers+0x20/0x20
>  [<ffffffff810640e8>] __do_softirq+0x138/0x250
>  [<ffffffff817030fc>] call_softirq+0x1c/0x30
>  [<ffffffff810153c5>] do_softirq+0x95/0xd0
>  [<ffffffff81063cbd>] irq_exit+0xdd/0x110
>  [<ffffffff810310c9>] smp_apic_timer_interrupt+0x69/0xa0
>  [<ffffffff81701973>] apic_timer_interrupt+0x73/0x80
>  <EOI>=20
>  [<ffffffff8109a802>] ? lock_acquire+0x122/0x140
>  [<ffffffff8122bc80>] ? nfs_handle_cb_pathdown+0x20/0x20
>  [<ffffffff8122bcc7>] nfs_have_delegation+0x47/0xb0
>  [<ffffffff8122bc80>] ? nfs_handle_cb_pathdown+0x20/0x20
>  [<ffffffff81205806>] nfs_attribute_cache_expired+0x16/0x70
>  [<ffffffff81096c3d>] ? trace_hardirqs_on_caller+0x13d/0x1c0
>  [<ffffffff81206e7f>] nfs_revalidate_mapping+0x2f/0x130
>  [<ffffffff81204d1f>] nfs_file_read+0x7f/0x120
>  [<ffffffff810529dc>] ? finish_task_switch+0x8c/0x100
>  [<ffffffff8112aa91>] do_sync_read+0xd1/0x120
>  [<ffffffff816f50f2>] ? __schedule+0x5c2/0xa20
>  [<ffffffff8112b7b8>] vfs_read+0xc8/0x180
>  [<ffffffff8112b960>] sys_read+0x50/0x90
>  [<ffffffff81700e92>] system_call_fastpath+0x16/0x1b
> Code: 89 d0 d3 e0 41 39 c0 74 56 8d 7a 01 d3 e7 89 f8 c9 c3 89 c7 44 =
89 c0 29 f0 39 f8 7d 05 44 39 c7 7e 30 44 89 c2 44 89 c0 c1 fa 1f <f7> =
fe 89 c7 0f af fe 89 f8 eb da 0f 1f 40 00 f7 d9 41 89 d0 89=20
> RIP  [<ffffffff81660199>] __tcp_select_window+0xe9/0x130
>  RSP <ffff88022fc43cd0>
> divide error: 0000 [#4] SMP=20
> CPU 0=20
> Modules linked in: ipmi_devintf ipmi_si ipmi_msghandler xt_recent nf_=
conntrack_ftp xt_state xt_owner nf_conntrack_ipv4 nf_conntrack nf_defra=
g_ipv4 bnx2
>=20
> Pid: 25177, comm: php Tainted: G      D     3.1.0-hw-lockdep+ #57 Del=
l Inc. PowerEdge 1950/0UR033
> RIP: 0010:[<ffffffff81660199>]  [<ffffffff81660199>] __tcp_select_win=
dow+0xe9/0x130
> RSP: 0000:ffff88022fc03cd0  EFLAGS: 00010246
> RAX: 0000000000003908 RBX: ffff88001519b0cc RCX: 000000000000ffff
> RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000000003908
> RBP: ffff88022fc03cd0 R08: 0000000000003908 R09: 0000000000007fff
> R10: 0000000000000014 R11: 0000000000000000 R12: ffff88000263a400
> R13: ffff88016545f300 R14: 0000000000003908 R15: 0000000000000014
> FS:  00007ffbdac9b720(0000) GS:ffff88022fc00000(0000) knlGS:000000000=
0000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 0000000003f97000 CR3: 0000000104c4c000 CR4: 00000000000006f0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Process php (pid: 25177, threadinfo ffff880214e7c000, task ffff880116=
940000)
> Stack:
>  ffff88022fc03d50 ffffffff816606e9 ffffffff81660de2 ffff88016545f328
>  0000000000000100 0000000000000100 0000000000000000 0000000000000000
>  0000000000000000 0000000000000000 0000000000000000 0000000000000000
> Call Trace:
>  <IRQ>=20
>  [<ffffffff816606e9>] tcp_transmit_skb+0x209/0x8e0
>  [<ffffffff81660de2>] ? tcp_xmit_probe_skb+0x22/0xe0
>  [<ffffffff81660e8e>] tcp_xmit_probe_skb+0xce/0xe0
>  [<ffffffff8166252e>] tcp_write_wakeup+0x6e/0x180
>  [<ffffffff81664897>] tcp_keepalive_timer+0x247/0x270
>  [<ffffffff8106cd8d>] run_timer_softirq+0x26d/0x410
>  [<ffffffff8106ccb8>] ? run_timer_softirq+0x198/0x410
>  [<ffffffff81664650>] ? tcp_init_xmit_timers+0x20/0x20
>  [<ffffffff810640e8>] __do_softirq+0x138/0x250
>  [<ffffffff817030fc>] call_softirq+0x1c/0x30
>  [<ffffffff810153c5>] do_softirq+0x95/0xd0
>  [<ffffffff81063cbd>] irq_exit+0xdd/0x110
>  [<ffffffff810310c9>] smp_apic_timer_interrupt+0x69/0xa0
>  [<ffffffff81701973>] apic_timer_interrupt+0x73/0x80
>  <EOI>=20
>  [<ffffffff81700eca>] ? sysret_check+0x2e/0x69
> Code: 89 d0 d3 e0 41 39 c0 74 56 8d 7a 01 d3 e7 89 f8 c9 c3 89 c7 44 =
89 c0 29 f0 39 f8 7d 05 44 39 c7 7e 30 44 89 c2 44 89 c0 c1 fa 1f <f7> =
fe 89 c7 0f af fe 89 f8 eb da 0f 1f 40 00 f7 d9 41 89 d0 89=20
> RIP  [<ffffffff81660199>] __tcp_select_window+0xe9/0x130
>  RSP <ffff88022fc03cd0>
>=20

OK, it seems we let a timer running while we free the socket (same erro=
r
path than your previous bug report, because of the NULL route)

We arm this keepalive timer in tcp_create_openreq_child()

net/ipv4/tcp_minisocks.c:513
	if (sock_flag(newsk, SOCK_KEEPOPEN))
		inet_csk_reset_keepalive_timer(newsk,
			keepalive_time_when(newtp));

I would try to add a call to tcp_clear_xmit_timers() as well

Please try following patch :

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index a744315..a9db4b1 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1510,6 +1510,7 @@ exit:
 	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_LISTENDROPS);
 	return NULL;
 put_and_exit:
+	tcp_clear_xmit_timers(newsk);
 	bh_unlock_sock(newsk);
 	sock_put(newsk);
 	goto exit;
