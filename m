From: Dave Jones <davej@codemonkey.org.uk>
Subject: Re: 3.19-rc7 netconsole locking bug.
Date: Wed, 4 Feb 2015 14:59:01 -0500
Message-ID: <20150204195901.GA1682@codemonkey.org.uk>
References: <20150204193902.GB652@codemonkey.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from arcturus.aphlor.org ([188.246.204.175]:32904 "EHLO
	arcturus.aphlor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1162074AbbBDT7G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 14:59:06 -0500
Received: from arcturus.ipv6.aphlor.org ([2a03:9800:10:4a::2] helo=codemonkey.org.uk)
	by arcturus.aphlor.org with esmtpsa (TLSv1.2:AES128-GCM-SHA256:128)
	(Exim 4.80.1)
	(envelope-from <davej@codemonkey.org.uk>)
	id 1YJ66J-0000TT-1i
	for netdev@vger.kernel.org; Wed, 04 Feb 2015 19:59:03 +0000
Content-Disposition: inline
In-Reply-To: <20150204193902.GB652@codemonkey.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 04, 2015 at 02:39:02PM -0500, Dave Jones wrote:
 > I set up netconsole this morning, and noticed when I rebooted the machine
 > that this happens when it initializes..
 > ... 
 > 
 > Despite the positive sounding last two lines, nothing actually gets logged
 > over the netconsole.

After changing the boot process to modprobe netconsole later, I still
see the same spew, but the console now works.
However, shortly afterwards, there's another locking warning..

BUG: sleeping function called from invalid context at kernel/irq/manage.c:104
in_atomic(): 1, irqs_disabled(): 1, pid: 0, name: swapper/1
4 locks held by swapper/1/0:
 #0:  (rcu_read_lock){......}, at: [<ffffffffa07c7e98>] __netif_receive_skb_core+0x78/0xc00
 #1:  (rcu_read_lock_bh){......}, at: [<ffffffffa084676f>] ip_finish_output2+0x9f/0xaa0
 #2:  (rcu_read_lock_bh){......}, at: [<ffffffffa07cd9a3>] __dev_queue_xmit+0x63/0xbe0
 #3:  (_xmit_ETHER#2){+.-...}, at: [<ffffffffa0801b3f>] sch_direct_xmit+0x11f/0x330
irq event stamp: 136019
hardirqs last  enabled at (136018): [<ffffffffa09b26da>] _raw_spin_unlock_irqrestore+0x5a/0xb0
hardirqs last disabled at (136019): [<ffffffffa09b4cca>] irq_work_interrupt+0x6a/0x80
softirqs last  enabled at (135536): [<ffffffffa0093fd5>] _local_bh_enable+0x25/0x80
softirqs last disabled at (135537): [<ffffffffa00952ed>] irq_exit+0x27d/0x2e0
CPU: 1 PID: 0 Comm: swapper/1 Not tainted 3.19.0-rc7+ #13 
 ffffffffa0d3d363 2097f77ab05a8c13 ffff88007ec03160 ffffffffa09a5efa
 0000000000000000 0000000000000000 ffff88007ec03190 ffffffffa00ca277
 ffff88007ec03190 ffffffffa0d3d363 0000000000000068 0000000000000000
Call Trace:
 <IRQ>  [<ffffffffa09a5efa>] dump_stack+0x84/0xb9
 [<ffffffffa00ca277>] ___might_sleep+0x2d7/0x390
 [<ffffffffa00ca3b0>] __might_sleep+0x80/0x100
 [<ffffffffa01123f7>] synchronize_irq+0x67/0x120
 [<ffffffffa01125a9>] ? __disable_irq_nosync+0x69/0xc0
 [<ffffffffa0112634>] disable_irq+0x34/0x50
 [<ffffffffa06c93f5>] e1000_netpoll+0x55/0x1d0
 [<ffffffffa07fc3f9>] netpoll_poll_dev+0x99/0x300
 [<ffffffffa07fc83f>] netpoll_send_skb_on_dev+0x1df/0x470
 [<ffffffffa07fcddc>] netpoll_send_udp+0x30c/0x5a0
 [<ffffffffc016c1c5>] ? write_msg+0x65/0x1b0 [netconsole]
 [<ffffffffc016c267>] write_msg+0x107/0x1b0 [netconsole]
 [<ffffffffa010dad9>] call_console_drivers.constprop.10+0x129/0x190
 [<ffffffffa010edf4>] console_unlock+0x534/0x740
 [<ffffffffa010ff8a>] ? vprintk_emit+0x43a/0xa80
 [<ffffffffa01103d3>] vprintk_emit+0x883/0xa80
 [<ffffffffa00d96ed>] ? local_clock+0x4d/0x60
 [<ffffffffa01105f2>] vprintk_default+0x22/0x30
 [<ffffffffa09a5369>] printk+0x58/0x75
 [<ffffffffa01954fb>] perf_duration_warn+0x6b/0x80
 [<ffffffffa0192b6f>] irq_work_run_list+0x7f/0xd0
 [<ffffffffa0192be8>] irq_work_run+0x28/0x70
 [<ffffffffa000c3c1>] smp_irq_work_interrupt+0x51/0x70
 [<ffffffffa09b4ccf>] irq_work_interrupt+0x6f/0x80
 [<ffffffffa014ec54>] ? __module_address+0x24/0x1e0
 [<ffffffffa014ee2a>] __module_text_address+0x1a/0xb0
 [<ffffffffa0155060>] is_module_text_address+0x20/0x40
 [<ffffffffa00bd684>] __kernel_text_address+0x94/0xe0
 [<ffffffffa0009e0e>] print_context_stack+0x6e/0x130
 [<ffffffffa00082e8>] dump_trace+0x2f8/0x600
 [<ffffffffa01036eb>] ? mark_held_locks+0xcb/0x110
 [<ffffffffa09b26da>] ? _raw_spin_unlock_irqrestore+0x5a/0xb0
 [<ffffffffa001acc3>] save_stack_trace+0x33/0x70
 [<ffffffffa04452ea>] dma_entry_alloc+0x7a/0xd0
 [<ffffffffa0445edb>] debug_dma_map_page+0xdb/0x1e0
 [<ffffffffa06c6e87>] e1000_xmit_frame+0xa27/0x1660
 [<ffffffffa07cd6fb>] dev_hard_start_xmit+0x4fb/0x740
 [<ffffffffa07cd278>] ? dev_hard_start_xmit+0x78/0x740
 [<ffffffffa0801b3f>] ? sch_direct_xmit+0x11f/0x330
 [<ffffffffa0801b79>] sch_direct_xmit+0x159/0x330
 [<ffffffffa07cdcba>] __dev_queue_xmit+0x37a/0xbe0
 [<ffffffffa07cd9a3>] ? __dev_queue_xmit+0x63/0xbe0
 [<ffffffffa00d96ed>] ? local_clock+0x4d/0x60
 [<ffffffffa07ce553>] dev_queue_xmit+0x13/0x20
 [<ffffffffa0846ecd>] ip_finish_output2+0x7fd/0xaa0
 [<ffffffffa0848788>] ? ip_finish_output+0x498/0x810
 [<ffffffffa00f9b7c>] ? __lock_is_held+0x7c/0xb0
 [<ffffffffa0848788>] ip_finish_output+0x498/0x810
 [<ffffffffa0849fe8>] ip_output+0xb8/0x1a0
 [<ffffffffa0841db7>] ip_forward_finish+0xd7/0x2a0
 [<ffffffffa0842604>] ip_forward+0x684/0x990
 [<ffffffffa083e46b>] ip_rcv_finish+0xeb/0x820
 [<ffffffffa083fa05>] ip_rcv+0x3e5/0x5a0
 [<ffffffffa07c86ad>] __netif_receive_skb_core+0x88d/0xc00
 [<ffffffffa07c7e98>] ? __netif_receive_skb_core+0x78/0xc00
 [<ffffffffa07c8a56>] __netif_receive_skb+0x36/0xb0
 [<ffffffffa07c9dd6>] netif_receive_skb_internal+0x66/0x3a0
 [<ffffffffa08a7c7a>] ? inet_gro_complete+0x5a/0x320
 [<ffffffffa07ca39d>] napi_gro_complete+0x28d/0x3a0
 [<ffffffffa07ca143>] ? napi_gro_complete+0x33/0x3a0
 [<ffffffffa07cafe0>] napi_gro_flush+0xa0/0xe0
 [<ffffffffa07cb0f2>] napi_complete_done+0xd2/0x1a0
 [<ffffffffa06cdbcb>] e1000e_poll+0x11b/0x3f0
 [<ffffffffa07cb3f8>] net_rx_action+0x238/0x4e0
 [<ffffffffa00949f6>] __do_softirq+0x1c6/0x460
 [<ffffffffa009518c>] ? irq_exit+0x11c/0x2e0
 [<ffffffffa00952ed>] irq_exit+0x27d/0x2e0
 [<ffffffffa0007b15>] do_IRQ+0x75/0x140
 [<ffffffffa09b44af>] common_interrupt+0x6f/0x6f
 <EOI>  [<ffffffffa076e72a>] ? cpuidle_enter_state+0x7a/0x110
 [<ffffffffa076e71e>] ? cpuidle_enter_state+0x6e/0x110
 [<ffffffffa076e98a>] cpuidle_enter+0x1a/0x30
 [<ffffffffa00f43de>] cpu_startup_entry+0x47e/0x6f0
 [<ffffffffa00440a7>] start_secondary+0x2b7/0x3b0
