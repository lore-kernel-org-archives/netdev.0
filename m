From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 01/16] net/mlx5: Set interface flags before cleanup in unload_one
Date: Tue, 27 Jun 2017 17:28:41 +0300
Message-ID: <20170627142856.9448-2-saeedm@mellanox.com>
References: <20170627142856.9448-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Leon Romanovsky <leonro@mellanox.com>,
        Ilan Tayari <ilant@mellanox.com>,
        Boris Pismenny <borisp@mellanox.com>,
        Yevgeny Kliteynik <kliteyn@mellanox.com>,
        Yossi Kuperman <yossiku@mellanox.com>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        Sowmini Varadhan <sowmini.varadhan@oracle.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:50375 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752656AbdF0OaK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2017 10:30:10 -0400
In-Reply-To: <20170627142856.9448-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ilan Tayari <ilant@mellanox.com>

In load_one, the interface flags are changed from down to up,
only after initializing the interfaces.
In unload_one, the flags are changed from up to down before the
interface cleanup.

Change the cleanup order to be opposite to initialization order.

This fixes flag consistency between init and cleanup.

Signed-off-by: Ilan Tayari <ilant@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/main.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index c7f75e12c13b..9a5a475d9e00 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -1254,6 +1254,9 @@ static int mlx5_unload_one(struct mlx5_core_dev *dev, struct mlx5_priv *priv,
 		goto out;
 	}
 
+	clear_bit(MLX5_INTERFACE_STATE_UP, &dev->intf_state);
+	set_bit(MLX5_INTERFACE_STATE_DOWN, &dev->intf_state);
+
 	if (mlx5_device_registered(dev))
 		mlx5_detach_device(dev);
 
@@ -1282,8 +1285,6 @@ static int mlx5_unload_one(struct mlx5_core_dev *dev, struct mlx5_priv *priv,
 	mlx5_cmd_cleanup(dev);
 
 out:
-	clear_bit(MLX5_INTERFACE_STATE_UP, &dev->intf_state);
-	set_bit(MLX5_INTERFACE_STATE_DOWN, &dev->intf_state);
 	mutex_unlock(&dev->intf_state_mutex);
 	return err;
 }
-- 
2.11.0
