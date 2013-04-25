From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH V1 net-next 2/8] net/mlx4_en: Disable HW clock overflow check when no HW support
Date: Thu, 25 Apr 2013 18:22:24 +0300
Message-ID: <1366903350-9096-3-git-send-email-ogerlitz@mellanox.com>
References: <1366903350-9096-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog111.obsmtp.com ([207.126.144.131]:38261 "EHLO
	eu1sys200aog111.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755921Ab3DYPWo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 11:22:44 -0400
In-Reply-To: <1366903350-9096-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>

Should not run HW clock overflow check if HW clock is not supported. Also, since
this watchdog is the only customer of service_task, no need to start it in that case.

Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index f4f88b8..05c7c13 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -1373,7 +1373,8 @@ static void mlx4_en_service_task(struct work_struct *work)
 
 	mutex_lock(&mdev->state_lock);
 	if (mdev->device_up) {
-		mlx4_en_ptp_overflow_check(mdev);
+		if (mdev->dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_TS)
+			mlx4_en_ptp_overflow_check(mdev);
 
 		queue_delayed_work(mdev->workqueue, &priv->service_task,
 				   SERVICE_TASK_DELAY);
@@ -2228,8 +2229,11 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	}
 	mlx4_en_set_default_moderation(priv);
 	queue_delayed_work(mdev->workqueue, &priv->stats_task, STATS_DELAY);
-	queue_delayed_work(mdev->workqueue, &priv->service_task,
-			   SERVICE_TASK_DELAY);
+
+	if (mdev->dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_TS)
+		queue_delayed_work(mdev->workqueue, &priv->service_task,
+				   SERVICE_TASK_DELAY);
+
 	return 0;
 
 out:
-- 
1.7.1
