From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Sun, 17 Aug 2008 15:42:54 +0200
Message-ID: <48A82ADE.5010903@gmail.com>
References: <20080813102701.GD5367@ff.dom.local> <20080813104238.GA11374@gondor.apana.org.au> <20080813105052.GA6838@ff.dom.local> <20080813.151918.61294677.davem@davemloft.net> <20080814112433.GA12476@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, Denys Fedoryshchenko <denys@visp.net.lb>
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:58117 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753246AbYHQNlU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Aug 2008 09:41:20 -0400
Received: by ug-out-1314.google.com with SMTP id c2so104876ugf.37
        for <netdev@vger.kernel.org>; Sun, 17 Aug 2008 06:41:18 -0700 (PDT)
In-Reply-To: <20080814112433.GA12476@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote, On 08/14/2008 01:24 PM:

> On Wed, Aug 13, 2008 at 03:19:18PM -0700, David Miller wrote:
> ...
>> Ok, so what I'm going to do is check in my patch and then try
>> to figure out how to resolve this "both bits clear" scenerio.
> 
> BTW, here is my older doubt revisited, where I hope to be re-considered/
> re-convinced, if possible...


After problems while testing this by Denys in another thread
I withdraw this patch.

Thanks,
Jarek P.


 
> ---------------->
> 
> pkt_sched: Destroy qdiscs under rtnl_lock again.
> 
> We don't need to trigger __qdisc_destroy() as an RCU callback because
> the use of qdisc isn't controlled by RCU alone: after querying RCU
> with synchronize_rcu() in dev_deactivate() we additionaly wait in a
> loop checking some flags. After the loop is done there could be no
> outstanding use of the qdisc, so call_rcu() doesn't make any sense.
> 
> On the other hand, current calling Qdisc's ->destroy() from a softirq
> context without locking (rtnl) can break various things like:
> qdisc_put_rtab(), tcf_destroy_chain() (e.g. u32_destroy()), and
> probably more.
> 
> 
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
> 
> ---
> 
>  net/sched/sch_generic.c |    8 ++------
>  1 files changed, 2 insertions(+), 6 deletions(-)
> 
> diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
> index 4685746..e7379d2 100644
> --- a/net/sched/sch_generic.c
> +++ b/net/sched/sch_generic.c
> @@ -518,12 +518,8 @@ void qdisc_reset(struct Qdisc *qdisc)
>  }
>  EXPORT_SYMBOL(qdisc_reset);
>  
> -/* this is the rcu callback function to clean up a qdisc when there
> - * are no further references to it */
> -
> -static void __qdisc_destroy(struct rcu_head *head)
> +static void __qdisc_destroy(struct Qdisc *qdisc)
>  {
> -	struct Qdisc *qdisc = container_of(head, struct Qdisc, q_rcu);
>  	const struct Qdisc_ops  *ops = qdisc->ops;
>  
>  #ifdef CONFIG_NET_SCHED
> @@ -554,7 +550,7 @@ void qdisc_destroy(struct Qdisc *qdisc)
>  	if (qdisc->parent)
>  		list_del(&qdisc->list);
>  
> -	call_rcu(&qdisc->q_rcu, __qdisc_destroy);
> +	__qdisc_destroy(qdisc);
>  }
>  EXPORT_SYMBOL(qdisc_destroy);
>  
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


