From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [RFC][PATCH 1/4] IRQ: IRQ groups for multiqueue devices
Date: Tue, 21 Sep 2010 21:04:39 +0200 (CEST)
Message-ID: <alpine.LFD.2.00.1009211827440.2416@localhost6.localdomain6>
References: <1285009290.2282.121.camel@achroite.uk.solarflarecom.com>  <1285009685.2282.127.camel@achroite.uk.solarflarecom.com>  <alpine.LFD.2.00.1009202137580.2416@localhost6.localdomain6> <1285071945.2307.21.camel@achroite.uk.solarflarecom.com>
 <alpine.LFD.2.00.1009211455140.2416@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Tom Herbert <therbert@google.com>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@elte.hu>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.1009211455140.2416@localhost6.localdomain6>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 21 Sep 2010, Thomas Gleixner wrote:
> On Tue, 21 Sep 2010, Ben Hutchings wrote:
> > On Mon, 2010-09-20 at 23:27 +0200, Thomas Gleixner wrote:
> Lemme summarize what I understand so far. For multiqueue devices with
> several queues and interrupts you want to lookup the closest queue/irq
> to the cpu on which you are currently running to avoid expensive cross
> node memory access. Now you need to follow affinity changes for this
> lookup table.
> 
> The basic idea of your code is ok. The lookup table itself is fine,
> but the integration into the genirq code sucks. What needs to be done:
> 
> 1) Remove the references to irq_desc in the group. They are not needed
>    and will never work. The group does not need any information about
>    the irq number and the irq descriptor.
> 
> 2) Add proper refcounting to struct irq_group so it can be accessed
>    outside of irq_desc->lock.
> 
> 3) Move the update of the map outside of irq_desc->lock and the irq
>    disabled region. Update the map in setup_affinity() as well. That
>    code can be called from various atomic contexts, so it's probably
>    the best thing to delegate the update to a workqueue or such unless
>    you come up with a nice prebuilt lookup table.
> 
> 4) Add comments so the code is understandable for mere mortals
> 
> 5) Add proper install/free handling. Hint: affinity_hint
> 
> 6) All modifications of irq_desc need a check whether irq_to_desc
>    returned a valid pointer and must hold desc->lock
> 
> 7) Deal with concurrent updates of multiple irqs in a group (at least
>    a comment why the code does not need serialization)
> 
> 8) Move the code to kernel/irq/irqgroup.c or some other sensible name
>    and make it configurable so embedded folks don't have to carry it
>    around as useless binary bloat.

Talked to Peter about it and we came to the conclusion, that we should
just provide a callback infrastructure in the irq code which does not
care about the action behind it. That's going to solve #1,#2,#3,#5,#6
and parts of #8

That queue/index map code should move to lib/ or some other
appropriate place so it can be shared with storage or whatever is
going to grow multiqueue. comments #4, #7, #8 (s@kernel/irq@lib/@)
above still apply :)

The modification to the genirq code would be based on registering

struct irq_affinity_callback {
	unsigned int irq;
	struct kref kref;
	struct work work;
	void (*callback)(struct irq_affinity_callback *, const cpumask_t *mask);
	void (*release)(struct kref *ref);
};

for an interrupt via 

int irq_set_affinity_callback(unsigned int irq,
    			      struct irq_affinity_callback *cb);

That function can be called with cb=NULL to remove the callback. if
cb!=NULL, irq, kref and work are initialized.

The genirq code schedules work when affinity changes and the callback
struct pointer is non NULL. The callback is then called from the
worker thread with a copy of the irq affinity mask.

So on any affinity change, we do with desc->lock held:

   if (desc->affinity_callback) {
      	kref_get(&desc->affinity_callback->kref);
	schedule_work(&desc->affinity_callback->work);
   }

The worker function in the genirq code does:
{
    struct irq_affinity_callback *cb;
    struct irq_desc *desc;
    cpu_mask_t cpumask;

    cb = container_of(work, struct irq_affinity_callback, work);

    desc = irq_to_desc(cb->irq);
    if (!desc)
       goto out;

    if (!alloc_cpumask_var(&cpumask, GFP_KERNEL)
       goto out;

    raw_spin_lock_irqsave(&desc->lock, flags);
    cpumask_copy(cpumask, desc->affinity);
    raw_spin_unlock_irqrestore(&desc->lock, flags);

    cb->callback(cb, cpumask);

    free_cpumask_var(cpumask);
out:
    kref_put(&cb->kref, cb->release);
}

That allows you to do all kind of magic in thread context, updating
the queue map, reallocating queue memory when the node affinity
changes (I know that you want to), go wild.

Thoughts ?

	 tglx
