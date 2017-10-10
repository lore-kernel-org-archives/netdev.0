From: Alexander Aring <aring@mojatatu.com>
Subject: Re: [RFC net 1/1] net: sched: act: fix rcu race in dump
Date: Tue, 10 Oct 2017 08:39:42 -0400
Message-ID: <CAOHTApinT4Q1PiV0J5snyS2qH0ZRW6AktmNDJJKG16=9ivq1kQ@mail.gmail.com>
References: <20171010123218.5251-1-aring@mojatatu.com> <20171010123218.5251-2-aring@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        =?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
        netdev@vger.kernel.org, Manish Kurup <kurup.manish@gmail.com>,
        Brenda Butler <bjb@mojatatu.com>,
        Alexander Aring <aring@mojatatu.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f193.google.com ([209.85.217.193]:35378 "EHLO
        mail-ua0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751434AbdJJMjn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 08:39:43 -0400
Received: by mail-ua0-f193.google.com with SMTP id d3so1387800uai.2
        for <netdev@vger.kernel.org>; Tue, 10 Oct 2017 05:39:43 -0700 (PDT)
In-Reply-To: <20171010123218.5251-2-aring@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Tue, Oct 10, 2017 at 8:32 AM, Alexander Aring <aring@mojatatu.com> wrote:
> This patch fixes an issue with kfree_rcu which is not protected by RTNL
> lock. It could be that the current assigned rcu pointer will be freed by
> kfree_rcu while dump callback is running.
>
> To prevent this, we call rcu_synchronize at first. Then we are sure all
> latest rcu functions e.g. rcu_assign_pointer and kfree_rcu in init are
> done. After rcu_synchronize we dereference under RTNL lock which is also
> held in init function, which means no other rcu_assign_pointer or
> kfree_rcu will occur.
>
> To call rcu_synchronize will also prevent weird behaviours by doing over
> netlink:
>
>  - set params A
>  - set params B
>  - dump params
>   \--> will dump params A
>
> This could be a unlikely case that the last rcu_assign_pointer was not
> happened before dump callback.
>
> Signed-off-by: Alexander Aring <aring@mojatatu.com>
> ---
>  net/sched/act_skbmod.c | 7 ++++++-
>  1 file changed, 6 insertions(+), 1 deletion(-)
>
> diff --git a/net/sched/act_skbmod.c b/net/sched/act_skbmod.c
> index b642ad3d39dd..231e07bca384 100644
> --- a/net/sched/act_skbmod.c
> +++ b/net/sched/act_skbmod.c
> @@ -198,7 +198,7 @@ static int tcf_skbmod_dump(struct sk_buff *skb, struct tc_action *a,
>  {
>         struct tcf_skbmod *d = to_skbmod(a);
>         unsigned char *b = skb_tail_pointer(skb);
> -       struct tcf_skbmod_params  *p = rtnl_dereference(d->skbmod_p);
> +       struct tcf_skbmod_params  *p;
>         struct tc_skbmod opt = {
>                 .index   = d->tcf_index,
>                 .refcnt  = d->tcf_refcnt - ref,
> @@ -207,6 +207,11 @@ static int tcf_skbmod_dump(struct sk_buff *skb, struct tc_action *a,
>         };
>         struct tcf_t t;
>
> +       /* wait until last rcu_assign_pointer/kfree_rcu is done */
> +       rcu_synchronize();

... and next time I should use the right function:

s/rcu_synchronize/synchronize_rcu/

anyway there exists a reason why sent it as RFC. :-)

Thanks.

- Alex
