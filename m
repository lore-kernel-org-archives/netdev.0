From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH,v2 net] net: sched: validate that class is found in qdisc_tree_decrease_qlen
Date: Tue, 21 Jul 2015 11:12:12 -0700
Message-ID: <CAM_iQpWWzMFLuLsJZD4rJLW7rNWNOEotrjj7o4Z+0Pr330M2Fw@mail.gmail.com>
References: <1437421248-2796139-1-git-send-email-agartrell@fb.com>
	<55AE1939.105@mojatatu.com>
	<1437475945.9913.7.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Alex Gartrell <agartrell@fb.com>,
	David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	kernel-team@fb.com, stable@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f54.google.com ([209.85.215.54]:35947 "EHLO
	mail-la0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933337AbbGUSMO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2015 14:12:14 -0400
In-Reply-To: <1437475945.9913.7.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 21, 2015 at 3:52 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2015-07-21 at 06:04 -0400, Jamal Hadi Salim wrote:
>
>> It is worrisome to fix the core code for this. The root cause seems to
>> be codel. Dont have time but in general, reset would be something like:
>>
>> struct fq_codel_sched_data *q = qdisc_priv(sch);
>> qdisc_reset(q)
>
> This only works for very simple qdisc with one queue.
>
>>
>> or something along those lines...
>> But certainly dequeue semantics dont seem right there..
>
> Well, reset() is trivial to implement like this
>
> while (skb = local_dequeue(sch)) {
>         kfree_skb(skb);
> }
>
> And I guess I copy/pasted sfq code here, because I was lazy.
>
> But yes, qdisc_tree_decrease_qlen() would have to be not called.


Hmm, so the semantic is each qdisc resets qlen for its own
and calls qdisc_reset() to reset its leaf qdisc's, that makes sense
for me.

>
> It seems I coded fq_reset() differently.
>
> Alex, please try instead :
>
> diff --git a/net/sched/sch_fq_codel.c b/net/sched/sch_fq_codel.c
> index 21ca33c9f036..3f0320ab6029 100644
> --- a/net/sched/sch_fq_codel.c
> +++ b/net/sched/sch_fq_codel.c
> @@ -288,10 +288,21 @@ begin:
>
>  static void fq_codel_reset(struct Qdisc *sch)
>  {
> -       struct sk_buff *skb;
> +       struct fq_codel_sched_data *q = qdisc_priv(sch);
> +       int i;
>
> -       while ((skb = fq_codel_dequeue(sch)) != NULL)
> -               kfree_skb(skb);
> +       INIT_LIST_HEAD(&q->new_flows);
> +       INIT_LIST_HEAD(&q->old_flows);
> +       for (i = 0; i < q->flows_cnt; i++) {
> +               struct fq_codel_flow *flow = q->flows + i;
> +
> +               while (flow->head)
> +                       kfree_skb(dequeue_head(flow));
> +
> +               INIT_LIST_HEAD(&flow->flowchain);


You probably need to call codel_vars_init(&flow->cvars) as well.

> +       }
> +       memset(q->backlogs, 0, q->flows_cnt * sizeof(u32));
> +       sch->q.qlen = 0;
>  }
>
>  static const struct nla_policy fq_codel_policy[TCA_FQ_CODEL_MAX + 1] = {
>
>
>

Thanks.
