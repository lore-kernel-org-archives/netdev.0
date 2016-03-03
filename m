From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Thu, 3 Mar 2016 11:28:47 +1100
Message-ID: <20160303112847.44a69356@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Tariq Toukan <tariqt@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  drivers/net/ethernet/mellanox/mlx5/core/en_main.c

between commit:

  85082dba0a50 ("net/mlx5e: Correctly handle RSS indirection table when changing number of channels")

from the net tree and commit:

  08fb1dacdd76 ("net/mlx5e: Support DCBNL IEEE ETS")

from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

-- 
Cheers,
Stephen Rothwell

diff --cc drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 402994bf7e16,5063c0e0f8ac..000000000000
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@@ -141,12 -143,10 +143,14 @@@ void mlx5e_update_stats(struct mlx5e_pr
  		return;
  
  	/* Collect firts the SW counters and then HW for consistency */
 +	s->rx_packets		= 0;
 +	s->rx_bytes		= 0;
 +	s->tx_packets		= 0;
 +	s->tx_bytes		= 0;
  	s->tso_packets		= 0;
  	s->tso_bytes		= 0;
+ 	s->tso_inner_packets	= 0;
+ 	s->tso_inner_bytes	= 0;
  	s->tx_queue_stopped	= 0;
  	s->tx_queue_wake	= 0;
  	s->tx_queue_dropped	= 0;
@@@ -170,10 -169,10 +175,12 @@@
  		for (j = 0; j < priv->params.num_tc; j++) {
  			sq_stats = &priv->channel[i]->sq[j].stats;
  
 +			s->tx_packets		+= sq_stats->packets;
 +			s->tx_bytes		+= sq_stats->bytes;
  			s->tso_packets		+= sq_stats->tso_packets;
  			s->tso_bytes		+= sq_stats->tso_bytes;
+ 			s->tso_inner_packets	+= sq_stats->tso_inner_packets;
+ 			s->tso_inner_bytes	+= sq_stats->tso_inner_bytes;
  			s->tx_queue_stopped	+= sq_stats->stopped;
  			s->tx_queue_wake	+= sq_stats->wake;
  			s->tx_queue_dropped	+= sq_stats->dropped;
@@@ -233,8 -233,25 +241,8 @@@
  	s->tx_broadcast_bytes   =
  		MLX5_GET_CTR(out, transmitted_eth_broadcast.octets);
  
 -	s->rx_packets =
 -		s->rx_unicast_packets +
 -		s->rx_multicast_packets +
 -		s->rx_broadcast_packets;
 -	s->rx_bytes =
 -		s->rx_unicast_bytes +
 -		s->rx_multicast_bytes +
 -		s->rx_broadcast_bytes;
 -	s->tx_packets =
 -		s->tx_unicast_packets +
 -		s->tx_multicast_packets +
 -		s->tx_broadcast_packets;
 -	s->tx_bytes =
 -		s->tx_unicast_bytes +
 -		s->tx_multicast_bytes +
 -		s->tx_broadcast_bytes;
 -
  	/* Update calculated offload counters */
- 	s->tx_csum_offload = s->tx_packets - tx_offload_none;
+ 	s->tx_csum_offload = s->tx_packets - tx_offload_none - s->tx_csum_inner;
  	s->rx_csum_good    = s->rx_packets - s->rx_csum_none -
  			       s->rx_csum_sw;
  
@@@ -2091,15 -2235,24 +2237,33 @@@ u16 mlx5e_get_max_inline_cap(struct mlx
  	       2 /*sizeof(mlx5e_tx_wqe.inline_hdr_start)*/;
  }
  
 +void mlx5e_build_default_indir_rqt(u32 *indirection_rqt, int len,
 +				   int num_channels)
 +{
 +	int i;
 +
 +	for (i = 0; i < len; i++)
 +		indirection_rqt[i] = i % num_channels;
 +}
 +
+ #ifdef CONFIG_MLX5_CORE_EN_DCB
+ static void mlx5e_ets_init(struct mlx5e_priv *priv)
+ {
+ 	int i;
+ 
+ 	priv->params.ets.ets_cap = mlx5_max_tc(priv->mdev) + 1;
+ 	for (i = 0; i < priv->params.ets.ets_cap; i++) {
+ 		priv->params.ets.tc_tx_bw[i] = MLX5E_MAX_BW_ALLOC;
+ 		priv->params.ets.tc_tsa[i] = IEEE_8021QAZ_TSA_VENDOR;
+ 		priv->params.ets.prio_tc[i] = i;
+ 	}
+ 
+ 	/* tclass[prio=0]=1, tclass[prio=1]=0, tclass[prio=i]=i (for i>1) */
+ 	priv->params.ets.prio_tc[0] = 1;
+ 	priv->params.ets.prio_tc[1] = 0;
+ }
+ #endif
+ 
  static void mlx5e_build_netdev_priv(struct mlx5_core_dev *mdev,
  				    struct net_device *netdev,
  				    int num_channels)
