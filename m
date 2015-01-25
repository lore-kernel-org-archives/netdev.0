From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH V1 net-next 3/9] net/mlx4_core: Refactor the catas flow to work per device
Date: Sun, 25 Jan 2015 16:59:37 +0200
Message-ID: <1422197983-16048-4-git-send-email-ogerlitz@mellanox.com>
References: <1422197983-16048-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Matan Barak <matanb@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Roland Dreier <roland@kernel.org>,
	Yishai Hadas <yishaih@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:33637 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753598AbbAYO75 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 Jan 2015 09:59:57 -0500
In-Reply-To: <1422197983-16048-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yishai Hadas <yishaih@mellanox.com>

Using a WQ per device instead of a single global WQ, this allows
independent reset handling per device even when SRIOV is used.

This comes as a pre-patch for supporting chip reset
for both native and SRIOV.

Signed-off-by: Yishai Hadas <yishaih@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/catas.c |   75 +++++++++++++---------------
 drivers/net/ethernet/mellanox/mlx4/main.c  |   12 ++++-
 drivers/net/ethernet/mellanox/mlx4/mlx4.h  |    3 +-
 include/linux/mlx4/device.h                |    2 +
 4 files changed, 48 insertions(+), 44 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/catas.c b/drivers/net/ethernet/mellanox/mlx4/catas.c
index 1a102c9..5bb9aa6 100644
--- a/drivers/net/ethernet/mellanox/mlx4/catas.c
+++ b/drivers/net/ethernet/mellanox/mlx4/catas.c
@@ -40,10 +40,7 @@ enum {
 	MLX4_CATAS_POLL_INTERVAL	= 5 * HZ,
 };
 
-static DEFINE_SPINLOCK(catas_lock);
 
-static LIST_HEAD(catas_list);
-static struct work_struct catas_work;
 
 static int internal_err_reset = 1;
 module_param(internal_err_reset, int, 0644);
@@ -77,13 +74,9 @@ static void poll_catas(unsigned long dev_ptr)
 			dump_err_buf(dev);
 			mlx4_dispatch_event(dev, MLX4_DEV_EVENT_CATASTROPHIC_ERROR, 0);
 
-			if (internal_err_reset) {
-				spin_lock(&catas_lock);
-				list_add(&priv->catas_err.list, &catas_list);
-				spin_unlock(&catas_lock);
-
-				queue_work(mlx4_wq, &catas_work);
-			}
+			if (internal_err_reset)
+				queue_work(dev->persist->catas_wq,
+					   &dev->persist->catas_work);
 		}
 	} else
 		mod_timer(&priv->catas_err.timer,
@@ -92,34 +85,23 @@ static void poll_catas(unsigned long dev_ptr)
 
 static void catas_reset(struct work_struct *work)
 {
-	struct mlx4_priv *priv, *tmppriv;
-	struct mlx4_dev *dev;
-	struct mlx4_dev_persistent *persist;
-
-	LIST_HEAD(tlist);
+	struct mlx4_dev_persistent *persist =
+		container_of(work, struct mlx4_dev_persistent,
+			     catas_work);
+	struct pci_dev *pdev = persist->pdev;
 	int ret;
 
-	spin_lock_irq(&catas_lock);
-	list_splice_init(&catas_list, &tlist);
-	spin_unlock_irq(&catas_lock);
-
-	list_for_each_entry_safe(priv, tmppriv, &tlist, catas_err.list) {
-		struct pci_dev *pdev = priv->dev.persist->pdev;
-
-		/* If the device is off-line, we cannot reset it */
-		if (pci_channel_offline(pdev))
-			continue;
+	/* If the device is off-line, we cannot reset it */
+	if (pci_channel_offline(pdev))
+		return;
 
-		ret = mlx4_restart_one(priv->dev.persist->pdev);
-		/* 'priv' now is not valid */
-		if (ret)
-			pr_err("mlx4 %s: Reset failed (%d)\n",
-			       pci_name(pdev), ret);
-		else {
-			persist  = pci_get_drvdata(pdev);
-			mlx4_dbg(persist->dev, "Reset succeeded\n");
-		}
-	}
+	ret = mlx4_restart_one(pdev);
+	/* 'priv' now is not valid */
+	if (ret)
+		pr_err("mlx4 %s: Reset failed (%d)\n",
+		       pci_name(pdev), ret);
+	else
+		mlx4_dbg(persist->dev, "Reset succeeded\n");
 }
 
 void mlx4_start_catas_poll(struct mlx4_dev *dev)
@@ -158,15 +140,26 @@ void mlx4_stop_catas_poll(struct mlx4_dev *dev)
 
 	del_timer_sync(&priv->catas_err.timer);
 
-	if (priv->catas_err.map)
+	if (priv->catas_err.map) {
 		iounmap(priv->catas_err.map);
+		priv->catas_err.map = NULL;
+	}
+}
 
