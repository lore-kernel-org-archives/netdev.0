From: Yevgeny Petrilin <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
Subject: [PATCH 17/25 v2] mlx4: Changed Mac management
Date: Fri, 06 Nov 2009 05:09:52 +0200
Message-ID: <4AF39380.1050402@mellanox.co.il>
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


RX qp is given from a pool of previously reserved range of QPs.
Activating Mac steering now.
Giving an option to change mac without the need to change the RX QP.
All the mac management is done by the master, added wrappers for the
mac management.

Signed-off-by: Yevgeny Petrilin <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
---
 drivers/net/mlx4/cmd.c       |   26 +++++++++++
 drivers/net/mlx4/en_netdev.c |   32 +++++++-------
 drivers/net/mlx4/en_port.c   |    1 +
 drivers/net/mlx4/en_port.h   |    8 +++-
 drivers/net/mlx4/en_rx.c     |   11 +----
 drivers/net/mlx4/main.c      |   11 +++--
 drivers/net/mlx4/mlx4.h      |    7 ++-
 drivers/net/mlx4/port.c      |   96 ++++++++++++++++++++++++++++++++----------
 include/linux/mlx4/cmd.h     |    9 ++--
 include/linux/mlx4/device.h  |    5 +-
 10 files changed, 144 insertions(+), 62 deletions(-)

diff --git a/drivers/net/mlx4/cmd.c b/drivers/net/mlx4/cmd.c
index d68d0e1..71d822a 100644
--- a/drivers/net/mlx4/cmd.c
+++ b/drivers/net/mlx4/cmd.c
@@ -507,6 +507,24 @@ static int mlx4_RESOURCE_wrapper(struct mlx4_dev *dev, int slave, struct mlx4_vh
 		} else
 			mlx4_free_mtt_range(dev, param1 /* first */, param2 /* order */);
 		break;
+	case RES_MAC:
+		switch (vhcr->op) {
+		case MLX4_CMD_ALLOC_RES:
+			ret = mlx4_register_mac(dev, vhcr->op_modifier,
+						vhcr->in_param, (int *) &vhcr->out_param);
+			vhcr->errno = ret;
+			break;
+		case MLX4_CMD_FREE_RES:
+			mlx4_unregister_mac(dev, vhcr->op_modifier, vhcr->in_param);
+			break;
+		case MLX4_CMD_REPLACE_RES:
+			ret = mlx4_replace_mac(dev, vhcr->op_modifier,
+					       vhcr->out_param, vhcr->in_param);
+			vhcr->errno = ret;
+			break;
+		default:
+			vhcr->errno = -EINVAL;
+		}
 	default:
 		vhcr->errno = -EINVAL;
 	}
@@ -622,6 +640,14 @@ static struct mlx4_cmd_info {
 		.wrapper = mlx4_RESOURCE_wrapper
 	},
 	{
+		.opcode = MLX4_CMD_REPLACE_RES,
+		.has_inbox = false,
+		.has_outbox = false,
+		.out_is_imm = true,
+		.verify = NULL,
+		.wrapper = mlx4_RESOURCE_wrapper
+	},
+	{
 		.opcode = MLX4_CMD_GET_EVENT,
 		.has_inbox = false,
 		.has_outbox = false,
diff --git a/drivers/net/mlx4/en_netdev.c b/drivers/net/mlx4/en_netdev.c
index c48b0f4..fd96078 100644
--- a/drivers/net/mlx4/en_netdev.c
+++ b/drivers/net/mlx4/en_netdev.c
@@ -145,9 +145,8 @@ static void mlx4_en_do_set_mac(struct work_struct *work)
 	mutex_lock(&mdev->state_lock);
 	if (priv->port_up) {
 		/* Remove old MAC and insert the new one */
-		mlx4_unregister_mac(mdev->dev, priv->port, priv->mac_index);
-		err = mlx4_register_mac(mdev->dev, priv->port,
-					priv->mac, &priv->mac_index);
+		err = mlx4_replace_mac(mdev->dev, priv->port,
+				       priv->base_qpn, priv->mac);
 		if (err)
 			en_err(priv, "Failed changing HW MAC address\n");
 	} else
@@ -596,10 +595,19 @@ int mlx4_en_start_port(struct net_device *dev)
 		++rx_index;
 	}
 
