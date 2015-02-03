From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 05/10] net/mlx4_core: Port aggregation upper layer interface
Date: Tue,  3 Feb 2015 16:48:33 +0200
Message-ID: <1422974919-28084-6-git-send-email-ogerlitz@mellanox.com>
References: <1422974919-28084-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Roland Dreier <roland@kernel.org>,
	Amir Vadai <amirv@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Moni Shoua <monis@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:60095 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S965526AbbBCOuK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Feb 2015 09:50:10 -0500
In-Reply-To: <1422974919-28084-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Moni Shoua <monis@mellanox.com>

Supply interface functions to bond and unbond ports of a mlx4 internal
interfaces. Example for such an interface is the one registered by the
mlx4 IB driver under RoCE.

There are

1. Functions to go in/out to/from bonded mode
2. Function to remap virtual ports to physical ports

The bond_mutex prevents simultaneous access to data that keep status of
the device in bonded mode.

The upper mlx4 interface marks to the mlx4 core module that they
want to be subject for such bonding by setting the MLX4_INTFF_BONDING
flag. Interface which goes to/from bonded mode is re-created.

The mlx4 Ethernet driver does not set this flag when registering the
interface, the IB driver does.

Signed-off-by: Moni Shoua <monis@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_resources.c  |    8 ++-
 drivers/net/ethernet/mellanox/mlx4/intf.c          |   54 ++++++++++++
 drivers/net/ethernet/mellanox/mlx4/main.c          |   89 ++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx4/mlx4.h          |    3 +
 drivers/net/ethernet/mellanox/mlx4/qp.c            |    2 +
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |    3 +
 include/linux/mlx4/device.h                        |    1 +
 include/linux/mlx4/driver.h                        |   19 ++++
 8 files changed, 177 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_resources.c b/drivers/net/ethernet/mellanox/mlx4/en_resources.c
index f1a5500..34f2fdf 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_resources.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_resources.c
@@ -50,10 +50,14 @@ void mlx4_en_fill_qp_context(struct mlx4_en_priv *priv, int size, int stride,
 	context->mtu_msgmax = 0xff;
 	if (!is_tx && !rss)
 		context->rq_size_stride = ilog2(size) << 3 | (ilog2(stride) - 4);
-	if (is_tx)
+	if (is_tx) {
 		context->sq_size_stride = ilog2(size) << 3 | (ilog2(stride) - 4);
-	else
+		if (mdev->dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_PORT_REMAP)
+			context->params2 |= MLX4_QP_BIT_FPP;
+
+	} else {
 		context->sq_size_stride = ilog2(TXBB_SIZE) - 4;
+	}
 	context->usr_page = cpu_to_be32(mdev->priv_uar.index);
 	context->local_qpn = cpu_to_be32(qpn);
 	context->pri_path.ackto = 1 & 0x07;
diff --git a/drivers/net/ethernet/mellanox/mlx4/intf.c b/drivers/net/ethernet/mellanox/mlx4/intf.c
index 68d2bad..6fce587 100644
--- a/drivers/net/ethernet/mellanox/mlx4/intf.c
+++ b/drivers/net/ethernet/mellanox/mlx4/intf.c
@@ -33,11 +33,13 @@
 
 #include <linux/slab.h>
 #include <linux/export.h>
+#include <linux/errno.h>
 
 #include "mlx4.h"
 
 struct mlx4_device_context {
 	struct list_head	list;
+	struct list_head	bond_list;
 	struct mlx4_interface  *intf;
 	void		       *context;
 };
@@ -115,6 +117,58 @@ void mlx4_unregister_interface(struct mlx4_interface *intf)
 }
 EXPORT_SYMBOL_GPL(mlx4_unregister_interface);
 
+int mlx4_do_bond(struct mlx4_dev *dev, bool enable)
+{
+	struct mlx4_priv *priv = mlx4_priv(dev);
+	struct mlx4_device_context *dev_ctx = NULL, *temp_dev_ctx;
+	unsigned long flags;
+	int ret;
+	LIST_HEAD(bond_list);
+
+	if (!(dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_PORT_REMAP))
+		return -ENOTSUPP;
+
+	ret = mlx4_disable_rx_port_check(dev, enable);
+	if (ret) {
+		mlx4_err(dev, "Fail to %s rx port check\n",
+			 enable ? "enable" : "disable");
+		return ret;
+	}
+	if (enable) {
+		dev->flags |= MLX4_FLAG_BONDED;
+	} else {
+		 ret = mlx4_virt2phy_port_map(dev, 1, 2);
+		if (ret) {
+			mlx4_err(dev, "Fail to reset port map\n");
+			return ret;
+		}
+		dev->flags &= ~MLX4_FLAG_BONDED;
+	}
+
+	spin_lock_irqsave(&priv->ctx_lock, flags);
+	list_for_each_entry_safe(dev_ctx, temp_dev_ctx, &priv->ctx_list, list) {
+		if (dev_ctx->intf->flags & MLX4_INTFF_BONDING) {
+			list_add_tail(&dev_ctx->bond_list, &bond_list);
+			list_del(&dev_ctx->list);
+		}
+	}
+	spin_unlock_irqrestore(&priv->ctx_lock, flags);
+
+	list_for_each_entry(dev_ctx, &bond_list, bond_list) {
+		dev_ctx->intf->remove(dev, dev_ctx->context);
+		dev_ctx->context =  dev_ctx->intf->add(dev);
+
+		spin_lock_irqsave(&priv->ctx_lock, flags);
+		list_add_tail(&dev_ctx->list, &priv->ctx_list);
+		spin_unlock_irqrestore(&priv->ctx_lock, flags);
+
+		mlx4_dbg(dev, "Inrerface for protocol %d restarted with when bonded mode is %s\n",
+			 dev_ctx->intf->protocol, enable ?
+			 "enabled" : "disabled");
+	}
+	return 0;
+}
+
 void mlx4_dispatch_event(struct mlx4_dev *dev, enum mlx4_dev_event type,
 			 unsigned long param)
 {
diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index cc9f484..f3245fe 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -1160,6 +1160,91 @@ err_set_port:
 	return err ? err : count;
 }
 
