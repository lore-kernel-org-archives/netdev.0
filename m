From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 02/13] net/mlx5: Avoid calling sleeping function by the health poll thread
Date: Thu, 30 Jun 2016 17:34:39 +0300
Message-ID: <1467297290-11443-3-git-send-email-saeedm@mellanox.com>
References: <1467297290-11443-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Mohamad Haj Yahia <mohamad@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:37672 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752141AbcF3OhV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Jun 2016 10:37:21 -0400
In-Reply-To: <1467297290-11443-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mohamad Haj Yahia <mohamad@mellanox.com>

In internal error state the health poll thread will eventually call
synchronize_irq() (to safely trigger command completions) which might
sleep, so we are calling sleeping function from atomic context which is
invalid.
Here we move trigger_cmd_completions(dev) to enter error state which is
the earliest stage in error state handling.
This way we won't need to wait for next health poll to trigger command
completions and will solve the scheduling while atomic issue.
mlx5_enter_error_state can be called from two contexts, protect it with
dev->intf_state_lock

Fixes: 89d44f0a6c73 ('net/mlx5_core: Add pci error handlers to mlx5_core driver')
Signed-off-by: Mohamad Haj Yahia <mohamad@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/health.c | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/health.c b/drivers/net/ethernet/mellanox/mlx5/core/health.c
index 42d16b9..96a5946 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/health.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/health.c
@@ -108,15 +108,21 @@ static int in_fatal(struct mlx5_core_dev *dev)
 
 void mlx5_enter_error_state(struct mlx5_core_dev *dev)
 {
+	mutex_lock(&dev->intf_state_mutex);
 	if (dev->state == MLX5_DEVICE_STATE_INTERNAL_ERROR)
-		return;
+		goto unlock;
 
 	mlx5_core_err(dev, "start\n");
-	if (pci_channel_offline(dev->pdev) || in_fatal(dev))
+	if (pci_channel_offline(dev->pdev) || in_fatal(dev)) {
 		dev->state = MLX5_DEVICE_STATE_INTERNAL_ERROR;
+		trigger_cmd_completions(dev);
+	}
 
 	mlx5_core_event(dev, MLX5_DEV_EVENT_SYS_ERROR, 0);
 	mlx5_core_err(dev, "end\n");
+
+unlock:
+	mutex_unlock(&dev->intf_state_mutex);
 }
 
 static void mlx5_handle_bad_state(struct mlx5_core_dev *dev)
@@ -245,7 +251,6 @@ static void poll_health(unsigned long data)
 	u32 count;
 
 	if (dev->state == MLX5_DEVICE_STATE_INTERNAL_ERROR) {
-		trigger_cmd_completions(dev);
 		mod_timer(&health->timer, get_next_poll_jiffies());
 		return;
 	}
-- 
2.8.0
