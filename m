From: Ingo Molnar <mingo@elte.hu>
Subject: [patch] genirq: temporary fix for level-triggered IRQ resend
Date: Tue, 31 Jul 2007 17:58:43 +0200
Message-ID: <20070731155843.GA7033@elte.hu>
References: <alpine.LFD.0.999.0707241228291.3607@woody.linux-foundation.org> <20070724200431.GA22190@elte.hu> <1185322771.4175.102.camel@chaos> <4bacf17f0707260016x14fc1c92s628ae64353663833@mail.gmail.com> <20070726081326.GA3197@ff.dom.local> <1185437431.3227.21.camel@chaos> <20070726083120.GA26910@elte.hu> <20070726085523.GA3423@ff.dom.local> <20070726091254.GA8063@elte.hu> <4bacf17f0707300029g5116e70bq4808059dc8b069f1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jarek Poplawski <jarkao2@o2.pl>,
	Thomas Gleixner <tglx@linutronix.de>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Jean-Baptiste Vignaud <vignaud@xandmail.fr>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	shemminger <shemminger@linux-foundation.org>,
	linux-net <linux-net@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>, marcin.slusarz@gmail.com
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-net-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4bacf17f0707300029g5116e70bq4808059dc8b069f1@mail.gmail.com>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Linus,

with -rc2 approaching i think we should apply the minimal fix below to 
get Marcin's ne2k-pci networking back in working order. The 
WARN_ON_ONCE() will not prevent the system from working and it will be a 
reminder.

a better workaround would be to inhibit the resent vector via the 
IO-APIC irqchip - but i'd still like to have the patch below because the 
ne2k driver _should_ be able to survive the spurious irq that happens. 
(even on Marcin's system that ne2k-pci irq line is shared with another 
networking card, so an irq could happen at any moment - it's just that 
with the delayed-disable logic it happens _all the time_.)

	Ingo

----------------------->
From: Thomas Gleixner <tglx@linutronix.de>
Subject: genirq: temporary fix for level-triggered IRQ resend

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

Signed-off-by: Ingo Molnar <mingo@elte.hu>
---
 kernel/irq/resend.c |    9 +++++++++
 1 file changed, 9 insertions(+)

Index: linux/kernel/irq/resend.c
===================================================================
--- linux.orig/kernel/irq/resend.c
+++ linux/kernel/irq/resend.c
@@ -62,6 +62,15 @@ void check_irq_resend(struct irq_desc *d
 	 */
 	desc->chip->enable(irq);
 
+	/*
+	 * Temporary hack to figure out more about the problem, which
+	 * is causing the ancient network cards to die.
+	 */
+	if (desc->handle_irq != handle_edge_irq) {
+		WARN_ON_ONCE(1);
+		return;
+	}
+
 	if ((status & (IRQ_PENDING | IRQ_REPLAY)) == IRQ_PENDING) {
 		desc->status = (status & ~IRQ_PENDING) | IRQ_REPLAY;
 

