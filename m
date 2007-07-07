From: Ranko Zivojnovic <ranko@spidernet.net>
Subject: Re: + gen_estimator-fix-locking-and-timer-related-bugs.patch added
	to -mm tree
Date: Sat, 07 Jul 2007 10:55:18 +0300
Message-ID: <1183794918.30237.69.camel@localhost.localdomain>
References: <200706271921.l5RJLgCC003910@imap1.linux-foundation.org>
	 <1183642800.3789.11.camel@ranko-fc2.spidernet.net>
	 <20070705142135.GG4759@ff.dom.local>
	 <1183646029.4069.11.camel@ranko-fc2.spidernet.net>
	 <1183651165.4069.26.camel@ranko-fc2.spidernet.net>
	 <20070706061420.GA1846@ff.dom.local> <20070706062629.GC1846@ff.dom.local>
	 <20070706064523.GA2144@ff.dom.local>
	 <1183727654.6389.3.camel@ranko-fc2.spidernet.net>
	 <468E4FD9.4060702@trash.net>
	 <1183733732.6389.26.camel@ranko-fc2.spidernet.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@o2.pl>, akpm@linux-foundation.org,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from MPP-Goya.spidernet.net ([194.154.128.52]:11674 "EHLO
	mail0pop.spidernet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753951AbXGGH4h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Jul 2007 03:56:37 -0400
In-Reply-To: <1183733732.6389.26.camel@ranko-fc2.spidernet.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-07-06 at 17:55 +0300, Ranko Zivojnovic wrote:
> On Fri, 2007-07-06 at 16:21 +0200, Patrick McHardy wrote:
> > Ranko Zivojnovic wrote:
> > > BUG: spinlock lockup on CPU#0, swapper/0, c03eff80
> > >  [<c01ed1fe>] _raw_spin_lock+0x108/0x13c
> > >  [<c02a8468>] __qdisc_run+0x97/0x1b0
> > >  [<c02a96f3>] qdisc_watchdog+0x19/0x58
> > >  [<c02fe5e7>] __lock_text_start+0x37/0x43
> > >  [<c02a9730>] qdisc_watchdog+0x56/0x58
> > >  [<c02a96da>] qdisc_watchdog+0x0/0x58
> > >  [<c0135d84>] run_hrtimer_softirq+0x58/0xb5
> > >  [...]
> > 
> > > BUG: spinlock lockup on CPU#1, swapper/0, c03eff80
> > >  [<c01ed1fe>] _raw_spin_lock+0x108/0x13c
> > >  [<c0298b9b>] est_timer+0x53/0x148
> > >  [<c01294b3>] run_timer_softirq+0x30/0x184
> > >  [<c01295a4>] run_timer_softirq+0x121/0x184
> > >  [<c0126252>] __do_softirq+0x66/0xf3
> > >  [<c0298b48>] est_timer+0x0/0x148
> > >  [...]
> > 
> > 
> > There is at least one ABBA deadlock, est_timer does:
> > 
> > read_lock(&est_lock)
> > spin_lock(e->stats_lock) (which is dev->queue_lock)
> > 
> > and qdisc_destroy calls htb_destroy under dev->queue_lock, which
> > calls htb_destroy_class, then gen_kill_estimator and this
> > write_locks est_lock.
> > 
> > I can't see the problem above though, the qdisc_run path only takes
> > dev->queue_lock. Please enable lockdep and post the output if any.
> 

I've got both code paths this time. It shows exactly the ABBA deadlock
you describe above. The details are below.

Maybe the appropriate way to fix this would to call gen_kill_estimator,
with the appropriate lock order, before the call to qdisc_destroy, so
when dev->queue_lock is taken for qdisc_destroy - the structure is
already off the list.

-------------LOG------------
BUG: spinlock lockup on CPU#2, ping/27868, c03eff80
 [<c01ed1fe>] _raw_spin_lock+0x108/0x13c
 [<c0298b9b>] est_timer+0x53/0x148
 [<c01295a4>] run_timer_softirq+0x121/0x184
 [<c0126252>] __do_softirq+0x66/0xf3
 [<c0298b48>] est_timer+0x0/0x148
 [<c012626a>] __do_softirq+0x7e/0xf3
 [<c0126335>] do_softirq+0x56/0x58
 [<c0112574>] smp_apic_timer_interrupt+0x5a/0x85
 [<c0103eb1>] apic_timer_interrupt+0x29/0x38
 [<c0103ebb>] apic_timer_interrupt+0x33/0x38
 [<c0126485>] local_bh_enable+0x94/0x13b
 [<c029c380>] dev_queue_xmit+0x95/0x2d5
 [<c02bb9a9>] ip_output+0x193/0x32a
 [<c02b9fd8>] ip_finish_output+0x0/0x29e
 [<c02b8aa6>] ip_push_pending_frames+0x27f/0x46b
 [<c02b8770>] dst_output+0x0/0x7
 [<c02d4fb9>] raw_sendmsg+0x70b/0x7f2
 [<c02dcbe0>] inet_sendmsg+0x2b/0x49
 [<c028fb66>] sock_sendmsg+0xe2/0xfd
 [<c0132bbb>] autoremove_wake_function+0x0/0x37
 [<c0132bbb>] autoremove_wake_function+0x0/0x37
 [<c011aacc>] enqueue_entity+0x139/0x4f8
 [<c01e0dc3>] copy_from_user+0x2d/0x59
 [<c028fcae>] sys_sendmsg+0x12d/0x243
 [<c013dec5>] __lock_acquire+0x825/0x1002
 [<c013dec5>] __lock_acquire+0x825/0x1002
 [<c011d8a2>] scheduler_tick+0x1a7/0x20e
 [<c02fea7a>] _spin_unlock_irq+0x20/0x23
 [<c013d166>] trace_hardirqs_on+0x73/0x147
 [<c01294b3>] run_timer_softirq+0x30/0x184
 [<c02fea7a>] _spin_unlock_irq+0x20/0x23
 [<c0290eed>] sys_socketcall+0x24f/0x271
 [<c013d19e>] trace_hardirqs_on+0xab/0x147
 [<c01e0fe6>] copy_to_user+0x2f/0x49
 [<c0103396>] sysenter_past_esp+0x8f/0x99
 [<c0103366>] sysenter_past_esp+0x5f/0x99
 =======================

And here is the ABBA deadlock:
---cut---
SysRq : Show Locks Held

Showing all locks held in the system:
****snip****
3 locks held by ping/27868:
 #0:  (sk_lock-AF_INET){--..}, at: [<c02d4f24>] raw_sendmsg+0x676/0x7f2
 #1:  (est_lock#2){-.-+}, at: [<c0298b5d>] est_timer+0x15/0x148
 #2:  (&dev->queue_lock){-+..}, at: [<c0298b9b>] est_timer+0x53/0x148
****snip****
8 locks held by tc/2278:
 #0:  (rtnl_mutex){--..}, at: [<c02a26d7>] rtnetlink_rcv+0x18/0x42
 #1:  (&dev->queue_lock){-+..}, at: [<c02a7f27>] qdisc_lock_tree+0xe/0x1c
 #2:  (&dev->ingress_lock){-...}, at: [<c02a9ba8>] tc_get_qdisc+0x192/0x1e9
 #3:  (est_lock#2){-.-+}, at: [<c02989bc>] gen_kill_estimator+0x58/0x6f
 #4:  (&irq_lists[i].lock){++..}, at: [<c024164d>] serial8250_interrupt+0x14/0x132
 #5:  (&port_lock_key){++..}, at: [<c024169b>] serial8250_interrupt+0x62/0x132
 #6:  (sysrq_key_table_lock){+...}, at: [<c0235460>] __handle_sysrq+0x17/0x115
 #7:  (tasklist_lock){..-?}, at: [<c013be2b>] debug_show_all_locks+0x2e/0x15e
****snip****
---cut---

As well as 'tc' stack:
---cut---
SysRq : Show Regs

Pid: 2278, comm:                   tc
EIP: 0060:[<c02fe39b>] CPU: 0
EIP is at __write_lock_failed+0xf/0x1c
 EFLAGS: 00000287    Not tainted
(2.6.22-rc6-mm1.SNET.Thors.htbpatch.2.lockdebug #1)
EAX: c03f5968 EBX: c03f5968 ECX: 00000000 EDX: 00000004
ESI: c9852840 EDI: c85eae24 EBP: c06aaa60 DS: 007b ES: 007b FS: 00d8
CR0: 8005003b CR2: 008ba828 CR3: 11841000 CR4: 000006d0
DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
DR6: ffff0ff0 DR7: 00000400
 [<c01ed264>] _raw_write_lock+0x32/0x6e
 [<c02989bc>] gen_kill_estimator+0x58/0x6f
 [<f8bb55a6>] htb_destroy_class+0x27/0x12f [sch_htb]
 [<f8bb6037>] htb_destroy+0x34/0x70 [sch_htb]
 [<c02a8152>] qdisc_destroy+0x52/0x8d
 [<c013d166>] trace_hardirqs_on+0x73/0x147
 [<f8bb5651>] htb_destroy_class+0xd2/0x12f [sch_htb]
 [<f8bb6037>] htb_destroy+0x34/0x70 [sch_htb]
 [<c02a8152>] qdisc_destroy+0x52/0x8d
 [<c02a9bb1>] tc_get_qdisc+0x19b/0x1e9
 [<c02a9a16>] tc_get_qdisc+0x0/0x1e9
 [<c02a28f5>] rtnetlink_rcv_msg+0x1c2/0x1f5
 [<c02ad51f>] netlink_run_queue+0x96/0xfd
 [<c02a2733>] rtnetlink_rcv_msg+0x0/0x1f5
 [<c02a26e5>] rtnetlink_rcv+0x26/0x42
 [<c02ada49>] netlink_data_ready+0x12/0x54
 [<c02ac6d4>] netlink_sendskb+0x1f/0x53
 [<c02ad958>] netlink_sendmsg+0x1f5/0x2d4
 [<c028fb66>] sock_sendmsg+0xe2/0xfd
 [<c0132bbb>] autoremove_wake_function+0x0/0x37
 [<c013dec5>] __lock_acquire+0x825/0x1002
 [<c028fb66>] sock_sendmsg+0xe2/0xfd
 [<c01e0dc3>] copy_from_user+0x2d/0x59
 [<c028fcae>] sys_sendmsg+0x12d/0x243
 [<c0157d4c>] __do_fault+0x12b/0x38b
 [<c0157db9>] __do_fault+0x198/0x38b
 [<c013d7b8>] __lock_acquire+0x118/0x1002
 [<c014de85>] filemap_fault+0x0/0x42f
 [<c015922e>] __handle_mm_fault+0x11e/0x68d
 [<c0290eed>] sys_socketcall+0x24f/0x271
 [<c013d19e>] trace_hardirqs_on+0xab/0x147
 [<c0103438>] restore_nocheck+0x12/0x15
 [<c0103366>] sysenter_past_esp+0x5f/0x99
 =======================
---cut---

Best regards,

Ranko

