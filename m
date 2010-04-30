From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH linux-next v3 1/2] irq: Add CPU mask affinity hint
Date: Fri, 30 Apr 2010 22:02:25 +0100
Message-ID: <1272661345.2110.28.camel@achroite.uk.solarflarecom.com>
References: <20100430202343.4591.66240.stgit@ppwaskie-hc2.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: tglx@linutronix.de, davem@davemloft.net, arjan@linux.jf.intel.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100430202343.4591.66240.stgit@ppwaskie-hc2.jf.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2010-04-30 at 13:23 -0700, Peter P Waskiewicz Jr wrote:
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
[...]
> diff --git a/kernel/irq/manage.c b/kernel/irq/manage.c
> index 704e488..1354fc9 100644
> --- a/kernel/irq/manage.c
> +++ b/kernel/irq/manage.c
> @@ -138,6 +138,22 @@ int irq_set_affinity(unsigned int irq, const struct cpumask *cpumask)
>  	return 0;
>  }
>  
> +int irq_register_affinity_hint(unsigned int irq, const struct cpumask *m)
> +{
> +	struct irq_desc *desc = irq_to_desc(irq);
> +	unsigned long flags;
> +
> +	if (!desc)
> +		return -EINVAL;

Is it possible for irq_to_desc(irq) to be NULL?  This function already
assumes that the caller 'owns' the IRQ.

> +	raw_spin_lock_irqsave(&desc->lock, flags);
> +	desc->affinity_hint = m;
> +	raw_spin_unlock_irqrestore(&desc->lock, flags);
> +
> +	return 0;
> +}
[...]
> diff --git a/kernel/irq/proc.c b/kernel/irq/proc.c
> index 7a6eb04..1aa7939 100644
> --- a/kernel/irq/proc.c
> +++ b/kernel/irq/proc.c
> @@ -32,6 +32,32 @@ static int irq_affinity_proc_show(struct seq_file *m, void *v)
>  	return 0;
>  }
>  
> +static int irq_affinity_hint_proc_show(struct seq_file *m, void *v)
> +{
> +	struct irq_desc *desc = irq_to_desc((long)m->private);
> +	unsigned long flags;
> +	cpumask_var_t mask;
> +	int ret = -EINVAL;
> +
> +	if (!alloc_cpumask_var(&mask, GFP_KERNEL))
> +		return -ENOMEM;
> +
> +	raw_spin_lock_irqsave(&desc->lock, flags);
> +	if (desc->affinity_hint) {
> +		cpumask_copy(mask, desc->affinity_hint);
> +		ret = 0;
> +	}
> +	raw_spin_unlock_irqrestore(&desc->lock, flags);
> +
> +	if (!ret) {
> +		seq_cpumask(m, mask);
> +		seq_putc(m, '\n');
> +	}
> +	free_cpumask_var(mask);
> +
> +	return ret;
> +}
[...]

I don't think this should be returning -EINVAL if the affinity hint is
missing.  That means 'invalid argument', but there is nothing invalid
about trying to read() the corresponding file.  The file should simply
be empty if there is no hint.  (Actually it might be better if it didn't
appear at all, but that would be a pain to implement.)

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
