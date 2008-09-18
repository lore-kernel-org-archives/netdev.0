From: Sebastien Dugue <sebastien.dugue@bull.net>
Subject: Re: [PATCH HACK] powerpc: quick hack to get a functional eHEA with
 hardirq preemption
Date: Thu, 18 Sep 2008 11:27:13 +0200
Message-ID: <20080918112713.75872c95@bull.net>
References: <20080915100406.342e027a@bull.net>
	<OF39C3BF0F.17B60FAA-ONC12574C8.002AE138-C12574C8.002B6422@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: gilles.carry@ext.bull.net, Jan-Bernd Themann <THEMANN@de.ibm.com>,
	jean-pierre.dion@bull.net,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Linux-rt <linux-rt-users@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>, netdev@vger.kernel.org,
	Thomas Q Klein <TKLEIN@de.ibm.com>, tinytim@us.ibm.com,
	Benjamin Herrenschmidt <bherren@au1.ibm.com>
To: Christoph Raisch <RAISCH@de.ibm.com>
Return-path: <linux-rt-users-owner@vger.kernel.org>
In-Reply-To: <OF39C3BF0F.17B60FAA-ONC12574C8.002AE138-C12574C8.002B6422@de.ibm.com>
Sender: linux-rt-users-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 18 Sep 2008 09:53:54 +0200 Christoph Raisch <RAISCH@de.ibm.com> wrote:

> 
> Sebastien Dugue <sebastien.dugue@bull.net> wrote on 15.09.2008 10:04:06:
> > [PATCH HACK] powerpc: quick hack to get a functional eHEA with
> > hardirq preemption
> >
> > Sebastien Dugue
> >
> > to:
> >
> > 15.09.2008 10:07
> >
> > Cc:
> >
> > linux-ppc, linux-kernel, Linux-rt, netdev, Jan-Bernd Themann, Thomas
> > Q Klein, Christoph Raisch, jean-pierre.dion, gilles.carry, tinytim
> >
> >
> > WARNING: HACK - HACK - HACK
> > Not-Signed-off-by: Sebastien Dugue <sebastien.dugue@bull.net>
> > ---
> > --- a/arch/powerpc/kernel/ibmebus.c
> > +++ b/arch/powerpc/kernel/ibmebus.c
> > @@ -41,6 +41,7 @@
> > -   return request_irq(irq, handler, irq_flags, devname, dev_id);
> > +   ret = request_irq(irq, handler, irq_flags, devname, dev_id);
> > +
> > +   desc = irq_desc + irq;
> > +   desc->status &= ~(IRQ_TYPE_SENSE_MASK | IRQ_LEVEL);
> > +   desc->status |= IRQ_TYPE_EDGE_RISING;
> > +
> > +   return ret;
> This looks a bit like a set_irq_type call.

  Yep.

> Don't know if this is fully implemented for xics though...

  No, the xics does not implement a set_type() method.

> >  }
> >  EXPORT_SYMBOL(ibmebus_request_irq);
> >
> > diff --git a/kernel/irq/chip.c b/kernel/irq/chip.c
> > index b7b397a..6d366ca 100644
> > --- a/kernel/irq/chip.c
> > +++ b/kernel/irq/chip.c
> > @@ -430,7 +430,7 @@ handle_fasteoi_irq(unsigned int irq, struct
> > irq_desc *desc)
> >     action = desc->action;
> >     if (unlikely(!action || (desc->status & (IRQ_INPROGRESS |
> >                     IRQ_DISABLED)))) {
> > -      desc->status |= IRQ_PENDING;
> > +      desc->status |= IRQ_PENDING | IRQ_MASKED;
> >        if (desc->chip->mask)
> >           desc->chip->mask(irq);
> >        goto out;
> > @@ -439,9 +439,10 @@ handle_fasteoi_irq(unsigned int irq, struct
> > irq_desc *desc)
> >     desc->status |= IRQ_INPROGRESS;
> >     /*
> >      * In the threaded case we fall back to a mask+eoi sequence:
> > +    * excepted for edge interrupts which are not masked.
> >      */
> >     if (redirect_hardirq(desc)) {
> > -      if (desc->chip->mask)
> > +      if (desc->chip->mask && !(desc->status & IRQ_TYPE_EDGE_BOTH))
> >           desc->chip->mask(irq);
> >        goto out;
> >     }
> > diff --git a/kernel/irq/manage.c b/kernel/irq/manage.c
> > index 3bffa20..3e39c71 100644
> > --- a/kernel/irq/manage.c
> > +++ b/kernel/irq/manage.c
> > @@ -788,9 +788,12 @@ static void do_hardirq(struct irq_desc *desc)
> >        thread_simple_irq(desc);
> >     else if (desc->handle_irq == handle_level_irq)
> >        thread_level_irq(desc);
> > -   else if (desc->handle_irq == handle_fasteoi_irq)
> > -      thread_fasteoi_irq(desc);
> > -   else if (desc->handle_irq == handle_edge_irq)
> > +   else if (desc->handle_irq == handle_fasteoi_irq) {
> > +      if (desc->status & IRQ_TYPE_EDGE_BOTH)
> > +         thread_edge_irq(desc);
> > +      else
> > +         thread_fasteoi_irq(desc);
> > +   } else if (desc->handle_irq == handle_edge_irq)
> >        thread_edge_irq(desc);
> >     else
> >        thread_do_irq(desc);
> > --
> > 1.6.0.1.308.gede4c
> >
> According to the specs at some point in the system the HEA IRQs have a edge
> characteristic.
> But since PCI-E edge and level can both be forwarded through a message
> interface
> (HEA is not PCI-E, it's only connected to the same internal bus, where the
> PHB resides)

  Good to know, the problem here seems to be that the xics is using the
fasteoi flow handler, which under unconditionally masks the irq. Will have to
dig in the genirq stuff a bit more to understand what the differences are
between -rt and mainline.

> 
> Anybody from the xics experts want to comment on this?

  It would be really interresting to know if the eHCA exhibits the same
problem under -rt as it's the only other user of the ibmebus.
Unfortunately I don't have the hardware to test.

  Thanks,

  Sebastien.


> 
> 
> 
> Gruss / Regards
> Christoph R.  & Jan-Bernd
> 
> 
