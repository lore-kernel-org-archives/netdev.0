From: akpm@osdl.org
Subject: [patch 11/11] forcedeth: hardirq lockdep warning
Date: Mon, 25 Sep 2006 16:39:26 -0700
Message-ID: <200609252339.k8PNdQKG002661@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, a.p.zijlstra@chello.nl,
	aabdulla@nvidia.com, arjan@linux.intel.com, davej@redhat.com,
	mingo@elte.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:26036 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751712AbWIYXkE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2006 19:40:04 -0400
To: jeff@garzik.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Peter Zijlstra <a.p.zijlstra@chello.nl>

BUG: warning at kernel/lockdep.c:1816/trace_hardirqs_on() (Not tainted)

Call Trace:
 show_trace
 dump_stack
 trace_hardirqs_on
 :forcedeth:nv_nic_irq_other
 handle_IRQ_event
 __do_IRQ
 do_IRQ
 ret_from_intr
DWARF2 barf
 default_idle
 cpu_idle
 rest_init
 start_kernel
 _sinittext

These 3 functions nv_nic_irq_tx(), nv_nic_irq_rx() and nv_nic_irq_other()
are reachable from IRQ context and process context. Make use of the
irq-save/restore spinlock variant.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Jeff Garzik <jeff@garzik.org>
Cc: Ingo Molnar <mingo@elte.hu>
Cc: Arjan van de Ven <arjan@linux.intel.com>
Cc: Dave Jones <davej@redhat.com>
Cc: Ayaz Abdulla <aabdulla@nvidia.com>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/forcedeth.c |   31 +++++++++++++++++--------------
 1 file changed, 17 insertions(+), 14 deletions(-)

diff -puN drivers/net/forcedeth.c~forcedeth-hardirq-lockdep-warning drivers/net/forcedeth.c
--- a/drivers/net/forcedeth.c~forcedeth-hardirq-lockdep-warning
+++ a/drivers/net/forcedeth.c
@@ -2497,6 +2497,7 @@ static irqreturn_t nv_nic_irq_tx(int foo
 	u8 __iomem *base = get_hwbase(dev);
 	u32 events;
 	int i;
+	unsigned long flags;
 
 	dprintk(KERN_DEBUG "%s: nv_nic_irq_tx\n", dev->name);
 
@@ -2508,16 +2509,16 @@ static irqreturn_t nv_nic_irq_tx(int foo
 		if (!(events & np->irqmask))
 			break;
 
-		spin_lock_irq(&np->lock);
+		spin_lock_irqsave(&np->lock, flags);
 		nv_tx_done(dev);
-		spin_unlock_irq(&np->lock);
+		spin_unlock_irqrestore(&np->lock, flags);
 
 		if (events & (NVREG_IRQ_TX_ERR)) {
 			dprintk(KERN_DEBUG "%s: received irq with events 0x%x. Probably TX fail.\n",
 						dev->name, events);
 		}
 		if (i > max_interrupt_work) {
-			spin_lock_irq(&np->lock);
+			spin_lock_irqsave(&np->lock, flags);
 			/* disable interrupts on the nic */
 			writel(NVREG_IRQ_TX_ALL, base + NvRegIrqMask);
 			pci_push(base);
@@ -2527,7 +2528,7 @@ static irqreturn_t nv_nic_irq_tx(int foo
 				mod_timer(&np->nic_poll, jiffies + POLL_WAIT);
 			}
 			printk(KERN_DEBUG "%s: too many iterations (%d) in nv_nic_irq_tx.\n", dev->name, i);
-			spin_unlock_irq(&np->lock);
+			spin_unlock_irqrestore(&np->lock, flags);
 			break;
 		}
 
@@ -2601,6 +2602,7 @@ static irqreturn_t nv_nic_irq_rx(int foo
 	u8 __iomem *base = get_hwbase(dev);
 	u32 events;
 	int i;
+	unsigned long flags;
 
 	dprintk(KERN_DEBUG "%s: nv_nic_irq_rx\n", dev->name);
 
@@ -2614,14 +2616,14 @@ static irqreturn_t nv_nic_irq_rx(int foo
 
 		nv_rx_process(dev, dev->weight);
 		if (nv_alloc_rx(dev)) {
-			spin_lock_irq(&np->lock);
+			spin_lock_irqsave(&np->lock, flags);
 			if (!np->in_shutdown)
 				mod_timer(&np->oom_kick, jiffies + OOM_REFILL);
-			spin_unlock_irq(&np->lock);
+			spin_unlock_irqrestore(&np->lock, flags);
 		}
 
 		if (i > max_interrupt_work) {
-			spin_lock_irq(&np->lock);
+			spin_lock_irqsave(&np->lock, flags);
 			/* disable interrupts on the nic */
 			writel(NVREG_IRQ_RX_ALL, base + NvRegIrqMask);
 			pci_push(base);
@@ -2631,7 +2633,7 @@ static irqreturn_t nv_nic_irq_rx(int foo
 				mod_timer(&np->nic_poll, jiffies + POLL_WAIT);
 			}
 			printk(KERN_DEBUG "%s: too many iterations (%d) in nv_nic_irq_rx.\n", dev->name, i);
-			spin_unlock_irq(&np->lock);
+			spin_unlock_irqrestore(&np->lock, flags);
 			break;
 		}
 	}
@@ -2648,6 +2650,7 @@ static irqreturn_t nv_nic_irq_other(int 
 	u8 __iomem *base = get_hwbase(dev);
 	u32 events;
 	int i;
+	unsigned long flags;
 
 	dprintk(KERN_DEBUG "%s: nv_nic_irq_other\n", dev->name);
 
@@ -2660,14 +2663,14 @@ static irqreturn_t nv_nic_irq_other(int 
 			break;
 
 		if (events & NVREG_IRQ_LINK) {
-			spin_lock_irq(&np->lock);
+			spin_lock_irqsave(&np->lock, flags);
 			nv_link_irq(dev);
-			spin_unlock_irq(&np->lock);
+			spin_unlock_irqrestore(&np->lock, flags);
 		}
 		if (np->need_linktimer && time_after(jiffies, np->link_timeout)) {
-			spin_lock_irq(&np->lock);
+			spin_lock_irqsave(&np->lock, flags);
 			nv_linkchange(dev);
-			spin_unlock_irq(&np->lock);
+			spin_unlock_irqrestore(&np->lock, flags);
 			np->link_timeout = jiffies + LINK_TIMEOUT;
 		}
 		if (events & (NVREG_IRQ_UNKNOWN)) {
@@ -2675,7 +2678,7 @@ static irqreturn_t nv_nic_irq_other(int 
 						dev->name, events);
 		}
 		if (i > max_interrupt_work) {
-			spin_lock_irq(&np->lock);
+			spin_lock_irqsave(&np->lock, flags);
 			/* disable interrupts on the nic */
 			writel(NVREG_IRQ_OTHER, base + NvRegIrqMask);
 			pci_push(base);
@@ -2685,7 +2688,7 @@ static irqreturn_t nv_nic_irq_other(int 
 				mod_timer(&np->nic_poll, jiffies + POLL_WAIT);
 			}
 			printk(KERN_DEBUG "%s: too many iterations (%d) in nv_nic_irq_other.\n", dev->name, i);
-			spin_unlock_irq(&np->lock);
+			spin_unlock_irqrestore(&np->lock, flags);
 			break;
 		}
 
_
