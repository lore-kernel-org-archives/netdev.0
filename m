From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next 1/9] sched: add helper for updating statistics on
 all actions
Date: Thu, 1 Jun 2017 23:54:54 +0300
Message-ID: <CAJ3xEMiZU69RpXxVNYCyt7ZThicHmzM=r8Oswq6QLW-y1CAhEQ@mail.gmail.com>
References: <20170531150651.16873-1-jakub.kicinski@netronome.com> <20170531150651.16873-2-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
        oss-drivers@netronome.com, Jiri Pirko <jiri@mellanox.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:35076 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751029AbdFAUzB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2017 16:55:01 -0400
Received: by mail-oi0-f68.google.com with SMTP id j66so5867588oib.2
        for <netdev@vger.kernel.org>; Thu, 01 Jun 2017 13:55:00 -0700 (PDT)
In-Reply-To: <20170531150651.16873-2-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 31, 2017 at 6:06 PM, Jakub Kicinski
<jakub.kicinski@netronome.com> wrote:
> Forgetting to disable preemption around tcf_action_stats_update()
> seems to be a common mistake.  Add a helper function for updating
> stats on all actions of a filter.
>
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> ---
> CC: Jiri Pirko <jiri@mellanox.com>
> CC: Jamal Hadi Salim <jhs@mojatatu.com>
> CC: Cong Wang <xiyou.wangcong@gmail.com>
> CC: Saeed Mahameed <saeedm@mellanox.com>
> CC: Or Gerlitz <ogerlitz@mellanox.com>
>
>  drivers/net/ethernet/mellanox/mlx5/core/en_tc.c       | 10 +---------
>  drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c | 10 +---------
>  drivers/net/ethernet/netronome/nfp/nfp_net_offload.c  | 11 ++---------
>  include/net/pkt_cls.h                                 | 19 +++++++++++++++++++
>  4 files changed, 23 insertions(+), 27 deletions(-)
>
> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
> index d2f90ba2dbc4..7914a32a3036 100644
> --- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
> @@ -1863,9 +1863,7 @@ int mlx5e_stats_flower(struct mlx5e_priv *priv,
>  {
>         struct mlx5e_tc_table *tc = &priv->fs.tc;
>         struct mlx5e_tc_flow *flow;
> -       struct tc_action *a;
>         struct mlx5_fc *counter;
> -       LIST_HEAD(actions);
>         u64 bytes;
>         u64 packets;
>         u64 lastuse;
> @@ -1884,13 +1882,7 @@ int mlx5e_stats_flower(struct mlx5e_priv *priv,
>
>         mlx5_fc_query_cached(counter, &bytes, &packets, &lastuse);
>
> -       preempt_disable();
> -
> -       tcf_exts_to_list(f->exts, &actions);
> -       list_for_each_entry(a, &actions, list)
> -               tcf_action_stats_update(a, bytes, packets, lastuse);
> -
> -       preempt_enable();
> +       tcf_exts_stats_update(f->exts, bytes, packets, lastuse);
>
>         return 0;
>  }

> index f7762295b7b8..537d0a0ad4c4 100644
> --- a/include/net/pkt_cls.h
> +++ b/include/net/pkt_cls.h
> @@ -157,6 +157,25 @@ static inline void tcf_exts_to_list(const struct tcf_exts *exts,
>  #endif
>  }
>
> +static inline void
> +tcf_exts_stats_update(const struct tcf_exts *exts,
> +                     u64 bytes, u64 packets, u64 lastuse)
> +{
> +#ifdef CONFIG_NET_CLS_ACT
> +       int i;
> +
> +       preempt_disable();
> +
> +       for (i = 0; i < exts->nr_actions; i++) {
> +               struct tc_action *a = exts->actions[i];
> +
> +               tcf_action_stats_update(a, bytes, packets, lastuse);
> +       }
> +
> +       preempt_enable();
> +#endif
> +}

looks ok, for the mlx5 and pkt_cls.h parts:

Acked-by: Or Gerlitz <ogerlitz@mellanox.com>
