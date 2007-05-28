From: tsbogend@alpha.franken.de (Thomas Bogendoerfer)
Subject: Re: [PCNET32] Lock solid with netconsole
Date: Mon, 28 May 2007 22:51:44 +0200
Message-ID: <20070528205144.GB26309@alpha.franken.de>
References: <JIRC73$62E39331D73FCF49870995034400C560@laposte.net> <20070528183148.GA10009@csclub.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Emmanuel Fust? <emmanuel.fuste@laposte.net>,
	romieu <romieu@fr.zoreil.com>, pcnet32 <pcnet32@verizon.net>,
	netdev <netdev@vger.kernel.org>
To: Lennart Sorensen <lsorense@csclub.uwaterloo.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elvis.franken.de ([193.175.24.41]:40990 "EHLO elvis.franken.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752206AbXE1Uws (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 May 2007 16:52:48 -0400
Content-Disposition: inline
In-Reply-To: <20070528183148.GA10009@csclub.uwaterloo.ca>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 28, 2007 at 02:31:48PM -0400, Lennart Sorensen wrote:
> On Mon, May 28, 2007 at 05:25:51PM +0200, Emmanuel Fust? wrote:
> > > Any difference if you disable the debug messages in the pcnet32
> > > driver and you apply the patch below ?
> > > 
> > > diff --git a/drivers/net/pcnet32.c b/drivers/net/pcnet32.c
> > > index 9c171a7..be4513f 100644
> > > --- a/drivers/net/pcnet32.c
> > > +++ b/drivers/net/pcnet32.c
> > > @@ -2556,11 +2556,12 @@ pcnet32_interrupt(int irq, void *dev_id)
> > >  	unsigned long ioaddr;
> > >  	u16 csr0;
> > >  	int boguscnt = max_interrupt_work;
> > > +	unsigned long flags;
> > >  
> > >  	ioaddr = dev->base_addr;
> > >  	lp = netdev_priv(dev);
> > >  
> > > -	spin_lock(&lp->lock);
> > > +	spin_lock_irqsave(&lp->lock, flags);
> > >  
> > >  	csr0 = lp->a.read_csr(ioaddr, CSR0);
> > >  	while ((csr0 & 0x8f00) && --boguscnt >= 0) {
> > > @@ -2632,7 +2633,7 @@ pcnet32_interrupt(int irq, void *dev_id)
> > >  		printk(KERN_DEBUG "%s: exiting interrupt, csr0=%#4.4x.\n",
> > >  		       dev->name, lp->a.read_csr(ioaddr, CSR0));
> > >  
> > > -	spin_unlock(&lp->lock);
> > > +	spin_unlock_irqrestore(&lp->lock, flags);
> > >  
> > >  	return IRQ_HANDLED;
> > >  }
> > > 
> > Hi,
> > Tested under very high console activity and it no longer freeze.
> 
> Hmm, I have been seeing lockups too and asked about doing something
> almost exactly the same as this recently, but was told that it shouldn't
> need irqs disabled at this point.  Well if it makes netconsole more

for normal interrupt delivery it doesn't matter, because there shouldn't
be any more interrupts coming in at that point. But netconsole uses
pcnet32_interrupt for polling the chip. So if during service of a
a real interrupt a polled pcnet32_interrupt call is done, the machine
will deadlock.

Using spin_lock_irqsave() is probably the only race free solution,
when using NET_POLL.

Thomas.

-- 
Crap can work. Given enough thrust pigs will fly, but it's not necessary a
good idea.                                                [ RFC1925, 2.3 ]
