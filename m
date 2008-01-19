From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/3] sfq: timer is deferrable
Date: Fri, 18 Jan 2008 20:34:46 -0800
Message-ID: <20080119043446.GB24840@linux.vnet.ibm.com>
References: <20080118144900.1df0dd90@deepthought>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen.hemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:52984 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758400AbYASEe7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jan 2008 23:34:59 -0500
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m0J4YmKk003109
	for <netdev@vger.kernel.org>; Fri, 18 Jan 2008 23:34:48 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0J4YmlC097112
	for <netdev@vger.kernel.org>; Fri, 18 Jan 2008 21:34:48 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m0J4Ym0h029873
	for <netdev@vger.kernel.org>; Fri, 18 Jan 2008 21:34:48 -0700
Content-Disposition: inline
In-Reply-To: <20080118144900.1df0dd90@deepthought>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 18, 2008 at 02:49:00PM -0800, Stephen Hemminger wrote:
> The perturbation timer used for re-keying can be deferred, it doesn't
> need to be deterministic.

The only concern that I can come up with is that the sfq_perturbation
timer might be on one CPU, and all the operations using the corresponding
SFQ on another.  This could in theory allow a nearly omniscient attacker
to exploit an SFQ imbalance while preventing perturbation of the hash
function.

This does not seem to be a valid concern at this point, since there are
very few uses of init_timer_deferrable().  And if it should become a
problem, one approach would be to have some sort of per-timer limit to
the deferral.  Of course, at that point one would need to figure out
what this limit should be!

Acked-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

> Signed-off-by: Stephen Hemminger <stephen.hemminger@vyatta.com>
> 
> 
> --- a/net/sched/sch_sfq.c	2008-01-17 08:29:24.000000000 -0800
> +++ b/net/sched/sch_sfq.c	2008-01-17 09:00:58.000000000 -0800
> @@ -426,7 +426,9 @@ static int sfq_init(struct Qdisc *sch, s
>  	struct sfq_sched_data *q = qdisc_priv(sch);
>  	int i;
> 
> -	setup_timer(&q->perturb_timer, sfq_perturbation, (unsigned long)sch);
> +	q->perturb_timer.function = sfq_perturbation;
> +	q->perturb_timer.data = (unsigned long)sch;;
> +	init_timer_deferrable(&q->perturb_timer);
> 
>  	for (i=0; i<SFQ_HASH_DIVISOR; i++)
>  		q->ht[i] = SFQ_DEPTH;
