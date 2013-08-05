From: Eli Cohen <eli@dev.mellanox.co.il>
Subject: [PATCH] mlx5: remove health handler plugin
Date: Mon, 5 Aug 2013 16:05:32 +0300
Message-ID: <20130805130532.GA26634@mtldesk30>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dborkman@redhat.com, netdev@vger.kernel.org, ogerlitz@mellanox.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:39116 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753001Ab3HENFg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Aug 2013 09:05:36 -0400
Received: by mail-wi0-f174.google.com with SMTP id j17so1432635wiw.7
        for <netdev@vger.kernel.org>; Mon, 05 Aug 2013 06:05:35 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove this code, per Dave Miller's request, since it is not being used
anywhere in the kernel.

Signed-off-by: Eli Cohen <eli@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/health.c | 29 +-----------------------
 include/linux/mlx5/driver.h                      |  3 ---
 2 files changed, 1 insertion(+), 31 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/health.c b/drivers/net/ethernet/mellanox/mlx5/core/health.c
index 748f10a..3e6670c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/health.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/health.c
@@ -55,33 +55,9 @@ enum {
 };
 
 static DEFINE_SPINLOCK(health_lock);
-
 static LIST_HEAD(health_list);
 static struct work_struct health_work;
 
-static health_handler_t reg_handler;
-int mlx5_register_health_report_handler(health_handler_t handler)
-{
-	spin_lock_irq(&health_lock);
-	if (reg_handler) {
-		spin_unlock_irq(&health_lock);
-		return -EEXIST;
-	}
-	reg_handler = handler;
-	spin_unlock_irq(&health_lock);
-
-	return 0;
-}
-EXPORT_SYMBOL(mlx5_register_health_report_handler);
-
-void mlx5_unregister_health_report_handler(void)
-{
-	spin_lock_irq(&health_lock);
-	reg_handler = NULL;
-	spin_unlock_irq(&health_lock);
-}
-EXPORT_SYMBOL(mlx5_unregister_health_report_handler);
-
 static void health_care(struct work_struct *work)
 {
 	struct mlx5_core_health *health, *n;
@@ -98,11 +74,8 @@ static void health_care(struct work_struct *work)
 		priv = container_of(health, struct mlx5_priv, health);
 		dev = container_of(priv, struct mlx5_core_dev, priv);
 		mlx5_core_warn(dev, "handling bad device here\n");
+		/* nothing yet */
 		spin_lock_irq(&health_lock);
-		if (reg_handler)
-			reg_handler(dev->pdev, health->health,
-				    sizeof(health->health));
-
 		list_del_init(&health->list);
 		spin_unlock_irq(&health_lock);
 	}
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index 2aa258b..611e65e 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -731,9 +731,6 @@ void mlx5_cq_debugfs_cleanup(struct mlx5_core_dev *dev);
 int mlx5_db_alloc(struct mlx5_core_dev *dev, struct mlx5_db *db);
 void mlx5_db_free(struct mlx5_core_dev *dev, struct mlx5_db *db);
 
-typedef void (*health_handler_t)(struct pci_dev *pdev, struct health_buffer __iomem *buf, int size);
-int mlx5_register_health_report_handler(health_handler_t handler);
-void mlx5_unregister_health_report_handler(void);
 const char *mlx5_command_str(int command);
 int mlx5_cmdif_debugfs_init(struct mlx5_core_dev *dev);
 void mlx5_cmdif_debugfs_cleanup(struct mlx5_core_dev *dev);
-- 
1.8.1.3
