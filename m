From: Don Fry <brazilnut@us.ibm.com>
Subject: Re: [PATCH 8/9] pcnet32: NAPI implementation.
Date: Thu, 29 Jun 2006 16:41:04 -0700
Message-ID: <20060629234104.GA22583@us.ibm.com>
References: <20060629205551.GA22031@us.ibm.com> <20060629222438.GB8122@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tsbogend@alpha.franken.de, jgarzik@pobox.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:38073 "EHLO e1.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S933087AbWF2Xkv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2006 19:40:51 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k5TNenSh017905
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Thu, 29 Jun 2006 19:40:49 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k5TNenu2266338
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 29 Jun 2006 19:40:49 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k5TNemtA025497
	for <netdev@vger.kernel.org>; Thu, 29 Jun 2006 19:40:49 -0400
To: Francois Romieu <romieu@fr.zoreil.com>
Content-Disposition: inline
In-Reply-To: <20060629222438.GB8122@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 30, 2006 at 12:24:38AM +0200, Francois Romieu wrote:
> Nit below.
> 
> Don Fry <brazilnut@us.ibm.com> :
> [...]
> > --- linux-2.6.17-git13/drivers/net/purge.pcnet32.c	Thu Jun 29 13:28:24 2006
> > +++ linux-2.6.17-git13/drivers/net/pcnet32.c	Thu Jun 29 13:28:31 2006
> [...]
> > +#ifdef CONFIG_PCNET32_NAPI
> > +static int pcnet32_poll(struct net_device *dev, int *budget)
> > +{
> [...]
> > +	netif_rx_complete(dev);
> > +
> > +	spin_lock_irqsave(&lp->lock, flags);
> 
> No need to save/restore (it's true in pcnet32_{get_regs/suspend} too).

This lock is taken by the interrupt handler and my reading of
spinlocks.txt says I do need to use spin_lock_irqsave unless I
misunderstand.  The only spin_lock() is in the interrupt handler itself,
all others are spin_lock_irqsave.

> 
> > +
> > +	/* clear interrupt masks */
> > +	val = lp->a.read_csr(ioaddr, CSR3);
> > +	val &= 0x00ff;
> > +	lp->a.write_csr(ioaddr, CSR3, val);
> > +
> > +	/* Set interrupt enable. */
> > +	lp->a.write_csr(ioaddr, CSR0, CSR0_INTEN);
> 
> Insert mmiowb():

Is this required in addition to the two outw() in write_csr?  There are
rmb() and wmb() in the places that need them, but no mmiowb() anywhere.
What are the factors for when mmiowb needs to be inserted?

> 
> > +
> > +	spin_unlock_irqrestore(&lp->lock, flags);
> 
> [...]
> > @@ -2413,183 +2608,41 @@ pcnet32_interrupt(int irq, void *dev_id,
> >  				       dev->name, csr0);
> >  			/* unlike for the lance, there is no restart needed */
> >  		}
> > -
> > -		if (must_restart) {
> > +#ifdef CONFIG_PCNET32_NAPI
> > +		if (netif_rx_schedule_prep(dev)) {
> > +			u16 val;
> > +			/* set interrupt masks */
> > +			val = lp->a.read_csr(ioaddr, CSR3);
> > +			val |= 0x5f00;
> > +			lp->a.write_csr(ioaddr, CSR3, val);
> 
> Insert mmiowb();
> 
> -- 
> Ueimor

-- 
Don Fry
brazilnut@us.ibm.com
