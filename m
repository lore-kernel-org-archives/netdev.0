From: Ingo Molnar <mingo@elte.hu>
Subject: Re: 2.6.20->2.6.21 - networking dies after random time
Date: Thu, 26 Jul 2007 11:12:54 +0200
Message-ID: <20070726091254.GA8063@elte.hu>
References: <20070724080534.GC18740@elte.hu> <20070724094202.GA11610@elte.hu> <alpine.LFD.0.999.0707241228291.3607@woody.linux-foundation.org> <20070724200431.GA22190@elte.hu> <1185322771.4175.102.camel@chaos> <4bacf17f0707260016x14fc1c92s628ae64353663833@mail.gmail.com> <20070726081326.GA3197@ff.dom.local> <1185437431.3227.21.camel@chaos> <20070726083120.GA26910@elte.hu> <20070726085523.GA3423@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Gleixner <tglx@linutronix.de>,
	Marcin ??lusarz <marcin.slusarz@gmail.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Jean-Baptiste Vignaud <vignaud@xandmail.fr>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	shemminger <shemminger@linux-foundation.org>,
	linux-net <linux-net@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:42880 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750969AbXGZJNG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jul 2007 05:13:06 -0400
Content-Disposition: inline
In-Reply-To: <20070726085523.GA3423@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Jarek Poplawski <jarkao2@o2.pl> wrote:

> On Thu, Jul 26, 2007 at 10:31:20AM +0200, Ingo Molnar wrote:
> ...
> > yeah. The patch below enables sw-resend on x86, to test the theory 
> > whether the APIC-driven hardware-vector-resend code has some problem.
> 
> I think Marcin is using x86_64 (Athlon 64) yet.

yeah - i meant to cover both arches but forgot about x86_64 - updated 
patch attached below.

	Ingo

----------------->
Subject: x86: activate HARDIRQS_SW_RESEND
From: Ingo Molnar <mingo@elte.hu>

activate the software-triggered IRQ-resend logic.

it appears some chipsets/cpus do not handle local-APIC driven IRQ
resends all that well, so always use the soft mechanism to trigger
the execution of pending interrupts.

Signed-off-by: Ingo Molnar <mingo@elte.hu>
---
 arch/i386/Kconfig   |    4 ++++
 arch/x86_64/Kconfig |    4 ++++
 kernel/irq/manage.c |    8 ++++++++
 3 files changed, 16 insertions(+)

Index: linux-rt-rebase.q/arch/i386/Kconfig
===================================================================
--- linux-rt-rebase.q.orig/arch/i386/Kconfig
+++ linux-rt-rebase.q/arch/i386/Kconfig
@@ -1284,6 +1284,10 @@ config GENERIC_PENDING_IRQ
 	depends on GENERIC_HARDIRQS && SMP
 	default y
 
+config HARDIRQS_SW_RESEND
+	bool
+	default y
+
 config X86_SMP
 	bool
 	depends on SMP && !X86_VOYAGER
Index: linux-rt-rebase.q/arch/x86_64/Kconfig
===================================================================
--- linux-rt-rebase.q.orig/arch/x86_64/Kconfig
+++ linux-rt-rebase.q/arch/x86_64/Kconfig
@@ -721,6 +721,10 @@ config GENERIC_PENDING_IRQ
 	depends on GENERIC_HARDIRQS && SMP
 	default y
 
+config HARDIRQS_SW_RESEND
+	bool
+	default y
+
 menu "Power management options"
 
 source kernel/power/Kconfig
Index: linux-rt-rebase.q/kernel/irq/manage.c
===================================================================
--- linux-rt-rebase.q.orig/kernel/irq/manage.c
+++ linux-rt-rebase.q/kernel/irq/manage.c
@@ -175,6 +175,14 @@ void enable_irq(unsigned int irq)
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
 
