From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 19/23 v3] mlx4: SET port for Ethernet moved to mlx4_core
Date: Thu, 04 Feb 2010 17:56:53 +0200
Message-ID: <4B6AEE45.8090802@mellanox.co.il>
References: <49BFC313.1030901@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: general@lists.openfabrics.org, netdev@vger.kernel.org,
	liranl@mellanox.co.il, tziporet@mellanox.co.il
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:49873 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S933245Ab0BDP44 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Feb 2010 10:56:56 -0500
In-Reply-To: <49BFC313.1030901@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The physical port is common resource for all the functions.
Its management should go through the multifunction mechanism.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/en_port.c  |   64 -------------------------
 drivers/net/mlx4/en_port.h  |   43 -----------------
 drivers/net/mlx4/mlx4.h     |   44 ++++++++++++++++++
 drivers/net/mlx4/port.c     |  107 ++++++++++++++++++++++++++++++++++++++-----
 include/linux/mlx4/device.h |    5 ++
 5 files changed, 144 insertions(+), 119 deletions(-)

diff --git a/drivers/net/mlx4/en_port.c b/drivers/net/mlx4/en_port.c
index b099f81..2863a30 100644
--- a/drivers/net/mlx4/en_port.c
+++ b/drivers/net/mlx4/en_port.c
@@ -41,70 +41,6 @@
 #include "mlx4_en.h"
 
 
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
-		       MLX4_CMD_TIME_CLASS_B);
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
-	u32 m_promisc = (dev->caps.vep_mc_steering) ? MCAST_DIRECT : MCAST_DEFAULT;
-
-	mailbox = mlx4_alloc_cmd_mailbox(dev);
-	if (IS_ERR(mailbox))
-		return PTR_ERR(mailbox);
-	context = mailbox->buf;
-	memset(context, 0, sizeof *context);
-
-	context->base_qpn = cpu_to_be32(base_qpn);
-	context->n_mac = 0x7;
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
-		       MLX4_CMD_TIME_CLASS_B);
-
-	mlx4_free_cmd_mailbox(dev, mailbox);
-	return err;
-}
-
-
 int mlx4_en_DUMP_ETH_STATS(struct mlx4_en_dev *mdev, u8 port, u8 reset)
 {
 	struct mlx4_en_stat_out_mbox *mlx4_en_stats;
diff --git a/drivers/net/mlx4/en_port.h b/drivers/net/mlx4/en_port.h
index 8b221d6..40918ab 100644
--- a/drivers/net/mlx4/en_port.h
+++ b/drivers/net/mlx4/en_port.h
@@ -35,49 +35,6 @@
 #define _MLX4_EN_PORT_H_
 
 
-#define SET_PORT_GEN_ALL_VALID		0x7
-#define SET_PORT_PROMISC_SHIFT		31
-#define SET_PORT_MC_PROMISC_SHIFT	30
-
-enum {
-	MCAST_DIRECT_ONLY	= 0,
-	MCAST_DIRECT		= 1,
-	MCAST_DEFAULT		= 2
-};
-
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
-
 enum {
 	MLX4_MCAST_CONFIG       = 0,
 	MLX4_MCAST_DISABLE      = 1,
diff --git a/drivers/net/mlx4/mlx4.h b/drivers/net/mlx4/mlx4.h
index 74543d7..1cc4c13 100644
--- a/drivers/net/mlx4/mlx4.h
+++ b/drivers/net/mlx4/mlx4.h
@@ -382,6 +382,50 @@ struct mlx4_vlan_table {
 	int			max;
 };
 
+
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
+
 struct mlx4_port_info {
 	struct mlx4_dev	       *dev;
 	int			port;
diff --git a/drivers/net/mlx4/port.c b/drivers/net/mlx4/port.c
index 1bec155..e94a373 100644
--- a/drivers/net/mlx4/port.c
+++ b/drivers/net/mlx4/port.c
@@ -348,9 +348,8 @@ int mlx4_get_port_ib_caps(struct mlx4_dev *dev, u8 port, __be32 *caps)
 	return err;
 }
 
-int mlx4_SET_PORT_wrapper(struct mlx4_dev *dev, int slave, struct mlx4_vhcr *vhcr,
-							struct mlx4_cmd_mailbox *inbox,
-							struct mlx4_cmd_mailbox *outbox)
+static int mlx4_common_set_port(struct mlx4_dev *dev, int slave, u32 in_mod,
+				u8 op_mod, struct mlx4_cmd_mailbox *inbox)
 {
 	struct mlx4_priv *priv = mlx4_priv(dev);
 	struct mlx4_port_info *port_info;
@@ -370,9 +369,9 @@ int mlx4_SET_PORT_wrapper(struct mlx4_dev *dev, int slave, struct mlx4_vhcr *vhc
 	__be32 slave_cap_mask;
 	__be32 new_cap_mask;
 
-	port = vhcr->in_modifier & 0xff;
-	in_modifier = vhcr->in_modifier >> 8;
-	is_eth = vhcr->op_modifier;
+	port = in_mod & 0xff;
+	in_modifier = in_mod >> 8;
+	is_eth = op_mod;
 	port_info = &priv->port[port];
 
 	/* All slaves can perform SET_PORT operations, just need to verify
@@ -417,10 +416,8 @@ int mlx4_SET_PORT_wrapper(struct mlx4_dev *dev, int slave, struct mlx4_vhcr *vhc
 			gen_context->mtu = cpu_to_be16(master->max_mtu[port]);
 			break;
 		}
-		return mlx4_cmd(dev, inbox->dma, vhcr->in_modifier,
-						 vhcr->op_modifier,
-						 MLX4_CMD_SET_PORT,
-						 MLX4_CMD_TIME_CLASS_B);
+		return mlx4_cmd(dev, inbox->dma, in_mod, op_mod,
+				MLX4_CMD_SET_PORT, MLX4_CMD_TIME_CLASS_B);
 	}
 
 	/* For IB, we only consider:
@@ -471,6 +468,16 @@ int mlx4_SET_PORT_wrapper(struct mlx4_dev *dev, int slave, struct mlx4_vhcr *vhc
 	return err;
 }
 
+int mlx4_SET_PORT_wrapper(struct mlx4_dev *dev, int slave,
+			  struct mlx4_vhcr *vhcr,
+			  struct mlx4_cmd_mailbox *inbox,
+			  struct mlx4_cmd_mailbox *outbox)
+{
+	return mlx4_common_set_port(dev, slave, vhcr->in_modifier,
+				    vhcr->op_modifier, inbox);
+}
+
+
 int mlx4_SET_PORT(struct mlx4_dev *dev, u8 port)
 {
 	struct mlx4_cmd_mailbox *mailbox;
@@ -486,12 +493,88 @@ int mlx4_SET_PORT(struct mlx4_dev *dev, u8 port)
 	memset(mailbox->buf, 0, 256);
 
 	((__be32 *) mailbox->buf)[1] = dev->caps.ib_port_def_cap[port];
-	err = mlx4_cmd(dev, mailbox->dma, port, 0, MLX4_CMD_SET_PORT,
-		       MLX4_CMD_TIME_CLASS_B);
+
+	if (mlx4_is_master(dev))
+		err = mlx4_common_set_port(dev, dev->caps.function, port, 0, mailbox);
+	else
+		err = mlx4_cmd(dev, mailbox->dma, port, 0, MLX4_CMD_SET_PORT,
+			       MLX4_CMD_TIME_CLASS_B);
+
+	mlx4_free_cmd_mailbox(dev, mailbox);
+	return err;
+}
+
+
+int mlx4_SET_PORT_general(struct mlx4_dev *dev, u8 port, int mtu,
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
+	if (mlx4_is_master(dev))
+		err = mlx4_common_set_port(dev, dev->caps.function, in_mod, 1, mailbox);
+	else
+		err = mlx4_cmd(dev, mailbox->dma, in_mod, 1, MLX4_CMD_SET_PORT,
+			       MLX4_CMD_TIME_CLASS_B);
+
+	mlx4_free_cmd_mailbox(dev, mailbox);
+	return err;
+}
+EXPORT_SYMBOL(mlx4_SET_PORT_general);
+
+int mlx4_SET_PORT_qpn_calc(struct mlx4_dev *dev, u8 port, u32 base_qpn,
+			   u8 promisc)
+{
+	struct mlx4_cmd_mailbox *mailbox;
+	struct mlx4_set_port_rqp_calc_context *context;
+	int err;
+	u32 in_mod;
+	u32 m_promisc = (dev->caps.vep_mc_steering) ? MCAST_DIRECT : MCAST_DEFAULT;
+
+	mailbox = mlx4_alloc_cmd_mailbox(dev);
+	if (IS_ERR(mailbox))
+		return PTR_ERR(mailbox);
+	context = mailbox->buf;
+	memset(context, 0, sizeof *context);
+
+	context->base_qpn = cpu_to_be32(base_qpn);
+	context->n_mac = 0x7;
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
+	if (mlx4_is_master(dev))
+		err = mlx4_common_set_port(dev, dev->caps.function, in_mod, 1, mailbox);
+	else
+		err = mlx4_cmd(dev, mailbox->dma, in_mod, 1, MLX4_CMD_SET_PORT,
+			       MLX4_CMD_TIME_CLASS_B);
 
 	mlx4_free_cmd_mailbox(dev, mailbox);
 	return err;
 }
+EXPORT_SYMBOL(mlx4_SET_PORT_qpn_calc);
 
 static int mlx4_common_set_mcast_fltr(struct mlx4_dev *dev, int function,
 				      int port, u64 addr, u64 clear, u8 mode)
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index 8e51af5..a52caf6 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -498,6 +498,11 @@ void mlx4_srq_free(struct mlx4_dev *dev, struct mlx4_srq *srq);
 int mlx4_srq_arm(struct mlx4_dev *dev, struct mlx4_srq *srq, int limit_watermark);
 int mlx4_srq_query(struct mlx4_dev *dev, struct mlx4_srq *srq, int *limit_watermark);
 
+int mlx4_SET_PORT_general(struct mlx4_dev *dev, u8 port, int mtu,
+			  u8 pptx, u8 pfctx, u8 pprx, u8 pfcrx);
+int mlx4_SET_PORT_qpn_calc(struct mlx4_dev *dev, u8 port, u32 base_qpn,
+			   u8 promisc);
+
 int mlx4_INIT_PORT(struct mlx4_dev *dev, int port);
 int mlx4_CLOSE_PORT(struct mlx4_dev *dev, int port);
 
-- 
1.6.1.3


