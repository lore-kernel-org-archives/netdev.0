From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net-next V2 6/8] net/mlx4_en: Pass user MTU value to Firmware at set port command
Date: Sun, 29 Jan 2017 13:22:28 +0200
Message-ID: <1485688950-32443-7-git-send-email-tariqt@mellanox.com>
References: <1485688950-32443-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Shaker Daibes <shakerd@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:51139 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1750894AbdA2LaO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 29 Jan 2017 06:30:14 -0500
In-Reply-To: <1485688950-32443-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shaker Daibes <shakerd@mellanox.com>

When starting the port, driver will inform Firmware about the actual MTU
which does not include implicit headers, such as FCS or VLAN tags.

Signed-off-by: Shaker Daibes <shakerd@mellanox.com>
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |  8 +++
 drivers/net/ethernet/mellanox/mlx4/fw.c        |  2 +-
 drivers/net/ethernet/mellanox/mlx4/mlx4.h      |  7 ++-
 drivers/net/ethernet/mellanox/mlx4/port.c      | 71 ++++++++++++++++++++++++--
 include/linux/mlx4/device.h                    |  1 +
 5 files changed, 82 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index cfb4a9d67b45..60a021c34881 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -1695,6 +1695,14 @@ int mlx4_en_start_port(struct net_device *dev)
 		       priv->port, err);
 		goto tx_err;
 	}
