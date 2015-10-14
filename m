From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next 1/4] net_sched: introduce qdisc_replace()
 helper
Date: Tue, 13 Oct 2015 18:54:48 -0700 (PDT)
Message-ID: <20151013.185448.842417293758576210.davem@davemloft.net>
References: <1444675083-9825-1-git-send-email-xiyou.wangcong@gmail.com>
	<1444675083-9825-2-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55392 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752557AbbJNBip (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2015 21:38:45 -0400
In-Reply-To: <1444675083-9825-2-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Mon, 12 Oct 2015 11:38:00 -0700

> Remove nearly duplicated code and prepare for the following patch.
> 
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

This isn't an equivalent transformation:

> +static inline struct Qdisc *qdisc_replace(struct Qdisc *sch, struct Qdisc *new,
> +					  struct Qdisc **pold)
> +{
> +	struct Qdisc *old;
> +
> +	sch_tree_lock(sch);
> +	old = *pold;
> +	*pold = new;
> +	if (old != NULL) {
> +		qdisc_tree_decrease_qlen(old, old->q.qlen);
> +		qdisc_reset(old);
> +	}
> +	sch_tree_unlock(sch);
> +
> +	return old;
> +}
> +

Is not the same as:

> diff --git a/net/sched/sch_drr.c b/net/sched/sch_drr.c
> index f26bdea..c76cdd4 100644
> --- a/net/sched/sch_drr.c
> +++ b/net/sched/sch_drr.c
> @@ -226,11 +226,7 @@ static int drr_graft_class(struct Qdisc *sch, unsigned long arg,
>  			new = &noop_qdisc;
>  	}
>  
> -	sch_tree_lock(sch);
> -	drr_purge_queue(cl);
> -	*old = cl->qdisc;
> -	cl->qdisc = new;
> -	sch_tree_unlock(sch);
> +	*old = qdisc_replace(sch, new, &cl->qdisc);
>  	return 0;
>  }
>  

This.

If you want to change semantics, you must do it explicitly in a separate
commit with a detailed commit message explaining how and why.
