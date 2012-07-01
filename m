From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 04/10] net/mlx4: Set steering mode according to device capabilities
Date: Sun,  1 Jul 2012 12:43:37 +0300
Message-ID: <1341135823-29039-5-git-send-email-ogerlitz@mellanox.com>
References: <1341135823-29039-1-git-send-email-ogerlitz@mellanox.com>
Cc: roland@kernel.org, yevgenyp@mellanox.com, oren@mellanox.com,
	netdev@vger.kernel.org, Hadar Hen Zion <hadarh@mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog104.obsmtp.com ([207.126.144.117]:36314 "HELO
	eu1sys200aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754770Ab2GAJn6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jul 2012 05:43:58 -0400
In-Reply-To: <1341135823-29039-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hadar Hen Zion <hadarh@mellanox.co.il>

Instead of checking the firmware supported steering mode in various
places in the code, add a dedicated field in the mlx4 device capabilities
structure which is written once during the initialization flow and read
across the code.

This also set the grounds for add new steering modes. Currently two modes
are supported, and are named after the ConnectX HW versions A0 and B0.

A0 steering uses mac_index, vlan_index and priority to steer traffic
into pre-defined range of QPs.

B0 steering uses Ethernet L2 hashing rules and is enabled only
if the firmware supports both unicast and multicast B0 steering,

The current steering modes are relevant for Ethernet traffic only,
such that Infiniband steering remains untouched.

Signed-off-by: Hadar Hen Zion <hadarh@mellanox.co.il>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |  107 ++++++++++++++++--------
 drivers/net/ethernet/mellanox/mlx4/fw.c        |    2 +-
 drivers/net/ethernet/mellanox/mlx4/main.c      |   17 ++++-
 drivers/net/ethernet/mellanox/mlx4/mcg.c       |   70 +++++++---------
 drivers/net/ethernet/mellanox/mlx4/port.c      |    9 +-
 include/linux/mlx4/device.h                    |   24 +++++
 6 files changed, 148 insertions(+), 81 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 35c64f2..f9a4a00 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -263,7 +263,7 @@ static void mlx4_en_do_set_multicast(struct work_struct *work)
 	struct mlx4_en_mc_list *mclist, *tmp;
 	u64 mcast_addr = 0;
 	u8 mc_list[16] = {0};
-	int err;
+	int err = 0;
 
 	mutex_lock(&mdev->state_lock);
 	if (!mdev->device_up) {
@@ -298,16 +298,35 @@ static void mlx4_en_do_set_multicast(struct work_struct *work)
 			priv->flags |= MLX4_EN_FLAG_PROMISC;
 
 			/* Enable promiscouos mode */
-			if (!(mdev->dev->caps.flags &
-						MLX4_DEV_CAP_FLAG_VEP_UC_STEER))
-				err = mlx4_SET_PORT_qpn_calc(mdev->dev, priv->port,
-							     priv->base_qpn, 1);
-			else
-				err = mlx4_unicast_promisc_add(mdev->dev, priv->base_qpn,
+			switch (mdev->dev->caps.steering_mode) {
+			case MLX4_STEERING_MODE_B0:
+				err = mlx4_unicast_promisc_add(mdev->dev,
+							       priv->base_qpn,
 							       priv->port);
-			if (err)
-				en_err(priv, "Failed enabling "
-					     "promiscuous mode\n");
+				if (err)
+					en_err(priv, "Failed enabling unicast promiscuous mode\n");
+
+				/* Add the default qp number as multicast
+				* promisc */
+				if (!(priv->flags & MLX4_EN_FLAG_MC_PROMISC)) {
+					err = mlx4_multicast_promisc_add(mdev->dev,
+									 priv->base_qpn,
+									 priv->port);
+					if (err)
+						en_err(priv, "Failed enabling multicast promiscuous mode\n");
+					priv->flags |= MLX4_EN_FLAG_MC_PROMISC;
+				}
+				break;
+
+			case MLX4_STEERING_MODE_A0:
+				err = mlx4_SET_PORT_qpn_calc(mdev->dev,
+							     priv->port,
+							     priv->base_qpn,
+							     1);
+				if (err)
+					en_err(priv, "Failed enabling promiscuous mode\n");
+				break;
+			}
 
 			/* Disable port multicast filter (unconditionally) */
 			err = mlx4_SET_MCAST_FLTR(mdev->dev, priv->port, 0,
@@ -316,15 +335,6 @@ static void mlx4_en_do_set_multicast(struct work_struct *work)
 				en_err(priv, "Failed disabling "
 					     "multicast filter\n");
 
-			/* Add the default qp number as multicast promisc */
-			if (!(priv->flags & MLX4_EN_FLAG_MC_PROMISC)) {
-				err = mlx4_multicast_promisc_add(mdev->dev, priv->base_qpn,
-								 priv->port);
-				if (err)
-					en_err(priv, "Failed entering multicast promisc mode\n");
-				priv->flags |= MLX4_EN_FLAG_MC_PROMISC;
-			}
-
 			/* Disable port VLAN filter */
 			err = mlx4_SET_VLAN_FLTR(mdev->dev, priv);
 			if (err)
@@ -343,22 +353,31 @@ static void mlx4_en_do_set_multicast(struct work_struct *work)
 		priv->flags &= ~MLX4_EN_FLAG_PROMISC;
 
 		/* Disable promiscouos mode */
-		if (!(mdev->dev->caps.flags & MLX4_DEV_CAP_FLAG_VEP_UC_STEER))
-			err = mlx4_SET_PORT_qpn_calc(mdev->dev, priv->port,
-						     priv->base_qpn, 0);
-		else
-			err = mlx4_unicast_promisc_remove(mdev->dev, priv->base_qpn,
+		switch (mdev->dev->caps.steering_mode) {
+		case MLX4_STEERING_MODE_B0:
+			err = mlx4_unicast_promisc_remove(mdev->dev,
+							  priv->base_qpn,
 							  priv->port);
-		if (err)
-			en_err(priv, "Failed disabling promiscuous mode\n");
+			if (err)
+				en_err(priv, "Failed disabling unicast promiscuous mode\n");
+			/* Disable Multicast promisc */
+			if (priv->flags & MLX4_EN_FLAG_MC_PROMISC) {
+				err = mlx4_multicast_promisc_remove(mdev->dev,
+								    priv->base_qpn,
+								    priv->port);
+				if (err)
+					en_err(priv, "Failed disabling multicast promiscuous mode\n");
+				priv->flags &= ~MLX4_EN_FLAG_MC_PROMISC;
+			}
+			break;
 
-		/* Disable Multicast promisc */
-		if (priv->flags & MLX4_EN_FLAG_MC_PROMISC) {
-			err = mlx4_multicast_promisc_remove(mdev->dev, priv->base_qpn,
-							    priv->port);
+		case MLX4_STEERING_MODE_A0:
+			err = mlx4_SET_PORT_qpn_calc(mdev->dev,
+						     priv->port,
+						     priv->base_qpn, 0);
 			if (err)
-				en_err(priv, "Failed disabling multicast promiscuous mode\n");
-			priv->flags &= ~MLX4_EN_FLAG_MC_PROMISC;
+				en_err(priv, "Failed disabling promiscuous mode\n");
+			break;
 		}
 
 		/* Enable port VLAN filter */
@@ -376,8 +395,16 @@ static void mlx4_en_do_set_multicast(struct work_struct *work)
 
 		/* Add the default qp number as multicast promisc */
 		if (!(priv->flags & MLX4_EN_FLAG_MC_PROMISC)) {
-			err = mlx4_multicast_promisc_add(mdev->dev, priv->base_qpn,
-							 priv->port);
+			switch (mdev->dev->caps.steering_mode) {
+			case MLX4_STEERING_MODE_B0:
+				err = mlx4_multicast_promisc_add(mdev->dev,
+								 priv->base_qpn,
+								 priv->port);
+				break;
+
+			case MLX4_STEERING_MODE_A0:
+				break;
+			}
 			if (err)
 				en_err(priv, "Failed entering multicast promisc mode\n");
 			priv->flags |= MLX4_EN_FLAG_MC_PROMISC;
@@ -385,8 +412,16 @@ static void mlx4_en_do_set_multicast(struct work_struct *work)
 	} else {
 		/* Disable Multicast promisc */
 		if (priv->flags & MLX4_EN_FLAG_MC_PROMISC) {
-			err = mlx4_multicast_promisc_remove(mdev->dev, priv->base_qpn,
-							    priv->port);
+			switch (mdev->dev->caps.steering_mode) {
+			case MLX4_STEERING_MODE_B0:
+				err = mlx4_multicast_promisc_remove(mdev->dev,
+								    priv->base_qpn,
+								    priv->port);
+				break;
+
+			case MLX4_STEERING_MODE_A0:
+				break;
+			}
 			if (err)
 				en_err(priv, "Failed disabling multicast promiscuous mode\n");
 			priv->flags &= ~MLX4_EN_FLAG_MC_PROMISC;
diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index 9c83bb8..40e048b 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -1124,7 +1124,7 @@ int mlx4_INIT_HCA(struct mlx4_dev *dev, struct mlx4_init_hca_param *param)
 	MLX4_PUT(inbox, param->mc_base,		INIT_HCA_MC_BASE_OFFSET);
 	MLX4_PUT(inbox, param->log_mc_entry_sz, INIT_HCA_LOG_MC_ENTRY_SZ_OFFSET);
 	MLX4_PUT(inbox, param->log_mc_hash_sz,  INIT_HCA_LOG_MC_HASH_SZ_OFFSET);
-	if (dev->caps.flags & MLX4_DEV_CAP_FLAG_VEP_MC_STEER)
+	if (dev->caps.steering_mode == MLX4_STEERING_MODE_B0)
 		MLX4_PUT(inbox, (u8) (1 << 3),	INIT_HCA_UC_STEERING_OFFSET);
 	MLX4_PUT(inbox, param->log_mc_table_sz, INIT_HCA_LOG_MC_TABLE_SZ_OFFSET);
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index a0313de..7df0517 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -243,7 +243,6 @@ static int mlx4_dev_cap(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 	dev->caps.reserved_srqs	     = dev_cap->reserved_srqs;
 	dev->caps.max_sq_desc_sz     = dev_cap->max_sq_desc_sz;
 	dev->caps.max_rq_desc_sz     = dev_cap->max_rq_desc_sz;
-	dev->caps.num_qp_per_mgm     = mlx4_get_qp_per_mgm(dev);
 	/*
 	 * Subtract 1 from the limit because we need to allocate a
 	 * spare CQE so the HCA HW can tell the difference between an
@@ -274,6 +273,22 @@ static int mlx4_dev_cap(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 	dev->caps.max_gso_sz	     = dev_cap->max_gso_sz;
 	dev->caps.max_rss_tbl_sz     = dev_cap->max_rss_tbl_sz;
 
+	if (dev->caps.flags & MLX4_DEV_CAP_FLAG_VEP_UC_STEER &&
+	    dev->caps.flags & MLX4_DEV_CAP_FLAG_VEP_MC_STEER) {
+		dev->caps.steering_mode = MLX4_STEERING_MODE_B0;
+
+	} else {
+		dev->caps.steering_mode = MLX4_STEERING_MODE_A0;
+
+		if (dev->caps.flags & MLX4_DEV_CAP_FLAG_VEP_UC_STEER ||
+		    dev->caps.flags & MLX4_DEV_CAP_FLAG_VEP_MC_STEER)
+			mlx4_warn(dev, "Must have UC_STEER and MC_STEER flags "
+				       "set to use B0 steering. Falling back to A0 steering mode.\n");
+	}
+	mlx4_dbg(dev, "Steering mode is: %s\n",
+		 mlx4_steering_mode_str(dev->caps.steering_mode));
+	dev->caps.num_qp_per_mgm = mlx4_get_qp_per_mgm(dev);
+
 	/* Sense port always allowed on supported devices for ConnectX1 and 2 */
 	if (dev->pdev->device != 0x1003)
 		dev->caps.flags |= MLX4_DEV_CAP_FLAG_SENSE_SUPPORT;
diff --git a/drivers/net/ethernet/mellanox/mlx4/mcg.c b/drivers/net/ethernet/mellanox/mlx4/mcg.c
index f4a8f98..319c9d4 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mcg.c
+++ b/drivers/net/ethernet/mellanox/mlx4/mcg.c
@@ -868,36 +868,50 @@ static int mlx4_QP_ATTACH(struct mlx4_dev *dev, struct mlx4_qp *qp,
 int mlx4_multicast_attach(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
 			  int block_mcast_loopback, enum mlx4_protocol prot)
 {
-	if (prot == MLX4_PROT_ETH &&
-			!(dev->caps.flags & MLX4_DEV_CAP_FLAG_VEP_MC_STEER))
-		return 0;
 
-	if (prot == MLX4_PROT_ETH)
-		gid[7] |= (MLX4_MC_STEER << 1);
+	switch (dev->caps.steering_mode) {
+	case MLX4_STEERING_MODE_A0:
+		if (prot == MLX4_PROT_ETH)
+			return 0;
 
-	if (mlx4_is_mfunc(dev))
-		return mlx4_QP_ATTACH(dev, qp, gid, 1,
-					block_mcast_loopback, prot);
+	case MLX4_STEERING_MODE_B0:
+		if (prot == MLX4_PROT_ETH)
+			gid[7] |= (MLX4_MC_STEER << 1);
 
-	return mlx4_qp_attach_common(dev, qp, gid, block_mcast_loopback,
-					prot, MLX4_MC_STEER);
+		if (mlx4_is_mfunc(dev))
+			return mlx4_QP_ATTACH(dev, qp, gid, 1,
+					      block_mcast_loopback, prot);
+		return mlx4_qp_attach_common(dev, qp, gid,
+					     block_mcast_loopback, prot,
+					     MLX4_MC_STEER);
+
+	default:
+		return -EINVAL;
+	}
 }
 EXPORT_SYMBOL_GPL(mlx4_multicast_attach);
 
 int mlx4_multicast_detach(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
 			  enum mlx4_protocol prot)
 {
-	if (prot == MLX4_PROT_ETH &&
-			!(dev->caps.flags & MLX4_DEV_CAP_FLAG_VEP_MC_STEER))
-		return 0;
+	switch (dev->caps.steering_mode) {
+	case MLX4_STEERING_MODE_A0:
+		if (prot == MLX4_PROT_ETH)
+			return 0;
 
-	if (prot == MLX4_PROT_ETH)
-		gid[7] |= (MLX4_MC_STEER << 1);
+	case MLX4_STEERING_MODE_B0:
+		if (prot == MLX4_PROT_ETH)
+			gid[7] |= (MLX4_MC_STEER << 1);
 
-	if (mlx4_is_mfunc(dev))
-		return mlx4_QP_ATTACH(dev, qp, gid, 0, 0, prot);
+		if (mlx4_is_mfunc(dev))
+			return mlx4_QP_ATTACH(dev, qp, gid, 0, 0, prot);
+
+		return mlx4_qp_detach_common(dev, qp, gid, prot,
+					     MLX4_MC_STEER);
 
-	return mlx4_qp_detach_common(dev, qp, gid, prot, MLX4_MC_STEER);
+	default:
+		return -EINVAL;
+	}
 }
 EXPORT_SYMBOL_GPL(mlx4_multicast_detach);
 
@@ -905,10 +919,6 @@ int mlx4_unicast_attach(struct mlx4_dev *dev,
 			struct mlx4_qp *qp, u8 gid[16],
 			int block_mcast_loopback, enum mlx4_protocol prot)
 {
-	if (prot == MLX4_PROT_ETH &&
-			!(dev->caps.flags & MLX4_DEV_CAP_FLAG_VEP_UC_STEER))
-		return 0;
-
 	if (prot == MLX4_PROT_ETH)
 		gid[7] |= (MLX4_UC_STEER << 1);
 
@@ -924,10 +934,6 @@ EXPORT_SYMBOL_GPL(mlx4_unicast_attach);
 int mlx4_unicast_detach(struct mlx4_dev *dev, struct mlx4_qp *qp,
 			       u8 gid[16], enum mlx4_protocol prot)
 {
-	if (prot == MLX4_PROT_ETH &&
-			!(dev->caps.flags & MLX4_DEV_CAP_FLAG_VEP_UC_STEER))
-		return 0;
-
 	if (prot == MLX4_PROT_ETH)
 		gid[7] |= (MLX4_UC_STEER << 1);
 
@@ -968,9 +974,6 @@ static int mlx4_PROMISC(struct mlx4_dev *dev, u32 qpn,
 
 int mlx4_multicast_promisc_add(struct mlx4_dev *dev, u32 qpn, u8 port)
 {
-	if (!(dev->caps.flags & MLX4_DEV_CAP_FLAG_VEP_MC_STEER))
-		return 0;
-
 	if (mlx4_is_mfunc(dev))
 		return mlx4_PROMISC(dev, qpn, MLX4_MC_STEER, 1, port);
 
@@ -980,9 +983,6 @@ EXPORT_SYMBOL_GPL(mlx4_multicast_promisc_add);
 
 int mlx4_multicast_promisc_remove(struct mlx4_dev *dev, u32 qpn, u8 port)
 {
-	if (!(dev->caps.flags & MLX4_DEV_CAP_FLAG_VEP_MC_STEER))
-		return 0;
-
 	if (mlx4_is_mfunc(dev))
 		return mlx4_PROMISC(dev, qpn, MLX4_MC_STEER, 0, port);
 
@@ -992,9 +992,6 @@ EXPORT_SYMBOL_GPL(mlx4_multicast_promisc_remove);
 
 int mlx4_unicast_promisc_add(struct mlx4_dev *dev, u32 qpn, u8 port)
 {
-	if (!(dev->caps.flags & MLX4_DEV_CAP_FLAG_VEP_UC_STEER))
-		return 0;
-
 	if (mlx4_is_mfunc(dev))
 		return mlx4_PROMISC(dev, qpn, MLX4_UC_STEER, 1, port);
 
@@ -1004,9 +1001,6 @@ EXPORT_SYMBOL_GPL(mlx4_unicast_promisc_add);
 
 int mlx4_unicast_promisc_remove(struct mlx4_dev *dev, u32 qpn, u8 port)
 {
-	if (!(dev->caps.flags & MLX4_DEV_CAP_FLAG_VEP_UC_STEER))
-		return 0;
-
 	if (mlx4_is_mfunc(dev))
 		return mlx4_PROMISC(dev, qpn, MLX4_UC_STEER, 0, port);
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/port.c b/drivers/net/ethernet/mellanox/mlx4/port.c
index a8fb529..58de723 100644
--- a/drivers/net/ethernet/mellanox/mlx4/port.c
+++ b/drivers/net/ethernet/mellanox/mlx4/port.c
@@ -155,7 +155,7 @@ int mlx4_get_eth_qp(struct mlx4_dev *dev, u8 port, u64 mac, int *qpn)
 		return err;
 	}
 
-	if (!(dev->caps.flags & MLX4_DEV_CAP_FLAG_VEP_UC_STEER)) {
+	if (dev->caps.steering_mode == MLX4_STEERING_MODE_A0) {
 		*qpn = info->base_qpn + index;
 		return 0;
 	}
@@ -206,7 +206,7 @@ void mlx4_put_eth_qp(struct mlx4_dev *dev, u8 port, u64 mac, int qpn)
 		 (unsigned long long) mac);
 	mlx4_unregister_mac(dev, port, mac);
 
-	if (dev->caps.flags & MLX4_DEV_CAP_FLAG_VEP_UC_STEER) {
+	if (dev->caps.steering_mode != MLX4_STEERING_MODE_A0) {
 		entry = radix_tree_lookup(&info->mac_tree, qpn);
 		if (entry) {
 			mlx4_dbg(dev, "Releasing qp: port %d, mac 0x%llx,"
@@ -359,7 +359,7 @@ int mlx4_replace_mac(struct mlx4_dev *dev, u8 port, int qpn, u64 new_mac)
 	int index = qpn - info->base_qpn;
 	int err = 0;
 
-	if (dev->caps.flags & MLX4_DEV_CAP_FLAG_VEP_UC_STEER) {
+	if (dev->caps.steering_mode != MLX4_STEERING_MODE_A0) {
 		entry = radix_tree_lookup(&info->mac_tree, qpn);
 		if (!entry)
 			return -EINVAL;
@@ -803,8 +803,7 @@ int mlx4_SET_PORT_qpn_calc(struct mlx4_dev *dev, u8 port, u32 base_qpn,
 	u32 m_promisc = (dev->caps.flags & MLX4_DEV_CAP_FLAG_VEP_MC_STEER) ?
 		MCAST_DIRECT : MCAST_DEFAULT;
 
-	if (dev->caps.flags & MLX4_DEV_CAP_FLAG_VEP_MC_STEER  &&
-	    dev->caps.flags & MLX4_DEV_CAP_FLAG_VEP_UC_STEER)
+	if (dev->caps.steering_mode != MLX4_STEERING_MODE_A0)
 		return 0;
 
 	mailbox = mlx4_alloc_cmd_mailbox(dev);
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index 6a8f002..80891a4 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -70,6 +70,29 @@ enum {
 	MLX4_MFUNC_EQE_MASK     = (MLX4_MFUNC_MAX_EQES - 1)
 };
 
+/* Driver supports 2 diffrent device methods to manage traffic steering:
+	- B0 steering mode - Common low level API for ib and (if supported) eth.
+	- A0 steering mode - Limited low level API for eth. In case of IB,
+			     B0 mode is in use.
+ */
+enum {
+	MLX4_STEERING_MODE_A0,
+	MLX4_STEERING_MODE_B0
+};
+
+static inline const char *mlx4_steering_mode_str(int steering_mode)
+{
+	switch (steering_mode) {
+	case MLX4_STEERING_MODE_A0:
+		return "A0 steering";
+
+	case MLX4_STEERING_MODE_B0:
+		return "B0 steering";
+	default:
+		return "Unrecognize steering mode";
+	}
+}
+
 enum {
 	MLX4_DEV_CAP_FLAG_RC		= 1LL <<  0,
 	MLX4_DEV_CAP_FLAG_UC		= 1LL <<  1,
@@ -295,6 +318,7 @@ struct mlx4_caps {
 	int			num_amgms;
 	int			reserved_mcgs;
 	int			num_qp_per_mgm;
+	int			steering_mode;
 	int			num_pds;
 	int			reserved_pds;
 	int			max_xrcds;
-- 
1.7.1