-	spin_lock_irq(&catas_lock);
-	list_del(&priv->catas_err.list);
-	spin_unlock_irq(&catas_lock);
+int  mlx4_catas_init(struct mlx4_dev *dev)
+{
+	INIT_WORK(&dev->persist->catas_work, catas_reset);
+	dev->persist->catas_wq = create_singlethread_workqueue("mlx4_health");
+	if (!dev->persist->catas_wq)
+		return -ENOMEM;
+
+	return 0;
 }
 
-void  __init mlx4_catas_init(void)
+void mlx4_catas_end(struct mlx4_dev *dev)
 {
-	INIT_WORK(&catas_work, catas_reset);
+	if (dev->persist->catas_wq) {
+		destroy_workqueue(dev->persist->catas_wq);
+		dev->persist->catas_wq = NULL;
+	}
 }
diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 2c5a555..a61694c 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -3064,11 +3064,19 @@ static int __mlx4_init_one(struct pci_dev *pdev, int pci_dev_data,
 		}
 	}
 
-	err = mlx4_load_one(pdev, pci_dev_data, total_vfs, nvfs, priv);
+	err = mlx4_catas_init(&priv->dev);
 	if (err)
 		goto err_release_regions;
+
+	err = mlx4_load_one(pdev, pci_dev_data, total_vfs, nvfs, priv);
+	if (err)
+		goto err_catas;
+
 	return 0;
 
+err_catas:
+	mlx4_catas_end(&priv->dev);
+
 err_release_regions:
 	pci_release_regions(pdev);
 
@@ -3219,6 +3227,7 @@ static void mlx4_remove_one(struct pci_dev *pdev)
 	struct mlx4_priv *priv = mlx4_priv(dev);
 
 	mlx4_unload_one(pdev);
+	mlx4_catas_end(dev);
 	pci_release_regions(pdev);
 	pci_disable_device(pdev);
 	kfree(dev->persist);
@@ -3403,7 +3412,6 @@ static int __init mlx4_init(void)
 	if (mlx4_verify_params())
 		return -EINVAL;
 
-	mlx4_catas_init();
 
 	mlx4_wq = create_singlethread_workqueue("mlx4");
 	if (!mlx4_wq)
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4.h b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
index faa37ab..d41af84 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
@@ -995,7 +995,8 @@ void __mlx4_xrcd_free(struct mlx4_dev *dev, u32 xrcdn);
 
 void mlx4_start_catas_poll(struct mlx4_dev *dev);
 void mlx4_stop_catas_poll(struct mlx4_dev *dev);
-void mlx4_catas_init(void);
+int mlx4_catas_init(struct mlx4_dev *dev);
+void mlx4_catas_end(struct mlx4_dev *dev);
 int mlx4_restart_one(struct pci_dev *pdev);
 int mlx4_register_device(struct mlx4_dev *dev);
 void mlx4_unregister_device(struct mlx4_dev *dev);
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index 8c3837a..da425d2 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -751,6 +751,8 @@ struct mlx4_dev_persistent {
 	int			num_vfs;
 	enum mlx4_port_type curr_port_type[MLX4_MAX_PORTS + 1];
 	enum mlx4_port_type curr_port_poss_type[MLX4_MAX_PORTS + 1];
+	struct work_struct      catas_work;
+	struct workqueue_struct *catas_wq;
 };
 
 struct mlx4_dev {
-- 
1.7.1
