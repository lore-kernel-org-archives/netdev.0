From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1b/2] tc: check for errors in gen_rate_estimator creation
Date: Tue, 25 Nov 2008 20:05:46 +0100
Message-ID: <492C4C8A.9000202@trash.net>
References: <20081125101656.52348bdd@extreme>	<492C43DF.1040703@trash.net> <20081125105850.7aa30a3d@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34291 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752308AbYKYTF4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 14:05:56 -0500
In-Reply-To: <20081125105850.7aa30a3d@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> The functions gen_new_estimator and gen_replace_estimator can return errors,
> but they were being ignored.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> 
> ---
> --- a/net/sched/sch_api.c	2008-11-25 10:51:47.000000000 -0800
> +++ b/net/sched/sch_api.c	2008-11-25 10:54:16.000000000 -0800
> @@ -887,6 +887,14 @@ static int qdisc_change(struct Qdisc *sc
>  			return err;
>  	}
>  
> +	if (tca[TCA_RATE]) {
> +		err = gen_replace_estimator(&sch->bstats, &sch->rate_est,
> +					    qdisc_root_sleeping_lock(sch),
> +					    tca[TCA_RATE]);
> +		if (err)
> +			return err;

This appears to have the same problem as in HFSC unless I missed more
code movement - changes to the qdisc have already been performed.

> --- a/net/sched/sch_hfsc.c	2008-11-25 10:51:47.000000000 -0800
> +++ b/net/sched/sch_hfsc.c	2008-11-25 10:54:16.000000000 -0800
> @@ -1018,6 +1018,14 @@ hfsc_change_class(struct Qdisc *sch, u32
>  		}
>  		cur_time = psched_get_time();
>  
> +		if (tca[TCA_RATE]) {
> +			err = gen_replace_estimator(&cl->bstats, &cl->rate_est,
> +					      qdisc_root_sleeping_lock(sch),
> +					      tca[TCA_RATE]);
> +			if (err)
> +				return err;
> +		}
> +
>  		sch_tree_lock(sch);
>  		if (rsc != NULL)
>  			hfsc_change_rsc(cl, rsc, cur_time);
> @@ -1034,10 +1042,6 @@ hfsc_change_class(struct Qdisc *sch, u32
>  		}
>  		sch_tree_unlock(sch);
>  
> -		if (tca[TCA_RATE])
> -			gen_replace_estimator(&cl->bstats, &cl->rate_est,
> -					      qdisc_root_sleeping_lock(sch),
> -					      tca[TCA_RATE]);
>  		return 0;
>  	}

There's a gen_new_estimator() a few lines below that is still unchecked.

The remaining ones look fine.
