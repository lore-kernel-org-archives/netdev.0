From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH]: Schedule correct qdisc in watchdog.
Date: Mon, 18 Aug 2008 09:10:12 +0000
Message-ID: <20080818091011.GC5434@ff.dom.local>
References: <20080818.013954.187452037.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:18950 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751074AbYHRJKT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Aug 2008 05:10:19 -0400
Received: by ug-out-1314.google.com with SMTP id c2so162097ugf.37
        for <netdev@vger.kernel.org>; Mon, 18 Aug 2008 02:10:17 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080818.013954.187452037.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 18, 2008 at 01:39:54AM -0700, David Miller wrote:
> 
> Jarek, I bet this is what was causing the crash you were trying to fix
> yesterday.
> 
> But that's just my newbie hunch :-)

Yes, this was one of the reasons, but not the only one, and my oldbie
version of this fix could be found here as "02-fix1.patch":

http://permalink.gmane.org/gmane.linux.network/103039

It's a bit different, because I think wd->qdisc can probably
point to the noop_qdisc (if it's the root qdisc).

Anyway this kind of change is necessary here, and everywhere where
netif_schedule() could be called (I've found sch_cbq.c only).

Jarek P.

> 
> pkt_sched: Never scheduler non-root qdiscs.
> 
> The qdisc watchdogs can be attached to any qdisc,
> not just the root, so make sure we schedule the
> correct one.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
> index c8dc72e..98c0084 100644
> --- a/net/sched/sch_api.c
> +++ b/net/sched/sch_api.c
> @@ -426,7 +426,7 @@ static enum hrtimer_restart qdisc_watchdog(struct hrtimer *timer)
>  
>  	wd->qdisc->flags &= ~TCQ_F_THROTTLED;
>  	smp_wmb();
> -	__netif_schedule(wd->qdisc);
> +	__netif_schedule(qdisc_root(wd->qdisc));
>  
>  	return HRTIMER_NORESTART;
>  }
