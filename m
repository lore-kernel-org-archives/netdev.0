From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH] mlx4: give precise rx/tx bytes/packets counters
Date: Sun, 27 Nov 2016 00:47:48 +0200
Message-ID: <CALzJLG8nFBFy=-pjy-XBYb-y-F=grC5wjN35zTt9eUOT-612Eg@mail.gmail.com>
References: <1480088780.8455.543.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:35602 "EHLO
        mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752136AbcKZWsL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 26 Nov 2016 17:48:11 -0500
Received: by mail-lf0-f67.google.com with SMTP id p100so6149270lfg.2
        for <netdev@vger.kernel.org>; Sat, 26 Nov 2016 14:48:10 -0800 (PST)
In-Reply-To: <1480088780.8455.543.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 25, 2016 at 5:46 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> mlx4 stats are chaotic because a deferred work queue is responsible
> to update them every 250 ms.
>
Hello Eric,

Well the only historical reason for this deferred work is that we
query FW for some counters which might sleep.
and there is one place in the kernel where dev_get_stats(dev, &temp)
is called under a rw lock "read_lock(&dev_base_lock);"
in http://lxr.free-electrons.com/source/net/core/net-sysfs.c#L552, i
am not sure why is it this way ? Maybe it is time fix this and get rid
of the deferred work, which will give you the same precision even for
when reading ehttool stats, which this patch didn't take care off.
this will also improve other drivers who might sleep while reading
stats.

