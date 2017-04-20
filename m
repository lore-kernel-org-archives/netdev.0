From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net v2] net/mlx5e: Fix race in mlx5e_sw_stats and mlx5e_vport_stats
Date: Thu, 20 Apr 2017 17:23:11 +0300
Message-ID: <CALzJLG9n1m5F9qXp_M3pYjVdz-9g5TudaLGv_aEc2uZm-Gag3A@mail.gmail.com>
References: <20170419233259.2255806-1-kafai@fb.com> <CALzJLG_r4x2PvVTG8vdDRFfGBfRe-totyUaPtV8ehmqiL0dURA@mail.gmail.com>
 <20170420141526.maq6b6rgqfjcdyn6@kafai-mba.dhcp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Gal Pressman <galp@mellanox.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Kernel Team <kernel-team@fb.com>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:36732 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1032639AbdDTOXd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 10:23:33 -0400
Received: by mail-qt0-f194.google.com with SMTP id t52so7710329qtb.3
        for <netdev@vger.kernel.org>; Thu, 20 Apr 2017 07:23:33 -0700 (PDT)
In-Reply-To: <20170420141526.maq6b6rgqfjcdyn6@kafai-mba.dhcp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 20, 2017 at 5:15 PM, Martin KaFai Lau <kafai@fb.com> wrote:
> On Thu, Apr 20, 2017 at 05:00:13PM +0300, Saeed Mahameed wrote:
>> On Thu, Apr 20, 2017 at 2:32 AM, Martin KaFai Lau <kafai@fb.com> wrote:
>> > We have observed a sudden spike in rx/tx_packets and rx/tx_bytes
>> > reported under /proc/net/dev.  There is a race in mlx5e_update_stats()
>> > and some of the get-stats functions (the one that we hit is the
>> > mlx5e_get_stats() which is called by ndo_get_stats64()).
>> >
>> > In particular, the very first thing mlx5e_update_sw_counters()
>> > does is 'memset(s, 0, sizeof(*s))'.  For example, if mlx5e_get_stats()
>> > is unlucky at one point, rx_bytes and rx_packets could be 0.  One second
>> > later, a normal (and much bigger than 0) value will be reported.
>> >
>> > This patch is to use a 'struct mlx5e_sw_stats temp' to avoid
>> > a direct memset zero on priv->stats.sw.
>> >
>> > mlx5e_update_vport_counters() has a similar race.  Hence, addressed
>> > together.
>> >
>> > I am lucky enough to catch this 0-reset in rx multicast:
>> > eth0: 41457665   76804   70    0    0    70          0     47085 15586634   87502    3    0    0     0       3          0
>> > eth0: 41459860   76815   70    0    0    70          0     47094 15588376   87516    3    0    0     0       3          0
>> > eth0: 41460577   76822   70    0    0    70          0         0 15589083   87521    3    0    0     0       3          0
>> > eth0: 41463293   76838   70    0    0    70          0     47108 15595872   87538    3    0    0     0       3          0
>> > eth0: 41463379   76839   70    0    0    70          0     47116 15596138   87539    3    0    0     0       3          0
>> >
>> > Cc: Saeed Mahameed <saeedm@mellanox.com>
>> > Suggested-by: Eric Dumazet <eric.dumazet@gmail.com>
>> > Signed-off-by: Martin KaFai Lau <kafai@fb.com>
>> > ---
>> >  drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 7 +++++--
>> >  1 file changed, 5 insertions(+), 2 deletions(-)
>> >
>> > diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
>> > index 66c133757a5e..246786bb861b 100644
>> > --- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
>> > +++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
>> > @@ -174,7 +174,7 @@ static void mlx5e_tx_timeout_work(struct work_struct *work)
>> >
>> >  static void mlx5e_update_sw_counters(struct mlx5e_priv *priv)
>> >  {
>> > -       struct mlx5e_sw_stats *s = &priv->stats.sw;
>> > +       struct mlx5e_sw_stats temp, *s = &temp;
>> >         struct mlx5e_rq_stats *rq_stats;
>> >         struct mlx5e_sq_stats *sq_stats;
>> >         u64 tx_offload_none = 0;
>> > @@ -229,12 +229,14 @@ static void mlx5e_update_sw_counters(struct mlx5e_priv *priv)
>> >         s->link_down_events_phy = MLX5_GET(ppcnt_reg,
>> >                                 priv->stats.pport.phy_counters,
>> >                                 counter_set.phys_layer_cntrs.link_down_events);
>> > +       memcpy(&priv->stats.sw, s, sizeof(*s));
>> >  }
>> >
>> >  static void mlx5e_update_vport_counters(struct mlx5e_priv *priv)
>> >  {
>> > +       struct mlx5e_vport_stats temp;
>> >         int outlen = MLX5_ST_SZ_BYTES(query_vport_counter_out);
>> > -       u32 *out = (u32 *)priv->stats.vport.query_vport_out;
>> > +       u32 *out = (u32 *)temp.query_vport_out;
>> >         u32 in[MLX5_ST_SZ_DW(query_vport_counter_in)] = {0};
>> >         struct mlx5_core_dev *mdev = priv->mdev;
>> >
>> > @@ -245,6 +247,7 @@ static void mlx5e_update_vport_counters(struct mlx5e_priv *priv)
>> >
>> >         memset(out, 0, outlen);
>>
>> Actually you don't need any temp here, it is safe to just remove this
>> redundant memset
>> and mlx5_cmd_exec will do the copy for you.
>>
>> >         mlx5_cmd_exec(mdev, in, sizeof(in), out, outlen);
>> > +       memcpy(priv->stats.vport.query_vport_out, out, outlen);
>> >  }
>>
>> Anyway we still need a spin lock here, and also for all the counters
>> under priv->stats which are affected by this race as well.
>>
>> If you want I can accept this as a temporary  fix for net and Gal will
>> work on a spin lock based mechanism to fix the memcpy race for all the
>> counters.
> A follow-up patch approach by Gal will be nice.
>

Ok, I will expect V3 with the removal of the memset from
mlx5e_update_vport_counters instead of the memcpy.
and Gal will work on the follow up patch
