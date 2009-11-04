From: Yevgeny Petrilin <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
Subject: [PATCH 15/25] mlx4_core: multi-function interface setup
Date: Wed, 04 Nov 2009 17:31:36 +0200
Message-ID: <4AF19E58.8000804@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	liranl-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org, tziporet-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org,
	yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org
To: rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Master verifies hw healthiness.
Interface drivers are only supported on slaves.

Signed-off-by: Liran Liss <liranl-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
---
 drivers/net/mlx4/intf.c |   21 ++++++++++++++-------
 1 files changed, 14 insertions(+), 7 deletions(-)

diff --git a/drivers/net/mlx4/intf.c b/drivers/net/mlx4/intf.c
index 0e7eb10..f5f4523 100644
--- a/drivers/net/mlx4/intf.c
+++ b/drivers/net/mlx4/intf.c
@@ -88,8 +88,11 @@ int mlx4_register_interface(struct mlx4_interface *intf)
 	mutex_lock(&intf_mutex);
 
 	list_add_tail(&intf->list, &intf_list);
-	list_for_each_entry(priv, &dev_list, dev_list)
-		mlx4_add_device(intf, priv);
+	list_for_each_entry(priv, &dev_list, dev_list) {
+		/* CX1: master cannot run interfaces */
+		if (!mlx4_is_master(&priv->dev))
+			mlx4_add_device(intf, priv);
+	}
 
 	mutex_unlock(&intf_mutex);
 
@@ -135,11 +138,14 @@ int mlx4_register_device(struct mlx4_dev *dev)
 	mutex_lock(&intf_mutex);
 
 	list_add_tail(&priv->dev_list, &dev_list);
-	list_for_each_entry(intf, &intf_list, list)
-		mlx4_add_device(intf, priv);
-
+	/* CX1: master cannot run interfaces */
+	if (!mlx4_is_master(dev)) {
+		list_for_each_entry(intf, &intf_list, list)
+			mlx4_add_device(intf, priv);
+	}
 	mutex_unlock(&intf_mutex);
-	mlx4_start_catas_poll(dev);
+	if (!mlx4_is_slave(dev))
+		mlx4_start_catas_poll(dev);
 
 	return 0;
 }
@@ -149,7 +155,8 @@ void mlx4_unregister_device(struct mlx4_dev *dev)
 	struct mlx4_priv *priv = mlx4_priv(dev);
 	struct mlx4_interface *intf;
 
-	mlx4_stop_catas_poll(dev);
+	if (!mlx4_is_slave(dev))
+		mlx4_stop_catas_poll(dev);
 	mutex_lock(&intf_mutex);
 
 	list_for_each_entry(intf, &intf_list, list)
-- 
1.6.1.3




--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
