From: igorm@etf.rs
Subject: [PATCH 0/1] jump_label logic fixing in dev.c
Date: Mon, 28 Nov 2011 21:23:15 +0100
Message-ID: <1322511796-6908-1-git-send-email-igorm@etf.rs>
References: <igorm@etf.rs>
Cc: eric.dumazet@gmail.com, Igor Maravic <igorm@etf.rs>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.etf.rs ([147.91.14.170]:46631 "EHLO mx2.etf.bg.ac.rs"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753677Ab1K1UXW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Nov 2011 15:23:22 -0500
In-Reply-To: <igorm@etf.rs>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Igor Maravic <igorm@etf.rs>

Hi all,
I had the problem with this specific patch:
http://git.kernel.org/?p=linux/kernel/git/davem/net-next.git;a=commitdiff;h=588f033075d8c7efe28695402114eab3f9da47c4;hp=66846048f55c6c05a4c46c2daabb773173f8f28d
Problem was occurring when I would ping unreachable host and then, after some while,
I would type Ctrl+C. This is the Call Trace:

------------
Nov 25 14:34:41 igortest kernel: [  102.264227] BUG: sleeping function called from invalid context at kernel/mutex.c:271
Nov 25 14:34:41 igortest kernel: [  102.264273] in_atomic(): 1, irqs_disabled(): 0, pid: 0, name: swapper
Nov 25 14:34:41 igortest kernel: [  102.264305] 1 lock held by swapper/0:
Nov 25 14:34:41 igortest kernel: [  102.264307]  #0:  (&n->timer){+.-...}, at: [<ffffffff8107ce90>] call_timer_fn+0x0/0x340
Nov 25 14:34:41 igortest kernel: [  102.264318] Pid: 0, comm: swapper Not tainted 3.2.0-rc2-net-next-mpls+ #1
Nov 25 14:34:41 igortest kernel: [  102.264320] Call Trace:
Nov 25 14:34:41 igortest kernel: [  102.264321]  <IRQ>  [<ffffffff8104f417>] __might_sleep+0x137/0x1f0
Nov 25 14:34:41 igortest kernel: [  102.264330]  [<ffffffff816b9a2f>] mutex_lock_nested+0x2f/0x370
Nov 25 14:34:41 igortest kernel: [  102.264334]  [<ffffffff810a89fd>] ? trace_hardirqs_off+0xd/0x10
Nov 25 14:34:41 igortest kernel: [  102.264337]  [<ffffffff8109a37f>] ? local_clock+0x6f/0x80
Nov 25 14:34:41 igortest kernel: [  102.264340]  [<ffffffff810a90a5>] ? lock_release_holdtime.part.22+0x15/0x1a0
Nov 25 14:34:41 igortest kernel: [  102.264344]  [<ffffffff81557929>] ? sock_def_write_space+0x59/0x160
Nov 25 14:34:41 igortest kernel: [  102.264347]  [<ffffffff815e936e>] ? arp_error_report+0x3e/0x90
Nov 25 14:34:41 igortest kernel: [  102.264350]  [<ffffffff810969cd>] atomic_dec_and_mutex_lock+0x5d/0x80
Nov 25 14:34:41 igortest kernel: [  102.264354]  [<ffffffff8112fc1d>] jump_label_dec+0x1d/0x50
Nov 25 14:34:41 igortest kernel: [  102.264357]  [<ffffffff81566525>] net_disable_timestamp+0x15/0x20
Nov 25 14:34:41 igortest kernel: [  102.264360]  [<ffffffff81557a75>] sock_disable_timestamp+0x45/0x50
Nov 25 14:34:41 igortest kernel: [  102.264362]  [<ffffffff81557b00>] __sk_free+0x80/0x200
Nov 25 14:34:41 igortest kernel: [  102.264365]  [<ffffffff815578d0>] ? sk_send_sigurg+0x70/0x70
Nov 25 14:34:42 igortest kernel: [  102.264367]  [<ffffffff815e936e>] ? arp_error_report+0x3e/0x90
Nov 25 14:34:42 igortest kernel: [  102.264370]  [<ffffffff81557cba>] sock_wfree+0x3a/0x70
Nov 25 14:34:42 igortest kernel: [  102.264373]  [<ffffffff8155c2b0>] skb_release_head_state+0x70/0x120
Nov 25 14:34:42 igortest kernel: [  102.264376]  [<ffffffff8155c0b6>] __kfree_skb+0x16/0x30
Nov 25 14:34:42 igortest kernel: [  102.264378]  [<ffffffff8155c119>] kfree_skb+0x49/0x170
Nov 25 14:34:42 igortest kernel: [  102.264381]  [<ffffffff815e936e>] arp_error_report+0x3e/0x90
Nov 25 14:34:42 igortest kernel: [  102.264384]  [<ffffffff81575bd9>] neigh_invalidate+0x89/0xc0
Nov 25 14:34:42 igortest kernel: [  102.264387]  [<ffffffff81578dbe>] neigh_timer_handler+0x9e/0x2a0
Nov 25 14:34:42 igortest kernel: [  102.264389]  [<ffffffff81578d20>] ? neigh_update+0x640/0x640
Nov 25 14:34:42 igortest kernel: [  102.264406]  [<ffffffff81073558>] __do_softirq+0xc8/0x3a0
Nov 25 14:34:42 igortest kernel: [  102.264409]  [<ffffffff810a4864>] ? clockevents_program_event+0x74/0x100
Nov 25 14:34:42 igortest kernel: [  102.264411]  [<ffffffff810a5f34>] ? tick_program_event+0x24/0x30
Nov 25 14:34:42 igortest kernel: [  102.264415]  [<ffffffff816c6ffc>] call_softirq+0x1c/0x30
Nov 25 14:34:42 igortest kernel: [  102.264418]  [<ffffffff8101b615>] do_softirq+0xa5/0xe0
Nov 25 14:34:42 igortest kernel: [  102.264420]  [<ffffffff81073bbe>] irq_exit+0xae/0xe0
Nov 25 14:34:42 igortest kernel: [  102.264423]  [<ffffffff816c72de>] smp_apic_timer_interrupt+0x6e/0x99
Nov 25 14:34:42 igortest kernel: [  102.264426]  [<ffffffff816c6473>] apic_timer_interrupt+0x73/0x80
Nov 25 14:34:42 igortest kernel: [  102.264427]  <EOI>  [<ffffffff816c0c20>] ? notifier_call_chain+0x100/0x100
Nov 25 14:34:42 igortest kernel: [  102.264433]  [<ffffffff810400ab>] ? native_safe_halt+0xb/0x10
Nov 25 14:34:42 igortest kernel: [  102.264436]  [<ffffffff810ac86d>] ? trace_hardirqs_on+0xd/0x10
Nov 25 14:34:42 igortest kernel: [  102.264439]  [<ffffffff8102202a>] default_idle+0x4a/0x290
Nov 25 14:34:42 igortest kernel: [  102.264441]  [<ffffffff81022338>] amd_e400_idle+0xc8/0x160
Nov 25 14:34:42 igortest kernel: [  102.264444]  [<ffffffff81018239>] cpu_idle+0xe9/0x150
Nov 25 14:34:42 igortest kernel: [  102.264447]  [<ffffffff81684cce>] rest_init+0xd2/0xe4
Nov 25 14:34:42 igortest kernel: [  102.264450]  [<ffffffff81684bfc>] ? csum_partial_copy_generic+0x16c/0x16c
Nov 25 14:34:42 igortest kernel: [  102.264453]  [<ffffffff81eb5c69>] start_kernel+0x3fb/0x407
Nov 25 14:34:42 igortest kernel: [  102.264456]  [<ffffffff81eb5388>] x86_64_start_reservations+0x132/0x136
Nov 25 14:34:42 igortest kernel: [  102.264459]  [<ffffffff81eb5140>] ? early_idt_handlers+0x140/0x140
Nov 25 14:34:42 igortest kernel: [  102.264461]  [<ffffffff81eb5459>] x86_64_start_kernel+0xcd/0xdc
Nov 25 14:34:42 igortest kernel: [  102.264470]
Nov 25 14:34:42 igortest kernel: [  102.264479] =================================
Nov 25 14:34:42 igortest kernel: [  102.264501] [ INFO: inconsistent lock state ]
Nov 25 14:34:42 igortest kernel: [  102.264523] 3.2.0-rc2-net-next-mpls+ #1
Nov 25 14:34:42 igortest kernel: [  102.264542] ---------------------------------
Nov 25 14:34:42 igortest kernel: [  102.264564] inconsistent {SOFTIRQ-ON-W} -> {IN-SOFTIRQ-W} usage.
Nov 25 14:34:42 igortest kernel: [  102.264594] swapper/0 [HC0[0]:SC1[1]:HE1:SE0] takes:
Nov 25 14:34:42 igortest kernel: [  102.264618]  (jump_label_mutex){+.?.+.}, at: [<ffffffff810969cd>] atomic_dec_and_mutex_lock+0x5d/0x80
Nov 25 14:34:42 igortest kernel: [  102.265911] {SOFTIRQ-ON-W} state was registered at:
Nov 25 14:34:42 igortest kernel: [  102.267182]   [<ffffffff810ac44f>] mark_irqflags+0x15f/0x1c0
Nov 25 14:34:42 igortest kernel: [  102.268082]   [<ffffffff810ae81b>] __lock_acquire+0x5cb/0xb40
Nov 25 14:34:42 igortest kernel: [  102.268082]   [<ffffffff810af48a>] lock_acquire+0xaa/0x200
Nov 25 14:34:42 igortest kernel: [  102.268082]   [<ffffffff816b9a78>] mutex_lock_nested+0x78/0x370
Nov 25 14:34:42 igortest kernel: [  102.268082]   [<ffffffff8112fa67>] jump_label_lock+0x17/0x20
Nov 25 14:34:42 igortest kernel: [  102.268082]   [<ffffffff8112fb25>] jump_label_module_notify+0x95/0xe0
Nov 25 14:34:42 igortest kernel: [  102.268082]   [<ffffffff816c0bb3>] notifier_call_chain+0x93/0x100
Nov 25 14:34:42 igortest kernel: [  102.268082]   [<ffffffff81099d28>] __blocking_notifier_call_chain+0x78/0xb0
Nov 25 14:34:42 igortest kernel: [  102.268082]   [<ffffffff81099d76>] blocking_notifier_call_chain+0x16/0x20
Nov 25 14:34:42 igortest kernel: [  102.268082]   [<ffffffff810be911>] sys_init_module+0x71/0x230
Nov 25 14:34:42 igortest kernel: [  102.268082]   [<ffffffff816c5902>] system_call_fastpath+0x16/0x1b
Nov 25 14:34:42 igortest kernel: [  102.268082] irq event stamp: 356072
Nov 25 14:34:42 igortest kernel: [  102.268082] hardirqs last  enabled at (356072): [<ffffffff81072dc7>] local_bh_enable_ip+0x97/0x100
Nov 25 14:34:42 igortest kernel: [  102.268082] hardirqs last disabled at (356071): [<ffffffff81072d74>] local_bh_enable_ip+0x44/0x100
Nov 25 14:34:42 igortest kernel: [  102.268082] softirqs last  enabled at (355994): [<ffffffff81072263>] _local_bh_enable+0x13/0x20
Nov 25 14:34:42 igortest kernel: [  102.268082] softirqs last disabled at (355995): [<ffffffff816c6ffc>] call_softirq+0x1c/0x30
Nov 25 14:34:42 igortest kernel: [  102.268082]
Nov 25 14:34:42 igortest kernel: [  102.268082] other info that might help us debug this:
Nov 25 14:34:42 igortest kernel: [  102.268082]  Possible unsafe locking scenario:
Nov 25 14:34:42 igortest kernel: [  102.268082]
Nov 25 14:34:42 igortest kernel: [  102.268082]        CPU0
Nov 25 14:34:42 igortest kernel: [  102.268082]        ----
Nov 25 14:34:42 igortest kernel: [  102.268082]   lock(jump_label_mutex);
Nov 25 14:34:42 igortest kernel: [  102.268082]   <Interrupt>
Nov 25 14:34:42 igortest kernel: [  102.268082]     lock(jump_label_mutex);
Nov 25 14:34:42 igortest kernel: [  102.268082]
Nov 25 14:34:42 igortest kernel: [  102.268082]  *** DEADLOCK ***
Nov 25 14:34:42 igortest kernel: [  102.268082]
Nov 25 14:34:42 igortest kernel: [  102.268082] 1 lock held by swapper/0:
Nov 25 14:34:42 igortest kernel: [  102.268082]  #0:  (&n->timer){+.-...}, at: [<ffffffff8107ce90>] call_timer_fn+0x0/0x340
Nov 25 14:34:42 igortest kernel: [  102.268082]
Nov 25 14:34:42 igortest kernel: [  102.268082] stack backtrace:
Nov 25 14:34:42 igortest kernel: [  102.268082] Pid: 0, comm: swapper Not tainted 3.2.0-rc2-net-next-mpls+ #1
Nov 25 14:34:42 igortest kernel: [  102.268082] Call Trace:
Nov 25 14:34:42 igortest kernel: [  102.268082]  <IRQ>  [<ffffffff816a3725>] print_usage_bug+0x164/0x175
Nov 25 14:34:42 igortest kernel: [  102.268082]  [<ffffffff810aa520>] ? print_irq_inversion_bug.part.33+0x1f0/0x1f0
Nov 25 14:34:42 igortest kernel: [  102.268082]  [<ffffffff816a37a2>] mark_lock_irq+0x6c/0x137
Nov 25 14:34:42 igortest kernel: [  102.268082]  [<ffffffff810ac225>] mark_lock+0x125/0x1f0
Nov 25 14:34:42 igortest kernel: [  102.268082]  [<ffffffff810ac409>] mark_irqflags+0x119/0x1c0
Nov 25 14:34:42 igortest kernel: [  102.268082]  [<ffffffff810ae81b>] __lock_acquire+0x5cb/0xb40
Nov 25 14:34:42 igortest kernel: [  102.268082]  [<ffffffff810af48a>] lock_acquire+0xaa/0x200
Nov 25 14:34:42 igortest kernel: [  102.268082]  [<ffffffff810969cd>] ? atomic_dec_and_mutex_lock+0x5d/0x80
Nov 25 14:34:42 igortest kernel: [  102.268082]  [<ffffffff8169f6b2>] ? dump_stack+0x77/0x80
Nov 25 14:34:42 igortest kernel: [  102.268082]  [<ffffffff816b9a78>] mutex_lock_nested+0x78/0x370
Nov 25 14:34:42 igortest kernel: [  102.268082]  [<ffffffff810969cd>] ? atomic_dec_and_mutex_lock+0x5d/0x80
Nov 25 14:34:42 igortest kernel: [  102.268082]  [<ffffffff810a89fd>] ? trace_hardirqs_off+0xd/0x10
Nov 25 14:34:42 igortest kernel: [  102.268082]  [<ffffffff8109a37f>] ? local_clock+0x6f/0x80
Nov 25 14:34:42 igortest kernel: [  102.268082]  [<ffffffff810969cd>] ? atomic_dec_and_mutex_lock+0x5d/0x80
Nov 25 14:34:42 igortest kernel: [  102.268082]  [<ffffffff810a90a5>] ? lock_release_holdtime.part.22+0x15/0x1a0
Nov 25 14:34:42 igortest kernel: [  102.268082]  [<ffffffff81557929>] ? sock_def_write_space+0x59/0x160
Nov 25 14:34:42 igortest kernel: [  102.268082]  [<ffffffff815e936e>] ? arp_error_report+0x3e/0x90
Nov 25 14:34:42 igortest kernel: [  102.268082]  [<ffffffff810969cd>] atomic_dec_and_mutex_lock+0x5d/0x80
Nov 25 14:34:42 igortest kernel: [  102.268082]  [<ffffffff8112fc1d>] jump_label_dec+0x1d/0x50
Nov 25 14:34:42 igortest kernel: [  102.268082]  [<ffffffff81566525>] net_disable_timestamp+0x15/0x20
Nov 25 14:34:42 igortest kernel: [  102.268082]  [<ffffffff81557a75>] sock_disable_timestamp+0x45/0x50
Nov 25 14:34:42 igortest kernel: [  102.268082]  [<ffffffff81557b00>] __sk_free+0x80/0x200
Nov 25 14:34:42 igortest kernel: [  102.268082]  [<ffffffff815578d0>] ? sk_send_sigurg+0x70/0x70
Nov 25 14:34:42 igortest kernel: [  102.268082]  [<ffffffff815e936e>] ? arp_error_report+0x3e/0x90
Nov 25 14:34:42 igortest kernel: [  102.268082]  [<ffffffff81557cba>] sock_wfree+0x3a/0x70
Nov 25 14:34:42 igortest kernel: [  102.268082]  [<ffffffff8155c2b0>] skb_release_head_state+0x70/0x120
Nov 25 14:34:42 igortest kernel: [  102.268082]  [<ffffffff8155c0b6>] __kfree_skb+0x16/0x30
Nov 25 14:34:42 igortest kernel: [  102.268082]  [<ffffffff8155c119>] kfree_skb+0x49/0x170
Nov 25 14:34:42 igortest kernel: [  102.268082]  [<ffffffff815e936e>] arp_error_report+0x3e/0x90
Nov 25 14:34:42 igortest kernel: [  102.268082]  [<ffffffff81575bd9>] neigh_invalidate+0x89/0xc0
Nov 25 14:34:42 igortest kernel: [  102.268082]  [<ffffffff81578dbe>] neigh_timer_handler+0x9e/0x2a0
Nov 25 14:34:42 igortest kernel: [  102.268082]  [<ffffffff81578d20>] ? neigh_update+0x640/0x640
Nov 25 14:34:42 igortest kernel: [  102.268082]  [<ffffffff8107cf1a>] call_timer_fn+0x8a/0x340
Nov 25 14:34:42 igortest kernel: [  102.268082]  [<ffffffff8107ce90>] ? init_timer_deferrable_key+0x30/0x30
Nov 25 14:34:42 igortest kernel: [  102.268082]  [<ffffffff8107d309>] run_timer_softirq+0x139/0x300
Nov 25 14:34:42 igortest kernel: [  102.268082]  [<ffffffff81073511>] ? __do_softirq+0x81/0x3a0
Nov 25 14:34:42 igortest kernel: [  102.268082]  [<ffffffff81578d20>] ? neigh_update+0x640/0x640
Nov 25 14:34:42 igortest kernel: [  102.268082]  [<ffffffff81073558>] __do_softirq+0xc8/0x3a0
Nov 25 14:34:42 igortest kernel: [  102.268082]  [<ffffffff810a4864>] ? clockevents_program_event+0x74/0x100
Nov 25 14:34:42 igortest kernel: [  102.268082]  [<ffffffff810a5f34>] ? tick_program_event+0x24/0x30
Nov 25 14:34:42 igortest kernel: [  102.268082]  [<ffffffff816c6ffc>] call_softirq+0x1c/0x30
Nov 25 14:34:42 igortest kernel: [  102.268082]  [<ffffffff8101b615>] do_softirq+0xa5/0xe0
Nov 25 14:34:42 igortest kernel: [  102.268082]  [<ffffffff81073bbe>] irq_exit+0xae/0xe0
Nov 25 14:34:42 igortest kernel: [  102.268082]  [<ffffffff816c72de>] smp_apic_timer_interrupt+0x6e/0x99
Nov 25 14:34:42 igortest kernel: [  102.268082]  [<ffffffff816c6473>] apic_timer_interrupt+0x73/0x80
Nov 25 14:34:42 igortest kernel: [  102.268082]  <EOI>  [<ffffffff816c0c20>] ? notifier_call_chain+0x100/0x100
Nov 25 14:34:42 igortest kernel: [  102.268082]  [<ffffffff810400ab>] ? native_safe_halt+0xb/0x10
Nov 25 14:34:42 igortest kernel: [  102.268082]  [<ffffffff810ac86d>] ? trace_hardirqs_on+0xd/0x10
Nov 25 14:34:42 igortest kernel: [  102.268082]  [<ffffffff8102202a>] default_idle+0x4a/0x290
Nov 25 14:34:42 igortest kernel: [  102.268082]  [<ffffffff81022338>] amd_e400_idle+0xc8/0x160
Nov 25 14:34:42 igortest kernel: [  102.268082]  [<ffffffff81018239>] cpu_idle+0xe9/0x150
Nov 25 14:34:42 igortest kernel: [  102.268082]  [<ffffffff81684cce>] rest_init+0xd2/0xe4
Nov 25 14:34:42 igortest kernel: [  102.268082]  [<ffffffff81684bfc>] ? csum_partial_copy_generic+0x16c/0x16c
Nov 25 14:34:42 igortest kernel: [  102.268082]  [<ffffffff81eb5c69>] start_kernel+0x3fb/0x407
Nov 25 14:34:42 igortest kernel: [  102.268082]  [<ffffffff81eb5388>] x86_64_start_reservations+0x132/0x136
Nov 25 14:34:42 igortest kernel: [  102.268082]  [<ffffffff81eb5140>] ? early_idt_handlers+0x140/0x140
Nov 25 14:34:42 igortest kernel: [  102.268082]  [<ffffffff81eb5459>] x86_64_start_kernel+0xcd/0xdc
------------------
Problem was calling net_disable_timestamp from Interrupt. By reverting netstamp_needed from jump_label_key 
to atomic_t I solved the problem. 
BR
Igor

Igor Maravic (1):
  netstamp_needed shouldn't be jump_label_key

 net/core/dev.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

-- 
1.7.5.4
