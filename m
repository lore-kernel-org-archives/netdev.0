From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCHv2] skbedit: allow the user to specify bitmask for mark
Date: Wed, 23 Jul 2014 10:15:50 -0700
Message-ID: <CAHA+R7O_=MY4ehGPUkKru2HA11RZ7efjHhgFv44gyjdtLE2c7w@mail.gmail.com>
References: <1406102589-8441-1-git-send-email-antonio@meshcoding.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	sergei.shtylyov@cogentembedded.com,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Antonio Quartulli <antonio@open-mesh.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Antonio Quartulli <antonio@meshcoding.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f179.google.com ([209.85.217.179]:51220 "EHLO
	mail-lb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932718AbaGWRPw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2014 13:15:52 -0400
Received: by mail-lb0-f179.google.com with SMTP id v6so1160136lbi.10
        for <netdev@vger.kernel.org>; Wed, 23 Jul 2014 10:15:51 -0700 (PDT)
In-Reply-To: <1406102589-8441-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 23, 2014 at 1:03 AM, Antonio Quartulli
<antonio@meshcoding.com> wrote:
> From: Antonio Quartulli <antonio@open-mesh.com>
>
> The user may want to use only some bits of the skb mark in
> his skbedit rules because the remaining part might be used by
> something else.
>
> Introduce the "mask" parameter to the skbedit actor in order
> to implement such functionality.
>
> When the mask is specified, only those bits selected by the
> latter are altered really changed by the actor, while the
> rest is left untouched.
>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Antonio Quartulli <antonio@open-mesh.com>
> ---
>
> Jamal, I'm not adding your Signed-off because the patches has new part with
> respect to v1.
>
>
> Changes from v1:
> - use '&=' tcf_skbedit() to clean the mark
> - extend tcf_skbedit_dump() in order to send the mask as well
>
>
>
>
>
>  include/net/tc_act/tc_skbedit.h        |  1 +
>  include/uapi/linux/tc_act/tc_skbedit.h |  2 ++
>  net/sched/act_skbedit.c                | 24 +++++++++++++++++++++---
>  3 files changed, 24 insertions(+), 3 deletions(-)
>
> diff --git a/include/net/tc_act/tc_skbedit.h b/include/net/tc_act/tc_skbedit.h
> index 0df9a0d..a385c68 100644
> --- a/include/net/tc_act/tc_skbedit.h
> +++ b/include/net/tc_act/tc_skbedit.h
> @@ -26,6 +26,7 @@ struct tcf_skbedit {
>         u32                     flags;
>         u32                     priority;
>         u32                     mark;
> +       u32                     mask;
>         u16                     queue_mapping;
>         /* XXX: 16-bit pad here? */
>  };
> diff --git a/include/uapi/linux/tc_act/tc_skbedit.h b/include/uapi/linux/tc_act/tc_skbedit.h
> index 7a2e910..c7c8c5f 100644
> --- a/include/uapi/linux/tc_act/tc_skbedit.h
> +++ b/include/uapi/linux/tc_act/tc_skbedit.h
> @@ -27,6 +27,7 @@
>  #define SKBEDIT_F_PRIORITY             0x1
>  #define SKBEDIT_F_QUEUE_MAPPING                0x2
>  #define SKBEDIT_F_MARK                 0x4
> +#define SKBEDIT_F_MASK                 0x8
>
>  struct tc_skbedit {
>         tc_gen;
> @@ -39,6 +40,7 @@ enum {
>         TCA_SKBEDIT_PRIORITY,
>         TCA_SKBEDIT_QUEUE_MAPPING,
>         TCA_SKBEDIT_MARK,
> +       TCA_SKBEDIT_MASK,
>         __TCA_SKBEDIT_MAX
>  };
>  #define TCA_SKBEDIT_MAX (__TCA_SKBEDIT_MAX - 1)
> diff --git a/net/sched/act_skbedit.c b/net/sched/act_skbedit.c
> index fcfeeaf..6111b06 100644
> --- a/net/sched/act_skbedit.c
> +++ b/net/sched/act_skbedit.c
> @@ -43,8 +43,12 @@ static int tcf_skbedit(struct sk_buff *skb, const struct tc_action *a,
>         if (d->flags & SKBEDIT_F_QUEUE_MAPPING &&
>             skb->dev->real_num_tx_queues > d->queue_mapping)
>                 skb_set_queue_mapping(skb, d->queue_mapping);
> -       if (d->flags & SKBEDIT_F_MARK)
> -               skb->mark = d->mark;
> +       if (d->flags & SKBEDIT_F_MARK) {
> +               /* unset all the bits in the mask */
> +               skb->mark &= ~d->mask;
> +               /* assign the mark value for the masked bit only */
> +               skb->mark |= d->mark & d->mask;
> +       }
>
>         spin_unlock(&d->tcf_lock);
>         return d->tcf_action;
> @@ -55,6 +59,7 @@ static const struct nla_policy skbedit_policy[TCA_SKBEDIT_MAX + 1] = {
>         [TCA_SKBEDIT_PRIORITY]          = { .len = sizeof(u32) },
>         [TCA_SKBEDIT_QUEUE_MAPPING]     = { .len = sizeof(u16) },
>         [TCA_SKBEDIT_MARK]              = { .len = sizeof(u32) },
> +       [TCA_SKBEDIT_MASK]              = { .len = sizeof(u32) },
>  };
>
>  static int tcf_skbedit_init(struct net *net, struct nlattr *nla,
> @@ -64,7 +69,7 @@ static int tcf_skbedit_init(struct net *net, struct nlattr *nla,
>         struct nlattr *tb[TCA_SKBEDIT_MAX + 1];
>         struct tc_skbedit *parm;
>         struct tcf_skbedit *d;
> -       u32 flags = 0, *priority = NULL, *mark = NULL;
> +       u32 flags = 0, *priority = NULL, *mark = NULL, *mask = NULL;
>         u16 *queue_mapping = NULL;
>         int ret = 0, err;
>
> @@ -93,6 +98,11 @@ static int tcf_skbedit_init(struct net *net, struct nlattr *nla,
>                 mark = nla_data(tb[TCA_SKBEDIT_MARK]);
>         }
>
> +       if (tb[TCA_SKBEDIT_MASK] != NULL) {
> +               flags |= SKBEDIT_F_MASK;
> +               mask = nla_data(tb[TCA_SKBEDIT_MASK]);
> +       }
> +
>         if (!flags)
>                 return -EINVAL;
>
> @@ -123,6 +133,10 @@ static int tcf_skbedit_init(struct net *net, struct nlattr *nla,
>                 d->queue_mapping = *queue_mapping;
>         if (flags & SKBEDIT_F_MARK)
>                 d->mark = *mark;
> +       /* default behaviour is to use all the bits */
> +       d->mask = 0xffffffff;
> +       if (flags & SKBEDIT_F_MASK)
> +               d->mask = *mask;
>
>         d->tcf_action = parm->action;
>
> @@ -160,6 +174,10 @@ static int tcf_skbedit_dump(struct sk_buff *skb, struct tc_action *a,
>             nla_put(skb, TCA_SKBEDIT_MARK, sizeof(d->mark),
>                     &d->mark))
>                 goto nla_put_failure;
> +       if ((d->flags & SKBEDIT_F_MASK) &&
> +           nla_put(skb, TCA_SKBEDIT_MASK, sizeof(d->mask),
> +                   &d->mark))
> +               goto nla_put_failure;
>         t.install = jiffies_to_clock_t(jiffies - d->tcf_tm.install);
>         t.lastuse = jiffies_to_clock_t(jiffies - d->tcf_tm.lastuse);
>         t.expires = jiffies_to_clock_t(d->tcf_tm.expires);
> --
> 1.8.5.5
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
