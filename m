From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 2/2] net/mlx4_en: Fix HW timestamp init issue upon system startup
Date: Thu, 17 Dec 2015 15:35:38 +0200
Message-ID: <1450359338-32220-3-git-send-email-ogerlitz@mellanox.com>
References: <a>
 <1450359338-32220-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Eugenia Emantayev <eugenia@mellanox.com>,
	Marina Varshaver <marinav@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:36160 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753462AbbLQNgG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Dec 2015 08:36:06 -0500
In-Reply-To: <1450359338-32220-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugenia Emantayev <eugenia@mellanox.com>

mlx4_en_init_timestamp was called before creation of netdev and port
init, thus used uninitialized values.  Specifically - NIC frequency was
incorrect causing wrong calculations and later wrong HW timestamps.

Fixes: 1ec4864b1017 ('net/mlx4_en: Fixed crash when port type is changed')
Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
Signed-off-by: Marina Varshaver <marinav@mellanox.com>
Signed-off-by: Eran Ben Elisha <eranbe@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_clock.c  | 7 +++++++
 drivers/net/ethernet/mellanox/mlx4/en_main.c   | 7 -------
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 7 +++++++
 3 files changed, 14 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_clock.c b/drivers/net/ethernet/mellanox/mlx4/en_clock.c
index 8a083d7..038f9ce 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_clock.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_clock.c
@@ -242,6 +242,13 @@ void mlx4_en_init_timestamp(struct mlx4_en_dev *mdev)
 	unsigned long flags;
 	u64 ns, zero = 0;
 
+	/* mlx4_en_init_timestamp is called for each netdev.
+	 * mdev->ptp_clock is common for all ports, skip initialization if
+	 * was done for other port.
+	 */
+	if (mdev->ptp_clock)
+		return;
+
 	rwlock_init(&mdev->clock_lock);
 
 	memset(&mdev->cycles, 0, sizeof(mdev->cycles));
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_main.c b/drivers/net/ethernet/mellanox/mlx4/en_main.c
index 005f910..e0ec280 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_main.c
@@ -232,9 +232,6 @@ static void mlx4_en_remove(struct mlx4_dev *dev, void *endev_ptr)
 		if (mdev->pndev[i])
 			mlx4_en_destroy_netdev(mdev->pndev[i]);
 
-	if (mdev->dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_TS)
-		mlx4_en_remove_timestamp(mdev);
-
 	flush_workqueue(mdev->workqueue);
 	destroy_workqueue(mdev->workqueue);
 	(void) mlx4_mr_free(dev, &mdev->mr);
@@ -320,10 +317,6 @@ static void *mlx4_en_add(struct mlx4_dev *dev)
 	mlx4_foreach_port(i, dev, MLX4_PORT_TYPE_ETH)
 		mdev->port_cnt++;
 
-	/* Initialize time stamp mechanism */
-	if (mdev->dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_TS)
-		mlx4_en_init_timestamp(mdev);
-
 	/* Set default number of RX rings*/
 	mlx4_en_set_num_rx_rings(mdev);
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 4eef316..7869f97 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -2072,6 +2072,9 @@ void mlx4_en_destroy_netdev(struct net_device *dev)
 	/* flush any pending task for this netdev */
 	flush_workqueue(mdev->workqueue);
 
+	if (mdev->dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_TS)
+		mlx4_en_remove_timestamp(mdev);
+
 	/* Detach the netdev so tasks would not attempt to access it */
 	mutex_lock(&mdev->state_lock);
 	mdev->pndev[priv->port] = NULL;
@@ -3058,6 +3061,10 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	}
 	queue_delayed_work(mdev->workqueue, &priv->stats_task, STATS_DELAY);
 
+	/* Initialize time stamp mechanism */
+	if (mdev->dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_TS)
+		mlx4_en_init_timestamp(mdev);
+
 	queue_delayed_work(mdev->workqueue, &priv->service_task,
 			   SERVICE_TASK_DELAY);
 
-- 
2.3.7
