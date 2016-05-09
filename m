From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [net-next PATCH v2 1/6] net sched: vlan action fix late binding
Date: Sun, 8 May 2016 20:08:41 -0700
Message-ID: <CAM_iQpVtk1AowsH_jDz24yNqAZTCOPtMk=KM0dhFtYUJLfOk4Q@mail.gmail.com>
References: <1462728392-28489-1-git-send-email-jhs@emojatatu.com> <1462728392-28489-2-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f170.google.com ([209.85.161.170]:32798 "EHLO
	mail-yw0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750879AbcEIDJC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2016 23:09:02 -0400
Received: by mail-yw0-f170.google.com with SMTP id t10so273641571ywa.0
        for <netdev@vger.kernel.org>; Sun, 08 May 2016 20:09:01 -0700 (PDT)
In-Reply-To: <1462728392-28489-2-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 8, 2016 at 10:26 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> diff --git a/net/sched/act_vlan.c b/net/sched/act_vlan.c
> index c1682ab..352653f 100644
> --- a/net/sched/act_vlan.c
> +++ b/net/sched/act_vlan.c
> @@ -77,7 +77,7 @@ static int tcf_vlan_init(struct net *net, struct nlattr *nla,
>         int action;
>         __be16 push_vid = 0;
>         __be16 push_proto = 0;
> -       int ret = 0;
> +       int ret = 0, aexists = 0;
>         int err;
>
>         if (!nla)
> @@ -90,15 +90,25 @@ static int tcf_vlan_init(struct net *net, struct nlattr *nla,
>         if (!tb[TCA_VLAN_PARMS])
>                 return -EINVAL;
>         parm = nla_data(tb[TCA_VLAN_PARMS]);
> +       aexists = tcf_hash_check(tn, parm->index, a, bind);


I think 'exists' is a better name than 'aexists', shorter and clear.


> +       if (aexists && bind)
> +               return 0;
> +
>         switch (parm->v_action) {
>         case TCA_VLAN_ACT_POP:
>                 break;
>         case TCA_VLAN_ACT_PUSH:
> -               if (!tb[TCA_VLAN_PUSH_VLAN_ID])
> +               if (!tb[TCA_VLAN_PUSH_VLAN_ID]) {
> +                       if (aexists)
> +                               tcf_hash_release(a, bind);
>                         return -EINVAL;
> +               }
>                 push_vid = nla_get_u16(tb[TCA_VLAN_PUSH_VLAN_ID]);
> -               if (push_vid >= VLAN_VID_MASK)
> +               if (push_vid >= VLAN_VID_MASK) {
> +                       if (aexists)
> +                               tcf_hash_release(a, bind);
>                         return -ERANGE;
> +               }
>
>                 if (tb[TCA_VLAN_PUSH_VLAN_PROTOCOL]) {
>                         push_proto = nla_get_be16(tb[TCA_VLAN_PUSH_VLAN_PROTOCOL]);
> @@ -114,11 +124,13 @@ static int tcf_vlan_init(struct net *net, struct nlattr *nla,
>                 }
>                 break;
>         default:
> +               if (aexists)
> +                       tcf_hash_release(a, bind);


Introduce a goto to reduce duplicated cleanup code?


>                 return -EINVAL;
>         }
>         action = parm->v_action;
>
> -       if (!tcf_hash_check(tn, parm->index, a, bind)) {
> +       if (!aexists) {
>                 ret = tcf_hash_create(tn, parm->index, est, a,
>                                       sizeof(*v), bind, false);
>                 if (ret)
> @@ -126,8 +138,6 @@ static int tcf_vlan_init(struct net *net, struct nlattr *nla,
>
>                 ret = ACT_P_CREATED;
>         } else {
> -               if (bind)
> -                       return 0;
>                 tcf_hash_release(a, bind);
>                 if (!ovr)
>                         return -EEXIST;


The rest looks good to me.
