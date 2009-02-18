From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [patch] timers: add mod_timer_pending()
Date: Wed, 18 Feb 2009 19:23:11 +0100
Message-ID: <20090218182311.GC26802@elte.hu>
References: <20090218051906.174295181@vyatta.com> <20090218052747.437271195@vyatta.com> <20090218092041.GC3294@elte.hu> <499BDDFE.5010101@trash.net> <20090218120508.GB4100@elte.hu> <20090218170057.GA28825@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	Rick Jones <rick.jones2@hp.com>,
	Eric Dumazet <dada1@cosmosbay.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, tglx@linutronix.de,
	Martin Josefsson <gandalf@wlug.westbo.se>
To: Oleg Nesterov <oleg@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:56525 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753307AbZBRSXh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Feb 2009 13:23:37 -0500
Content-Disposition: inline
In-Reply-To: <20090218170057.GA28825@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Oleg Nesterov <oleg@redhat.com> wrote:

> On 02/18, Ingo Molnar wrote:
> >
> > Based on an idea from Stephen Hemminger: introduce
> >  mod_timer_pending() which is a mod_timer() offspring
> > that is an invariant on already removed timers.
> 
> This also can be used by workqueues, see
> 
> 	http://marc.info/?l=linux-kernel&m=122209752020413
> 
> but can't we add another helper? Because,
> 
> > +static inline int
> > +__mod_timer(struct timer_list *timer, unsigned long expires, bool pending_only)
> >  {
> >  	struct tvec_base *base, *new_base;
> >  	unsigned long flags;
> > -	int ret = 0;
> > +	int ret;
> > +
> > +	ret = 0;
> >
> >  	timer_stats_timer_set_start_info(timer);
> >  	BUG_ON(!timer->function);
> > @@ -614,6 +617,9 @@ int __mod_timer(struct timer_list *timer
> >  	if (timer_pending(timer)) {
> >  		detach_timer(timer, 0);
> >  		ret = 1;
> > +	} else {
> > +		if (pending_only)
> > +			goto out_unlock;
> 
> This can change the base (CPU) of the pending timer.
> 
> How about
> 
> 	int __update_timer(struct timer_list *timer, unsigned long expires)
> 	{
> 		struct tvec_base *base;
> 		unsigned long flags;
> 		int ret = 0;
> 
> 		base = lock_timer_base(timer, &flags);
> 		if (timer_pending(timer)) {
> 			detach_timer(timer, 0);
> 			timer->expires = expires;
> 			internal_add_timer(base, timer);
> 			ret = 1;
> 		}
> 		spin_unlock_irqrestore(&base->lock, flags);
> 
> 		return ret;
> 	}
> 
> ?
> 
> Unlike __mod_timer(..., bool pending_only), it preserves the CPU on
> which the timer is pending.
> 
> Or, perhaps, we can modify __mod_timer() further,
> 
> 	static inline int
> 	__mod_timer(struct timer_list *timer, unsigned long expires, bool pending_only)
> 	{
> 		struct tvec_base *base;
> 		unsigned long flags;
> 		int ret;
> 
> 		ret = 0;
> 
> 		timer_stats_timer_set_start_info(timer);
> 		BUG_ON(!timer->function);
> 
> 		base = lock_timer_base(timer, &flags);
> 
> 		if (timer_pending(timer)) {
> 			detach_timer(timer, 0);
> 			ret = 1;
> 		} else if (pending_only)
> 			goto out_unlock;
> 		}
> 
> 		debug_timer_activate(timer);
> 
> 		if (!pending_only) {
> 			struct tvec_base *new_base = __get_cpu_var(tvec_bases);
> 
> 			if (base != new_base) {
> 				/*
> 				 * We are trying to schedule the timer on the local CPU.
> 				 * However we can't change timer's base while it is running,
> 				 * otherwise del_timer_sync() can't detect that the timer's
> 				 * handler yet has not finished. This also guarantees that
> 				 * the timer is serialized wrt itself.
> 				 */
> 				if (likely(base->running_timer != timer)) {
> 					/* See the comment in lock_timer_base() */
> 					timer_set_base(timer, NULL);
> 					spin_unlock(&base->lock);
> 					base = new_base;
> 					spin_lock(&base->lock);
> 					timer_set_base(timer, base);
> 				}
> 			}
> 		}
> 
> 		timer->expires = expires;
> 		internal_add_timer(base, timer);
> 
> 	out_unlock:
> 		spin_unlock_irqrestore(&base->lock, flags);
> 
> 		return ret;
> 	}
> 
> What do you all think?

if then i'd put it into a separate commit.

I think the auto-migration of all the mod_timer() variants is a 
scalability feature: if for example a networking socket's main 
user migrates to another CPU, then the timer 'follows' it - even 
if the timer never actually expires (which is quite common for 
high-speed high-reliability networking transports).

By keeping it on the same CPU we'd allow the timer's and the 
task's affinity to differ.

Agreed?

	Ingo
