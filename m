From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: bad unlock balance detected during stress
Date: Wed, 3 Feb 2010 13:05:44 -0700
Message-ID: <EA929A9653AAE14F841771FB1DE5A1365FDD5CAF52@rrsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "paulmck@linux.vnet.ibm.com" <paulmck@linux.vnet.ibm.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:62804 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757770Ab0BCUFq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2010 15:05:46 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I got this panic while running netperf stress test using recent pull from net-next:

=====================================
[ BUG: bad unlock balance detected! ]
-------------------------------------
netperf/25568 is trying to release lock (rcu_read_lock) at:
[<ffffffff8133078c>] rcu_read_unlock+0x0/0x23
but there are no more locks to release!

other info that might help us debug this:
2 locks held by netperf/25568:
 #0:  (&q->timer){......}, at: [<ffffffff810500fe>] __run_timers+0xb6/0x1c8
 #1:  (&(&q->lock)->rlock){......}, at: [<ffffffff813a26cb>] _raw_spin_lock+0x9/0xb

stack backtrace:
Pid: 25568, comm: netperf Not tainted 2.6.33-rc5-net-next-igb-tag020210 #29
Call Trace:
 <IRQ>  [<ffffffff8106e251>] print_unlock_inbalance_bug+0xca/0xd5
 [<ffffffff8106e31a>] lock_release_non_nested+0xbe/0x200
 [<ffffffff8133078c>] ? rcu_read_unlock+0x0/0x23
 [<ffffffff813a270d>] ? _raw_write_unlock+0x9/0xb
 [<ffffffff8133078c>] ? rcu_read_unlock+0x0/0x23
 [<ffffffff8106e48d>] lock_release_nested+0x31/0x87
 [<ffffffff8106e7b1>] __lock_release+0x3f/0x58
 [<ffffffff8133078c>] ? rcu_read_unlock+0x0/0x23
 [<ffffffff8106eba4>] lock_release+0x50/0x6a
 [<ffffffff813307a8>] rcu_read_unlock+0x1c/0x23
 [<ffffffff8133136c>] ip_expire+0xfa/0x116
 [<ffffffff8105017f>] __run_timers+0x137/0x1c8
 [<ffffffff810500fe>] ? __run_timers+0xb6/0x1c8
 [<ffffffff81331272>] ? ip_expire+0x0/0x116
 [<ffffffff8105024d>] run_timer_softirq+0x3d/0x42
 [<ffffffff810488ed>] __do_softirq+0x96/0x132
 [<ffffffff81003c4c>] call_softirq+0x1c/0x28
 [<ffffffff8100553e>] do_softirq+0x33/0x69
 [<ffffffff810489bf>] irq_exit+0x36/0x7e
 [<ffffffff8101a47d>] smp_apic_timer_interrupt+0x34/0x43
 [<ffffffff81003713>] apic_timer_interrupt+0x13/0x20
 <EOI> 
huh, entered ffffffff81331272 with preempt_count 00000101, exited with 00000100?
------------[ cut here ]------------
kernel BUG at kernel/timer.c:1035!
invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
last sysfs file: /sys/devices/pci0000:00/0000:00:03.0/0000:02:00.1/irq
CPU 7 
Pid: 25568, comm: netperf Not tainted 2.6.33-rc5-net-next-igb-tag020210 #29 S5520HC/S5520HC
RIP: 0010:[<ffffffff810501c0>]  [<ffffffff810501c0>] __run_timers+0x178/0x1c8
RSP: 0000:ffff8801f58c3e50  EFLAGS: 00010282
RAX: 0000000000000057 RBX: ffff8801f58c3e70 RCX: 0000000000000000
RDX: 0000000000004847 RSI: 0000000000000003 RDI: ffff8801e5120000
RBP: ffff8801f58c3ed0 R08: 0000000000000001 R09: 00000000fffff8d4
R10: 00000000fffff8d4 R11: ffffffff81625b18 R12: 0000000000000101
R13: ffff880367f0f460 R14: ffff880369078000 R15: ffff8801e5121fd8
FS:  00007f98cb24f6e0(0000) GS:ffff8801f58c0000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 00007f98cb268000 CR3: 00000001e791e000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process netperf (pid: 25568, threadinfo ffff8801e5120000, task ffff8801e7be8000)
Stack:
 ffffffff810500fe 0000000000000000 ffffffff81331272 ffff880367f0f400
<0> ffffffff81f541a8 0000000000000000 ffffffff815c4474 ffff8801e5121fd8
<0> ffff880367f0dc60 ffff880367f0fa60 ffff8801f58c3ec0 ffff880369078000
Call Trace:
 <IRQ> 
 [<ffffffff810500fe>] ? __run_timers+0xb6/0x1c8
 [<ffffffff81331272>] ? ip_expire+0x0/0x116
 [<ffffffff8105024d>] run_timer_softirq+0x3d/0x42
 [<ffffffff810488ed>] __do_softirq+0x96/0x132
 [<ffffffff81003c4c>] call_softirq+0x1c/0x28
 [<ffffffff8100553e>] do_softirq+0x33/0x69
 [<ffffffff810489bf>] irq_exit+0x36/0x7e
 [<ffffffff8101a47d>] smp_apic_timer_interrupt+0x34/0x43
 [<ffffffff81003713>] apic_timer_interrupt+0x13/0x20
 <EOI> 
Code: df e8 b9 e9 01 00 45 3b a7 44 e0 ff ff 74 20 41 8b 8f 44 e0 ff ff 44 89 e2 48 8b 75 90 48 c7 c7 0e fe 56 81 31 c0 e8 34 2b ff ff <0f> 0b eb fe 4c 89 f7 e8 d9 fd ff ff 4c 8b 6d c0 48 8d 45 c0 49 
RIP  [<ffffffff810501c0>] __run_timers+0x178/0x1c8
 RSP <ffff8801f58c3e50>
---[ end trace e94a4fa06a0233c4 ]---

Thanks,
Emil