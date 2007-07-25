From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: 2.6.20->2.6.21 - networking dies after random time
Date: Wed, 25 Jul 2007 02:19:31 +0200
Message-ID: <1185322771.4175.102.camel@chaos>
References: <JKE37W$0126317E099DF36884CC046B6F8A7AA9@xandmail.com>
	 <20070629150759.GC2771@ff.dom.local>
	 <4bacf17f0707222244p664e7a6ap850b3357a57d73c@mail.gmail.com>
	 <20070724080534.GC18740@elte.hu> <20070724094202.GA11610@elte.hu>
	 <alpine.LFD.0.999.0707241228291.3607@woody.linux-foundation.org>
	 <20070724200431.GA22190@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Marcin ??lusarz <marcin.slusarz@gmail.com>,
	Jarek Poplawski <jarkao2@o2.pl>,
	Jean-Baptiste Vignaud <vignaud@xandmail.fr>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	shemminger <shemminger@linux-foundation.org>,
	linux-net <linux-net@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.osadl.org ([213.239.205.134]:57369 "EHLO mail.tglx.de"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932274AbXGYATg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jul 2007 20:19:36 -0400
In-Reply-To: <20070724200431.GA22190@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-07-24 at 22:04 +0200, Ingo Molnar wrote:
> Marcin, could you try the patch below too? [without having any other 
> patch applied.] It basically turns the critical section into an irqs-off 
> critical section and thus checks whether your problem is related to that 
> particular area of code.
> 

I read back on this thread and I think the problem is somewhere else:

delayed disable relies on the ability to re-trigger the interrupt in the
case that a real interrupt happens after the software disable was set.
In this case we actually disable the interrupt on the hardware level
_after_ it occurred.

On enable_irq, we need to re-trigger the interrupt. On i386 this relies
on a hardware resend mechanism (send_IPI_self()). 

Actually we only need the resend for edge type interrupts. Level type
interrupts come back once enable_irq() re-enables the interrupt line.

I assume that the interrupt in question is level triggered because it is
shared and above the legacy irqs 0-15:

	17:         12   IO-APIC-fasteoi   eth1, eth0

Looking into the IO_APIC code, the resend via send_IPI_self() happens
unconditionally. So the resend is done for level and edge interrupts.
This makes the problem more mysterious.

The code in question lib8390.c does

	disable_irq();
	fiddle_with_the_network_card_hardware()
	enable_irq();

The fiddle_with_the_network_card_hardware() might cause interrupts,
which are cleared in the same code path again,

Marcin found that when he disables the irq line on the hardware level
(removing the delayed disable) the card is kept alive.

So the difference is that we can get a resend on enable_irq, when an
interrupt happens during the time, where we are in the disabled region.

No idea how this affects the network card, as the code there must be
able to handle interrupts, which are not originated from the card due to
interrupt sharing.

Marcin, can you please try the patch below ? It's just a debugging aid
to gather some more data about that problem.

If the patch fixes the problem, then we should try to disable the resend
mechanism for not edge type irq lines on the irq_chip level (i.e. the
IOAPIC code)

Thanks,

	tglx

--- linux-2.6.orig/kernel/irq/resend.c
+++ linux-2.6/kernel/irq/resend.c
@@ -62,6 +62,15 @@ void check_irq_resend(struct irq_desc *desc, unsigned int irq)
 	 */
 	desc->chip->enable(irq);
 
+	/*
+	 * Temporary hack to figure out more about the problem, which
+	 * is causing the ancient network cards to die.
+	 */
+	if (desc->handle_irq != handle_edge_irq) {
+		printk(KERN_DEBUG "Skip resend for irq %u\n", irq);
+		return;
+	}
+
 	if ((status & (IRQ_PENDING | IRQ_REPLAY)) == IRQ_PENDING) {
 		desc->status = (status & ~IRQ_PENDING) | IRQ_REPLAY;
 


