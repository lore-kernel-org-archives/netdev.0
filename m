From: Simon Kirby <sim@hostway.ca>
Subject: [3.1] Divide by zero in __tcp_select_window()
Date: Tue, 8 Nov 2011 12:54:11 -0800
Message-ID: <20111108205411.GA23642@hostway.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Dave Jones <davej@redhat.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Ingo Molnar <mingo@elte.hu>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Network Development <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

We've seen a few more hang traces with tcp_keeaplive_timer() since we
fixed the socket unlocking, so I was thinking that I must have borked
the patching, but we finally caught it on a box with a serial console,
and it turned out to be a different problem (pasted below).

This is on the same boxes as before (random web loads), running
3.1+Thomas and Eric's socket locking fixes, still with some anti-abuse
scripts that use blackhole routes.

By the way, Greg seems to have only pulled Thomas' patch into queue-3.1,
not Eric's, so I think that may have been missed.

The only divide in __tcp_select_window is the one that lines up the
window to a multiple of the mss:

		/* Get the largest window that is a nice multiple of mss.
		 * Window clamp already applied above.
		 * If our current window offering is within 1 mss of the
		 * free space we just keep it. This prevents the divide
		 * and multiply from happening most of the time.
		 * We also don't do any window rounding when the free space
		 * is too small.
		 */
		if (window <= free_space - mss || window > free_space)
			window = (free_space / mss) * mss;
		else if (mss == full_space &&
			 free_space > window + (full_space >> 1))
			window = free_space;

None of that code has changed for years, so I suspect something else has
changed to cause mss to be zero by the time it got here.

Simon-

