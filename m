From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [net-next PATCH v2 5/6] net sched: skbedit action fix late binding
Date: Sun, 8 May 2016 20:28:50 -0700
Message-ID: <CAM_iQpXTTJjs0HBvRDzVY4eHVrGenq2bzkwCQo92vwWV0e9LUA@mail.gmail.com>
References: <1462728392-28489-1-git-send-email-jhs@emojatatu.com> <1462728392-28489-6-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f174.google.com ([209.85.161.174]:33522 "EHLO
	mail-yw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750905AbcEID3L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2016 23:29:11 -0400
Received: by mail-yw0-f174.google.com with SMTP id t10so273920064ywa.0
        for <netdev@vger.kernel.org>; Sun, 08 May 2016 20:29:10 -0700 (PDT)
In-Reply-To: <1462728392-28489-6-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 8, 2016 at 10:26 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> From: Jamal Hadi Salim <jhs@mojatatu.com>
>
> The process below was broken and is fixed with this patch.
>
> //add a skbedit action and give it an instance id of 1
> sudo tc actions add action skbedit mark 10 index 1
> //create a filter which binds to skbedit action id 1
> sudo tc filter add dev $DEV parent ffff: protocol ip prio 1 u32\
> match ip dst 17.0.0.1/32 flowid 1:10 action skbedit index 1
>
> Message before fix was:
> RTNETLINK answers: Invalid argument
> We have an error talking to the kernel
>
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
> ---
>  net/sched/act_skbedit.c | 22 +++++++++++++++-------
>  1 file changed, 15 insertions(+), 7 deletions(-)
>
> diff --git a/net/sched/act_skbedit.c b/net/sched/act_skbedit.c
> index 51b2499..784b478 100644
> --- a/net/sched/act_skbedit.c
> +++ b/net/sched/act_skbedit.c
> @@ -69,7 +69,7 @@ static int tcf_skbedit_init(struct net *net, struct nlattr *nla,
>         struct tcf_skbedit *d;
>         u32 flags = 0, *priority = NULL, *mark = NULL;
>         u16 *queue_mapping = NULL;
> -       int ret = 0, err;
> +       int ret = 0, err, aexists = 0;
>
>         if (nla == NULL)
>                 return -EINVAL;
> @@ -96,12 +96,22 @@ static int tcf_skbedit_init(struct net *net, struct nlattr *nla,
>                 mark = nla_data(tb[TCA_SKBEDIT_MARK]);
>         }
>
> -       if (!flags)
> -               return -EINVAL;
> -
>         parm = nla_data(tb[TCA_SKBEDIT_PARMS]);
>
> -       if (!tcf_hash_check(tn, parm->index, a, bind)) {
> +       aexists = tcf_hash_check(tn, parm->index, a, bind);
> +
> +       /* if action exists and this is a late filter bind, no need
> +        * to continue processing
> +       */

This comment looks useless, at least for me, because the code
is already clear.


> +       if (aexists && bind)
> +                       return 0;


One extra tab?


> +
> +       if (!flags) {
> +               tcf_hash_release(a, bind);
> +               return -EINVAL;
> +       }
> +
> +       if (!aexists) {
>                 ret = tcf_hash_create(tn, parm->index, est, a,
>                                       sizeof(*d), bind, false);
>                 if (ret)
> @@ -111,8 +121,6 @@ static int tcf_skbedit_init(struct net *net, struct nlattr *nla,
>                 ret = ACT_P_CREATED;
>         } else {
>                 d = to_skbedit(a);
> -               if (bind)
> -                       return 0;
>                 tcf_hash_release(a, bind);
>                 if (!ovr)
>                         return -EEXIST;
> --
> 1.9.1
>
