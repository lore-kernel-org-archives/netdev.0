From: Eli Cohen <eli@dev.mellanox.co.il>
Subject: [PATCH net-next 3/3] mlx5: Adjust events to use unsigned long param instead of void *
Date: Mon, 28 Jul 2014 23:30:24 +0300
Message-ID: <1406579424-16213-4-git-send-email-eli@mellanox.com>
References: <1406579424-16213-1-git-send-email-eli@mellanox.com>
Cc: netdev@vger.kernel.org, roland@kernel.org, ogerlitz@mellanox.com,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Eli Cohen <eli@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f47.google.com ([74.125.82.47]:50503 "EHLO
	mail-wg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751991AbaG1Uaq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jul 2014 16:30:46 -0400
Received: by mail-wg0-f47.google.com with SMTP id b13so7868536wgh.30
        for <netdev@vger.kernel.org>; Mon, 28 Jul 2014 13:30:42 -0700 (PDT)
In-Reply-To: <1406579424-16213-1-git-send-email-eli@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jack Morgenstein <jackm@dev.mellanox.co.il>

In the event flow, we currently pass only a port number in the
void *data argument.  Rather than pass a pointer to the event handlers,
we should use an "unsigned long" parameter, and pass the port number
value directly.

In the future, if necessary for some events, we can use the unsigned long
parameter to pass a pointer.

Based on a patch by Eli Cohen <eli@mellanox.com>

Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Signed-off-by: Eli Cohen <eli@mellanox.com>
---
 drivers/infiniband/hw/mlx5/main.c              | 14 +++++++-------
 drivers/net/ethernet/mellanox/mlx5/core/eq.c   |  3 ++-
 drivers/net/ethernet/mellanox/mlx5/core/main.c |  4 ++--
 include/linux/mlx5/driver.h                    |  4 ++--
 4 files changed, 13 insertions(+), 12 deletions(-)

diff --git a/drivers/infiniband/hw/mlx5/main.c b/drivers/infiniband/hw/mlx5/main.c
index 166335a95c59..d8907b20522a 100644
--- a/drivers/infiniband/hw/mlx5/main.c
+++ b/drivers/infiniband/hw/mlx5/main.c
@@ -905,7 +905,7 @@ static struct device_attribute *mlx5_class_attributes[] = {
 };
 
 static void mlx5_ib_event(struct mlx5_core_dev *dev, void *context,
-			  enum mlx5_dev_event event, void *data)
+			  enum mlx5_dev_event event, unsigned long param)
 {
 	struct mlx5_ib_dev *ibdev = (struct mlx5_ib_dev *)context;
 	struct ib_event ibev;
@@ -920,12 +920,12 @@ static void mlx5_ib_event(struct mlx5_core_dev *dev, void *context,
 
 	case MLX5_DEV_EVENT_PORT_UP:
 		ibev.event = IB_EVENT_PORT_ACTIVE;
-		port = *(u8 *)data;
+		port = (u8)param;
 		break;
 
 	case MLX5_DEV_EVENT_PORT_DOWN:
 		ibev.event = IB_EVENT_PORT_ERR;
-		port = *(u8 *)data;
+		port = (u8)param;
 		break;
 
 	case MLX5_DEV_EVENT_PORT_INITIALIZED:
@@ -934,22 +934,22 @@ static void mlx5_ib_event(struct mlx5_core_dev *dev, void *context,
 
 	case MLX5_DEV_EVENT_LID_CHANGE:
 		ibev.event = IB_EVENT_LID_CHANGE;
-		port = *(u8 *)data;
+		port = (u8)param;
 		break;
 
 	case MLX5_DEV_EVENT_PKEY_CHANGE:
 		ibev.event = IB_EVENT_PKEY_CHANGE;
-		port = *(u8 *)data;
+		port = (u8)param;
 		break;
 
 	case MLX5_DEV_EVENT_GUID_CHANGE:
 		ibev.event = IB_EVENT_GID_CHANGE;
-		port = *(u8 *)data;
+		port = (u8)param;
 		break;
 
 	case MLX5_DEV_EVENT_CLIENT_REREG:
 		ibev.event = IB_EVENT_CLIENT_REREGISTER;
-		port = *(u8 *)data;
+		port = (u8)param;
 		break;
 	}
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eq.c b/drivers/net/ethernet/mellanox/mlx5/core/eq.c
index 67cead2c079e..4e8bd0b34bb0 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eq.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eq.c
@@ -253,7 +253,8 @@ static int mlx5_eq_int(struct mlx5_core_dev *dev, struct mlx5_eq *eq)
 			case MLX5_PORT_CHANGE_SUBTYPE_CLIENT_REREG:
 			case MLX5_PORT_CHANGE_SUBTYPE_INITIALIZED:
 				if (dev->event)
-					dev->event(dev, port_subtype_event(eqe->sub_type), &port);
+					dev->event(dev, port_subtype_event(eqe->sub_type),
+						   (unsigned long)port);
 				break;
 			default:
 				mlx5_core_warn(dev, "Port event with unrecognized subtype: port %d, sub_type %d\n",
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index fd782bf49dc6..f2716cc1f51d 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -704,7 +704,7 @@ void mlx5_unregister_interface(struct mlx5_interface *intf)
 EXPORT_SYMBOL(mlx5_unregister_interface);
 
 static void mlx5_core_event(struct mlx5_core_dev *dev, enum mlx5_dev_event event,
-			    void *data)
+			    unsigned long param)
 {
 	struct mlx5_priv *priv = &dev->priv;
 	struct mlx5_device_context *dev_ctx;
@@ -714,7 +714,7 @@ static void mlx5_core_event(struct mlx5_core_dev *dev, enum mlx5_dev_event event
 
 	list_for_each_entry(dev_ctx, &priv->ctx_list, list)
 		if (dev_ctx->intf->event)
-			dev_ctx->intf->event(dev, dev_ctx->context, event, data);
+			dev_ctx->intf->event(dev, dev_ctx->context, event, param);
 
 	spin_unlock_irqrestore(&priv->ctx_lock, flags);
 }
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index 76de0cc41640..9f3a5476bb71 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -559,7 +559,7 @@ struct mlx5_core_dev {
 	struct mlx5_init_seg __iomem *iseg;
 	void			(*event) (struct mlx5_core_dev *dev,
 					  enum mlx5_dev_event event,
-					  void *data);
+					  unsigned long param);
 	struct mlx5_priv	priv;
 	struct mlx5_profile	*profile;
 	atomic_t		num_qps;
@@ -817,7 +817,7 @@ struct mlx5_interface {
 	void *			(*add)(struct mlx5_core_dev *dev);
 	void			(*remove)(struct mlx5_core_dev *dev, void *context);
 	void			(*event)(struct mlx5_core_dev *dev, void *context,
-					 enum mlx5_dev_event event, void *data);
+					 enum mlx5_dev_event event, unsigned long param);
 	struct list_head	list;
 };
 
-- 
1.9.3
