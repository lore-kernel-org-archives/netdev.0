From: Julio Kriger <juliokriger@gmail.com>
Subject: Re: [Netem] [PATCH] (3/3) netem: allow random reordering
Date: Sat, 21 May 2005 23:00:41 +0000
Message-ID: <682bc30a05052116005bc813a2@mail.gmail.com>
References: <20050519151254.79afe7e7@dxpl.pdx.osdl.net>
Reply-To: Julio Kriger <juliokriger@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com,
        netem@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050519151254.79afe7e7@dxpl.pdx.osdl.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,
I have a doubt about about this lines (#90)

	if (q->gap == 0 && q->counter < q->gap && 
	    q->reorder < get_crandom(&q->reorder_cor)) {

I could not achieve reordering. I've set gap and reordering values but
did'nt success. Then I've modified those lines to this one

	if( 0 < q->reorder && q->reorder < get_crandom(&q->reorder_cor) ) {

and I achieve reordering (I test it pinging localhost).

Is this correct or I'm doing something wrong?

Regards,
Julio



On 5/19/05, Stephen Hemminger <shemminger@osdl.org> wrote:
> Enhance the reorder feature of netem to allow random percent to be reordered.
> Has expected backwards compatibility behaviour.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
> 
> Index: netem-2.6.12-rc4/include/linux/pkt_sched.h
> ===================================================================
> --- netem-2.6.12-rc4.orig/include/linux/pkt_sched.h
> +++ netem-2.6.12-rc4/include/linux/pkt_sched.h
> @@ -427,6 +427,7 @@ enum
>         TCA_NETEM_UNSPEC,
>         TCA_NETEM_CORR,
>         TCA_NETEM_DELAY_DIST,
> +       TCA_NETEM_REORDER,
>         __TCA_NETEM_MAX,
>  };
> 
> @@ -437,7 +438,7 @@ struct tc_netem_qopt
>         __u32   latency;        /* added delay (us) */
>         __u32   limit;          /* fifo limit (packets) */
>         __u32   loss;           /* random packet loss (0=none ~0=100%) */
> -       __u32   gap;            /* re-ordering gap (0 for delay all) */
> +       __u32   gap;            /* re-ordering gap (0 for none) */
>         __u32   duplicate;      /* random packet dup  (0=none ~0=100%) */
>         __u32   jitter;         /* random jitter in latency (us) */
>  };
> @@ -449,6 +450,12 @@ struct tc_netem_corr
>         __u32   dup_corr;       /* duplicate correlation  */
>  };
> 
> +struct tc_netem_reorder
> +{
> +       __u32   probability;
> +       __u32   correlation;
> +};
> +
>  #define NETEM_DIST_SCALE       8192
> 
>  #endif
> Index: netem-2.6.12-rc4/net/sched/sch_netem.c
> ===================================================================
> --- netem-2.6.12-rc4.orig/net/sched/sch_netem.c
> +++ netem-2.6.12-rc4/net/sched/sch_netem.c
> @@ -62,11 +62,12 @@ struct netem_sched_data {
>         u32 gap;
>         u32 jitter;
>         u32 duplicate;
> +       u32 reorder;
> 
>         struct crndstate {
>                 unsigned long last;
>                 unsigned long rho;
> -       } delay_cor, loss_cor, dup_cor;
> +       } delay_cor, loss_cor, dup_cor, reorder_cor;
> 
>         struct disttable {
>                 u32  size;
> @@ -185,18 +186,18 @@ static int netem_enqueue(struct sk_buff
>          * of the queue.
>          * gap == 0 is special case for no-reordering.
>          */
> -       if (q->gap == 0 || q->counter != q->gap) {
> +       if (q->gap == 0 && q->counter < q->gap &&
> +           q->reorder < get_crandom(&q->reorder_cor)) {
>                 psched_time_t now;
>                 PSCHED_GET_TIME(now);
> -               PSCHED_TADD2(now,
> -                            tabledist(q->latency, q->jitter, &q->delay_cor, q->delay_dist),
> +               PSCHED_TADD2(now, tabledist(q->latency, q->jitter,
> +                                           &q->delay_cor, q->delay_dist),
>                              cb->time_to_send);
> -
>                 ++q->counter;
>                 ret = q->qdisc->enqueue(skb, q->qdisc);
>         } else {
> -               q->counter = 0;
>                 PSCHED_GET_TIME(cb->time_to_send);
> +               q->counter = 0;
>                 ret = q->qdisc->ops->requeue(skb, q->qdisc);
>         }
> 
> @@ -351,6 +352,19 @@ static int get_correlation(struct Qdisc
>         return 0;
>  }
> 
> +static int get_reorder(struct Qdisc *sch, const struct rtattr *attr)
> +{
> +       struct netem_sched_data *q = qdisc_priv(sch);
> +       const struct tc_netem_reorder *r = RTA_DATA(attr);
> +
> +       if (RTA_PAYLOAD(attr) != sizeof(*r))
> +               return -EINVAL;
> +
> +       q->reorder = r->probability;
> +       init_crandom(&q->reorder_cor, r->correlation);
> +       return 0;
> +}
> +
>  static int netem_change(struct Qdisc *sch, struct rtattr *opt)
>  {
>         struct netem_sched_data *q = qdisc_priv(sch);
> @@ -371,9 +385,15 @@ static int netem_change(struct Qdisc *sc
>         q->jitter = qopt->jitter;
>         q->limit = qopt->limit;
>         q->gap = qopt->gap;
> +       q->counter = 0;
>         q->loss = qopt->loss;
>         q->duplicate = qopt->duplicate;
> 
> +       /* for compatiablity with earlier versions.
> +        * if gap is set, need to assume 100% probablity
> +        */
> +       q->reorder = ~0;
> +
>         /* Handle nested options after initial queue options.
>          * Should have put all options in nested format but too late now.
>          */
> @@ -395,6 +415,11 @@ static int netem_change(struct Qdisc *sc
>                         if (ret)
>                                 return ret;
>                 }
> +               if (tb[TCA_NETEM_REORDER-1]) {
> +                       ret = get_reorder(sch, tb[TCA_NETEM_REORDER-1]);
> +                       if (ret)
> +                               return ret;
> +               }
>         }
> 
> 
> @@ -412,7 +437,6 @@ static int netem_init(struct Qdisc *sch,
>         init_timer(&q->timer);
>         q->timer.function = netem_watchdog;
>         q->timer.data = (unsigned long) sch;
> -       q->counter = 0;
> 
>         q->qdisc = qdisc_create_dflt(sch->dev, &pfifo_qdisc_ops);
>         if (!q->qdisc) {
> @@ -444,6 +468,7 @@ static int netem_dump(struct Qdisc *sch,
>         struct rtattr *rta = (struct rtattr *) b;
>         struct tc_netem_qopt qopt;
>         struct tc_netem_corr cor;
> +       struct tc_netem_reorder reorder;
> 
>         qopt.latency = q->latency;
>         qopt.jitter = q->jitter;
> @@ -457,6 +482,11 @@ static int netem_dump(struct Qdisc *sch,
>         cor.loss_corr = q->loss_cor.rho;
>         cor.dup_corr = q->dup_cor.rho;
>         RTA_PUT(skb, TCA_NETEM_CORR, sizeof(cor), &cor);
> +
> +       reorder.probability = q->reorder;
> +       reorder.correlation = q->reorder_cor.rho;
> +       RTA_PUT(skb, TCA_NETEM_REORDER, sizeof(reorder), &reorder);
> +
>         rta->rta_len = skb->tail - b;
> 
>         return skb->len;
> 
> 
> _______________________________________________
> Netem mailing list
> Netem@lists.osdl.org
> http://lists.osdl.org/mailman/listinfo/netem
> 
> 
> 


-- 
----------------------------
Julio Kriger
mailto:juliokriger@gmail.com
