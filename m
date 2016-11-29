From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Tue, 29 Nov 2016 11:25:03 +1100
Message-ID: <20161129112503.6bc31027@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
        Tariq Toukan <tariqt@mellanox.com>
To: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  drivers/net/ethernet/mellanox/mlx4/en_netdev.c

between commit:

  b4353708f5a1 ("Revert "net/mlx4_en: Avoid unregister_netdev at shutdown flow"")

from the net tree and commit:

  67f8b1dcb9ee ("net/mlx4_en: Refactor the XDP forwarding rings scheme")

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

diff --cc drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index fb8bb027b69c,ea76b28b728b..000000000000
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@@ -2155,6 -2209,9 +2202,7 @@@ void mlx4_en_destroy_netdev(struct net_
  {
  	struct mlx4_en_priv *priv = netdev_priv(dev);
  	struct mlx4_en_dev *mdev = priv->mdev;
 -	bool shutdown = mdev->dev->persist->interface_state &
 -					    MLX4_INTERFACE_STATE_SHUTDOWN;
+ 	int t;
  
  	en_dbg(DRV, priv, "Destroying netdev on port:%d\n", priv->port);
  
@@@ -2188,10 -2248,13 +2236,12 @@@
  	mlx4_en_free_resources(priv);
  	mutex_unlock(&mdev->state_lock);
  
- 	kfree(priv->tx_ring);
- 	kfree(priv->tx_cq);
+ 	for (t = 0; t < MLX4_EN_NUM_TX_TYPES; t++) {
+ 		kfree(priv->tx_ring[t]);
+ 		kfree(priv->tx_cq[t]);
+ 	}
  
 -	if (!shutdown)
 -		free_netdev(dev);
 +	free_netdev(dev);
  }
  
  static int mlx4_en_change_mtu(struct net_device *dev, int new_mtu)
