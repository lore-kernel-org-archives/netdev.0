From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 4/5] netem: avoid excessive requeues
Date: Thu, 22 Mar 2007 21:40:43 +0100
Message-ID: <4602E9CB.8030500@trash.net>
References: <20070321174231.890361963@linux-foundation.org> <20070321174422.767901837@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:44754 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934228AbXCVUkq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Mar 2007 16:40:46 -0400
In-Reply-To: <20070321174422.767901837@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> @@ -315,6 +316,7 @@ void qdisc_watchdog_schedule(struct qdis
>  	ktime_t time;
>  
>  	wd->qdisc->flags |= TCQ_F_THROTTLED;
> +	smp_wmb();
>  	time = ktime_set(0, 0);
>  	time = ktime_add_ns(time, PSCHED_US2NS(expires));
>  	hrtimer_start(&wd->timer, time, HRTIMER_MODE_ABS);
> @@ -325,6 +327,7 @@ void qdisc_watchdog_cancel(struct qdisc_
>  {
>  	hrtimer_cancel(&wd->timer);
>  	wd->qdisc->flags &= ~TCQ_F_THROTTLED;
> +	smp_wmb();
>  }
>  EXPORT_SYMBOL(qdisc_watchdog_cancel);


These two look unnecessary, we're holding the queue lock.

> --- net-2.6.22.orig/net/sched/sch_netem.c
> +++ net-2.6.22/net/sched/sch_netem.c
> @@ -272,6 +272,10 @@ static struct sk_buff *netem_dequeue(str
>  	struct netem_sched_data *q = qdisc_priv(sch);
>  	struct sk_buff *skb;
>  
> +	smp_mb();
> +	if (sch->flags & TCQ_F_THROTTLED)
> +		return NULL;
> +


Perhaps we should put this in qdisc_restart, other qdiscs have the
same problem.
