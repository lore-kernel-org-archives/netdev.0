From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 23/25] mlx4: Configuring multicast filter
Date: Wed, 04 Nov 2009 17:32:19 +0200
Message-ID: <4AF19E83.8030200@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
	liranl@mellanox.co.il, tziporet@mellanox.co.il,
	yevgenyp@mellanox.co.il
To: rdreier@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:34810 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755958AbZKDMed (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Nov 2009 07:34:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Multicast filter configuration is done by the master,
that manages the filter which is common for all the functions.
The master holds a list of multicast addresses for all the
slaves, and adds them to the filter.
In case some slave wishes to flush the filter, only his addresses
are removed.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/cmd.c      |    6 ++-
 drivers/net/mlx4/en_port.c  |    7 ---
 drivers/net/mlx4/mlx4.h     |   10 ++++
 drivers/net/mlx4/mlx4_en.h  |    1 -
 drivers/net/mlx4/port.c     |  125 +++++++++++++++++++++++++++++++++++++++++++
 include/linux/mlx4/device.h |    1 +
 6 files changed, 140 insertions(+), 10 deletions(-)

diff --git a/drivers/net/mlx4/cmd.c b/drivers/net/mlx4/cmd.c
index 183ba8d..3b0b22a 100644
--- a/drivers/net/mlx4/cmd.c
+++ b/drivers/net/mlx4/cmd.c
@@ -599,7 +599,7 @@ static struct mlx4_cmd_info {
 
 	/* Ethernet specific commands */
 	{MLX4_CMD_SET_VLAN_FLTR,   1, 0, 0, NULL, NULL}, /* need wrapper */
-	{MLX4_CMD_SET_MCAST_FLTR,  0, 0, 0, NULL, NULL}, /* need wrapper */
+	{MLX4_CMD_SET_MCAST_FLTR,  0, 0, 0, NULL, mlx4_SET_MCAST_FLTR_wrapper},
 	{MLX4_CMD_DUMP_ETH_STATS,  0, 1, 0, NULL, NULL}, /* need wrapper */
 };
 
@@ -822,7 +822,7 @@ static void mlx4_master_poll_comm(struct work_struct *work)
 int mlx4_multi_func_init(struct mlx4_dev *dev)
 {
 	struct mlx4_priv *priv = mlx4_priv(dev);
-	int i;
+	int i, port;
 
 	priv->mfunc.vhcr = dma_alloc_coherent(&(dev->pdev->dev), PAGE_SIZE,
 					    &priv->mfunc.vhcr_dma,
@@ -855,6 +855,8 @@ int mlx4_multi_func_init(struct mlx4_dev *dev)
 
 		for (i = 0; i < dev->num_slaves; ++i) {
 			priv->mfunc.master.slave_state[i].last_cmd = MLX4_COMM_CMD_RESET;
+			for (port = 1; port <= MLX4_MAX_PORTS; port++)
+				INIT_LIST_HEAD(&priv->mfunc.master.slave_state[i].mcast_filters[port]);
 			spin_lock_init(&priv->mfunc.master.slave_state[i].lock);
 		}
 
diff --git a/drivers/net/mlx4/en_port.c b/drivers/net/mlx4/en_port.c
index c7aa86e..6dc07c9 100644
--- a/drivers/net/mlx4/en_port.c
+++ b/drivers/net/mlx4/en_port.c
@@ -41,13 +41,6 @@
 #include "mlx4_en.h"
 
 
-int mlx4_SET_MCAST_FLTR(struct mlx4_dev *dev, u8 port,
-			u64 mac, u64 clear, u8 mode)
-{
-	return mlx4_cmd(dev, (mac | (clear << 63)), port, mode,
-			MLX4_CMD_SET_MCAST_FLTR, MLX4_CMD_TIME_CLASS_B);
-}
-
 int mlx4_SET_VLAN_FLTR(struct mlx4_dev *dev, u8 port, struct vlan_group *grp)
 {
 	struct mlx4_cmd_mailbox *mailbox;
diff --git a/drivers/net/mlx4/mlx4.h b/drivers/net/mlx4/mlx4.h
index 1213de6..7040671 100644
--- a/drivers/net/mlx4/mlx4.h
+++ b/drivers/net/mlx4/mlx4.h
@@ -216,6 +216,11 @@ struct mlx4_slave_eqe {
 	u32 param;
 };
 
+struct mlx4_mcast_entry {
+	struct list_head list;
+	u64 addr;
+};
+
 struct mlx4_slave_state {
 	u8 comm_toggle;
 	u8 last_cmd;
@@ -224,6 +229,7 @@ struct mlx4_slave_state {
 	u16 mtu[MLX4_MAX_PORTS + 1];
 	__be32 ib_cap_mask[MLX4_MAX_PORTS + 1];
 	struct mlx4_slave_eqe eq[MLX4_MFUNC_MAX_EQES];
+	struct list_head mcast_filters[MLX4_MAX_PORTS + 1];
 	u16 eq_pi;
 	u16 eq_ci;
 	int sqp_start;
@@ -234,6 +240,7 @@ struct mlx4_mfunc_master_ctx {
 	struct mlx4_slave_state *slave_state;
 	int			init_port_ref[MLX4_MAX_PORTS + 1];
 	u16			max_mtu[MLX4_MAX_PORTS + 1];
+	int			disable_mcast_ref[MLX4_MAX_PORTS + 1];
 };
 
 struct mlx4_vhcr {
@@ -550,5 +557,8 @@ int mlx4_GET_SLAVE_SQP_wrapper(struct mlx4_dev *dev, int slave, struct mlx4_vhcr
 int mlx4_MCAST_wrapper(struct mlx4_dev *dev, int slave, struct mlx4_vhcr *vhcr,
 						     struct mlx4_cmd_mailbox *inbox,
 						     struct mlx4_cmd_mailbox *outbox);
+int mlx4_SET_MCAST_FLTR_wrapper(struct mlx4_dev *dev, int slave, struct mlx4_vhcr *vhcr,
+				struct mlx4_cmd_mailbox *inbox,
+				struct mlx4_cmd_mailbox *outbox);
 
 #endif /* MLX4_H */
diff --git a/drivers/net/mlx4/mlx4_en.h b/drivers/net/mlx4/mlx4_en.h
index 6e0c9ed..b4731d5 100644
--- a/drivers/net/mlx4/mlx4_en.h
+++ b/drivers/net/mlx4/mlx4_en.h
@@ -556,7 +556,6 @@ void mlx4_en_release_rss_steer(struct mlx4_en_priv *priv);
 int mlx4_en_free_tx_buf(struct net_device *dev, struct mlx4_en_tx_ring *ring);
 void mlx4_en_rx_irq(struct mlx4_cq *mcq);
 
-int mlx4_SET_MCAST_FLTR(struct mlx4_dev *dev, u8 port, u64 mac, u64 clear, u8 mode);
 int mlx4_SET_VLAN_FLTR(struct mlx4_dev *dev, u8 port, struct vlan_group *grp);
 int mlx4_SET_PORT_general(struct mlx4_dev *dev, u8 port, int mtu,
 			  u8 pptx, u8 pfctx, u8 pprx, u8 pfcrx);
diff --git a/drivers/net/mlx4/port.c b/drivers/net/mlx4/port.c
index 7317d0f..1bc527c 100644
--- a/drivers/net/mlx4/port.c
+++ b/drivers/net/mlx4/port.c
@@ -491,3 +491,128 @@ int mlx4_SET_PORT(struct mlx4_dev *dev, u8 port)
 	mlx4_free_cmd_mailbox(dev, mailbox);
 	return err;
 }
+
+int mlx4_SET_MCAST_FLTR_wrapper(struct mlx4_dev *dev, int slave, struct mlx4_vhcr *vhcr,
+				struct mlx4_cmd_mailbox *inbox,
+				struct mlx4_cmd_mailbox *outbox)
+{
+	struct mlx4_priv *priv = mlx4_priv(dev);
+	int port = vhcr->in_modifier;
+	int err = 0;
+	u64 addr = vhcr->in_param & 0xffffffffffffULL;
+	u64 clear = vhcr->in_param >> 63;
+	struct mlx4_mcast_entry *entry, *tmp;
+	struct mlx4_slave_state *s_state = &priv->mfunc.master.slave_state[slave];
+	int i;
+
+	switch (vhcr->op_modifier) {
+	case MLX4_MCAST_DISABLE:
+		/* The multicast filter is disabled only once,
+		 * If some other function already done it, operation
+		 * is ignored */
+		if (!(priv->mfunc.master.disable_mcast_ref[port]++))
+			err = mlx4_cmd(dev, 0, port, MLX4_MCAST_DISABLE,
+					MLX4_CMD_SET_MCAST_FLTR,
+					MLX4_CMD_TIME_CLASS_B);
+		break;
+	case MLX4_MCAST_ENABLE:
+		/* We enable the muticast filter only if all functions
+		 * have the filter enabled */
+		if (!(--priv->mfunc.master.disable_mcast_ref[port]))
+			err = mlx4_cmd(dev, 0, port, MLX4_MCAST_ENABLE,
+					MLX4_CMD_SET_MCAST_FLTR,
+					MLX4_CMD_TIME_CLASS_B);
+		break;
+	case MLX4_MCAST_CONFIG:
+		if (clear) {
+			/* Disable the muticast filter while updating it */
+			if (!priv->mfunc.master.disable_mcast_ref[port]) {
+				err = mlx4_cmd(dev, 0, port, MLX4_MCAST_DISABLE,
+						MLX4_CMD_SET_MCAST_FLTR,
+						MLX4_CMD_TIME_CLASS_B);
+				if (err) {
+					mlx4_warn(dev, "Failed to disable multicast "
+						       "filter\n");
+					goto out;
+				}
+			}
+			/* Clear the multicast filter */
+			err = mlx4_cmd(dev, clear << 63, port,
+				       MLX4_MCAST_CONFIG,
+				       MLX4_CMD_SET_MCAST_FLTR,
+				       MLX4_CMD_TIME_CLASS_B);
+			if (err) {
+				mlx4_warn(dev, "Failed clearing the multicast filter\n");
+				goto out;
+			}
+
+			/* Clear the multicast addresses for the given slave */
+			list_for_each_entry_safe(entry, tmp,
+						 &s_state->mcast_filters[port],
+						 list) {
+				list_del(&entry->list);
+				kfree(entry);
+			}
+
+			/* Assign all the multicast addresses that still exist */
+			for (i = 0; i < dev->num_slaves; i++) {
+				list_for_each_entry(entry,
+					&priv->mfunc.master.slave_state[slave].mcast_filters[port],
+					list) {
+					if (mlx4_cmd(dev, entry->addr, port,
+						     MLX4_MCAST_CONFIG,
+						     MLX4_CMD_SET_MCAST_FLTR,
+						     MLX4_CMD_TIME_CLASS_B))
+						mlx4_warn(dev, "Failed to reconfigure "
+							  "multicast address: 0x%llx\n",
+							  entry->addr);
+				}
+			}
+			/* Enable the filter */
+			if (!priv->mfunc.master.disable_mcast_ref[port]) {
+				err = mlx4_cmd(dev, 0, port, MLX4_MCAST_ENABLE,
+						MLX4_CMD_SET_MCAST_FLTR,
+						MLX4_CMD_TIME_CLASS_B);
+				if (err) {
+					mlx4_warn(dev, "Failed to enable multicast "
+						       "filter\n");
+					goto out;
+				}
+			}
+		}
+		/* Add the new address if exists */
+		if (addr) {
+			entry = kzalloc(sizeof (struct mlx4_mcast_entry),
+					GFP_KERNEL);
+			if (!entry) {
+				mlx4_warn(dev, "Failed to allocate entry for "
+					       "muticast address\n");
+				err = -ENOMEM;
+				goto out;
+			}
+			INIT_LIST_HEAD(&entry->list);
+			entry->addr = addr;
+			list_add_tail(&entry->list, &s_state->mcast_filters[port]);
+			err = mlx4_cmd(dev, addr, port, MLX4_MCAST_CONFIG,
+				       MLX4_CMD_SET_MCAST_FLTR,
+				       MLX4_CMD_TIME_CLASS_B);
+			if (err)
+				mlx4_warn(dev, "Failed to add the new address:"
+					       "0x%llx\n", addr);
+		}
+		break;
+	default:
+		mlx4_warn(dev, "SET_MCAST_FILTER called with illegal modifier\n");
+		err = -EINVAL;
+	}
+out:
+	return err;
+}
+
+int mlx4_SET_MCAST_FLTR(struct mlx4_dev *dev, u8 port,
+			u64 mac, u64 clear, u8 mode)
+{
+	return mlx4_cmd(dev, (mac | (clear << 63)), port, mode,
+			MLX4_CMD_SET_MCAST_FLTR, MLX4_CMD_TIME_CLASS_B);
+}
+EXPORT_SYMBOL(mlx4_SET_MCAST_FLTR);
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index 3d74198..10a5fb8 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -498,6 +498,7 @@ int mlx4_multicast_attach(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
 			  int block_mcast_loopback, enum mlx4_protocol prot);
 int mlx4_multicast_detach(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
 			  enum mlx4_protocol prot);
+int mlx4_SET_MCAST_FLTR(struct mlx4_dev *dev, u8 port, u64 mac, u64 clear, u8 mode);
 
 int mlx4_register_mac(struct mlx4_dev *dev, u8 port, u64 mac, int *qpn);
 void mlx4_unregister_mac(struct mlx4_dev *dev, u8 port, int qpn);
-- 
1.6.1.3




