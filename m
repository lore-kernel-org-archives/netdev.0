From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: [Bugme-new] [Bug 15239] New: Problem with network performance
 after a while.
Date: Mon, 8 Feb 2010 15:06:24 -0800 (Pacific Standard Time)
Message-ID: <alpine.WNT.2.00.1002081432390.6892@jbrandeb-desk1.amr.corp.intel.com>
References: <bug-15239-10286@http.bugzilla.kernel.org/> <20100208141513.b5d0be56.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"bugzilla-daemon@bugzilla.kernel.org"
	<bugzilla-daemon@bugzilla.kernel.org>,
	"bugme-daemon@bugzilla.kernel.org" <bugme-daemon@bugzilla.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"pstaszewski@artcom.pl" <pstaszewski@artcom.pl>,
	"stable@kernel.org" <stable@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:12202 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751235Ab0BHXGZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Feb 2010 18:06:25 -0500
In-Reply-To: <20100208141513.b5d0be56.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Andrew, thanks.

On Mon, 8 Feb 2010, Andrew Morton wrote:
> > Hello the problem is that after some time of working my router have some
> > performance problems.
> > 
> > The problem exist on kernel 2.6.32.7 and 2.6.33-rc6-git5
> > The problem dont exist on 2.6.32.2 kernel.
> 
> That would be bad.  That's a regression in 2.6.33-rc, and we've
> backported that regression into 2.6.32.x -stable.

there were no changes to e1000e from v2.6.32..v2.6.32.7
# git whatchanged v2.6.32..v2.6.32.7 drivers/net/e1000e

 
> > on 2.6.33-rc6-git5 i have this info:

> > BUG: soft lockup - CPU#1 stuck for 61s!
> > [events/1:28]

so why is this events/1 thing here?  I've see this kernel thread related 
to ipv6 stack hanging when under heavy incoming packet load as the 
interface comes up.  Was the interface just brought up or something 
changed in rules or something?

> > Modules linked in:
> > CPU 1
> > Pid: 28, comm: events/1 Not tainted 2.6.33-rc6-git5 #1 X7DCT/X7DCT
> > RIP: 0010:[<ffffffff810a3d89>]  [<ffffffff810a3d89>]
> > kmem_cache_free+0x11b/0x11c
> > RSP: 0018:ffff880028243e50  EFLAGS: 00000292
> > RAX: 0000000000000032 RBX: 000000000000007d RCX: ffff8803190683c0
> > RDX: 0000000000000031 RSI: ffff8803190683c0 RDI: ffff88031f83e680
> > RBP: ffffffff81002893 R08: 0000000000000000 R09: 000000000000007c
> > R10: ffff88030d776800 R11: ffff88030d7768a0 R12: ffff880028243dd0
> > R13: ffffc900008b2f80 R14: ffff88031fa7c800 R15: ffffffff81012da7
> > FS:  0000000000000000(0000) GS:ffff880028240000(0000) knlGS:0000000000000000
> > CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> > CR2: 00007fd61d5bd000 CR3: 000000031e55c000 CR4: 00000000000006a0
> > DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> > DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> > Process events/1 (pid: 28, threadinfo ffff88031f9c8000, task ffff88031f9a4f80)
> > Stack:
> >  ffffffff8126826f ffff88031faa4600 ffffffff8126834a 000096ba00000023
> > <0> 01ffc90000000024 ffff88031fbb4000 ffff88031faa4600 0000000000000040
> > <0> 0000000000000040 ffff88031faa4788 ffff88031faa4600 0000000000000740
> > Call Trace:
> >  <IRQ>
> >  [<ffffffff8126826f>] ? e1000_put_txbuf+0x62/0x74
> >  [<ffffffff8126834a>] ? e1000_clean_tx_irq+0xc9/0x235

clean_tx_irq in e1000e has a break-out condition to keep the transmit 
cleanup for running forever (if another cpu is transmitting) so it seems 
that something else must have happened.  Can kmem_cache_free sleep or 
stall on a lock?