+	/* Set port mac number */
+	en_dbg(DRV, priv, "Setting mac for port %d\n", priv->port);
+	err = mlx4_register_mac(mdev->dev, priv->port,
+				priv->mac, &priv->base_qpn);
+	if (err) {
+		en_err(priv, "Failed setting port mac\n");
+		goto cq_err;
+	}
+
 	err = mlx4_en_config_rss_steer(priv);
 	if (err) {
 		en_err(priv, "Failed configuring rss steering\n");
-		goto cq_err;
+		goto mac_err;
 	}
 
 	/* Configure tx cq's and rings */
@@ -652,21 +660,13 @@ int mlx4_en_start_port(struct net_device *dev)
 		en_err(priv, "Failed setting default qp numbers\n");
 		goto tx_err;
 	}
-	/* Set port mac number */
-	en_dbg(DRV, priv, "Setting mac for port %d\n", priv->port);
-	err = mlx4_register_mac(mdev->dev, priv->port,
-				priv->mac, &priv->mac_index);
-	if (err) {
-		en_err(priv, "Failed setting port mac\n");
-		goto tx_err;
-	}
 
 	/* Init port */
 	en_dbg(HW, priv, "Initializing port\n");
 	err = mlx4_INIT_PORT(mdev->dev, priv->port);
 	if (err) {
 		en_err(priv, "Failed Initializing port\n");
-		goto mac_err;
+		goto tx_err;
 	}
 
 	/* Schedule multicast task to populate multicast list */
@@ -676,8 +676,6 @@ int mlx4_en_start_port(struct net_device *dev)
 	netif_tx_start_all_queues(dev);
 	return 0;
 
-mac_err:
-	mlx4_unregister_mac(mdev->dev, priv->port, priv->mac_index);
 tx_err:
 	while (tx_index--) {
 		mlx4_en_deactivate_tx_ring(priv, &priv->tx_ring[tx_index]);
@@ -685,6 +683,8 @@ tx_err:
 	}
 
 	mlx4_en_release_rss_steer(priv);
+mac_err:
+	mlx4_unregister_mac(mdev->dev, priv->port, priv->base_qpn);
 cq_err:
 	while (rx_index--)
 		mlx4_en_deactivate_cq(priv, &priv->rx_cq[rx_index]);
@@ -716,7 +716,7 @@ void mlx4_en_stop_port(struct net_device *dev)
 	mlx4_CLOSE_PORT(mdev->dev, priv->port);
 
 	/* Unregister Mac address for the port */
