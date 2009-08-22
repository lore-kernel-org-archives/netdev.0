From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 2/2]: pkt_sched: Convert CBQ to tasklet_hrtimer.
Date: Sat, 22 Aug 2009 11:17:53 +0200 (CEST)
Message-ID: <alpine.LFD.2.00.0908221041290.1769@localhost.localdomain>
References: <20090821.170333.153413841.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.tglx.de ([62.245.132.106]:33906 "EHLO www.tglx.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753893AbZHVJR7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Aug 2009 05:17:59 -0400
In-Reply-To: <20090821.170333.153413841.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 21 Aug 2009, David Miller wrote:
> This code expects to run in softirq context, and bare hrtimers
> run in hw IRQ context.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>

> @@ -510,12 +512,12 @@ static void cbq_ovl_delay(struct cbq_class *cl)
>  
>  			expires = ktime_set(0, 0);
>  			expires = ktime_add_ns(expires, PSCHED_TICKS2NS(sched));
> -			if (hrtimer_try_to_cancel(&q->delay_timer) &&
> -			    ktime_to_ns(ktime_sub(
> -					hrtimer_get_expires(&q->delay_timer),
> -					expires)) > 0)
> -				hrtimer_set_expires(&q->delay_timer, expires);
> -			hrtimer_restart(&q->delay_timer);
> +			ht = &q->delay_timer.timer;
> +			if (hrtimer_try_to_cancel(ht) &&
> +			    ktime_to_ns(ktime_sub(hrtimer_get_expires(ht),
> +						  expires)) > 0)
> +				hrtimer_set_expires(ht, expires);
> +			hrtimer_restart(ht);

This code looks still wrong. The new expiry time is only set when the
timer is already active. If the timer is not active then you restart
it with the last stale expiry time which is probably in the past, but
might be somewhere in the future as well. I doubt that this is the
intention.

So what you really want is:
 
 			cl->cpriority = TC_CBQ_MAXPRIO;
 			q->pmask |= (1<<TC_CBQ_MAXPRIO);
 
-			expires = ktime_set(0, 0);
-			expires = ktime_add_ns(expires, PSCHED_TICKS2NS(sched));
-			if (hrtimer_try_to_cancel(&q->delay_timer) &&
-			    ktime_to_ns(ktime_sub(
-					hrtimer_get_expires(&q->delay_timer),
-					expires)) > 0)
-				hrtimer_set_expires(&q->delay_timer, expires);
-			hrtimer_restart(&q->delay_timer);
+			ht = &q->delay_timer.timer;
+			expires = ns_to_ktime(PSCHED_TICKS2NS(sched));
+			if (!hrtimer_active(ht) ||
+			    expires.tv64 < hrtimer_get_expires(ht).tv64)
+				hrtimer_start(ht, expires, HRTIMER_MODE_ABS);
 			cl->delayed = 1;
 			cl->xstats.overactions++;
 			return;

This starts the timer when

     1) the timer is not active

     2) the timer is active and the new expiry time is before the
     	current one. (hrtimer_start takes care of stopping the active
     	timer)

Thanks,

	tglx
