From: Jarek Poplawski <jarkao2@o2.pl>
Subject: [patch (testing)] Re: 2.6.20->2.6.21 - networking dies after random time
Date: Thu, 9 Aug 2007 11:19:19 +0200
Message-ID: <20070809091919.GB2423@ff.dom.local>
References: <20070731132037.GC1046@ff.dom.local> <4bacf17f0708060000n5a00bb77i74adc3b4b28ac42b@mail.gmail.com> <20070806070300.GA4509@elte.hu> <4bacf17f0708070046o14403089v8376a4544f72fec3@mail.gmail.com> <20070807082321.GB2120@ff.dom.local> <4bacf17f0708070237w19d184b3p7f74b53612edb9a6@mail.gmail.com> <20070807095246.GB3223@ff.dom.local> <20070807121339.GA3946@ff.dom.local> <4bacf17f0708080409t116b5c84ye60dff7da51d0fdf@mail.gmail.com> <20070808114243.GC2426@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Jean-Baptiste Vignaud <vignaud@xandmail.fr>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	shemminger <shemminger@linux-foundation.org>,
	linux-net <linux-net@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>
To: Marcin =?iso-8859-2?Q?=A6lusarz?= <marcin.slusarz@gmail.com>
Return-path: <linux-net-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20070808114243.GC2426@ff.dom.local>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 08, 2007 at 01:42:43PM +0200, Jarek Poplawski wrote:
> Read below please:
>=20
> On Wed, Aug 08, 2007 at 01:09:36PM +0200, Marcin =A6lusarz wrote:
> > 2007/8/7, Jarek Poplawski <jarkao2@o2.pl>:
> > > So, the let's try this idea yet: modified Ingo's "x86: activate
> > > HARDIRQS_SW_RESEND" patch.
> > > (Don't forget about make oldconfig before make.)
> > > For testing only.
=2E..
> > > diff -Nurp 2.6.22.1-/arch/i386/Kconfig 2.6.22.1/arch/i386/Kconfig
> > > --- 2.6.22.1-/arch/i386/Kconfig 2007-07-09 01:32:17.000000000 +02=
00
> > > +++ 2.6.22.1/arch/i386/Kconfig  2007-08-07 13:13:03.000000000 +02=
00
> > > @@ -1252,6 +1252,10 @@ config GENERIC_PENDING_IRQ
> > >         depends on GENERIC_HARDIRQS && SMP
> > >         default y
> > >
> > > +config HARDIRQS_SW_RESEND
=2E..
> > Works fine with:
>=20
> Very nice! It would be about time this kernel should start behave...
>=20
> > WARNING: at kernel/irq/resend.c:79 check_irq_resend()
> >=20
> > Call Trace:
=2E..
> So, it looks like x86_64 io_apic's IPI code was unused too long...
> I hope it's a piece of cake for Ingo now...

So, we know now it's almost definitely something about lapic and IPIs
but, maybe it's not this code to blame...

Here is one more patch to check the possibility it's about the way
the resend edge type irqs are handled by level type handlers:
so, let's check if acking isn't too late...

Marcin and Jean-Baptiste: I would be very glad, as usual! And no need
to hurry; I think we know enough to fix this for you, but maybe this
test could explain if there are errors in lapics or only bad handling.

Many thanks,
Jarek P.=20

PS: this patch is very experimental, and only intended for testing.
It should be applied to clean 2.6.23-rc1 or a bit older (eg. 2.6.22)
(so 2.6.23-rc2 or any patches from this thread shouldn't be around)=20

---

diff -Nurp 2.6.23-rc1-/kernel/irq/chip.c 2.6.23-rc1/kernel/irq/chip.c
--- 2.6.23-rc1-/kernel/irq/chip.c	2007-07-09 01:32:17.000000000 +0200
+++ 2.6.23-rc1/kernel/irq/chip.c	2007-08-08 20:49:07.000000000 +0200
@@ -389,12 +389,19 @@ handle_fasteoi_irq(unsigned int irq, str
 	unsigned int cpu =3D smp_processor_id();
 	struct irqaction *action;
 	irqreturn_t action_ret;
+	int edge =3D 0;
=20
 	spin_lock(&desc->lock);
=20
 	if (unlikely(desc->status & IRQ_INPROGRESS))
 		goto out;
=20
+	if ((desc->status & (IRQ_PENDING | IRQ_REPLAY)) =3D=3D
+							IRQ_REPLAY) {
+		desc->chip->ack(irq);
+		edge =3D 1;
+	}
+
 	desc->status &=3D ~(IRQ_REPLAY | IRQ_WAITING);
 	kstat_cpu(cpu).irqs[irq]++;
=20
@@ -421,7 +428,8 @@ handle_fasteoi_irq(unsigned int irq, str
 	spin_lock(&desc->lock);
 	desc->status &=3D ~IRQ_INPROGRESS;
 out:
-	desc->chip->eoi(irq);
+	if (!edge)
+		desc->chip->eoi(irq);
=20
 	spin_unlock(&desc->lock);
 }
diff -Nurp 2.6.23-rc1-/kernel/irq/resend.c 2.6.23-rc1/kernel/irq/resend=
=2Ec
--- 2.6.23-rc1-/kernel/irq/resend.c	2007-07-09 01:32:17.000000000 +0200
+++ 2.6.23-rc1/kernel/irq/resend.c	2007-08-08 20:44:14.000000000 +0200
@@ -57,14 +57,10 @@ void check_irq_resend(struct irq_desc *d
 {
 	unsigned int status =3D desc->status;
=20
-	/*
-	 * Make sure the interrupt is enabled, before resending it:
-	 */
-	desc->chip->enable(irq);
-
 	if ((status & (IRQ_PENDING | IRQ_REPLAY)) =3D=3D IRQ_PENDING) {
 		desc->status =3D (status & ~IRQ_PENDING) | IRQ_REPLAY;
=20
+		WARN_ON_ONCE(1);
 		if (!desc->chip || !desc->chip->retrigger ||
 					!desc->chip->retrigger(irq)) {
 #ifdef CONFIG_HARDIRQS_SW_RESEND
@@ -74,4 +70,5 @@ void check_irq_resend(struct irq_desc *d
 #endif
 		}
 	}
+	desc->chip->enable(irq);
 }
