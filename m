From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [RFC][PATCH 1/4] IRQ: IRQ groups for multiqueue devices
Date: Mon, 20 Sep 2010 23:27:01 +0200 (CEST)
Message-ID: <alpine.LFD.2.00.1009202137580.2416@localhost6.localdomain6>
References: <1285009290.2282.121.camel@achroite.uk.solarflarecom.com> <1285009685.2282.127.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Tom Herbert <therbert@google.com>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@elte.hu>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1285009685.2282.127.camel@achroite.uk.solarflarecom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ben,

On Mon, 20 Sep 2010, Ben Hutchings wrote:

it would have been nice if I'd been cc'ed on that, but of course it's
my fault that there is no entry in MAINTAINERS. No, it's not.

> When initiating I/O on multiqueue devices, we usually want to select a

"we usually" is pretty useless for people not familiar with the
problem at hand. A [PATCH 0/4] intro would have been helpful along
with the users (aka [PATCH 2-4/4]) of the new facility.

Don't take it personally and I'm sure that you're solving a real world
problem, but I'm starting to get grumpy that especially networking
folks (aside of various driver developers) believe that adding random
stuff to kernel/irq is their private pleasure. Is it that hard to talk
to me upfront ?

> queue for which the response will be handled on the same or a nearby
> CPU.  IRQ groups hold a mapping of CPU to IRQ which will be updated
> based on the inverse of IRQ CPU-affinities plus CPU topology
> information.

Can you please explain, why you need that reverse mapping including
the below code ? What problem does this solve which can not be deduced
by the exisiting information/infrastructure ? And why is that reverse
mapping tied to interrupts and not something which we want to see in
some generic available (library) code ?

More comments inline.

