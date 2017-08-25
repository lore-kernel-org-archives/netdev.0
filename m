From: Eric Dumazet <erdnetdev@gmail.com>
Subject: Re: [PATCH net-next RESEND] sched: sfq: drop packets after root
 qdisc lock is released
Date: Fri, 25 Aug 2017 05:49:37 -0700
Message-ID: <1503665377.18816.2.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1503646997-94678-1-git-send-email-gfree.wind@vip.163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, xiyou.wangcong@gmail.com, jiri@resnulli.us,
        davem@davemloft.net, edumazet@google.com, netdev@vger.kernel.org
To: gfree.wind@vip.163.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:36571 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754704AbdHYMtk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2017 08:49:40 -0400
Received: by mail-pg0-f67.google.com with SMTP id 83so3772496pgb.3
        for <netdev@vger.kernel.org>; Fri, 25 Aug 2017 05:49:40 -0700 (PDT)
In-Reply-To: <1503646997-94678-1-git-send-email-gfree.wind@vip.163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-08-25 at 15:43 +0800, gfree.wind@vip.163.com wrote:
> From: Gao Feng <gfree.wind@vip.163.com>
> 
> The commit 520ac30f4551 ("net_sched: drop packets after root qdisc lock
> is released) made a big change of tc for performance. But there are
> some points which are not changed in SFQ enqueue operation.
> 1. Fail to find the SFQ hash slot;
> 2. When the queue is full;
> 
> Now use qdisc_drop instead free skb directly.


Thanks for doing this work.

I have one comment

> 
> Signed-off-by: Gao Feng <gfree.wind@vip.163.com>
> ---
>  net/sched/sch_sfq.c | 16 ++++++++++------
>  1 file changed, 10 insertions(+), 6 deletions(-)
> 
> diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
> index 82469ef..8841f4d 100644
> --- a/net/sched/sch_sfq.c
> +++ b/net/sched/sch_sfq.c
> @@ -292,7 +292,7 @@ static inline void slot_queue_add(struct sfq_slot *slot, struct sk_buff *skb)
>  	slot->skblist_prev = skb;
>  }
>  
> -static unsigned int sfq_drop(struct Qdisc *sch)
> +static unsigned int sfq_drop(struct Qdisc *sch, struct sk_buff **to_free)
>  {
>  	struct sfq_sched_data *q = qdisc_priv(sch);
>  	sfq_index x, d = q->cur_depth;
> @@ -310,9 +310,13 @@ static unsigned int sfq_drop(struct Qdisc *sch)
>  		slot->backlog -= len;
>  		sfq_dec(q, x);
>  		sch->q.qlen--;
> -		qdisc_qstats_drop(sch);
>  		qdisc_qstats_backlog_dec(sch, skb);
> -		kfree_skb(skb);
> +		if (likely(to_free)) {
> +			qdisc_drop(skb, sch, to_free);
> +		} else {
> +			qdisc_qstats_drop(sch);
> +			kfree_skb(skb);

                         rtnl_kfree_skbs(skb, skb);  ?

Or even better provide a non NULL to_free from sfq_change()

Then call rtnl_kfree_skbs() once from sfq_change()


> +		}
>  		return len;
>  	}
>  
> @@ -360,7 +364,7 @@ static int sfq_headdrop(const struct sfq_sched_data *q)
>  	if (hash == 0) {
>  		if (ret & __NET_XMIT_BYPASS)
>  			qdisc_qstats_drop(sch);
> -		kfree_skb(skb);
> +		__qdisc_drop(skb, to_free);
>  		return ret;
>  	}
>  	hash--;
> @@ -465,7 +469,7 @@ static int sfq_headdrop(const struct sfq_sched_data *q)
>  		return NET_XMIT_SUCCESS;
>  
>  	qlen = slot->qlen;
> -	dropped = sfq_drop(sch);
> +	dropped = sfq_drop(sch, to_free);
>  	/* Return Congestion Notification only if we dropped a packet
>  	 * from this flow.
>  	 */
> @@ -675,7 +679,7 @@ static int sfq_change(struct Qdisc *sch, struct nlattr *opt)
>  
>  	qlen = sch->q.qlen;
>  	while (sch->q.qlen > q->limit)
> -		dropped += sfq_drop(sch);
> +		dropped += sfq_drop(sch, NULL);
>  	qdisc_tree_reduce_backlog(sch, qlen - sch->q.qlen, dropped);
>  
>  	del_timer(&q->perturb_timer);
