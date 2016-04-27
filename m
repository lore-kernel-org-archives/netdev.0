From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Wed, 27 Apr 2016 12:01:09 +1000
Message-ID: <20160427120109.37449920@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Saeed Mahameed <saeedm@mellanox.com>,
	Gal Pressman <galp@mellanox.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  drivers/net/ethernet/mellanox/mlx5/core/en_main.c

between commit:

  d8edd2469ace ("et/mlx5e: Fix minimum MTU")

from the net tree and commit:

  0e405443e803 ("net/mlx5e: Improve set features ndo resiliency")

from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary. This
is now fixed as far as linux-next is concerned, but any non trivial
conflicts should be mentioned to your upstream maintainer when your tree
is submitted for merging.  You may also want to consider cooperating
with the maintainer of the conflicting tree to minimise any particularly
complex conflicts.

-- 
Cheers,
Stephen Rothwell

diff --cc drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 67d548b70e14,5bad17d37d7b..000000000000
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@@ -2025,9 -2214,49 +2240,52 @@@ static int set_feature_rx_vlan(struct n
  	return err;
  }
  
+ static int mlx5e_handle_feature(struct net_device *netdev,
+ 				netdev_features_t wanted_features,
+ 				netdev_features_t feature,
+ 				mlx5e_feature_handler feature_handler)
+ {
+ 	netdev_features_t changes = wanted_features ^ netdev->features;
+ 	bool enable = !!(wanted_features & feature);
+ 	int err;
+ 
+ 	if (!(changes & feature))
+ 		return 0;
+ 
+ 	err = feature_handler(netdev, enable);
+ 	if (err) {
+ 		netdev_err(netdev, "%s feature 0x%llx failed err %d\n",
+ 			   enable ? "Enable" : "Disable", feature, err);
+ 		return err;
+ 	}
+ 
+ 	MLX5E_SET_FEATURE(netdev, feature, enable);
+ 	return 0;
+ }
+ 
+ static int mlx5e_set_features(struct net_device *netdev,
+ 			      netdev_features_t features)
+ {
+ 	int err;
+ 
+ 	err  = mlx5e_handle_feature(netdev, features, NETIF_F_LRO,
+ 				    set_feature_lro);
+ 	err |= mlx5e_handle_feature(netdev, features,
+ 				    NETIF_F_HW_VLAN_CTAG_FILTER,
+ 				    set_feature_vlan_filter);
+ 	err |= mlx5e_handle_feature(netdev, features, NETIF_F_HW_TC,
+ 				    set_feature_tc_num_filters);
+ 	err |= mlx5e_handle_feature(netdev, features, NETIF_F_RXALL,
+ 				    set_feature_rx_all);
+ 	err |= mlx5e_handle_feature(netdev, features, NETIF_F_HW_VLAN_CTAG_RX,
+ 				    set_feature_rx_vlan);
+ 
+ 	return err ? -EINVAL : 0;
+ }
+ 
 +#define MXL5_HW_MIN_MTU 64
 +#define MXL5E_MIN_MTU (MXL5_HW_MIN_MTU + ETH_FCS_LEN)
 +
  static int mlx5e_change_mtu(struct net_device *netdev, int new_mtu)
  {
  	struct mlx5e_priv *priv = netdev_priv(netdev);
@@@ -2633,18 -2966,10 +2997,19 @@@ static void mlx5e_destroy_netdev(struc
  	schedule_work(&priv->set_rx_mode_work);
  	mlx5e_disable_async_events(priv);
  	flush_scheduled_work();
 -	unregister_netdev(netdev);
 +	if (test_bit(MLX5_INTERFACE_STATE_SHUTDOWN, &mdev->intf_state)) {
 +		netif_device_detach(netdev);
 +		mutex_lock(&priv->state_lock);
 +		if (test_bit(MLX5E_STATE_OPENED, &priv->state))
 +			mlx5e_close_locked(netdev);
 +		mutex_unlock(&priv->state_lock);
 +	} else {
 +		unregister_netdev(netdev);
 +	}
 +
  	mlx5e_tc_cleanup(priv);
  	mlx5e_vxlan_cleanup(priv);
+ 	mlx5e_destroy_q_counter(priv);
  	mlx5e_destroy_flow_tables(priv);
  	mlx5e_destroy_tirs(priv);
  	mlx5e_destroy_rqt(priv, MLX5E_SINGLE_RQ_RQT);
