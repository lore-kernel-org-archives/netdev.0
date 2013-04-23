From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V3 5/5] net/mlx4_en: Add a service task
Date: Tue, 23 Apr 2013 19:06:51 +0300
Message-ID: <1366733211-10228-6-git-send-email-amirv@mellanox.com>
References: <1366733211-10228-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Richard Cochran <richardcochran@gmail.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog110.obsmtp.com ([207.126.144.129]:40634 "EHLO
	eu1sys200aog110.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932196Ab3DWQHB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Apr 2013 12:07:01 -0400
In-Reply-To: <1366733211-10228-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a service task to run tasks that needed to be executed periodically.
Currently the only task is a watchdog to catch NIC clock overflow, to make
timestamping accurate.
Will move the statistics task into this framework in a later patch.

Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_clock.c  |   19 +++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |   24 ++++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   |    4 ++++
 3 files changed, 47 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_clock.c b/drivers/net/ethernet/mellanox/mlx4/en_clock.c
index 501c72f..2f18121 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_clock.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_clock.c
@@ -129,4 +129,23 @@ void mlx4_en_init_timestamp(struct mlx4_en_dev *mdev)
 
 	timecounter_init(&mdev->clock, &mdev->cycles,
 			 ktime_to_ns(ktime_get_real()));
+
+	/* Calculate period in seconds to call the overflow watchdog - to make
+	 * sure counter is checked at least once every wrap around.
+	 */
+	mdev->overflow_period =
+		(cyclecounter_cyc2ns(&mdev->cycles,
+				    mdev->cycles.mask) / NSEC_PER_SEC / 2)
+		* HZ;
+}
+
+void mlx4_en_ptp_overflow_check(struct mlx4_en_dev *mdev)
+{
+	bool timeout = time_is_before_jiffies(mdev->last_overflow_check +
+					      mdev->overflow_period);
+
+	if (timeout) {
+		timecounter_read(&mdev->clock);
+		mdev->last_overflow_check = jiffies;
+	}
 }
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 4cb9f32..f4f88b8 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -1361,6 +1361,26 @@ static void mlx4_en_do_get_stats(struct work_struct *work)
 	mutex_unlock(&mdev->state_lock);
 }
 
+/* mlx4_en_service_task - Run service task for tasks that needed to be done
+ * periodically
+ */
+static void mlx4_en_service_task(struct work_struct *work)
+{
+	struct delayed_work *delay = to_delayed_work(work);
+	struct mlx4_en_priv *priv = container_of(delay, struct mlx4_en_priv,
+						 service_task);
+	struct mlx4_en_dev *mdev = priv->mdev;
+
+	mutex_lock(&mdev->state_lock);
+	if (mdev->device_up) {
+		mlx4_en_ptp_overflow_check(mdev);
+
+		queue_delayed_work(mdev->workqueue, &priv->service_task,
+				   SERVICE_TASK_DELAY);
+	}
+	mutex_unlock(&mdev->state_lock);
+}
+
 static void mlx4_en_linkstate(struct work_struct *work)
 {
 	struct mlx4_en_priv *priv = container_of(work, struct mlx4_en_priv,
@@ -1865,6 +1885,7 @@ void mlx4_en_destroy_netdev(struct net_device *dev)
 		mlx4_free_hwq_res(mdev->dev, &priv->res, MLX4_EN_PAGE_SIZE);
 
 	cancel_delayed_work(&priv->stats_task);
+	cancel_delayed_work(&priv->service_task);
 	/* flush any pending task for this netdev */
 	flush_workqueue(mdev->workqueue);
 
@@ -2084,6 +2105,7 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	INIT_WORK(&priv->watchdog_task, mlx4_en_restart);
 	INIT_WORK(&priv->linkstate_task, mlx4_en_linkstate);
 	INIT_DELAYED_WORK(&priv->stats_task, mlx4_en_do_get_stats);
+	INIT_DELAYED_WORK(&priv->service_task, mlx4_en_service_task);
 #ifdef CONFIG_MLX4_EN_DCB
 	if (!mlx4_is_slave(priv->mdev->dev)) {
 		if (mdev->dev->caps.flags & MLX4_DEV_CAP_FLAG_SET_ETH_SCHED) {
@@ -2206,6 +2228,8 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	}
 	mlx4_en_set_default_moderation(priv);
 	queue_delayed_work(mdev->workqueue, &priv->stats_task, STATS_DELAY);
+	queue_delayed_work(mdev->workqueue, &priv->service_task,
+			   SERVICE_TASK_DELAY);
 	return 0;
 
 out:
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 85b0754..b1d7657 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -78,6 +78,7 @@
 #define STAMP_SHIFT		31
 #define STAMP_VAL		0x7fffffff
 #define STATS_DELAY		(HZ / 4)
+#define SERVICE_TASK_DELAY	(HZ / 4)
 #define MAX_NUM_OF_FS_RULES	256
 
 #define MLX4_EN_FILTER_HASH_SHIFT 4
@@ -355,6 +356,7 @@ struct mlx4_en_dev {
 	struct cyclecounter	cycles;
 	struct timecounter	clock;
 	unsigned long		last_overflow_check;
+	unsigned long		overflow_period;
 };
 
 
@@ -519,6 +521,7 @@ struct mlx4_en_priv {
 	struct work_struct watchdog_task;
 	struct work_struct linkstate_task;
 	struct delayed_work stats_task;
+	struct delayed_work service_task;
 	struct mlx4_en_perf_stats pstats;
 	struct mlx4_en_pkt_stats pkstats;
 	struct mlx4_en_port_stats port_stats;
@@ -645,6 +648,7 @@ void mlx4_en_cleanup_filters(struct mlx4_en_priv *priv,
 #define MLX4_EN_NUM_SELF_TEST	5
 void mlx4_en_ex_selftest(struct net_device *dev, u32 *flags, u64 *buf);
 u64 mlx4_en_mac_to_u64(u8 *addr);
+void mlx4_en_ptp_overflow_check(struct mlx4_en_dev *mdev);
 
 /*
  * Functions for time stamping
-- 
1.7.8.2
