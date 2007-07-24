From: Ingo Molnar <mingo@elte.hu>
Subject: Re: 2.6.20->2.6.21 - networking dies after random time
Date: Tue, 24 Jul 2007 22:04:31 +0200
Message-ID: <20070724200431.GA22190@elte.hu>
References: <JKE37W$0126317E099DF36884CC046B6F8A7AA9@xandmail.com> <20070629150759.GC2771@ff.dom.local> <4bacf17f0707222244p664e7a6ap850b3357a57d73c@mail.gmail.com> <20070724080534.GC18740@elte.hu> <20070724094202.GA11610@elte.hu> <alpine.LFD.0.999.0707241228291.3607@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Marcin ??lusarz <marcin.slusarz@gmail.com>,
	Jarek Poplawski <jarkao2@o2.pl>,
	Jean-Baptiste Vignaud <vignaud@xandmail.fr>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	shemminger <shemminger@linux-foundation.org>,
	linux-net <linux-net@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Andrew Morton <akpm@linux-foundation.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932133AbXGXUFl@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.0.999.0707241228291.3607@woody.linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Linus Torvalds <torvalds@linux-foundation.org> wrote:

> On Tue, 24 Jul 2007, Ingo Molnar wrote:
> > 
> > please try the patch below instead.
> 
> I'm hoping this is just a "let's see if the behavior changes" patch, 
> not something that you think should be applied if it fixes something?
> 
> This patch looks like it is trying to paper over (rather than fix) 
> some possible bug in the "->disable" logic. Makes sense as a "let's 
> see if it's that" kind of thing, but not as a "let's fix it".
> 
> Or am I missing something?

yeah - it's a totaly bad and unacceptable hack (i realized how bad it 
was when i wrote up that comment section ...), i just wanted to see 
which portion of ne2k/lib8390.c is sensitive to the fact whether an irq 
line is masked or not. The patch has no SOB line either.

the current best fix forward is to undo my original change, unless we 
find a better fix for this problem. (Note that the other patches posted 
in this thread are broken too: they only mask the irq but dont reliably 
unmask it.)

here's the current method of handling irqs for Marcin's card:

17:         12   IO-APIC-fasteoi   eth1, eth0

and fasteoi is a really simple sequence: no masking/unmasking by the 
flow handler itself but a NOP at entry and an APIC-EOI at the end. The 
disable/enable irq thing should thus have minimal effect if done within 
an irq handler.

now ne2k does something uncommon: for xmit (which is normally done 
outside of irq handlers) it will disable_irq_nosync()/enable_irq() the 
interrupt. It does it to exclude the handler from _that_ CPU, but due to 
the _nosync it does not exclude it from any other CPUs. So that's a bit 
weird already.

just in case, i've just re-checked all the genirq bits that change 
IRQ_DISABLED (that bit accidentally clear would be the only way to truly 
allow an IRQ handler to interrupt the disable_irq_nosync() critical 
section on that CPU) - but i can see no way for that to happen: we 
unconditionally detect and report unbalanced and underflowing 
irq_desc->depth, and the only other place (besides enable_irq()) that 
clears IRQ_DISABLED is __set_irq_handler(), and on x86 that is only used 
during bootup.

Marcin, could you try the patch below too? [without having any other 
patch applied.] It basically turns the critical section into an irqs-off 
critical section and thus checks whether your problem is related to that 
particular area of code.

	Ingo

Index: linux/drivers/net/lib8390.c
===================================================================
--- linux.orig/drivers/net/lib8390.c
+++ linux/drivers/net/lib8390.c
@@ -297,9 +297,7 @@ static int ei_start_xmit(struct sk_buff 
 	 *	Slow phase with lock held.
 	 */
 
-	disable_irq_nosync_lockdep_irqsave(dev->irq, &flags);
-
-	spin_lock(&ei_local->page_lock);
+	spin_lock_irqsave(&ei_local->page_lock, flags);
 
 	ei_local->irqlock = 1;
 
@@ -376,8 +374,7 @@ static int ei_start_xmit(struct sk_buff 
 	ei_local->irqlock = 0;
 	ei_outb_p(ENISR_ALL, e8390_base + EN0_IMR);
 
-	spin_unlock(&ei_local->page_lock);
-	enable_irq_lockdep_irqrestore(dev->irq, &flags);
+	spin_unlock_irqrestore(&ei_local->page_lock, flags);
 
 	dev_kfree_skb (skb);
 	ei_local->stat.tx_bytes += send_length;
