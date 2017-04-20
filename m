From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [RFC PATCH net] net/mlx5e: Race between mlx5e_update_stats() and
 getting the stats
Date: Thu, 20 Apr 2017 16:22:19 +0300
Message-ID: <CALzJLG8WFw-qPmcBZvhCMP1mtCq9+6aqOdCJCF2LKj+9G1ncpw@mail.gmail.com>
References: <20170419182936.788220-1-kafai@fb.com> <1492633478.22296.14.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170419215338.vrbvzkceufktatoo@giedrius-mbp.dhcp.thefacebook.com> <1492644938.22296.19.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Martin KaFai Lau <kafai@fb.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Kernel Team <kernel-team@fb.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:36249 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S945641AbdDTNWl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 09:22:41 -0400
Received: by mail-qt0-f195.google.com with SMTP id t52so7446945qtb.3
        for <netdev@vger.kernel.org>; Thu, 20 Apr 2017 06:22:41 -0700 (PDT)
In-Reply-To: <1492644938.22296.19.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 20, 2017 at 2:35 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2017-04-19 at 14:53 -0700, Martin KaFai Lau wrote:
>
>> Right, a temp and a memcpy should be enough to solve our spike problem.
>> It may be the right fix for net.
>>
>> Agree that using a spinlock is better (likely changing state_lock
>> to spinlock).  A quick grep shows 80 line changes.  Saeed, thoughts?

No, changing the current state_lock is a bad idea, as Eric said it is
for a reason,
to synchronize between arbitrary ring/device state changes which might sleep.

memcpy is a good idea to better hide or delay the issue :),
new dedicated spin lock is the right way to go, As Eric suggested below.

BTW, very nice catch Martin, I just got back from vacation to work on this bug,
and you already root caused it, Thanks !!

>
> I was not advising replacing the mutex (maybe it is a mutex for good
> reason), I simply suggested to use another spinlock only for this very
> specific section.
>
> Something like :
>
> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
> index dc52053128bc752ccd398449330c24c0bdf8b3a1..9b2e1b79fded22d55e9409cb572308190679cfdd 100644
> --- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
> @@ -722,6 +722,7 @@ struct mlx5e_priv {
>         struct mlx5_core_dev      *mdev;
>         struct net_device         *netdev;
>         struct mlx5e_stats         stats;
> +       spinlock_t                 stats_lock;
>         struct mlx5e_tstamp        tstamp;
>         u16 q_counter;
>  #ifdef CONFIG_MLX5_CORE_EN_DCB
> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
> index a004a5a1a4c22a742ef3f9939769c6b5c9445f46..b4b7d43bf899cadca2c2a17151d35acac9773859 100644
> --- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
> @@ -315,9 +315,11 @@ static void mlx5e_get_ethtool_stats(struct net_device *dev,
>                 mlx5e_update_stats(priv);
>         mutex_unlock(&priv->state_lock);
>
> +       spin_lock(&priv->stats_lock);
>         for (i = 0; i < NUM_SW_COUNTERS; i++)
>                 data[idx++] = MLX5E_READ_CTR64_CPU(&priv->stats.sw,
>                                                    sw_stats_desc, i);
> +       spin_unlock(&priv->stats_lock);
>
>         for (i = 0; i < MLX5E_NUM_Q_CNTRS(priv); i++)
>                 data[idx++] = MLX5E_READ_CTR32_CPU(&priv->stats.qcnt,
> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
> index 66c133757a5ee8daae122e93322306b1c5c44336..4d6672045b1126a8bab4d6f2035e6a9b830560d2 100644
> --- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
> @@ -174,7 +174,7 @@ static void mlx5e_tx_timeout_work(struct work_struct *work)
>
>  static void mlx5e_update_sw_counters(struct mlx5e_priv *priv)
>  {
> -       struct mlx5e_sw_stats *s = &priv->stats.sw;
> +       struct mlx5e_sw_stats temp, *s = &temp;
>         struct mlx5e_rq_stats *rq_stats;
>         struct mlx5e_sq_stats *sq_stats;
>         u64 tx_offload_none = 0;
> @@ -229,6 +229,9 @@ static void mlx5e_update_sw_counters(struct mlx5e_priv *priv)
>         s->link_down_events_phy = MLX5_GET(ppcnt_reg,
>                                 priv->stats.pport.phy_counters,
>                                 counter_set.phys_layer_cntrs.link_down_events);
> +       spin_lock(&priv->stats_lock);
> +       memcpy(&priv->stats.sw, s, sizeof(*s));
> +       spin_unlock(&priv->stats_lock);

I like this ! minimized the critical section with a temp buffer and a
memcpy .. perfect.

>  }
>
>  static void mlx5e_update_vport_counters(struct mlx5e_priv *priv)
> @@ -2754,11 +2757,13 @@ mlx5e_get_stats(struct net_device *dev, struct rtnl_link_stats64 *stats)
>                 stats->tx_packets = PPORT_802_3_GET(pstats, a_frames_transmitted_ok);
>                 stats->tx_bytes   = PPORT_802_3_GET(pstats, a_octets_transmitted_ok);
>         } else {
> +               spin_lock(&priv->stats_lock);
>                 stats->rx_packets = sstats->rx_packets;
>                 stats->rx_bytes   = sstats->rx_bytes;
>                 stats->tx_packets = sstats->tx_packets;
>                 stats->tx_bytes   = sstats->tx_bytes;
>                 stats->tx_dropped = sstats->tx_queue_dropped;
> +               spin_unlock(&priv->stats_lock);
>         }
>
>         stats->rx_dropped = priv->stats.qcnt.rx_out_of_buffer;
> @@ -3561,6 +3566,8 @@ static void mlx5e_build_nic_netdev_priv(struct mlx5_core_dev *mdev,
>
>         mutex_init(&priv->state_lock);
>
> +       spin_lock_init(&priv->stats_lock);
> +
>         INIT_WORK(&priv->update_carrier_work, mlx5e_update_carrier_work);
>         INIT_WORK(&priv->set_rx_mode_work, mlx5e_set_rx_mode_work);
>         INIT_WORK(&priv->tx_timeout_work, mlx5e_tx_timeout_work);
>
>
