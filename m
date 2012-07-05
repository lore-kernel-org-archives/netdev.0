From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V1 08/10] net/mlx4: Implement promiscuous mode with device managed flow-steering
Date: Thu,  5 Jul 2012 17:03:48 +0300
Message-ID: <1341497030-1818-9-git-send-email-ogerlitz@mellanox.com>
References: <1341497030-1818-1-git-send-email-ogerlitz@mellanox.com>
Cc: roland@kernel.org, yevgenyp@mellanox.com, oren@mellanox.com,
	netdev@vger.kernel.org, amirv@mellanox.com,
	Hadar Hen Zion <hadarh@mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog104.obsmtp.com ([207.126.144.117]:41562 "HELO
	eu1sys200aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756327Ab2GEOEF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jul 2012 10:04:05 -0400
In-Reply-To: <1341497030-1818-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hadar Hen Zion <hadarh@mellanox.co.il>

The device managed flow steering API has three promiscuous modes:

1. Uplink - captures all the packets that arrive to the port.
2. Allmulti - captures all multicast packets arriving to the port.
3. Function port - for future use, this mode is not implemented yet.

Use these modes with the flow_attach and flow_detach firmware commands
according to the promiscuous state of the netdevice.

Signed-off-by: Hadar Hen Zion <hadarh@mellanox.co.il>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |   41 ++++++++++++++++
 drivers/net/ethernet/mellanox/mlx4/mcg.c       |   60 ++++++++++++++++++++++++
 include/linux/mlx4/device.h                    |    7 +++
 3 files changed, 108 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index eb5ed8e..b7945a8 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -301,6 +301,16 @@ static void mlx4_en_do_set_multicast(struct work_struct *work)
 
 			/* Enable promiscouos mode */
 			switch (mdev->dev->caps.steering_mode) {
+			case MLX4_STEERING_MODE_DEVICE_MANAGED:
+				err = mlx4_flow_steer_promisc_add(mdev->dev,
+								  priv->port,
+								  priv->base_qpn,
+								  MLX4_FS_PROMISC_UPLINK);
+				if (err)
+					en_err(priv, "Failed enabling promiscuous mode\n");
+				priv->flags |= MLX4_EN_FLAG_MC_PROMISC;
+				break;
+
 			case MLX4_STEERING_MODE_B0:
 				err = mlx4_unicast_promisc_add(mdev->dev,
 							       priv->base_qpn,
@@ -357,6 +367,15 @@ static void mlx4_en_do_set_multicast(struct work_struct *work)
 
 		/* Disable promiscouos mode */
 		switch (mdev->dev->caps.steering_mode) {
+		case MLX4_STEERING_MODE_DEVICE_MANAGED:
+			err = mlx4_flow_steer_promisc_remove(mdev->dev,
+							     priv->port,
+							     MLX4_FS_PROMISC_UPLINK);
+			if (err)
+				en_err(priv, "Failed disabling promiscuous mode\n");
+			priv->flags &= ~MLX4_EN_FLAG_MC_PROMISC;
+			break;
+
 		case MLX4_STEERING_MODE_B0:
 			err = mlx4_unicast_promisc_remove(mdev->dev,
 							  priv->base_qpn,
@@ -399,6 +418,13 @@ static void mlx4_en_do_set_multicast(struct work_struct *work)
 		/* Add the default qp number as multicast promisc */
 		if (!(priv->flags & MLX4_EN_FLAG_MC_PROMISC)) {
 			switch (mdev->dev->caps.steering_mode) {
+			case MLX4_STEERING_MODE_DEVICE_MANAGED:
+				err = mlx4_flow_steer_promisc_add(mdev->dev,
+								  priv->port,
+								  priv->base_qpn,
+								  MLX4_FS_PROMISC_ALL_MULTI);
+				break;
+
 			case MLX4_STEERING_MODE_B0:
 				err = mlx4_multicast_promisc_add(mdev->dev,
 								 priv->base_qpn,
@@ -416,6 +442,12 @@ static void mlx4_en_do_set_multicast(struct work_struct *work)
 		/* Disable Multicast promisc */
 		if (priv->flags & MLX4_EN_FLAG_MC_PROMISC) {
 			switch (mdev->dev->caps.steering_mode) {
+			case MLX4_STEERING_MODE_DEVICE_MANAGED:
+				err = mlx4_flow_steer_promisc_remove(mdev->dev,
+								     priv->port,
+								     MLX4_FS_PROMISC_ALL_MULTI);
+				break;
+
 			case MLX4_STEERING_MODE_B0:
 				err = mlx4_multicast_promisc_remove(mdev->dev,
 								    priv->base_qpn,
@@ -839,6 +871,15 @@ int mlx4_en_start_port(struct net_device *dev)
 
 	/* Must redo promiscuous mode setup. */
 	priv->flags &= ~(MLX4_EN_FLAG_PROMISC | MLX4_EN_FLAG_MC_PROMISC);
+	if (mdev->dev->caps.steering_mode ==
+	    MLX4_STEERING_MODE_DEVICE_MANAGED) {
+		mlx4_flow_steer_promisc_remove(mdev->dev,
+					       priv->port,
+					       MLX4_FS_PROMISC_UPLINK);
+		mlx4_flow_steer_promisc_remove(mdev->dev,
+					       priv->port,
+					       MLX4_FS_PROMISC_ALL_MULTI);
+	}
 
 	/* Schedule multicast task to populate multicast list */
 	queue_work(mdev->workqueue, &priv->mcast_task);
diff --git a/drivers/net/ethernet/mellanox/mlx4/mcg.c b/drivers/net/ethernet/mellanox/mlx4/mcg.c
index 768a2a4..bc62f53 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mcg.c
+++ b/drivers/net/ethernet/mellanox/mlx4/mcg.c
@@ -1295,6 +1295,66 @@ int mlx4_multicast_detach(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
 }
 EXPORT_SYMBOL_GPL(mlx4_multicast_detach);
 
+int mlx4_flow_steer_promisc_add(struct mlx4_dev *dev, u8 port,
+				u32 qpn, enum mlx4_net_trans_promisc_mode mode)
+{
+	struct mlx4_net_trans_rule rule;
+	u64 *regid_p;
+
+	switch (mode) {
+	case MLX4_FS_PROMISC_UPLINK:
+	case MLX4_FS_PROMISC_FUNCTION_PORT:
+		regid_p = &dev->regid_promisc_array[port];
+		break;
+	case MLX4_FS_PROMISC_ALL_MULTI:
+		regid_p = &dev->regid_allmulti_array[port];
+		break;
+	default:
+		return -1;
+	}
+
+	if (*regid_p != 0)
+		return -1;
+
+	rule.promisc_mode = mode;
+	rule.port = port;
+	rule.qpn = qpn;
+	INIT_LIST_HEAD(&rule.list);
+	mlx4_err(dev, "going promisc on %x\n", port);
+
+	return  mlx4_flow_attach(dev, &rule, regid_p);
+}
+EXPORT_SYMBOL_GPL(mlx4_flow_steer_promisc_add);
+
+int mlx4_flow_steer_promisc_remove(struct mlx4_dev *dev, u8 port,
+				   enum mlx4_net_trans_promisc_mode mode)
+{
+	int ret;
+	u64 *regid_p;
+
+	switch (mode) {
+	case MLX4_FS_PROMISC_UPLINK:
+	case MLX4_FS_PROMISC_FUNCTION_PORT:
+		regid_p = &dev->regid_promisc_array[port];
+		break;
+	case MLX4_FS_PROMISC_ALL_MULTI:
+		regid_p = &dev->regid_allmulti_array[port];
+		break;
+	default:
+		return -1;
+	}
+
+	if (*regid_p == 0)
+		return -1;
+
+	ret =  mlx4_flow_detach(dev, *regid_p);
+	if (ret == 0)
+		*regid_p = 0;
+
+	return ret;
+}
+EXPORT_SYMBOL_GPL(mlx4_flow_steer_promisc_remove);
+
 int mlx4_unicast_attach(struct mlx4_dev *dev,
 			struct mlx4_qp *qp, u8 gid[16],
 			int block_mcast_loopback, enum mlx4_protocol prot)
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index e45fc20..6f0d133 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -542,6 +542,8 @@ struct mlx4_dev {
 	u8			rev_id;
 	char			board_id[MLX4_BOARD_ID_LEN];
 	int			num_vfs;
+	u64			regid_promisc_array[MLX4_MAX_PORTS + 1];
+	u64			regid_allmulti_array[MLX4_MAX_PORTS + 1];
 };
 
 struct mlx4_init_port_param {
@@ -681,6 +683,7 @@ enum mlx4_net_trans_rule_id {
 enum mlx4_net_trans_promisc_mode {
 	MLX4_FS_PROMISC_NONE = 0,
 	MLX4_FS_PROMISC_UPLINK,
+	/* For future use. Not implemented yet */
 	MLX4_FS_PROMISC_FUNCTION_PORT,
 	MLX4_FS_PROMISC_ALL_MULTI,
 };
@@ -744,6 +747,10 @@ struct mlx4_net_trans_rule {
 	u32	qpn;
 };
 
+int mlx4_flow_steer_promisc_add(struct mlx4_dev *dev, u8 port, u32 qpn,
+				enum mlx4_net_trans_promisc_mode mode);
+int mlx4_flow_steer_promisc_remove(struct mlx4_dev *dev, u8 port,
+				   enum mlx4_net_trans_promisc_mode mode);
 int mlx4_multicast_promisc_add(struct mlx4_dev *dev, u32 qpn, u8 port);
 int mlx4_multicast_promisc_remove(struct mlx4_dev *dev, u32 qpn, u8 port);
 int mlx4_unicast_promisc_add(struct mlx4_dev *dev, u32 qpn, u8 port);
-- 
1.7.1