+
+	err = mlx4_SET_PORT_user_mtu(mdev->dev, priv->port, dev->mtu);
+	if (err) {
+		en_err(priv, "Failed to pass user MTU(%d) to Firmware for port %d, with error %d\n",
+		       dev->mtu, priv->port, err);
+		goto tx_err;
+	}
+
 	/* Set default qp number */
 	err = mlx4_SET_PORT_qpn_calc(mdev->dev, priv->port, priv->base_qpn, 0);
 	if (err) {
diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index de39a5db4a6f..3fe885ce1902 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -2983,7 +2983,7 @@ static int mlx4_SET_PORT_phv_bit(struct mlx4_dev *dev, u8 port, u8 phv_bit)
 		return PTR_ERR(mailbox);
 	context = mailbox->buf;
 
-	context->v_ignore_fcs |=  SET_PORT_GEN_PHV_VALID;
+	context->flags2 |=  SET_PORT_GEN_PHV_VALID;
 	if (phv_bit)
 		context->phv_en |=  SET_PORT_GEN_PHV_EN;
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4.h b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
index 88ee7d8a5923..1132d76ddfdf 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
@@ -487,6 +487,7 @@ struct mlx4_slave_state {
 	bool vst_qinq_supported;
 	u8 function;
 	dma_addr_t vhcr_dma;
+	u16 user_mtu[MLX4_MAX_PORTS + 1];
 	u16 mtu[MLX4_MAX_PORTS + 1];
 	__be32 ib_cap_mask[MLX4_MAX_PORTS + 1];
 	struct mlx4_slave_eqe eq[MLX4_MFUNC_MAX_EQES];
@@ -590,6 +591,7 @@ struct mlx4_mfunc_master_ctx {
 	struct mlx4_master_qp0_state qp0_state[MLX4_MAX_PORTS + 1];
 	int			init_port_ref[MLX4_MAX_PORTS + 1];
 	u16			max_mtu[MLX4_MAX_PORTS + 1];
+	u16			max_user_mtu[MLX4_MAX_PORTS + 1];
 	u8			pptx;
 	u8			pprx;
 	int			disable_mcast_ref[MLX4_MAX_PORTS + 1];
@@ -787,7 +789,7 @@ enum {
 
 struct mlx4_set_port_general_context {
 	u16 reserved1;
-	u8 v_ignore_fcs;
+	u8 flags2;
 	u8 flags;
 	union {
 		u8 ignore_fcs;
@@ -803,7 +805,8 @@ struct mlx4_set_port_general_context {
 	u16 reserved4;
 	u32 reserved5;
 	u8 phv_en;
-	u8 reserved6[3];
+	u8 reserved6[5];
+	__be16 user_mtu;
 };
 
 struct mlx4_set_port_rqp_calc_context {
diff --git a/drivers/net/ethernet/mellanox/mlx4/port.c b/drivers/net/ethernet/mellanox/mlx4/port.c
index b656dd5772e5..a7b0cdcb358a 100644
--- a/drivers/net/ethernet/mellanox/mlx4/port.c
+++ b/drivers/net/ethernet/mellanox/mlx4/port.c
@@ -50,7 +50,8 @@
 #define MLX4_STATS_ERROR_COUNTERS_MASK		0x1ffc30ULL
 #define MLX4_STATS_PORT_COUNTERS_MASK		0x1fe00000ULL
 
-#define MLX4_FLAG_V_IGNORE_FCS_MASK		0x2
+#define MLX4_FLAG2_V_IGNORE_FCS_MASK		BIT(1)
+#define MLX4_FLAG2_V_USER_MTU_MASK		BIT(5)
 #define MLX4_IGNORE_FCS_MASK			0x1
 #define MLX4_TC_MAX_NUMBER			8
 
@@ -1239,6 +1240,38 @@ void mlx4_reset_roce_gids(struct mlx4_dev *dev, int slave)
 	return;
 }
 
+static void
+mlx4_en_set_port_user_mtu(struct mlx4_dev *dev, int slave, int port,
+			  struct mlx4_set_port_general_context *gen_context)
+{
+	struct mlx4_priv *priv = mlx4_priv(dev);
+	struct mlx4_mfunc_master_ctx *master = &priv->mfunc.master;
+	struct mlx4_slave_state *slave_st = &master->slave_state[slave];
+	u16 user_mtu, prev_user_mtu;
+
+	/* User Mtu is configured as the max USER_MTU among all
+	 * the functions on the port.
+	 */
+	user_mtu = be16_to_cpu(gen_context->user_mtu);
+	user_mtu = min_t(int, user_mtu, dev->caps.eth_mtu_cap[port]);
+	prev_user_mtu = slave_st->user_mtu[port];
+	slave_st->user_mtu[port] = user_mtu;
+	if (user_mtu > master->max_user_mtu[port])
+		master->max_user_mtu[port] = user_mtu;
+	if (user_mtu < prev_user_mtu &&
+	    prev_user_mtu == master->max_user_mtu[port]) {
+		int i;
+
+		slave_st->user_mtu[port] = user_mtu;
+		master->max_user_mtu[port] = user_mtu;
+		for (i = 0; i < dev->num_slaves; i++)
+			master->max_user_mtu[port] =
+				max_t(u16, master->max_user_mtu[port],
+				      master->slave_state[i].user_mtu[port]);
+	}
+	gen_context->user_mtu = cpu_to_be16(master->max_user_mtu[port]);
+}
+
 static int mlx4_common_set_port(struct mlx4_dev *dev, int slave, u32 in_mod,
 				u8 op_mod, struct mlx4_cmd_mailbox *inbox)
 {
@@ -1269,7 +1302,9 @@ static int mlx4_common_set_port(struct mlx4_dev *dev, int slave, u32 in_mod,
 	is_eth = op_mod;
 	port_info = &priv->port[port];
 
-	/* Slaves cannot perform SET_PORT operations except changing MTU */
+	/* Slaves cannot perform SET_PORT operations,
+	 * except for changing MTU and USER_MTU.
+	 */
 	if (is_eth) {
 		if (slave != dev->caps.function &&
 		    in_modifier != MLX4_SET_PORT_GENERAL &&
@@ -1316,8 +1351,12 @@ static int mlx4_common_set_port(struct mlx4_dev *dev, int slave, u32 in_mod,
 					    master->slave_state[i].mtu[port]);
 				}
 			}
-
 			gen_context->mtu = cpu_to_be16(master->max_mtu[port]);
+
+			if (gen_context->flags2 & MLX4_FLAG2_V_USER_MTU_MASK)
+				mlx4_en_set_port_user_mtu(dev, slave, port,
+							  gen_context);
+
 			/* Slave cannot change Global Pause configuration */
 			if (slave != mlx4_master_func_num(dev) &&
 			    ((gen_context->pptx != master->pptx) ||
@@ -1608,6 +1647,30 @@ int mlx4_SET_PORT_qpn_calc(struct mlx4_dev *dev, u8 port, u32 base_qpn,
 }
 EXPORT_SYMBOL(mlx4_SET_PORT_qpn_calc);
 
+int mlx4_SET_PORT_user_mtu(struct mlx4_dev *dev, u8 port, u16 user_mtu)
+{
+	struct mlx4_cmd_mailbox *mailbox;
+	struct mlx4_set_port_general_context *context;
+	u32 in_mod;
+	int err;
+
+	mailbox = mlx4_alloc_cmd_mailbox(dev);
+	if (IS_ERR(mailbox))
+		return PTR_ERR(mailbox);
+	context = mailbox->buf;
+	context->flags2 |= MLX4_FLAG2_V_USER_MTU_MASK;
+	context->user_mtu = cpu_to_be16(user_mtu);
+
+	in_mod = MLX4_SET_PORT_GENERAL << 8 | port;
+	err = mlx4_cmd(dev, mailbox->dma, in_mod, MLX4_SET_PORT_ETH_OPCODE,
+		       MLX4_CMD_SET_PORT, MLX4_CMD_TIME_CLASS_B,
+		       MLX4_CMD_WRAPPED);
+
+	mlx4_free_cmd_mailbox(dev, mailbox);
+	return err;
+}
+EXPORT_SYMBOL(mlx4_SET_PORT_user_mtu);
+
 int mlx4_SET_PORT_fcs_check(struct mlx4_dev *dev, u8 port, u8 ignore_fcs_value)
 {
 	struct mlx4_cmd_mailbox *mailbox;
@@ -1619,7 +1682,7 @@ int mlx4_SET_PORT_fcs_check(struct mlx4_dev *dev, u8 port, u8 ignore_fcs_value)
 	if (IS_ERR(mailbox))
 		return PTR_ERR(mailbox);
 	context = mailbox->buf;
-	context->v_ignore_fcs |= MLX4_FLAG_V_IGNORE_FCS_MASK;
+	context->flags2 |= MLX4_FLAG2_V_IGNORE_FCS_MASK;
 	if (ignore_fcs_value)
 		context->ignore_fcs |= MLX4_IGNORE_FCS_MASK;
 	else
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index c3ac945b2759..7e66e4f62858 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -1374,6 +1374,7 @@ int mlx4_flow_steer_promisc_remove(struct mlx4_dev *dev, u8 port,
 int __mlx4_replace_mac(struct mlx4_dev *dev, u8 port, int qpn, u64 new_mac);
 int mlx4_SET_PORT_general(struct mlx4_dev *dev, u8 port, int mtu,
 			  u8 pptx, u8 pfctx, u8 pprx, u8 pfcrx);
+int mlx4_SET_PORT_user_mtu(struct mlx4_dev *dev, u8 port, u16 user_mtu);
 int mlx4_SET_PORT_qpn_calc(struct mlx4_dev *dev, u8 port, u32 base_qpn,
 			   u8 promisc);
 int mlx4_SET_PORT_BEACON(struct mlx4_dev *dev, u8 port, u16 time);
-- 
1.8.3.1
