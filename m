From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/6] pkt_sched: sch_htb: Consider used jiffies in	htb_dequeue()
Date: Tue, 09 Dec 2008 11:28:44 +0100
Message-ID: <493E485C.9090706@trash.net>
References: <20081209102118.GB14862@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, Martin Devera <devik@cdi.cz>,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59146 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752129AbYLIK2s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2008 05:28:48 -0500
In-Reply-To: <20081209102118.GB14862@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> Next event time should consider jiffies used for recounting. Otherwise
> qdisc_watchdog_schedule() triggers hrtimer immediately with the event
> in the past, and may cause very high ksoftirqd cpu usage (if highres
> is on). This patch charges jiffies globally, so we can skip this in
> htb_do_events().
> 
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
> ---
>  net/sched/sch_htb.c |   14 ++++++++++++--
>  1 files changed, 12 insertions(+), 2 deletions(-)
> 
> diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
> index d6eb4a7..102866d 100644
> --- a/net/sched/sch_htb.c
> +++ b/net/sched/sch_htb.c
> @@ -685,8 +685,11 @@ static psched_time_t htb_do_events(struct htb_sched *q, int level)
>  		if (cl->cmode != HTB_CAN_SEND)
>  			htb_add_to_wait_tree(q, cl, diff);
>  	}
> -	/* too much load - let's continue on next jiffie (including above) */
> -	return q->now + 2 * PSCHED_TICKS_PER_SEC / HZ;
> +	/*
> +	 * Too much load - let's continue on next jiffie.
> +	 * (Used jiffies are charged later.)
> +	 */
> +	return q->now + 1;
>  

This (including the last patch) is really confusing - q->now doesn't
contain HZ values but psched ticks. Could you describe the overall
algorithm you're trying to implement please?

