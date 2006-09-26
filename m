From: Dave Jones <davej@redhat.com>
Subject: Re: tc related lockdep warning.
Date: Tue, 26 Sep 2006 17:20:34 -0400
Message-ID: <20060926212034.GA3134@redhat.com>
References: <20060925124352.GA1592@ff.dom.local> <1159188473.5301.68.camel@jzny2> <4517D9A6.70307@trash.net> <45195219.7050105@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, Jarek Poplawski <jarkao2@o2.pl>,
	netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:27058 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S932419AbWIZVVA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2006 17:21:00 -0400
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <45195219.7050105@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 26, 2006 at 06:15:21PM +0200, Patrick McHardy wrote:
 > Patrick McHardy wrote:
 > > jamal wrote:
 > > 
 > >>Yes, that looks plausible. Can you try making those changes and see if
 > >>the warning is gone?
 > > 
 > >
 > > I think this points to a bigger brokeness caused by the move of
 > > dev->qdisc to RCU. It means destruction of filters and actions doesn't
 > > necessarily happens in user-context and thus not protected by the rtnl
 > > anymore.
 > 
 > I looked into this and we indeed still have lots of problems from that
 > broken RCU patch. Basically all locking (qdiscs, classifiers, actions,
 > estimators) assumes that updates are only done in process context and
 > thus read_lock doesn't need bottem half protection. Quite a few things
 > also assume that updates only happen under the RTNL and don't need
 > any further protection if not used during packet processing.
 > 
 > Instead of "fixing" all this I suggest something like this (untested)
 > patch instead. Since only the dev->qdisc pointer is protected by RCU,
 > but enqueue and the qdisc tree are still protected by dev->qdisc_lock,
 > we can perform destruction of the tree immediately and only do the
 > final free in the rcu callback, as long as we make sure not to enqueue
 > anything to a half-way destroyed qdisc.

With this patch, I get no lockdep warnings, but the machine locks up completely.
I hooked up a serial console, and found this..


u32 classifier
    Performance counters on
    input device check on 
    Actions configured 
BUG: warning at net/sched/sch_htb.c:395/htb_safe_rb_erase()

Call Trace:
 [<ffffffff8026f79b>] show_trace+0xae/0x336
 [<ffffffff8026fa38>] dump_stack+0x15/0x17
 [<ffffffff8860a171>] :sch_htb:htb_safe_rb_erase+0x3b/0x55
 [<ffffffff8860a4d5>] :sch_htb:htb_deactivate_prios+0x173/0x1cd
 [<ffffffff8860b437>] :sch_htb:htb_dequeue+0x4d0/0x856
 [<ffffffff8042dc0d>] __qdisc_run+0x3f/0x1ca
 [<ffffffff802329a6>] dev_queue_xmit+0x137/0x268
 [<ffffffff8025b4a2>] neigh_resolve_output+0x249/0x27e
 [<ffffffff802353fd>] ip_output+0x210/0x25a
 [<ffffffff8043ce28>] ip_push_pending_frames+0x37c/0x45b
 [<ffffffff8044ffd7>] icmp_push_reply+0x13b/0x148
 [<ffffffff80450900>] icmp_send+0x366/0x3d3
 [<ffffffff802568a9>] udp_rcv+0x53d/0x556
 [<ffffffff80237e73>] ip_local_deliver+0x1a3/0x26b
 [<ffffffff80238ec8>] ip_rcv+0x4b9/0x501
 [<ffffffff802218bb>] netif_receive_skb+0x33d/0x3c9
 [<ffffffff881f6348>] :e1000:e1000_clean_rx_irq+0x450/0x4fe
 [<ffffffff881f47eb>] :e1000:e1000_clean+0x88/0x17d
 [<ffffffff8020cab3>] net_rx_action+0xac/0x1d1
 [<ffffffff80212725>] __do_softirq+0x68/0xf5
 [<ffffffff80262638>] call_softirq+0x1c/0x28
DWARF2 unwinder stuck at call_softirq+0x1c/0x28
Leftover inexact backtrace:
 <IRQ> [<ffffffff80270aaa>] do_softirq+0x39/0x9f
 [<ffffffff80296102>] irq_exit+0x57/0x59
 [<ffffffff80270c0d>] do_IRQ+0xfd/0x107
 [<ffffffff8025b51d>] mwait_idle+0x0/0x54
 [<ffffffff802618c6>] ret_from_intr+0x0/0xf
 <EOI> [<ffffffff80265e66>] __sched_text_start+0xaa6/0xadd
 [<ffffffff8025b55c>] mwait_idle+0x3f/0x54
 [<ffffffff8025b526>] mwait_idle+0x9/0x54
 [<ffffffff8024c81c>] cpu_idle+0xa2/0xc5
 [<ffffffff8026e519>] rest_init+0x2b/0x2d
 [<ffffffff80a7f811>] start_kernel+0x24a/0x24c
 [<ffffffff80a7f28b>] _sinittext+0x28b/0x292

BUG: warning at net/sched/sch_htb.c:395/htb_safe_rb_erase()

