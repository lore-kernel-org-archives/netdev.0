From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 1/2]: pkt_sched: Convert qdisc_watchdog to tasklet_hrtimer
Date: Sat, 22 Aug 2009 14:04:31 +0200
Message-ID: <4A8FDECF.3040601@gmail.com>
References: <20090821.170330.217935645.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tglx@linutronix.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f217.google.com ([209.85.220.217]:41055 "EHLO
	mail-fx0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755779AbZHVMEl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Aug 2009 08:04:41 -0400
Received: by fxm17 with SMTP id 17so821071fxm.37
        for <netdev@vger.kernel.org>; Sat, 22 Aug 2009 05:04:42 -0700 (PDT)
In-Reply-To: <20090821.170330.217935645.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote, On 08/22/2009 02:03 AM:

> None of this stuff should execute in hw IRQ context, therefore
> use a tasklet_hrtimer so that it runs in softirq context.


Do you mean __netif_schedule()? Could you explain it more?

Thanks,
Jarek P.

> 
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  include/net/pkt_sched.h |    4 ++--
>  net/sched/sch_api.c     |    8 ++++----
>  2 files changed, 6 insertions(+), 6 deletions(-)
> 
> diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
> index 82a3191..7eafb8d 100644
> --- a/include/net/pkt_sched.h
> +++ b/include/net/pkt_sched.h
> @@ -61,8 +61,8 @@ psched_tdiff_bounded(psched_time_t tv1, psched_time_t tv2, psched_time_t bound)
>  }
>  
>  struct qdisc_watchdog {
> -	struct hrtimer	timer;
> -	struct Qdisc	*qdisc;
> +	struct tasklet_hrtimer	timer;
> +	struct Qdisc		*qdisc;
>  };
>  
>  extern void qdisc_watchdog_init(struct qdisc_watchdog *wd, struct Qdisc *qdisc);
> diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
> index 24d17ce..e1c2bf7 100644
> --- a/net/sched/sch_api.c
> +++ b/net/sched/sch_api.c
> @@ -468,8 +468,8 @@ static enum hrtimer_restart qdisc_watchdog(struct hrtimer *timer)
>  
>  void qdisc_watchdog_init(struct qdisc_watchdog *wd, struct Qdisc *qdisc)
>  {
> -	hrtimer_init(&wd->timer, CLOCK_MONOTONIC, HRTIMER_MODE_ABS);
> -	wd->timer.function = qdisc_watchdog;
> +	tasklet_hrtimer_init(&wd->timer, qdisc_watchdog,
> +			     CLOCK_MONOTONIC, HRTIMER_MODE_ABS);
>  	wd->qdisc = qdisc;
>  }
>  EXPORT_SYMBOL(qdisc_watchdog_init);
> @@ -485,13 +485,13 @@ void qdisc_watchdog_schedule(struct qdisc_watchdog *wd, psched_time_t expires)
>  	wd->qdisc->flags |= TCQ_F_THROTTLED;
>  	time = ktime_set(0, 0);
>  	time = ktime_add_ns(time, PSCHED_TICKS2NS(expires));
> -	hrtimer_start(&wd->timer, time, HRTIMER_MODE_ABS);
> +	tasklet_hrtimer_start(&wd->timer, time, HRTIMER_MODE_ABS);
>  }
>  EXPORT_SYMBOL(qdisc_watchdog_schedule);
>  
>  void qdisc_watchdog_cancel(struct qdisc_watchdog *wd)
>  {
> -	hrtimer_cancel(&wd->timer);
> +	tasklet_hrtimer_cancel(&wd->timer);
>  	wd->qdisc->flags &= ~TCQ_F_THROTTLED;
>  }
>  EXPORT_SYMBOL(qdisc_watchdog_cancel);


