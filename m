From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH linux-next v2 1/2] irq: Add CPU mask affinity hint
Date: Fri, 30 Apr 2010 12:53:11 +0200 (CEST)
Message-ID: <alpine.LFD.2.00.1004301249540.2951@localhost.localdomain>
References: <20100430085150.4630.46790.stgit@ppwaskie-hc2.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: davem@davemloft.net, arjan@linux.jf.intel.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100430085150.4630.46790.stgit@ppwaskie-hc2.jf.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 30 Apr 2010, Peter P Waskiewicz Jr wrote:

> This patch adds a cpumask affinity hint to the irq_desc
> structure, along with a registration function and a read-only
> proc entry for each interrupt.
> 
> This affinity_hint handle for each interrupt can be used by
> underlying drivers that need a better mechanism to control
> interrupt affinity.  The underlying driver can register a
> cpumask for the interrupt, which will allow the driver to
> provide the CPU mask for the interrupt to anything that
> requests it.  The intent is to extend the userspace daemon,
> irqbalance, to help hint to it a preferred CPU mask to balance
> the interrupt into.
> 
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> ---
> 
>  include/linux/interrupt.h |   13 +++++++++++++
>  include/linux/irq.h       |    1 +
>  kernel/irq/manage.c       |   28 ++++++++++++++++++++++++++++
>  kernel/irq/proc.c         |   33 +++++++++++++++++++++++++++++++++
>  4 files changed, 75 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/interrupt.h b/include/linux/interrupt.h
> index 75f3f00..9c9ea2a 100644
> --- a/include/linux/interrupt.h
> +++ b/include/linux/interrupt.h
> @@ -209,6 +209,9 @@ extern int irq_set_affinity(unsigned int irq, const struct cpumask *cpumask);
>  extern int irq_can_set_affinity(unsigned int irq);
>  extern int irq_select_affinity(unsigned int irq);
>  
> +extern int irq_register_affinity_hint(unsigned int irq,
> +                                      const struct cpumask *m);

I think we can do with a single funtion irq_set_affinity_hint() and
let the caller set the pointer to NULL.

>  
> +int irq_register_affinity_hint(unsigned int irq, const struct cpumask *m)
> +{
> +	struct irq_desc *desc = irq_to_desc(irq);
> +	unsigned long flags;

  desc needs to be checked. It might be NULL !

> +
> +	raw_spin_lock_irqsave(&desc->lock, flags);
> +	desc->affinity_hint = m;
> +	raw_spin_unlock_irqrestore(&desc->lock, flags);
> +
> +	return 0;
> +}
> +EXPORT_SYMBOL(irq_register_affinity_hint);

  EXPORT_SYMBOL_GPL please

> +static int irq_affinity_hint_proc_show(struct seq_file *m, void *v)
> +{
> +	struct irq_desc *desc = irq_to_desc((long)m->private);
> +	unsigned long flags;
> +	int ret = -EINVAL;
> +
> +	raw_spin_lock_irqsave(&desc->lock, flags);
> +	if (desc->affinity_hint) {
> +		seq_cpumask(m, desc->affinity_hint);

  Please make a local copy under desc->mask and do the seq_cpumask()
  stuff on the local copy outside of desc->lock

Thanks,

	tglx
