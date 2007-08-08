From: Jarek Poplawski <jarkao2@o2.pl>
Subject: [patch] genirq: temporary fix for level-triggered IRQ resend
Date: Wed, 8 Aug 2007 13:00:37 +0200
Message-ID: <20070808110037.GB2426@ff.dom.local>
References: <1185322771.4175.102.camel@chaos> <4bacf17f0707260016x14fc1c92s628ae64353663833@mail.gmail.com> <20070726081326.GA3197@ff.dom.local> <1185437431.3227.21.camel@chaos> <20070726083120.GA26910@elte.hu> <20070726085523.GA3423@ff.dom.local> <20070726091254.GA8063@elte.hu> <4bacf17f0707300029g5116e70bq4808059dc8b069f1@mail.gmail.com> <20070731155843.GA7033@elte.hu> <20070731160008.GA7776@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Jean-Baptiste Vignaud <vignaud@xandmail.fr>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	shemminger <shemminger@linux-foundation.org>,
	linux-net <linux-net@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>, marcin.slusarz@gmail.com
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx12.go2.pl ([193.17.41.142]:60977 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750986AbXHHLAG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Aug 2007 07:00:06 -0400
Content-Disposition: inline
In-Reply-To: <20070731160008.GA7776@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I see there is a bit of complaining on this original resend temporary
patch. But, since it seems to do a good job for some people, here is
my proposal to limit the 'range of fire' a little bit.

Marcin and Jean-Baptiste: try to test this with 2.6.23-rc2, please.
(Unless Ingo or Thomas have other plans with this problem?)

Thanks,
Jarek P.

-------->

Subject: [patch] genirq: temporary fix for level-triggered IRQ resend


Marcin Slusarz reported a ne2k-pci "hung network interface" regression.

delayed disable relies on the ability to re-trigger the interrupt in the
case that a real interrupt happens after the software disable was set.
In this case we actually disable the interrupt on the hardware level
_after_ it occurred.

On enable_irq, we need to re-trigger the interrupt. On i386 this relies
on a hardware resend mechanism (send_IPI_self()).

Actually we only need the resend for edge type interrupts. Level type
interrupts come back once enable_irq() re-enables the interrupt line.

Marcin found that when he disables the irq line on the hardware level
(removing the delayed disable) the card is kept alive.

Thomas Gleixner prepared a testing patch which proved to fix hung ups
after limiting irqs resending to edge type only. Then Ingo Molnar's
version of this patch was applied to 2.6.23-rc2 kernel as a temporary
solution. Since, the problem is still diagnosed, but seems to affect
mainly X86_64 arch, here is a modified, but still temporary, version of
this solution, which should limit the range of warnings and changes in
interrupt handling to minimum.


Signed-off-by: Jarek Poplawski <jarkao2@o2.pl>
Cc: Marcin Slusarz <marcin.slusarz@gmail.com>
Cc: Jean-Baptiste Vignaud <vignaud@xandmail.fr>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@elte.hu>

---

diff -Nurp 2.6.23-rc2-/kernel/irq/resend.c 2.6.23-rc2/kernel/irq/resend.c
--- 2.6.23-rc2-/kernel/irq/resend.c	2007-08-08 11:48:15.000000000 +0200
+++ 2.6.23-rc2/kernel/irq/resend.c	2007-08-08 11:58:42.000000000 +0200
@@ -62,18 +62,19 @@ void check_irq_resend(struct irq_desc *d
 	 */
 	desc->chip->enable(irq);
 
+	if ((status & (IRQ_PENDING | IRQ_REPLAY)) == IRQ_PENDING) {
+		desc->status = (status & ~IRQ_PENDING) | IRQ_REPLAY;
+
+#ifdef CONFIG_X86_64
 	/*
 	 * Temporary hack to figure out more about the problem, which
 	 * is causing the ancient network cards to die.
 	 */
-	if (desc->handle_irq != handle_edge_irq) {
-		WARN_ON_ONCE(1);
-		return;
-	}
-
-	if ((status & (IRQ_PENDING | IRQ_REPLAY)) == IRQ_PENDING) {
-		desc->status = (status & ~IRQ_PENDING) | IRQ_REPLAY;
-
+		if (desc->handle_irq == handle_fasteoi_irq) {
+			WARN_ON_ONCE(1);
+			return;
+		}
+#endif
 		if (!desc->chip || !desc->chip->retrigger ||
 					!desc->chip->retrigger(irq)) {
 #ifdef CONFIG_HARDIRQS_SW_RESEND
