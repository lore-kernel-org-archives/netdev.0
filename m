From: Andrew Morton <akpm@osdl.org>
Subject: Fw: Badness in local_bh_enable at kernel/softirq.c:119
Date: Mon, 29 Sep 2003 14:36:42 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030929143642.18b491ba.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: cramerj@intel.com, scott.feldman@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Badness in local_bh_enable at kernel/softirq.c:119
Call Trace:
 [<c01253d7>] local_bh_enable+0x93/0x96
 [<c032d0fb>] xprt_write_space+0xfb/0x158
 [<c02cf42a>] sock_wfree+0x48/0x4a
 [<c02cf3e2>] sock_wfree+0x0/0x4a
 [<c02d02df>] __kfree_skb+0x49/0xda
 [<c020bcc0>] __delay+0x14/0x18
 [<c02752a0>] e1000_clean_tx_irq+0x1f0/0x1f6
 [<c0273a07>] e1000_tx_flush+0x69/0xd0
 [<c0273d08>] e1000_watchdog+0xba/0x340
 [<c011be80>] scheduler_tick+0x5a6/0x5ac
 [<c0273c4e>] e1000_watchdog+0x0/0x340
 [<c0129846>] run_timer_softirq+0xe8/0x1cc
 [<c0116903>] smp_apic_timer_interrupt+0x147/0x14c
 [<c0125341>] do_softirq+0xc9/0xcc
 [<c01253ac>] local_bh_enable+0x68/0x96
 [<c02e63a2>] rt_run_flush+0xa4/0xda
 [<c031f95b>] fib_netdev_event+0x57/0x8b
 [<c012ea23>] notifier_call_chain+0x27/0x40
 [<c02d3e6b>] netdev_state_change+0x37/0x52
 [<c02de65a>] linkwatch_run_queue+0xce/0xe2
 [<c02de694>] linkwatch_event+0x26/0x2c
 [<c0131504>] worker_thread+0x212/0x314
 [<c02de66e>] linkwatch_event+0x0/0x2c
 [<c011c598>] default_wake_function+0x0/0x2e
 [<c01094b6>] ret_from_fork+0x6/0x14
 [<c011c598>] default_wake_function+0x0/0x2e
 [<c01312f2>] worker_thread+0x0/0x314
 [<c010739d>] kernel_thread_helper+0x5/0xc

It hapenned while NFS was having trouble communicating with the server.



Due to this:

		spin_lock_irqsave(&netdev->xmit_lock, flags);
		e1000_tx_flush(adapter);
		spin_unlock_irqrestore(&netdev->xmit_lock, flags);

I'd have thought that calling kfree_skb() under xmit_lock would be a big
ranking bug..  But the reason why the kernel dropped this backtrace is that
local_bh_enable() will unconditionally enable interrupts, so this driver is
exposed to a deadlock.

Other parts of the kernel do not take xmit_lock with irq's disabled, so a
simple spin_lock() here may suffice.

Oh, it's taking xmit_lock in a timer handler.  I give up.
