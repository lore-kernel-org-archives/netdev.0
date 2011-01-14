From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/2] genirq: Add IRQ affinity notifiers
Date: Fri, 14 Jan 2011 20:06:37 +0000
Message-ID: <1295035597.5386.8.camel@bwh-desktop>
References: <1294169842.3636.31.camel@bwh-desktop>
	 <1294169919.3636.33.camel@bwh-desktop>
	 <alpine.LFD.2.00.1101141928210.2678@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.1101141928210.2678@localhost6.localdomain6>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2011-01-14 at 20:47 +0100, Thomas Gleixner wrote:
> On Tue, 4 Jan 2011, Ben Hutchings wrote:
> > +/**
> > + * struct irq_affinity_notify - context for notification of IRQ affinity changes
> > + * @irq:		Interrupt to which notification applies
> > + * @kref:		Reference count, for internal use
> > + * @work:		Work item, for internal use
> > + * @notify:		Function to be called on change.  This will be
> > + *			called in process context.
> > + * @release:		Function to be called on release.  This will be
> > + *			called in process context.  Once registered, the
> > + *			structure must only be freed when this function is
> > + *			called or later.
> > + */
> > +struct irq_affinity_notify {
> > +        unsigned int irq;
> > +        struct kref kref;
> > +#if defined(CONFIG_SMP) && defined(CONFIG_GENERIC_HARDIRQS)
> 
> The whole affinity thing is SMP and GENERIC_HARDIRQS only anyway, so
> what's the point of this ifdeffery ?

The intent is that code using this can be compiled even if those config
options are not set.  The work_struct is not needed in that case.  I
think this is probably pointless though.

> > +        struct work_struct work;
> > +#endif
> > +        void (*notify)(struct irq_affinity_notify *, const cpumask_t *mask);
> > +        void (*release)(struct kref *ref);
> > +};
> > +
> 
> > +/**
> > + *	irq_set_affinity_notifier - control notification of IRQ affinity changes
> > + *	@irq:		Interrupt for which to enable/disable notification
> > + *	@notify:	Context for notification, or %NULL to disable
> > + *			notification.  Function pointers must be initialised;
> > + *			the other fields will be initialised by this function.
> > + *
> > + *	Must be called in process context.  Notification may only be enabled
> > + *	after the IRQ is allocated but before it is bound with request_irq()
> 
> Why? And if there is that restriction, then it needs to be
> checked. But I don't see why this is necessary.

Which restriction?

> > + *	and must be disabled before the IRQ is freed using free_irq().
> > + */
> 
> > +#ifdef CONFIG_SMP
> > +	BUG_ON(desc->affinity_notify);
> 
> We should be nice here and just WARN and fixup the wreckage by
> uninstalling it.

OK.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