Call Trace:
 [<ffffffff8026f79b>] show_trace+0xae/0x336
 [<ffffffff8026fa38>] dump_stack+0x15/0x17
 [<ffffffff8860a171>] :sch_htb:htb_safe_rb_erase+0x3b/0x55
 [<ffffffff8860a4d5>] :sch_htb:htb_deactivate_prios+0x173/0x1cd
 [<ffffffff8860b437>] :sch_htb:htb_dequeue+0x4d0/0x856
 [<ffffffff8042dc0d>] __qdisc_run+0x3f/0x1ca
 [<ffffffff802329a6>] dev_queue_xmit+0x137/0x268
 [<ffffffff8025b4a2>] neigh_resolve_output+0x249/0x27e
 [<ffffffff802353fd>] ip_output+0x210/0x25a
 [<ffffffff8043ce28>] ip_push_pending_frames+0x37c/0x45b
 [<ffffffff8044ffd7>] icmp_push_reply+0x13b/0x148
 [<ffffffff80450900>] icmp_send+0x366/0x3d3
 [<ffffffff802568a9>] udp_rcv+0x53d/0x556
 [<ffffffff80237e73>] ip_local_deliver+0x1a3/0x26b
 [<ffffffff80238ec8>] ip_rcv+0x4b9/0x501
 [<ffffffff802218bb>] netif_receive_skb+0x33d/0x3c9
 [<ffffffff881f6348>] :e1000:e1000_clean_rx_irq+0x450/0x4fe
 [<ffffffff881f47eb>] :e1000:e1000_clean+0x88/0x17d
 [<ffffffff8020cab3>] net_rx_action+0xac/0x1d1
 [<ffffffff80212725>] __do_softirq+0x68/0xf5
 [<ffffffff80262638>] call_softirq+0x1c/0x28
DWARF2 unwinder stuck at call_softirq+0x1c/0x28
Leftover inexact backtrace:
 <IRQ> [<ffffffff80270aaa>] do_softirq+0x39/0x9f
 [<ffffffff80296102>] irq_exit+0x57/0x59
 [<ffffffff80270c0d>] do_IRQ+0xfd/0x107
 [<ffffffff8025b51d>] mwait_idle+0x0/0x54
 [<ffffffff802618c6>] ret_from_intr+0x0/0xf
 <EOI> [<ffffffff80265e66>] __sched_text_start+0xaa6/0xadd
 [<ffffffff8025b55c>] mwait_idle+0x3f/0x54
 [<ffffffff8025b526>] mwait_idle+0x9/0x54
 [<ffffffff8024c81c>] cpu_idle+0xa2/0xc5
 [<ffffffff8026e519>] rest_init+0x2b/0x2d
 [<ffffffff80a7f811>] start_kernel+0x24a/0x24c
 [<ffffffff80a7f28b>] _sinittext+0x28b/0x292

BUG: soft lockup detected on CPU#0!

Call Trace:
 [<ffffffff8026f79b>] show_trace+0xae/0x336
 [<ffffffff8026fa38>] dump_stack+0x15/0x17
 [<ffffffff802bfea7>] softlockup_tick+0xd5/0xea
 [<ffffffff80250dba>] run_local_timers+0x13/0x15
 [<ffffffff8029a0f9>] update_process_times+0x4c/0x79
 [<ffffffff8027a6ca>] smp_local_timer_interrupt+0x2b/0x50
 [<ffffffff8027aea7>] smp_apic_timer_interrupt+0x58/0x62
 [<ffffffff80261faf>] apic_timer_interrupt+0x6b/0x70
DWARF2 unwinder stuck at apic_timer_interrupt+0x6b/0x70
Leftover inexact backtrace:
 <IRQ> [<ffffffff80232976>] dev_queue_xmit+0x107/0x268
 [<ffffffff80232976>] dev_queue_xmit+0x107/0x268
 [<ffffffff802277bc>] __rb_rotate_left+0x5f/0x60
 [<ffffffff802135fb>] rb_insert_color+0xb9/0xe3
 [<ffffffff8860aa1a>] :sch_htb:htb_add_to_id_tree+0x64/0x66
 [<ffffffff8860aaf2>] :sch_htb:htb_activate_prios+0xd6/0xe7
 [<ffffffff8860c835>] :sch_htb:htb_enqueue+0x139/0x194
 [<ffffffff80232988>] dev_queue_xmit+0x119/0x268
 [<ffffffff8025b4a2>] neigh_resolve_output+0x249/0x27e
 [<ffffffff802353fd>] ip_output+0x210/0x25a
 [<ffffffff8043ce28>] ip_push_pending_frames+0x37c/0x45b
 [<ffffffff8044ffd7>] icmp_push_reply+0x13b/0x148
 [<ffffffff80450900>] icmp_send+0x366/0x3d3
 [<ffffffff802568a9>] udp_rcv+0x53d/0x556
 [<ffffffff80237e73>] ip_local_deliver+0x1a3/0x26b
 [<ffffffff80238ec8>] ip_rcv+0x4b9/0x501
 [<ffffffff802218bb>] netif_receive_skb+0x33d/0x3c9
 [<ffffffff881f6348>] :e1000:e1000_clean_rx_irq+0x450/0x4fe
 [<ffffffff881f47eb>] :e1000:e1000_clean+0x88/0x17d
 [<ffffffff8020cab3>] net_rx_action+0xac/0x1d1
 [<ffffffff80212711>] __do_softirq+0x54/0xf5
 [<ffffffff80212725>] __do_softirq+0x68/0xf5
 [<ffffffff80262638>] call_softirq+0x1c/0x28
 [<ffffffff80270aaa>] do_softirq+0x39/0x9f
 [<ffffffff80296102>] irq_exit+0x57/0x59
 [<ffffffff80270c0d>] do_IRQ+0xfd/0x107
 [<ffffffff8025b51d>] mwait_idle+0x0/0x54
 [<ffffffff802618c6>] ret_from_intr+0x0/0xf
 <EOI> [<ffffffff80265e66>] __sched_text_start+0xaa6/0xadd
 [<ffffffff8025b55c>] mwait_idle+0x3f/0x54
 [<ffffffff8025b526>] mwait_idle+0x9/0x54
 [<ffffffff8024c81c>] cpu_idle+0xa2/0xc5
 [<ffffffff8026e519>] rest_init+0x2b/0x2d
 [<ffffffff80a7f811>] start_kernel+0x24a/0x24c
 [<ffffffff80a7f28b>] _sinittext+0x28b/0x292

BUG: soft lockup detected on CPU#3!

