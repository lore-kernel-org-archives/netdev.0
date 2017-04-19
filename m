From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH net] net/mlx5e: Race between mlx5e_update_stats()
 and getting the stats
Date: Wed, 19 Apr 2017 13:24:38 -0700
Message-ID: <1492633478.22296.14.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170419182936.788220-1-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>,
        kernel-team@fb.com
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yb0-f196.google.com ([209.85.213.196]:35484 "EHLO
        mail-yb0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S939380AbdDSUYl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2017 16:24:41 -0400
Received: by mail-yb0-f196.google.com with SMTP id 19so2277947ybl.2
        for <netdev@vger.kernel.org>; Wed, 19 Apr 2017 13:24:41 -0700 (PDT)
In-Reply-To: <20170419182936.788220-1-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-04-19 at 11:29 -0700, Martin KaFai Lau wrote:
> We have observed a sudden spike in rx/tx_packets and rx/tx_bytes
> reported under /proc/net/dev.  It seems there is a race in
> mlx5e_update_stats() and some of the get-stats functions (the
> one that we hit is the mlx5e_get_stats() which is called
> by ndo_get_stats64()).
> 
> In particular, the very first thing mlx5e_update_sw_counters()
> does is 'memset(s, 0, sizeof(*s))'.  For example, if mlx5e_get_stats()
> is unlucky at one point, rx_bytes and rx_packets could be 0.  One second
> later, a normal (and much bigger than 0) value will be reported.
> 
> This patch is not meant to be a proper fix.  It merely tries
> to show what I have suspected and start the discussion.
> 
> Signed-off-by: Martin KaFai Lau <kafai@fb.com>
> Cc: Saeed Mahameed <saeedm@mellanox.com>
> ---
>  drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c | 7 +++++--
>  drivers/net/ethernet/mellanox/mlx5/core/en_main.c    | 3 +++
>  2 files changed, 8 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
> index a004a5a1a4c2..d24916f720bb 100644
> --- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
> @@ -313,7 +313,6 @@ static void mlx5e_get_ethtool_stats(struct net_device *dev,
>  	mutex_lock(&priv->state_lock);
>  	if (test_bit(MLX5E_STATE_OPENED, &priv->state))
>  		mlx5e_update_stats(priv);
> -	mutex_unlock(&priv->state_lock);
>  
>  	for (i = 0; i < NUM_SW_COUNTERS; i++)
>  		data[idx++] = MLX5E_READ_CTR64_CPU(&priv->stats.sw,
> @@ -378,8 +377,10 @@ static void mlx5e_get_ethtool_stats(struct net_device *dev,
>  		data[idx++] = MLX5E_READ_CTR64_CPU(mlx5_priv->pme_stats.error_counters,
>  						   mlx5e_pme_error_desc, i);
>  
> -	if (!test_bit(MLX5E_STATE_OPENED, &priv->state))
> +	if (!test_bit(MLX5E_STATE_OPENED, &priv->state)) {
> +		mutex_unlock(&priv->state_lock);
>  		return;
> +	}
>  
>  	/* per channel counters */
>  	for (i = 0; i < priv->params.num_channels; i++)
> @@ -393,6 +394,8 @@ static void mlx5e_get_ethtool_stats(struct net_device *dev,
>  			for (j = 0; j < NUM_SQ_STATS; j++)
>  				data[idx++] = MLX5E_READ_CTR64_CPU(&priv->channel[i]->sq[tc].stats,
>  								   sq_stats_desc, j);
> +
> +	mutex_unlock(&priv->state_lock);
>  }
>  
>  static u32 mlx5e_rx_wqes_to_packets(struct mlx5e_priv *priv, int rq_wq_type,
> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
> index 66c133757a5e..a4c100bea541 100644
> --- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
> @@ -2748,6 +2748,8 @@ mlx5e_get_stats(struct net_device *dev, struct rtnl_link_stats64 *stats)
>  	struct mlx5e_vport_stats *vstats = &priv->stats.vport;
>  	struct mlx5e_pport_stats *pstats = &priv->stats.pport;
>  
> +	mutex_lock(&priv->state_lock);
> +

We can not sleep from ndo_get_stats() ( look at bonding driver )

What about the following ?

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 66c133757a5ee8daae122e93322306b1c5c44336..b9fea146a0ca18498a8dfa5698dca7dea06e3c5e 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -174,7 +174,7 @@ static void mlx5e_tx_timeout_work(struct work_struct *work)
 
 static void mlx5e_update_sw_counters(struct mlx5e_priv *priv)
 {
-	struct mlx5e_sw_stats *s = &priv->stats.sw;
+	struct mlx5e_sw_stats temp, *s = &temp;
 	struct mlx5e_rq_stats *rq_stats;
 	struct mlx5e_sq_stats *sq_stats;
 	u64 tx_offload_none = 0;
@@ -229,6 +229,8 @@ static void mlx5e_update_sw_counters(struct mlx5e_priv *priv)
 	s->link_down_events_phy = MLX5_GET(ppcnt_reg,
 				priv->stats.pport.phy_counters,
 				counter_set.phys_layer_cntrs.link_down_events);
+	/* A bit racy (depending on memcpy() sanity...) , we probably should use a spinlock */
+	memcpy(&priv->stats.sw, s, sizeof(*s));
 }
 
 static void mlx5e_update_vport_counters(struct mlx5e_priv *priv)
