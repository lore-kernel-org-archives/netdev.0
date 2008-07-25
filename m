From: Ingo Molnar <mingo@elte.hu>
Subject: [lockdep warning] AOE / networking: aoenet_xmit:
	noop_qdisc.q.lock, INFO: inconsistent lock state at 0000000000000370
Date: Fri, 25 Jul 2008 08:20:09 +0200
Message-ID: <20080725062009.GA6476@elte.hu>
References: <20080721.134608.75595942.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"Ed L. Cashin" <ecashin@coraid.com>, Jens Axboe <axboe@suse.de>,
	Mike Miller <mike.miller@hp.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	"Rafael J. Wysocki" <rjw@sisk.pl>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:32847 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750918AbYGYGUs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jul 2008 02:20:48 -0400
Content-Disposition: inline
In-Reply-To: <20080721.134608.75595942.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


not sure whether it got reported already, but -tip testing triggered 
this new ATA over Ethernet lockdep warning on latest -git:

=================================
[ INFO: inconsistent lock state ]
2.6.26-tip-00346-gb4d3941-dirty #13925
---------------------------------
inconsistent {softirq-on-W} -> {in-softirq-W} usage.
swapper/0 [HC0[0]:SC1[2]:HE1:SE0] takes:
 (noop_qdisc.q.lock){-+..}, at: [<ffffffff80880ba8>] dev_queue_xmit+0xd8/0x520
{softirq-on-W} state was registered at:
  [<ffffffff80266517>] __lock_acquire+0x3a7/0x10e0
  [<ffffffff802672a7>] lock_acquire+0x57/0x80
  [<ffffffff80a080da>] _spin_lock+0x2a/0x40
  [<ffffffff808a141f>] shutdown_scheduler_queue+0x3f/0x60
  [<ffffffff808a1481>] dev_shutdown+0x41/0x90
  [<ffffffff8087e9da>] rollback_registered+0x6a/0x100
  [<ffffffff8087ea92>] unregister_netdevice+0x22/0x80
  [<ffffffff80999bcc>] ieee80211_register_hw+0x2ec/0x3b0
  [<ffffffff80eb0dbc>] init_mac80211_hwsim+0x1bc/0x370
  [<ffffffff80209045>] do_one_initcall+0x45/0x180
  [<ffffffff80e7fb75>] kernel_init+0x1d5/0x2f0
  [<ffffffff8020d599>] child_rip+0xa/0x11
  [<ffffffffffffffff>] 0xffffffffffffffff
irq event stamp: 326488
hardirqs last  enabled at (326488): [<ffffffff80265cbd>] trace_hardirqs_on+0xd/0x10
hardirqs last disabled at (326487): [<ffffffff802642ed>] trace_hardirqs_off+0xd/0x10
softirqs last  enabled at (326450): [<ffffffff80248462>] __do_softirq+0x102/0x120
softirqs last disabled at (326461): [<ffffffff8020d86c>] call_softirq+0x1c/0x30

other info that might help us debug this:
1 lock held by swapper/0:
 #0:  (rcu_read_lock){..--}, at: [<ffffffff80880b2b>] dev_queue_xmit+0x5b/0x520

stack backtrace:
Pid: 0, comm: swapper Not tainted 2.6.26-tip-00346-gb4d3941-dirty #13925

Call Trace:
 <IRQ>  [<ffffffff80264c6b>] print_usage_bug+0x18b/0x190
 [<ffffffff80265a67>] mark_lock+0x517/0x570
 [<ffffffff802664ce>] __lock_acquire+0x35e/0x10e0
 [<ffffffff80265c5b>] ? trace_hardirqs_on_caller+0x7b/0xd0
 [<ffffffff802672a7>] lock_acquire+0x57/0x80
 [<ffffffff80880ba8>] ? dev_queue_xmit+0xd8/0x520
 [<ffffffff80a080da>] _spin_lock+0x2a/0x40
 [<ffffffff80880b2b>] ? dev_queue_xmit+0x5b/0x520
 [<ffffffff80880ba8>] dev_queue_xmit+0xd8/0x520
 [<ffffffff807aba2f>] aoenet_xmit+0x2f/0x40
 [<ffffffff807a9cd0>] aoecmd_cfg+0x140/0x170
 [<ffffffff807ab890>] ? discover_timer+0x0/0x110
 [<ffffffff807ab92a>] discover_timer+0x9a/0x110
 [<ffffffff8024bf3b>] run_timer_softirq+0x20b/0x250
 [<ffffffff802483f4>] __do_softirq+0x94/0x120
 [<ffffffff80260e6d>] ? clockevents_program_event+0x5d/0x90
 [<ffffffff8020d86c>] call_softirq+0x1c/0x30
 [<ffffffff8021018a>] do_softirq+0x6a/0xa0
 [<ffffffff80248349>] irq_exit+0x99/0xb0
 [<ffffffff80220842>] smp_apic_timer_interrupt+0x92/0xd0
 [<ffffffff8020d34b>] apic_timer_interrupt+0x6b/0x70
 <EOI>  [<ffffffff80214afc>] ? mwait_idle+0x4c/0x60
 [<ffffffff80214af3>] ? mwait_idle+0x43/0x60
 [<ffffffff8020af51>] ? cpu_idle+0xa1/0x110
 [<ffffffff80a00990>] ? start_secondary+0x150/0x1a0

with this config:

  http://redhat.com/~mingo/misc/log-Fri_Jul_25_06_07_52_CEST_2008.bad

full bootlog:

  http://redhat.com/~mingo/misc/config-Fri_Jul_25_06_07_52_CEST_2008.bad

i suspect this too is about the changed locking dependencies.

	Ingo
