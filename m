From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 6/9] net/mlx4_core: Manage interface state for Reset flow cases
Date: Wed, 21 Jan 2015 16:45:54 +0200
Message-ID: <1421851557-12084-7-git-send-email-ogerlitz@mellanox.com>
References: <1421851557-12084-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Matan Barak <matanb@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Roland Dreier <roland@kernel.org>,
	Yishai Hadas <yishaih@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:43096 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753417AbbAUOrQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Jan 2015 09:47:16 -0500
In-Reply-To: <1421851557-12084-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yishai Hadas <yishaih@mellanox.com>

We need to manage interface state to sync between reset flow and some other
relative cases such as remove_one. This has to be done to prevent certain
races. For example in case software stack is down as a result of unload call,
the remove_one should skip the unload phase.

Implement the remove_one case, handling AER and other cases comes next.

The interface can be up/down, upon remove_one, the state will include an extra
bit indicating that the device is cleaned-up, forcing other tasks to finish
before the final cleanup.

Signed-off-by: Yishai Hadas <yishaih@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/catas.c |   13 +++++++++++--
 drivers/net/ethernet/mellanox/mlx4/intf.c  |    2 ++
 drivers/net/ethernet/mellanox/mlx4/main.c  |   13 ++++++++++++-
 include/linux/mlx4/device.h                |    7 +++++++
 4 files changed, 32 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/catas.c b/drivers/net/ethernet/mellanox/mlx4/catas.c
index 63f14ff..3fcf3cf 100644
--- a/drivers/net/ethernet/mellanox/mlx4/catas.c
+++ b/drivers/net/ethernet/mellanox/mlx4/catas.c
@@ -122,8 +122,14 @@ static void mlx4_handle_error_state(struct mlx4_dev_persistent *persist)
 	int err = 0;
 
 	mlx4_enter_error_state(persist);
-	err = mlx4_restart_one(persist->pdev);
-	mlx4_info(persist->dev, "mlx4_restart_one was ended, ret=%d\n", err);
+	mutex_lock(&persist->interface_state_mutex);
+	if (persist->interface_state & MLX4_INTERFACE_STATE_UP &&
+	    !(persist->interface_state & MLX4_INTERFACE_STATE_DELETION)) {
+		err = mlx4_restart_one(persist->pdev);
+		mlx4_info(persist->dev, "mlx4_restart_one was ended, ret=%d\n",
+			  err);
+	}
+	mutex_unlock(&persist->interface_state_mutex);
 }
 
 static void dump_err_buf(struct mlx4_dev *dev)
@@ -211,6 +217,9 @@ void mlx4_stop_catas_poll(struct mlx4_dev *dev)
 		iounmap(priv->catas_err.map);
 		priv->catas_err.map = NULL;
 	}
+
+	if (dev->persist->interface_state & MLX4_INTERFACE_STATE_DELETION)
+		flush_workqueue(dev->persist->catas_wq);
 }
 
 int  mlx4_catas_init(struct mlx4_dev *dev)
diff --git a/drivers/net/ethernet/mellanox/mlx4/intf.c b/drivers/net/ethernet/mellanox/mlx4/intf.c
index 116895a..fba0b96 100644
--- a/drivers/net/ethernet/mellanox/mlx4/intf.c
+++ b/drivers/net/ethernet/mellanox/mlx4/intf.c
@@ -138,6 +138,7 @@ int mlx4_register_device(struct mlx4_dev *dev)
 
 	mutex_lock(&intf_mutex);
 
+	dev->persist->interface_state |= MLX4_INTERFACE_STATE_UP;
 	list_add_tail(&priv->dev_list, &dev_list);
 	list_for_each_entry(intf, &intf_list, list)
 		mlx4_add_device(intf, priv);
@@ -162,6 +163,7 @@ void mlx4_unregister_device(struct mlx4_dev *dev)
 		mlx4_remove_device(intf, priv);
 
 	list_del(&priv->dev_list);
+	dev->persist->interface_state &= ~MLX4_INTERFACE_STATE_UP;
 
 	mutex_unlock(&intf_mutex);
 }
diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index dc2d910..d59cae5 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -3114,6 +3114,7 @@ static int mlx4_init_one(struct pci_dev *pdev, const struct pci_device_id *id)
 	pci_set_drvdata(pdev, dev->persist);
 	priv->pci_dev_data = id->driver_data;
 	mutex_init(&dev->persist->device_state_mutex);
+	mutex_init(&dev->persist->interface_state_mutex);
 
 	ret =  __mlx4_init_one(pdev, id->driver_data, priv);
 	if (ret) {
@@ -3232,7 +3233,17 @@ static void mlx4_remove_one(struct pci_dev *pdev)
 	struct mlx4_dev  *dev  = persist->dev;
 	struct mlx4_priv *priv = mlx4_priv(dev);
 
-	mlx4_unload_one(pdev);
+	mutex_lock(&persist->interface_state_mutex);
+	persist->interface_state |= MLX4_INTERFACE_STATE_DELETION;
+	mutex_unlock(&persist->interface_state_mutex);
+
+	/* device marked to be under deletion running now without the lock
+	 * letting other tasks to be terminated
+	 */
+	if (persist->interface_state & MLX4_INTERFACE_STATE_UP)
+		mlx4_unload_one(pdev);
+	else
+		mlx4_info(dev, "%s: interface is down\n", __func__);
 	mlx4_catas_end(dev);
 	pci_release_regions(pdev);
 	pci_disable_device(pdev);
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index 7d5d317..33f9ca7 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -416,6 +416,11 @@ enum {
 	MLX4_DEVICE_STATE_INTERNAL_ERROR	= 1 << 1,
 };
 
+enum {
+	MLX4_INTERFACE_STATE_UP		= 1 << 0,
+	MLX4_INTERFACE_STATE_DELETION	= 1 << 1,
+};
+
 #define MSTR_SM_CHANGE_MASK (MLX4_EQ_PORT_INFO_MSTR_SM_SL_CHANGE_MASK | \
 			     MLX4_EQ_PORT_INFO_MSTR_SM_LID_CHANGE_MASK)
 
@@ -760,6 +765,8 @@ struct mlx4_dev_persistent {
 	struct workqueue_struct *catas_wq;
 	struct mutex	device_state_mutex; /* protect HW state */
 	u8		state;
+	struct mutex	interface_state_mutex; /* protect SW state */
+	u8	interface_state;
 };
 
 struct mlx4_dev {
-- 
1.7.1
