From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH v2 net 1/1] net sched actions: fix GETing actions
Date: Mon, 12 Sep 2016 10:18:15 -0700
Message-ID: <CAM_iQpX3j_ejd1MjnaYkq0OL8B_gsN+SEoFk-8Srp+nWxKHzQg@mail.gmail.com>
References: <1473675692-8490-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:32993 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751321AbcILRTQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2016 13:19:16 -0400
Received: by mail-oi0-f67.google.com with SMTP id y2so19003447oie.0
        for <netdev@vger.kernel.org>; Mon, 12 Sep 2016 10:19:16 -0700 (PDT)
In-Reply-To: <1473675692-8490-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 12, 2016 at 3:21 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> From: Jamal Hadi Salim <jhs@mojatatu.com>
>
> With the batch changes that translated transient actions into
> a temporary list we lost in the translation the fact that
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
> 22dc13c837c3 ("net_sched: convert tcf_exts from list to pointer array"),
> 824a7e8863b3 ("net_sched: remove an unnecessary list_del()")
> f07fed82ad79 ("net_sched: remove the leftover cleanup_a()")
>
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
> ---
>  net/sched/act_api.c | 19 +++++++++++++++++++
>  1 file changed, 19 insertions(+)
>
> diff --git a/net/sched/act_api.c b/net/sched/act_api.c
> index d09d068..63b8167 100644
> --- a/net/sched/act_api.c
> +++ b/net/sched/act_api.c
> @@ -592,6 +592,16 @@ err_out:
>         return ERR_PTR(err);
>  }
>
> +static void cleanup_a(struct list_head *actions, int ovr)
> +{
> +       struct tc_action *a, *tmp;
> +
> +       list_for_each_entry_safe(a, tmp, actions, list) {


No need the safe version.

> +               if (ovr)
> +                       a->tcfa_refcnt-=1;

How about tcfa_bindcnt?

I hate to point out coding style issue, but since you need to update
the patch anyway, please add two spaces surround '-='.

I think checkpatch.pl should be able to catch this.

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

Need to check this boolean? It looks like we need this for !ovr case too?


> +                       act->tcfa_refcnt+=1;


Ditto for coding style.

>                 list_add_tail(&act->list, actions);
>         }
> +
> +       /* Remove the temp refcnt which was necessary to protect against
> +        * destroying an existing action which was being replaced
> +        */
> +       cleanup_a(actions, ovr);
>         return 0;
>
>  err:
> @@ -883,6 +900,8 @@ tca_action_gd(struct net *net, struct nlattr *nla, struct nlmsghdr *n,
>                         goto err;
>                 }
>                 act->order = i;
> +               if (event == RTM_GETACTION)
> +                       act->tcfa_refcnt+=1;

Ditto.


>                 list_add_tail(&act->list, &actions);
>         }
>


Thanks.
