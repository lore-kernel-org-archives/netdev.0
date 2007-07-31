From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [patch] genirq: temporary fix for level-triggered IRQ resend
Date: Tue, 31 Jul 2007 18:00:08 +0200
Message-ID: <20070731160008.GA7776@elte.hu>
References: <20070724200431.GA22190@elte.hu> <1185322771.4175.102.camel@chaos> <4bacf17f0707260016x14fc1c92s628ae64353663833@mail.gmail.com> <20070726081326.GA3197@ff.dom.local> <1185437431.3227.21.camel@chaos> <20070726083120.GA26910@elte.hu> <20070726085523.GA3423@ff.dom.local> <20070726091254.GA8063@elte.hu> <4bacf17f0707300029g5116e70bq4808059dc8b069f1@mail.gmail.com> <20070731155843.GA7033@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jarek Poplawski <jarkao2@o2.pl>,
	Thomas Gleixner <tglx@linutronix.de>,
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
In-Reply-To: <20070731155843.GA7033@elte.hu>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Ingo Molnar <mingo@elte.hu> wrote:

> Linus,
> 
> with -rc2 approaching i think we should apply the minimal fix below to 
> get Marcin's ne2k-pci networking back in working order. The 
> WARN_ON_ONCE() will not prevent the system from working and it will be 
> a reminder.

there's one more test-patch that Marcin has not tested yet (see below) - 
perhaps a POST artifact in ne2k could explain this bug.

	Ingo

------------------------->

* Alan Cox <alan@lxorguk.ukuu.org.uk> wrote:

> Ok the logic behind the 8390 is very simple:

thanks for the explanation Alan! A few comments and a question:

> Things to know
> 	- IRQ delivery is asynchronous to the PCI bus
> 	- Blocking the local CPU IRQ via spin locks was too slow
> 	- The chip has register windows needing locking work
> 
> So the path was once (I say once as people appear to have changed it 
> in the mean time and it now looks rather bogus if the changes to use 
> disable_irq_nosync_irqsave are disabling the local IRQ)
> 
> 
> 	Take the page lock
> 	Mask the IRQ on chip
> 	Disable the IRQ (but not mask locally- someone seems to have
> 		broken this with the lock validator stuff)
> 		[This must be _nosync as the page lock may otherwise
> 			deadlock us]

( side-note: you can ignore the lock validator stuff here, the validator
  changes are supposed to a NOP on the !lockdep case. Local irqs will
  only be disabled if the validator is running. This could cause dropped
  serial irqs on very old boxes but i doubt anyone will want to run the
  validator on those. )

> 	Drop the page lock and turn IRQs back on
> 	
> 	At this point an existing IRQ may still be running but we can't
> 	get a new one
> 
> 	Take the lock (so we know the IRQ has terminated) but don't mask
> the IRQs on the processor
> 	Set irqlock [for debug]
> 
> 	Transmit (slow as ****)
> 
> 	re-enable the IRQ
> 
> 
> We have to use disable_irq because otherwise you will get delayed 
> interrupts on the APIC bus deadlocking the transmit path.
> 
> Quite hairy but the chip simply wasn't designed for SMP and you can't 
> even ACK an interrupt without risking corrupting other parallel 
> activities on the chip.

So the whole locking is to be able to keep irqs enabled for a long time, 
without risking entry of the same IRQ handler on this same CPU, correct?

Marcin's test results suggest that if an IRQ is resent right at the 
enable_irq() point [be that via the hw irq-resend mechanism or the sw 
irq-resend mechanism], the hang happens.

In the previous 2.6.20 logic we'd not normally generate an IRQ at that 
point (because we masked the irq and the card itself deasserts the line 
so any level-triggered irq is now moot).

Once Thomas hacked off this resend mechanism for level-triggered irqs, 
Marcin saw the hangs go away.

So it seems to me that maybe the driver could be surprised via these 
spurious interrupts that happen right after the irq_enable(). Does the 
patch below make any sense in your opinion?

	Ingo

Index: linux/drivers/net/lib8390.c
===================================================================
--- linux.orig/drivers/net/lib8390.c
+++ linux/drivers/net/lib8390.c
@@ -375,6 +375,8 @@ static int ei_start_xmit(struct sk_buff 
 	/* Turn 8390 interrupts back on. */
 	ei_local->irqlock = 0;
 	ei_outb_p(ENISR_ALL, e8390_base + EN0_IMR);
+	/* force POST: */
+	ei_inb_p(e8390_base + EN0_IMR);
 
 	spin_unlock(&ei_local->page_lock);
 	enable_irq_lockdep_irqrestore(dev->irq, &flags);
