From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 2/2]: pkt_sched: Convert CBQ to tasklet_hrtimer.
Date: Sun, 23 Aug 2009 09:22:48 +0200 (CEST)
Message-ID: <alpine.LFD.2.00.0908230919420.1769@localhost.localdomain>
References: <20090821.170333.153413841.davem@davemloft.net> <alpine.LFD.2.00.0908221041290.1769@localhost.localdomain> <20090822.180836.34851176.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.tglx.de ([62.245.132.106]:42999 "EHLO www.tglx.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752684AbZHWHW4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Aug 2009 03:22:56 -0400
In-Reply-To: <20090822.180836.34851176.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

B1;2005;0cOn Sat, 22 Aug 2009, David Miller wrote:
> From: Thomas Gleixner <tglx@linutronix.de>
> Date: Sat, 22 Aug 2009 11:17:53 +0200 (CEST)
> 
> > On Fri, 21 Aug 2009, David Miller wrote:
> >> This code expects to run in softirq context, and bare hrtimers
> >> run in hw IRQ context.
> >> 
> >> Signed-off-by: David S. Miller <davem@davemloft.net>
> > 
> >> @@ -510,12 +512,12 @@ static void cbq_ovl_delay(struct cbq_class *cl)
> >>  
> >>  			expires = ktime_set(0, 0);
> >>  			expires = ktime_add_ns(expires, PSCHED_TICKS2NS(sched));
> >> -			if (hrtimer_try_to_cancel(&q->delay_timer) &&
> >> -			    ktime_to_ns(ktime_sub(
> >> -					hrtimer_get_expires(&q->delay_timer),
> >> -					expires)) > 0)
> >> -				hrtimer_set_expires(&q->delay_timer, expires);
> >> -			hrtimer_restart(&q->delay_timer);
> >> +			ht = &q->delay_timer.timer;
> >> +			if (hrtimer_try_to_cancel(ht) &&
> >> +			    ktime_to_ns(ktime_sub(hrtimer_get_expires(ht),
> >> +						  expires)) > 0)
> >> +				hrtimer_set_expires(ht, expires);
> >> +			hrtimer_restart(ht);
> > 
> > This code looks still wrong.
> 
> I'm not convinced either way, the code logic here has been like
> this since at least 2.2.x, where it reads:
> 
> 	if (!cl->delayed) {
> 		unsigned long sched = jiffies;
>  ...
> 		if (delay > 0) {
> 			sched += PSCHED_US2JIFFIE(delay) + cl->penalty;
>  ...
> 			if (del_timer(&q->delay_timer) &&
> 			    (long)(q->delay_timer.expires - sched) > 0)
> 				q->delay_timer.expires = sched;
> 			add_timer(&q->delay_timer);

That does not make more sense than the hrtimer version :)

> And what we have there now is a conversion to hrtimers.  The intention
> to always schedule the timer is very clear in the above code snippet.
> 
> Furthermore, fixing this logic is a seperate change from dealing with
> the softirq context issue.

Sure. Just mentioned it as a reminder.
 
> So please review my patch in the context of a straight conversion to
> tasklet_hrtimer, and let's deal with the timer offset logic here
> seperately (and in -next, not 2.6.31-rcX)

The straight conversion looks fine. Add my Acked-by.

Thanks,

	tglx
