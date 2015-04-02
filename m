From: Eli Cohen <eli@dev.mellanox.co.il>
Subject: [PATCH net-next 16/16] net/mlx5_core: Extend struct mlx5_interface to support multiple protocols
Date: Thu,  2 Apr 2015 17:07:34 +0300
Message-ID: <1427983654-971-17-git-send-email-eli@mellanox.com>
References: <1427983654-971-1-git-send-email-eli@mellanox.com>
Cc: netdev@vger.kernel.org, idos@mellaox.com, amirv@mellanox.com,
	Saeed Mahameed <saeedm@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Eli Cohen <eli@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:38344 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753552AbbDBOIT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2015 10:08:19 -0400
Received: by wibgn9 with SMTP id gn9so106954427wib.1
        for <netdev@vger.kernel.org>; Thu, 02 Apr 2015 07:08:17 -0700 (PDT)
In-Reply-To: <1427983654-971-1-git-send-email-eli@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>

Preparation for ethernet driver.

Signed-off-by: Achiad Shochat <achiad@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Eli Cohen <eli@mellanox.com>
---
 drivers/infiniband/hw/mlx5/main.c              |  1 +
 drivers/net/ethernet/mellanox/mlx5/core/main.c | 22 ++++++++++++++++++++++
 include/linux/mlx5/driver.h                    |  8 ++++++++
 3 files changed, 31 insertions(+)

diff --git a/drivers/infiniband/hw/mlx5/main.c b/drivers/infiniband/hw/mlx5/main.c
index e59e2a1f8726..57c9809e8b87 100644
--- a/drivers/infiniband/hw/mlx5/main.c
+++ b/drivers/infiniband/hw/mlx5/main.c
@@ -1362,6 +1362,7 @@ static struct mlx5_interface mlx5_ib_interface = {
 	.add            = mlx5_ib_add,
 	.remove         = mlx5_ib_remove,
 	.event          = mlx5_ib_event,
+	.protocol	= MLX5_INTERFACE_PROTOCOL_IB,
 };
 
 static int __init mlx5_ib_init(void)
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index cfc29027f07a..28425e5ea91f 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -908,6 +908,28 @@ void mlx5_unregister_interface(struct mlx5_interface *intf)
 }
 EXPORT_SYMBOL(mlx5_unregister_interface);
 
+void *mlx5_get_protocol_dev(struct mlx5_core_dev *mdev, int protocol)
+{
+	struct mlx5_priv *priv = &mdev->priv;
+	struct mlx5_device_context *dev_ctx;
+	unsigned long flags;
+	void *result = NULL;
+
+	spin_lock_irqsave(&priv->ctx_lock, flags);
+
+	list_for_each_entry(dev_ctx, &mdev->priv.ctx_list, list)
+		if ((dev_ctx->intf->protocol == protocol) &&
+		    dev_ctx->intf->get_dev) {
+			result = dev_ctx->intf->get_dev(dev_ctx->context);
+			break;
+		}
+
+	spin_unlock_irqrestore(&priv->ctx_lock, flags);
+
+	return result;
+}
+EXPORT_SYMBOL(mlx5_get_protocol_dev);
+
 static void mlx5_core_event(struct mlx5_core_dev *dev, enum mlx5_dev_event event,
 			    unsigned long param)
 {
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index f250f6580dad..9a90e7523dc2 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -781,14 +781,22 @@ enum {
 	MAX_MR_CACHE_ENTRIES    = 16,
 };
 
+enum {
+	MLX5_INTERFACE_PROTOCOL_IB  = 0,
+	MLX5_INTERFACE_PROTOCOL_ETH = 1,
+};
+
 struct mlx5_interface {
 	void *			(*add)(struct mlx5_core_dev *dev);
 	void			(*remove)(struct mlx5_core_dev *dev, void *context);
 	void			(*event)(struct mlx5_core_dev *dev, void *context,
 					 enum mlx5_dev_event event, unsigned long param);
+	void *                  (*get_dev)(void *context);
+	int			protocol;
 	struct list_head	list;
 };
 
+void *mlx5_get_protocol_dev(struct mlx5_core_dev *mdev, int protocol);
 int mlx5_register_interface(struct mlx5_interface *intf);
 void mlx5_unregister_interface(struct mlx5_interface *intf);
 
-- 
2.3.1
