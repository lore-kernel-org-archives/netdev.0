From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] softirq: Fix warnings triggered by netconsole
Date: Wed, 19 Nov 2008 11:07:48 +0000
Message-ID: <20081119110748.GA7557@ff.dom.local>
References: <87y6zwwy5c.fsf@tac.ki.iif.hu> <20081119084125.GB6699@ff.dom.local> <20081119093224.GE22309@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes@sipsolutions.net>,
	David Miller <davem@davemloft.net>,
	Ferenc Wagner <wferi@niif.hu>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.183]:28525 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751573AbYKSLH6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2008 06:07:58 -0500
Received: by ik-out-1112.google.com with SMTP id c29so1582411ika.5
        for <netdev@vger.kernel.org>; Wed, 19 Nov 2008 03:07:55 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20081119093224.GE22309@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 19, 2008 at 10:32:24AM +0100, Ingo Molnar wrote:
> 
> * Jarek Poplawski <jarkao2@gmail.com> wrote:
> 
> > Consider netconsole case as special in local_bh_enable()/_disable().
> > This patch skips in_irq() and irqs_disabled() warnings for NETPOLL
> > configs when it's safe wrt. do_softirq().
> > 
> > Reported-by: Ferenc Wagner <wferi@niif.hu>
> > Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
> > ---
> > [apply on top of my first softirq patch in this thread]
> > 
> > diff -Nurp a/kernel/softirq.c b/kernel/softirq.c
> > --- a/kernel/softirq.c	2008-11-19 07:33:23.000000000 +0000
> > +++ b/kernel/softirq.c	2008-11-19 07:26:28.000000000 +0000
> > @@ -76,7 +76,12 @@ static void __local_bh_disable(unsigned 
> >  {
> >  	unsigned long flags;
> >  
> > +#ifdef CONFIG_NETPOLL
> > +	if (!softirq_count())
> > +		WARN_ON_ONCE(in_irq());
> > +#else
> >  	WARN_ON_ONCE(in_irq());
> > +#endif
> >  
> >  	raw_local_irq_save(flags);
> >  	add_preempt_count(SOFTIRQ_OFFSET);
> > @@ -138,7 +143,16 @@ static inline void _local_bh_enable_ip(u
> >  #ifdef CONFIG_TRACE_IRQFLAGS
> >  	unsigned long flags;
> >  #endif
> > +#ifdef CONFIG_NETPOLL
> > +	/*
> > +	 * Special-case - netconsole runs network code with all interrupts
> > +	 * disabled. Warn only if it can be really dangerous:
> > +	 */
> > +	if (softirq_count() == SOFTIRQ_OFFSET)
> > +		WARN_ON_ONCE(in_irq() || irqs_disabled());
> > +#else
> >  	WARN_ON_ONCE(in_irq() || irqs_disabled());
> > +#endif
> >  #ifdef CONFIG_TRACE_IRQFLAGS
> >  	local_irq_save(flags);
> >  #endif
> 
> this is a very ugly patch, not really acceptable.

Well, it's a question of taste. Anyway, this patch is only about
warnings, so no big deal. But I still think the first patch reverting
local_irq_save() -> local_irq_disable() change should be applied.
There is no need to give users any additional lockups risk while we
know there are unsolved issues.

BTW, the current situation with: local_irq_disable() in
_local_bh_enable() and local_irq_save() in do_softirq() doesn't make
much sense. I know, there is local_irq_disable() in __do_softirq()
again, but it can be often skipped on this path because of
in_interrupt() test (and there is soon this local_irq_restore()
in do_softirq()).

Jarek P.
