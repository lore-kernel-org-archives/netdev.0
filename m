From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Thu, 21 Jul 2016 11:41:53 +1000
Message-ID: <20160721114153.2d8fa30f@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>,
	Brenden Blanco <bblanco@plumgrid.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  drivers/net/ethernet/mellanox/mlx4/en_ethtool.c

between commit:

  ec25bc04ed8e ("net/mlx4_en: Add resilience in low memory systems")

from the net tree and commit:

  9ecc2d86171a ("net/mlx4_en: add xdp forwarding and data write support")

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

diff --cc drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
index 44cf16d01f42,f32e272c83dd..000000000000
--- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
@@@ -1730,28 -1722,32 +1729,35 @@@ static int mlx4_en_set_channels(struct 
  	    !channel->tx_count || !channel->rx_count)
  		return -EINVAL;
  
+ 	if (channel->tx_count * MLX4_EN_NUM_UP <= priv->xdp_ring_num) {
+ 		en_err(priv, "Minimum %d tx channels required with XDP on\n",
+ 		       priv->xdp_ring_num / MLX4_EN_NUM_UP + 1);
+ 		return -EINVAL;
+ 	}
+ 
 +	tmp = kzalloc(sizeof(*tmp), GFP_KERNEL);
 +	if (!tmp)
 +		return -ENOMEM;
 +
  	mutex_lock(&mdev->state_lock);
 +	memcpy(&new_prof, priv->prof, sizeof(struct mlx4_en_port_profile));
 +	new_prof.num_tx_rings_p_up = channel->tx_count;
 +	new_prof.tx_ring_num = channel->tx_count * MLX4_EN_NUM_UP;
 +	new_prof.rx_ring_num = channel->rx_count;
 +
 +	err = mlx4_en_try_alloc_resources(priv, tmp, &new_prof);
 +	if (err)
 +		goto out;
 +
  	if (priv->port_up) {
  		port_up = 1;
  		mlx4_en_stop_port(dev, 1);
  	}
  
 -	mlx4_en_free_resources(priv);
 -
 -	priv->num_tx_rings_p_up = channel->tx_count;
 -	priv->tx_ring_num = channel->tx_count * MLX4_EN_NUM_UP;
 -	priv->rx_ring_num = channel->rx_count;
 -
 -	err = mlx4_en_alloc_resources(priv);
 -	if (err) {
 -		en_err(priv, "Failed reallocating port resources\n");
 -		goto out;
 -	}
 +	mlx4_en_safe_replace_resources(priv, tmp);
  
- 	netif_set_real_num_tx_queues(dev, priv->tx_ring_num);
+ 	netif_set_real_num_tx_queues(dev, priv->tx_ring_num -
+ 							priv->xdp_ring_num);
  	netif_set_real_num_rx_queues(dev, priv->rx_ring_num);
  
  	if (dev->num_tc)
