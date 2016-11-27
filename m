From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net-next 01/10] net/mlx4_core: Make each VF manage its own mac table
Date: Sun, 27 Nov 2016 17:51:08 +0200
Message-ID: <1480261877-19720-2-git-send-email-tariqt@mellanox.com>
References: <1480261877-19720-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Erez Shitrit <erezsh@mellanox.com>,
        Gal Pressman <galp@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:50465 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753198AbcK0Pvo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 27 Nov 2016 10:51:44 -0500
In-Reply-To: <1480261877-19720-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erez Shitrit <erezsh@mellanox.com>

Each VF can catch up to the max number of MACs in the
MAC table (128) on the base of "first asks first gets".
The VF should know the total free number of MACs from
the PF.

Signed-off-by: Erez Shitrit <erezsh@mellanox.com>
Signed-off-by: Gal Pressman <galp@mellanox.com>
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/fw.c            | 13 ++++
 drivers/net/ethernet/mellanox/mlx4/main.c          |  4 +-
 drivers/net/ethernet/mellanox/mlx4/mlx4.h          |  1 +
 drivers/net/ethernet/mellanox/mlx4/port.c          | 90 +++++++++++++++++++++-
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |  6 +-
 include/linux/mlx4/device.h                        |  1 +
 6 files changed, 110 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index 84bab9f0732e..b03b473a7b07 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -1415,6 +1415,9 @@ int mlx4_QUERY_PORT_wrapper(struct mlx4_dev *dev, int slave,
 			   MLX4_CMD_NATIVE);
 
 	if (!err && dev->caps.function != slave) {
+		u8 field;
+		u8 vlan;
+
 		def_mac = priv->mfunc.master.vf_oper[slave].vport[vhcr->in_modifier].state.mac;
 		MLX4_PUT(outbox->buf, def_mac, QUERY_PORT_MAC_OFFSET);
 
@@ -1455,6 +1458,16 @@ int mlx4_QUERY_PORT_wrapper(struct mlx4_dev *dev, int slave,
 		short_field = dev->caps.pkey_table_len[vhcr->in_modifier];
 		MLX4_PUT(outbox->buf, short_field,
 			 QUERY_PORT_CUR_MAX_PKEY_OFFSET);
+
+		/* Change the mac table size for the VF */
+		MLX4_GET(field, outbox, QUERY_PORT_MAX_MACVLAN_OFFSET);
+		/* keep the origin vlan of the VF */
+		vlan = field >> 4;
+		/* set the field with the prev vlan and the mac defined quota */
+		field = vlan << 4;
+		field |= ilog2(mlx4_get_port_free_macs(dev,
+						       priv->port->port + 1));
+		MLX4_PUT(outbox->buf, field, QUERY_PORT_MAX_MACVLAN_OFFSET);
 	}
 out:
 	return err;
diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 6f4e67bc3538..7cd1fb566f5a 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -2937,12 +2937,14 @@ static int mlx4_init_port_info(struct mlx4_dev *dev, int port)
 	info->dev = dev;
 	info->port = port;
 	if (!mlx4_is_slave(dev)) {
-		mlx4_init_mac_table(dev, &info->mac_table);
 		mlx4_init_vlan_table(dev, &info->vlan_table);
 		mlx4_init_roce_gid_table(dev, &info->gid_table);
 		info->base_qpn = mlx4_get_base_qpn(dev, port);
 	}
 
+	/* let the vf manage its own mac table state */
+	mlx4_init_mac_table(dev, &info->mac_table);
+
 	sprintf(info->dev_name, "mlx4_port%d", port);
 	info->port_attr.attr.name = info->dev_name;
 	if (mlx4_is_mfunc(dev))
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4.h b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
index 88ee7d8a5923..d953d6eb7d9e 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
@@ -741,6 +741,7 @@ struct mlx4_catas_err {
 
 #define MLX4_MAX_MAC_NUM	128
 #define MLX4_MAC_TABLE_SIZE	(MLX4_MAX_MAC_NUM << 3)
+#define MLX4_VF_MAC_QUOTA	2
 
 struct mlx4_mac_table {
 	__be64			entries[MLX4_MAX_MAC_NUM];
diff --git a/drivers/net/ethernet/mellanox/mlx4/port.c b/drivers/net/ethernet/mellanox/mlx4/port.c
index b656dd5772e5..86cb58690845 100644
--- a/drivers/net/ethernet/mellanox/mlx4/port.c
+++ b/drivers/net/ethernet/mellanox/mlx4/port.c
@@ -39,6 +39,7 @@
 
 #include "mlx4.h"
 #include "mlx4_stats.h"
+#include "fw.h"
 
 #define MLX4_MAC_VALID		(1ull << 63)
 
@@ -54,6 +55,34 @@
 #define MLX4_IGNORE_FCS_MASK			0x1
 #define MLX4_TC_MAX_NUMBER			8
 
+static void mlx4_inc_port_macs(struct mlx4_dev *mdev, int port)
+{
+	struct mlx4_port_info *info = &mlx4_priv(mdev)->port[port];
+
+	mutex_lock(&info->mac_table.mutex);
+	info->mac_table.total++;
+	mutex_unlock(&info->mac_table.mutex);
+	mlx4_info(mdev, "%s added mac for port: %d, now: %d\n",
+		  __func__, port, info->mac_table.total);
+}
+
+static void mlx4_dec_port_macs(struct mlx4_dev *mdev, int port)
+{
+	struct mlx4_port_info *info = &mlx4_priv(mdev)->port[port];
+
+	if (!info->mac_table.total) {
+		mlx4_warn(mdev, "No current macs for port: %d\n", port);
+		return;
+	}
+
+	mutex_lock(&info->mac_table.mutex);
+	info->mac_table.total--;
+	mutex_unlock(&info->mac_table.mutex);
+
+	mlx4_info(mdev, "%s removed mac, port: %d, now: %d\n",
+		  __func__, port, info->mac_table.total);
+}
+
 void mlx4_init_mac_table(struct mlx4_dev *dev, struct mlx4_mac_table *table)
 {
 	int i;
@@ -340,6 +369,8 @@ int mlx4_register_mac(struct mlx4_dev *dev, u8 port, u64 mac)
 	int err = -EINVAL;
 
 	if (mlx4_is_mfunc(dev)) {
+		u32 p_l;
+
 		if (!(dev->flags & MLX4_FLAG_OLD_REG_MAC)) {
 			err = mlx4_cmd_imm(dev, mac, &out_param,
 					   ((u32) port) << 8 | (u32) RES_MAC,
@@ -358,8 +389,13 @@ int mlx4_register_mac(struct mlx4_dev *dev, u8 port, u64 mac)
 		if (err)
 			return err;
 
-		return get_param_l(&out_param);
+		p_l = get_param_l(&out_param);
+		/* update vf table, the master updated via __register_mac */
+		if (p_l && mlx4_is_slave(dev))
+			mlx4_inc_port_macs(dev, port);
+		return p_l;
 	}
+
 	return __mlx4_register_mac(dev, port, mac);
 }
 EXPORT_SYMBOL_GPL(mlx4_register_mac);
@@ -459,6 +495,11 @@ void mlx4_unregister_mac(struct mlx4_dev *dev, u8 port, u64 mac)
 					    RES_OP_RESERVE_AND_MAP, MLX4_CMD_FREE_RES,
 					    MLX4_CMD_TIME_CLASS_A, MLX4_CMD_WRAPPED);
 		}
+
+		/* update vf mac table */
+		if (mlx4_is_slave(dev))
+			mlx4_dec_port_macs(dev, port);
+
 		return;
 	}
 	__mlx4_unregister_mac(dev, port, mac);
@@ -2016,3 +2057,50 @@ int mlx4_max_tc(struct mlx4_dev *dev)
 	return num_tc;
 }
 EXPORT_SYMBOL(mlx4_max_tc);
+
+static int mlx4_get_port_reserved_mac_num(struct mlx4_dev *mdev, int port)
+{
+	struct mlx4_priv *priv = mlx4_priv(mdev);
+	struct resource_allocator *res_alloc;
+	int reserved;
+
+	if (mlx4_is_slave(mdev))
+		return 0;
+
+	res_alloc = &priv->mfunc.master.res_tracker.res_alloc[RES_MAC];
+
+	reserved = (port > 0) ? res_alloc->res_port_rsvd[port - 1] :
+		res_alloc->res_reserved;
+
+	return reserved;
+}
+
+static int mlx4_get_port_max_macs(struct mlx4_dev *mdev, int port)
+{
+	struct mlx4_port_info *info = &mlx4_priv(mdev)->port[port];
+
+	/* The maximum value should considers the reserved macs for the vfs */
+	return info->mac_table.max - mlx4_get_port_reserved_mac_num(mdev, port);
+}
+
+static int mlx4_get_port_total_macs(struct mlx4_dev *mdev, int port)
+{
+	struct mlx4_port_info *info = &mlx4_priv(mdev)->port[port];
+
+	return info->mac_table.total;
+}
+
+int mlx4_get_port_free_macs(struct mlx4_dev *mdev, int port)
+{
+	/* slave will get the free macs (log2) from its master */
+	if (mlx4_is_slave(mdev)) {
+		struct mlx4_port_cap port_cap;
+
+		mlx4_QUERY_PORT(mdev, port, &port_cap);
+		return (1 << port_cap.log_max_macs);
+	}
+
+	return (mlx4_get_port_max_macs(mdev, port) -
+		mlx4_get_port_total_macs(mdev, port));
+}
+EXPORT_SYMBOL(mlx4_get_port_free_macs);
diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
index c548beaaf910..ba7b70630d5d 100644
--- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
+++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
@@ -576,14 +576,14 @@ int mlx4_init_resource_tracker(struct mlx4_dev *dev)
 					}
 					res_alloc->quota[t] =
 						MLX4_MAX_MAC_NUM -