Call Trace:
 [<ffffffff8026f79b>] show_trace+0xae/0x336
 [<ffffffff8026fa38>] dump_stack+0x15/0x17
 [<ffffffff802bfea7>] softlockup_tick+0xd5/0xea
 [<ffffffff80250dba>] run_local_timers+0x13/0x15
 [<ffffffff8029a0f9>] update_process_times+0x4c/0x79
 [<ffffffff8027a6ca>] smp_local_timer_interrupt+0x2b/0x50
 [<ffffffff8027aea7>] smp_apic_timer_interrupt+0x58/0x62
 [<ffffffff80261faf>] apic_timer_interrupt+0x6b/0x70
DWARF2 unwinder stuck at apic_timer_interrupt+0x6b/0x70
Leftover inexact backtrace:
 <IRQ> [<ffffffff8860c645>] :sch_htb:htb_rate_timer+0x21/0xd8
 [<ffffffff8860c645>] :sch_htb:htb_rate_timer+0x21/0xd8
 [<ffffffff8020cc4c>] __delay+0xa/0x15
 [<ffffffff802079c2>] _raw_spin_lock+0x8c/0x104
 [<ffffffff8860c645>] :sch_htb:htb_rate_timer+0x21/0xd8
 [<ffffffff802687b9>] _spin_lock_bh+0x32/0x36
 [<ffffffff8860c645>] :sch_htb:htb_rate_timer+0x21/0xd8
 [<ffffffff802998c6>] run_timer_softirq+0x14c/0x1d5
 [<ffffffff80212725>] __do_softirq+0x68/0xf5
 [<ffffffff80262638>] call_softirq+0x1c/0x28
 [<ffffffff80270aaa>] do_softirq+0x39/0x9f
 [<ffffffff80296102>] irq_exit+0x57/0x59
 [<ffffffff8027aeac>] smp_apic_timer_interrupt+0x5d/0x62
 [<ffffffff8025b51d>] mwait_idle+0x0/0x54
 [<ffffffff80261faf>] apic_timer_interrupt+0x6b/0x70
 <EOI> [<ffffffff80265e66>] __sched_text_start+0xaa6/0xadd
 [<ffffffff8025b55c>] mwait_idle+0x3f/0x54
 [<ffffffff8025b526>] mwait_idle+0x9/0x54
 [<ffffffff8024c81c>] cpu_idle+0xa2/0xc5
 [<ffffffff8027a4bd>] start_secondary+0x468/0x477

BUG: soft lockup detected on CPU#0!

Call Trace:
 [<ffffffff8026f79b>] show_trace+0xae/0x336
 [<ffffffff8026fa38>] dump_stack+0x15/0x17
 [<ffffffff802bfea7>] softlockup_tick+0xd5/0xea
 [<ffffffff80250dba>] run_local_timers+0x13/0x15
 [<ffffffff8029a0f9>] update_process_times+0x4c/0x79
 [<ffffffff8027a6ca>] smp_local_timer_interrupt+0x2b/0x50
 [<ffffffff8027aea7>] smp_apic_timer_interrupt+0x58/0x62
 [<ffffffff80261faf>] apic_timer_interrupt+0x6b/0x70
DWARF2 unwinder stuck at apic_timer_interrupt+0x6b/0x70
Leftover inexact backtrace:
 <IRQ> [<ffffffff80232976>] dev_queue_xmit+0x107/0x268
 [<ffffffff80232976>] dev_queue_xmit+0x107/0x268
 [<ffffffff8022779a>] __rb_rotate_left+0x3d/0x60
 [<ffffffff802135fb>] rb_insert_color+0xb9/0xe3
 [<ffffffff8860aa1a>] :sch_htb:htb_add_to_id_tree+0x64/0x66
 [<ffffffff8860aaf2>] :sch_htb:htb_activate_prios+0xd6/0xe7
 [<ffffffff8860c835>] :sch_htb:htb_enqueue+0x139/0x194
 [<ffffffff80232988>] dev_queue_xmit+0x119/0x268
 [<ffffffff8025b4a2>] neigh_resolve_output+0x249/0x27e
 [<ffffffff802353fd>] ip_output+0x210/0x25a
 [<ffffffff8043ce28>] ip_push_pending_frames+0x37c/0x45b
 [<ffffffff8044ffd7>] icmp_push_reply+0x13b/0x148
 [<ffffffff80450900>] icmp_send+0x366/0x3d3
 [<ffffffff802568a9>] udp_rcv+0x53d/0x556
 [<ffffffff80237e73>] ip_local_deliver+0x1a3/0x26b
 [<ffffffff80238ec8>] ip_rcv+0x4b9/0x501
 [<ffffffff802218bb>] netif_receive_skb+0x33d/0x3c9
 [<ffffffff881f6348>] :e1000:e1000_clean_rx_irq+0x450/0x4fe
 [<ffffffff881f47eb>] :e1000:e1000_clean+0x88/0x17d
 [<ffffffff8020cab3>] net_rx_action+0xac/0x1d1
 [<ffffffff80212711>] __do_softirq+0x54/0xf5
 [<ffffffff80212725>] __do_softirq+0x68/0xf5
 [<ffffffff80262638>] call_softirq+0x1c/0x28
 [<ffffffff80270aaa>] do_softirq+0x39/0x9f
 [<ffffffff80296102>] irq_exit+0x57/0x59
 [<ffffffff80270c0d>] do_IRQ+0xfd/0x107
 [<ffffffff8025b51d>] mwait_idle+0x0/0x54
 [<ffffffff802618c6>] ret_from_intr+0x0/0xf
 <EOI> [<ffffffff80265e66>] __sched_text_start+0xaa6/0xadd
 [<ffffffff8025b55c>] mwait_idle+0x3f/0x54
 [<ffffffff8025b526>] mwait_idle+0x9/0x54
 [<ffffffff8024c81c>] cpu_idle+0xa2/0xc5
 [<ffffffff8026e519>] rest_init+0x2b/0x2d
 [<ffffffff80a7f811>] start_kernel+0x24a/0x24c
 [<ffffffff80a7f28b>] _sinittext+0x28b/0x292

