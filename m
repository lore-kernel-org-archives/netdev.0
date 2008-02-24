From: Jan Engelhardt <jengelh@computergmbh.de>
Subject: lockdep warnings in ipv6
Date: Sun, 24 Feb 2008 13:10:58 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0802241307310.15321@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:60444 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750875AbYBXMLA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Feb 2008 07:11:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,


when doing IPv6 (ping6, ssh otherhost, etc.), lockdep spews a warning in 
2.6.25-rc2 on the target. CONFIG_..._FRAME_POINTER is off,

CONFIG_SCHED_NO_NO_OMIT_FRAME_POINTER=y
# CONFIG_FRAME_POINTER is not set

so I am not sure if the stack trace is worth something, is it?

[  449.168320] =======================================================
[  449.168637] [ INFO: possible circular locking dependency detected ]
[  449.168851] 2.6.25-rc2 #67
[  449.168951] -------------------------------------------------------
[  449.169078] swapper/0 is trying to acquire lock:
[  449.169315]  (&tbl->lock){-+-+}, at: [<c023d5a3>] 
neigh_lookup+0x43/0xb0
[  449.170147] 
[  449.170150] but task is already holding lock:
[  449.170309]  (&n->lock){-+-+}, at: [<c023f975>] 
neigh_timer_handler+0x15/0x2a0
[  449.170512] 
[  449.170514] which lock already depends on the new lock.
[  449.170516] 
[  449.170736] 
[  449.170738] the existing dependency chain (in reverse order) is:
[  449.170926] 
[  449.170927] -> #1 (&n->lock){-+-+}:
[  449.171188]        [<c0132266>] add_lock_to_list+0x46/0xc0
[  449.171509]        [<c0134c48>] __lock_acquire+0xb48/0xf90
[  449.171678]        [<c023dcda>] neigh_periodic_timer+0x7a/0x170
[  449.171849]        [<c01350ef>] lock_acquire+0x5f/0x80
[  449.172007]        [<c023dcda>] neigh_periodic_timer+0x7a/0x170
[  449.172173]        [<c029b239>] _write_lock+0x29/0x40
[  449.172342]        [<c023dcda>] neigh_periodic_timer+0x7a/0x170
[  449.172508]        [<c023dcda>] neigh_periodic_timer+0x7a/0x170
[  449.172670]        [<c011dd5f>] run_timer_softirq+0x15f/0x1c0
[  449.172984]        [<c023dc60>] neigh_periodic_timer+0x0/0x170
[  449.173180]        [<c023dc60>] neigh_periodic_timer+0x0/0x170
[  449.173349]        [<c011a182>] __do_softirq+0x52/0xb0
[  449.173516]        [<c011a225>] do_softirq+0x45/0x50
[  449.173675]        [<c011a665>] irq_exit+0x55/0x70
[  449.173831]        [<c0104e83>] do_IRQ+0x43/0x90
[  449.173987]        [<c0103214>] common_interrupt+0x24/0x40
[  449.174147]        [<c010321e>] common_interrupt+0x2e/0x40
[  449.174308]        [<ffffffff>] 0xffffffff
[  449.174767] 
[  449.174769] -> #0 (&tbl->lock){-+-+}:
[  449.174939]        [<c01324f0>] print_circular_bug_entry+0x40/0x50
[  449.175108]        [<c0134a71>] __lock_acquire+0x971/0xf90
[  449.175268]        [<c013425e>] __lock_acquire+0x15e/0xf90
[  449.175468]        [<c0133c16>] trace_hardirqs_on+0x66/0x110
[  449.175633]        [<c01350ef>] lock_acquire+0x5f/0x80
[  449.175793]        [<c023d5a3>] neigh_lookup+0x43/0xb0
[  449.175973]        [<c029b2fe>] _read_lock_bh+0x2e/0x40
[  449.176139]        [<c023d5a3>] neigh_lookup+0x43/0xb0
[  449.176303]        [<c023d5a3>] neigh_lookup+0x43/0xb0
[  449.177821]        [<c8a74a8c>] ndisc_dst_alloc+0x13c/0x1a0 [ipv6]
[  449.177821]        [<c8a74950>] ndisc_dst_alloc+0x0/0x1a0 [ipv6]
[  449.177821]        [<c8a78575>] __ndisc_send+0x95/0x4e0 [ipv6]
[  449.177821]        [<c8a67410>] ip6_output+0x0/0xb00 [ipv6]
[  449.177821]        [<c8a79467>] ndisc_send_ns+0x67/0xa0 [ipv6]
[  449.177821]        [<c8a6eeb0>] ipv6_chk_addr+0xa0/0xb0 [ipv6]
[  449.177821]        [<c8a7a4ef>] ndisc_solicit+0x9f/0x1b0 [ipv6]
[  449.177821]        [<c0133af8>] mark_held_locks+0x38/0x70
[  449.177821]        [<c029b665>] _spin_unlock_irqrestore+0x45/0x60
[  449.177821]        [<c0133c16>] trace_hardirqs_on+0x66/0x110
[  449.177821]        [<c023fab5>] neigh_timer_handler+0x155/0x2a0
[  449.177821]        [<c011dd5f>] run_timer_softirq+0x15f/0x1c0
[  449.177821]        [<c023f960>] neigh_timer_handler+0x0/0x2a0
[  449.177821]        [<c023f960>] neigh_timer_handler+0x0/0x2a0
[  449.177821]        [<c011a182>] __do_softirq+0x52/0xb0
[  449.177821]        [<c011a225>] do_softirq+0x45/0x50
[  449.177821]        [<c011a665>] irq_exit+0x55/0x70
[  449.177821]        [<c0104e83>] do_IRQ+0x43/0x90
[  449.177821]        [<c0103214>] common_interrupt+0x24/0x40
[  449.177821]        [<c010321e>] common_interrupt+0x2e/0x40
[  449.177821]        [<c0101ace>] default_idle+0x5e/0x90
[  449.177821]        [<c0101a70>] default_idle+0x0/0x90
[  449.177821]        [<c0101910>] cpu_idle+0x30/0x80
[  449.177821]        [<ffffffff>] 0xffffffff
[  449.177821] 
[  449.177821] other info that might help us debug this:
[  449.177821] 
[  449.177821] 1 lock held by swapper/0:
[  449.177821]  #0:  (&n->lock){-+-+}, at: [<c023f975>] 
neigh_timer_handler+0x15/0x2a0
[  449.177821] 
[  449.177821] stack backtrace:
[  449.177821] Pid: 0, comm: swapper Not tainted 2.6.25-rc2 #67
[  449.177821]  [<c0132d72>] print_circular_bug_tail+0x72/0x80
[  449.177821]  [<c0134a71>] __lock_acquire+0x971/0xf90
[  449.177821]  [<c013425e>] __lock_acquire+0x15e/0xf90
[  449.177821]  [<c0133c16>] trace_hardirqs_on+0x66/0x110
[  449.177821]  [<c01350ef>] lock_acquire+0x5f/0x80
[  449.177821]  [<c023d5a3>] neigh_lookup+0x43/0xb0
[  449.177821]  [<c029b2fe>] _read_lock_bh+0x2e/0x40
[  449.177821]  [<c023d5a3>] neigh_lookup+0x43/0xb0
[  449.177821]  [<c023d5a3>] neigh_lookup+0x43/0xb0
[  449.177821]  [<c8a74a8c>] ndisc_dst_alloc+0x13c/0x1a0 [ipv6]
[  449.177821]  [<c8a74950>] ndisc_dst_alloc+0x0/0x1a0 [ipv6]
[  449.177821]  [<c8a78575>] __ndisc_send+0x95/0x4e0 [ipv6]
[  449.177821]  [<c8a67410>] ip6_output+0x0/0xb00 [ipv6]
[  449.177821]  [<c8a79467>] ndisc_send_ns+0x67/0xa0 [ipv6]
[  449.177821]  [<c8a6eeb0>] ipv6_chk_addr+0xa0/0xb0 [ipv6]
[  449.177821]  [<c8a7a4ef>] ndisc_solicit+0x9f/0x1b0 [ipv6]
[  449.177821]  [<c0133af8>] mark_held_locks+0x38/0x70
[  449.177821]  [<c029b665>] _spin_unlock_irqrestore+0x45/0x60
[  449.177821]  [<c0133c16>] trace_hardirqs_on+0x66/0x110
[  449.177821]  [<c023fab5>] neigh_timer_handler+0x155/0x2a0
[  449.177821]  [<c011dd5f>] run_timer_softirq+0x15f/0x1c0
[  449.177821]  [<c023f960>] neigh_timer_handler+0x0/0x2a0
[  449.177821]  [<c023f960>] neigh_timer_handler+0x0/0x2a0
[  449.177821]  [<c011a182>] __do_softirq+0x52/0xb0
[  449.177821]  [<c011a225>] do_softirq+0x45/0x50
[  449.177821]  [<c011a665>] irq_exit+0x55/0x70
[  449.177821]  [<c0104e83>] do_IRQ+0x43/0x90
[  449.177821]  [<c0103214>] common_interrupt+0x24/0x40
[  449.177821]  [<c010321e>] common_interrupt+0x2e/0x40
[  449.177821]  [<c0101ace>] default_idle+0x5e/0x90
[  449.177821]  [<c0101a70>] default_idle+0x0/0x90
[  449.177821]  [<c0101910>] cpu_idle+0x30/0x80
[  449.177821]  =======================
