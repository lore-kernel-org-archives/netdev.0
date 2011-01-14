From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 1/2] genirq: Add IRQ affinity notifiers
Date: Fri, 14 Jan 2011 20:47:23 +0100 (CET)
Message-ID: <alpine.LFD.2.00.1101141928210.2678@localhost6.localdomain6>
References: <1294169842.3636.31.camel@bwh-desktop> <1294169919.3636.33.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.tglx.de ([62.245.132.106]:48198 "EHLO www.tglx.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751490Ab1ANTrj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Jan 2011 14:47:39 -0500
In-Reply-To: <1294169919.3636.33.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 4 Jan 2011, Ben Hutchings wrote:
> +/**
> + * struct irq_affinity_notify - context for notification of IRQ affinity changes
> + * @irq:		Interrupt to which notification applies
> + * @kref:		Reference count, for internal use
> + * @work:		Work item, for internal use
> + * @notify:		Function to be called on change.  This will be
> + *			called in process context.
> + * @release:		Function to be called on release.  This will be
> + *			called in process context.  Once registered, the
> + *			structure must only be freed when this function is
> + *			called or later.
> + */
> +struct irq_affinity_notify {
> +        unsigned int irq;
> +        struct kref kref;
> +#if defined(CONFIG_SMP) && defined(CONFIG_GENERIC_HARDIRQS)

The whole affinity thing is SMP and GENERIC_HARDIRQS only anyway, so
what's the point of this ifdeffery ?

> +        struct work_struct work;
> +#endif
> +        void (*notify)(struct irq_affinity_notify *, const cpumask_t *mask);
> +        void (*release)(struct kref *ref);
> +};
> +

> +/**
> + *	irq_set_affinity_notifier - control notification of IRQ affinity changes
> + *	@irq:		Interrupt for which to enable/disable notification
> + *	@notify:	Context for notification, or %NULL to disable
> + *			notification.  Function pointers must be initialised;
> + *			the other fields will be initialised by this function.
> + *
> + *	Must be called in process context.  Notification may only be enabled
> + *	after the IRQ is allocated but before it is bound with request_irq()

Why? And if there is that restriction, then it needs to be
checked. But I don't see why this is necessary.

> + *	and must be disabled before the IRQ is freed using free_irq().
> + */

> +#ifdef CONFIG_SMP
> +	BUG_ON(desc->affinity_notify);

We should be nice here and just WARN and fixup the wreckage by
uninstalling it.

Thanks,

	tglx
