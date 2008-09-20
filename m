From: Daniel Walker <dwalker@mvista.com>
Subject: Re: [PATCH 2/2]: softirq: Add support for triggering softirq work
	on softirqs.
Date: Sat, 20 Sep 2008 08:43:33 -0700
Message-ID: <1221925413.1343.132.camel@localhost.localdomain>
References: <20080919.234832.127229997.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com, steffen.klassert@secunet.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway-1237.mvista.com ([63.81.120.158]:13245 "EHLO
	gateway-1237.mvista.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750713AbYITPnh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2008 11:43:37 -0400
In-Reply-To: <20080919.234832.127229997.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2008-09-19 at 23:48 -0700, David Miller wrote:

> @@ -6,6 +6,8 @@
>   *	Distribute under GPLv2.
>   *
>   *	Rewritten. Old one was good in 2.2, but in 2.3 it was immoral. --ANK (990903)
> + *
> + *	Remote softirq infrastructure is by Jens Axboe.
>   */

This goes in the GIT log so I hear, so you shouldn't need to add it to
the top.. It sounds like your saying Jens is the author, but I'm sure
you are..

>  #include <linux/module.h>
> @@ -463,17 +465,118 @@ void tasklet_kill(struct tasklet_struct *t)
>  
>  EXPORT_SYMBOL(tasklet_kill);
>  
> +DEFINE_PER_CPU(struct list_head, softirq_work_list[NR_SOFTIRQ]);
> +
> +static void __local_trigger(struct call_single_data *cp, int softirq)
> +{
> +	struct list_head *head = &__get_cpu_var(softirq_work_list[softirq]);
> +
> +	list_add_tail(&cp->list, head);
> +	if (head->next == &cp->list)
> +		raise_softirq_irqoff(softirq);
> +}

This list your adding is rather confusing .. You add to it, but never
remove anything.. You've got it in the header file, so you must use it
someplace else .. Then I don't see what else it could be used for other
than triggering the softirq..

> +#if defined(CONFIG_SMP) && defined(CONFIG_USE_GENERIC_SMP_HELPERS)

This whole patch really needs ifdefs. There's no value here on UP, since
what other cpu are you going to send softirqs to?

Daniel

