From: Julio Kriger <juliokriger@gmail.com>
Subject: Re: [PATCH] netem: fix logic bug in reorder conditional
Date: Mon, 23 May 2005 17:55:35 -0300
Message-ID: <682bc30a050523135534b38b8b@mail.gmail.com>
References: <20050519151254.79afe7e7@dxpl.pdx.osdl.net>
	 <682bc30a05052116005bc813a2@mail.gmail.com>
	 <20050523104342.78b1032d@dxpl.pdx.osdl.net>
Reply-To: Julio Kriger <juliokriger@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com,
        netem@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050523104342.78b1032d@dxpl.pdx.osdl.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi!

1) Supouse I don't want reordering, so in 'tc' I don't add reorder
option. Will this code work? The previous (on this subject) patch has
a the following:

+       /* for compatiablity with earlier versions.
+        * if gap is set, need to assume 100% probablity
+        */
+       q->reorder = ~0;
+

Should it be set to 100% or 101%? 
This "q->reorder = ~0;" mean 100%?

2) If I set latency = 50ms and a jitter = 300ms, tabledist can give me
a negative number. This value is addes to cb->time_to_send, so it
could change it to a negative value. Should we only accept positives
number before add it to cb->time_to_send? or will
q->qdisc->enqueue(skb, q->qdisc) put the package on the queue in a
special way so it will be handled "before" other packages alrealy on
the queue but with gretaer time_to_send?

Regards,
Julio

On 5/23/05, Stephen Hemminger <shemminger@osdl.org> wrote:
> Thanks, Julio you spotted the problem with the logic.  This should fix it:
> 
> Index: netem-2.6.12-rc4/net/sched/sch_netem.c
> ===================================================================
> --- netem-2.6.12-rc4.orig/net/sched/sch_netem.c
> +++ netem-2.6.12-rc4/net/sched/sch_netem.c
> @@ -181,13 +181,9 @@ static int netem_enqueue(struct sk_buff
>                 q->duplicate = dupsave;
>         }
> 
> -       /*
> -        * Do re-ordering by putting one out of N packets at the front
> -        * of the queue.
> -        * gap == 0 is special case for no-reordering.
> -        */
> -       if (q->gap == 0 && q->counter < q->gap &&
> -           q->reorder < get_crandom(&q->reorder_cor)) {
> +       if (q->gap == 0                 /* not doing reordering */
> +           || q->counter < q->gap      /* inside last reordering gap */
> +           || q->reorder < get_crandom(&q->reorder_cor)) {
>                 psched_time_t now;
>                 PSCHED_GET_TIME(now);
>                 PSCHED_TADD2(now, tabledist(q->latency, q->jitter,
> @@ -196,6 +192,10 @@ static int netem_enqueue(struct sk_buff
>                 ++q->counter;
>                 ret = q->qdisc->enqueue(skb, q->qdisc);
>         } else {
> +               /*
> +                * Do re-ordering by putting one out of N packets at the front
> +                * of the queue.
> +                */
>                 PSCHED_GET_TIME(cb->time_to_send);
>                 q->counter = 0;
>                 ret = q->qdisc->ops->requeue(skb, q->qdisc);
> 


-- 
----------------------------
Julio Kriger
mailto:juliokriger@gmail.com
