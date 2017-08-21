From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] net_sched/hhf: update hierarchical backlog when drop packet
Date: Mon, 21 Aug 2017 09:52:12 -0700
Message-ID: <CAM_iQpU4bQsNVHrooO1Mu_nmUvaD5WxQNmKiJBxOSmOtBBWvcQ@mail.gmail.com>
References: <150330315167.155003.1998024290510727078.stgit@buzz>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Jiri Pirko <jiri@resnulli.us>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:34597 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753546AbdHUQwd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Aug 2017 12:52:33 -0400
Received: by mail-pg0-f68.google.com with SMTP id i12so9272251pgr.1
        for <netdev@vger.kernel.org>; Mon, 21 Aug 2017 09:52:33 -0700 (PDT)
In-Reply-To: <150330315167.155003.1998024290510727078.stgit@buzz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 21, 2017 at 1:12 AM, Konstantin Khlebnikov
<khlebnikov@yandex-team.ru> wrote:
> When hhf_enqueue() drops packet from another bucket it
> have to update backlog at upper qdiscs too.
>
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> Fixes: 2ccccf5fb43f ("net_sched: update hierarchical backlog too")
> ---
>  net/sched/sch_hhf.c |    5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
>
> diff --git a/net/sched/sch_hhf.c b/net/sched/sch_hhf.c
> index 51d3ba682af9..c8d84436e427 100644
> --- a/net/sched/sch_hhf.c
> +++ b/net/sched/sch_hhf.c
> @@ -406,8 +406,11 @@ static int hhf_enqueue(struct sk_buff *skb, struct Qdisc *sch,
>         /* Return Congestion Notification only if we dropped a packet from this
>          * bucket.
>          */
> -       if (hhf_drop(sch, to_free) == idx)
> +       if (hhf_drop(sch, to_free) == idx) {
> +               qdisc_tree_reduce_backlog(sch, 0,


It should be 1 here instead of 0, because one packet is dropped
even if hhf_drop() == idx.


> +                                         prev_backlog - sch->qstats.backlog);
>                 return NET_XMIT_CN;
> +       }
>
>         /* As we dropped a packet, better let upper stack know this. */
>         qdisc_tree_reduce_backlog(sch, 1, prev_backlog - sch->qstats.backlog);
>