> >  [<ffffffff8126b71b>] ? e1000_clean+0x5c/0x21c
> >  [<ffffffff812f29a3>] ? net_rx_action+0x71/0x15d
> >  [<ffffffff81035311>] ? __do_softirq+0xd7/0x196
> >  [<ffffffff81002dac>] ? call_softirq+0x1c/0x28
> >  [<ffffffff812f768f>] ? dst_gc_task+0x0/0x1a7
> >  [<ffffffff81002dac>] ? call_softirq+0x1c/0x28
> >  <EOI>
> >  [<ffffffff81004599>] ? do_softirq+0x31/0x63
> >  [<ffffffff81034ec1>] ? local_bh_enable_ip+0x75/0x86
> >  [<ffffffff812f768f>] ? dst_gc_task+0x0/0x1a7
> >  [<ffffffff812f775d>] ? dst_gc_task+0xce/0x1a7
> >  [<ffffffff8136b08c>] ? schedule+0x82c/0x906
> >  [<ffffffff8103c44f>] ? lock_timer_base+0x26/0x4b
> >  [<ffffffff810a41d6>] ? cache_reap+0x0/0x11d
> >  [<ffffffff81044c38>] ? worker_thread+0x14c/0x1dc
> >  [<ffffffff81047dcd>] ? autoremove_wake_function+0x0/0x2e
> >  [<ffffffff81044aec>] ? worker_thread+0x0/0x1dc
> >  [<ffffffff810479bd>] ? kthread+0x79/0x81
> >  [<ffffffff81002cb4>] ? kernel_thread_helper+0x4/0x10
> >  [<ffffffff81047944>] ? kthread+0x0/0x81
> >  [<ffffffff81002cb0>] ? kernel_thread_helper+0x0/0x10
> > Code: fe 79 4c 00 48 85 db 74 14 48 8b 74 24 10 48 89 ef ff 13 48 83 c3 08 48
> > 83 3b 00 eb ea 48 83 c4 18 5b 5d 41 5c 41 5d 41 5e 41 5f <c3> 55 48 89 f5 53 48
> > 89 fb 48 83 ec 08 48 8b 76 18 48 2b 75 10
> > Call Trace:
> >  <IRQ>  [<ffffffff8126826f>] ? e1000_put_txbuf+0x62/0x74
> >  [<ffffffff8126834a>] ? e1000_clean_tx_irq+0xc9/0x235
> >  [<ffffffff8126b71b>] ? e1000_clean+0x5c/0x21c
> >  [<ffffffff812f29a3>] ? net_rx_action+0x71/0x15d
> >  [<ffffffff81035311>] ? __do_softirq+0xd7/0x196
> >  [<ffffffff81002dac>] ? call_softirq+0x1c/0x28
> >  [<ffffffff812f768f>] ? dst_gc_task+0x0/0x1a7
> >  [<ffffffff81002dac>] ? call_softirq+0x1c/0x28
> >  <EOI>  [<ffffffff81004599>] ? do_softirq+0x31/0x63
> >  [<ffffffff81034ec1>] ? local_bh_enable_ip+0x75/0x86
> >  [<ffffffff812f768f>] ? dst_gc_task+0x0/0x1a7
> >  [<ffffffff812f775d>] ? dst_gc_task+0xce/0x1a7
> >  [<ffffffff8136b08c>] ? schedule+0x82c/0x906
> >  [<ffffffff8103c44f>] ? lock_timer_base+0x26/0x4b
> >  [<ffffffff810a41d6>] ? cache_reap+0x0/0x11d
> >  [<ffffffff81044c38>] ? worker_thread+0x14c/0x1dc
> >  [<ffffffff81047dcd>] ? autoremove_wake_function+0x0/0x2e
> >  [<ffffffff81044aec>] ? worker_thread+0x0/0x1dc
> >  [<ffffffff810479bd>] ? kthread+0x79/0x81
> >  [<ffffffff81002cb4>] ? kernel_thread_helper+0x4/0x10
> >  [<ffffffff81047944>] ? kthread+0x0/0x81
> >  [<ffffffff81002cb0>] ? kernel_thread_helper+0x0/0x10
> > 
> > And on 2.6.32.7
> > Feb  4 13:12:40 TM_01_C1 ------------[ cut here ]------------
> > Feb  4 13:12:40 TM_01_C1 WARNING: at net/sched/sch_generic.c:261
> > dev_watchdog+0x130/0x1d6()
> > Feb  4 13:12:40 TM_01_C1 Hardware name: X7DCT
> > Feb  4 13:12:40 TM_01_C1 NETDEV WATCHDOG: eth0 (e1000e): transmit queue 0 timed
> > out
> > Feb  4 13:12:40 TM_01_C1 Modules linked in: oprofile
> > Feb  4 13:12:40 TM_01_C1 Pid: 0, comm: swapper Not tainted 2.6.32 #1