-						2 * max_vfs_pport;
-					res_alloc->guaranteed[t] = 2;
+						MLX4_VF_MAC_QUOTA * max_vfs_pport;
+					res_alloc->guaranteed[t] = MLX4_VF_MAC_QUOTA;
 					for (j = 0; j < MLX4_MAX_PORTS; j++)
 						res_alloc->res_port_free[j] =
 							MLX4_MAX_MAC_NUM;
 				} else {
 					res_alloc->quota[t] = MLX4_MAX_MAC_NUM;
-					res_alloc->guaranteed[t] = 2;
+					res_alloc->guaranteed[t] = MLX4_VF_MAC_QUOTA;
 				}
 				break;
 			case RES_VLAN:
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index 3be7abd6e722..4220fe8fe094 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -1493,6 +1493,7 @@ struct mlx4_slaves_pport mlx4_phys_to_slaves_pport_actv(
 int mlx4_get_base_gid_ix(struct mlx4_dev *dev, int slave, int port);
 
 int mlx4_config_vxlan_port(struct mlx4_dev *dev, __be16 udp_port);
+int mlx4_get_port_free_macs(struct mlx4_dev *mdev, int port);
 int mlx4_disable_rx_port_check(struct mlx4_dev *dev, bool dis);
 int mlx4_config_roce_v2_port(struct mlx4_dev *dev, u16 udp_port);
 int mlx4_virt2phy_port_map(struct mlx4_dev *dev, u32 port1, u32 port2);
-- 
1.8.3.1
