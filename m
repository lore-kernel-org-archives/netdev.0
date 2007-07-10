From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: + gen_estimator-fix-locking-and-timer-related-bugs.patch added to -mm tree
Date: Tue, 10 Jul 2007 09:34:47 +0200
Message-ID: <20070710073447.GA1870@ff.dom.local>
References: <20070706062629.GC1846@ff.dom.local> <20070706064523.GA2144@ff.dom.local> <1183727654.6389.3.camel@ranko-fc2.spidernet.net> <468E4FD9.4060702@trash.net> <1183733732.6389.26.camel@ranko-fc2.spidernet.net> <1183794918.30237.69.camel@localhost.localdomain> <Pine.LNX.4.64.0707071704370.1808@x2> <1183984861.18656.21.camel@ranko-fc2.spidernet.net> <46923DA8.9010208@trash.net> <1183999420.18656.54.camel@ranko-fc2.spidernet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org
To: Ranko Zivojnovic <ranko@spidernet.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:41133 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756475AbXGJJMa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jul 2007 05:12:30 -0400
Content-Disposition: inline
In-Reply-To: <1183999420.18656.54.camel@ranko-fc2.spidernet.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 09, 2007 at 07:43:40PM +0300, Ranko Zivojnovic wrote:
> On Mon, 2007-07-09 at 15:52 +0200, Patrick McHardy wrote:
> > Ranko Zivojnovic wrote:
> > > Patrick, I've taken liberty to try and implement this myself. Attached
> > > is the whole new gen_estimator-fix-locking-and-timer-related-bugs.patch
> > > that is RCU lists based. Please be kind to review.
...

I've some doubts/suggestions too:

> --- a/net/core/gen_estimator.c	2007-06-25 02:21:48.000000000 +0300
> +++ b/net/core/gen_estimator.c	2007-07-09 19:08:06.801544963 +0300
...
> @@ -173,20 +172,24 @@
>  	est->last_packets = bstats->packets;
>  	est->avpps = rate_est->pps<<10;
>  
> -	est->next = elist[est->interval].list;
> -	if (est->next == NULL) {
> -		init_timer(&elist[est->interval].timer);
> -		elist[est->interval].timer.data = est->interval;
> -		elist[est->interval].timer.expires = jiffies + ((HZ<<est->interval)/4);
> -		elist[est->interval].timer.function = est_timer;
> -		add_timer(&elist[est->interval].timer);
> +	if (!elist[idx].timer.function) {
> +		INIT_LIST_HEAD(&elist[idx].list);
> +		setup_timer(&elist[idx].timer, est_timer, est->interval);

s/est->interval/idx/ here and below.

>  	}
> -	write_lock_bh(&est_lock);
> -	elist[est->interval].list = est;
> -	write_unlock_bh(&est_lock);
> +		
> +	if (list_empty(&elist[est->interval].list))
> +		mod_timer(&elist[idx].timer, jiffies + ((HZ<<idx)/4));
> +
> +	list_add_rcu(&est->list, &elist[idx].list);
>  	return 0;
>  }
>  
> +static void __gen_kill_estimator(struct rcu_head *head)
> +{
> +	struct gen_estimator *e = container_of(head, struct gen_estimator, e_rcu);
> +	kfree(e);
> +}
> +
>  /**
>   * gen_kill_estimator - remove a rate estimator
>   * @bstats: basic statistics
> @@ -199,26 +202,21 @@
>  	struct gnet_stats_rate_est *rate_est)
>  {
...
> +		list_for_each_entry_safe(e, n, &elist[idx].list, list) {

IMHO, at least for readability list_for_each_entry_rcu() is better here.

> +			if (e->rate_est != rate_est || e->bstats != bstats)
> +				continue;
>  
> -			kfree(est);
> -			killed++;
> +			list_del_rcu(&e->list);
> +			call_rcu(&e->e_rcu, __gen_kill_estimator);

I think a race is possible here: e.g. a timer could be running
after return from this function yet, and trying to use *bstats,
*rate_est and maybe even stats_lock after their destruction.

BTW, I think, rcu_read_lock/unlock are recommended around e.g.
rcu lists traversals, even if the current implementation doesn't
use them now.

Regards,
Jarek P.
