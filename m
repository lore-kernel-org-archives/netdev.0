From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] softirq: Fix warnings triggered by netconsole
Date: Wed, 19 Nov 2008 10:32:24 +0100
Message-ID: <20081119093224.GE22309@elte.hu>
References: <87y6zwwy5c.fsf@tac.ki.iif.hu> <20081119084125.GB6699@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes@sipsolutions.net>,
	David Miller <davem@davemloft.net>,
	Ferenc Wagner <wferi@niif.hu>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:48387 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752524AbYKSJci (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Nov 2008 04:32:38 -0500
Content-Disposition: inline
In-Reply-To: <20081119084125.GB6699@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Jarek Poplawski <jarkao2@gmail.com> wrote:

> Consider netconsole case as special in local_bh_enable()/_disable().
> This patch skips in_irq() and irqs_disabled() warnings for NETPOLL
> configs when it's safe wrt. do_softirq().
> 
> Reported-by: Ferenc Wagner <wferi@niif.hu>
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
> ---
> [apply on top of my first softirq patch in this thread]
> 
> diff -Nurp a/kernel/softirq.c b/kernel/softirq.c
> --- a/kernel/softirq.c	2008-11-19 07:33:23.000000000 +0000
> +++ b/kernel/softirq.c	2008-11-19 07:26:28.000000000 +0000
> @@ -76,7 +76,12 @@ static void __local_bh_disable(unsigned 
>  {
>  	unsigned long flags;
>  
> +#ifdef CONFIG_NETPOLL
> +	if (!softirq_count())
> +		WARN_ON_ONCE(in_irq());
> +#else
>  	WARN_ON_ONCE(in_irq());
> +#endif
>  
>  	raw_local_irq_save(flags);
>  	add_preempt_count(SOFTIRQ_OFFSET);
> @@ -138,7 +143,16 @@ static inline void _local_bh_enable_ip(u
>  #ifdef CONFIG_TRACE_IRQFLAGS
>  	unsigned long flags;
>  #endif
> +#ifdef CONFIG_NETPOLL
> +	/*
> +	 * Special-case - netconsole runs network code with all interrupts
> +	 * disabled. Warn only if it can be really dangerous:
> +	 */
> +	if (softirq_count() == SOFTIRQ_OFFSET)
> +		WARN_ON_ONCE(in_irq() || irqs_disabled());
> +#else
>  	WARN_ON_ONCE(in_irq() || irqs_disabled());
> +#endif
>  #ifdef CONFIG_TRACE_IRQFLAGS
>  	local_irq_save(flags);
>  #endif

this is a very ugly patch, not really acceptable.

printk methods should not be doing softirq processing - period.

	Ingo
