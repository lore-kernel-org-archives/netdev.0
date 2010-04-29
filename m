From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: Re: [PATCH RFC: linux-next 1/2] irq: Add CPU mask affinity hint
 callback framework
Date: Thu, 29 Apr 2010 10:59:06 -0700
Message-ID: <1272563946.9614.1.camel@localhost>
References: <20100419045741.30276.23233.stgit@ppwaskie-hc2.jf.intel.com>
	 <alpine.LFD.2.00.1004271425140.2951@localhost.localdomain>
	 <Pine.WNT.4.64.1004270856560.320@PPWASKIE-MOBL2.amr.corp.intel.com>
	 <alpine.LFD.2.00.1004271809080.2951@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"arjan@linux.jf.intel.com" <arjan@linux.jf.intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:2297 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933084Ab0D3RVW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Apr 2010 13:21:22 -0400
In-Reply-To: <alpine.LFD.2.00.1004271809080.2951@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-04-28 at 09:45 -0700, Thomas Gleixner wrote:
> B1;2005;0cPeter,
> 
> On Tue, 27 Apr 2010, Peter P Waskiewicz Jr wrote:
> > On Tue, 27 Apr 2010, Thomas Gleixner wrote:
> > > On Sun, 18 Apr 2010, Peter P Waskiewicz Jr wrote:
> > > > +/**
> > > > + * struct irqaffinityhint - per interrupt affinity helper
> > > > + * @callback:	device driver callback function
> > > > + * @dev:	reference for the affected device
> > > > + * @irq:	interrupt number
> > > > + */
> > > > +struct irqaffinityhint {
> > > > +	irq_affinity_hint_t callback;
> > > > +	void *dev;
> > > > +	int irq;
> > > > +};
> > > 
> > > Why do you need that extra data structure ? The device and the irq
> > > number are known, so all you need is the callback itself. So no need
> > > for allocating memory ....
> > 
> > When I register the function callback with the interrupt layer, I need to
> > know what device structures to reference back in the driver.  In other words,
> > if I call into an underlying driver with just an interrupt number, then I
> > have no way at getting at the dev structures (netdevice for me, plus my
> > private adapter structures), unless I declare them globally (yuck).
> 
> Grr, I knew that I missed something. That'll teach me to review
> patches before the coffee has reached my brain cells :)
> 
> > I had a different approach before this one where I assumed the device from
> > the irq handler callback was safe to use for the device in this new callback.
> > I didn't feel really great about that, since it's an implicit assumption that
> > could cause things to go sideways really quickly.
> >
> > Let me know what you think either way.  I'm certainly willing to make a
> > change, I just don't know at this point what's the safest approach from what
> > I currently have.
> 
> So you need a reference to your device, so what about the following:
> 
> struct irq_affinity_hint;
> 
> struct irq_affinity_hint {
>        unsigned int (*callback)(unsigned int irq, struct irq_affinity_hint *hint,
> 				cpumask_var_t *mask);
> }
> 
> Now you embed that struct into your device private data structure and
> you get the reference to it back in the callback function. No extra
> kmalloc/kfree, less code.

Good idea!  I'll roll that into my new version.

> One other thing I noticed, but forgot to comment on:
> 
> > +static int irq_affinity_hint_proc_show(struct seq_file *m, void *v)
> > +{
> > +	struct irq_desc *desc = irq_to_desc((long)m->private);
> > +	struct cpumask mask;
> > +	unsigned int ret = 0;
> 
>  Why do we return 0, when there is no callback and no hint available ?

I initialized it to 0 to remove a compiler warning; I can put more
thought into it and assign a more appropriate return value.

> > +
> 
>   We don't want to have cpumask enforced on stack. Please make that:
> 
>      	cpumask_var_t mask;
> 
> 	if (!alloc_cpumask_var(&mask, GFP_KERNEL))
> 	       return -ENOMEM;

I'll roll this into my next version.

> > +	if (desc->hint && desc->hint->callback) {
> 
>   The access to desc-> needs to be protected with
>   desc->lock. Otherwise you might race with a callback unregister.

Good point.  I'll fix this.

> > +		ret = desc->hint->callback(&mask, (long)m->private,
> > +		                           desc->hint->dev);
> > +		if (!ret)
> > +			seq_cpumask(m, &mask);
> > +	}
> > +
> > +	seq_putc(m, '\n');
> > +	return ret;
> > +}
> 
> Thanks,
> 

Thanks for the feedback.  I'll have the updated patches for review soon.

-PJ

