From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [RFC PATCH 14/15] net: sched: make qstats per cpu
Date: Wed, 30 Apr 2014 10:08:01 -0700
Message-ID: <CAM_iQpUMJcP3guRvCPBGqfzTbVn+t4uZ8eETGVnwk5Y88ZJi_A@mail.gmail.com>
References: <20140430163250.9021.21199.stgit@nitbit.x32>
	<20140430164051.9021.77279.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f176.google.com ([209.85.214.176]:57246 "EHLO
	mail-ob0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758895AbaD3RIC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Apr 2014 13:08:02 -0400
Received: by mail-ob0-f176.google.com with SMTP id wp4so2285491obc.7
        for <netdev@vger.kernel.org>; Wed, 30 Apr 2014 10:08:01 -0700 (PDT)
In-Reply-To: <20140430164051.9021.77279.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 30, 2014 at 9:40 AM, John Fastabend
<john.fastabend@gmail.com> wrote:
> diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
> index 1a55e19..6d67a27 100644
> --- a/include/net/sch_generic.h
> +++ b/include/net/sch_generic.h
> @@ -92,7 +92,10 @@ struct Qdisc {
>                 struct gnet_stats_basic_cpu __percpu *cpu_bstats;
>         } bstats_qdisc;
>         unsigned int            __state;
> -       struct gnet_stats_queue qstats;
> +       union {
> +               struct gnet_stats_queue qstats;
> +               struct gnet_stats_queue __percpu *cpu_qstats;
> +       } qstats_qdisc;
>         struct rcu_head         rcu_head;
>         int                     padded;
>         atomic_t                refcnt;


So only ingress qdisc uses ->cpu_qstats, the rest still uses
->qstats. Hmm, doesn't this mean ingress qdisc should init
->cpu_qstats in its ->init()?

[...]

> diff --git a/net/sched/sch_ingress.c b/net/sched/sch_ingress.c
> index 5700c27..2423d7b 100644
> --- a/net/sched/sch_ingress.c
> +++ b/net/sched/sch_ingress.c
> @@ -58,6 +58,7 @@ static struct tcf_proto **ingress_find_tcf(struct Qdisc *sch, unsigned long cl)
>  static int ingress_enqueue(struct sk_buff *skb, struct Qdisc *sch)
>  {
>         struct ingress_qdisc_data *p = qdisc_priv(sch);
> +       struct gnet_stats_queue *qstats;
>         struct tcf_result res;
>         struct tcf_proto *fl = rcu_dereference_bh(p->filter_list);
>         int result;
> @@ -68,7 +69,8 @@ static int ingress_enqueue(struct sk_buff *skb, struct Qdisc *sch)
>         switch (result) {
>         case TC_ACT_SHOT:
>                 result = TC_ACT_SHOT;
> -               sch->qstats.drops++;
> +               qstats = this_cpu_ptr(sch->qstats_qdisc.cpu_qstats);
> +               qstats->drops++;
>                 break;
>         case TC_ACT_STOLEN:
>         case TC_ACT_QUEUED:

I don't see you call alloc_percpu() and free_percpu() in sch_ingress.c.
