From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net 2/6] net/mlx5: Continue health polling until it is explicitly stopped
Date: Sun, 11 Jun 2017 17:00:24 +0300
Message-ID: <20170611140028.12467-3-saeedm@mellanox.com>
References: <20170611140028.12467-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Mohamad Haj Yahia <mohamad@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:35974 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751955AbdFKOAv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 11 Jun 2017 10:00:51 -0400
In-Reply-To: <20170611140028.12467-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mohamad Haj Yahia <mohamad@mellanox.com>

The issue is that when we get an assert we will stop polling the health
and thus we cant enter error state when we have a real health issue.

Fixes: fd76ee4da55a ('net/mlx5_core: Fix internal error detection conditions')
Signed-off-by: Mohamad Haj Yahia <mohamad@mellanox.com>
Reviewed-by: Daniel Jurgens <danielj@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/health.c | 11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/health.c b/drivers/net/ethernet/mellanox/mlx5/core/health.c
index 44f59b1d6f0f..f27f84ffbc85 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/health.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/health.c
@@ -275,10 +275,8 @@ static void poll_health(unsigned long data)
 	struct mlx5_core_health *health = &dev->priv.health;
 	u32 count;
 
-	if (dev->state == MLX5_DEVICE_STATE_INTERNAL_ERROR) {
-		mod_timer(&health->timer, get_next_poll_jiffies());
-		return;
-	}
+	if (dev->state == MLX5_DEVICE_STATE_INTERNAL_ERROR)
+		goto out;
 
 	count = ioread32be(health->health_counter);
 	if (count == health->prev)
@@ -290,8 +288,6 @@ static void poll_health(unsigned long data)
 	if (health->miss_counter == MAX_MISSES) {
 		dev_err(&dev->pdev->dev, "device's health compromised - reached miss count\n");
 		print_health_info(dev);
-	} else {
-		mod_timer(&health->timer, get_next_poll_jiffies());
 	}
 
 	if (in_fatal(dev) && !health->sick) {
@@ -305,6 +301,9 @@ static void poll_health(unsigned long data)
 				"new health works are not permitted at this stage\n");
 		spin_unlock(&health->wq_lock);
 	}
+
+out:
+	mod_timer(&health->timer, get_next_poll_jiffies());
 }
 
 void mlx5_start_health_poll(struct mlx5_core_dev *dev)
-- 
2.11.0
