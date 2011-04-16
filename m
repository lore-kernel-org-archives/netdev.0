From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 1/3] irq: Add registered affinity guidance
 infrastructure
Date: Sat, 16 Apr 2011 02:22:58 +0200 (CEST)
Message-ID: <alpine.LFD.2.00.1104160144370.2744@localhost6.localdomain6>
References: <1302898677-3833-1-git-send-email-nhorman@tuxdriver.com> <1302898677-3833-2-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	nhorman <nhorman@devel2.think-freely.org>,
	Dimitris Michailidis <dm@chelsio.com>,
	David Howells <dhowells@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:56533 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752420Ab1DPAXF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2011 20:23:05 -0400
In-Reply-To: <1302898677-3833-2-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 15 Apr 2011, Neil Horman wrote:

> From: nhorman <nhorman@devel2.think-freely.org>
> 
> This patch adds the needed data to the irq_desc struct, as well as the needed
> API calls to allow the requester of an irq to register a handler function to
> determine the affinity_hint of that irq when queried from user space.

This changelog simply sucks. It does not explain the rationale for
this churn at all.

Which problem is it solving?
Why are the current interfaces not sufficient?
....

> +#ifdef CONFIG_AFFINITY_UPDATE
> +extern int setup_affinity_data(int irq, irq_affinity_init_t, void *);

yuck, irq_affinity_init_t ???  

> +#ifdef CONFIG_AFFINITY_UPDATE
> +static inline int __must_check
> +request_affinity_irq(unsigned int irq, irq_handler_t handler,
> +		     irq_handler_t thread_fn,
> +		     unsigned long flags, const char *name, void *dev,
> +		     irq_affinity_init_t af_init, void *af_priv)

So next time we make a wrapper around request_affinity_irq() which
takes another 3 arguments?

> +{
> +	int rc;
> +
> +	rc = request_threaded_irq(irq, handler, thread_fn, flags, name, dev);
> +	if (rc)
> +		goto out;

Brilliant use case for a goto. _NOT_

> +	if (af_init)
> +		rc = setup_affinity_data(irq, af_init, af_priv);
> +	if (rc)
> +		free_irq(irq, dev);
> +
> +out:
> +	return rc;
> +}
> +#else
> +#define request_affinity_irq(irq, hnd, tfn, flg, nm, dev, init, priv) \
> +	request_threaded_irq(irq, hnd, NULL, flg, nm, dev)

Oh nice. tfn becomes magically NULL if that magic CONFIG switch is not
set.

  
>  struct irq_desc;
>  struct irq_data;
> +struct affin_data {

Gah. Do you think that I went to major pain to consolidate the irq
namespace just to accecpt another random one?

Also that's completely undocumented. Hint: 

# grep -C1 "/\*\*" $this_file

> +	void *priv;
> +	char *affinity_alg;

const perhaps ?

> +	void (*affin_update)(int irq, struct affin_data *ad);
> +	void (*affin_cleanup)(int irq, struct affin_data *ad);
> +};
> +
> +typedef int (*irq_affinity_init_t)(int, struct affin_data*, void *);

Whee. Why do you want a typedef for that ?

> --- a/kernel/irq/Kconfig
> +++ b/kernel/irq/Kconfig
> @@ -51,6 +51,17 @@ config IRQ_PREFLOW_FASTEOI
>  config IRQ_FORCED_THREADING
>         bool
>  
> +config AFFINITY_UPDATE
> +	bool "Support irq affinity direction"
> +	depends on GENERIC_HARDIRQS

Right. We need a dependency for somthing which is inside of a guarded
section which selects GENERIC_HARDIRQS.

> +	---help---
> +
> +	Affinity updating adds the ability for requestors of irqs to
> +	register affinity update methods against the irq in question
> +	in so doing the requestor can be informed every time user space
> +	queries an irq for its optimal affinity, giving the requstor the
> +	chance to tell user space where the irq can be optimally handled

-ENOPARSE. I still do not understand what you are trying to solve.

