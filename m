From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [RFT 2/4] Add mod_timer_noact
Date: Wed, 18 Feb 2009 10:20:41 +0100
Message-ID: <20090218092041.GC3294@elte.hu>
References: <20090218051906.174295181@vyatta.com> <20090218052747.437271195@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Rick Jones <rick.jones2@hp.com>,
	Eric Dumazet <dada1@cosmosbay.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, tglx@linutronix.de,
	Martin Josefsson <gandalf@wlug.westbo.se>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:60771 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752892AbZBRJU4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Feb 2009 04:20:56 -0500
Content-Disposition: inline
In-Reply-To: <20090218052747.437271195@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Stephen Hemminger <shemminger@vyatta.com> wrote:

> Introduce mod_timer_noact() which for example is to replace the calls to
> del_timer()/add_timer() in __nf_ct_refresh_acct(). It works like mod_timer()
> but doesn't activate or modify the timeout of an inactive timer which is the
> behaviour we want in order to be able to use timers as a means of
> synchronization in nf_conntrack.
> 
> A later patch will modify __nf_ct_refresh_acct() to use mod_timer_noact()
> which will then save one spin_lock_irqsave() / spin_lock_irqrestore() pair per
> conntrack timer update. This will also get rid of the race we currently have
> without adding more locking in nf_conntrack.
> 
> Signed-off-by: Martin Josefsson <gandalf@wlug.westbo.se>
> 
> ---
>  include/linux/timer.h |    8 ++++++--
>  kernel/relay.c        |    2 +-
>  kernel/timer.c        |   40 +++++++++++++++++++++++++++++++++++-----
>  3 files changed, 42 insertions(+), 8 deletions(-)
> 
> --- a/include/linux/timer.h	2009-02-17 10:55:33.427785986 -0800
> +++ b/include/linux/timer.h	2009-02-17 11:04:10.291844534 -0800
> @@ -25,6 +25,9 @@ struct timer_list {
>  
>  extern struct tvec_base boot_tvec_bases;
>  
> +#define TIMER_ACT	1
> +#define TIMER_NOACT	0

Ugly flaggery.

> -extern int __mod_timer(struct timer_list *timer, unsigned long expires);
> +extern int __mod_timer(struct timer_list *timer, unsigned long expires, int activate);

This is not really acceptable, it slows down every single 
add_timer() and mod_timer() call in the kernel with a flag that 
has one specific value in all but your case. There's more than 
2000 such callsites in the kernel.

Why dont you use something like this instead:

	if (del_timer(timer))
		add_timer(timer);

?

	Ingo
