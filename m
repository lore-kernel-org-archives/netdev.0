From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Tue, 19 Aug 2008 06:46:09 +0000
Message-ID: <20080819064609.GA4376@ff.dom.local>
References: <20080818.165411.255925269.davem@davemloft.net> <20080819000551.GA26699@gondor.apana.org.au> <20080818.171124.192743795.davem@davemloft.net> <20080818.210701.80578862.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	denys@visp.net.lb
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.180]:48389 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752277AbYHSGqQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2008 02:46:16 -0400
Received: by ik-out-1112.google.com with SMTP id c28so2605437ika.5
        for <netdev@vger.kernel.org>; Mon, 18 Aug 2008 23:46:14 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080818.210701.80578862.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 18, 2008 at 09:07:01PM -0700, David Miller wrote:
...
> pkt_sched: Don't hold qdisc lock over qdisc_destroy().
> 
> Based upon reports by Denys Fedoryshchenko, and feedback
> and help from Jarek Poplawski and Herbert Xu.
> 
> We always either:
> 
> 1) Never made an external reference to this qdisc.
> 
> or
> 
> 2) Did a dev_deactivate() which purged all asynchronous
>    references.

3) Read below, please...

> 
> So do not lock the qdisc when we call qdisc_destroy(),
> it's illegal anyways as when we drop the lock this is
> free'd memory.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  net/sched/sch_api.c     |   13 ++-----------
>  net/sched/sch_generic.c |    6 ------
>  2 files changed, 2 insertions(+), 17 deletions(-)
> 
> diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
> index 7d7070b..d91a233 100644
> --- a/net/sched/sch_api.c
> +++ b/net/sched/sch_api.c
> @@ -638,11 +638,8 @@ static void notify_and_destroy(struct sk_buff *skb, struct nlmsghdr *n, u32 clid
>  	if (new || old)
>  		qdisc_notify(skb, n, clid, old, new);
>  
> -	if (old) {
> -		sch_tree_lock(old);
> +	if (old)
>  		qdisc_destroy(old);
> -		sch_tree_unlock(old);
> -	}
>  }

Actually, I, and earlier Herbert, have written about destroying root
qdiscs without sch_tree_lock(). I don't know how Herbert, but I'd
prefer to leave here this lock for child qdiscs: they can remove some
common structures, so this needs more checking, and even if they don't
do this currently, there is no need to remove this possibility here.
Similarly, I'm not sure if removing BH protection is really needed
here.

And, btw., this is neither 1) nor 2) case according to the changelog,
I guess.

>  
>  /* Graft qdisc "new" to class "classid" of qdisc "parent" or
> @@ -1092,16 +1089,10 @@ create_n_graft:
>  
>  graft:
>  	if (1) {
> -		spinlock_t *root_lock;
> -
>  		err = qdisc_graft(dev, p, skb, n, clid, q, NULL);
>  		if (err) {
> -			if (q) {
> -				root_lock = qdisc_root_lock(q);
> -				spin_lock_bh(root_lock);
> +			if (q)
>  				qdisc_destroy(q);
> -				spin_unlock_bh(root_lock);
> -			}

Probably, as above.

>  			return err;
>  		}
>  	}
> diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
> index 6f96b7b..c3ed4d4 100644
> --- a/net/sched/sch_generic.c
> +++ b/net/sched/sch_generic.c
> @@ -518,8 +518,6 @@ void qdisc_reset(struct Qdisc *qdisc)
>  }
>  EXPORT_SYMBOL(qdisc_reset);
>  
> -/* Under qdisc_lock(qdisc) and BH! */
> -

??
+ /* Under BH for all, and qdisc_lock(qdisc) for child qdiscs only */

Jarek P.

>  void qdisc_destroy(struct Qdisc *qdisc)
>  {
>  	const struct Qdisc_ops  *ops = qdisc->ops;
> @@ -712,14 +710,10 @@ static void shutdown_scheduler_queue(struct net_device *dev,
>  	struct Qdisc *qdisc_default = _qdisc_default;
>  
>  	if (qdisc) {
> -		spinlock_t *root_lock = qdisc_lock(qdisc);
> -
>  		dev_queue->qdisc = qdisc_default;
>  		dev_queue->qdisc_sleeping = qdisc_default;
>  
> -		spin_lock_bh(root_lock);
>  		qdisc_destroy(qdisc);
> -		spin_unlock_bh(root_lock);
>  	}
>  }
>  
> -- 
> 1.5.6.5.GIT
> 
