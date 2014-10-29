From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: e1000_netpoll(): disable_irq() triggers might_sleep() on
 linux-next
Date: Wed, 29 Oct 2014 19:07:34 +0100
Message-ID: <20141029180734.GQ12706@worktop.programming.kicks-ass.net>
References: <20141029155620.GA4886@kria>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jeffrey.t.kirsher@intel.com, Thomas Gleixner <tglx@linutronix.de>
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141029155620.GA4886@kria>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 29, 2014 at 04:56:20PM +0100, Sabrina Dubroca wrote:
> commit e22b886a8a43b ("sched/wait: Add might_sleep() checks") included
> in today's linux-next added a check that fires on e1000 with netpoll:
> 
> 
> BUG: sleeping function called from invalid context at kernel/irq/manage.c:104
> in_atomic(): 1, irqs_disabled(): 1, pid: 1, name: systemd
> no locks held by systemd/1.
> irq event stamp: 10102965
> hardirqs last  enabled at (10102965): [<ffffffff810cbafd>] vprintk_emit+0x2dd/0x6a0
> hardirqs last disabled at (10102964): [<ffffffff810cb897>] vprintk_emit+0x77/0x6a0
> softirqs last  enabled at (10102342): [<ffffffff810666aa>] __do_softirq+0x27a/0x6f0
> softirqs last disabled at (10102337): [<ffffffff81066e86>] irq_exit+0x56/0xe0
> Preemption disabled at:[<ffffffff817de50d>] printk_emit+0x31/0x33
> 
> CPU: 1 PID: 1 Comm: systemd Not tainted 3.18.0-rc2-next-20141029-dirty #222
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.7.5-20140617_173321-var-lib-archbuild-testing-x86_64-tobias 04/01/2014
>  ffffffff81a82291 ffff88001e743978 ffffffff817df31d 0000000000000000
>  0000000000000000 ffff88001e7439a8 ffffffff8108dfa2 ffff88001e7439a8
>  ffffffff81a82291 0000000000000068 0000000000000000 ffff88001e7439d8
> Call Trace:
>  [<ffffffff817df31d>] dump_stack+0x4f/0x7c
>  [<ffffffff8108dfa2>] ___might_sleep+0x182/0x2b0
>  [<ffffffff8108e10a>] __might_sleep+0x3a/0xc0
>  [<ffffffff810ce358>] synchronize_irq+0x38/0xa0
>  [<ffffffff810ce690>] disable_irq+0x20/0x30
>  [<ffffffff815d7253>] e1000_netpoll+0x23/0x60
>  [<ffffffff81678d02>] netpoll_poll_dev+0x72/0x3a0
>  [<ffffffff816791e7>] netpoll_send_skb_on_dev+0x1b7/0x2e0
>  [<ffffffff816795f3>] netpoll_send_udp+0x2e3/0x490

Oh cute.. not entirely sure what to do there. This only works if you
_know_ desc->threads_active will never be !0.

The best I can come up with is something like this, which avoids the
might_sleep() in the one special case.

Thomas?

---
 kernel/irq/manage.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/kernel/irq/manage.c b/kernel/irq/manage.c
index 0a9104b4608b..b7cb736a8b32 100644
--- a/kernel/irq/manage.c
+++ b/kernel/irq/manage.c
@@ -100,8 +100,11 @@ void synchronize_irq(unsigned int irq)
 		 * running. Now verify that no threaded handlers are
 		 * active.
 		 */
-		wait_event(desc->wait_for_threads,
-			   !atomic_read(&desc->threads_active));
+		if (atomic_read(&desc->threads_active)) {
+			might_sleep();
+			__wait_event(desc->wait_for_threads,
+				     !atomic_read(&desc->threads_active));
+		}
 	}
 }
 EXPORT_SYMBOL(synchronize_irq);
