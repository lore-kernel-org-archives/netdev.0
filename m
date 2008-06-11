From: "Rafael Almeida" <almeidaraf@gmail.com>
Subject: Re: [PATCH] Fixed NetEm's reorder option
Date: Wed, 11 Jun 2008 17:05:10 -0300
Message-ID: <6de6b1650806111305m51bf2eccocbe0d0c7afee266d@mail.gmail.com>
References: <48479f6a.e203be0a.73e1.fffff59b@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.176]:4811 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751117AbYFKUFL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2008 16:05:11 -0400
Received: by wa-out-1112.google.com with SMTP id j37so2625364waf.23
        for <netdev@vger.kernel.org>; Wed, 11 Jun 2008 13:05:11 -0700 (PDT)
In-Reply-To: <48479f6a.e203be0a.73e1.fffff59b@mx.google.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I noticed no one said anything about my patch below, did I do
something terrible wrong? Should I just be more patient?

On Thu, Jun 5, 2008 at 1:34 AM, Rafael C. de Almeida
<almeidaraf@gmail.com> wrote:
> The reorder option wasn't working correctly. It would only kick in if
> the gap option was set. In that case it would only lower the
> probability of reordering packets because of how the if conditional
> was stated.
>
> This patch separetes the algorithm for reordering with gap from the
> rest, rendering the code more readable and correct.
>
> Signed-off-by: Rafael C. de Almeida <rafaelc@dcc.ufmg.br>
> ---
>  net/sched/sch_netem.c |   45 ++++++++++++++++++++++++++++++++-------------
>  1 files changed, 32 insertions(+), 13 deletions(-)
>
> diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
> index c9c649b..477ee09 100644
> --- a/net/sched/sch_netem.c
> +++ b/net/sched/sch_netem.c
> @@ -206,27 +206,46 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
>        }
>
>        cb = (struct netem_skb_cb *)skb->cb;
> -       if (q->gap == 0                 /* not doing reordering */
> -           || q->counter < q->gap      /* inside last reordering gap */
> -           || q->reorder < get_crandom(&q->reorder_cor)) {
> +       if (q->gap) {
> +               /* The comparison of reorder is here to keep compatibility with
> +                * the old behaviour when one had reorder and gap set, maybe it
> +                * could be removed.
> +                */
> +               if (q->counter < q->gap
> +                   || q->reorder < get_crandom(&q->reorder_cor)) {
> +                       psched_time_t now;
> +                       psched_tdiff_t delay;
> +
> +                       delay = tabledist(q->latency, q->jitter,
> +                                         &q->delay_cor, q->delay_dist);
> +
> +                       now = psched_get_time();
> +                       cb->time_to_send = now + delay;
> +                       ++q->counter;
> +                       ret = q->qdisc->enqueue(skb, q->qdisc);
> +               } else {
> +                       /*
> +                        * Do re-ordering by putting one out of N packets at the front
> +                        * of the queue.
> +                        */
> +                       cb->time_to_send = psched_get_time();
> +                       q->counter = 0;
> +                       ret = q->qdisc->ops->requeue(skb, q->qdisc);
> +               }
> +       } else {
>                psched_time_t now;
>                psched_tdiff_t delay;
>
> -               delay = tabledist(q->latency, q->jitter,
> -                                 &q->delay_cor, q->delay_dist);
> +               if (!q->reorder || q->reorder < get_crandom(&q->reorder_cor))
> +                       delay = tabledist(q->latency, q->jitter,
> +                                         &q->delay_cor, q->delay_dist);
> +               else
> +                       delay = 0;
>
>                now = psched_get_time();
>                cb->time_to_send = now + delay;
>                ++q->counter;
>                ret = q->qdisc->enqueue(skb, q->qdisc);
> -       } else {
> -               /*
> -                * Do re-ordering by putting one out of N packets at the front
> -                * of the queue.
> -                */
> -               cb->time_to_send = psched_get_time();
> -               q->counter = 0;
> -               ret = q->qdisc->ops->requeue(skb, q->qdisc);
>        }
>
>        if (likely(ret == NET_XMIT_SUCCESS)) {
> --
> 1.5.5.GIT
>
>
