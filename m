From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net 04/11] net/mlx5: Skip mlx5_unload_one if mlx5_load_one fails
Date: Thu, 31 Aug 2017 01:21:03 +0300
Message-ID: <20170830222110.15737-5-saeedm@mellanox.com>
References: <20170830222110.15737-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Huy Nguyen <huyn@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:53238 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751330AbdH3WVd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 18:21:33 -0400
In-Reply-To: <20170830222110.15737-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Huy Nguyen <huyn@mellanox.com>

There is an issue where the firmware fails during mlx5_load_one,
the health_care timer detects the issue and schedules a health_care call.
Then the mlx5_load_one detects the issue, cleans up and quits. Then
the health_care starts and calls mlx5_unload_one to clean up the resources
that no longer exist and causes kernel panic.

The root cause is that the bit MLX5_INTERFACE_STATE_DOWN is not set
after mlx5_load_one fails. The solution is removing the bit
MLX5_INTERFACE_STATE_DOWN and quit mlx5_unload_one if the
bit MLX5_INTERFACE_STATE_UP is not set. The bit MLX5_INTERFACE_STATE_DOWN
is redundant and we can use MLX5_INTERFACE_STATE_UP instead.

Fixes: 5fc7197d3a25 ("net/mlx5: Add pci shutdown callback")
Signed-off-by: Huy Nguyen <huyn@mellanox.com>
Reviewed-by: Daniel Jurgens <danielj@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/main.c | 4 +---
 include/linux/mlx5/driver.h                    | 5 ++---
 2 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index c065132b956d..4cdb414aa2d5 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -1186,7 +1186,6 @@ static int mlx5_load_one(struct mlx5_core_dev *dev, struct mlx5_priv *priv,
 		}
 	}
 
-	clear_bit(MLX5_INTERFACE_STATE_DOWN, &dev->intf_state);
 	set_bit(MLX5_INTERFACE_STATE_UP, &dev->intf_state);
 out:
 	mutex_unlock(&dev->intf_state_mutex);
@@ -1261,7 +1260,7 @@ static int mlx5_unload_one(struct mlx5_core_dev *dev, struct mlx5_priv *priv,
 		mlx5_drain_health_recovery(dev);
 
 	mutex_lock(&dev->intf_state_mutex);
-	if (test_bit(MLX5_INTERFACE_STATE_DOWN, &dev->intf_state)) {
+	if (!test_bit(MLX5_INTERFACE_STATE_UP, &dev->intf_state)) {
 		dev_warn(&dev->pdev->dev, "%s: interface is down, NOP\n",
 			 __func__);
 		if (cleanup)
@@ -1270,7 +1269,6 @@ static int mlx5_unload_one(struct mlx5_core_dev *dev, struct mlx5_priv *priv,
 	}
 
 	clear_bit(MLX5_INTERFACE_STATE_UP, &dev->intf_state);
-	set_bit(MLX5_INTERFACE_STATE_DOWN, &dev->intf_state);
 
 	if (mlx5_device_registered(dev))
 		mlx5_detach_device(dev);
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index df6ce59a1f95..918f5e644506 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -673,9 +673,8 @@ enum mlx5_device_state {
 };
 
 enum mlx5_interface_state {
-	MLX5_INTERFACE_STATE_DOWN = BIT(0),
-	MLX5_INTERFACE_STATE_UP = BIT(1),
-	MLX5_INTERFACE_STATE_SHUTDOWN = BIT(2),
+	MLX5_INTERFACE_STATE_UP = BIT(0),
+	MLX5_INTERFACE_STATE_SHUTDOWN = BIT(1),
 };
 
 enum mlx5_pci_status {
-- 
2.13.0
