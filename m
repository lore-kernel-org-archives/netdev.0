From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Mon, 3 Jul 2017 11:43:20 +1000
Message-ID: <20170703114320.6d2130f8@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Mohamad Haj Yahia <mohamad@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Moshe Shemesh <moshe@mellanox.com>,
        Ilan Tayari <ilant@mellanox.com>
To: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got conflicts in:

  drivers/net/ethernet/mellanox/mlx5/core/health.c
  include/linux/mlx5/driver.h

between commit:

  2a0165a034ac ("net/mlx5: Cancel delayed recovery work when unloading the driver")

from the net tree and commit:

  0179720d6be2 ("Introduce new function for entering bad-health state.")

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

diff --cc drivers/net/ethernet/mellanox/mlx5/core/health.c
index 8a8b5f0e497c,0648a659b21d..000000000000
--- a/drivers/net/ethernet/mellanox/mlx5/core/health.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/health.c
@@@ -193,8 -193,8 +194,8 @@@ static void health_care(struct work_str
  	mlx5_core_warn(dev, "handling bad device here\n");
  	mlx5_handle_bad_state(dev);
  
- 	spin_lock(&health->wq_lock);
+ 	spin_lock_irqsave(&health->wq_lock, flags);
 -	if (!test_bit(MLX5_DROP_NEW_HEALTH_WORK, &health->flags))
 +	if (!test_bit(MLX5_DROP_NEW_RECOVERY_WORK, &health->flags))
  		schedule_delayed_work(&health->recover_work, recover_delay);
  	else
  		dev_err(&dev->pdev->dev,
@@@ -334,11 -341,11 +343,12 @@@ void mlx5_stop_health_poll(struct mlx5_
  void mlx5_drain_health_wq(struct mlx5_core_dev *dev)
  {
  	struct mlx5_core_health *health = &dev->priv.health;
+ 	unsigned long flags;
  
- 	spin_lock(&health->wq_lock);
+ 	spin_lock_irqsave(&health->wq_lock, flags);
  	set_bit(MLX5_DROP_NEW_HEALTH_WORK, &health->flags);
 +	set_bit(MLX5_DROP_NEW_RECOVERY_WORK, &health->flags);
- 	spin_unlock(&health->wq_lock);
+ 	spin_unlock_irqrestore(&health->wq_lock, flags);
  	cancel_delayed_work_sync(&health->recover_work);
  	cancel_work_sync(&health->work);
  }
diff --cc include/linux/mlx5/driver.h
index ba260330ce5e,2ab4ae3e3a1a..000000000000
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@@ -925,7 -945,7 +945,8 @@@ int mlx5_health_init(struct mlx5_core_d
  void mlx5_start_health_poll(struct mlx5_core_dev *dev);
  void mlx5_stop_health_poll(struct mlx5_core_dev *dev);
  void mlx5_drain_health_wq(struct mlx5_core_dev *dev);
 +void mlx5_drain_health_recovery(struct mlx5_core_dev *dev);
+ void mlx5_trigger_health_work(struct mlx5_core_dev *dev);
  int mlx5_buf_alloc_node(struct mlx5_core_dev *dev, int size,
  			struct mlx5_buf *buf, int node);
  int mlx5_buf_alloc(struct mlx5_core_dev *dev, int size, struct mlx5_buf *buf);
