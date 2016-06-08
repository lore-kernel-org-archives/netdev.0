From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] qfq: don't leak skb if kzalloc fails
Date: Wed, 08 Jun 2016 08:54:33 -0700
Message-ID: <1465401273.7945.18.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1465389093-29674-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:34016 "EHLO
	mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752276AbcFHPyf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2016 11:54:35 -0400
Received: by mail-pa0-f66.google.com with SMTP id ug1so821094pab.1
        for <netdev@vger.kernel.org>; Wed, 08 Jun 2016 08:54:35 -0700 (PDT)
In-Reply-To: <1465389093-29674-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-06-08 at 14:31 +0200, Florian Westphal wrote:
> When we need to create a new aggregate to enqueue the skb we need
> to kzalloc the new struct.
> 
> If that fails we returned ENOBUFS without freeing the skb.
> 
> Spotted during code review.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>
> ---
>  net/sched/sch_qfq.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/sched/sch_qfq.c b/net/sched/sch_qfq.c
> index 8d2d8d9..435b970 100644
> --- a/net/sched/sch_qfq.c
> +++ b/net/sched/sch_qfq.c
> @@ -1236,7 +1236,7 @@ static int qfq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
>  		err = qfq_change_agg(sch, cl, cl->agg->class_weight,
>  				     qdisc_pkt_len(skb));
>  		if (err)
> -			return err;
> +			return qdisc_drop(skb, sch);
>  	}
>  
>  	err = qdisc_enqueue(skb, cl->qdisc);

Good catch, but it looks like you forgot :

	cl->qstats.drops++;
