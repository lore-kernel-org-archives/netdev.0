From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: 2.6.20->2.6.21 - networking dies after random time
Date: Tue, 7 Aug 2007 14:13:39 +0200
Message-ID: <20070807121339.GA3946@ff.dom.local>
References: <20070726085523.GA3423@ff.dom.local> <20070726091254.GA8063@elte.hu> <4bacf17f0707300029g5116e70bq4808059dc8b069f1@mail.gmail.com> <20070731132037.GC1046@ff.dom.local> <4bacf17f0708060000n5a00bb77i74adc3b4b28ac42b@mail.gmail.com> <20070806070300.GA4509@elte.hu> <4bacf17f0708070046o14403089v8376a4544f72fec3@mail.gmail.com> <20070807082321.GB2120@ff.dom.local> <4bacf17f0708070237w19d184b3p7f74b53612edb9a6@mail.gmail.com> <20070807095246.GB3223@ff.dom.local>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx12.go2.pl ([193.17.41.142]:48615 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756334AbXHGMNL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Aug 2007 08:13:11 -0400
Content-Disposition: inline
In-Reply-To: <20070807095246.GB3223@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 07, 2007 at 11:52:46AM +0200, Jarek Poplawski wrote:
> On Tue, Aug 07, 2007 at 11:37:01AM +0200, Marcin =A6lusarz wrote:
> > 2007/8/7, Jarek Poplawski <jarkao2@o2.pl>:
> > > On Tue, Aug 07, 2007 at 09:46:36AM +0200, Marcin =A6lusarz wrote:
> > > > Network card still locks up (tested on 2.6.22.1). I had to uplo=
ad more
> > > > data than usual (~350 MB vs ~1-100 MB) to trigger that bug but =
it
> > > > might be a coincidence...
> > >
> > > Thanks! It's a good news after all - it would be really strange w=
hy
> > > this place doesn't hit more people (it seems there is some safety
> > > elsewhere for this).
> > >
> > > BTW: I hope, this previous Thomas' patch with Ingo's warning to r=
esend.c
> > > (with a warning), had no problems with a similar load?
> > I always tested on 500-600 MB "dataset"
> >=20
> > > PS: Marcin, if you need a break in this testing let us know!
> > No, i don't need a break. I'll have more time in next weeks.
>=20
> Great! So, I'll try to send a patch with _SW_RESEND in a few hours,
> if Ingo doesn't prepare something for you.

So, the let's try this idea yet: modified Ingo's "x86: activate
HARDIRQS_SW_RESEND" patch.
(Don't forget about make oldconfig before make.)
=46or testing only.

Cheers,
Jarek P.

PS: alas there was not even time for "compile checking"...

---

diff -Nurp 2.6.22.1-/arch/i386/Kconfig 2.6.22.1/arch/i386/Kconfig
--- 2.6.22.1-/arch/i386/Kconfig	2007-07-09 01:32:17.000000000 +0200
+++ 2.6.22.1/arch/i386/Kconfig	2007-08-07 13:13:03.000000000 +0200
@@ -1252,6 +1252,10 @@ config GENERIC_PENDING_IRQ
 	depends on GENERIC_HARDIRQS && SMP
 	default y
=20
+config HARDIRQS_SW_RESEND
+	bool
+	default y
+
 config X86_SMP
 	bool
 	depends on SMP && !X86_VOYAGER
diff -Nurp 2.6.22.1-/arch/x86_64/Kconfig 2.6.22.1/arch/x86_64/Kconfig
--- 2.6.22.1-/arch/x86_64/Kconfig	2007-07-09 01:32:17.000000000 +0200
+++ 2.6.22.1/arch/x86_64/Kconfig	2007-08-07 13:13:03.000000000 +0200
@@ -690,6 +690,10 @@ config GENERIC_PENDING_IRQ
 	depends on GENERIC_HARDIRQS && SMP
 	default y
=20
+config HARDIRQS_SW_RESEND
+	bool
+	default y
+
 menu "Power management options"
=20
 source kernel/power/Kconfig
diff -Nurp 2.6.22.1-/kernel/irq/manage.c 2.6.22.1/kernel/irq/manage.c
--- 2.6.22.1-/kernel/irq/manage.c	2007-07-09 01:32:17.000000000 +0200
+++ 2.6.22.1/kernel/irq/manage.c	2007-08-07 13:13:03.000000000 +0200
@@ -169,6 +169,14 @@ void enable_irq(unsigned int irq)
 		desc->depth--;
 	}
 	spin_unlock_irqrestore(&desc->lock, flags);
+#ifdef CONFIG_HARDIRQS_SW_RESEND
+	/*
+	 * Do a bh disable/enable pair to trigger any pending
+	 * irq resend logic:
+	 */
+	local_bh_disable();
+	local_bh_enable();
+#endif
 }
 EXPORT_SYMBOL(enable_irq);
=20
diff -Nurp 2.6.22.1-/kernel/irq/resend.c 2.6.22.1/kernel/irq/resend.c
--- 2.6.22.1-/kernel/irq/resend.c	2007-07-09 01:32:17.000000000 +0200
+++ 2.6.22.1/kernel/irq/resend.c	2007-08-07 13:57:54.000000000 +0200
@@ -62,16 +62,24 @@ void check_irq_resend(struct irq_desc *d
 	 */
 	desc->chip->enable(irq);
=20
+	/*
+	 * Temporary hack to figure out more about the problem, which
+	 * is causing the ancient network cards to die.
+	 */
+
 	if ((status & (IRQ_PENDING | IRQ_REPLAY)) =3D=3D IRQ_PENDING) {
 		desc->status =3D (status & ~IRQ_PENDING) | IRQ_REPLAY;
=20
-		if (!desc->chip || !desc->chip->retrigger ||
-					!desc->chip->retrigger(irq)) {
+		if (desc->handle_irq =3D=3D handle_edge_irq) {
+			if (desc->chip->retrigger)
+				desc->chip->retrigger(irq);
+			return;
+		}
 #ifdef CONFIG_HARDIRQS_SW_RESEND
-			/* Set it pending and activate the softirq: */
-			set_bit(irq, irqs_resend);
-			tasklet_schedule(&resend_tasklet);
+		WARN_ON_ONCE(1);
+		/* Set it pending and activate the softirq: */
+		set_bit(irq, irqs_resend);
+		tasklet_schedule(&resend_tasklet);
 #endif
-		}
 	}
 }
