From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 4/7] net/mlx5_core: Use private health thread for each device
Date: Thu,  8 Oct 2015 17:14:00 +0300
Message-ID: <1444313643-15284-5-git-send-email-ogerlitz@mellanox.com>
References: <1444313643-15284-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Eli Cohen <eli@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:45279 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932192AbbJHOOd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Oct 2015 10:14:33 -0400
In-Reply-To: <1444313643-15284-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eli Cohen <eli@mellanox.com>

Use a single threaded work queue for each device in the system instead of
using one thread for any device. This is required so we can concurrently
process system error handling for all the devices that need that.

Signed-off-by: Eli Cohen <eli@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/health.c | 63 +++++++++++-------------
 drivers/net/ethernet/mellanox/mlx5/core/main.c   | 37 +++++++-------
 include/linux/mlx5/driver.h                      |  7 +--
 3 files changed, 52 insertions(+), 55 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/health.c b/drivers/net/ethernet/mellanox/mlx5/core/health.c
index 8770968..9b81e1c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/health.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/health.c
@@ -57,31 +57,16 @@ enum {
 	MLX5_HEALTH_SYNDR_HIGH_TEMP		= 0x10
 };
 
-static DEFINE_SPINLOCK(health_lock);
-static LIST_HEAD(health_list);
-static struct work_struct health_work;
-
 static void health_care(struct work_struct *work)
 {
-	struct mlx5_core_health *health, *n;
+	struct mlx5_core_health *health;
 	struct mlx5_core_dev *dev;
 	struct mlx5_priv *priv;
-	LIST_HEAD(tlist);
-
-	spin_lock_irq(&health_lock);
-	list_splice_init(&health_list, &tlist);
-
-	spin_unlock_irq(&health_lock);
 
-	list_for_each_entry_safe(health, n, &tlist, list) {
-		priv = container_of(health, struct mlx5_priv, health);
-		dev = container_of(priv, struct mlx5_core_dev, priv);
-		mlx5_core_warn(dev, "handling bad device here\n");
-		/* nothing yet */
-		spin_lock_irq(&health_lock);
-		list_del_init(&health->list);
-		spin_unlock_irq(&health_lock);
-	}
+	health = container_of(work, struct mlx5_core_health, work);
+	priv = container_of(health, struct mlx5_priv, health);
+	dev = container_of(priv, struct mlx5_core_dev, priv);
+	mlx5_core_warn(dev, "handling bad device here\n");
 }
 
 static const char *hsynd_str(u8 synd)