> Even sampling stats every one second with "sar -n DEV 1" gives
> variations like the following :
>
> lpaa23:~# sar -n DEV 1 10 | grep eth0 | cut -c1-65
> 07:39:22         eth0 146877.00 3265554.00   9467.15 4828168.50
> 07:39:23         eth0 146587.00 3260329.00   9448.15 4820445.98
> 07:39:24         eth0 146894.00 3259989.00   9468.55 4819943.26
> 07:39:25         eth0 110368.00 2454497.00   7113.95 3629012.17  <<>>
> 07:39:26         eth0 146563.00 3257502.00   9447.25 4816266.23
> 07:39:27         eth0 145678.00 3258292.00   9389.79 4817414.39
> 07:39:28         eth0 145268.00 3253171.00   9363.85 4809852.46
> 07:39:29         eth0 146439.00 3262185.00   9438.97 4823172.48
> 07:39:30         eth0 146758.00 3264175.00   9459.94 4826124.13
> 07:39:31         eth0 146843.00 3256903.00   9465.44 4815381.97
> Average:         eth0 142827.50 3179259.70   9206.30 4700578.16
>
> This patch allows rx/tx bytes/packets counters being folded at the
> time we need stats.
>
> We now can fetch stats every 1 ms if we want to check NIC behavior
> on a small time window. It is also easier to detect anomalies.
>
> lpaa23:~# sar -n DEV 1 10 | grep eth0 | cut -c1-65
> 07:42:50         eth0 142915.00 3177696.00   9212.06 4698270.42
> 07:42:51         eth0 143741.00 3200232.00   9265.15 4731593.02
> 07:42:52         eth0 142781.00 3171600.00   9202.92 4689260.16
> 07:42:53         eth0 143835.00 3192932.00   9271.80 4720761.39
> 07:42:54         eth0 141922.00 3165174.00   9147.64 4679759.21
> 07:42:55         eth0 142993.00 3207038.00   9216.78 4741653.05
> 07:42:56         eth0 141394.06 3154335.64   9113.85 4663731.73
> 07:42:57         eth0 141850.00 3161202.00   9144.48 4673866.07
> 07:42:58         eth0 143439.00 3180736.00   9246.05 4702755.35
> 07:42:59         eth0 143501.00 3210992.00   9249.99 4747501.84
> Average:         eth0 142835.66 3182165.93   9206.98 4704874.08
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Tariq Toukan <tariqt@mellanox.com>
> ---
>  drivers/net/ethernet/mellanox/mlx4/en_ethtool.c |    2
>  drivers/net/ethernet/mellanox/mlx4/en_netdev.c  |    1
>  drivers/net/ethernet/mellanox/mlx4/en_port.c    |   77 +++++++++-----
>  drivers/net/ethernet/mellanox/mlx4/mlx4_en.h    |    1
>  4 files changed, 58 insertions(+), 23 deletions(-)
>
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
> index 487a58f9c192896852fef271b6cce9bde132deb7..d9c9f86a30df953fa555934c5406057dcaf28960 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
> @@ -367,6 +367,8 @@ static void mlx4_en_get_ethtool_stats(struct net_device *dev,
>
>         spin_lock_bh(&priv->stats_lock);
>
> +       mlx4_en_fold_software_stats(dev);
> +
>         for (i = 0; i < NUM_MAIN_STATS; i++, bitmap_iterator_inc(&it))
>                 if (bitmap_iterator_test(&it))
>                         data[index++] = ((unsigned long *)&dev->stats)[i];
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> index 9018bb1b2e12142e048281a9d28ddf95e0023a61..d28d841db23ce885d2011877a156bacf23f65afe 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> @@ -1321,6 +1321,7 @@ mlx4_en_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats)
>         struct mlx4_en_priv *priv = netdev_priv(dev);
>
>         spin_lock_bh(&priv->stats_lock);
> +       mlx4_en_fold_software_stats(dev);
>         netdev_stats_to_stats64(stats, &dev->stats);
>         spin_unlock_bh(&priv->stats_lock);
>
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_port.c b/drivers/net/ethernet/mellanox/mlx4/en_port.c
> index 1eb4c1e10bad1dad26049876acf107a2073a6ab1..c6c4f1238923e09eced547454b86c68720292859 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_port.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_port.c
> @@ -147,6 +147,39 @@ static unsigned long en_stats_adder(__be64 *start, __be64 *next, int num)
>         return ret;
>  }
>
> +void mlx4_en_fold_software_stats(struct net_device *dev)
> +{
> +       struct mlx4_en_priv *priv = netdev_priv(dev);
> +       struct mlx4_en_dev *mdev = priv->mdev;
> +       unsigned long packets, bytes;
> +       int i;
> +
> +       if (mlx4_is_master(mdev->dev))
> +               return;

hmm, I think here you are just dragging a wrong discussion made in
mlx4 driver that the PF (only in SRIOV mode) netdev stats should
report the whole port stats from MLX4_CMD_DUMP_ETH_STATS FW command.

IMHO mlx4_en_get_stats64 should always report SW stats.
regardless, this function "mlx4_en_fold_software_stats" should always
fold the SW stats unconditionally, and W/A it somewhere else if SW
stats should be reported from FW. otherwise we will keep dragging this
confusion.

> +
> +       packets = 0;
> +       bytes = 0;
> +       for (i = 0; i < priv->rx_ring_num; i++) {
> +               const struct mlx4_en_rx_ring *ring = priv->rx_ring[i];
> +
> +               packets += READ_ONCE(ring->packets);
> +               bytes   += READ_ONCE(ring->bytes);
> +       }
> +       dev->stats.rx_packets = packets;
> +       dev->stats.rx_bytes = bytes;
> +
> +       packets = 0;
> +       bytes = 0;
> +       for (i = 0; i < priv->tx_ring_num[TX]; i++) {
> +               const struct mlx4_en_tx_ring *ring = priv->tx_ring[TX][i];
> +
> +               packets += READ_ONCE(ring->packets);
> +               bytes   += READ_ONCE(ring->bytes);
> +       }
> +       dev->stats.tx_packets = packets;
> +       dev->stats.tx_bytes = bytes;
> +}
> +
>  int mlx4_en_DUMP_ETH_STATS(struct mlx4_en_dev *mdev, u8 port, u8 reset)
>  {
>         struct mlx4_counter tmp_counter_stats;
> @@ -159,6 +192,7 @@ int mlx4_en_DUMP_ETH_STATS(struct mlx4_en_dev *mdev, u8 port, u8 reset)
>         u64 in_mod = reset << 8 | port;
>         int err;
>         int i, counter_index;
> +       unsigned long sw_tx_dropped = 0;
>         unsigned long sw_rx_dropped = 0;
>
>         mailbox = mlx4_alloc_cmd_mailbox(mdev->dev);
> @@ -174,8 +208,8 @@ int mlx4_en_DUMP_ETH_STATS(struct mlx4_en_dev *mdev, u8 port, u8 reset)
>
>         spin_lock_bh(&priv->stats_lock);
>
> -       stats->rx_packets = 0;
> -       stats->rx_bytes = 0;
> +       mlx4_en_fold_software_stats(dev);
> +
>         priv->port_stats.rx_chksum_good = 0;
>         priv->port_stats.rx_chksum_none = 0;
>         priv->port_stats.rx_chksum_complete = 0;
> @@ -183,19 +217,16 @@ int mlx4_en_DUMP_ETH_STATS(struct mlx4_en_dev *mdev, u8 port, u8 reset)
>         priv->xdp_stats.rx_xdp_tx      = 0;
>         priv->xdp_stats.rx_xdp_tx_full = 0;
>         for (i = 0; i < priv->rx_ring_num; i++) {
> -               stats->rx_packets += priv->rx_ring[i]->packets;
> -               stats->rx_bytes += priv->rx_ring[i]->bytes;
> -               sw_rx_dropped += priv->rx_ring[i]->dropped;
> -               priv->port_stats.rx_chksum_good += priv->rx_ring[i]->csum_ok;
> -               priv->port_stats.rx_chksum_none += priv->rx_ring[i]->csum_none;
> -               priv->port_stats.rx_chksum_complete += priv->rx_ring[i]->csum_complete;
> -               priv->xdp_stats.rx_xdp_drop    += priv->rx_ring[i]->xdp_drop;
> -               priv->xdp_stats.rx_xdp_tx      += priv->rx_ring[i]->xdp_tx;
> -               priv->xdp_stats.rx_xdp_tx_full += priv->rx_ring[i]->xdp_tx_full;
> +               const struct mlx4_en_rx_ring *ring = priv->rx_ring[i];
> +
> +               sw_rx_dropped                   += READ_ONCE(ring->dropped);
> +               priv->port_stats.rx_chksum_good += READ_ONCE(ring->csum_ok);
> +               priv->port_stats.rx_chksum_none += READ_ONCE(ring->csum_none);
> +               priv->port_stats.rx_chksum_complete += READ_ONCE(ring->csum_complete);
> +               priv->xdp_stats.rx_xdp_drop     += READ_ONCE(ring->xdp_drop);
> +               priv->xdp_stats.rx_xdp_tx       += READ_ONCE(ring->xdp_tx);
> +               priv->xdp_stats.rx_xdp_tx_full  += READ_ONCE(ring->xdp_tx_full);
>         }
> -       stats->tx_packets = 0;
> -       stats->tx_bytes = 0;
> -       stats->tx_dropped = 0;
>         priv->port_stats.tx_chksum_offload = 0;
>         priv->port_stats.queue_stopped = 0;
>         priv->port_stats.wake_queue = 0;
> @@ -205,15 +236,14 @@ int mlx4_en_DUMP_ETH_STATS(struct mlx4_en_dev *mdev, u8 port, u8 reset)
>         for (i = 0; i < priv->tx_ring_num[TX]; i++) {
>                 const struct mlx4_en_tx_ring *ring = priv->tx_ring[TX][i];
>
> -               stats->tx_packets += ring->packets;
> -               stats->tx_bytes += ring->bytes;
> -               stats->tx_dropped += ring->tx_dropped;
> -               priv->port_stats.tx_chksum_offload += ring->tx_csum;
> -               priv->port_stats.queue_stopped     += ring->queue_stopped;
> -               priv->port_stats.wake_queue        += ring->wake_queue;
> -               priv->port_stats.tso_packets       += ring->tso_packets;
> -               priv->port_stats.xmit_more         += ring->xmit_more;
> +               sw_tx_dropped                      += READ_ONCE(ring->tx_dropped);
> +               priv->port_stats.tx_chksum_offload += READ_ONCE(ring->tx_csum);
> +               priv->port_stats.queue_stopped     += READ_ONCE(ring->queue_stopped);
> +               priv->port_stats.wake_queue        += READ_ONCE(ring->wake_queue);
> +               priv->port_stats.tso_packets       += READ_ONCE(ring->tso_packets);
> +               priv->port_stats.xmit_more         += READ_ONCE(ring->xmit_more);
>         }
> +
>         if (mlx4_is_master(mdev->dev)) {
>                 stats->rx_packets = en_stats_adder(&mlx4_en_stats->RTOT_prio_0,
>                                                    &mlx4_en_stats->RTOT_prio_1,

As you see here in SRIOV mode (PF only) reads   sw stats from FW.
Tariq, I think we need to fix this.


> @@ -251,7 +281,8 @@ int mlx4_en_DUMP_ETH_STATS(struct mlx4_en_dev *mdev, u8 port, u8 reset)
>         stats->rx_length_errors = be32_to_cpu(mlx4_en_stats->RdropLength);
>         stats->rx_crc_errors = be32_to_cpu(mlx4_en_stats->RCRC);
>         stats->rx_fifo_errors = be32_to_cpu(mlx4_en_stats->RdropOvflw);
> -       stats->tx_dropped += be32_to_cpu(mlx4_en_stats->TDROP);
> +       stats->tx_dropped = be32_to_cpu(mlx4_en_stats->TDROP) +
> +                           sw_tx_dropped;
>
>         /* RX stats */
>         priv->pkstats.rx_multicast_packets = stats->multicast;
> diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
> index 574bcbb1b38fc4758511d8f7bd17a87b0a507a73..20a936428f4a44c8ca0a7161855da310f9166b50 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
> +++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
> @@ -755,6 +755,7 @@ void mlx4_en_rx_irq(struct mlx4_cq *mcq);
>  int mlx4_SET_MCAST_FLTR(struct mlx4_dev *dev, u8 port, u64 mac, u64 clear, u8 mode);
>  int mlx4_SET_VLAN_FLTR(struct mlx4_dev *dev, struct mlx4_en_priv *priv);
>
> +void mlx4_en_fold_software_stats(struct net_device *dev);
>  int mlx4_en_DUMP_ETH_STATS(struct mlx4_en_dev *mdev, u8 port, u8 reset);
>  int mlx4_en_QUERY_PORT(struct mlx4_en_dev *mdev, u8 port);
>
>
>