BUG: soft lockup detected on CPU#3!

Call Trace:
 [<ffffffff8026f79b>] show_trace+0xae/0x336
 [<ffffffff8026fa38>] dump_stack+0x15/0x17
 [<ffffffff802bfea7>] softlockup_tick+0xd5/0xea
 [<ffffffff80250dba>] run_local_timers+0x13/0x15
 [<ffffffff8029a0f9>] update_process_times+0x4c/0x79
 [<ffffffff8027a6ca>] smp_local_timer_interrupt+0x2b/0x50
 [<ffffffff8027aea7>] smp_apic_timer_interrupt+0x58/0x62
 [<ffffffff80261faf>] apic_timer_interrupt+0x6b/0x70
DWARF2 unwinder stuck at apic_timer_interrupt+0x6b/0x70
Leftover inexact backtrace:
 <IRQ> [<ffffffff8860c645>] :sch_htb:htb_rate_timer+0x21/0xd8
 [<ffffffff8860c645>] :sch_htb:htb_rate_timer+0x21/0xd8
 [<ffffffff8020cc4c>] __delay+0xa/0x15
 [<ffffffff802079c2>] _raw_spin_lock+0x8c/0x104
 [<ffffffff8860c645>] :sch_htb:htb_rate_timer+0x21/0xd8
 [<ffffffff802687b9>] _spin_lock_bh+0x32/0x36
 [<ffffffff8860c645>] :sch_htb:htb_rate_timer+0x21/0xd8
 [<ffffffff802998c6>] run_timer_softirq+0x14c/0x1d5
 [<ffffffff80212725>] __do_softirq+0x68/0xf5
 [<ffffffff80262638>] call_softirq+0x1c/0x28
 [<ffffffff80270aaa>] do_softirq+0x39/0x9f
 [<ffffffff80296102>] irq_exit+0x57/0x59
 [<ffffffff8027aeac>] smp_apic_timer_interrupt+0x5d/0x62
 [<ffffffff8025b51d>] mwait_idle+0x0/0x54
 [<ffffffff80261faf>] apic_timer_interrupt+0x6b/0x70
 <EOI> [<ffffffff80265e66>] __sched_text_start+0xaa6/0xadd
 [<ffffffff8025b55c>] mwait_idle+0x3f/0x54
 [<ffffffff8025b526>] mwait_idle+0x9/0x54
 [<ffffffff8024c81c>] cpu_idle+0xa2/0xc5
 [<ffffffff8027a4bd>] start_secondary+0x468/0x477

BUG: soft lockup detected on CPU#0!

Call Trace:
 [<ffffffff8026f79b>] show_trace+0xae/0x336
 [<ffffffff8026fa38>] dump_stack+0x15/0x17
 [<ffffffff802bfea7>] softlockup_tick+0xd5/0xea
 [<ffffffff80250dba>] run_local_timers+0x13/0x15
 [<ffffffff8029a0f9>] update_process_times+0x4c/0x79
 [<ffffffff8027a6ca>] smp_local_timer_interrupt+0x2b/0x50
 [<ffffffff8027aea7>] smp_apic_timer_interrupt+0x58/0x62
 [<ffffffff80261faf>] apic_timer_interrupt+0x6b/0x70
DWARF2 unwinder stuck at apic_timer_interrupt+0x6b/0x70
Leftover inexact backtrace:
 <IRQ> [<ffffffff80232976>] dev_queue_xmit+0x107/0x268
 [<ffffffff80232976>] dev_queue_xmit+0x107/0x268
 [<ffffffff802241c6>] __rb_rotate_right+0x41/0x60
 [<ffffffff802135aa>] rb_insert_color+0x68/0xe3
 [<ffffffff8860aa1a>] :sch_htb:htb_add_to_id_tree+0x64/0x66
 [<ffffffff8860aaf2>] :sch_htb:htb_activate_prios+0xd6/0xe7
 [<ffffffff8860c835>] :sch_htb:htb_enqueue+0x139/0x194
 [<ffffffff80232988>] dev_queue_xmit+0x119/0x268
 [<ffffffff8025b4a2>] neigh_resolve_output+0x249/0x27e
 [<ffffffff802353fd>] ip_output+0x210/0x25a
 [<ffffffff8043ce28>] ip_push_pending_frames+0x37c/0x45b
 [<ffffffff8044ffd7>] icmp_push_reply+0x13b/0x148
 [<ffffffff80450900>] icmp_send+0x366/0x3d3
 [<ffffffff802568a9>] udp_rcv+0x53d/0x556
 [<ffffffff80237e73>] ip_local_deliver+0x1a3/0x26b
 [<ffffffff80238ec8>] ip_rcv+0x4b9/0x501
 [<ffffffff802218bb>] netif_receive_skb+0x33d/0x3c9
 [<ffffffff881f6348>] :e1000:e1000_clean_rx_irq+0x450/0x4fe
 [<ffffffff881f47eb>] :e1000:e1000_clean+0x88/0x17d
 [<ffffffff8020cab3>] net_rx_action+0xac/0x1d1
 [<ffffffff80212711>] __do_softirq+0x54/0xf5
 [<ffffffff80212725>] __do_softirq+0x68/0xf5
 [<ffffffff80262638>] call_softirq+0x1c/0x28
 [<ffffffff80270aaa>] do_softirq+0x39/0x9f
 [<ffffffff80296102>] irq_exit+0x57/0x59
 [<ffffffff80270c0d>] do_IRQ+0xfd/0x107
 [<ffffffff8025b51d>] mwait_idle+0x0/0x54
 [<ffffffff802618c6>] ret_from_intr+0x0/0xf
 <EOI> [<ffffffff80265e66>] __sched_text_start+0xaa6/0xadd
 [<ffffffff8025b55c>] mwait_idle+0x3f/0x54
 [<ffffffff8025b526>] mwait_idle+0x9/0x54
 [<ffffffff8024c81c>] cpu_idle+0xa2/0xc5
 [<ffffffff8026e519>] rest_init+0x2b/0x2d
 [<ffffffff80a7f811>] start_kernel+0x24a/0x24c
 [<ffffffff80a7f28b>] _sinittext+0x28b/0x292

