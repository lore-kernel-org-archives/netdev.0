From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [RFC][PATCH 1/4] IRQ: IRQ groups for multiqueue devices
Date: Tue, 21 Sep 2010 17:34:26 +0200 (CEST)
Message-ID: <alpine.LFD.2.00.1009211455140.2416@localhost6.localdomain6>
References: <1285009290.2282.121.camel@achroite.uk.solarflarecom.com>  <1285009685.2282.127.camel@achroite.uk.solarflarecom.com>  <alpine.LFD.2.00.1009202137580.2416@localhost6.localdomain6> <1285071945.2307.21.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Tom Herbert <therbert@google.com>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@elte.hu>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1285071945.2307.21.camel@achroite.uk.solarflarecom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 21 Sep 2010, Ben Hutchings wrote:
> On Mon, 2010-09-20 at 23:27 +0200, Thomas Gleixner wrote:
> > > queue for which the response will be handled on the same or a nearby
> > > CPU.  IRQ groups hold a mapping of CPU to IRQ which will be updated
> > > based on the inverse of IRQ CPU-affinities plus CPU topology
> > > information.
> > 
> > Can you please explain, why you need that reverse mapping including
> > the below code ? What problem does this solve which can not be deduced
> > by the exisiting information/infrastructure ? And why is that reverse
> > mapping tied to interrupts and not something which we want to see in
> > some generic available (library) code ?
> 
> Are you thinking of a per-CPU distance map?  That seems like it would be
> useful to have.  I wonder about the storage requirements on larger
> systems.

  That might be a problem, but we should at least look into this.

  But even if a prebuilt map is too expensive storage wise, then the
  functions which build the lookup map might be useful for similar
  distance lookup scenarios as well.

> > > +static inline struct irq_group *alloc_irq_group(unsigned int size, gfp_t flags)
> > > +{
> > > +	static struct irq_group dummy;
> > 
> >   That will create one static instance per callsite. Is that on
> >   purpose? If yes, it needs a damned good comment.
> 
> Which uses no storage, or maybe 1 byte.  I'm open to suggestions for a
> better dummy implementation.
> 
> > > +	return &dummy;

  Why does it need to return a real struct instead of NULL ?
 
> > > +	}
> > 
> >   This is called from irq_set_affinity() with desc->lock held and
> >   interrupts disabled. You're not serious about that, are you ?
> > 
> >   Damned, there are two iterations over each online cpu and another
> >   one over the affinity mask. Did you ever extrapolate how long that
> >   runs on a really large machine ?
> 
> No, and I know this sucks.  So, do you want to suggest anything better?
> Should I look at building those CPU distance maps (trading space for
> time)?

  The point is that there is no reason why this code needs to run in a
  spinlocked irq disabled reason. I know why your implementation needs
  it, because it protects you against module unload etc. Come on, we
  have enough infrastructure to control the lifetime of objects in
  sane ways and not by hijacking a heavy lock and disabling
  interrupts.

  Btw, how does this code deal with concurrent affinity setting of
  multiple irqs in the group ? Random number generator ?

> > > + *	@flags:		Allocation flags e.g. %GFP_KERNEL

  Why do we need flags here? That code gets called in a device setup
  routine and not from random context.

> > > + */
> > > +struct irq_group *alloc_irq_group(unsigned int size, gfp_t flags)
> > > +{

> > > +
> > > +/**
> > > + *	free_irq_group - free IRQ group
> > > + *	@group:		IRQ group allocated with alloc_irq_group(), or %NULL
> > 
> >   How is this serialized or sanity checked against free_irq() ?
> 
> free_irq() should be called first, for all IRQs in the group.  The IRQs
> should then be really freed with pci_disable_msix() or similar.

  I explained that several times, that I do not care about what should
  be called in which order and what not. Driver coders get it wrong
  all the time, then it explodes in the genirq code and I get the crap
  to debug. No, thanks.

  Also if you call free_irq() first, then you still have a reference
  to that very irq descriptor in your group and a reference to the
  group in the irq descriptor. Brilliant, as the irq descriptor can be
  reused immediately after free_irq().

  Also it's not only problematic against free_irq, it's damned racy
  against a concurrent affinity setting as well. And that's not
  controlled by "should be called" at all.

> > > +/**
> > > + *	irq_group_add - add IRQ to a group
> > > + *	@group:		IRQ group allocated with alloc_irq_group()
> > > + *	@irq:		Interrupt to add to group
> > > + */
> > > +void irq_group_add(struct irq_group *group, unsigned int irq)
> > > +{
> > > +	struct irq_desc *desc = irq_to_desc(irq);
> > 
> >   Again, how is this serialized against anything else fiddling with
> >   irq_desc[irq]?
> 
> The driver should call this after allocating IRQs with pci_enable_msix()
> or similar and before setting the handlers with request_irq().  Is that
> sufficient?

  "should call" is _NEVER_ sufficient. fiddling with irq_desc w/o
  holding the lock is a nono, period.

> > > +	BUG_ON(desc->group);
> > > +	BUG_ON(group->used >= group->size);
> > > +
> > > +	desc->group = group;
> > > +	desc->group_index = group->used;
> > > +	group->irq[group->used++] = desc;

  Forgot to ask yesterday. Why do we need to store irq desc in the
  group ? For free_irq_group() I guess, but I explained already why
  this code is broken. And it's even more broken when an irq is moved
  to a different node and CONFIG_NUMA_IRQ_DESC=y.

Lemme summarize what I understand so far. For multiqueue devices with
several queues and interrupts you want to lookup the closest queue/irq
to the cpu on which you are currently running to avoid expensive cross
node memory access. Now you need to follow affinity changes for this
lookup table.

The basic idea of your code is ok. The lookup table itself is fine,
but the integration into the genirq code sucks. What needs to be done:

1) Remove the references to irq_desc in the group. They are not needed
   and will never work. The group does not need any information about
   the irq number and the irq descriptor.

2) Add proper refcounting to struct irq_group so it can be accessed
   outside of irq_desc->lock.

3) Move the update of the map outside of irq_desc->lock and the irq
   disabled region. Update the map in setup_affinity() as well. That
   code can be called from various atomic contexts, so it's probably
   the best thing to delegate the update to a workqueue or such unless
   you come up with a nice prebuilt lookup table.

4) Add comments so the code is understandable for mere mortals

5) Add proper install/free handling. Hint: affinity_hint

6) All modifications of irq_desc need a check whether irq_to_desc
   returned a valid pointer and must hold desc->lock

7) Deal with concurrent updates of multiple irqs in a group (at least
   a comment why the code does not need serialization)

8) Move the code to kernel/irq/irqgroup.c or some other sensible name
   and make it configurable so embedded folks don't have to carry it
   around as useless binary bloat.

Thanks,

	tglx