+int mlx4_bond(struct mlx4_dev *dev)
+{
+	int ret = 0;
+	struct mlx4_priv *priv = mlx4_priv(dev);
+
+	mutex_lock(&priv->bond_mutex);
+
+	if (!mlx4_is_bonded(dev))
+		ret = mlx4_do_bond(dev, true);
+	else
+		ret = 0;
+
+	mutex_unlock(&priv->bond_mutex);
+	if (ret)
+		mlx4_err(dev, "Failed to bond device: %d\n", ret);
+	else
+		mlx4_dbg(dev, "Device is bonded\n");
+	return ret;
+}
+EXPORT_SYMBOL_GPL(mlx4_bond);
+
+int mlx4_unbond(struct mlx4_dev *dev)
+{
+	int ret = 0;
+	struct mlx4_priv *priv = mlx4_priv(dev);
+
+	mutex_lock(&priv->bond_mutex);
+
+	if (mlx4_is_bonded(dev))
+		ret = mlx4_do_bond(dev, false);
+
+	mutex_unlock(&priv->bond_mutex);
+	if (ret)
+		mlx4_err(dev, "Failed to unbond device: %d\n", ret);
+	else
+		mlx4_dbg(dev, "Device is unbonded\n");
+	return ret;
+}
+EXPORT_SYMBOL_GPL(mlx4_unbond);
+
+
+int mlx4_port_map_set(struct mlx4_dev *dev, struct mlx4_port_map *v2p)
+{
+	u8 port1 = v2p->port1;
+	u8 port2 = v2p->port2;
+	struct mlx4_priv *priv = mlx4_priv(dev);
+	int err;
+
+	if (!(dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_PORT_REMAP))
+		return -ENOTSUPP;
+
+	mutex_lock(&priv->bond_mutex);
+
+	/* zero means keep current mapping for this port */
+	if (port1 == 0)
+		port1 = priv->v2p.port1;
+	if (port2 == 0)
+		port2 = priv->v2p.port2;
+
+	if ((port1 < 1) || (port1 > MLX4_MAX_PORTS) ||
+	    (port2 < 1) || (port2 > MLX4_MAX_PORTS) ||
+	    (port1 == 2 && port2 == 1)) {
+		/* besides boundary checks cross mapping makes
+		 * no sense and therefore not allowed */
+		err = -EINVAL;
+	} else if ((port1 == priv->v2p.port1) &&
+		 (port2 == priv->v2p.port2)) {
+		err = 0;
+	} else {
+		err = mlx4_virt2phy_port_map(dev, port1, port2);
+		if (!err) {
+			mlx4_dbg(dev, "port map changed: [%d][%d]\n",
+				 port1, port2);
+			priv->v2p.port1 = port1;
+			priv->v2p.port2 = port2;
+		} else {
+			mlx4_err(dev, "Failed to change port mape: %d\n", err);
+		}
+	}
+
+	mutex_unlock(&priv->bond_mutex);
+	return err;
+}
+EXPORT_SYMBOL_GPL(mlx4_port_map_set);
+
 static int mlx4_load_fw(struct mlx4_dev *dev)
 {
 	struct mlx4_priv *priv = mlx4_priv(dev);
@@ -2638,6 +2723,7 @@ static int mlx4_load_one(struct pci_dev *pdev, int pci_dev_data,
 	spin_lock_init(&priv->ctx_lock);
 
 	mutex_init(&priv->port_mutex);
+	mutex_init(&priv->bond_mutex);
 
 	INIT_LIST_HEAD(&priv->pgdir_list);
 	mutex_init(&priv->pgdir_mutex);
@@ -2934,6 +3020,9 @@ slave_start:
 			goto err_port;
 	}
 
+	priv->v2p.port1 = 1;
+	priv->v2p.port2 = 2;
+
 	err = mlx4_register_device(dev);
 	if (err)
 		goto err_port;
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4.h b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
index 148dc09..803f176 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
@@ -885,6 +885,8 @@ struct mlx4_priv {
 	int			reserved_mtts;
 	int			fs_hash_mode;
 	u8 virt2phys_pkey[MLX4_MFUNC_MAX][MLX4_MAX_PORTS][MLX4_MAX_PORT_PKEYS];
+	struct mlx4_port_map	v2p; /* cached port mapping configuration */
+	struct mutex		bond_mutex; /* for bond mode */
 	__be64			slave_node_guids[MLX4_MFUNC_MAX];
 
 	atomic_t		opreq_count;
@@ -1364,6 +1366,7 @@ int mlx4_get_slave_num_gids(struct mlx4_dev *dev, int slave, int port);
 /* Returns the VF index of slave */
 int mlx4_get_vf_indx(struct mlx4_dev *dev, int slave);
 int mlx4_config_mad_demux(struct mlx4_dev *dev);
+int mlx4_do_bond(struct mlx4_dev *dev, bool enable);
 
 enum mlx4_zone_flags {
 	MLX4_ZONE_ALLOW_ALLOC_FROM_LOWER_PRIO	= 1UL << 0,
diff --git a/drivers/net/ethernet/mellanox/mlx4/qp.c b/drivers/net/ethernet/mellanox/mlx4/qp.c
index 1586ecc..2bb8553 100644
--- a/drivers/net/ethernet/mellanox/mlx4/qp.c
+++ b/drivers/net/ethernet/mellanox/mlx4/qp.c
@@ -882,6 +882,8 @@ int mlx4_qp_to_ready(struct mlx4_dev *dev, struct mlx4_mtt *mtt,
 	for (i = 0; i < ARRAY_SIZE(states) - 1; i++) {
 		context->flags &= cpu_to_be32(~(0xf << 28));
 		context->flags |= cpu_to_be32(states[i + 1] << 28);
+		if (states[i + 1] != MLX4_QP_STATE_RTR)
+			context->params2 &= ~MLX4_QP_BIT_FPP;
 		err = mlx4_qp_modify(dev, mtt, states[i], states[i + 1],
 				     context, 0, 0, qp);
 		if (err) {
diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
index 79feeb6..c5f3dfc 100644
--- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
+++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
@@ -2944,6 +2944,9 @@ static int verify_qp_parameters(struct mlx4_dev *dev,
 	qp_type	= (be32_to_cpu(qp_ctx->flags) >> 16) & 0xff;
 	optpar	= be32_to_cpu(*(__be32 *) inbox->buf);
 
+	if (slave != mlx4_master_func_num(dev))
+		qp_ctx->params2 &= ~MLX4_QP_BIT_FPP;
+
 	switch (qp_type) {
 	case MLX4_QP_ST_RC:
 	case MLX4_QP_ST_XRC:
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index d9afd99..977b0b1 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -70,6 +70,7 @@ enum {
 	MLX4_FLAG_SLAVE		= 1 << 3,
 	MLX4_FLAG_SRIOV		= 1 << 4,
 	MLX4_FLAG_OLD_REG_MAC	= 1 << 6,
+	MLX4_FLAG_BONDED	= 1 << 7
 };
 
 enum {
diff --git a/include/linux/mlx4/driver.h b/include/linux/mlx4/driver.h
index 022055c..9553a73 100644
--- a/include/linux/mlx4/driver.h
+++ b/include/linux/mlx4/driver.h
@@ -49,6 +49,10 @@ enum mlx4_dev_event {
 	MLX4_DEV_EVENT_SLAVE_SHUTDOWN,
 };
 
+enum {
+	MLX4_INTFF_BONDING	= 1 << 0
+};
+
 struct mlx4_interface {
 	void *			(*add)	 (struct mlx4_dev *dev);
 	void			(*remove)(struct mlx4_dev *dev, void *context);
@@ -57,11 +61,26 @@ struct mlx4_interface {
 	void *			(*get_dev)(struct mlx4_dev *dev, void *context, u8 port);
 	struct list_head	list;
 	enum mlx4_protocol	protocol;
+	int			flags;
 };
 
 int mlx4_register_interface(struct mlx4_interface *intf);
 void mlx4_unregister_interface(struct mlx4_interface *intf);
 
+int mlx4_bond(struct mlx4_dev *dev);
+int mlx4_unbond(struct mlx4_dev *dev);
+static inline int mlx4_is_bonded(struct mlx4_dev *dev)
+{
+	return !!(dev->flags & MLX4_FLAG_BONDED);
+}
+
+struct mlx4_port_map {
+	u8	port1;
+	u8	port2;
+};
+
+int mlx4_port_map_set(struct mlx4_dev *dev, struct mlx4_port_map *v2p);
+
 void *mlx4_get_protocol_dev(struct mlx4_dev *dev, enum mlx4_protocol proto, int port);
 
 static inline u64 mlx4_mac_to_u64(u8 *addr)
-- 
1.7.1