-	mlx4_unregister_mac(mdev->dev, priv->port, priv->mac_index);
+	mlx4_unregister_mac(mdev->dev, priv->port, priv->base_qpn);
 
 	/* Free TX Rings */
 	for (i = 0; i < priv->tx_ring_num; i++) {
diff --git a/drivers/net/mlx4/en_port.c b/drivers/net/mlx4/en_port.c
index a29abe8..c099cb4 100644
--- a/drivers/net/mlx4/en_port.c
+++ b/drivers/net/mlx4/en_port.c
@@ -127,6 +127,7 @@ int mlx4_SET_PORT_qpn_calc(struct mlx4_dev *dev, u8 port, u32 base_qpn,
 	memset(context, 0, sizeof *context);
 
 	context->base_qpn = cpu_to_be32(base_qpn);
+	context->n_mac = 0x7;
 	context->promisc = cpu_to_be32(promisc << SET_PORT_PROMISC_SHIFT | base_qpn);
 	context->mcast = cpu_to_be32(1 << SET_PORT_PROMISC_SHIFT | base_qpn);
 	context->intra_no_vlan = 0;
diff --git a/drivers/net/mlx4/en_port.h b/drivers/net/mlx4/en_port.h
index 3892896..62c9135 100644
--- a/drivers/net/mlx4/en_port.h
+++ b/drivers/net/mlx4/en_port.h
@@ -54,14 +54,18 @@ struct mlx4_set_port_general_context {
 
 struct mlx4_set_port_rqp_calc_context {
 	__be32 base_qpn;
+	u8 rererved;
+	u8 n_mac;
+	u8 n_vlan;
+	u8 n_prio;
 	__be32 flags;
-	u8 reserved[3];
+	u8 reserved2[3];
 	u8 mac_miss;
 	u8 intra_no_vlan;
 	u8 no_vlan;
 	u8 intra_vlan_miss;
 	u8 vlan_miss;
-	u8 reserved2[3];
+	u8 reserved3[3];
 	u8 no_vlan_prio;
 	__be32 promisc;
 	__be32 mcast;
diff --git a/drivers/net/mlx4/en_rx.c b/drivers/net/mlx4/en_rx.c
index 03b781a..d3884ce 100644
--- a/drivers/net/mlx4/en_rx.c
+++ b/drivers/net/mlx4/en_rx.c
@@ -865,16 +865,10 @@ int mlx4_en_config_rss_steer(struct mlx4_en_priv *priv)
 	}
 
 	/* Configure RSS indirection qp */
-	err = mlx4_qp_reserve_range(mdev->dev, 1, 1, &priv->base_qpn);
-	if (err) {
-		en_err(priv, "Failed to reserve range for RSS "
-			     "indirection qp\n");
-		goto rss_err;
-	}
 	err = mlx4_qp_alloc(mdev->dev, priv->base_qpn, &rss_map->indir_qp);
 	if (err) {
 		en_err(priv, "Failed to allocate RSS indirection QP\n");
-		goto reserve_err;
+		goto rss_err;
 	}
 	rss_map->indir_qp.event = mlx4_en_sqp_event;
 	mlx4_en_fill_qp_context(priv, 0, 0, 0, 1, priv->base_qpn,
@@ -900,8 +894,6 @@ indir_err:
 		       MLX4_QP_STATE_RST, NULL, 0, 0, &rss_map->indir_qp);
 	mlx4_qp_remove(mdev->dev, &rss_map->indir_qp);
 	mlx4_qp_free(mdev->dev, &rss_map->indir_qp);
-reserve_err:
-	mlx4_qp_release_range(mdev->dev, priv->base_qpn, 1);
 rss_err:
 	for (i = 0; i < good_qps; i++) {
 		mlx4_qp_modify(mdev->dev, NULL, rss_map->state[i],
@@ -923,7 +915,6 @@ void mlx4_en_release_rss_steer(struct mlx4_en_priv *priv)
 		       MLX4_QP_STATE_RST, NULL, 0, 0, &rss_map->indir_qp);
 	mlx4_qp_remove(mdev->dev, &rss_map->indir_qp);
 	mlx4_qp_free(mdev->dev, &rss_map->indir_qp);
-	mlx4_qp_release_range(mdev->dev, priv->base_qpn, 1);
 
 	for (i = 0; i < priv->rx_ring_num; i++) {
 		mlx4_qp_modify(mdev->dev, NULL, rss_map->state[i],
diff --git a/drivers/net/mlx4/main.c b/drivers/net/mlx4/main.c
index 787bcde..45ce765 100644
--- a/drivers/net/mlx4/main.c
+++ b/drivers/net/mlx4/main.c
@@ -104,7 +104,7 @@ static struct mlx4_profile default_profile = {
 	.num_mtt	= 1 << 20,
 };
 
-static int log_num_mac = 2;
+static int log_num_mac = 7;
 module_param_named(log_num_mac, log_num_mac, int, 0444);
 MODULE_PARM_DESC(log_num_mac, "Log2 max number of MACs per ETH port (1-7)");
 
@@ -1155,9 +1155,12 @@ static int mlx4_init_port_info(struct mlx4_dev *dev, int port)
 
 	info->dev = dev;
 	info->port = port;
-	mlx4_init_mac_table(dev, &info->mac_table);
-	mlx4_init_vlan_table(dev, &info->vlan_table);
-
+	if (!mlx4_is_slave(dev)) {
+		mlx4_init_mac_table(dev, &info->mac_table);
+		mlx4_init_vlan_table(dev, &info->vlan_table);
+		info->base_qpn = dev->caps.reserved_qps_base[MLX4_QP_REGION_ETH_ADDR] +
+			(port - 1) * (1 << log_num_mac);
+	}
 	sprintf(info->dev_name, "mlx4_port%d", port);
 	info->port_attr.attr.name = info->dev_name;
 	info->port_attr.attr.mode = S_IRUGO | S_IWUSR;
diff --git a/drivers/net/mlx4/mlx4.h b/drivers/net/mlx4/mlx4.h
index b94c590..19c87e7 100644
--- a/drivers/net/mlx4/mlx4.h
+++ b/drivers/net/mlx4/mlx4.h
@@ -101,7 +101,10 @@ enum mlx4_resource {
 	RES_CQ,
 	RES_SRQ,
 	RES_MPT,
-	RES_MTT
+	RES_MTT,
+	RES_MAC,
+	RES_VLAN,
+	RES_MCAST
 };
 
 enum mlx4_alloc_mode {
@@ -344,7 +347,6 @@ struct mlx4_catas_err {
 
 struct mlx4_mac_table {
 	__be64			entries[MLX4_MAX_MAC_NUM];
-	int			refs[MLX4_MAX_MAC_NUM];
 	struct mutex		mutex;
 	int			total;
 	int			max;
@@ -369,6 +371,7 @@ struct mlx4_port_info {
 	enum mlx4_port_type	tmp_type;
 	struct mlx4_mac_table	mac_table;
 	struct mlx4_vlan_table	vlan_table;
+	int			base_qpn;
 };
 
 struct mlx4_sense {
diff --git a/drivers/net/mlx4/port.c b/drivers/net/mlx4/port.c
index 67f0751..6e729dd 100644
--- a/drivers/net/mlx4/port.c
+++ b/drivers/net/mlx4/port.c
@@ -48,10 +48,8 @@ void mlx4_init_mac_table(struct mlx4_dev *dev, struct mlx4_mac_table *table)
 	int i;
 
 	mutex_init(&table->mutex);
-	for (i = 0; i < MLX4_MAX_MAC_NUM; i++) {
+	for (i = 0; i < MLX4_MAX_MAC_NUM; i++)
 		table->entries[i] = 0;
-		table->refs[i]	 = 0;
-	}
 	table->max   = 1 << dev->caps.log_num_macs;
 	table->total = 0;
 }
@@ -90,24 +88,33 @@ static int mlx4_set_port_mac_table(struct mlx4_dev *dev, u8 port,
 	return err;
 }
 
-int mlx4_register_mac(struct mlx4_dev *dev, u8 port, u64 mac, int *index)
+int mlx4_register_mac(struct mlx4_dev *dev, u8 port, u64 mac, int *qpn)
 {
-	struct mlx4_mac_table *table = &mlx4_priv(dev)->port[port].mac_table;
+	struct mlx4_port_info *info = &mlx4_priv(dev)->port[port];
+	struct mlx4_mac_table *table = &info->mac_table;
+	u64 out_param;
 	int i, err = 0;
 	int free = -1;
 
+	if (mlx4_is_slave(dev)) {
+		err = mlx4_cmd_imm(dev, mac, &out_param, RES_MAC, port,
+				   MLX4_CMD_ALLOC_RES, MLX4_CMD_TIME_CLASS_A);
+		if (!err)
+			*qpn = out_param;
+		return err;
+	}
+
 	mlx4_dbg(dev, "Registering MAC: 0x%llx\n", (unsigned long long) mac);
 	mutex_lock(&table->mutex);
 	for (i = 0; i < MLX4_MAX_MAC_NUM - 1; i++) {
-		if (free < 0 && !table->refs[i]) {
+		if (free < 0 && !table->entries[i]) {
 			free = i;
 			continue;
 		}
 
 		if (mac == (MLX4_MAC_MASK & be64_to_cpu(table->entries[i]))) {
-			/* MAC already registered, increase refernce count */
-			*index = i;
-			++table->refs[i];
+			/* MAC already registered, Must not have duplicates */
+			err = -EEXIST;
 			goto out;
 		}
 	}
@@ -120,18 +127,16 @@ int mlx4_register_mac(struct mlx4_dev *dev, u8 port, u64 mac, int *index)
 	}
 
 	/* Register new MAC */
-	table->refs[free] = 1;
 	table->entries[free] = cpu_to_be64(mac | MLX4_MAC_VALID);
 
 	err = mlx4_set_port_mac_table(dev, port, table->entries);
 	if (unlikely(err)) {
 		mlx4_err(dev, "Failed adding MAC: 0x%llx\n", (unsigned long long) mac);
-		table->refs[free] = 0;
 		table->entries[free] = 0;
 		goto out;
 	}
 
-	*index = free;
+	*qpn = info->base_qpn + free;
 	++table->total;
 out:
 	mutex_unlock(&table->mutex);
@@ -139,20 +144,35 @@ out:
 }
 EXPORT_SYMBOL_GPL(mlx4_register_mac);
 
-void mlx4_unregister_mac(struct mlx4_dev *dev, u8 port, int index)
+static int validate_index(struct mlx4_dev *dev,
+			  struct mlx4_mac_table *table, int index)
 {
-	struct mlx4_mac_table *table = &mlx4_priv(dev)->port[port].mac_table;
+	int err = 0;
 
-	mutex_lock(&table->mutex);
-	if (!table->refs[index]) {
-		mlx4_warn(dev, "No MAC entry for index %d\n", index);
-		goto out;
+	if (index < 0 || index >= table->max || !table->entries[index]) {
+		mlx4_warn(dev, "No valid Mac entry for the given index\n");
+		err = -EINVAL;
 	}
-	if (--table->refs[index]) {
-		mlx4_warn(dev, "Have more references for index %d,"
-			  "no need to modify MAC table\n", index);
-		goto out;
+	return err;
+}
+
+void mlx4_unregister_mac(struct mlx4_dev *dev, u8 port, int qpn)
+{
+	struct mlx4_port_info *info = &mlx4_priv(dev)->port[port];
+	struct mlx4_mac_table *table = &info->mac_table;
+	int index = qpn - info->base_qpn;
+
+	if (mlx4_is_slave(dev)) {
+		mlx4_cmd(dev, qpn, RES_MAC, port,
+			 MLX4_CMD_FREE_RES, MLX4_CMD_TIME_CLASS_A);
+		return;
 	}
+
+	mutex_lock(&table->mutex);
+
+	if (validate_index(dev, table, index))
+		goto out;
+
 	table->entries[index] = 0;
 	mlx4_set_port_mac_table(dev, port, table->entries);
 	--table->total;
@@ -161,6 +181,38 @@ out:
 }
 EXPORT_SYMBOL_GPL(mlx4_unregister_mac);
 
+int mlx4_replace_mac(struct mlx4_dev *dev, u8 port, int qpn, u64 new_mac)
+{
+	struct mlx4_port_info *info = &mlx4_priv(dev)->port[port];
+	struct mlx4_mac_table *table = &info->mac_table;
+	int index = qpn - info->base_qpn;
+	int err;
+
+	if (mlx4_is_slave(dev)) {
+		err = mlx4_cmd_imm(dev, new_mac, (u64 *) &qpn, RES_MAC, port,
+				   MLX4_CMD_REPLACE_RES, MLX4_CMD_TIME_CLASS_A);
+		return err;
+	}
+
+	mutex_lock(&table->mutex);
+
+	err = validate_index(dev, table, index);
+	if (err)
+		goto out;
+
+	table->entries[index] = cpu_to_be64(new_mac | MLX4_MAC_VALID);
+
+	err = mlx4_set_port_mac_table(dev, port, table->entries);
+	if (unlikely(err)) {
+		mlx4_err(dev, "Failed adding MAC: 0x%llx\n", (unsigned long long) new_mac);
+		table->entries[index] = 0;
+	}
+out:
+	mutex_unlock(&table->mutex);
+	return err;
+}
+EXPORT_SYMBOL_GPL(mlx4_replace_mac);
+
 static int mlx4_set_port_vlan_table(struct mlx4_dev *dev, u8 port,
 				    __be32 *entries)
 {
diff --git a/include/linux/mlx4/cmd.h b/include/linux/mlx4/cmd.h
index 99145d4..c163d5e 100644
--- a/include/linux/mlx4/cmd.h
+++ b/include/linux/mlx4/cmd.h
@@ -127,10 +127,11 @@ enum {
 	/* virtual commands */
 	MLX4_CMD_ALLOC_RES	 = 0x50,
 	MLX4_CMD_FREE_RES	 = 0x51,
-	MLX4_CMD_GET_EVENT	 = 0x52,
-	MLX4_CMD_QUERY_SLAVE_CAP = 0x53,
-	MLX4_CMD_MCAST_ATTACH	 = 0x54,
-	MLX4_CMD_GET_SLAVE_SQP	 = 0x55,
+	MLX4_CMD_REPLACE_RES	 = 0x52,
+	MLX4_CMD_GET_EVENT	 = 0x53,
+	MLX4_CMD_QUERY_SLAVE_CAP = 0x54,
+	MLX4_CMD_MCAST_ATTACH	 = 0x55,
+	MLX4_CMD_GET_SLAVE_SQP	 = 0x56,
 
 	/* debug commands */
 	MLX4_CMD_QUERY_DEBUG_MSG = 0x2a,
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index bbd398b..246b7bc 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -491,8 +491,9 @@ int mlx4_multicast_attach(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
 			  int block_mcast_loopback);
 int mlx4_multicast_detach(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16]);
 
-int mlx4_register_mac(struct mlx4_dev *dev, u8 port, u64 mac, int *index);
-void mlx4_unregister_mac(struct mlx4_dev *dev, u8 port, int index);
+int mlx4_register_mac(struct mlx4_dev *dev, u8 port, u64 mac, int *qpn);
+void mlx4_unregister_mac(struct mlx4_dev *dev, u8 port, int qpn);
+int mlx4_replace_mac(struct mlx4_dev *dev, u8 port, int qpn, u64 new_mac);
 
 int mlx4_register_vlan(struct mlx4_dev *dev, u8 port, u16 vlan, int *index);
 void mlx4_unregister_vlan(struct mlx4_dev *dev, u8 port, int index);
-- 
1.5.3.7

From: Liran Liss <liranl-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>





--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