the above doesn't match your statement that it is 2.6.32.7

> > Feb  4 13:12:40 TM_01_C1 Call Trace:
> > Feb  4 13:12:40 TM_01_C1 <IRQ>  [<ffffffff812fcaf7>] ? dev_watchdog+0x130/0x1d6
> > Feb  4 13:12:40 TM_01_C1 [<ffffffff812fcaf7>] ? dev_watchdog+0x130/0x1d6
> > Feb  4 13:12:40 TM_01_C1 [<ffffffff81038811>] ? warn_slowpath_common+0x77/0xa3
> > Feb  4 13:12:40 TM_01_C1 [<ffffffff81038899>] ? warn_slowpath_fmt+0x51/0x59
> > Feb  4 13:12:40 TM_01_C1 [<ffffffff8102897e>] ? activate_task+0x3f/0x4e
> > Feb  4 13:12:40 TM_01_C1 [<ffffffff81034fe5>] ? try_to_wake_up+0x1eb/0x1f8
> > Feb  4 13:12:40 TM_01_C1 [<ffffffff812eb768>] ? netdev_drivername+0x3b/0x40
> > Feb  4 13:12:40 TM_01_C1 [<ffffffff812fcaf7>] ? dev_watchdog+0x130/0x1d6
> > Feb  4 13:12:40 TM_01_C1 [<ffffffff8102d1e3>] ? __wake_up+0x30/0x44
> > Feb  4 13:12:40 TM_01_C1 [<ffffffff812fc9c7>] ? dev_watchdog+0x0/0x1d6
> > Feb  4 13:12:40 TM_01_C1 [<ffffffff810448c4>] ? run_timer_softirq+0x1ff/0x29d
> > Feb  4 13:12:40 TM_01_C1 [<ffffffff810556ab>] ? ktime_get+0x5f/0xb7
> > Feb  4 13:12:40 TM_01_C1 [<ffffffff8103e0fd>] ? __do_softirq+0xd7/0x196
> > Feb  4 13:12:40 TM_01_C1 [<ffffffff8100be7c>] ? call_softirq+0x1c/0x28
> > Feb  4 13:12:40 TM_01_C1 [<ffffffff8100d645>] ? do_softirq+0x31/0x66
> > Feb  4 13:12:40 TM_01_C1 [<ffffffff8101b148>] ?
> > smp_apic_timer_interrupt+0x87/0x95
> > Feb  4 13:12:40 TM_01_C1 [<ffffffff8100b873>] ? apic_timer_interrupt+0x13/0x20
> > Feb  4 13:12:40 TM_01_C1 <EOI>  [<ffffffff810111f5>] ? mwait_idle+0x9b/0xa0
> > Feb  4 13:12:40 TM_01_C1 [<ffffffff8100a236>] ? cpu_idle+0x49/0x7c
> > Feb  4 13:12:40 TM_01_C1 ---[ end trace c670a6a17be040e5 ]---
> > 
> > 
> > Machine is a BGP router with some iproute traffic management.

please send a full dmesg from boot.  also full lspci -vvv.

We sporadically see some issue with some people's use of traffic 
management with some e1000/e devices, we have no repro or common 
reproduction case, so haven't solved the issue yet.  I suspect there is a 
strange interaction with HTB or one of the other queueing disciplines that 
causes some odd skb or set of skb's to arrive, but that is just a theory.

I see two different bugs above, one is the tx hang, could it be that you 
didn't have SOFTLOCKUP detection enabled on 2.6.32?  A softlockup could 
cause a tx hang.

The other bug is the softlockup and I don't know how the driver could be 
at fault in that listed stack path.  We simply can't loop more than 
tx_ring->count times, which could never take > 60 seconds unless one of 
the calls we were making was getting stalled for some reason.

So your traffic is "heavy" forwarding at the time of the failure, do you 
have any input on average packet size?  I'm trying to figure out how we 
might reproduce this.

Jesse
