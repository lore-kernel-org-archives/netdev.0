From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v4 1/5] irq: add tracepoint to softirq_raise
Date: Fri, 03 Sep 2010 11:43:12 -0400
Message-ID: <1283528592.2356.439.camel@gandalf.stny.rr.com>
References: <4C72422C.5070102@jp.fujitsu.com>
	 <4C724298.4050509@jp.fujitsu.com>  <20100903152909.GA5352@nowhere>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Koki Sanagi <sanagi.koki@jp.fujitsu.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	kaneshige.kenji@jp.fujitsu.com, izumi.taku@jp.fujitsu.com,
	kosaki.motohiro@jp.fujitsu.com, nhorman@tuxdriver.com,
	laijs@cn.fujitsu.com, scott.a.mcmillan@intel.com,
	eric.dumazet@gmail.com, mathieu.desnoyers@polymtl.ca
To: Frederic Weisbecker <fweisbec@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hrndva-omtalb.mail.rr.com ([71.74.56.125]:37436 "EHLO
	hrndva-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752593Ab0ICPnS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Sep 2010 11:43:18 -0400
In-Reply-To: <20100903152909.GA5352@nowhere>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-09-03 at 17:29 +0200, Frederic Weisbecker wrote:

> >  /*
> >   * These correspond to the IORESOURCE_IRQ_* defines in
> > @@ -407,7 +408,12 @@ asmlinkage void do_softirq(void);
> >  asmlinkage void __do_softirq(void);
> >  extern void open_softirq(int nr, void (*action)(struct softirq_action *));
> >  extern void softirq_init(void);
> > -#define __raise_softirq_irqoff(nr) do { or_softirq_pending(1UL << (nr)); } while (0)
> > +static inline void __raise_softirq_irqoff(unsigned int nr)
> > +{
> > +	trace_softirq_raise((struct softirq_action *)&nr, NULL);

Perhaps doing:

	trace_softirq_raise((struct softirq_action *)((unsigend long)nr),
				NULL);

and ...

> > +	or_softirq_pending(1UL << nr);
> > +}
> > +
> >  extern void raise_softirq_irqoff(unsigned int nr);
> >  extern void raise_softirq(unsigned int nr);
> >  extern void wakeup_softirqd(void);
> > diff --git a/include/trace/events/irq.h b/include/trace/events/irq.h
> > index 0e4cfb6..3ddda02 100644
> > --- a/include/trace/events/irq.h
> > +++ b/include/trace/events/irq.h
> > @@ -5,7 +5,9 @@
> >  #define _TRACE_IRQ_H
> >  
> >  #include <linux/tracepoint.h>
> > -#include <linux/interrupt.h>
> > +
> > +struct irqaction;
> > +struct softirq_action;
> >  
> >  #define softirq_name(sirq) { sirq##_SOFTIRQ, #sirq }
> >  #define show_softirq_name(val)				\
> > @@ -93,7 +95,10 @@ DECLARE_EVENT_CLASS(softirq,
> >  	),
> >  
> >  	TP_fast_assign(
> > -		__entry->vec = (int)(h - vec);
> > +		if (vec)
> > +			__entry->vec = (int)(h - vec);
> > +		else
> > +			__entry->vec = *((int *)h);

			__entry->vec = (int)h;

would be better.


> >  	),
> 
> 
> 
> It seems that this will break softirq_entry/exit tracepoints.
> __entry->vec will deref vec->action() for these two, which is not
> what we want.
> 
> If you can't have the same tracepoint signature for the three, just
> split the new one in a seperate TRACE_EVENT().

Doing the above will at least be a bit safer.

-- Steve


