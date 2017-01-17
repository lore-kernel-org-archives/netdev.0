From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net 1/1] net sched actions: fix refcnt when GETing of
 action after bind
Date: Tue, 17 Jan 2017 10:17:08 -0800
Message-ID: <CAM_iQpURppLMupbxCSqmZe866APGrcYficzaOTFNyzheQrrePg@mail.gmail.com>
References: <1484493246-10911-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33697 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751162AbdAQSRa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 13:17:30 -0500
Received: by mail-wm0-f67.google.com with SMTP id r144so40365894wme.0
        for <netdev@vger.kernel.org>; Tue, 17 Jan 2017 10:17:29 -0800 (PST)
In-Reply-To: <1484493246-10911-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 15, 2017 at 7:14 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> diff --git a/net/sched/act_api.c b/net/sched/act_api.c
> index 2095c83..e10456ef6f 100644
> --- a/net/sched/act_api.c
> +++ b/net/sched/act_api.c
> @@ -900,8 +900,6 @@ static int tca_action_flush(struct net *net, struct nlattr *nla,
>                         goto err;
>                 }
>                 act->order = i;
> -               if (event == RTM_GETACTION)
> -                       act->tcfa_refcnt++;
>                 list_add_tail(&act->list, &actions);
>         }
>
> @@ -914,7 +912,8 @@ static int tca_action_flush(struct net *net, struct nlattr *nla,
>                 return ret;
>         }
>  err:
> -       tcf_action_destroy(&actions, 0);
> +       if (event != RTM_GETACTION)
> +               tcf_action_destroy(&actions, 0);

Why this check for RTM_GETACTION? It does not make sense
at least for the error case, that is, when tcf_action_get_1() fails
in the middle of the loop, all the previous ones should be destroyed
no matter it's GETACTION or DELACTION...

Also, for the non-error case of GETACTION, they should be
destroyed too after dumping to user-space, otherwise there is no
way to use them since 'actions' is local to that function.

I thought in commit aecc5cefc389 you grab that refcnt on purpose.
