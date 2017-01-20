From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next] fq_codel: Avoid regenerating skb flow hash
 unless necessary
Date: Fri, 20 Jan 2017 09:23:43 -0800
Message-ID: <CALx6S37Pnjyz6cpykKgy5JOU23MkH4EJ2Z+do+zVfXR08X5NYg@mail.gmail.com>
References: <20170118210428.24006-1-acollins@cradlepoint.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Andrew Collins <acollins@cradlepoint.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yb0-f195.google.com ([209.85.213.195]:34806 "EHLO
        mail-yb0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751303AbdATR3w (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 12:29:52 -0500
Received: by mail-yb0-f195.google.com with SMTP id w194so8344644ybe.1
        for <netdev@vger.kernel.org>; Fri, 20 Jan 2017 09:29:52 -0800 (PST)
In-Reply-To: <20170118210428.24006-1-acollins@cradlepoint.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 18, 2017 at 1:04 PM, Andrew Collins
<acollins@cradlepoint.com> wrote:
> The fq_codel qdisc currently always regenerates the skb flow hash.
> This wastes some cycles and prevents flow seperation in cases where
> the traffic has been encrypted and can no longer be understood by the
> flow dissector.
>
> Change it to use the prexisting flow hash if one exists, and only
> regenerate if necessary.
>
> Signed-off-by: Andrew Collins <acollins@cradlepoint.com>
> ---
>  net/sched/sch_fq_codel.c | 6 +-----
>  1 file changed, 1 insertion(+), 5 deletions(-)
>
> diff --git a/net/sched/sch_fq_codel.c b/net/sched/sch_fq_codel.c
> index a5ea0e9..2f50e4c 100644
> --- a/net/sched/sch_fq_codel.c
> +++ b/net/sched/sch_fq_codel.c
> @@ -57,7 +57,6 @@ struct fq_codel_sched_data {
>         struct fq_codel_flow *flows;    /* Flows table [flows_cnt] */
>         u32             *backlogs;      /* backlog table [flows_cnt] */
>         u32             flows_cnt;      /* number of flows */
> -       u32             perturbation;   /* hash perturbation */
>         u32             quantum;        /* psched_mtu(qdisc_dev(sch)); */
>         u32             drop_batch_size;
>         u32             memory_limit;
> @@ -75,9 +74,7 @@ struct fq_codel_sched_data {
>  static unsigned int fq_codel_hash(const struct fq_codel_sched_data *q,
>                                   struct sk_buff *skb)
>  {
> -       u32 hash = skb_get_hash_perturb(skb, q->perturbation);
> -
> -       return reciprocal_scale(hash, q->flows_cnt);
> +       return reciprocal_scale(skb_get_hash(skb), q->flows_cnt);

So the perturbing of the hash is no longer needed for fq_codel?

>  }
>
>  static unsigned int fq_codel_classify(struct sk_buff *skb, struct Qdisc *sch,
> @@ -482,7 +479,6 @@ static int fq_codel_init(struct Qdisc *sch, struct nlattr *opt)
>         q->memory_limit = 32 << 20; /* 32 MBytes */
>         q->drop_batch_size = 64;
>         q->quantum = psched_mtu(qdisc_dev(sch));
> -       q->perturbation = prandom_u32();
>         INIT_LIST_HEAD(&q->new_flows);
>         INIT_LIST_HEAD(&q->old_flows);
>         codel_params_init(&q->cparams);
> --
> 2.9.3
>
