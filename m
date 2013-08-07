From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [RFC PATCHv2 1/3] hrtimer: Add notifer for clock_was_set
Date: Wed, 07 Aug 2013 11:20:55 +0200
Message-ID: <52021177.6020306@redhat.com>
References: <1375866296-15079-1-git-send-email-fan.du@windriver.com> <1375866296-15079-2-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, davem@davemloft.net,
	herbert@gondor.hengli.com.au, netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47431 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756494Ab3HGJVR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Aug 2013 05:21:17 -0400
In-Reply-To: <1375866296-15079-2-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/07/2013 11:04 AM, Fan Du wrote:
> When clock_was_set is called in case of system wall time change
> or host resume from suspend state, use this notifier for places
> where interested in this action.

(Only minor commenting on this one ...)

> Signed-off-by: Fan Du <fan.du@windriver.com>
> ---
>   kernel/hrtimer.c |    4 ++++
>   1 file changed, 4 insertions(+)
>
> diff --git a/kernel/hrtimer.c b/kernel/hrtimer.c
> index 383319b..b7c62a9 100644
> --- a/kernel/hrtimer.c
> +++ b/kernel/hrtimer.c
> @@ -755,6 +755,9 @@ static inline void retrigger_next_event(void *arg) { }
>
>   #endif /* CONFIG_HIGH_RES_TIMERS */
>
> +ATOMIC_NOTIFIER_HEAD(clock_change_notifier_list);
> +EXPORT_SYMBOL(clock_change_notifier_list);

This should be static and hidden from other modules, e.g. have a look at
netevent_notif_chain (net/core/netevent.c).

Instead, this should be accessed via registration/un-registration handlers
for notifier blocks, and those can then be exported as EXPORT_SYMBOL_GPL
as this is core area.

> +
>   /*
>    * Clock realtime was set
>    *
> @@ -773,6 +776,7 @@ void clock_was_set(void)
>   	on_each_cpu(retrigger_next_event, NULL, 1);
>   #endif
>   	timerfd_clock_was_set();
> +	atomic_notifier_call_chain(&clock_change_notifier_list, 0, 0);

Also here a small one-line handler call_clock_change_notifiers() would be
better.

>   }
>
>   /*
>
