From: Yevgeny Petrilin <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
Subject: [PATCH net-next V2 15/21] mlx4: Ethernet port management modifications
Date: Tue, 13 Dec 2011 16:16:21 +0200
Message-ID: <4EE75E35.10608@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>, <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>,
	<liranl-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>, <jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>,
	<eugenia-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
To: <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Eugenia Emantayev <eugenia-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>

The physical port is now common to the PF and VFs.
The port resources and configuration is managed by the PF, VFs can
only influence the MTU of the port, it is set as max among all functions,
Each function allocates RX buffers of required size to meet it's MTU enforcement.
Port management code was moved to mlx4_core, as the mlx4_en module is
virtualization unaware

Move handling qp functionality to mlx4_get_eth_qp/mlx4_put_eth_qp
including reserve/release range and add/release unicast steering.
Let mlx4_register/unregister_mac deal only with MAC (un)registration.

Signed-off-by: Eugenia Emantayev <eugenia-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
Signed-off-by: Yevgeny Petrilin <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
---
 drivers/net/ethernet/mellanox/mlx4/cmd.c           |   37 ++
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c     |   32 +-
 drivers/net/ethernet/mellanox/mlx4/en_port.c       |   77 ---
 drivers/net/ethernet/mellanox/mlx4/en_port.h       |   37 --
 drivers/net/ethernet/mellanox/mlx4/mcg.c           |    4 +-
 drivers/net/ethernet/mellanox/mlx4/mlx4.h          |   53 ++
 drivers/net/ethernet/mellanox/mlx4/port.c          |  606 ++++++++++++++++----
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |   33 +-
 include/linux/mlx4/device.h                        |   12 +-
 9 files changed, 630 insertions(+), 261 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/ethernet/mellanox/mlx4/cmd.c
index 0f2069d..8e6e4b2 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
@@ -654,6 +654,15 @@ static struct mlx4_cmd_info cmd_info[] = {
 		.wrapper = mlx4_QUERY_PORT_wrapper
 	},
 	{
+		.opcode = MLX4_CMD_SET_PORT,
+		.has_inbox = true,
+		.has_outbox = false,
+		.out_is_imm = false,
+		.encode_slave_id = false,
+		.verify = NULL,
+		.wrapper = mlx4_SET_PORT_wrapper
+	},
+	{
 		.opcode = MLX4_CMD_MAP_EQ,
 		.has_inbox = false,
 		.has_outbox = false,
@@ -1005,6 +1014,34 @@ static struct mlx4_cmd_info cmd_info[] = {
 		.verify = NULL,
 		.wrapper = mlx4_PROMISC_wrapper
 	},
+	/* Ethernet specific commands */
+	{
+		.opcode = MLX4_CMD_SET_VLAN_FLTR,
+		.has_inbox = true,
+		.has_outbox = false,
+		.out_is_imm = false,
+		.encode_slave_id = false,
+		.verify = NULL,
+		.wrapper = mlx4_SET_VLAN_FLTR_wrapper
+	},
+	{
+		.opcode = MLX4_CMD_SET_MCAST_FLTR,
+		.has_inbox = false,
+		.has_outbox = false,
+		.out_is_imm = false,
+		.encode_slave_id = false,
+		.verify = NULL,
+		.wrapper = mlx4_SET_MCAST_FLTR_wrapper
+	},
+	{
+		.opcode = MLX4_CMD_DUMP_ETH_STATS,
+		.has_inbox = false,
+		.has_outbox = true,
+		.out_is_imm = false,
+		.encode_slave_id = false,
+		.verify = NULL,
+		.wrapper = mlx4_DUMP_ETH_STATS_wrapper
+	},
 	{
 		.opcode = MLX4_CMD_INFORM_FLR_DONE,
 		.has_inbox = false,
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 2083f3b..1db6fea 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -136,7 +136,7 @@ static void mlx4_en_do_set_mac(struct work_struct *work)
 	if (priv->port_up) {
 		/* Remove old MAC and insert the new one */
 		err = mlx4_replace_mac(mdev->dev, priv->port,
-				       priv->base_qpn, priv->mac, 0);
+				       priv->base_qpn, priv->mac);
 		if (err)
 			en_err(priv, "Failed changing HW MAC address\n");
 	} else
@@ -207,6 +207,16 @@ static void mlx4_en_do_set_multicast(struct work_struct *work)
 		goto out;
 	}
 
+	if (!netif_carrier_ok(dev)) {
+		if (!mlx4_en_QUERY_PORT(mdev, priv->port)) {
+			if (priv->port_state.link_state) {
+				priv->last_link_state = MLX4_DEV_EVENT_PORT_UP;
+				netif_carrier_on(dev);
+				en_dbg(LINK, priv, "Link Up\n");
+			}
+		}
+	}
+
 	/*
 	 * Promsicuous mode: disable all filters
 	 */
@@ -602,12 +612,12 @@ int mlx4_en_start_port(struct net_device *dev)
 		++rx_index;
 	}
 
-	/* Set port mac number */
-	en_dbg(DRV, priv, "Setting mac for port %d\n", priv->port);
-	err = mlx4_register_mac(mdev->dev, priv->port,
-				priv->mac, &priv->base_qpn, 0);
+	/* Set qp number */
+	en_dbg(DRV, priv, "Getting qp number for port %d\n", priv->port);
+	err = mlx4_get_eth_qp(mdev->dev, priv->port,
+				priv->mac, &priv->base_qpn);
 	if (err) {
-		en_err(priv, "Failed setting port mac\n");
+		en_err(priv, "Failed getting eth qp\n");
 		goto cq_err;
 	}
 	mdev->mac_removed[priv->port] = 0;
@@ -702,7 +712,7 @@ tx_err:
 
 	mlx4_en_release_rss_steer(priv);
 mac_err:
-	mlx4_unregister_mac(mdev->dev, priv->port, priv->base_qpn);
+	mlx4_put_eth_qp(mdev->dev, priv->port, priv->mac, priv->base_qpn);
 cq_err:
 	while (rx_index--)
 		mlx4_en_deactivate_cq(priv, &priv->rx_cq[rx_index]);
@@ -748,10 +758,6 @@ void mlx4_en_stop_port(struct net_device *dev)
 	/* Flush multicast filter */
 	mlx4_SET_MCAST_FLTR(mdev->dev, priv->port, 0, 1, MLX4_MCAST_CONFIG);
 
