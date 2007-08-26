From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] Prefix each line of multiline printk(KERN_<level>
	"foo\nbar") with KERN_<level>
Date: Sun, 26 Aug 2007 10:36:30 -0700
Message-ID: <1188149790.18004.44.camel@localhost>
References: <1187999098.32738.179.camel@localhost>
	 <Pine.LNX.4.64.0708261028120.31149@anakin>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755088AbXHZRhZ@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0708261028120.31149@anakin>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2007-08-26 at 10:30 +0200, Geert Uytterhoeven wrote: 
> On Fri, 24 Aug 2007, Joe Perches wrote:
> > Corrected printk calls with multiple output lines which
> > did not correctly preface each line with KERN_<level>
> > Fixed uses of some single lines with too many KERN_<level>
> > --- a/arch/arm/kernel/ecard.c
> > +++ b/arch/arm/kernel/ecard.c
> > @@ -547,7 +547,8 @@ static void ecard_check_lockup(struct irq_desc *desc)
> >  	if (last == jiffies) {
> >  		lockup += 1;
> >  		if (lockup > 1000000) {
> > -			printk(KERN_ERR "\nInterrupt lockup detected - "
> > +			printk(KERN_ERR "\n"
> > +			       KERN_ERR "Interrupt lockup detected - "
> >  			       "disabling all expansion card interrupts\n");
> >  
> >  			desc->chip->mask(IRQ_EXPANSIONCARD);
> 
> What's the purpose of having lines printed with e.g. `KERN_ERR "\n"' only?
> Shouldn't these just be removed?

My preference too.  There could be a separate effort for that.

egrep -r --include=*.[ch] "KERN_[A-Z]*[[:space:]]+\"\\\n" * | wc -l
104

These are either errors or a desire to prettify logs with
vertical whitespace.  I think vertical whitespace doesn't help.

> Usually lines starting with `\n' are continuations, but given some other
> module may call printk() in between, there's no guarantee continuations
> appear on the same line.

printk KERN_<level>s were sometimes bolted on after code was written.

etherfoo_card_init()
{
	printk(KERN_INFO "etherfoo card");
	slot = foo_getslot();
	if (slot < 0) {
		printk("\n" KERN_ERR "etherfoo card slot not found\n");
		return -1;
	}
	printk(" found in slot %d", slot);
	irq = foo_getirq();
	if (irq < 0) {
		printk("\n" KERN_ERR "etherfoo card irq not found\n");
		return -1;
	}
	printk(" with irq %d\n", irq);
}

Sometimes, a KERN_ERR is misplaced, or the "\n" is missing.

	printk(KERN_ERR "\n" msg);
or
	printk(KERN_ERR msg);

To me, the card announcement printk should move to the
end of the card_init routine and just be a single printk.

etherfoo_card_init()
{
	slot = foo_getslot();
	if (slot < 0) {
		printk(KERN_ERR "etherfoo card slot not found\n");
		return -1;
	}
	irq = foo_getirq();
	if (irq < 0) {
		printk(KERN_ERR "etherfoo card irq not found\n");
		return -1;
	}
	printk(KERN_INFO "etherfoo card in slot %d with irq %d\n",
	       slot, irq);
}
