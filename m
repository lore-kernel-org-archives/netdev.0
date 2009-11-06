From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 15/25 v2] mlx4_core: multi-function interface setup
Date: Fri, 06 Nov 2009 05:09:43 +0200
Message-ID: <4AF39377.3000305@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
	liranl@mellanox.co.il, tziporet@mellanox.co.il,
	yevgenyp@mellanox.co.il
To: rdreier@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:43191 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1759192AbZKFAMH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Nov 2009 19:12:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Liran Liss <liranl@mellanox.co.il>

Master verifies hw healthiness.
Interface drivers are only supported on slaves.

Signed-off-by: Liran Liss <liranl@mellanox.co.il>
Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
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
1.5.3.7

From: Liran Liss <liranl@mellanox.co.il>





