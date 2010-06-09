From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] pkt_sched: gen_kill_estimator() rcu fixes
Date: Wed, 9 Jun 2010 10:41:00 +0000
Message-ID: <20100609104100.GB7308@ff.dom.local>
References: <1275921171.2545.102.camel@edumazet-laptop> <AANLkTimgmYjA7Xp19gycRHDXmwP1w1twn92cfT08tCv2@mail.gmail.com> <1275924638.2545.121.camel@edumazet-laptop> <1275926151.2545.126.camel@edumazet-laptop> <1275929761.2545.159.camel@edumazet-laptop> <1276076415.2442.92.camel@edumazet-laptop> <1276077416.2442.97.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Changli Gao <xiaosuo@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.155]:34848 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757518Ab0FIKlE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jun 2010 06:41:04 -0400
Received: by fg-out-1718.google.com with SMTP id l26so1727080fgb.1
        for <netdev@vger.kernel.org>; Wed, 09 Jun 2010 03:41:02 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1276077416.2442.97.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 09, 2010 at 11:56:56AM +0200, Eric Dumazet wrote:
...
> Updated patch follows :
> 
> [PATCH] pkt_sched: gen_kill_estimator() rcu fixes
> 
> gen_kill_estimator() API is a bit misleading, since caller

I'd call it incomplete or simply buggy. Plus a tiny note below.

> should make sure an RCU grace period is respected before
> freeing stats_lock.
> 
> This was partially addressed in commit 5d944c640b4 
> (gen_estimator: deadlock fix), but same problem exist for all
> gen_kill_estimator() users, if lock they use is not already rcu
> protected.
> 
> A code review shows xt_RATEEST.c, act_api.c, act_police.c have this
> problem. Other are ok because they use qdisc lock.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
...
> diff --git a/net/netfilter/xt_RATEEST.c b/net/netfilter/xt_RATEEST.c
> index 69c01e1..096b18b 100644
> --- a/net/netfilter/xt_RATEEST.c
> +++ b/net/netfilter/xt_RATEEST.c
> @@ -60,13 +60,18 @@ struct xt_rateest *xt_rateest_lookup(const char *name)
>  }
>  EXPORT_SYMBOL_GPL(xt_rateest_lookup);
>  
> +static void xt_rateeset_free_rcu(struct rcu_head *head)
> +{
> +	kfree(container_of(head, struct xt_rateest, rcu));
> +}
> +
>  void xt_rateest_put(struct xt_rateest *est)
>  {
>  	mutex_lock(&xt_rateest_mutex);
>  	if (--est->refcnt == 0) {
>  		hlist_del(&est->list);
>  		gen_kill_estimator(&est->bstats, &est->rstats);
> -		kfree(est);
> +		call_rcu(&est->rcu, xt_rateeset_free_rcu);

Spelling suggestion: xt_rateest_free_rcu?

Since it's only 3 places I'd consider adding little comments,
who needs this call_rcu (like in qdisc_destroy).

Anyway this patch looks OK to me.

Jarek P.