BUG: soft lockup detected on CPU#3!

Call Trace:
 [<ffffffff8026f79b>] show_trace+0xae/0x336
 [<ffffffff8026fa38>] dump_stack+0x15/0x17
 [<ffffffff802bfea7>] softlockup_tick+0xd5/0xea
 [<ffffffff80250dba>] run_local_timers+0x13/0x15
 [<ffffffff8029a0f9>] update_process_times+0x4c/0x79
 [<ffffffff8027a6ca>] smp_local_timer_interrupt+0x2b/0x50
 [<ffffffff8027aea7>] smp_apic_timer_interrupt+0x58/0x62
 [<ffffffff80261faf>] apic_timer_interrupt+0x6b/0x70
DWARF2 unwinder stuck at apic_timer_interrupt+0x6b/0x70
Leftover inexact backtrace:
 <IRQ> [<ffffffff8860c645>] :sch_htb:htb_rate_timer+0x21/0xd8
 [<ffffffff8860c645>] :sch_htb:htb_rate_timer+0x21/0xd8
 [<ffffffff8020cc48>] __delay+0x6/0x15
 [<ffffffff802079c2>] _raw_spin_lock+0x8c/0x104
 [<ffffffff8860c645>] :sch_htb:htb_rate_timer+0x21/0xd8
 [<ffffffff802687b9>] _spin_lock_bh+0x32/0x36
 [<ffffffff8860c645>] :sch_htb:htb_rate_timer+0x21/0xd8
 [<ffffffff802998c6>] run_timer_softirq+0x14c/0x1d5
 [<ffffffff80212725>] __do_softirq+0x68/0xf5
 [<ffffffff80262638>] call_softirq+0x1c/0x28
 [<ffffffff80270aaa>] do_softirq+0x39/0x9f
 [<ffffffff80296102>] irq_exit+0x57/0x59
 [<ffffffff8027aeac>] smp_apic_timer_interrupt+0x5d/0x62
 [<ffffffff8025b51d>] mwait_idle+0x0/0x54
 [<ffffffff80261faf>] apic_timer_interrupt+0x6b/0x70
 <EOI> [<ffffffff80265e66>] __sched_text_start+0xaa6/0xadd
 [<ffffffff8025b55c>] mwait_idle+0x3f/0x54
 [<ffffffff8025b526>] mwait_idle+0x9/0x54
 [<ffffffff8024c81c>] cpu_idle+0xa2/0xc5
 [<ffffffff8027a4bd>] start_secondary+0x468/0x477

BUG: soft lockup detected on CPU#0!

Call Trace:
 [<ffffffff8026f79b>] show_trace+0xae/0x336
 [<ffffffff8026fa38>] dump_stack+0x15/0x17
 [<ffffffff802bfea7>] softlockup_tick+0xd5/0xea
 [<ffffffff80250dba>] run_local_timers+0x13/0x15
 [<ffffffff8029a0f9>] update_process_times+0x4c/0x79
 [<ffffffff8027a6ca>] smp_local_timer_interrupt+0x2b/0x50
 [<ffffffff8027aea7>] smp_apic_timer_interrupt+0x58/0x62
 [<ffffffff80261faf>] apic_timer_interrupt+0x6b/0x70
DWARF2 unwinder stuck at apic_timer_interrupt+0x6b/0x70
Leftover inexact backtrace:
 <IRQ> [<ffffffff80232976>] dev_queue_xmit+0x107/0x268
 [<ffffffff80232976>] dev_queue_xmit+0x107/0x268
 [<ffffffff802135aa>] rb_insert_color+0x68/0xe3
 [<ffffffff802135aa>] rb_insert_color+0x68/0xe3
 [<ffffffff8860aa1a>] :sch_htb:htb_add_to_id_tree+0x64/0x66
 [<ffffffff8860aaf2>] :sch_htb:htb_activate_prios+0xd6/0xe7
 [<ffffffff8860c835>] :sch_htb:htb_enqueue+0x139/0x194
 [<ffffffff80232988>] dev_queue_xmit+0x119/0x268
 [<ffffffff8025b4a2>] neigh_resolve_output+0x249/0x27e
 [<ffffffff802353fd>] ip_output+0x210/0x25a
 [<ffffffff8043ce28>] ip_push_pending_frames+0x37c/0x45b
 [<ffffffff8044ffd7>] icmp_push_reply+0x13b/0x148
 [<ffffffff80450900>] icmp_send+0x366/0x3d3
 [<ffffffff802568a9>] udp_rcv+0x53d/0x556
 [<ffffffff80237e73>] ip_local_deliver+0x1a3/0x26b
 [<ffffffff80238ec8>] ip_rcv+0x4b9/0x501
 [<ffffffff802218bb>] netif_receive_skb+0x33d/0x3c9
 [<ffffffff881f6348>] :e1000:e1000_clean_rx_irq+0x450/0x4fe
 [<ffffffff881f47eb>] :e1000:e1000_clean+0x88/0x17d
 [<ffffffff8020cab3>] net_rx_action+0xac/0x1d1
 [<ffffffff80212711>] __do_softirq+0x54/0xf5
 [<ffffffff80212725>] __do_softirq+0x68/0xf5
 [<ffffffff80262638>] call_softirq+0x1c/0x28
 [<ffffffff80270aaa>] do_softirq+0x39/0x9f
 [<ffffffff80296102>] irq_exit+0x57/0x59
 [<ffffffff80270c0d>] do_IRQ+0xfd/0x107
 [<ffffffff8025b51d>] mwait_idle+0x0/0x54
 [<ffffffff802618c6>] ret_from_intr+0x0/0xf
 <EOI> [<ffffffff80265e66>] __sched_text_start+0xaa6/0xadd
 [<ffffffff8025b55c>] mwait_idle+0x3f/0x54
 [<ffffffff8025b526>] mwait_idle+0x9/0x54
 [<ffffffff8024c81c>] cpu_idle+0xa2/0xc5
 [<ffffffff8026e519>] rest_init+0x2b/0x2d
 [<ffffffff80a7f811>] start_kernel+0x24a/0x24c
 [<ffffffff80a7f28b>] _sinittext+0x28b/0x292