> @@ -64,6 +75,5 @@ config SPARSE_IRQ
>  	    out the interrupt descriptors in a more NUMA-friendly way. )
>  
>  	  If you don't know what to do here, say N.
> -

Unrelated

>  endmenu
>  endif
> diff --git a/kernel/irq/manage.c b/kernel/irq/manage.c
> index acd599a..257ea4d 100644
> --- a/kernel/irq/manage.c
> +++ b/kernel/irq/manage.c
> @@ -1159,6 +1159,17 @@ static struct irqaction *__free_irq(unsigned int irq, void *dev_id)
>  
>  	unregister_handler_proc(irq, action);
>  
> +#ifdef CONFIG_AFFINITY_UPDATE
> +	/*
> +	 * Have to do this after we unregister proc accessors
> +	 */
> +	if (desc->af_data) {
> +		if (desc->af_data->affin_cleanup)
> +			desc->af_data->affin_cleanup(irq, desc->af_data);
> +		kfree(desc->af_data);
> +		desc->af_data = NULL;
> +	}
> +#endif

Grr. Aside of the fact, that I think that whole thing is silly and
overengineered, please move this out of line and keep your fricking
#ifdef mess out of the main code.

>  	/* Make sure it's not being used on another CPU: */
>  	synchronize_irq(irq);
>  
> @@ -1345,6 +1356,34 @@ int request_threaded_irq(unsigned int irq, irq_handler_t handler,
>  }
>  EXPORT_SYMBOL(request_threaded_irq);
>  
> +#ifdef CONFIG_AFFINITY_UPDATE
> +int setup_affinity_data(int irq, irq_affinity_init_t af_init, void *af_priv)

That interface is completely wrong for various reasons:

1) Namespace violation: irq_....

2) This want's to be separated into a allocation and a setter function

> +{
> +	struct affin_data *data;
> +	struct irq_desc *desc;
> +	int rc;
> +
> +	desc = irq_to_desc(irq);
> +	if (!desc)
> +		return -ENOENT;
> +
> +	data = kzalloc(sizeof(struct affin_data), GFP_KERNEL);
> +	if (!data)
> +		return -ENOMEM;
> +
> +	rc = af_init(irq, data, af_priv);
> +	if (rc) {
> +		kfree(data);
> +		return rc;
> +	}
> +
> +	desc->af_data = data;

Right, we do this unlocked of course.

> +	return 0;
> +}
> +EXPORT_SYMBOL(setup_affinity_data);

No. That want's to be EXPORT_SYMBOL_GPL if at all.

> --- a/kernel/irq/proc.c
> +++ b/kernel/irq/proc.c
> @@ -42,6 +42,11 @@ static int irq_affinity_hint_proc_show(struct seq_file *m, void *v)
>  	if (!zalloc_cpumask_var(&mask, GFP_KERNEL))
>  		return -ENOMEM;
>  
> +#ifdef CONFIG_AFFINITY_UPDATE
> +	if (desc->af_data && desc->af_data->affin_update)
> +		desc->af_data->affin_update((long)m->private, desc->af_data);
> +#endif
> +

Yikes. How the hell is this related to the changelog and to the scope
of this function? 

This function shows the hint we agreed on and nothing else. We do not
call magic crap via proc.

Locking is not your favourite topic, right ?

>  	raw_spin_lock_irqsave(&desc->lock, flags);
>  	if (desc->affinity_hint)
>  		cpumask_copy(mask, desc->affinity_hint);
> @@ -54,6 +59,19 @@ static int irq_affinity_hint_proc_show(struct seq_file *m, void *v)
>  	return 0;
>  }
>  
> +static int irq_affinity_alg_proc_show(struct seq_file *m, void *v)
> +{
> +	char *alg = "none";
> +#ifdef CONFIG_AFFINITY_UPDATE
> +	struct irq_desc *desc = irq_to_desc((long)m->private);
> +
> +	if (desc->af_data->affinity_alg)
> +		alg = desc->af_data->affinity_alg;
> +#endif

Nice, we add the policy concept to the kernel another time. No, we
don't want policies in the kernel except there is some reasonable
explanation.

Thanks,

	tglx
