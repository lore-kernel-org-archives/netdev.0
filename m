From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH v3 net 1/1] net sched actions: fix GETing actions
Date: Tue, 13 Sep 2016 09:20:39 -0700
Message-ID: <CAM_iQpWDNzceBLqzVibyyqExk5MXajJCt6Yu3KkC2r2poU0DQQ@mail.gmail.com>
References: <1473721658-6034-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:36615 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754885AbcIMQVB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Sep 2016 12:21:01 -0400
Received: by mail-it0-f65.google.com with SMTP id n143so1662351ita.3
        for <netdev@vger.kernel.org>; Tue, 13 Sep 2016 09:21:00 -0700 (PDT)
In-Reply-To: <1473721658-6034-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 12, 2016 at 4:07 PM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> From: Jamal Hadi Salim <jhs@mojatatu.com>
>
> With the batch changes that translated transient actions into
> a temporary list lost in the translation was the fact that
> tcf_action_destroy() will eventually delete the action from
> the permanent location if the refcount is zero.
>
> Example of what broke:
> ...add a gact action to drop
> sudo $TC actions add action drop index 10
> ...now retrieve it, looks good
> sudo $TC actions get action gact index 10
> ...retrieve it again and find it is gone!
> sudo $TC actions get action gact index 10
>
> Fixes:
> commit 22dc13c837c3 ("net_sched: convert tcf_exts from list to pointer array"),
> commit 824a7e8863b3 ("net_sched: remove an unnecessary list_del()")
> commit f07fed82ad79 ("net_sched: remove the leftover cleanup_a()")
>
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
> ---
>  net/sched/act_api.c | 19 +++++++++++++++++++
>  1 file changed, 19 insertions(+)
>
> diff --git a/net/sched/act_api.c b/net/sched/act_api.c
> index d09d068..50720b1 100644
> --- a/net/sched/act_api.c
> +++ b/net/sched/act_api.c
> @@ -592,6 +592,16 @@ err_out:
>         return ERR_PTR(err);
>  }
>
> +static void cleanup_a(struct list_head *actions, int ovr)
> +{
> +       struct tc_action *a;
> +
> +       list_for_each_entry(a, actions, list) {
> +               if (ovr)
> +                       a->tcfa_refcnt -= 1;
> +       }
> +}
> +
>  int tcf_action_init(struct net *net, struct nlattr *nla,
>                                   struct nlattr *est, char *name, int ovr,
>                                   int bind, struct list_head *actions)
> @@ -612,8 +622,15 @@ int tcf_action_init(struct net *net, struct nlattr *nla,
>                         goto err;
>                 }
>                 act->order = i;
> +               if (ovr)
> +                       act->tcfa_refcnt += 1;
>                 list_add_tail(&act->list, actions);
>         }
> +
> +       /* Remove the temp refcnt which was necessary to protect against
> +        * destroying an existing action which was being replaced
> +        */
> +       cleanup_a(actions, ovr);
>         return 0;

I am still trying to understand this piece, so here you hold the refcnt
for the same action used by the later iteration? Otherwise there is
almost none user inbetween hold and release...

The comment you add is not clear to me, we use RTNL/RCU to
sync destroy and replace, so how could that happen?

Thanks.
