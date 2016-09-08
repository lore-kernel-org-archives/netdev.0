From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net 1/1] net sched actions: fix GETing actions
Date: Thu, 8 Sep 2016 10:12:20 -0700
Message-ID: <CAM_iQpUrbikYYfttzEn8AihpSmXtwrdnV-949BzVH_0DdwW37g@mail.gmail.com>
References: <1473336754-24930-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:34039 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965152AbcIHRMm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 13:12:42 -0400
Received: by mail-oi0-f65.google.com with SMTP id x125so3167069oia.1
        for <netdev@vger.kernel.org>; Thu, 08 Sep 2016 10:12:41 -0700 (PDT)
In-Reply-To: <1473336754-24930-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 8, 2016 at 5:12 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> From: Jamal Hadi Salim <jhs@mojatatu.com>
>
> Example of what broke:
> ...add a gact action to drop
> sudo $TC actions add action drop index 10
> ...now retrieve it, looks good
> sudo $TC actions get action gact index 10
> ...retrieve it again and find it is gone!
> sudo $TC actions get action gact index 10

This changelog sucks, it only tells the phenomenon of the bug,
never explains what causes the bug, which is crucial for review.

>
> Fixes: f07fed82ad79 ("net_sched: remove the leftover cleanup_a())
>
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
> ---
>  net/sched/act_api.c | 20 +++++++++++++++++---
>  1 file changed, 17 insertions(+), 3 deletions(-)
>
> diff --git a/net/sched/act_api.c b/net/sched/act_api.c
> index d09d068..d4b4704 100644
> --- a/net/sched/act_api.c
> +++ b/net/sched/act_api.c
> @@ -612,6 +612,8 @@ int tcf_action_init(struct net *net, struct nlattr *nla,
>                         goto err;
>                 }
>                 act->order = i;
> +               if (ovr)
> +                       act->tcfa_refcnt+=1;

This looks like not relevant to commit f07fed82ad79 at all?


>                 list_add_tail(&act->list, actions);
>         }
>         return 0;
> @@ -856,6 +858,15 @@ tcf_del_notify(struct net *net, struct nlmsghdr *n, struct list_head *actions,
>         return ret;
>  }
>
> +static void cleanup_a(struct list_head *actions)
> +{
> +       struct tc_action *a, *tmp;
> +
> +       list_for_each_entry_safe(a, tmp, actions, list) {
> +               list_del(&a->list);
> +       }

After my patches, all the action lists are now temporary,
you didn't explain why we should remove an action from
a temporary list, they should just come and go, since
we call ist_add() every time.

Did see any list corruption or kernel crash (your changelog
didn't say so)?


> +}
> +
>  static int
>  tca_action_gd(struct net *net, struct nlattr *nla, struct nlmsghdr *n,
>               u32 portid, int event)
> @@ -883,6 +894,7 @@ tca_action_gd(struct net *net, struct nlattr *nla, struct nlmsghdr *n,
>                         goto err;
>                 }
>                 act->order = i;
> +               act->tcfa_refcnt+=1;


Maybe we only need to fixup the refcnt without touching list,
from my quick observation to your bug report (again, you didn't explain).


>                 list_add_tail(&act->list, &actions);
>         }
>
> @@ -892,10 +904,12 @@ tca_action_gd(struct net *net, struct nlattr *nla, struct nlmsghdr *n,
>                 ret = tcf_del_notify(net, n, &actions, portid);
>                 if (ret)
>                         goto err;
> +               cleanup_a(&actions);
>                 return ret;
>         }
>  err:
>         tcf_action_destroy(&actions, 0);
> +       cleanup_a(&actions);
>         return ret;
>  }
>
> @@ -931,10 +945,10 @@ tcf_action_add(struct net *net, struct nlattr *nla, struct nlmsghdr *n,
>         LIST_HEAD(actions);
>
>         ret = tcf_action_init(net, nla, NULL, NULL, ovr, 0, &actions);
> -       if (ret)
> -               return ret;
>
> -       return tcf_add_notify(net, n, &actions, portid);
> +       ret = tcf_add_notify(net, n, &actions, portid);
> +       cleanup_a(&actions);
> +       return ret;
>  }
>
>  static int tc_ctl_action(struct sk_buff *skb, struct nlmsghdr *n)
> --
> 1.9.1
>