> ---
>  include/linux/irq.h |   52 ++++++++++++++++++
>  kernel/irq/manage.c |  149 +++++++++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 201 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/irq.h b/include/linux/irq.h
> index c03243a..bbddd5f 100644
> --- a/include/linux/irq.h
> +++ b/include/linux/irq.h
> @@ -196,6 +196,8 @@ struct irq_desc {
>  #ifdef CONFIG_SMP
>  	cpumask_var_t		affinity;
>  	const struct cpumask	*affinity_hint;

  How about updating the kernel doc above the struct ?

> +	struct irq_group	*group;

  Grr, how does this compile ? That needs at least a forward
  declaration of struct irq_group. RFC is _NOT_ an excuse

> +	u16			group_index;

  What's group_index doing and what's the point of an u16 here ?

>  	unsigned int		node;
>  #ifdef CONFIG_GENERIC_PENDING_IRQ
>  	cpumask_var_t		pending_mask;
> @@ -498,6 +500,33 @@ static inline void free_desc_masks(struct irq_desc *old_desc,
>  #endif
>  }
>  
> +/**
> + * struct irq_group - IRQ group for multiqueue devices
> + * @closest: For each CPU, the index and distance to the closest IRQ,
> + *	based on affinity masks

  index of what ?

  Btw, please follow the style of the other kernel doc comments in this
  file where the explanation is aligned for readability sake

> + * @size: Size of the group
> + * @used: Number of IRQs currently included in the group
> + * @irq: Descriptors for IRQs in the group

  That's an array of pointers to irq descriptors, right ?

  Insert some sensible decription what irq groups are and for which
  problem space they are useful if at all.

> + */
> +struct irq_group {
> +	struct {
> +		u16	index;
> +		u16	dist;
> +	} closest[NR_CPUS];
> +	unsigned int	size, used;

  Separate lines please

> +	struct irq_desc *irq[0];
> +};

  Please separate this with a newline and add some useful comment
  about the meaning and purpose of this not selfexplaining constant.

> +#define IRQ_CPU_DIST_INF 0xffff

> +static inline u16 irq_group_get_index(struct irq_group *group, int cpu)
> +{
> +	return group->closest[cpu].index;
> +}
> +

  So you have an accessor function for closest[cpu].index. Are the
  other members meant to be accessible directly by random driver ?

>  #else /* !CONFIG_SMP */
>  
>  static inline bool alloc_desc_masks(struct irq_desc *desc, int node,
> @@ -519,6 +548,29 @@ static inline void free_desc_masks(struct irq_desc *old_desc,
>  				   struct irq_desc *new_desc)
>  {
>  }
> +
> +struct irq_group {
> +};
> +
> +static inline struct irq_group *alloc_irq_group(unsigned int size, gfp_t flags)
> +{
> +	static struct irq_group dummy;

  That will create one static instance per callsite. Is that on
  purpose? If yes, it needs a damned good comment.

> +	return &dummy;

>  #endif	/* CONFIG_SMP */
>  
>  #endif /* _LINUX_IRQ_H */
> diff --git a/kernel/irq/manage.c b/kernel/irq/manage.c
> index c3003e9..3f2b1a9 100644
> --- a/kernel/irq/manage.c
> +++ b/kernel/irq/manage.c
> @@ -100,6 +100,154 @@ void irq_set_thread_affinity(struct irq_desc *desc)
>  	}
>  }
>  
> +static void irq_group_update_neigh(struct irq_group *group,
> +				   const struct cpumask *mask,
> +				   u16 index, u16 dist)
> +{
> +	int cpu;
> +
> +	for_each_cpu(cpu, mask) {
> +		if (dist < group->closest[cpu].dist) {
> +			group->closest[cpu].index = index;
> +			group->closest[cpu].dist = dist;
> +		}
> +	}
> +}

  I have not the faintest idea how group, index and dist are related
  to each other. And I have no intention to decode the information
  about that piecewise by reverse engineering that obfuscated code.

> +static bool irq_group_copy_neigh(struct irq_group *group, int cpu,
> +				 const struct cpumask *mask, u16 dist)
> +{
> +	int neigh;
> +
> +	for_each_cpu(neigh, mask) {
> +		if (group->closest[neigh].dist <= dist) {
> +			group->closest[cpu].index = group->closest[neigh].index;
> +			group->closest[cpu].dist = dist;
> +			return true;
> +		}
> +	}
> +	return false;

  What's the reason for copying or not ?

> +}
> +
> +/* Update the per-CPU closest IRQs following a change of affinity */
> +static void
> +irq_update_group(struct irq_desc *desc, const struct cpumask *affinity)
> +{
> +	struct irq_group *group = desc->group;
> +	unsigned index = desc->group_index;
> +	int cpu;
> +
> +	if (!group)
> +		return;
> +
> +	/* Invalidate old distances to this IRQ */
> +	for_each_online_cpu(cpu)
> +		if (group->closest[cpu].index == index)
> +			group->closest[cpu].dist = IRQ_CPU_DIST_INF;
> +
> +	/*
> +	 * Set this as the closest IRQ for all CPUs in the affinity mask,
> +	 * plus the following CPUs if they don't have a closer IRQ:
> +	 * - all other threads in the same core (distance 1);
> +	 * - all other cores in the same package (distance 2);
> +	 * - all other packages in the same NUMA node (distance 3).
> +	 */
> +	for_each_cpu(cpu, affinity) {
> +		group->closest[cpu].index = index;
> +		group->closest[cpu].dist = 0;
> +		irq_group_update_neigh(group, topology_thread_cpumask(cpu),
> +				       index, 1);
> +		irq_group_update_neigh(group, topology_core_cpumask(cpu),
> +				       index, 2);
> +		irq_group_update_neigh(group, cpumask_of_node(cpu_to_node(cpu)),
> +				       index, 3);
> +	}
> +
> +	/* Find new closest IRQ for any CPUs left with invalid distances */
> +	for_each_online_cpu(cpu) {
> +		if (!(group->closest[cpu].index == index &&
> +		      group->closest[cpu].dist == IRQ_CPU_DIST_INF))
> +			continue;
> +		if (irq_group_copy_neigh(group, cpu,
> +					 topology_thread_cpumask(cpu), 1))
> +			continue;
> +		if (irq_group_copy_neigh(group, cpu,
> +					 topology_core_cpumask(cpu), 2))
> +			continue;
> +		if (irq_group_copy_neigh(group, cpu,
> +					 cpumask_of_node(cpu_to_node(cpu)), 3))
> +			continue;
> +		/* We could continue into NUMA node distances, but for now
> +		 * we give up. */

  What are the consequences of giving up ? Does not happen ? Should
  not happen ? Will break ? Don't care ? ....

> +	}

  This is called from irq_set_affinity() with desc->lock held and
  interrupts disabled. You're not serious about that, are you ?

  Damned, there are two iterations over each online cpu and another
  one over the affinity mask. Did you ever extrapolate how long that
  runs on a really large machine ?

  If CPU affinity of an IRQ changes, then it does not matter if one or
  two interrupts end up in the wrong space. Those changes are not
  happening every other interrupt.

> +}
> +
> +/**
> + *	alloc_irq_group - allocate IRQ group
> + *	@size:		Size of the group

  size of what ? I guess number of interrupts, right ?

> + *	@flags:		Allocation flags e.g. %GFP_KERNEL
> + */
> +struct irq_group *alloc_irq_group(unsigned int size, gfp_t flags)
> +{
> +	struct irq_group *group =
> +		kzalloc(sizeof(*group) + size * sizeof(group->irq[0]), flags);
> +	int cpu;
> +
> +	if (!group)
> +		return NULL;
> +
> +	/* Initially assign CPUs to IRQs on a rota */
> +	for (cpu = 0; cpu < NR_CPUS; cpu++) {
> +		group->closest[cpu].index = cpu % size;

  So here we randomly assign index with the lower cpu numbers no
  matter whether they are online or possible ?

> +		group->closest[cpu].dist = IRQ_CPU_DIST_INF;
> +	}
> +
> +	group->size = size;
> +	return group;
> +}
> +EXPORT_SYMBOL(alloc_irq_group);

  EXPORT_SYMBOL_GPL if at all. Same for the other exports

> +
> +/**
> + *	free_irq_group - free IRQ group
> + *	@group:		IRQ group allocated with alloc_irq_group(), or %NULL

  How is this serialized or sanity checked against free_irq() ?

> + */
> +void free_irq_group(struct irq_group *group)
> +{
> +	struct irq_desc *desc;
> +	unsigned int i;
> +
> +	if (!group)
> +		return;
> +
> +	/* Remove all descriptors from the group */
> +	for (i = 0; i < group->used; i++) {
> +		desc = group->irq[i];
> +		BUG_ON(desc->group != group || desc->group_index != i);
> +		desc->group = NULL;
> +	}
> +
> +	kfree(group);
> +}
> +EXPORT_SYMBOL(free_irq_group);
> +
> +/**
> + *	irq_group_add - add IRQ to a group
> + *	@group:		IRQ group allocated with alloc_irq_group()
> + *	@irq:		Interrupt to add to group
> + */
> +void irq_group_add(struct irq_group *group, unsigned int irq)
> +{
> +	struct irq_desc *desc = irq_to_desc(irq);

  Again, how is this serialized against anything else fiddling with
  irq_desc[irq]?

> +	BUG_ON(desc->group);
> +	BUG_ON(group->used >= group->size);
> +
> +	desc->group = group;
> +	desc->group_index = group->used;
> +	group->irq[group->used++] = desc;
> +}
> +EXPORT_SYMBOL(irq_group_add);

Thanks,

	tglx