BUG: soft lockup detected on CPU#3!

Call Trace:
 [<ffffffff8026f79b>] show_trace+0xae/0x336
 [<ffffffff8026fa38>] dump_stack+0x15/0x17
 [<ffffffff802bfea7>] softlockup_tick+0xd5/0xea
 [<ffffffff80250dba>] run_local_timers+0x13/0x15
 [<ffffffff8029a0f9>] update_process_times+0x4c/0x79
 [<ffffffff8027a6ca>] smp_local_timer_interrupt+0x2b/0x50
 [<ffffffff8027aea7>] smp_apic_timer_interrupt+0x58/0x62
 [<ffffffff80261faf>] apic_timer_interrupt+0x6b/0x70
DWARF2 unwinder stuck at apic_timer_interrupt+0x6b/0x70
Leftover inexact backtrace:
 <IRQ> [<ffffffff8860c645>] :sch_htb:htb_rate_timer+0x21/0xd8
 [<ffffffff8860c645>] :sch_htb:htb_rate_timer+0x21/0xd8
 [<ffffffff8020cc48>] __delay+0x6/0x15
 [<ffffffff802079c2>] _raw_spin_lock+0x8c/0x104
 [<ffffffff8860c645>] :sch_htb:htb_rate_timer+0x21/0xd8
 [<ffffffff802687b9>] _spin_lock_bh+0x32/0x36
 [<ffffffff8860c645>] :sch_htb:htb_rate_timer+0x21/0xd8
 [<ffffffff802998c6>] run_timer_softirq+0x14c/0x1d5
 [<ffffffff80212725>] __do_softirq+0x68/0xf5
 [<ffffffff80262638>] call_softirq+0x1c/0x28
 [<ffffffff80270aaa>] do_softirq+0x39/0x9f
 [<ffffffff80296102>] irq_exit+0x57/0x59
 [<ffffffff8027aeac>] smp_apic_timer_interrupt+0x5d/0x62
 [<ffffffff8025b51d>] mwait_idle+0x0/0x54
 [<ffffffff80261faf>] apic_timer_interrupt+0x6b/0x70
 <EOI> [<ffffffff80265e66>] __sched_text_start+0xaa6/0xadd
 [<ffffffff8025b55c>] mwait_idle+0x3f/0x54
 [<ffffffff8025b526>] mwait_idle+0x9/0x54
 [<ffffffff8024c81c>] cpu_idle+0xa2/0xc5
 [<ffffffff8027a4bd>] start_secondary+0x468/0x477

BUG: soft lockup detected on CPU#0!

Call Trace:
 [<ffffffff8026f79b>] show_trace+0xae/0x336
 [<ffffffff8026fa38>] dump_stack+0x15/0x17
 [<ffffffff802bfea7>] softlockup_tick+0xd5/0xea
 [<ffffffff80250dba>] run_local_timers+0x13/0x15
 [<ffffffff8029a0f9>] update_process_times+0x4c/0x79
 [<ffffffff8027a6ca>] smp_local_timer_interrupt+0x2b/0x50
 [<ffffffff8027aea7>] smp_apic_timer_interrupt+0x58/0x62
 [<ffffffff80261faf>] apic_timer_interrupt+0x6b/0x70
DWARF2 unwinder stuck at apic_timer_interrupt+0x6b/0x70
Leftover inexact backtrace:
 <IRQ> [<ffffffff80232976>] dev_queue_xmit+0x107/0x268
 [<ffffffff80232976>] dev_queue_xmit+0x107/0x268
 [<ffffffff80213605>] rb_insert_color+0xc3/0xe3
 [<ffffffff802135aa>] rb_insert_color+0x68/0xe3
 [<ffffffff8860aa1a>] :sch_htb:htb_add_to_id_tree+0x64/0x66
 [<ffffffff8860aaf2>] :sch_htb:htb_activate_prios+0xd6/0xe7
 [<ffffffff8860c835>] :sch_htb:htb_enqueue+0x139/0x194
 [<ffffffff80232988>] dev_queue_xmit+0x119/0x268
 [<ffffffff8025b4a2>] neigh_resolve_output+0x249/0x27e
 [<ffffffff802353fd>] ip_output+0x210/0x25a
 [<ffffffff8043ce28>] ip_push_pending_frames+0x37c/0x45b
 [<ffffffff8044ffd7>] icmp_push_reply+0x13b/0x148
 [<ffffffff80450900>] icmp_send+0x366/0x3d3
 [<ffffffff802568a9>] udp_rcv+0x53d/0x556
 [<ffffffff80237e73>] ip_local_deliver+0x1a3/0x26b
 [<ffffffff80238ec8>] ip_rcv+0x4b9/0x501
 [<ffffffff802218bb>] netif_receive_skb+0x33d/0x3c9
 [<ffffffff881f6348>] :e1000:e1000_clean_rx_irq+0x450/0x4fe
 [<ffffffff881f47eb>] :e1000:e1000_clean+0x88/0x17d
 [<ffffffff8020cab3>] net_rx_action+0xac/0x1d1
 [<ffffffff80212711>] __do_softirq+0x54/0xf5
 [<ffffffff80212725>] __do_softirq+0x68/0xf5
 [<ffffffff80262638>] call_softirq+0x1c/0x28
 [<ffffffff80270aaa>] do_softirq+0x39/0x9f
 [<ffffffff80296102>] irq_exit+0x57/0x59
 [<ffffffff80270c0d>] do_IRQ+0xfd/0x107
 [<ffffffff8025b51d>] mwait_idle+0x0/0x54
 [<ffffffff802618c6>] ret_from_intr+0x0/0xf
 <EOI> [<ffffffff80265e66>] __sched_text_start+0xaa6/0xadd
 [<ffffffff8025b55c>] mwait_idle+0x3f/0x54
 [<ffffffff8025b526>] mwait_idle+0x9/0x54
 [<ffffffff8024c81c>] cpu_idle+0xa2/0xc5
 [<ffffffff8026e519>] rest_init+0x2b/0x2d
 [<ffffffff80a7f811>] start_kernel+0x24a/0x24c
 [<ffffffff80a7f28b>] _sinittext+0x28b/0x292

