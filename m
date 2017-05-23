From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [for-next 3/6] net/mlx5: Introduce trigger_health_work function
Date: Tue, 23 May 2017 14:44:01 +0300
Message-ID: <20170523114404.20387-4-saeedm@mellanox.com>
References: <20170523114404.20387-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        Ilan Tayari <ilant@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>,
        Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:51035 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1762552AbdEWLoO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 07:44:14 -0400
In-Reply-To: <20170523114404.20387-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ilan Tayari <ilant@mellanox.com>

Introduce new function for entering bad-health state.

This function will be called from FPGA-related logic in a later patch from
asynchronous event (IRQ) context, for that we change the spin lock to an
IRQ-safe one.

Signed-off-by: Ilan Tayari <ilant@mellanox.com>
Reviewed-by: Boris Pismenny <borisp@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/health.c | 32 ++++++++++++++++--------
 include/linux/mlx5/driver.h                      |  1 +
 2 files changed, 22 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/health.c b/drivers/net/ethernet/mellanox/mlx5/core/health.c
index d0515391d33b..c3cedb6cec3f 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/health.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/health.c
@@ -185,6 +185,7 @@ static void health_care(struct work_struct *work)
 	struct mlx5_core_health *health;
 	struct mlx5_core_dev *dev;
 	struct mlx5_priv *priv;
+	unsigned long flags;
 
 	health = container_of(work, struct mlx5_core_health, work);
 	priv = container_of(health, struct mlx5_priv, health);
@@ -192,13 +193,13 @@ static void health_care(struct work_struct *work)
 	mlx5_core_warn(dev, "handling bad device here\n");
 	mlx5_handle_bad_state(dev);
 
-	spin_lock(&health->wq_lock);
+	spin_lock_irqsave(&health->wq_lock, flags);
 	if (!test_bit(MLX5_DROP_NEW_HEALTH_WORK, &health->flags))
 		schedule_delayed_work(&health->recover_work, recover_delay);
 	else
 		dev_err(&dev->pdev->dev,
 			"new health works are not permitted at this stage\n");
-	spin_unlock(&health->wq_lock);
+	spin_unlock_irqrestore(&health->wq_lock, flags);
 }
 
 static const char *hsynd_str(u8 synd)
@@ -269,6 +270,20 @@ static unsigned long get_next_poll_jiffies(void)
 	return next;
 }
 
+void mlx5_trigger_health_work(struct mlx5_core_dev *dev)
+{
+	struct mlx5_core_health *health = &dev->priv.health;
+	unsigned long flags;
+
+	spin_lock_irqsave(&health->wq_lock, flags);
+	if (!test_bit(MLX5_DROP_NEW_HEALTH_WORK, &health->flags))
+		queue_work(health->wq, &health->work);
+	else
+		dev_err(&dev->pdev->dev,
+			"new health works are not permitted at this stage\n");
+	spin_unlock_irqrestore(&health->wq_lock, flags);
+}
+
 static void poll_health(unsigned long data)
 {
 	struct mlx5_core_dev *dev = (struct mlx5_core_dev *)data;
@@ -297,13 +312,7 @@ static void poll_health(unsigned long data)
 	if (in_fatal(dev) && !health->sick) {
 		health->sick = true;
 		print_health_info(dev);
-		spin_lock(&health->wq_lock);
-		if (!test_bit(MLX5_DROP_NEW_HEALTH_WORK, &health->flags))
-			queue_work(health->wq, &health->work);
-		else
-			dev_err(&dev->pdev->dev,
-				"new health works are not permitted at this stage\n");
-		spin_unlock(&health->wq_lock);
+		mlx5_trigger_health_work(dev);
 	}
 }
 
@@ -333,10 +342,11 @@ void mlx5_stop_health_poll(struct mlx5_core_dev *dev)
 void mlx5_drain_health_wq(struct mlx5_core_dev *dev)
 {
 	struct mlx5_core_health *health = &dev->priv.health;
+	unsigned long flags;
 
-	spin_lock(&health->wq_lock);
+	spin_lock_irqsave(&health->wq_lock, flags);
 	set_bit(MLX5_DROP_NEW_HEALTH_WORK, &health->flags);
-	spin_unlock(&health->wq_lock);
+	spin_unlock_irqrestore(&health->wq_lock, flags);
 	cancel_delayed_work_sync(&health->recover_work);
 	cancel_work_sync(&health->work);
 }
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index c2740688d679..a277bb36c21f 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -915,6 +915,7 @@ int mlx5_health_init(struct mlx5_core_dev *dev);
 void mlx5_start_health_poll(struct mlx5_core_dev *dev);
 void mlx5_stop_health_poll(struct mlx5_core_dev *dev);
 void mlx5_drain_health_wq(struct mlx5_core_dev *dev);
+void mlx5_trigger_health_work(struct mlx5_core_dev *dev);
 int mlx5_buf_alloc_node(struct mlx5_core_dev *dev, int size,
 			struct mlx5_buf *buf, int node);
 int mlx5_buf_alloc(struct mlx5_core_dev *dev, int size, struct mlx5_buf *buf);
-- 
2.11.0