-	/* Unregister Mac address for the port */
-	mlx4_unregister_mac(mdev->dev, priv->port, priv->base_qpn);
-	mdev->mac_removed[priv->port] = 1;
-
 	/* Free TX Rings */
 	for (i = 0; i < priv->tx_ring_num; i++) {
 		mlx4_en_deactivate_tx_ring(priv, &priv->tx_ring[i]);
@@ -765,6 +771,10 @@ void mlx4_en_stop_port(struct net_device *dev)
 	/* Free RSS qps */
 	mlx4_en_release_rss_steer(priv);
 
+	/* Unregister Mac address for the port */
+	mlx4_put_eth_qp(mdev->dev, priv->port, priv->mac, priv->base_qpn);
+	mdev->mac_removed[priv->port] = 1;
+
 	/* Free RX Rings */
 	for (i = 0; i < priv->rx_ring_num; i++) {
 		mlx4_en_deactivate_rx_ring(priv, &priv->rx_ring[i]);
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_port.c b/drivers/net/ethernet/mellanox/mlx4/en_port.c
index ae120ef..3317914 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_port.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_port.c
@@ -41,14 +41,6 @@
 #include "mlx4_en.h"
 
 
-int mlx4_SET_MCAST_FLTR(struct mlx4_dev *dev, u8 port,
-			u64 mac, u64 clear, u8 mode)
-{
-	return mlx4_cmd(dev, (mac | (clear << 63)), port, mode,
-			MLX4_CMD_SET_MCAST_FLTR, MLX4_CMD_TIME_CLASS_B,
-			MLX4_CMD_WRAPPED);
-}
-
 int mlx4_SET_VLAN_FLTR(struct mlx4_dev *dev, struct mlx4_en_priv *priv)
 {
 	struct mlx4_cmd_mailbox *mailbox;
@@ -78,75 +70,6 @@ int mlx4_SET_VLAN_FLTR(struct mlx4_dev *dev, struct mlx4_en_priv *priv)
 	return err;
 }
 
-
-int mlx4_SET_PORT_general(struct mlx4_dev *dev, u8 port, int mtu,
-			  u8 pptx, u8 pfctx, u8 pprx, u8 pfcrx)
-{
-	struct mlx4_cmd_mailbox *mailbox;
-	struct mlx4_set_port_general_context *context;
-	int err;
-	u32 in_mod;
-
-	mailbox = mlx4_alloc_cmd_mailbox(dev);
-	if (IS_ERR(mailbox))
-		return PTR_ERR(mailbox);
-	context = mailbox->buf;
-	memset(context, 0, sizeof *context);
-
-	context->flags = SET_PORT_GEN_ALL_VALID;
-	context->mtu = cpu_to_be16(mtu);
-	context->pptx = (pptx * (!pfctx)) << 7;
-	context->pfctx = pfctx;
-	context->pprx = (pprx * (!pfcrx)) << 7;
-	context->pfcrx = pfcrx;
-
-	in_mod = MLX4_SET_PORT_GENERAL << 8 | port;
-	err = mlx4_cmd(dev, mailbox->dma, in_mod, 1, MLX4_CMD_SET_PORT,
-		       MLX4_CMD_TIME_CLASS_B, MLX4_CMD_WRAPPED);
-
-	mlx4_free_cmd_mailbox(dev, mailbox);
-	return err;
-}
-
-int mlx4_SET_PORT_qpn_calc(struct mlx4_dev *dev, u8 port, u32 base_qpn,
-			   u8 promisc)
-{
-	struct mlx4_cmd_mailbox *mailbox;
-	struct mlx4_set_port_rqp_calc_context *context;
-	int err;
-	u32 in_mod;
-	u32 m_promisc = (dev->caps.flags & MLX4_DEV_CAP_FLAG_VEP_MC_STEER) ?
-						MCAST_DIRECT : MCAST_DEFAULT;
-
-	if (dev->caps.flags & MLX4_DEV_CAP_FLAG_VEP_MC_STEER  &&
-			dev->caps.flags & MLX4_DEV_CAP_FLAG_VEP_UC_STEER)
-		return 0;
-
-	mailbox = mlx4_alloc_cmd_mailbox(dev);
-	if (IS_ERR(mailbox))
-		return PTR_ERR(mailbox);
-	context = mailbox->buf;
-	memset(context, 0, sizeof *context);
-
-	context->base_qpn = cpu_to_be32(base_qpn);
-	context->n_mac = dev->caps.log_num_macs;
-	context->promisc = cpu_to_be32(promisc << SET_PORT_PROMISC_SHIFT |
-				       base_qpn);
-	context->mcast = cpu_to_be32(m_promisc << SET_PORT_MC_PROMISC_SHIFT |
-				     base_qpn);
-	context->intra_no_vlan = 0;
-	context->no_vlan = MLX4_NO_VLAN_IDX;
-	context->intra_vlan_miss = 0;
-	context->vlan_miss = MLX4_VLAN_MISS_IDX;
-
-	in_mod = MLX4_SET_PORT_RQP_CALC << 8 | port;
-	err = mlx4_cmd(dev, mailbox->dma, in_mod, 1, MLX4_CMD_SET_PORT,
-		       MLX4_CMD_TIME_CLASS_B, MLX4_CMD_WRAPPED);
-
-	mlx4_free_cmd_mailbox(dev, mailbox);
-	return err;
-}
-
 int mlx4_en_QUERY_PORT(struct mlx4_en_dev *mdev, u8 port)
 {
 	struct mlx4_en_query_port_context *qport_context;
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_port.h b/drivers/net/ethernet/mellanox/mlx4/en_port.h
index c1bb834..6934fd7 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_port.h
+++ b/drivers/net/ethernet/mellanox/mlx4/en_port.h
@@ -39,43 +39,6 @@
 #define SET_PORT_PROMISC_SHIFT	31
 #define SET_PORT_MC_PROMISC_SHIFT	30
 
-enum {
-	MCAST_DIRECT_ONLY       = 0,
-	MCAST_DIRECT            = 1,
-	MCAST_DEFAULT           = 2
-};
-
-struct mlx4_set_port_general_context {
-	u8 reserved[3];
-	u8 flags;
-	u16 reserved2;
-	__be16 mtu;
-	u8 pptx;
-	u8 pfctx;
-	u16 reserved3;
-	u8 pprx;
-	u8 pfcrx;
-	u16 reserved4;
-};
-
-struct mlx4_set_port_rqp_calc_context {
-	__be32 base_qpn;
-	u8 rererved;
-	u8 n_mac;
-	u8 n_vlan;
-	u8 n_prio;
-	u8 reserved2[3];
-	u8 mac_miss;
-	u8 intra_no_vlan;
-	u8 no_vlan;
-	u8 intra_vlan_miss;
-	u8 vlan_miss;
-	u8 reserved3[3];
-	u8 no_vlan_prio;
-	__be32 promisc;
-	__be32 mcast;
-};
-
 #define VLAN_FLTR_SIZE	128
 struct mlx4_set_vlan_fltr_mbox {
 	__be32 entry[VLAN_FLTR_SIZE];
diff --git a/drivers/net/ethernet/mellanox/mlx4/mcg.c b/drivers/net/ethernet/mellanox/mlx4/mcg.c
index b36c279..0785d9b 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mcg.c
+++ b/drivers/net/ethernet/mellanox/mlx4/mcg.c
@@ -913,7 +913,7 @@ int mlx4_multicast_detach(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
 }
 EXPORT_SYMBOL_GPL(mlx4_multicast_detach);
 
-static int mlx4_unicast_attach(struct mlx4_dev *dev,
+int mlx4_unicast_attach(struct mlx4_dev *dev,
 			struct mlx4_qp *qp, u8 gid[16],
 			int block_mcast_loopback, enum mlx4_protocol prot)
 {
@@ -933,7 +933,7 @@ static int mlx4_unicast_attach(struct mlx4_dev *dev,
 }
 EXPORT_SYMBOL_GPL(mlx4_unicast_attach);
 
-static int mlx4_unicast_detach(struct mlx4_dev *dev, struct mlx4_qp *qp,
+int mlx4_unicast_detach(struct mlx4_dev *dev, struct mlx4_qp *qp,
 			       u8 gid[16], enum mlx4_protocol prot)
 {
 	if (prot == MLX4_PROT_ETH &&
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4.h b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
index a38ffc9..abf65d8 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
@@ -419,12 +419,23 @@ struct mlx4_comm {
 	u32			slave_read;
 };
 
+enum {
+	MLX4_MCAST_CONFIG       = 0,
+	MLX4_MCAST_DISABLE      = 1,
+	MLX4_MCAST_ENABLE       = 2,
+};
+
 #define VLAN_FLTR_SIZE	128
 
 struct mlx4_vlan_fltr {
 	__be32 entry[VLAN_FLTR_SIZE];
 };
 
+struct mlx4_mcast_entry {
+	struct list_head list;
+	u64 addr;
+};
+
 struct mlx4_promisc_qp {
 	struct list_head list;
 	u32 qpn;
@@ -615,6 +626,48 @@ struct mlx4_vlan_table {
 	int			max;
 };
 
+#define SET_PORT_GEN_ALL_VALID		0x7
+#define SET_PORT_PROMISC_SHIFT		31
+#define SET_PORT_MC_PROMISC_SHIFT	30
+
+enum {
+	MCAST_DIRECT_ONLY	= 0,
+	MCAST_DIRECT		= 1,
+	MCAST_DEFAULT		= 2
+};
+
+
+struct mlx4_set_port_general_context {
+	u8 reserved[3];
+	u8 flags;
+	u16 reserved2;
+	__be16 mtu;
+	u8 pptx;
+	u8 pfctx;
+	u16 reserved3;
+	u8 pprx;
+	u8 pfcrx;
+	u16 reserved4;
+};
+
+struct mlx4_set_port_rqp_calc_context {
+	__be32 base_qpn;
+	u8 rererved;
+	u8 n_mac;
+	u8 n_vlan;
+	u8 n_prio;
+	u8 reserved2[3];
+	u8 mac_miss;
+	u8 intra_no_vlan;
+	u8 no_vlan;
+	u8 intra_vlan_miss;
+	u8 vlan_miss;
+	u8 reserved3[3];
+	u8 no_vlan_prio;
+	__be32 promisc;
+	__be32 mcast;
+};
+
 struct mlx4_mac_entry {
 	u64 mac;
 };
diff --git a/drivers/net/ethernet/mellanox/mlx4/port.c b/drivers/net/ethernet/mellanox/mlx4/port.c
index da9f85c6..00a9547 100644
--- a/drivers/net/ethernet/mellanox/mlx4/port.c
+++ b/drivers/net/ethernet/mellanox/mlx4/port.c
@@ -70,41 +70,12 @@ void mlx4_init_vlan_table(struct mlx4_dev *dev, struct mlx4_vlan_table *table)
 	table->total = 0;
 }
 
-static int mlx4_set_port_mac_table(struct mlx4_dev *dev, u8 port,
-				   __be64 *entries)
-{
-	struct mlx4_cmd_mailbox *mailbox;
-	u32 in_mod;
-	int err;
-
-	mailbox = mlx4_alloc_cmd_mailbox(dev);
-	if (IS_ERR(mailbox))
-		return PTR_ERR(mailbox);
-
-	memcpy(mailbox->buf, entries, MLX4_MAC_TABLE_SIZE);
-
-	in_mod = MLX4_SET_PORT_MAC_TABLE << 8 | port;
-	err = mlx4_cmd(dev, mailbox->dma, in_mod, 1, MLX4_CMD_SET_PORT,
-		       MLX4_CMD_TIME_CLASS_B, MLX4_CMD_NATIVE);
-
-	mlx4_free_cmd_mailbox(dev, mailbox);
-	return err;
-}
-
-static int mlx4_uc_steer_add(struct mlx4_dev *dev, u8 port,
-			     u64 mac, int *qpn, u8 reserve)
+static int mlx4_uc_steer_add(struct mlx4_dev *dev, u8 port, u64 mac, int *qpn)
 {
 	struct mlx4_qp qp;
 	u8 gid[16] = {0};
 	int err;
 
-	if (reserve) {
-		err = mlx4_qp_reserve_range(dev, 1, 1, qpn);
-		if (err) {
-			mlx4_err(dev, "Failed to reserve qp for mac registration\n");
-			return err;
-		}
-	}
 	qp.qpn = *qpn;
 
 	mac &= 0xffffffffffffULL;
@@ -113,16 +84,15 @@ static int mlx4_uc_steer_add(struct mlx4_dev *dev, u8 port,
 	gid[5] = port;
 	gid[7] = MLX4_UC_STEER << 1;
 
-	err = mlx4_qp_attach_common(dev, &qp, gid, 0,
-				    MLX4_PROT_ETH, MLX4_UC_STEER);
-	if (err && reserve)
-		mlx4_qp_release_range(dev, *qpn, 1);
+	err = mlx4_unicast_attach(dev, &qp, gid, 0, MLX4_PROT_ETH);
+	if (err)
+		mlx4_warn(dev, "Failed Attaching Unicast\n");
 
 	return err;
 }
 
 static void mlx4_uc_steer_release(struct mlx4_dev *dev, u8 port,
-				  u64 mac, int qpn, u8 free)
+				  u64 mac, int qpn)
 {
 	struct mlx4_qp qp;
 	u8 gid[16] = {0};
@@ -134,60 +104,164 @@ static void mlx4_uc_steer_release(struct mlx4_dev *dev, u8 port,
 	gid[5] = port;
 	gid[7] = MLX4_UC_STEER << 1;
 
-	mlx4_qp_detach_common(dev, &qp, gid, MLX4_PROT_ETH, MLX4_UC_STEER);
-	if (free)
-		mlx4_qp_release_range(dev, qpn, 1);
+	mlx4_unicast_detach(dev, &qp, gid, MLX4_PROT_ETH);
+}
+
+static int validate_index(struct mlx4_dev *dev,
+			  struct mlx4_mac_table *table, int index)
+{
+	int err = 0;
+
+	if (index < 0 || index >= table->max || !table->entries[index]) {
+		mlx4_warn(dev, "No valid Mac entry for the given index\n");
+		err = -EINVAL;
+	}
+	return err;
+}
+
+static int find_index(struct mlx4_dev *dev,
+		      struct mlx4_mac_table *table, u64 mac)
+{
+	int i;
+
+	for (i = 0; i < MLX4_MAX_MAC_NUM; i++) {
+		if ((mac & MLX4_MAC_MASK) ==
+		    (MLX4_MAC_MASK & be64_to_cpu(table->entries[i])))
+			return i;
+	}
+	/* Mac not found */
+	return -EINVAL;
 }
 
-int mlx4_register_mac(struct mlx4_dev *dev, u8 port, u64 mac, int *qpn, u8 wrap)
+int mlx4_get_eth_qp(struct mlx4_dev *dev, u8 port, u64 mac, int *qpn)
 {
 	struct mlx4_port_info *info = &mlx4_priv(dev)->port[port];
-	struct mlx4_mac_table *table = &info->mac_table;
 	struct mlx4_mac_entry *entry;
-	int i, err = 0;
-	int free = -1;
+	int index = 0;
+	int err = 0;
 
-	if (dev->caps.flags & MLX4_DEV_CAP_FLAG_VEP_UC_STEER) {
-		err = mlx4_uc_steer_add(dev, port, mac, qpn, 1);
-		if (err)
-			return err;
+	mlx4_dbg(dev, "Registering MAC: 0x%llx for adding\n",
+			(unsigned long long) mac);
+	index = mlx4_register_mac(dev, port, mac);
+	if (index < 0) {
+		err = index;
+		mlx4_err(dev, "Failed adding MAC: 0x%llx\n",
+			 (unsigned long long) mac);
+		return err;
+	}
 
-		entry = kmalloc(sizeof *entry, GFP_KERNEL);
-		if (!entry) {
-			mlx4_uc_steer_release(dev, port, mac, *qpn, 1);
-			return -ENOMEM;
-		}
+	if (!(dev->caps.flags & MLX4_DEV_CAP_FLAG_VEP_UC_STEER)) {
+		*qpn = info->base_qpn + index;
+		return 0;
+	}
+
+	err = mlx4_qp_reserve_range(dev, 1, 1, qpn);
+	mlx4_dbg(dev, "Reserved qp %d\n", *qpn);
+	if (err) {
+		mlx4_err(dev, "Failed to reserve qp for mac registration\n");
+		goto qp_err;
+	}
+
+	err = mlx4_uc_steer_add(dev, port, mac, qpn);
+	if (err)
+		goto steer_err;
+
+	entry = kmalloc(sizeof *entry, GFP_KERNEL);
+	if (!entry) {
+		err = -ENOMEM;
+		goto alloc_err;
+	}
+	entry->mac = mac;
+	err = radix_tree_insert(&info->mac_tree, *qpn, entry);
+	if (err)
+		goto insert_err;
+	return 0;
 
-		entry->mac = mac;
-		err = radix_tree_insert(&info->mac_tree, *qpn, entry);
-		if (err) {
+insert_err:
+	kfree(entry);
+
+alloc_err:
+	mlx4_uc_steer_release(dev, port, mac, *qpn);
+
+steer_err:
+	mlx4_qp_release_range(dev, *qpn, 1);
+
+qp_err:
+	mlx4_unregister_mac(dev, port, mac);
+	return err;
+}
+EXPORT_SYMBOL_GPL(mlx4_get_eth_qp);
+
+void mlx4_put_eth_qp(struct mlx4_dev *dev, u8 port, u64 mac, int qpn)
+{
+	struct mlx4_port_info *info = &mlx4_priv(dev)->port[port];
+	struct mlx4_mac_entry *entry;
+
+	mlx4_dbg(dev, "Registering MAC: 0x%llx for deleting\n",
+		 (unsigned long long) mac);
+	mlx4_unregister_mac(dev, port, mac);
+
+	if (dev->caps.flags & MLX4_DEV_CAP_FLAG_VEP_UC_STEER) {
+		entry = radix_tree_lookup(&info->mac_tree, qpn);
+		if (entry) {
+			mlx4_dbg(dev, "Releasing qp: port %d, mac 0x%llx,"
+				 " qpn %d\n", port,
+				 (unsigned long long) mac, qpn);
+			mlx4_uc_steer_release(dev, port, entry->mac, qpn);
+			mlx4_qp_release_range(dev, qpn, 1);
+			radix_tree_delete(&info->mac_tree, qpn);
 			kfree(entry);
-			mlx4_uc_steer_release(dev, port, mac, *qpn, 1);
-			return err;
 		}
 	}
+}
+EXPORT_SYMBOL_GPL(mlx4_put_eth_qp);
+
+static int mlx4_set_port_mac_table(struct mlx4_dev *dev, u8 port,
+				   __be64 *entries)
+{
+	struct mlx4_cmd_mailbox *mailbox;
+	u32 in_mod;
+	int err;
+
+	mailbox = mlx4_alloc_cmd_mailbox(dev);
+	if (IS_ERR(mailbox))
+		return PTR_ERR(mailbox);
+
+	memcpy(mailbox->buf, entries, MLX4_MAC_TABLE_SIZE);
+
+	in_mod = MLX4_SET_PORT_MAC_TABLE << 8 | port;
+
+	err = mlx4_cmd(dev, mailbox->dma, in_mod, 1, MLX4_CMD_SET_PORT,
+		       MLX4_CMD_TIME_CLASS_B, MLX4_CMD_NATIVE);
 
-	mlx4_dbg(dev, "Registering MAC: 0x%llx\n", (unsigned long long) mac);
+	mlx4_free_cmd_mailbox(dev, mailbox);
+	return err;
+}
+
+int __mlx4_register_mac(struct mlx4_dev *dev, u8 port, u64 mac)
+{
+	struct mlx4_port_info *info = &mlx4_priv(dev)->port[port];
+	struct mlx4_mac_table *table = &info->mac_table;
+	int i, err = 0;
+	int free = -1;
+
+	mlx4_dbg(dev, "Registering MAC: 0x%llx for port %d\n",
+		 (unsigned long long) mac, port);
 
 	mutex_lock(&table->mutex);
-	for (i = 0; i < MLX4_MAX_MAC_NUM - 1; i++) {
-		if (free < 0 && !table->refs[i]) {
+	for (i = 0; i < MLX4_MAX_MAC_NUM; i++) {
+		if (free < 0 && !table->entries[i]) {
 			free = i;
 			continue;
 		}
 
 		if (mac == (MLX4_MAC_MASK & be64_to_cpu(table->entries[i]))) {
-			/* MAC already registered, increase references count */
-			++table->refs[i];
+			/* MAC already registered, Must not have duplicates */
+			err = -EEXIST;
 			goto out;
 		}
 	}
 
-	if (free < 0) {
-		err = -ENOMEM;
-		goto out;
-	}
-
 	mlx4_dbg(dev, "Free MAC index is %d\n", free);
 
 	if (table->total == table->max) {
@@ -197,103 +271,103 @@ int mlx4_register_mac(struct mlx4_dev *dev, u8 port, u64 mac, int *qpn, u8 wrap)
 	}
 
 	/* Register new MAC */
-	table->refs[free] = 1;
 	table->entries[free] = cpu_to_be64(mac | MLX4_MAC_VALID);
 
 	err = mlx4_set_port_mac_table(dev, port, table->entries);
 	if (unlikely(err)) {
-		mlx4_err(dev, "Failed adding MAC: 0x%llx\n", (unsigned long long) mac);
-		table->refs[free] = 0;
+		mlx4_err(dev, "Failed adding MAC: 0x%llx\n",
+			 (unsigned long long) mac);
 		table->entries[free] = 0;
 		goto out;
 	}
 
-	if (!(dev->caps.flags & MLX4_DEV_CAP_FLAG_VEP_UC_STEER))
-		*qpn = info->base_qpn + free;
+	err = free;
 	++table->total;
 out:
 	mutex_unlock(&table->mutex);
 	return err;
 }
-EXPORT_SYMBOL_GPL(mlx4_register_mac);
+EXPORT_SYMBOL_GPL(__mlx4_register_mac);
 
-static int validate_index(struct mlx4_dev *dev,
-			  struct mlx4_mac_table *table, int index)
+int mlx4_register_mac(struct mlx4_dev *dev, u8 port, u64 mac)
 {
-	int err = 0;
+	u64 out_param;
+	int err;
 
-	if (index < 0 || index >= table->max || !table->entries[index]) {
-		mlx4_warn(dev, "No valid Mac entry for the given index\n");
-		err = -EINVAL;
-	}
-	return err;
-}
+	if (mlx4_is_mfunc(dev)) {
+		set_param_l(&out_param, port);
+		err = mlx4_cmd_imm(dev, mac, &out_param, RES_MAC,
+				   RES_OP_RESERVE_AND_MAP, MLX4_CMD_ALLOC_RES,
+				   MLX4_CMD_TIME_CLASS_A, MLX4_CMD_WRAPPED);
+		if (err)
+			return err;
 
-static int find_index(struct mlx4_dev *dev,
-		      struct mlx4_mac_table *table, u64 mac)
-{
-	int i;
-	for (i = 0; i < MLX4_MAX_MAC_NUM; i++) {
-		if (mac == (MLX4_MAC_MASK & be64_to_cpu(table->entries[i])))
-			return i;
+		return get_param_l(&out_param);
 	}
-	/* Mac not found */
-	return -EINVAL;
+	return __mlx4_register_mac(dev, port, mac);
 }
+EXPORT_SYMBOL_GPL(mlx4_register_mac);
+
 
-void mlx4_unregister_mac(struct mlx4_dev *dev, u8 port, int qpn)
+void __mlx4_unregister_mac(struct mlx4_dev *dev, u8 port, u64 mac)
 {
 	struct mlx4_port_info *info = &mlx4_priv(dev)->port[port];
 	struct mlx4_mac_table *table = &info->mac_table;
-	int index = qpn - info->base_qpn;
-	struct mlx4_mac_entry *entry;
+	int index;
 
-	if (dev->caps.flags & MLX4_DEV_CAP_FLAG_VEP_UC_STEER) {
-		entry = radix_tree_lookup(&info->mac_tree, qpn);
-		if (entry) {
-			mlx4_uc_steer_release(dev, port, entry->mac, qpn, 1);
-			radix_tree_delete(&info->mac_tree, qpn);
-			index = find_index(dev, table, entry->mac);
-			kfree(entry);
-		}
-	}
+	index = find_index(dev, table, mac);
 
 	mutex_lock(&table->mutex);
 
 	if (validate_index(dev, table, index))
 		goto out;
 
-	/* Check whether this address has reference count */
-	if (!(--table->refs[index])) {
-		table->entries[index] = 0;
-		mlx4_set_port_mac_table(dev, port, table->entries);
-		--table->total;
-	}
+	table->entries[index] = 0;
+	mlx4_set_port_mac_table(dev, port, table->entries);
+	--table->total;
 out:
 	mutex_unlock(&table->mutex);
 }
+EXPORT_SYMBOL_GPL(__mlx4_unregister_mac);
+
+void mlx4_unregister_mac(struct mlx4_dev *dev, u8 port, u64 mac)
+{
+	u64 out_param;
+	int err;
+
+	if (mlx4_is_mfunc(dev)) {
+		set_param_l(&out_param, port);
+		err = mlx4_cmd_imm(dev, mac, &out_param, RES_MAC,
+				   RES_OP_RESERVE_AND_MAP, MLX4_CMD_FREE_RES,
+				   MLX4_CMD_TIME_CLASS_A, MLX4_CMD_WRAPPED);
+		return;
+	}
+	__mlx4_unregister_mac(dev, port, mac);
+	return;
+}
 EXPORT_SYMBOL_GPL(mlx4_unregister_mac);
 
-int mlx4_replace_mac(struct mlx4_dev *dev, u8 port, int qpn, u64 new_mac, u8 wrap)
+int mlx4_replace_mac(struct mlx4_dev *dev, u8 port, int qpn, u64 new_mac)
 {
 	struct mlx4_port_info *info = &mlx4_priv(dev)->port[port];
 	struct mlx4_mac_table *table = &info->mac_table;
-	int index = qpn - info->base_qpn;
 	struct mlx4_mac_entry *entry;
-	int err;
+	int index = qpn - info->base_qpn;
+	int err = 0;
 
 	if (dev->caps.flags & MLX4_DEV_CAP_FLAG_VEP_UC_STEER) {
 		entry = radix_tree_lookup(&info->mac_tree, qpn);
 		if (!entry)
 			return -EINVAL;
-		index = find_index(dev, table, entry->mac);
-		mlx4_uc_steer_release(dev, port, entry->mac, qpn, 0);
+		mlx4_uc_steer_release(dev, port, entry->mac, qpn);
+		mlx4_unregister_mac(dev, port, entry->mac);
 		entry->mac = new_mac;
-		err = mlx4_uc_steer_add(dev, port, entry->mac, &qpn, 0);
-		if (err || index < 0)
-			return err;
+		mlx4_register_mac(dev, port, new_mac);
+		err = mlx4_uc_steer_add(dev, port, entry->mac, &qpn);
+		return err;
 	}
 
+	/* CX1 doesn't support multi-functions */
 	mutex_lock(&table->mutex);
 
 	err = validate_index(dev, table, index);
@@ -304,7 +378,8 @@ int mlx4_replace_mac(struct mlx4_dev *dev, u8 port, int qpn, u64 new_mac, u8 wra
 
 	err = mlx4_set_port_mac_table(dev, port, table->entries);
 	if (unlikely(err)) {
-		mlx4_err(dev, "Failed adding MAC: 0x%llx\n", (unsigned long long) new_mac);
+		mlx4_err(dev, "Failed adding MAC: 0x%llx\n",
+			 (unsigned long long) new_mac);
 		table->entries[index] = 0;
 	}
 out:
@@ -312,6 +387,7 @@ out:
 	return err;
 }
 EXPORT_SYMBOL_GPL(mlx4_replace_mac);
+
 static int mlx4_set_port_vlan_table(struct mlx4_dev *dev, u8 port,
 				    __be32 *entries)
 {
@@ -352,7 +428,8 @@ int mlx4_find_cached_vlan(struct mlx4_dev *dev, u8 port, u16 vid, int *idx)
 }
 EXPORT_SYMBOL_GPL(mlx4_find_cached_vlan);
 
-int mlx4_register_vlan(struct mlx4_dev *dev, u8 port, u16 vlan, int *index)
+static int __mlx4_register_vlan(struct mlx4_dev *dev, u8 port, u16 vlan,
+				int *index)
 {
 	struct mlx4_vlan_table *table = &mlx4_priv(dev)->port[port].vlan_table;
 	int i, err = 0;
@@ -387,7 +464,7 @@ int mlx4_register_vlan(struct mlx4_dev *dev, u8 port, u16 vlan, int *index)
 		goto out;
 	}
 
-	/* Register new MAC */
+	/* Register new VLAN */
 	table->refs[free] = 1;
 	table->entries[free] = cpu_to_be32(vlan | MLX4_VLAN_VALID);
 
@@ -405,9 +482,27 @@ out:
 	mutex_unlock(&table->mutex);
 	return err;
 }
+
+int mlx4_register_vlan(struct mlx4_dev *dev, u8 port, u16 vlan, int *index)
+{
+	u64 out_param;
+	int err;
+
+	if (mlx4_is_mfunc(dev)) {
+		set_param_l(&out_param, port);
+		err = mlx4_cmd_imm(dev, vlan, &out_param, RES_VLAN,
+				   RES_OP_RESERVE_AND_MAP, MLX4_CMD_ALLOC_RES,
+				   MLX4_CMD_TIME_CLASS_A, MLX4_CMD_WRAPPED);
+		if (!err)
+			*index = get_param_l(&out_param);
+
+		return err;
+	}
+	return __mlx4_register_vlan(dev, port, vlan, index);
+}
 EXPORT_SYMBOL_GPL(mlx4_register_vlan);
 
-void mlx4_unregister_vlan(struct mlx4_dev *dev, u8 port, int index)
+static void __mlx4_unregister_vlan(struct mlx4_dev *dev, u8 port, int index)
 {
 	struct mlx4_vlan_table *table = &mlx4_priv(dev)->port[port].vlan_table;
 
@@ -432,6 +527,25 @@ void mlx4_unregister_vlan(struct mlx4_dev *dev, u8 port, int index)
 out:
 	mutex_unlock(&table->mutex);
 }
+
+void mlx4_unregister_vlan(struct mlx4_dev *dev, u8 port, int index)
+{
+	u64 in_param;
+	int err;
+
+	if (mlx4_is_mfunc(dev)) {
+		set_param_l(&in_param, port);
+		err = mlx4_cmd(dev, in_param, RES_VLAN, RES_OP_RESERVE_AND_MAP,
+			       MLX4_CMD_FREE_RES, MLX4_CMD_TIME_CLASS_A,
+			       MLX4_CMD_WRAPPED);
+		if (!err)
+			mlx4_warn(dev, "Failed freeing vlan at index:%d\n",
+					index);
+
+		return;
+	}
+	__mlx4_unregister_vlan(dev, port, index);
+}
 EXPORT_SYMBOL_GPL(mlx4_unregister_vlan);
 
 int mlx4_get_port_ib_caps(struct mlx4_dev *dev, u8 port, __be32 *caps)
@@ -514,6 +628,139 @@ int mlx4_check_ext_port_caps(struct mlx4_dev *dev, u8 port)
 	return err;
 }
 
+static int mlx4_common_set_port(struct mlx4_dev *dev, int slave, u32 in_mod,
+				u8 op_mod, struct mlx4_cmd_mailbox *inbox)
+{
+	struct mlx4_priv *priv = mlx4_priv(dev);
+	struct mlx4_port_info *port_info;
+	struct mlx4_mfunc_master_ctx *master = &priv->mfunc.master;
+	struct mlx4_slave_state *slave_st = &master->slave_state[slave];
+	struct mlx4_set_port_rqp_calc_context *qpn_context;
+	struct mlx4_set_port_general_context *gen_context;
+	int reset_qkey_viols;
+	int port;
+	int is_eth;
+	u32 in_modifier;
+	u32 promisc;
+	u16 mtu, prev_mtu;
+	int err;
+	int i;
+	__be32 agg_cap_mask;
+	__be32 slave_cap_mask;
+	__be32 new_cap_mask;
+
+	port = in_mod & 0xff;
+	in_modifier = in_mod >> 8;
+	is_eth = op_mod;
+	port_info = &priv->port[port];
+
+	/* Slaves cannot perform SET_PORT operations except changing MTU */
+	if (is_eth) {
+		if (slave != dev->caps.function &&
+		    in_modifier != MLX4_SET_PORT_GENERAL) {
+			mlx4_warn(dev, "denying SET_PORT for slave:%d\n",
+					slave);
+			return -EINVAL;
+		}
+		switch (in_modifier) {
+		case MLX4_SET_PORT_RQP_CALC:
+			qpn_context = inbox->buf;
+			qpn_context->base_qpn =
+				cpu_to_be32(port_info->base_qpn);
+			qpn_context->n_mac = 0x7;
+			promisc = be32_to_cpu(qpn_context->promisc) >>
+				SET_PORT_PROMISC_SHIFT;
+			qpn_context->promisc = cpu_to_be32(
+				promisc << SET_PORT_PROMISC_SHIFT |
+				port_info->base_qpn);
+			promisc = be32_to_cpu(qpn_context->mcast) >>
+				SET_PORT_MC_PROMISC_SHIFT;
+			qpn_context->mcast = cpu_to_be32(
+				promisc << SET_PORT_MC_PROMISC_SHIFT |
+				port_info->base_qpn);
+			break;
+		case MLX4_SET_PORT_GENERAL:
+			gen_context = inbox->buf;
+			/* Mtu is configured as the max MTU among all the
+			 * the functions on the port. */
+			mtu = be16_to_cpu(gen_context->mtu);
+			mtu = min_t(int, mtu, dev->caps.eth_mtu_cap[port]);
+			prev_mtu = slave_st->mtu[port];
+			slave_st->mtu[port] = mtu;
+			if (mtu > master->max_mtu[port])
+				master->max_mtu[port] = mtu;
+			if (mtu < prev_mtu && prev_mtu ==
+						master->max_mtu[port]) {
+				slave_st->mtu[port] = mtu;
+				master->max_mtu[port] = mtu;
+				for (i = 0; i < dev->num_slaves; i++) {
+					master->max_mtu[port] =
+					max(master->max_mtu[port],
+					    master->slave_state[i].mtu[port]);
+				}
+			}
+
+			gen_context->mtu = cpu_to_be16(master->max_mtu[port]);
+			break;
+		}
+		return mlx4_cmd(dev, inbox->dma, in_mod, op_mod,
+				MLX4_CMD_SET_PORT, MLX4_CMD_TIME_CLASS_B,
+				MLX4_CMD_NATIVE);
+	}
+
+	/* For IB, we only consider:
+	 * - The capability mask, which is set to the aggregate of all
+	 *   slave function capabilities
+	 * - The QKey violatin counter - reset according to each request.
+	 */
+
+	if (dev->flags & MLX4_FLAG_OLD_PORT_CMDS) {
+		reset_qkey_viols = (*(u8 *) inbox->buf) & 0x40;
+		new_cap_mask = ((__be32 *) inbox->buf)[2];
+	} else {
+		reset_qkey_viols = ((u8 *) inbox->buf)[3] & 0x1;
+		new_cap_mask = ((__be32 *) inbox->buf)[1];
+	}
+
+	agg_cap_mask = 0;
+	slave_cap_mask =
+		priv->mfunc.master.slave_state[slave].ib_cap_mask[port];
+	priv->mfunc.master.slave_state[slave].ib_cap_mask[port] = new_cap_mask;
+	for (i = 0; i < dev->num_slaves; i++)
+		agg_cap_mask |=
+			priv->mfunc.master.slave_state[i].ib_cap_mask[port];
+
+	/* only clear mailbox for guests.  Master may be setting
+	* MTU or PKEY table size
+	*/
+	if (slave != dev->caps.function)
+		memset(inbox->buf, 0, 256);
+	if (dev->flags & MLX4_FLAG_OLD_PORT_CMDS) {
+		*(u8 *) inbox->buf	   = !!reset_qkey_viols << 6;
+		((__be32 *) inbox->buf)[2] = agg_cap_mask;
+	} else {
+		((u8 *) inbox->buf)[3]     = !!reset_qkey_viols;
+		((__be32 *) inbox->buf)[1] = agg_cap_mask;
+	}
+
+	err = mlx4_cmd(dev, inbox->dma, port, is_eth, MLX4_CMD_SET_PORT,
+		       MLX4_CMD_TIME_CLASS_B, MLX4_CMD_NATIVE);
+	if (err)
+		priv->mfunc.master.slave_state[slave].ib_cap_mask[port] =
+			slave_cap_mask;
+	return err;
+}
+
+int mlx4_SET_PORT_wrapper(struct mlx4_dev *dev, int slave,
+			  struct mlx4_vhcr *vhcr,
+			  struct mlx4_cmd_mailbox *inbox,
+			  struct mlx4_cmd_mailbox *outbox,
+			  struct mlx4_cmd_info *cmd)
+{
+	return mlx4_common_set_port(dev, slave, vhcr->in_modifier,
+				    vhcr->op_modifier, inbox);
+}
+
 int mlx4_SET_PORT(struct mlx4_dev *dev, u8 port)
 {
 	struct mlx4_cmd_mailbox *mailbox;
@@ -535,3 +782,122 @@ int mlx4_SET_PORT(struct mlx4_dev *dev, u8 port)
 	mlx4_free_cmd_mailbox(dev, mailbox);
 	return err;
 }
+
+static int mlx4_SET_PORT_general(struct mlx4_dev *dev, u8 port, int mtu,
+			  u8 pptx, u8 pfctx, u8 pprx, u8 pfcrx)
+{
+	struct mlx4_cmd_mailbox *mailbox;
+	struct mlx4_set_port_general_context *context;
+	int err;
+	u32 in_mod;
+
+	mailbox = mlx4_alloc_cmd_mailbox(dev);
+	if (IS_ERR(mailbox))
+		return PTR_ERR(mailbox);
+	context = mailbox->buf;
+	memset(context, 0, sizeof *context);
+
+	context->flags = SET_PORT_GEN_ALL_VALID;
+	context->mtu = cpu_to_be16(mtu);
+	context->pptx = (pptx * (!pfctx)) << 7;
+	context->pfctx = pfctx;
+	context->pprx = (pprx * (!pfcrx)) << 7;
+	context->pfcrx = pfcrx;
+
+	in_mod = MLX4_SET_PORT_GENERAL << 8 | port;
+	err = mlx4_cmd(dev, mailbox->dma, in_mod, 1, MLX4_CMD_SET_PORT,
+		       MLX4_CMD_TIME_CLASS_B,  MLX4_CMD_WRAPPED);
+
+	mlx4_free_cmd_mailbox(dev, mailbox);
+	return err;
+}
+EXPORT_SYMBOL(mlx4_SET_PORT_general);
+
+static int mlx4_SET_PORT_qpn_calc(struct mlx4_dev *dev, u8 port, u32 base_qpn,
+			   u8 promisc)
+{
+	struct mlx4_cmd_mailbox *mailbox;
+	struct mlx4_set_port_rqp_calc_context *context;
+	int err;
+	u32 in_mod;
+	u32 m_promisc = (dev->caps.flags & MLX4_DEV_CAP_FLAG_VEP_MC_STEER) ?
+		MCAST_DIRECT : MCAST_DEFAULT;
+
+	if (dev->caps.flags & MLX4_DEV_CAP_FLAG_VEP_MC_STEER  &&
+	    dev->caps.flags & MLX4_DEV_CAP_FLAG_VEP_UC_STEER)
+		return 0;
+
+	mailbox = mlx4_alloc_cmd_mailbox(dev);
+	if (IS_ERR(mailbox))
+		return PTR_ERR(mailbox);
+	context = mailbox->buf;
+	memset(context, 0, sizeof *context);
+
+	context->base_qpn = cpu_to_be32(base_qpn);
+	context->n_mac = dev->caps.log_num_macs;
+	context->promisc = cpu_to_be32(promisc << SET_PORT_PROMISC_SHIFT |
+				       base_qpn);
+	context->mcast = cpu_to_be32(m_promisc << SET_PORT_MC_PROMISC_SHIFT |
+				     base_qpn);
+	context->intra_no_vlan = 0;
+	context->no_vlan = MLX4_NO_VLAN_IDX;
+	context->intra_vlan_miss = 0;
+	context->vlan_miss = MLX4_VLAN_MISS_IDX;
+
+	in_mod = MLX4_SET_PORT_RQP_CALC << 8 | port;
+	err = mlx4_cmd(dev, mailbox->dma, in_mod, 1, MLX4_CMD_SET_PORT,
+		       MLX4_CMD_TIME_CLASS_B,  MLX4_CMD_WRAPPED);
+
+	mlx4_free_cmd_mailbox(dev, mailbox);
+	return err;
+}
+EXPORT_SYMBOL(mlx4_SET_PORT_qpn_calc);
+
+int mlx4_SET_MCAST_FLTR_wrapper(struct mlx4_dev *dev, int slave,
+				struct mlx4_vhcr *vhcr,
+				struct mlx4_cmd_mailbox *inbox,
+				struct mlx4_cmd_mailbox *outbox,
+				struct mlx4_cmd_info *cmd)
+{
+	int err = 0;
+
+	return err;
+}
+
+int mlx4_SET_MCAST_FLTR(struct mlx4_dev *dev, u8 port,
+			u64 mac, u64 clear, u8 mode)
+{
+	return mlx4_cmd(dev, (mac | (clear << 63)), port, mode,
+			MLX4_CMD_SET_MCAST_FLTR, MLX4_CMD_TIME_CLASS_B,
+			MLX4_CMD_WRAPPED);
+}
+EXPORT_SYMBOL(mlx4_SET_MCAST_FLTR);
+
+int mlx4_SET_VLAN_FLTR_wrapper(struct mlx4_dev *dev, int slave,
+			       struct mlx4_vhcr *vhcr,
+			       struct mlx4_cmd_mailbox *inbox,
+			       struct mlx4_cmd_mailbox *outbox,
+			       struct mlx4_cmd_info *cmd)
+{
+	int err = 0;
+
+	return err;
+}
+
+int mlx4_common_dump_eth_stats(struct mlx4_dev *dev, int slave,
+			       u32 in_mod, struct mlx4_cmd_mailbox *outbox)
+{
+	return mlx4_cmd_box(dev, 0, outbox->dma, in_mod, 0,
+			    MLX4_CMD_DUMP_ETH_STATS, MLX4_CMD_TIME_CLASS_B,
+			    MLX4_CMD_NATIVE);
+}
+
+int mlx4_DUMP_ETH_STATS_wrapper(struct mlx4_dev *dev, int slave,
+				struct mlx4_vhcr *vhcr,
+				struct mlx4_cmd_mailbox *inbox,
+				struct mlx4_cmd_mailbox *outbox,
+				struct mlx4_cmd_info *cmd)
+{
+	return mlx4_common_dump_eth_stats(dev, slave,
+					  vhcr->in_modifier, outbox);
+}
diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
index 13be980..243231a 100644
--- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
+++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
@@ -254,17 +254,6 @@ static const char *ResourceType(enum mlx4_resource rt)
 	};
 }
 
-/* dummy procedures */
-int __mlx4_register_mac(struct mlx4_dev *dev, u8 port, u64 mac)
-{
-	return 0;
-}
-
-void __mlx4_unregister_mac(struct mlx4_dev *dev, u8 port, u64 mac)
-{
-}
-/* end dummies */
-
 int mlx4_init_resource_tracker(struct mlx4_dev *dev)
 {
 	struct mlx4_priv *priv = mlx4_priv(dev);
@@ -1302,6 +1291,12 @@ static int mac_alloc_res(struct mlx4_dev *dev, int slave, int op, int cmd,
 	return err;
 }
 
+static int vlan_alloc_res(struct mlx4_dev *dev, int slave, int op, int cmd,
+			 u64 in_param, u64 *out_param)
+{
+	return 0;
+}
+
 int mlx4_ALLOC_RES_wrapper(struct mlx4_dev *dev, int slave,
 			   struct mlx4_vhcr *vhcr,
 			   struct mlx4_cmd_mailbox *inbox,
@@ -1342,6 +1337,11 @@ int mlx4_ALLOC_RES_wrapper(struct mlx4_dev *dev, int slave,
 				    vhcr->in_param, &vhcr->out_param);
 		break;
 
+	case RES_VLAN:
+		err = vlan_alloc_res(dev, slave, vhcr->op_modifier, alop,
+				    vhcr->in_param, &vhcr->out_param);
+		break;
+
 	default:
 		err = -EINVAL;
 		break;
@@ -1518,6 +1518,12 @@ static int mac_free_res(struct mlx4_dev *dev, int slave, int op, int cmd,
 
 }
 
+static int vlan_free_res(struct mlx4_dev *dev, int slave, int op, int cmd,
+			    u64 in_param, u64 *out_param)
+{
+	return 0;
+}
+
 int mlx4_FREE_RES_wrapper(struct mlx4_dev *dev, int slave,
 			  struct mlx4_vhcr *vhcr,
 			  struct mlx4_cmd_mailbox *inbox,
@@ -1558,6 +1564,11 @@ int mlx4_FREE_RES_wrapper(struct mlx4_dev *dev, int slave,
 				   vhcr->in_param, &vhcr->out_param);
 		break;
 
+	case RES_VLAN:
+		err = vlan_free_res(dev, slave, vhcr->op_modifier, alop,
+				   vhcr->in_param, &vhcr->out_param);
+		break;
+
 	default:
 		break;
 	}
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index e4be34a..3ef73b0 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -599,6 +599,10 @@ int mlx4_srq_query(struct mlx4_dev *dev, struct mlx4_srq *srq, int *limit_waterm
 int mlx4_INIT_PORT(struct mlx4_dev *dev, int port);
 int mlx4_CLOSE_PORT(struct mlx4_dev *dev, int port);
 
+int mlx4_unicast_attach(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
+			int block_mcast_loopback, enum mlx4_protocol prot);
+int mlx4_unicast_detach(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
+			enum mlx4_protocol prot);
 int mlx4_multicast_attach(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
 			  int block_mcast_loopback, enum mlx4_protocol protocol);
 int mlx4_multicast_detach(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
@@ -609,9 +613,11 @@ int mlx4_unicast_promisc_add(struct mlx4_dev *dev, u32 qpn, u8 port);
 int mlx4_unicast_promisc_remove(struct mlx4_dev *dev, u32 qpn, u8 port);
 int mlx4_SET_MCAST_FLTR(struct mlx4_dev *dev, u8 port, u64 mac, u64 clear, u8 mode);
 
-int mlx4_register_mac(struct mlx4_dev *dev, u8 port, u64 mac, int *qpn, u8 wrap);
-void mlx4_unregister_mac(struct mlx4_dev *dev, u8 port, int qpn);
-int mlx4_replace_mac(struct mlx4_dev *dev, u8 port, int qpn, u64 new_mac, u8 wrap);
+int mlx4_register_mac(struct mlx4_dev *dev, u8 port, u64 mac);
+void mlx4_unregister_mac(struct mlx4_dev *dev, u8 port, u64 mac);
+int mlx4_replace_mac(struct mlx4_dev *dev, u8 port, int qpn, u64 new_mac);
+int mlx4_get_eth_qp(struct mlx4_dev *dev, u8 port, u64 mac, int *qpn);
+void mlx4_put_eth_qp(struct mlx4_dev *dev, u8 port, u64 mac, int qpn);
 
 int mlx4_find_cached_vlan(struct mlx4_dev *dev, u8 port, u16 vid, int *idx);
 int mlx4_register_vlan(struct mlx4_dev *dev, u8 port, u16 vlan, int *index);
-- 
1.7.7







--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