BUG: soft lockup detected on CPU#3!

Call Trace:
 [<ffffffff8026f79b>] show_trace+0xae/0x336
 [<ffffffff8026fa38>] dump_stack+0x15/0x17
 [<ffffffff802bfea7>] softlockup_tick+0xd5/0xea
 [<ffffffff80250dba>] run_local_timers+0x13/0x15
 [<ffffffff8029a0f9>] update_process_times+0x4c/0x79
 [<ffffffff8027a6ca>] smp_local_timer_interrupt+0x2b/0x50
 [<ffffffff8027aea7>] smp_apic_timer_interrupt+0x58/0x62
 [<ffffffff80261faf>] apic_timer_interrupt+0x6b/0x70
DWARF2 unwinder stuck at apic_timer_interrupt+0x6b/0x70
Leftover inexact backtrace:
 <IRQ> [<ffffffff8860c645>] :sch_htb:htb_rate_timer+0x21/0xd8
 [<ffffffff8860c645>] :sch_htb:htb_rate_timer+0x21/0xd8
 [<ffffffff8020cc4c>] __delay+0xa/0x15
 [<ffffffff802079c2>] _raw_spin_lock+0x8c/0x104
 [<ffffffff8860c645>] :sch_htb:htb_rate_timer+0x21/0xd8
 [<ffffffff802687b9>] _spin_lock_bh+0x32/0x36
 [<ffffffff8860c645>] :sch_htb:htb_rate_timer+0x21/0xd8
 [<ffffffff802998c6>] run_timer_softirq+0x14c/0x1d5
 [<ffffffff80212725>] __do_softirq+0x68/0xf5
 [<ffffffff80262638>] call_softirq+0x1c/0x28
 [<ffffffff80270aaa>] do_softirq+0x39/0x9f
 [<ffffffff80296102>] irq_exit+0x57/0x59
 [<ffffffff8027aeac>] smp_apic_timer_interrupt+0x5d/0x62
 [<ffffffff8025b51d>] mwait_idle+0x0/0x54
 [<ffffffff80261faf>] apic_timer_interrupt+0x6b/0x70
 <EOI> [<ffffffff80265e66>] __sched_text_start+0xaa6/0xadd
 [<ffffffff8025b55c>] mwait_idle+0x3f/0x54
 [<ffffffff8025b526>] mwait_idle+0x9/0x54
 [<ffffffff8024c81c>] cpu_idle+0xa2/0xc5
 [<ffffffff8027a4bd>] start_secondary+0x468/0x477

BUG: soft lockup detected on CPU#1!

Call Trace:
 [<ffffffff8026f79b>] show_trace+0xae/0x336
 [<ffffffff8026fa38>] dump_stack+0x15/0x17
 [<ffffffff802bfea7>] softlockup_tick+0xd5/0xea
 [<ffffffff80250dba>] run_local_timers+0x13/0x15
 [<ffffffff8029a0f9>] update_process_times+0x4c/0x79
 [<ffffffff8027a6ca>] smp_local_timer_interrupt+0x2b/0x50
 [<ffffffff8027aea7>] smp_apic_timer_interrupt+0x58/0x62
 [<ffffffff80261faf>] apic_timer_interrupt+0x6b/0x70
DWARF2 unwinder stuck at apic_timer_interrupt+0x6b/0x70
Leftover inexact backtrace:
 <IRQ> <EOI> [<ffffffff80232976>] dev_queue_xmit+0x107/0x268
 [<ffffffff80232976>] dev_queue_xmit+0x107/0x268
 [<ffffffff8020cc4e>] __delay+0xc/0x15
 [<ffffffff802079c2>] _raw_spin_lock+0x8c/0x104
 [<ffffffff80232976>] dev_queue_xmit+0x107/0x268
 [<ffffffff80268783>] _spin_lock+0x2d/0x31
 [<ffffffff80232976>] dev_queue_xmit+0x107/0x268
 [<ffffffff802353fd>] ip_output+0x210/0x25a
 [<ffffffff8043ce28>] ip_push_pending_frames+0x37c/0x45b
 [<ffffffff8043dc27>] ip_generic_getfrag+0x0/0x98
 [<ffffffff8044d712>] udp_push_pending_frames+0x251/0x278
 [<ffffffff80256249>] udp_sendmsg+0x4b8/0x5db
 [<ffffffff8024857b>] inet_sendmsg+0x46/0x53
 [<ffffffff80258da5>] sock_sendmsg+0x111/0x130
 [<ffffffff802a2c18>] autoremove_wake_function+0x0/0x38
 [<ffffffff80268a62>] _spin_unlock_irq+0x2b/0x31
 [<ffffffff802681fe>] trace_hardirqs_on_thunk+0x35/0x37
 [<ffffffff802681fe>] trace_hardirqs_on_thunk+0x35/0x37
 [<ffffffff80416108>] sys_sendto+0x106/0x12d
 [<ffffffff80246770>] sys_rt_sigreturn+0x28f/0x360
 [<ffffffff8024680f>] sys_rt_sigreturn+0x32e/0x360
 [<ffffffff8026138e>] system_call+0x7e/0x83

