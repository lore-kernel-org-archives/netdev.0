From: Ingo Molnar <mingo@elte.hu>
Subject: Re: 2.6.20->2.6.21 - networking dies after random time
Date: Tue, 24 Jul 2007 11:42:02 +0200
Message-ID: <20070724094202.GA11610@elte.hu>
References: <JKE37W$0126317E099DF36884CC046B6F8A7AA9@xandmail.com> <20070629150759.GC2771@ff.dom.local> <4bacf17f0707222244p664e7a6ap850b3357a57d73c@mail.gmail.com> <20070724080534.GC18740@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jarek Poplawski <jarkao2@o2.pl>,
	Jean-Baptiste Vignaud <vignaud@xandmail.fr>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	shemminger <shemminger@linux-foundation.org>,
	linux-net <linux-net@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
To: Marcin ??lusarz <marcin.slusarz@gmail.com>
Return-path: <linux-net-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20070724080534.GC18740@elte.hu>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Ingo Molnar <mingo@elte.hu> wrote:

> thanks for tracking it down! Could you try the patch below (ontop an 
> otherwise unmodified kernel)? This tests the theory whether the 
> problem is related to the disable_irq_nosync() call in the ne2k 
> driver's xmit path. Does this solve the hangs too?

please try the patch below instead.

	Ingo

Index: linux/kernel/irq/chip.c
===================================================================
--- linux.orig/kernel/irq/chip.c
+++ linux/kernel/irq/chip.c
@@ -231,7 +231,7 @@ static void default_enable(unsigned int 
 /*
  * default disable function
  */
-static void default_disable(unsigned int irq)
+void default_disable(unsigned int irq)
 {
 }
 
Index: linux/kernel/irq/internals.h
===================================================================
--- linux.orig/kernel/irq/internals.h
+++ linux/kernel/irq/internals.h
@@ -10,6 +10,8 @@ extern void irq_chip_set_defaults(struct
 /* Set default handler: */
 extern void compat_irq_chip_set_default_handler(struct irq_desc *desc);
 
+extern void default_disable(unsigned int irq);
+
 #ifdef CONFIG_PROC_FS
 extern void register_irq_proc(unsigned int irq);
 extern void register_handler_proc(unsigned int irq, struct irqaction *action);
Index: linux/kernel/irq/manage.c
===================================================================
--- linux.orig/kernel/irq/manage.c
+++ linux/kernel/irq/manage.c
@@ -102,7 +102,19 @@ void disable_irq_nosync(unsigned int irq
 	spin_lock_irqsave(&desc->lock, flags);
 	if (!desc->depth++) {
 		desc->status |= IRQ_DISABLED;
-		desc->chip->disable(irq);
+		/*
+		 * the _nosync variant of irq-disable suggests that the
+		 * caller is not worried about concurrency but about the
+		 * ordering of the irq flow itself. (such as hardware
+		 * getting confused about certain, normally valid irq
+		 * handling sequences.) So if the default disable handler
+		 * is in place then try the more conservative masking
+		 * instead:
+		 */
+		if (desc->chip->disable == default_disable && desc->chip->mask)
+			desc->chip->mask(irq);
+		else
+			desc->chip->disable(irq);
 	}
 	spin_unlock_irqrestore(&desc->lock, flags);
 }
