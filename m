From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 18/23 v3] mlx4_core: Managing common port filters by master
 function
Date: Thu, 04 Feb 2010 17:56:50 +0200
Message-ID: <4B6AEE42.3080900@mellanox.co.il>
References: <49BFC313.1030901@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: general@lists.openfabrics.org, netdev@vger.kernel.org,
	liranl@mellanox.co.il, tziporet@mellanox.co.il
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:49866 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932870Ab0BDP4x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Feb 2010 10:56:53 -0500
In-Reply-To: <49BFC313.1030901@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Multicast filter configuration is done by the master,
that manages the filter which is common for all the functions.
The master holds a list of multicast addresses for all the
slaves, and adds them to the filter.
In case some slave wishes to flush the filter, only his addresses
are removed.
The VLAN filter is a bitwise OR of all the VLAN filters for all functions,
the result is a false-positive filter.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/cmd.c      |   41 ++++++--
 drivers/net/mlx4/en_port.c  |   42 --------
 drivers/net/mlx4/en_port.h  |    5 -
 drivers/net/mlx4/mlx4.h     |   19 ++++
 drivers/net/mlx4/mlx4_en.h  |    1 -
 drivers/net/mlx4/port.c     |  221 +++++++++++++++++++++++++++++++++++++++++++
 include/linux/mlx4/device.h |    1 +
 7 files changed, 273 insertions(+), 57 deletions(-)

