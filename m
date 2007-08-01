From: Ingo Molnar <mingo@elte.hu>
Subject: Re: 2.6.20->2.6.21 - networking dies after random time
Date: Wed, 1 Aug 2007 09:27:41 +0200
Message-ID: <20070801072741.GA21551@elte.hu>
References: <1185322771.4175.102.camel@chaos> <4bacf17f0707260016x14fc1c92s628ae64353663833@mail.gmail.com> <20070726081326.GA3197@ff.dom.local> <1185437431.3227.21.camel@chaos> <20070726083120.GA26910@elte.hu> <20070726085523.GA3423@ff.dom.local> <20070726091254.GA8063@elte.hu> <4bacf17f0707300029g5116e70bq4808059dc8b069f1@mail.gmail.com> <20070730084925.GA12695@elte.hu> <4bacf17f0708010024r3abc196dv4d6924e314536b17@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jarek Poplawski <jarkao2@o2.pl>,
	Thomas Gleixner <tglx@linutronix.de>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Jean-Baptiste Vignaud <vignaud@xandmail.fr>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	shemminger <shemminger@linux-foundation.org>,
	linux-net <linux-net@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>
To: Marcin =?utf-8?Q?=C5=9Alusarz?= <marcin.slusarz@gmail.com>
Return-path: <linux-net-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4bacf17f0708010024r3abc196dv4d6924e314536b17@mail.gmail.com>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Marcin =C5=9Alusarz <marcin.slusarz@gmail.com> wrote:

> >         ei_outb_p(ENISR_ALL, e8390_base + EN0_IMR);
> > +       /* force POST: */
> > +       ei_inb_p(e8390_base + EN0_IMR);
> >
> >         spin_unlock(&ei_local->page_lock);
> >         enable_irq_lockdep_irqrestore(dev->irq, &flags);
> >
>=20
> Bad news. It doesn't fix the problem.

ok, it wasnt supposed to be _that_ easy i guess :-) Can you please=20
(re-)confirm that the workaround below indeed fixes the hung card=20
problem? (after producing a single WARN_ON message into the syslog)

also, does removing the ne2k-pci module and reinserting it again solve=20
the problem too, or is your network card stuck forever once it got into=
=20
that state?

	Ingo

----------------------->
=46rom: Thomas Gleixner <tglx@linutronix.de>
Subject: genirq: temporary fix for level-triggered IRQ resend

delayed disable relies on the ability to re-trigger the interrupt in th=
e
case that a real interrupt happens after the software disable was set.
In this case we actually disable the interrupt on the hardware level
_after_ it occurred.

On enable_irq, we need to re-trigger the interrupt. On i386 this relies
on a hardware resend mechanism (send_IPI_self()).=20

Actually we only need the resend for edge type interrupts. Level type
interrupts come back once enable_irq() re-enables the interrupt line.

I assume that the interrupt in question is level triggered because it i=
s
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
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux.orig/kernel/irq/resend.c
+++ linux/kernel/irq/resend.c
@@ -62,6 +62,15 @@ void check_irq_resend(struct irq_desc *d
 	 */
 	desc->chip->enable(irq);
=20
+	/*
+	 * Temporary hack to figure out more about the problem, which
+	 * is causing the ancient network cards to die.
+	 */
+	if (desc->handle_irq !=3D handle_edge_irq) {
+		WARN_ON_ONCE(1);
+		return;
+	}
+
 	if ((status & (IRQ_PENDING | IRQ_REPLAY)) =3D=3D IRQ_PENDING) {
 		desc->status =3D (status & ~IRQ_PENDING) | IRQ_REPLAY;
=20