@@ -168,11 +153,7 @@ static void poll_health(unsigned long data)
 	if (health->miss_counter == MAX_MISSES) {
 		mlx5_core_err(dev, "device's health compromised\n");
 		print_health_info(dev);
-		spin_lock_irq(&health_lock);
-		list_add_tail(&health->list, &health_list);
-		spin_unlock_irq(&health_lock);
-
-		queue_work(mlx5_core_wq, &health_work);
+		queue_work(health->wq, &health->work);
 	} else {
 		get_random_bytes(&next, sizeof(next));
 		next %= HZ;
@@ -185,7 +166,6 @@ void mlx5_start_health_poll(struct mlx5_core_dev *dev)
 {
 	struct mlx5_core_health *health = &dev->priv.health;
 
-	INIT_LIST_HEAD(&health->list);
 	init_timer(&health->timer);
 	health->health = &dev->iseg->health;
 	health->health_counter = &dev->iseg->health_counter;
@@ -201,18 +181,33 @@ void mlx5_stop_health_poll(struct mlx5_core_dev *dev)
 	struct mlx5_core_health *health = &dev->priv.health;
 
 	del_timer_sync(&health->timer);
-
-	spin_lock_irq(&health_lock);
-	if (!list_empty(&health->list))
-		list_del_init(&health->list);
-	spin_unlock_irq(&health_lock);
 }
 
-void mlx5_health_cleanup(void)
+void mlx5_health_cleanup(struct mlx5_core_dev *dev)
 {
+	struct mlx5_core_health *health = &dev->priv.health;
+
+	destroy_workqueue(health->wq);
 }
 
-void  __init mlx5_health_init(void)
+int mlx5_health_init(struct mlx5_core_dev *dev)
 {
-	INIT_WORK(&health_work, health_care);
+	struct mlx5_core_health *health;
+	char *name;
+
+	health = &dev->priv.health;
+	name = kmalloc(64, GFP_KERNEL);
+	if (!name)
+		return -ENOMEM;
+
+	strcpy(name, "mlx5_health");
+	strcat(name, dev_name(&dev->pdev->dev));
+	health->wq = create_singlethread_workqueue(name);
+	kfree(name);
+	if (!health->wq)
+		return -ENOMEM;
+
+	INIT_WORK(&health->work, health_care);
+
+	return 0;
 }
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index 7718f6a..b6edc58 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -62,7 +62,6 @@ static int prof_sel = MLX5_DEFAULT_PROF;
 module_param_named(prof_sel, prof_sel, int, 0444);
 MODULE_PARM_DESC(prof_sel, "profile selector. Valid range 0 - 2");
 
-struct workqueue_struct *mlx5_core_wq;
 static LIST_HEAD(intf_list);
 static LIST_HEAD(dev_list);
 static DEFINE_MUTEX(intf_mutex);
@@ -1046,6 +1045,7 @@ err_pagealloc_cleanup:
 
 static int mlx5_unload_one(struct mlx5_core_dev *dev, struct mlx5_priv *priv)
 {
+	int err;
 
 	mlx5_unregister_device(dev);
 	mlx5_cleanup_mr_table(dev);
@@ -1060,9 +1060,10 @@ static int mlx5_unload_one(struct mlx5_core_dev *dev, struct mlx5_priv *priv)
 	mlx5_eq_cleanup(dev);
 	mlx5_disable_msix(dev);
 	mlx5_stop_health_poll(dev);
-	if (mlx5_cmd_teardown_hca(dev)) {
+	err = mlx5_cmd_teardown_hca(dev);
+	if (err) {
 		dev_err(&dev->pdev->dev, "tear_down_hca failed, skip cleanup\n");
-		return 1;
+		goto out;
 	}
 	mlx5_pagealloc_stop(dev);
 	mlx5_reclaim_startup_pages(dev);
@@ -1070,11 +1071,12 @@ static int mlx5_unload_one(struct mlx5_core_dev *dev, struct mlx5_priv *priv)
 	mlx5_pagealloc_cleanup(dev);
 	mlx5_cmd_cleanup(dev);
 
-	return 0;
+out:
+	return err;
 }
 
 static void mlx5_core_event(struct mlx5_core_dev *dev, enum mlx5_dev_event event,
-			    unsigned long param)
+		     unsigned long param)
 {
 	struct mlx5_priv *priv = &dev->priv;
 	struct mlx5_device_context *dev_ctx;
@@ -1129,14 +1131,22 @@ static int init_one(struct pci_dev *pdev,
 		goto clean_dev;
 	}
 
+	err = mlx5_health_init(dev);
+	if (err) {
+		dev_err(&pdev->dev, "mlx5_health_init failed with error code %d\n", err);
+		goto close_pci;
+	}
+
 	err = mlx5_load_one(dev, priv);
 	if (err) {
 		dev_err(&pdev->dev, "mlx5_load_one failed with error code %d\n", err);
-		goto close_pci;
+		goto clean_health;
 	}
 
 	return 0;
 
+clean_health:
+	mlx5_health_cleanup(dev);
 close_pci:
 	mlx5_pci_close(dev, priv);
 clean_dev:
@@ -1153,8 +1163,10 @@ static void remove_one(struct pci_dev *pdev)
 
 	if (mlx5_unload_one(dev, priv)) {
 		dev_err(&dev->pdev->dev, "mlx5_unload_one failed\n");
+		mlx5_health_cleanup(dev);
 		return;
 	}
+	mlx5_health_cleanup(dev);
 	mlx5_pci_close(dev, priv);
 	pci_set_drvdata(pdev, NULL);
 	kfree(dev);
@@ -1184,16 +1196,10 @@ static int __init init(void)
 	int err;
 
 	mlx5_register_debugfs();
-	mlx5_core_wq = create_singlethread_workqueue("mlx5_core_wq");
-	if (!mlx5_core_wq) {
-		err = -ENOMEM;
-		goto err_debug;
-	}
-	mlx5_health_init();
 
 	err = pci_register_driver(&mlx5_core_driver);
 	if (err)
-		goto err_health;
+		goto err_debug;
 
 #ifdef CONFIG_MLX5_CORE_EN
 	mlx5e_init();
@@ -1201,9 +1207,6 @@ static int __init init(void)
 
 	return 0;
 
-err_health:
-	mlx5_health_cleanup();
-	destroy_workqueue(mlx5_core_wq);
 err_debug:
 	mlx5_unregister_debugfs();
 	return err;
@@ -1215,8 +1218,6 @@ static void __exit cleanup(void)
 	mlx5e_cleanup();
 #endif
 	pci_unregister_driver(&mlx5_core_driver);
-	mlx5_health_cleanup();
-	destroy_workqueue(mlx5_core_wq);
 	mlx5_unregister_debugfs();
 }
 
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index aa89955..41a3287 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -391,9 +391,10 @@ struct mlx5_core_health {
 	struct health_buffer __iomem   *health;
 	__be32 __iomem		       *health_counter;
 	struct timer_list		timer;
-	struct list_head		list;
 	u32				prev;
 	int				miss_counter;
+	struct workqueue_struct	       *wq;
+	struct work_struct		work;
 };
 
 struct mlx5_cq_table {
@@ -676,8 +677,8 @@ int mlx5_alloc_uuars(struct mlx5_core_dev *dev, struct mlx5_uuar_info *uuari);
 int mlx5_free_uuars(struct mlx5_core_dev *dev, struct mlx5_uuar_info *uuari);
 int mlx5_alloc_map_uar(struct mlx5_core_dev *mdev, struct mlx5_uar *uar);
 void mlx5_unmap_free_uar(struct mlx5_core_dev *mdev, struct mlx5_uar *uar);
-void mlx5_health_cleanup(void);
-void  __init mlx5_health_init(void);
+void mlx5_health_cleanup(struct mlx5_core_dev *dev);
+int mlx5_health_init(struct mlx5_core_dev *dev);
 void mlx5_start_health_poll(struct mlx5_core_dev *dev);
 void mlx5_stop_health_poll(struct mlx5_core_dev *dev);
 int mlx5_buf_alloc_node(struct mlx5_core_dev *dev, int size,
-- 
2.3.7
