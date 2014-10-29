From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: e1000_netpoll(): disable_irq() triggers might_sleep() on
 linux-next
Date: Wed, 29 Oct 2014 19:33:00 +0100 (CET)
Message-ID: <alpine.DEB.2.11.1410291918060.5308@nanos>
References: <20141029155620.GA4886@kria> <20141029180734.GQ12706@worktop.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Sabrina Dubroca <sd@queasysnail.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jeffrey.t.kirsher@intel.com
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141029180734.GQ12706@worktop.programming.kicks-ass.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 29 Oct 2014, Peter Zijlstra wrote:

> On Wed, Oct 29, 2014 at 04:56:20PM +0100, Sabrina Dubroca wrote:
> > commit e22b886a8a43b ("sched/wait: Add might_sleep() checks") included
> > in today's linux-next added a check that fires on e1000 with netpoll:
> > 
> > 
> > BUG: sleeping function called from invalid context at kernel/irq/manage.c:104
> > in_atomic(): 1, irqs_disabled(): 1, pid: 1, name: systemd
> > no locks held by systemd/1.
> > irq event stamp: 10102965
> > hardirqs last  enabled at (10102965): [<ffffffff810cbafd>] vprintk_emit+0x2dd/0x6a0
> > hardirqs last disabled at (10102964): [<ffffffff810cb897>] vprintk_emit+0x77/0x6a0
> > softirqs last  enabled at (10102342): [<ffffffff810666aa>] __do_softirq+0x27a/0x6f0
> > softirqs last disabled at (10102337): [<ffffffff81066e86>] irq_exit+0x56/0xe0
> > Preemption disabled at:[<ffffffff817de50d>] printk_emit+0x31/0x33
> > 
> > CPU: 1 PID: 1 Comm: systemd Not tainted 3.18.0-rc2-next-20141029-dirty #222
> > Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.7.5-20140617_173321-var-lib-archbuild-testing-x86_64-tobias 04/01/2014
> >  ffffffff81a82291 ffff88001e743978 ffffffff817df31d 0000000000000000
> >  0000000000000000 ffff88001e7439a8 ffffffff8108dfa2 ffff88001e7439a8
> >  ffffffff81a82291 0000000000000068 0000000000000000 ffff88001e7439d8
> > Call Trace:
> >  [<ffffffff817df31d>] dump_stack+0x4f/0x7c
> >  [<ffffffff8108dfa2>] ___might_sleep+0x182/0x2b0
> >  [<ffffffff8108e10a>] __might_sleep+0x3a/0xc0
> >  [<ffffffff810ce358>] synchronize_irq+0x38/0xa0
> >  [<ffffffff810ce690>] disable_irq+0x20/0x30
> >  [<ffffffff815d7253>] e1000_netpoll+0x23/0x60
> >  [<ffffffff81678d02>] netpoll_poll_dev+0x72/0x3a0
> >  [<ffffffff816791e7>] netpoll_send_skb_on_dev+0x1b7/0x2e0
> >  [<ffffffff816795f3>] netpoll_send_udp+0x2e3/0x490
> 
> Oh cute.. not entirely sure what to do there. This only works if you
> _know_ desc->threads_active will never be !0.
> 
> The best I can come up with is something like this, which avoids the
> might_sleep() in the one special case.
>  
> Thomas?

Yuck. No. You are just papering over the problem.

What happens if you add 'threadirqs' to the kernel command line? Or if
the interrupt line is shared with a real threaded interrupt user?

The proper solution is to have a poll_lock for e1000 which serializes
the hardware interrupt against netpoll instead of using
disable/enable_irq().

In fact that's less expensive than the disable/enable_irq() dance and
the chance of contention is pretty low. If done right it will be a
NOOP for the CONFIG_NET_POLL_CONTROLLER=n case.

Thanks,

	tglx

 