diff --git a/drivers/net/mlx4/cmd.c b/drivers/net/mlx4/cmd.c
index f9e8164..e437d74 100644
--- a/drivers/net/mlx4/cmd.c
+++ b/drivers/net/mlx4/cmd.c
@@ -938,7 +938,7 @@ static struct mlx4_cmd_info {
 		.has_outbox = false,
 		.out_is_imm = false,
 		.verify = NULL,
-		.wrapper = NULL /* need wrapper*/
+		.wrapper = mlx4_SET_VLAN_FLTR_wrapper
 	},
 	{
 		.opcode = MLX4_CMD_SET_MCAST_FLTR,
@@ -946,7 +946,7 @@ static struct mlx4_cmd_info {
 		.has_outbox = false,
 		.out_is_imm = false,
 		.verify = NULL,
-		.wrapper = NULL /* need wrapper*/
+		.wrapper = mlx4_SET_MCAST_FLTR_wrapper
 	},
 	{
 		.opcode = MLX4_CMD_DUMP_ETH_STATS,
@@ -1177,7 +1177,8 @@ static void mlx4_master_poll_comm(struct work_struct *work)
 int mlx4_multi_func_init(struct mlx4_dev *dev)
 {
 	struct mlx4_priv *priv = mlx4_priv(dev);
-	int i;
+	struct mlx4_slave_state *s_state;
+	int i, port;
 
 	priv->mfunc.vhcr = dma_alloc_coherent(&(dev->pdev->dev), PAGE_SIZE,
 					    &priv->mfunc.vhcr_dma,
@@ -1209,16 +1210,27 @@ int mlx4_multi_func_init(struct mlx4_dev *dev)
 			goto err_comm;
 
 		for (i = 0; i < dev->num_slaves; ++i) {
-			priv->mfunc.master.slave_state[i].last_cmd = MLX4_COMM_CMD_RESET;
-			spin_lock_init(&priv->mfunc.master.slave_state[i].lock);
+			s_state = &priv->mfunc.master.slave_state[i];
+			s_state->last_cmd = MLX4_COMM_CMD_RESET;
+			for (port = 1; port <= MLX4_MAX_PORTS; port++) {
+				s_state->vlan_filter[port] =
+					kzalloc(sizeof(struct mlx4_vlan_fltr),
+						GFP_KERNEL);
+				if (!s_state->vlan_filter[port]) {
+					if (--port)
+						kfree(s_state->vlan_filter[port]);
+					goto err_slaves;
+				}
+				INIT_LIST_HEAD(&s_state->mcast_filters[port]);
+			}
+			spin_lock_init(&s_state->lock);
 		}
 
 		INIT_DELAYED_WORK(&priv->mfunc.comm_work, mlx4_master_poll_comm);
 		priv->mfunc.comm_wq = create_singlethread_workqueue("mlx4_comm");
-		if (!priv->mfunc.comm_wq) {
-			kfree(priv->mfunc.master.slave_state);
-			goto err_comm;
-		}
+		if (!priv->mfunc.comm_wq)
+			goto err_slaves;
+
 	} else {
 		priv->cmd.comm_toggle = 0;
 		INIT_DELAYED_WORK(&priv->mfunc.comm_work, mlx4_slave_async_eq_poll);
@@ -1228,6 +1240,12 @@ int mlx4_multi_func_init(struct mlx4_dev *dev)
 	}
 	return 0;
 
+err_slaves:
+	while (--i) {
+		for (port = 1; port <= MLX4_MAX_PORTS; port++)
+			kfree(priv->mfunc.master.slave_state[i].vlan_filter[port]);
+	}
+	kfree(priv->mfunc.master.slave_state);
 err_comm:
 	iounmap(priv->mfunc.comm);
 err_vhcr:
@@ -1276,9 +1294,14 @@ err_hcr:
 void mlx4_multi_func_cleanup(struct mlx4_dev *dev)
 {
 	struct mlx4_priv *priv = mlx4_priv(dev);
+	int i, port;
 
 	if (priv->mfunc.vhcr) {
 		destroy_workqueue(priv->mfunc.comm_wq);
+		for (i = 0; i < dev->num_slaves; i++) {
+			for (port = 1; port <= MLX4_MAX_PORTS; port++)
+				kfree(priv->mfunc.master.slave_state[i].vlan_filter[port]);
+		}
 		kfree(priv->mfunc.master.slave_state);
 		iounmap(priv->mfunc.comm);
 		dma_free_coherent(&(dev->pdev->dev), PAGE_SIZE,
diff --git a/drivers/net/mlx4/en_port.c b/drivers/net/mlx4/en_port.c
index 2d55c1a..b099f81 100644
--- a/drivers/net/mlx4/en_port.c
+++ b/drivers/net/mlx4/en_port.c
@@ -41,48 +41,6 @@
 #include "mlx4_en.h"
 
 
-int mlx4_SET_MCAST_FLTR(struct mlx4_dev *dev, u8 port,
-			u64 mac, u64 clear, u8 mode)
-{
-	return mlx4_cmd(dev, (mac | (clear << 63)), port, mode,
-			MLX4_CMD_SET_MCAST_FLTR, MLX4_CMD_TIME_CLASS_B);
-}
-
-int mlx4_SET_VLAN_FLTR(struct mlx4_dev *dev, u8 port, struct vlan_group *grp)
-{
-	struct mlx4_cmd_mailbox *mailbox;
-	struct mlx4_set_vlan_fltr_mbox *filter;
-	int i;
-	int j;
-	int index = 0;
-	u32 entry;
-	int err = 0;
-
-	mailbox = mlx4_alloc_cmd_mailbox(dev);
-	if (IS_ERR(mailbox))
-		return PTR_ERR(mailbox);
-
-	filter = mailbox->buf;
-	if (grp) {
-		memset(filter, 0, sizeof *filter);
-		for (i = VLAN_FLTR_SIZE - 1; i >= 0; i--) {
-			entry = 0;
-			for (j = 0; j < 32; j++)
-				if (vlan_group_get_device(grp, index++))
-					entry |= 1 << j;
-			filter->entry[i] = cpu_to_be32(entry);
-		}
-	} else {
-		/* When no vlans are configured we block all vlans */
-		memset(filter, 0, sizeof(*filter));
-	}
-	err = mlx4_cmd(dev, mailbox->dma, port, 0, MLX4_CMD_SET_VLAN_FLTR,
-		       MLX4_CMD_TIME_CLASS_B);
-	mlx4_free_cmd_mailbox(dev, mailbox);
-	return err;
-}
-
-
 int mlx4_SET_PORT_general(struct mlx4_dev *dev, u8 port, int mtu,
 			  u8 pptx, u8 pfctx, u8 pprx, u8 pfcrx)
 {
diff --git a/drivers/net/mlx4/en_port.h b/drivers/net/mlx4/en_port.h
index f7a367b..8b221d6 100644
--- a/drivers/net/mlx4/en_port.h
+++ b/drivers/net/mlx4/en_port.h
@@ -77,11 +77,6 @@ struct mlx4_set_port_rqp_calc_context {
 	__be32 mcast;
 };
 
-#define VLAN_FLTR_SIZE	128
-struct mlx4_set_vlan_fltr_mbox {
-	__be32 entry[VLAN_FLTR_SIZE];
-};
-
 
 enum {
 	MLX4_MCAST_CONFIG       = 0,
diff --git a/drivers/net/mlx4/mlx4.h b/drivers/net/mlx4/mlx4.h
index 3417888..74543d7 100644
--- a/drivers/net/mlx4/mlx4.h
+++ b/drivers/net/mlx4/mlx4.h
@@ -224,6 +224,16 @@ struct mlx4_slave_eqe {
 	u32 param;
 };
 
+struct mlx4_mcast_entry {
+	struct list_head list;
+	u64 addr;
+};
+
+#define VLAN_FLTR_SIZE	128
+struct mlx4_vlan_fltr {
+	__be32 entry[VLAN_FLTR_SIZE];
+};
+
 struct mlx4_slave_state {
 	u8 comm_toggle;
 	u8 last_cmd;
@@ -232,6 +242,8 @@ struct mlx4_slave_state {
 	u16 mtu[MLX4_MAX_PORTS + 1];
 	__be32 ib_cap_mask[MLX4_MAX_PORTS + 1];
 	struct mlx4_slave_eqe eq[MLX4_MFUNC_MAX_EQES];
+	struct list_head mcast_filters[MLX4_MAX_PORTS + 1];
+	struct mlx4_vlan_fltr *vlan_filter[MLX4_MAX_PORTS + 1];
 	u16 eq_pi;
 	u16 eq_ci;
 	int sqp_start;
@@ -242,6 +254,7 @@ struct mlx4_mfunc_master_ctx {
 	struct mlx4_slave_state *slave_state;
 	int			init_port_ref[MLX4_MAX_PORTS + 1];
 	u16			max_mtu[MLX4_MAX_PORTS + 1];
+	int			disable_mcast_ref[MLX4_MAX_PORTS + 1];
 };
 
 struct mlx4_vhcr {
@@ -559,5 +572,11 @@ int mlx4_GET_SLAVE_SQP_wrapper(struct mlx4_dev *dev, int slave, struct mlx4_vhcr
 int mlx4_MCAST_wrapper(struct mlx4_dev *dev, int slave, struct mlx4_vhcr *vhcr,
 						     struct mlx4_cmd_mailbox *inbox,
 						     struct mlx4_cmd_mailbox *outbox);
+int mlx4_SET_MCAST_FLTR_wrapper(struct mlx4_dev *dev, int slave, struct mlx4_vhcr *vhcr,
+				struct mlx4_cmd_mailbox *inbox,
+				struct mlx4_cmd_mailbox *outbox);
+int mlx4_SET_VLAN_FLTR_wrapper(struct mlx4_dev *dev, int slave, struct mlx4_vhcr *vhcr,
+				struct mlx4_cmd_mailbox *inbox,
+				struct mlx4_cmd_mailbox *outbox);
 
 #endif /* MLX4_H */
diff --git a/drivers/net/mlx4/mlx4_en.h b/drivers/net/mlx4/mlx4_en.h
index 5ea438e..809c45d 100644
--- a/drivers/net/mlx4/mlx4_en.h
+++ b/drivers/net/mlx4/mlx4_en.h
@@ -554,7 +554,6 @@ void mlx4_en_release_rss_steer(struct mlx4_en_priv *priv);
 int mlx4_en_free_tx_buf(struct net_device *dev, struct mlx4_en_tx_ring *ring);
 void mlx4_en_rx_irq(struct mlx4_cq *mcq);
 
-int mlx4_SET_MCAST_FLTR(struct mlx4_dev *dev, u8 port, u64 mac, u64 clear, u8 mode);
 int mlx4_SET_VLAN_FLTR(struct mlx4_dev *dev, u8 port, struct vlan_group *grp);
 int mlx4_SET_PORT_general(struct mlx4_dev *dev, u8 port, int mtu,
 			  u8 pptx, u8 pfctx, u8 pprx, u8 pfcrx);
diff --git a/drivers/net/mlx4/port.c b/drivers/net/mlx4/port.c
index 5654fff..1bec155 100644
--- a/drivers/net/mlx4/port.c
+++ b/drivers/net/mlx4/port.c
@@ -32,6 +32,7 @@
 
 #include <linux/errno.h>
 #include <linux/if_ether.h>
+#include <linux/if_vlan.h>
 
 #include <linux/mlx4/cmd.h>
 
@@ -491,3 +492,223 @@ int mlx4_SET_PORT(struct mlx4_dev *dev, u8 port)
 	mlx4_free_cmd_mailbox(dev, mailbox);
 	return err;
 }
+
+static int mlx4_common_set_mcast_fltr(struct mlx4_dev *dev, int function,
+				      int port, u64 addr, u64 clear, u8 mode)
+{
+	struct mlx4_priv *priv = mlx4_priv(dev);
+	int err = 0;
+	struct mlx4_mcast_entry *entry, *tmp;
+	struct mlx4_slave_state *s_state = &priv->mfunc.master.slave_state[function];
+	int i;
+
+	switch (mode) {
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
+					&priv->mfunc.master.slave_state[function].mcast_filters[port],
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
+int mlx4_SET_MCAST_FLTR_wrapper(struct mlx4_dev *dev, int slave, struct mlx4_vhcr *vhcr,
+				struct mlx4_cmd_mailbox *inbox,
+				struct mlx4_cmd_mailbox *outbox)
+{
+	int port = vhcr->in_modifier;
+	u64 addr = vhcr->in_param & 0xffffffffffffULL;
+	u64 clear = vhcr->in_param >> 63;
+	u8 mode = vhcr->op_modifier;
+
+	return mlx4_common_set_mcast_fltr(dev, slave, port, addr, clear, mode);
+}
+
+int mlx4_SET_MCAST_FLTR(struct mlx4_dev *dev, u8 port,
+			u64 mac, u64 clear, u8 mode)
+{
+	if (mlx4_is_master(dev))
+		return mlx4_common_set_mcast_fltr(dev, dev->caps.function,
+						  port, mac, clear, mode);
+	else
+		return mlx4_cmd(dev, (mac | (clear << 63)), port, mode,
+				MLX4_CMD_SET_MCAST_FLTR, MLX4_CMD_TIME_CLASS_B);
+}
+EXPORT_SYMBOL(mlx4_SET_MCAST_FLTR);
+
+
+static int mlx4_common_set_vlan_fltr(struct mlx4_dev *dev, int function,
+				     int port, void *buf)
+{
+	struct mlx4_cmd_mailbox *mailbox;
+	struct mlx4_priv *priv = mlx4_priv(dev);
+	struct mlx4_vlan_fltr *filter;
+	struct mlx4_slave_state *s_state = &priv->mfunc.master.slave_state[function];
+	int i, j, err;
+
+	mailbox = mlx4_alloc_cmd_mailbox(dev);
+	if (IS_ERR(mailbox))
+		return PTR_ERR(mailbox);
+
+	/* Update slave's Vlan filter */
+	memcpy(s_state->vlan_filter[port]->entry, buf,
+	       sizeof(struct mlx4_vlan_fltr));
+
+	/* We configure the Vlan filter to allow the vlans of
+	 * all slaves */
+	filter = mailbox->buf;
+	memset(filter, 0, sizeof(*filter));
+	for (i = VLAN_FLTR_SIZE - 1; i >= 0; i--) {
+		for (j = 0; j < dev->num_slaves; j++) {
+			s_state = &priv->mfunc.master.slave_state[j];
+			filter->entry[i] |= s_state->vlan_filter[port]->entry[i];
+		}
+	}
+	err = mlx4_cmd(dev, mailbox->dma, port, 0, MLX4_CMD_SET_VLAN_FLTR,
+		       MLX4_CMD_TIME_CLASS_B);
+	mlx4_free_cmd_mailbox(dev, mailbox);
+	return err;
+}
+
+int mlx4_SET_VLAN_FLTR_wrapper(struct mlx4_dev *dev, int slave, struct mlx4_vhcr *vhcr,
+			       struct mlx4_cmd_mailbox *inbox,
+			       struct mlx4_cmd_mailbox *outbox)
+{
+	return mlx4_common_set_vlan_fltr(dev, slave, vhcr->in_modifier,
+					 inbox->buf);
+}
+
+
+int mlx4_SET_VLAN_FLTR(struct mlx4_dev *dev, u8 port, struct vlan_group *grp)
+{
+	struct mlx4_cmd_mailbox *mailbox;
+	struct mlx4_vlan_fltr *filter;
+	int i;
+	int j;
+	int index = 0;
+	u32 entry;
+	int err = 0;
+
+	mailbox = mlx4_alloc_cmd_mailbox(dev);
+	if (IS_ERR(mailbox))
+		return PTR_ERR(mailbox);
+
+	filter = mailbox->buf;
+	if (grp) {
+		memset(filter, 0, sizeof *filter);
+		for (i = VLAN_FLTR_SIZE - 1; i >= 0; i--) {
+			entry = 0;
+			for (j = 0; j < 32; j++)
+				if (vlan_group_get_device(grp, index++))
+					entry |= 1 << j;
+			filter->entry[i] = cpu_to_be32(entry);
+		}
+	} else {
+		/* When no vlans are configured we block all vlans */
+		memset(filter, 0, sizeof(*filter));
+	}
+	if (mlx4_is_master(dev))
+		err = mlx4_common_set_vlan_fltr(dev, dev->caps.function,
+						port, mailbox->buf);
+	else
+		err = mlx4_cmd(dev, mailbox->dma, port, 0, MLX4_CMD_SET_VLAN_FLTR,
+			       MLX4_CMD_TIME_CLASS_B);
+
+	mlx4_free_cmd_mailbox(dev, mailbox);
+	return err;
+}
+EXPORT_SYMBOL(mlx4_SET_VLAN_FLTR);
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index 9bdfbab..8e51af5 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -505,6 +505,7 @@ int mlx4_multicast_attach(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
 			  int block_mcast_loopback, enum mlx4_protocol prot);
 int mlx4_multicast_detach(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
 			  enum mlx4_protocol prot);
+int mlx4_SET_MCAST_FLTR(struct mlx4_dev *dev, u8 port, u64 mac, u64 clear, u8 mode);
 
 int mlx4_register_mac(struct mlx4_dev *dev, u8 port, u64 mac, int *qpn);
 void mlx4_unregister_mac(struct mlx4_dev *dev, u8 port, int qpn);
-- 
1.6.1.3


