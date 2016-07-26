From: Bhaktipriya Shridhar <bhaktipriya96-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH v2] net/mlx5_core/health: Remove deprecated
 create_singlethread_workqueue
Date: Tue, 26 Jul 2016 22:38:24 +0530
Message-ID: <20160726170824.GA10721@Karyakshetra>
References: <20160717051327.GA20674@leon.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
To: Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20160717051327.GA20674-2ukJVAZIZ/Y@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The workqueue health->wq was used as per device private health thread.
This was done to perform delayed work.

The workqueue has a single workitem(&health->work) and
hence doesn't require ordering. It is involved in handling the health of
the device and is not being used on a memory reclaim path.
Hence, the singlethreaded workqueue has been replaced with the use of
system_wq.

Work item has been flushed in mlx5_health_cleanup() to ensure that
there are no pending tasks while disconnecting the driver.

Signed-off-by: Bhaktipriya Shridhar <bhaktipriya96-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 Changes in v2:
	-Updated commit description as per the feedback received.

 drivers/net/ethernet/mellanox/mlx5/core/health.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/health.c b/drivers/net/ethernet/mellanox/mlx5/core/health.c
index 42d16b9..9acbccf 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/health.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/health.c
@@ -267,7 +267,7 @@ static void poll_health(unsigned long data)
 	if (in_fatal(dev) && !health->sick) {
 		health->sick = true;
 		print_health_info(dev);
-		queue_work(health->wq, &health->work);
+		schedule_work(&health->work);
 	}
 }

@@ -296,7 +296,7 @@ void mlx5_health_cleanup(struct mlx5_core_dev *dev)
 {
 	struct mlx5_core_health *health = &dev->priv.health;

-	destroy_workqueue(health->wq);
+	flush_work(&health->work);
 }

 int mlx5_health_init(struct mlx5_core_dev *dev)
@@ -311,10 +311,7 @@ int mlx5_health_init(struct mlx5_core_dev *dev)

 	strcpy(name, "mlx5_health");
 	strcat(name, dev_name(&dev->pdev->dev));
-	health->wq = create_singlethread_workqueue(name);
 	kfree(name);
-	if (!health->wq)
-		return -ENOMEM;

 	INIT_WORK(&health->work, health_care);

--
2.1.4

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
