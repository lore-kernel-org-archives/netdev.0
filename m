From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [RFC][PATCH 1/4] IRQ: IRQ groups for multiqueue devices
Date: Wed, 22 Sep 2010 18:06:32 +0200 (CEST)
Message-ID: <alpine.LFD.2.00.1009221803170.2416@localhost6.localdomain6>
References: <1285009290.2282.121.camel@achroite.uk.solarflarecom.com>  <1285009685.2282.127.camel@achroite.uk.solarflarecom.com>  <alpine.LFD.2.00.1009202137580.2416@localhost6.localdomain6>  <1285071945.2307.21.camel@achroite.uk.solarflarecom.com>
 <alpine.LFD.2.00.1009211455140.2416@localhost6.localdomain6>  <alpine.LFD.2.00.1009211827440.2416@localhost6.localdomain6> <1285171249.2279.11.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Tom Herbert <therbert@google.com>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@elte.hu>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1285171249.2279.11.camel@achroite.uk.solarflarecom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 22 Sep 2010, Ben Hutchings wrote:

> On Tue, 2010-09-21 at 21:04 +0200, Thomas Gleixner wrote:
> [...]
> > Talked to Peter about it and we came to the conclusion, that we should
> > just provide a callback infrastructure in the irq code which does not
> > care about the action behind it. That's going to solve #1,#2,#3,#5,#6
> > and parts of #8
> > 
> > That queue/index map code should move to lib/ or some other
> > appropriate place so it can be shared with storage or whatever is
> > going to grow multiqueue. comments #4, #7, #8 (s@kernel/irq@lib/@)
> > above still apply :)
> 
> OK.
> 
> > The modification to the genirq code would be based on registering
> > 
> > struct irq_affinity_callback {
> > 	unsigned int irq;
> > 	struct kref kref;
> > 	struct work work;
> > 	void (*callback)(struct irq_affinity_callback *, const cpumask_t *mask);
> > 	void (*release)(struct kref *ref);
> > };
> > 
> > for an interrupt via 
> > 
> > int irq_set_affinity_callback(unsigned int irq,
> >     			      struct irq_affinity_callback *cb);
> > 
> > That function can be called with cb=NULL to remove the callback. if
> > cb!=NULL, irq, kref and work are initialized.
> 
> When should it be called, relative to {request,free}_irq() and
> pci_{disable,enable}_msix()?

It should be called before request_irq and before free_irq. free_irq
will warn when the pointer is !NULL.
 
> [...]
> > That allows you to do all kind of magic in thread context, updating
> > the queue map, reallocating queue memory when the node affinity
> > changes (I know that you want to), go wild.
> 
> I definitely don't want to reallocate queues if node affinity of the IRQ
> is changed by irqbalance, because this will disrupt traffic.  So
> changing the node affinity of queues has to be a separate operation.

Fair enough.
 
> > Thoughts ?
> 
> This does look like something I can use, thanks.

Will look into it in the next days.

Thanks,

	tglx