BUG: soft lockup detected on CPU#0!

Call Trace:
 [<ffffffff8026f79b>] show_trace+0xae/0x336
 [<ffffffff8026fa38>] dump_stack+0x15/0x17
 [<ffffffff802bfea7>] softlockup_tick+0xd5/0xea
 [<ffffffff80250dba>] run_local_timers+0x13/0x15
 [<ffffffff8029a0f9>] update_process_times+0x4c/0x79
 [<ffffffff8027a6ca>] smp_local_timer_interrupt+0x2b/0x50
 [<ffffffff8027aea7>] smp_apic_timer_interrupt+0x58/0x62
 [<ffffffff80261faf>] apic_timer_interrupt+0x6b/0x70
DWARF2 unwinder stuck at apic_timer_interrupt+0x6b/0x70
Leftover inexact backtrace:
 <IRQ> [<ffffffff80232976>] dev_queue_xmit+0x107/0x268
 [<ffffffff80232976>] dev_queue_xmit+0x107/0x268
 [<ffffffff80213596>] rb_insert_color+0x54/0xe3
 [<ffffffff802135fb>] rb_insert_color+0xb9/0xe3
 [<ffffffff8860aa1a>] :sch_htb:htb_add_to_id_tree+0x64/0x66
 [<ffffffff8860aaf2>] :sch_htb:htb_activate_prios+0xd6/0xe7
 [<ffffffff8860c835>] :sch_htb:htb_enqueue+0x139/0x194
 [<ffffffff80232988>] dev_queue_xmit+0x119/0x268
 [<ffffffff8025b4a2>] neigh_resolve_output+0x249/0x27e
 [<ffffffff802353fd>] ip_output+0x210/0x25a
 [<ffffffff8043ce28>] ip_push_pending_frames+0x37c/0x45b
 [<ffffffff8044ffd7>] icmp_push_reply+0x13b/0x148
 [<ffffffff80450900>] icmp_send+0x366/0x3d3
 [<ffffffff802568a9>] udp_rcv+0x53d/0x556
 [<ffffffff80237e73>] ip_local_deliver+0x1a3/0x26b
 [<ffffffff80238ec8>] ip_rcv+0x4b9/0x501
 [<ffffffff802218bb>] netif_receive_skb+0x33d/0x3c9
 [<ffffffff881f6348>] :e1000:e1000_clean_rx_irq+0x450/0x4fe
 [<ffffffff881f47eb>] :e1000:e1000_clean+0x88/0x17d
 [<ffffffff8020cab3>] net_rx_action+0xac/0x1d1
 [<ffffffff80212711>] __do_softirq+0x54/0xf5
 [<ffffffff80212725>] __do_softirq+0x68/0xf5
 [<ffffffff80262638>] call_softirq+0x1c/0x28
 [<ffffffff80270aaa>] do_softirq+0x39/0x9f
 [<ffffffff80296102>] irq_exit+0x57/0x59
 [<ffffffff80270c0d>] do_IRQ+0xfd/0x107
 [<ffffffff8025b51d>] mwait_idle+0x0/0x54
 [<ffffffff802618c6>] ret_from_intr+0x0/0xf
 <EOI> [<ffffffff80265e66>] __sched_text_start+0xaa6/0xadd
 [<ffffffff8025b55c>] mwait_idle+0x3f/0x54
 [<ffffffff8025b526>] mwait_idle+0x9/0x54
 [<ffffffff8024c81c>] cpu_idle+0xa2/0xc5
 [<ffffffff8026e519>] rest_init+0x2b/0x2d
 [<ffffffff80a7f811>] start_kernel+0x24a/0x24c
 [<ffffffff80a7f28b>] _sinittext+0x28b/0x292

BUG: soft lockup detected on CPU#3!

Call Trace:
 [<ffffffff8026f79b>] show_trace+0xae/0x336
 [<ffffffff8026fa38>] dump_stack+0x15/0x17
 [<ffffffff802bfea7>] softlockup_tick+0xd5/0xea
 [<ffffffff80250dba>] run_local_timers+0x13/0x15
 [<ffffffff8029a0f9>] update_process_times+0x4c/0x79
 [<ffffffff8027a6ca>] smp_local_timer_interrupt+0x2b/0x50
 [<ffffffff8027aea7>] smp_apic_timer_interrupt+0x58/0x62
 [<ffffffff80261faf>] apic_timer_interrupt+0x6b/0x70
DWARF2 unwinder stuck at apic_timer_interrupt+0x6b/0x70
Leftover inexact backtrace:
 <IRQ> [<ffffffff8860c645>] :sch_htb:htb_rate_timer+0x21/0xd8
 [<ffffffff8860c645>] :sch_htb:htb_rate_timer+0x21/0xd8
 [<ffffffff8020cc4c>] __delay+0xa/0x15
 [<ffffffff802079c2>] _raw_spin_lock+0x8c/0x104
 [<ffffffff8860c645>] :sch_htb:htb_rate_timer+0x21/0xd8
 [<ffffffff802687b9>] _spin_lock_bh+0x32/0x36
 [<ffffffff8860c645>] :sch_htb:htb_rate_timer+0x21/0xd8
 [<ffffffff802998c6>] run_timer_softirq+0x14c/0x1d5
 [<ffffffff80212725>] __do_softirq+0x68/0xf5
 [<ffffffff80262638>] call_softirq+0x1c/0x28
 [<ffffffff80270aaa>] do_softirq+0x39/0x9f
 [<ffffffff80296102>] irq_exit+0x57/0x59
 [<ffffffff8027aeac>] smp_apic_timer_interrupt+0x5d/0x62
 [<ffffffff8025b51d>] mwait_idle+0x0/0x54
 [<fff


-- 
http://www.codemonkey.org.uk