divide error: 0000 [#1] SMP 
CPU 2 
Modules linked in: ipmi_devintf ipmi_si ipmi_msghandler xt_recent nf_conntrack_ftp xt_state xt_owner nf_conntrack_ipv4 nf_conntrack nf_defrag_ipv4 bnx2

Pid: 25125, comm: php4 Not tainted 3.1.0-hw-lockdep+ #57 Dell Inc. PowerEdge 1950/0UR033
RIP: 0010:[<ffffffff81660199>]  [<ffffffff81660199>] __tcp_select_window+0xe9/0x130
RSP: 0000:ffff88022fc83cd0  EFLAGS: 00010246
RAX: 0000000000003908 RBX: ffff88005032eccc RCX: 000000000000ffff
RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000000003908
RBP: ffff88022fc83cd0 R08: 0000000000003908 R09: 0000000000007fff
R10: 0000000000000014 R11: 0000000000000000 R12: ffff88006a1f9200
R13: ffff880101757f00 R14: 0000000000003908 R15: 0000000000000014
FS:  00007f7634433720(0000) GS:ffff88022fc80000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 000000000478c0a8 CR3: 000000013cbd0000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process php4 (pid: 25125, threadinfo ffff88016249a000, task ffff88003b243e40)
Stack:
 ffff88022fc83d50 ffffffff816606e9 ffffffff81660de2 ffff880101757f28
 0000000000000100 0000000000000100 0000000000000000 0000000000000000
 0000000000000000 0000000000000000 0000000000000000 0000000000000000
Call Trace:
 <IRQ> 
 [<ffffffff816606e9>] tcp_transmit_skb+0x209/0x8e0
 [<ffffffff81660de2>] ? tcp_xmit_probe_skb+0x22/0xe0
 [<ffffffff81660e8e>] tcp_xmit_probe_skb+0xce/0xe0
 [<ffffffff8166252e>] tcp_write_wakeup+0x6e/0x180
 [<ffffffff81664897>] tcp_keepalive_timer+0x247/0x270
 [<ffffffff8106cd8d>] run_timer_softirq+0x26d/0x410
 [<ffffffff8106ccb8>] ? run_timer_softirq+0x198/0x410
 [<ffffffff81664650>] ? tcp_init_xmit_timers+0x20/0x20
 [<ffffffff810640e8>] __do_softirq+0x138/0x250
 [<ffffffff817030fc>] call_softirq+0x1c/0x30
 [<ffffffff810153c5>] do_softirq+0x95/0xd0
 [<ffffffff81063cbd>] irq_exit+0xdd/0x110
 [<ffffffff810310c9>] smp_apic_timer_interrupt+0x69/0xa0
 [<ffffffff81701973>] apic_timer_interrupt+0x73/0x80
 <EOI> 
 [<ffffffff81700eca>] ? sysret_check+0x2e/0x69
Code: 89 d0 d3 e0 41 39 c0 74 56 8d 7a 01 d3 e7 89 f8 c9 c3 89 c7 44 89 c0 29 f0 39 f8 7d 05 44 39 c7 7e 30 44 89 c2 44 89 c0 c1 fa 1f <f7> fe 89 c7 0f af fe 89 f8 eb da 0f 1f 40 00 f7 d9 41 89 d0 89 
RIP  [<ffffffff81660199>] __tcp_select_window+0xe9/0x130
 RSP <ffff88022fc83cd0>
divide error: 0000 [#2] 
---[ end trace b3f46c09a69a2efe ]---
Kernel panic - not syncing: Fatal exception in interrupt
Pid: 25125, comm: php4 Tainted: G      D     3.1.0-hw-lockdep+ #57
Call Trace:
 <IRQ>  [<ffffffff816f4364>] panic+0xca/0x210
 [<ffffffff8105cd24>] ? kmsg_dump+0x104/0x160
 [<ffffffff8105cd3c>] ? kmsg_dump+0x11c/0x160
 [<ffffffff8105cc9c>] ? kmsg_dump+0x7c/0x160
 [<ffffffff816fa25c>] oops_end+0xdc/0xf0
 [<ffffffff810166d6>] die+0x56/0x90
 [<ffffffff816f9b8e>] do_trap+0x14e/0x170
 [<ffffffff8101474a>] do_divide_error+0x8a/0xb0
 [<ffffffff81660199>] ? __tcp_select_window+0xe9/0x130
 [<ffffffff81613a53>] ? __netif_receive_skb+0x383/0x560
 [<ffffffff81613835>] ? __netif_receive_skb+0x165/0x560
 [<ffffffff813a614d>] ? trace_hardirqs_off_thunk+0x3a/0x3c
 [<ffffffff816f91a4>] ? restore_args+0x30/0x30
 [<ffffffff81702e1b>] divide_error+0x1b/0x20
 [<ffffffff81660199>] ? __tcp_select_window+0xe9/0x130
 [<ffffffff816606e9>] tcp_transmit_skb+0x209/0x8e0
 [<ffffffff81660de2>] ? tcp_xmit_probe_skb+0x22/0xe0
 [<ffffffff81660e8e>] tcp_xmit_probe_skb+0xce/0xe0
 [<ffffffff8166252e>] tcp_write_wakeup+0x6e/0x180
 [<ffffffff81664897>] tcp_keepalive_timer+0x247/0x270
 [<ffffffff8106cd8d>] run_timer_softirq+0x26d/0x410
 [<ffffffff8106ccb8>] ? run_timer_softirq+0x198/0x410
 [<ffffffff81664650>] ? tcp_init_xmit_timers+0x20/0x20
 [<ffffffff810640e8>] __do_softirq+0x138/0x250
 [<ffffffff817030fc>] call_softirq+0x1c/0x30
 [<ffffffff810153c5>] do_softirq+0x95/0xd0
 [<ffffffff81063cbd>] irq_exit+0xdd/0x110
 [<ffffffff810310c9>] smp_apic_timer_interrupt+0x69/0xa0
 [<ffffffff81701973>] apic_timer_interrupt+0x73/0x80
 <EOI>  [<ffffffff81700eca>] ? sysret_check+0x2e/0x69
SMP 
CPU 3 
Modules linked in: ipmi_devintf ipmi_si ipmi_msghandler xt_recent nf_conntrack_ftp xt_state xt_owner nf_conntrack_ipv4 nf_conntrack nf_defrag_ipv4 bnx2

Pid: 0, comm: kworker/0:1 Tainted: G      D     3.1.0-hw-lockdep+ #57 Dell Inc. PowerEdge 1950/0UR033
RIP: 0010:[<ffffffff81660199>]  [<ffffffff81660199>] __tcp_select_window+0xe9/0x130
RSP: 0018:ffff88022fcc3cd0  EFLAGS: 00010246
RAX: 0000000000003908 RBX: ffff880010ce80cc RCX: 000000000000ffff
RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000000003908
RBP: ffff88022fcc3cd0 R08: 0000000000003908 R09: 0000000000007fff
R10: 0000000000000014 R11: 0000000000000000 R12: ffff88006636a400
R13: ffff88000afb0300 R14: 0000000000003908 R15: 0000000000000014
FS:  0000000000000000(0000) GS:ffff88022fcc0000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 00007fc220c14000 CR3: 000000013cbd0000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process kworker/0:1 (pid: 0, threadinfo ffff880226980000, task ffff880226959f20)
Stack:
 ffff88022fcc3d50 ffffffff816606e9 ffffffff81660de2 ffff88000afb0328
 0000000000000100 0000000000000100 0000000000000000 0000000000000000
 0000000000000000 0000000000000000 0000000000000000 0000000000000000
Call Trace:
 <IRQ> 
 [<ffffffff816606e9>] tcp_transmit_skb+0x209/0x8e0
 [<ffffffff81660de2>] ? tcp_xmit_probe_skb+0x22/0xe0
 [<ffffffff81660e8e>] tcp_xmit_probe_skb+0xce/0xe0
 [<ffffffff8166252e>] tcp_write_wakeup+0x6e/0x180
 [<ffffffff81664897>] tcp_keepalive_timer+0x247/0x270
 [<ffffffff8106cd8d>] run_timer_softirq+0x26d/0x410
 [<ffffffff8106ccb8>] ? run_timer_softirq+0x198/0x410
 [<ffffffff81664650>] ? tcp_init_xmit_timers+0x20/0x20
 [<ffffffff810640e8>] __do_softirq+0x138/0x250
 [<ffffffff817030fc>] call_softirq+0x1c/0x30
 [<ffffffff810153c5>] do_softirq+0x95/0xd0
 [<ffffffff81063cbd>] irq_exit+0xdd/0x110
 [<ffffffff810310c9>] smp_apic_timer_interrupt+0x69/0xa0
 [<ffffffff81701973>] apic_timer_interrupt+0x73/0x80
 <EOI> 
 [<ffffffff8101b80e>] ? mwait_idle+0x14e/0x170
 [<ffffffff8101b805>] ? mwait_idle+0x145/0x170
 [<ffffffff81013156>] cpu_idle+0x96/0xf0
 [<ffffffff816ef30b>] start_secondary+0x1ca/0x1ff
Code: 89 d0 d3 e0 41 39 c0 74 56 8d 7a 01 d3 e7 89 f8 c9 c3 89 c7 44 89 c0 29 f0 39 f8 7d 05 44 39 c7 7e 30 44 89 c2 44 89 c0 c1 fa 1f <f7> fe 89 c7 0f af fe 89 f8 eb da 0f 1f 40 00 f7 d9 41 89 d0 89 
RIP  [<ffffffff81660199>] __tcp_select_window+0xe9/0x130
 RSP <ffff88022fcc3cd0>
divide error: 0000 [#3] SMP 
CPU 1 
Modules linked in: ipmi_devintf ipmi_si ipmi_msghandler xt_recent nf_conntrack_ftp xt_state xt_owner nf_conntrack_ipv4 nf_conntrack nf_defrag_ipv4 bnx2

Pid: 25118, comm: search.pl Tainted: G      D     3.1.0-hw-lockdep+ #57 Dell Inc. PowerEdge 1950/0UR033
RIP: 0010:[<ffffffff81660199>]  [<ffffffff81660199>] __tcp_select_window+0xe9/0x130
RSP: 0018:ffff88022fc43cd0  EFLAGS: 00010246
RAX: 0000000000003908 RBX: ffff88003d808ccc RCX: 000000000000ffff
RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000000003908
RBP: ffff88022fc43cd0 R08: 0000000000003908 R09: 0000000000007fff
R10: 0000000000000014 R11: 0000000000000000 R12: ffff88001966da00
R13: ffff8800a4665500 R14: 0000000000003908 R15: 0000000000000014
FS:  00007f0872f48700(0000) GS:ffff88022fc40000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000003f0f470 CR3: 000000015e1ad000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process search.pl (pid: 25118, threadinfo ffff880109992000, task ffff880214f40000)
Stack:
 ffff88022fc43d50 ffffffff816606e9 ffffffff81660de2 ffff8800a4665528
 0000000000000100 0000000000000100 0000000000000000 0000000000000000
 0000000000000000 0000000000000000 0000000000000000 0000000000000000
Call Trace:
 <IRQ> 
 [<ffffffff816606e9>] tcp_transmit_skb+0x209/0x8e0
 [<ffffffff81660de2>] ? tcp_xmit_probe_skb+0x22/0xe0
 [<ffffffff81660e8e>] tcp_xmit_probe_skb+0xce/0xe0
 [<ffffffff8166252e>] tcp_write_wakeup+0x6e/0x180
 [<ffffffff81664897>] tcp_keepalive_timer+0x247/0x270
 [<ffffffff8106cd8d>] run_timer_softirq+0x26d/0x410
 [<ffffffff8106ccb8>] ? run_timer_softirq+0x198/0x410
 [<ffffffff81664650>] ? tcp_init_xmit_timers+0x20/0x20
 [<ffffffff810640e8>] __do_softirq+0x138/0x250
 [<ffffffff817030fc>] call_softirq+0x1c/0x30
 [<ffffffff810153c5>] do_softirq+0x95/0xd0
 [<ffffffff81063cbd>] irq_exit+0xdd/0x110
 [<ffffffff810310c9>] smp_apic_timer_interrupt+0x69/0xa0
 [<ffffffff81701973>] apic_timer_interrupt+0x73/0x80
 <EOI> 
 [<ffffffff8109a802>] ? lock_acquire+0x122/0x140
 [<ffffffff8122bc80>] ? nfs_handle_cb_pathdown+0x20/0x20
 [<ffffffff8122bcc7>] nfs_have_delegation+0x47/0xb0
 [<ffffffff8122bc80>] ? nfs_handle_cb_pathdown+0x20/0x20
 [<ffffffff81205806>] nfs_attribute_cache_expired+0x16/0x70
 [<ffffffff81096c3d>] ? trace_hardirqs_on_caller+0x13d/0x1c0
 [<ffffffff81206e7f>] nfs_revalidate_mapping+0x2f/0x130
 [<ffffffff81204d1f>] nfs_file_read+0x7f/0x120
 [<ffffffff810529dc>] ? finish_task_switch+0x8c/0x100
 [<ffffffff8112aa91>] do_sync_read+0xd1/0x120
 [<ffffffff816f50f2>] ? __schedule+0x5c2/0xa20
 [<ffffffff8112b7b8>] vfs_read+0xc8/0x180
 [<ffffffff8112b960>] sys_read+0x50/0x90
 [<ffffffff81700e92>] system_call_fastpath+0x16/0x1b
Code: 89 d0 d3 e0 41 39 c0 74 56 8d 7a 01 d3 e7 89 f8 c9 c3 89 c7 44 89 c0 29 f0 39 f8 7d 05 44 39 c7 7e 30 44 89 c2 44 89 c0 c1 fa 1f <f7> fe 89 c7 0f af fe 89 f8 eb da 0f 1f 40 00 f7 d9 41 89 d0 89 
RIP  [<ffffffff81660199>] __tcp_select_window+0xe9/0x130
 RSP <ffff88022fc43cd0>
divide error: 0000 [#4] SMP 
CPU 0 
Modules linked in: ipmi_devintf ipmi_si ipmi_msghandler xt_recent nf_conntrack_ftp xt_state xt_owner nf_conntrack_ipv4 nf_conntrack nf_defrag_ipv4 bnx2

Pid: 25177, comm: php Tainted: G      D     3.1.0-hw-lockdep+ #57 Dell Inc. PowerEdge 1950/0UR033
RIP: 0010:[<ffffffff81660199>]  [<ffffffff81660199>] __tcp_select_window+0xe9/0x130
RSP: 0000:ffff88022fc03cd0  EFLAGS: 00010246
RAX: 0000000000003908 RBX: ffff88001519b0cc RCX: 000000000000ffff
RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000000003908
RBP: ffff88022fc03cd0 R08: 0000000000003908 R09: 0000000000007fff
R10: 0000000000000014 R11: 0000000000000000 R12: ffff88000263a400
R13: ffff88016545f300 R14: 0000000000003908 R15: 0000000000000014
FS:  00007ffbdac9b720(0000) GS:ffff88022fc00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000003f97000 CR3: 0000000104c4c000 CR4: 00000000000006f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process php (pid: 25177, threadinfo ffff880214e7c000, task ffff880116940000)
Stack:
 ffff88022fc03d50 ffffffff816606e9 ffffffff81660de2 ffff88016545f328
 0000000000000100 0000000000000100 0000000000000000 0000000000000000
 0000000000000000 0000000000000000 0000000000000000 0000000000000000
Call Trace:
 <IRQ> 
 [<ffffffff816606e9>] tcp_transmit_skb+0x209/0x8e0
 [<ffffffff81660de2>] ? tcp_xmit_probe_skb+0x22/0xe0
 [<ffffffff81660e8e>] tcp_xmit_probe_skb+0xce/0xe0
 [<ffffffff8166252e>] tcp_write_wakeup+0x6e/0x180
 [<ffffffff81664897>] tcp_keepalive_timer+0x247/0x270
 [<ffffffff8106cd8d>] run_timer_softirq+0x26d/0x410
 [<ffffffff8106ccb8>] ? run_timer_softirq+0x198/0x410
 [<ffffffff81664650>] ? tcp_init_xmit_timers+0x20/0x20
 [<ffffffff810640e8>] __do_softirq+0x138/0x250
 [<ffffffff817030fc>] call_softirq+0x1c/0x30
 [<ffffffff810153c5>] do_softirq+0x95/0xd0
 [<ffffffff81063cbd>] irq_exit+0xdd/0x110
 [<ffffffff810310c9>] smp_apic_timer_interrupt+0x69/0xa0
 [<ffffffff81701973>] apic_timer_interrupt+0x73/0x80
 <EOI> 
 [<ffffffff81700eca>] ? sysret_check+0x2e/0x69
Code: 89 d0 d3 e0 41 39 c0 74 56 8d 7a 01 d3 e7 89 f8 c9 c3 89 c7 44 89 c0 29 f0 39 f8 7d 05 44 39 c7 7e 30 44 89 c2 44 89 c0 c1 fa 1f <f7> fe 89 c7 0f af fe 89 f8 eb da 0f 1f 40 00 f7 d9 41 89 d0 89 
RIP  [<ffffffff81660199>] __tcp_select_window+0xe9/0x130
 RSP <ffff88022fc03cd0>

(gdb) disassemble /m __tcp_select_window
Dump of assembler code for function __tcp_select_window:
1895    {
   0xffffffff81628ec0 <+0>:     push   %rbp
   0xffffffff81628ed3 <+19>:    mov    %rsp,%rbp

1896            struct inet_connection_sock *icsk = inet_csk(sk);
1897            struct tcp_sock *tp = tcp_sk(sk);
1898            /* MSS for the peer's data.  Previous versions used mss_clamp
1899             * here.  I don't know if the value based on our guesses
1900             * of peer's MSS is better for the performance.  It's more correct
1901             * but may be worse for the performance because of rcv_mss
1902             * fluctuations.  --SAW  1998/11/1
1903             */
1904            int mss = icsk->icsk_ack.rcv_mss;
   0xffffffff81628ed6 <+22>:    movzwl 0x3c6(%rdi),%r9d
   0xffffffff81628f06 <+70>:    movzwl %r9w,%eax
   0xffffffff81628f0d <+77>:    mov    %eax,%esi
   0xffffffff81628f0f <+79>:    cmp    %eax,%ecx
   0xffffffff81628f14 <+84>:    cmovle %ecx,%esi

1905            int free_space = tcp_space(sk);
1906            int full_space = min_t(int, tp->window_clamp, tcp_full_space(sk));
   0xffffffff81628eef <+47>:    mov    0x4a8(%rdi),%edx
   0xffffffff81628f02 <+66>:    cmp    %eax,%edx
   0xffffffff81628f04 <+68>:    mov    %eax,%ecx
   0xffffffff81628f0a <+74>:    cmovle %edx,%ecx
   0xffffffff81628fc2 <+258>:   mov    0x4a8(%rdi),%edx

1907            int window;
1908
1909            if (mss > full_space)
1910                    mss = full_space;
1911
1912            if (free_space < (full_space >> 1)) {
   0xffffffff81628f11 <+81>:    mov    %ecx,%r9d
   0xffffffff81628f17 <+87>:    sar    %r9d
   0xffffffff81628f1a <+90>:    cmp    %r8d,%r9d
   0xffffffff81628f1d <+93>:    jle    0xffffffff81628f54 <__tcp_select_window+148>

1913                    icsk->icsk_ack.quick = 0;
   0xffffffff81628f1f <+95>:    movb   $0x0,0x3b1(%rdi)

1914
1915                    if (tcp_memory_pressure)
   0xffffffff81628f26 <+102>:   mov    0x412633(%rip),%r10d        # 0xffffffff81a3b560
   0xffffffff81628f2d <+109>:   test   %r10d,%r10d
   0xffffffff81628f30 <+112>:   je     0xffffffff81628f4d <__tcp_select_window+141>

1916                            tp->rcv_ssthresh = min(tp->rcv_ssthresh,
   0xffffffff81628f32 <+114>:   movzwl 0x4b4(%rdi),%edx
   0xffffffff81628f39 <+121>:   mov    0x4ac(%rdi),%eax
   0xffffffff81628f3f <+127>:   shl    $0x2,%edx
   0xffffffff81628f42 <+130>:   cmp    %eax,%edx
   0xffffffff81628f44 <+132>:   cmovbe %edx,%eax
   0xffffffff81628f47 <+135>:   mov    %eax,0x4ac(%rdi)

1917                                                   4U * tp->advmss);
1918
1919                    if (free_space < mss)
   0xffffffff81628f4d <+141>:   xor    %eax,%eax
   0xffffffff81628f4f <+143>:   cmp    %esi,%r8d
   0xffffffff81628f52 <+146>:   jl     0xffffffff81628f8e <__tcp_select_window+206>

1920                            return 0;
1921            }
1922
1923            if (free_space > tp->rcv_ssthresh)
   0xffffffff81628f54 <+148>:   mov    0x4ac(%rdi),%eax

1924                    free_space = tp->rcv_ssthresh;
   0xffffffff81628f61 <+161>:   cmp    %eax,%r8d
   0xffffffff81628f64 <+164>:   cmova  %eax,%r8d

1925
1926            /* Don't do rounding if we are using window scaling, since the
1927             * scaled window will not line up with the MSS boundary anyway.
1928             */
1929            window = tp->rcv_wnd;
   0xffffffff81628f6b <+171>:   mov    0x518(%rdi),%eax
   0xffffffff81628f90 <+208>:   mov    %eax,%edi

1930            if (tp->rx_opt.rcv_wscale) {
   0xffffffff81628f5a <+154>:   movzbl 0x4f5(%rdi),%edx
   0xffffffff81628f68 <+168>:   test   $0xf0,%dl
   0xffffffff81628f71 <+177>:   je     0xffffffff81628f90 <__tcp_select_window+208>

1931                    window = free_space;
1932
1933                    /* Advertise enough space so that it won't get scaled away.
1934                     * Import case: prevent zero window announcement if
1935                     * 1<<rcv_wscale > mss.
1936                     */
1937                    if (((window >> tp->rx_opt.rcv_wscale) << tp->rx_opt.rcv_wscale) != window)
   0xffffffff81628f73 <+179>:   shr    $0x4,%dl
   0xffffffff81628f76 <+182>:   movzbl %dl,%ecx
   0xffffffff81628f79 <+185>:   mov    %r8d,%edx
   0xffffffff81628f7c <+188>:   sar    %cl,%edx
   0xffffffff81628f7e <+190>:   mov    %edx,%eax
   0xffffffff81628f80 <+192>:   shl    %cl,%eax
   0xffffffff81628f82 <+194>:   cmp    %eax,%r8d
   0xffffffff81628f85 <+197>:   je     0xffffffff81628fdd <__tcp_select_window+285>

1938                            window = (((window >> tp->rx_opt.rcv_wscale) + 1)
   0xffffffff81628f87 <+199>:   lea    0x1(%rdx),%edi
   0xffffffff81628f8a <+202>:   shl    %cl,%edi

1939                                      << tp->rx_opt.rcv_wscale);
1940            } else {
1941                    /* Get the largest window that is a nice multiple of mss.
1942                     * Window clamp already applied above.
1943                     * If our current window offering is within 1 mss of the
1944                     * free space we just keep it. This prevents the divide
1945                     * and multiply from happening most of the time.
1946                     * We also don't do any window rounding when the free space
1947                     * is too small.
1948                     */
1949                    if (window <= free_space - mss || window > free_space)
   0xffffffff81628f92 <+210>:   mov    %r8d,%eax
   0xffffffff81628f95 <+213>:   sub    %esi,%eax
   0xffffffff81628f97 <+215>:   cmp    %edi,%eax
   0xffffffff81628f99 <+217>:   jge    0xffffffff81628fa0 <__tcp_select_window+224>
   0xffffffff81628f9b <+219>:   cmp    %r8d,%edi
   0xffffffff81628f9e <+222>:   jle    0xffffffff81628fd0 <__tcp_select_window+272>

1950                            window = (free_space / mss) * mss;
   0xffffffff81628fa0 <+224>:   mov    %r8d,%edx
   0xffffffff81628fa3 <+227>:   mov    %r8d,%eax
   0xffffffff81628fa6 <+230>:   sar    $0x1f,%edx
   0xffffffff81628fa9 <+233>:   idiv   %esi
   0xffffffff81628fab <+235>:   mov    %eax,%edi
   0xffffffff81628fad <+237>:   imul   %esi,%edi

1951                    else if (mss == full_space &&
   0xffffffff81628fd0 <+272>:   cmp    %esi,%ecx
   0xffffffff81628fd2 <+274>:   jne    0xffffffff81628f8c <__tcp_select_window+204>
   0xffffffff81628fd4 <+276>:   lea    (%r9,%rdi,1),%eax
   0xffffffff81628fd8 <+280>:   cmp    %eax,%r8d
   0xffffffff81628fdb <+283>:   jle    0xffffffff81628f8c <__tcp_select_window+204>
   0xffffffff81628fdd <+285>:   mov    %r8d,%edi

1952                             free_space > window + (full_space >> 1))
1953                            window = free_space;
1954            }
1955
1956            return window;
   0xffffffff81628f8c <+204>:   mov    %edi,%eax
   0xffffffff81628fb0 <+240>:   mov    %edi,%eax
   0xffffffff81628fb2 <+242>:   jmp    0xffffffff81628f8e <__tcp_select_window+206>
   0xffffffff81628fb4 <+244>:   nopl   0x0(%rax)
   0xffffffff81628fe0 <+288>:   mov    %edi,%eax
   0xffffffff81628fe2 <+290>:   jmp    0xffffffff81628f8e <__tcp_select_window+206>
   0xffffffff81628fe4:  data32 data32 nopw %cs:0x0(%rax,%rax,1)

1957    }
   0xffffffff81628f8e <+206>:   leaveq
   0xffffffff81628f8f <+207>:   retq

End of assembler dump.
