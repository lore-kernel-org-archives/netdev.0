From: Yevgeny Petrilin <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
Subject: [PATCH net-next V1 03/21] mlx4_core: Add "native" argument to mlx4_cmd
 and its callers (where needed)
Date: Mon, 12 Dec 2011 16:43:10 +0200
Message-ID: <4EE612FE.3080704@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>, <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>,
	<liranl-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>, <jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
To: <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Jack Morgenstein <jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>

For SRIOV, some Hypervisor commands can be executed directly (native = 1).
Others should go through the command wrapper flow (for tracking resource
usage, for example, or for changing some HCA configurations that slaves
need to be notified of).

This patch sets the groundwork for this capability -- adding the correct
value of "native" in each case.

Note that if SRIOV is not activated, this parameter has no effect.

Signed-off-by: Jack Morgenstein <jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
---
 drivers/infiniband/hw/mlx4/mad.c                 |    6 ++-
 drivers/infiniband/hw/mlx4/main.c                |    7 ++-
 drivers/net/ethernet/mellanox/mlx4/cmd.c         |    2 +-
 drivers/net/ethernet/mellanox/mlx4/cq.c          |    6 +-
 drivers/net/ethernet/mellanox/mlx4/en_port.c     |   15 ++++---
 drivers/net/ethernet/mellanox/mlx4/en_selftest.c |    2 +-
 drivers/net/ethernet/mellanox/mlx4/eq.c          |    9 +++-
 drivers/net/ethernet/mellanox/mlx4/fw.c          |   45 +++++++++++++---------
 drivers/net/ethernet/mellanox/mlx4/icm.c         |    5 +-
 drivers/net/ethernet/mellanox/mlx4/mcg.c         |   10 +++--
 drivers/net/ethernet/mellanox/mlx4/mr.c          |    8 ++-
 drivers/net/ethernet/mellanox/mlx4/port.c        |   12 +++--
 drivers/net/ethernet/mellanox/mlx4/qp.c          |   11 +++--
 drivers/net/ethernet/mellanox/mlx4/sense.c       |    3 +-
 drivers/net/ethernet/mellanox/mlx4/srq.c         |    8 ++--
 include/linux/mlx4/cmd.h                         |   20 ++++++---
 16 files changed, 102 insertions(+), 67 deletions(-)

diff --git a/drivers/infiniband/hw/mlx4/mad.c b/drivers/infiniband/hw/mlx4/mad.c
index f36da99..95c94d8 100644
--- a/drivers/infiniband/hw/mlx4/mad.c
+++ b/drivers/infiniband/hw/mlx4/mad.c
@@ -109,7 +109,8 @@ int mlx4_MAD_IFC(struct mlx4_ib_dev *dev, int ignore_mkey, int ignore_bkey,
 
 	err = mlx4_cmd_box(dev->dev, inmailbox->dma, outmailbox->dma,
 			   in_modifier, op_modifier,
-			   MLX4_CMD_MAD_IFC, MLX4_CMD_TIME_CLASS_C);
+			   MLX4_CMD_MAD_IFC, MLX4_CMD_TIME_CLASS_C,
+			   MLX4_CMD_NATIVE);
 
 	if (!err)
 		memcpy(response_mad, outmailbox->buf, 256);
@@ -330,7 +331,8 @@ static int iboe_process_mad(struct ib_device *ibdev, int mad_flags, u8 port_num,
 		return IB_MAD_RESULT_FAILURE;
 
 	err = mlx4_cmd_box(dev->dev, 0, mailbox->dma, inmod, 0,
-			   MLX4_CMD_QUERY_IF_STAT, MLX4_CMD_TIME_CLASS_C);
+			   MLX4_CMD_QUERY_IF_STAT, MLX4_CMD_TIME_CLASS_C,
+			   MLX4_CMD_WRAPPED);
 	if (err)
 		err = IB_MAD_RESULT_FAILURE;
 	else {
diff --git a/drivers/infiniband/hw/mlx4/main.c b/drivers/infiniband/hw/mlx4/main.c
index 6128b29..34f8a5d 100644
--- a/drivers/infiniband/hw/mlx4/main.c
+++ b/drivers/infiniband/hw/mlx4/main.c
@@ -434,7 +434,7 @@ static int mlx4_ib_modify_device(struct ib_device *ibdev, int mask,
 	memset(mailbox->buf, 0, 256);
 	memcpy(mailbox->buf, props->node_desc, 64);
 	mlx4_cmd(to_mdev(ibdev)->dev, mailbox->dma, 1, 0,
-		 MLX4_CMD_SET_NODE, MLX4_CMD_TIME_CLASS_A);
+		 MLX4_CMD_SET_NODE, MLX4_CMD_TIME_CLASS_A, MLX4_CMD_WRAPPED);
 
 	mlx4_free_cmd_mailbox(to_mdev(ibdev)->dev, mailbox);
 
@@ -463,7 +463,7 @@ static int mlx4_SET_PORT(struct mlx4_ib_dev *dev, u8 port, int reset_qkey_viols,
 	}
 
 	err = mlx4_cmd(dev->dev, mailbox->dma, port, is_eth, MLX4_CMD_SET_PORT,
-		       MLX4_CMD_TIME_CLASS_B);
+		       MLX4_CMD_TIME_CLASS_B, MLX4_CMD_NATIVE);
 
 	mlx4_free_cmd_mailbox(dev->dev, mailbox);
 	return err;
@@ -899,7 +899,8 @@ static void update_gids_task(struct work_struct *work)
 	memcpy(gids, gw->gids, sizeof gw->gids);
 
 	err = mlx4_cmd(dev, mailbox->dma, MLX4_SET_PORT_GID_TABLE << 8 | gw->port,
-		       1, MLX4_CMD_SET_PORT, MLX4_CMD_TIME_CLASS_B);
+		       1, MLX4_CMD_SET_PORT, MLX4_CMD_TIME_CLASS_B,
+		       MLX4_CMD_NATIVE);
 	if (err)
 		printk(KERN_WARNING "set port command failed\n");
 	else {
diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/ethernet/mellanox/mlx4/cmd.c
index 78f5a1a..b27654e 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
@@ -311,7 +311,7 @@ out:
 
 int __mlx4_cmd(struct mlx4_dev *dev, u64 in_param, u64 *out_param,
 	       int out_is_imm, u32 in_modifier, u8 op_modifier,
-	       u16 op, unsigned long timeout)
+	       u16 op, unsigned long timeout, int native)
 {
 	if (mlx4_priv(dev)->cmd.use_events)
 		return mlx4_cmd_wait(dev, in_param, out_param, out_is_imm,
diff --git a/drivers/net/ethernet/mellanox/mlx4/cq.c b/drivers/net/ethernet/mellanox/mlx4/cq.c
index 499a516..ebd0eb2 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cq.c
@@ -118,14 +118,14 @@ static int mlx4_SW2HW_CQ(struct mlx4_dev *dev, struct mlx4_cmd_mailbox *mailbox,
 			 int cq_num)
 {
 	return mlx4_cmd(dev, mailbox->dma, cq_num, 0, MLX4_CMD_SW2HW_CQ,
-			MLX4_CMD_TIME_CLASS_A);
+			MLX4_CMD_TIME_CLASS_A, MLX4_CMD_WRAPPED);
 }
 
 static int mlx4_MODIFY_CQ(struct mlx4_dev *dev, struct mlx4_cmd_mailbox *mailbox,
 			 int cq_num, u32 opmod)
 {
 	return mlx4_cmd(dev, mailbox->dma, cq_num, opmod, MLX4_CMD_MODIFY_CQ,
-			MLX4_CMD_TIME_CLASS_A);
+			MLX4_CMD_TIME_CLASS_A, MLX4_CMD_WRAPPED);
 }
 
 static int mlx4_HW2SW_CQ(struct mlx4_dev *dev, struct mlx4_cmd_mailbox *mailbox,
@@ -133,7 +133,7 @@ static int mlx4_HW2SW_CQ(struct mlx4_dev *dev, struct mlx4_cmd_mailbox *mailbox,
 {
 	return mlx4_cmd_box(dev, 0, mailbox ? mailbox->dma : 0, cq_num,
 			    mailbox ? 0 : 1, MLX4_CMD_HW2SW_CQ,
-			    MLX4_CMD_TIME_CLASS_A);
+			    MLX4_CMD_TIME_CLASS_A, MLX4_CMD_WRAPPED);
 }
 
 int mlx4_cq_modify(struct mlx4_dev *dev, struct mlx4_cq *cq,
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_port.c b/drivers/net/ethernet/mellanox/mlx4/en_port.c
index 03c84cd..ae120ef 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_port.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_port.c
@@ -45,7 +45,8 @@ int mlx4_SET_MCAST_FLTR(struct mlx4_dev *dev, u8 port,
 			u64 mac, u64 clear, u8 mode)
 {
 	return mlx4_cmd(dev, (mac | (clear << 63)), port, mode,
-			MLX4_CMD_SET_MCAST_FLTR, MLX4_CMD_TIME_CLASS_B);
+			MLX4_CMD_SET_MCAST_FLTR, MLX4_CMD_TIME_CLASS_B,
+			MLX4_CMD_WRAPPED);
 }
 
 int mlx4_SET_VLAN_FLTR(struct mlx4_dev *dev, struct mlx4_en_priv *priv)
@@ -72,7 +73,7 @@ int mlx4_SET_VLAN_FLTR(struct mlx4_dev *dev, struct mlx4_en_priv *priv)
 		filter->entry[i] = cpu_to_be32(entry);
 	}
 	err = mlx4_cmd(dev, mailbox->dma, priv->port, 0, MLX4_CMD_SET_VLAN_FLTR,
-		       MLX4_CMD_TIME_CLASS_B);
+		       MLX4_CMD_TIME_CLASS_B, MLX4_CMD_WRAPPED);
 	mlx4_free_cmd_mailbox(dev, mailbox);
 	return err;
 }
@@ -101,7 +102,7 @@ int mlx4_SET_PORT_general(struct mlx4_dev *dev, u8 port, int mtu,
 
 	in_mod = MLX4_SET_PORT_GENERAL << 8 | port;
 	err = mlx4_cmd(dev, mailbox->dma, in_mod, 1, MLX4_CMD_SET_PORT,
-		       MLX4_CMD_TIME_CLASS_B);
+		       MLX4_CMD_TIME_CLASS_B, MLX4_CMD_WRAPPED);
 
 	mlx4_free_cmd_mailbox(dev, mailbox);
 	return err;
@@ -140,7 +141,7 @@ int mlx4_SET_PORT_qpn_calc(struct mlx4_dev *dev, u8 port, u32 base_qpn,
 
 	in_mod = MLX4_SET_PORT_RQP_CALC << 8 | port;
 	err = mlx4_cmd(dev, mailbox->dma, in_mod, 1, MLX4_CMD_SET_PORT,
-		       MLX4_CMD_TIME_CLASS_B);
+		       MLX4_CMD_TIME_CLASS_B, MLX4_CMD_WRAPPED);
 
 	mlx4_free_cmd_mailbox(dev, mailbox);
 	return err;
@@ -159,7 +160,8 @@ int mlx4_en_QUERY_PORT(struct mlx4_en_dev *mdev, u8 port)
 		return PTR_ERR(mailbox);
 	memset(mailbox->buf, 0, sizeof(*qport_context));
 	err = mlx4_cmd_box(mdev->dev, 0, mailbox->dma, port, 0,
-			   MLX4_CMD_QUERY_PORT, MLX4_CMD_TIME_CLASS_B);
+			   MLX4_CMD_QUERY_PORT, MLX4_CMD_TIME_CLASS_B,
+			   MLX4_CMD_WRAPPED);
 	if (err)
 		goto out;
 	qport_context = mailbox->buf;
@@ -204,7 +206,8 @@ int mlx4_en_DUMP_ETH_STATS(struct mlx4_en_dev *mdev, u8 port, u8 reset)
 		return PTR_ERR(mailbox);
 	memset(mailbox->buf, 0, sizeof(*mlx4_en_stats));
 	err = mlx4_cmd_box(mdev->dev, 0, mailbox->dma, in_mod, 0,
-			   MLX4_CMD_DUMP_ETH_STATS, MLX4_CMD_TIME_CLASS_B);
+			   MLX4_CMD_DUMP_ETH_STATS, MLX4_CMD_TIME_CLASS_B,
+			   MLX4_CMD_WRAPPED);
 	if (err)
 		goto out;
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_selftest.c b/drivers/net/ethernet/mellanox/mlx4/en_selftest.c
index 9fdbcec..bf2e5d3 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_selftest.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_selftest.c
@@ -43,7 +43,7 @@
 static int mlx4_en_test_registers(struct mlx4_en_priv *priv)
 {
 	return mlx4_cmd(priv->mdev->dev, 0, 0, 0, MLX4_CMD_HW_HEALTH_CHECK,
-			MLX4_CMD_TIME_CLASS_A);
+			MLX4_CMD_TIME_CLASS_A, MLX4_CMD_WRAPPED);
 }
 
 static int mlx4_en_test_loopback_xmit(struct mlx4_en_priv *priv)
diff --git a/drivers/net/ethernet/mellanox/mlx4/eq.c b/drivers/net/ethernet/mellanox/mlx4/eq.c
index ad9e377..9e5863d 100644
--- a/drivers/net/ethernet/mellanox/mlx4/eq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/eq.c
@@ -255,21 +255,24 @@ static int mlx4_MAP_EQ(struct mlx4_dev *dev, u64 event_mask, int unmap,
 			int eq_num)
 {
 	return mlx4_cmd(dev, event_mask, (unmap << 31) | eq_num,
-			0, MLX4_CMD_MAP_EQ, MLX4_CMD_TIME_CLASS_B);
+			0, MLX4_CMD_MAP_EQ, MLX4_CMD_TIME_CLASS_B,
+			MLX4_CMD_WRAPPED);
 }
 
 static int mlx4_SW2HW_EQ(struct mlx4_dev *dev, struct mlx4_cmd_mailbox *mailbox,
 			 int eq_num)
 {
 	return mlx4_cmd(dev, mailbox->dma, eq_num, 0, MLX4_CMD_SW2HW_EQ,
-			MLX4_CMD_TIME_CLASS_A);
+			MLX4_CMD_TIME_CLASS_A,
+			MLX4_CMD_WRAPPED);
 }
 
 static int mlx4_HW2SW_EQ(struct mlx4_dev *dev, struct mlx4_cmd_mailbox *mailbox,
 			 int eq_num)
 {
 	return mlx4_cmd_box(dev, 0, mailbox->dma, eq_num, 0, MLX4_CMD_HW2SW_EQ,
-			    MLX4_CMD_TIME_CLASS_A);
+			    MLX4_CMD_TIME_CLASS_A,
+			    MLX4_CMD_WRAPPED);
 }
 
 static int mlx4_num_eq_uar(struct mlx4_dev *dev)
diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index 435ca6e..9659fb0 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -139,7 +139,7 @@ int mlx4_MOD_STAT_CFG(struct mlx4_dev *dev, struct mlx4_mod_stat_cfg *cfg)
 	MLX4_PUT(inbox, cfg->log_pg_sz_m, MOD_STAT_CFG_PG_SZ_M_OFFSET);
 
 	err = mlx4_cmd(dev, mailbox->dma, 0, 0, MLX4_CMD_MOD_STAT_CFG,
-			MLX4_CMD_TIME_CLASS_A);
+			MLX4_CMD_TIME_CLASS_A, MLX4_CMD_NATIVE);
 
 	mlx4_free_cmd_mailbox(dev, mailbox);
 	return err;
@@ -229,7 +229,7 @@ int mlx4_QUERY_DEV_CAP(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 	outbox = mailbox->buf;
 
 	err = mlx4_cmd_box(dev, 0, mailbox->dma, 0, 0, MLX4_CMD_QUERY_DEV_CAP,
-			   MLX4_CMD_TIME_CLASS_A);
+			   MLX4_CMD_TIME_CLASS_A, !mlx4_is_slave(dev));
 	if (err)
 		goto out;
 
@@ -396,7 +396,8 @@ int mlx4_QUERY_DEV_CAP(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 
 		for (i = 1; i <= dev_cap->num_ports; ++i) {
 			err = mlx4_cmd_box(dev, 0, mailbox->dma, i, 0, MLX4_CMD_QUERY_PORT,
-					   MLX4_CMD_TIME_CLASS_B);
+					   MLX4_CMD_TIME_CLASS_B,
+					   !mlx4_is_slave(dev));
 			if (err)
 				goto out;
 
@@ -519,7 +520,8 @@ int mlx4_map_cmd(struct mlx4_dev *dev, u16 op, struct mlx4_icm *icm, u64 virt)
 
 			if (++nent == MLX4_MAILBOX_SIZE / 16) {
 				err = mlx4_cmd(dev, mailbox->dma, nent, 0, op,
-						MLX4_CMD_TIME_CLASS_B);
+						MLX4_CMD_TIME_CLASS_B,
+						MLX4_CMD_NATIVE);
 				if (err)
 					goto out;
 				nent = 0;
@@ -528,7 +530,8 @@ int mlx4_map_cmd(struct mlx4_dev *dev, u16 op, struct mlx4_icm *icm, u64 virt)
 	}
 
 	if (nent)
-		err = mlx4_cmd(dev, mailbox->dma, nent, 0, op, MLX4_CMD_TIME_CLASS_B);
+		err = mlx4_cmd(dev, mailbox->dma, nent, 0, op,
+			       MLX4_CMD_TIME_CLASS_B, MLX4_CMD_NATIVE);
 	if (err)
 		goto out;
 
@@ -557,13 +560,15 @@ int mlx4_MAP_FA(struct mlx4_dev *dev, struct mlx4_icm *icm)
 
 int mlx4_UNMAP_FA(struct mlx4_dev *dev)
 {
-	return mlx4_cmd(dev, 0, 0, 0, MLX4_CMD_UNMAP_FA, MLX4_CMD_TIME_CLASS_B);
+	return mlx4_cmd(dev, 0, 0, 0, MLX4_CMD_UNMAP_FA,
+			MLX4_CMD_TIME_CLASS_B, MLX4_CMD_NATIVE);
 }
 
 
 int mlx4_RUN_FW(struct mlx4_dev *dev)
 {
-	return mlx4_cmd(dev, 0, 0, 0, MLX4_CMD_RUN_FW, MLX4_CMD_TIME_CLASS_A);
+	return mlx4_cmd(dev, 0, 0, 0, MLX4_CMD_RUN_FW,
+			MLX4_CMD_TIME_CLASS_A, MLX4_CMD_NATIVE);
 }
 
 int mlx4_QUERY_FW(struct mlx4_dev *dev)
@@ -595,7 +600,7 @@ int mlx4_QUERY_FW(struct mlx4_dev *dev)
 	outbox = mailbox->buf;
 
 	err = mlx4_cmd_box(dev, 0, mailbox->dma, 0, 0, MLX4_CMD_QUERY_FW,
-			    MLX4_CMD_TIME_CLASS_A);
+			    MLX4_CMD_TIME_CLASS_A, MLX4_CMD_NATIVE);
 	if (err)
 		goto out;
 
@@ -711,7 +716,7 @@ int mlx4_QUERY_ADAPTER(struct mlx4_dev *dev, struct mlx4_adapter *adapter)
 	outbox = mailbox->buf;
 
 	err = mlx4_cmd_box(dev, 0, mailbox->dma, 0, 0, MLX4_CMD_QUERY_ADAPTER,
-			   MLX4_CMD_TIME_CLASS_A);
+			   MLX4_CMD_TIME_CLASS_A, MLX4_CMD_NATIVE);
 	if (err)
 		goto out;
 
@@ -834,7 +839,8 @@ int mlx4_INIT_HCA(struct mlx4_dev *dev, struct mlx4_init_hca_param *param)
 	MLX4_PUT(inbox, (u8) (PAGE_SHIFT - 12), INIT_HCA_UAR_PAGE_SZ_OFFSET);
 	MLX4_PUT(inbox, param->log_uar_sz,      INIT_HCA_LOG_UAR_SZ_OFFSET);
 
-	err = mlx4_cmd(dev, mailbox->dma, 0, 0, MLX4_CMD_INIT_HCA, 10000);
+	err = mlx4_cmd(dev, mailbox->dma, 0, 0, MLX4_CMD_INIT_HCA, 10000,
+		       MLX4_CMD_NATIVE);
 
 	if (err)
 		mlx4_err(dev, "INIT_HCA returns %d\n", err);
@@ -886,12 +892,12 @@ int mlx4_INIT_PORT(struct mlx4_dev *dev, int port)
 		MLX4_PUT(inbox, field, INIT_PORT_MAX_PKEY_OFFSET);
 
 		err = mlx4_cmd(dev, mailbox->dma, port, 0, MLX4_CMD_INIT_PORT,
-			       MLX4_CMD_TIME_CLASS_A);
+			       MLX4_CMD_TIME_CLASS_A, MLX4_CMD_NATIVE);
 
 		mlx4_free_cmd_mailbox(dev, mailbox);
 	} else
 		err = mlx4_cmd(dev, 0, port, 0, MLX4_CMD_INIT_PORT,
-			       MLX4_CMD_TIME_CLASS_A);
+			       MLX4_CMD_TIME_CLASS_A, MLX4_CMD_WRAPPED);
 
 	return err;
 }
@@ -899,20 +905,22 @@ EXPORT_SYMBOL_GPL(mlx4_INIT_PORT);
 
 int mlx4_CLOSE_PORT(struct mlx4_dev *dev, int port)
 {
-	return mlx4_cmd(dev, 0, port, 0, MLX4_CMD_CLOSE_PORT, 1000);
+	return mlx4_cmd(dev, 0, port, 0, MLX4_CMD_CLOSE_PORT, 1000,
+			MLX4_CMD_WRAPPED);
 }
 EXPORT_SYMBOL_GPL(mlx4_CLOSE_PORT);
 
 int mlx4_CLOSE_HCA(struct mlx4_dev *dev, int panic)
 {
-	return mlx4_cmd(dev, 0, 0, panic, MLX4_CMD_CLOSE_HCA, 1000);
+	return mlx4_cmd(dev, 0, 0, panic, MLX4_CMD_CLOSE_HCA, 1000,
+			MLX4_CMD_NATIVE);
 }
 
 int mlx4_SET_ICM_SIZE(struct mlx4_dev *dev, u64 icm_size, u64 *aux_pages)
 {
 	int ret = mlx4_cmd_imm(dev, icm_size, aux_pages, 0, 0,
 			       MLX4_CMD_SET_ICM_SIZE,
-			       MLX4_CMD_TIME_CLASS_A);
+			       MLX4_CMD_TIME_CLASS_A, MLX4_CMD_NATIVE);
 	if (ret)
 		return ret;
 
@@ -929,7 +937,7 @@ int mlx4_SET_ICM_SIZE(struct mlx4_dev *dev, u64 icm_size, u64 *aux_pages)
 int mlx4_NOP(struct mlx4_dev *dev)
 {
 	/* Input modifier of 0x1f means "finish as soon as possible." */
-	return mlx4_cmd(dev, 0, 0x1f, 0, MLX4_CMD_NOP, 100);
+	return mlx4_cmd(dev, 0, 0x1f, 0, MLX4_CMD_NOP, 100, MLX4_CMD_NATIVE);
 }
 
 #define MLX4_WOL_SETUP_MODE (5 << 28)
@@ -938,7 +946,8 @@ int mlx4_wol_read(struct mlx4_dev *dev, u64 *config, int port)
 	u32 in_mod = MLX4_WOL_SETUP_MODE | port << 8;
 
 	return mlx4_cmd_imm(dev, 0, config, in_mod, 0x3,
-			    MLX4_CMD_MOD_STAT_CFG, MLX4_CMD_TIME_CLASS_A);
+			    MLX4_CMD_MOD_STAT_CFG, MLX4_CMD_TIME_CLASS_A,
+			    MLX4_CMD_NATIVE);
 }
 EXPORT_SYMBOL_GPL(mlx4_wol_read);
 
@@ -947,6 +956,6 @@ int mlx4_wol_write(struct mlx4_dev *dev, u64 config, int port)
 	u32 in_mod = MLX4_WOL_SETUP_MODE | port << 8;
 
 	return mlx4_cmd(dev, config, in_mod, 0x1, MLX4_CMD_MOD_STAT_CFG,
-					MLX4_CMD_TIME_CLASS_A);
+			MLX4_CMD_TIME_CLASS_A, MLX4_CMD_NATIVE);
 }
 EXPORT_SYMBOL_GPL(mlx4_wol_write);
diff --git a/drivers/net/ethernet/mellanox/mlx4/icm.c b/drivers/net/ethernet/mellanox/mlx4/icm.c
index 02393fd..a9ade1c 100644
--- a/drivers/net/ethernet/mellanox/mlx4/icm.c
+++ b/drivers/net/ethernet/mellanox/mlx4/icm.c
@@ -213,7 +213,7 @@ static int mlx4_MAP_ICM(struct mlx4_dev *dev, struct mlx4_icm *icm, u64 virt)
 static int mlx4_UNMAP_ICM(struct mlx4_dev *dev, u64 virt, u32 page_count)
 {
 	return mlx4_cmd(dev, virt, page_count, 0, MLX4_CMD_UNMAP_ICM,
-			MLX4_CMD_TIME_CLASS_B);
+			MLX4_CMD_TIME_CLASS_B, MLX4_CMD_NATIVE);
 }
 
 int mlx4_MAP_ICM_AUX(struct mlx4_dev *dev, struct mlx4_icm *icm)
@@ -223,7 +223,8 @@ int mlx4_MAP_ICM_AUX(struct mlx4_dev *dev, struct mlx4_icm *icm)
 
 int mlx4_UNMAP_ICM_AUX(struct mlx4_dev *dev)
 {
-	return mlx4_cmd(dev, 0, 0, 0, MLX4_CMD_UNMAP_ICM_AUX, MLX4_CMD_TIME_CLASS_B);
+	return mlx4_cmd(dev, 0, 0, 0, MLX4_CMD_UNMAP_ICM_AUX,
+			MLX4_CMD_TIME_CLASS_B, MLX4_CMD_NATIVE);
 }
 
 int mlx4_table_get(struct mlx4_dev *dev, struct mlx4_icm_table *table, int obj)
diff --git a/drivers/net/ethernet/mellanox/mlx4/mcg.c b/drivers/net/ethernet/mellanox/mlx4/mcg.c
index 978688c..4187f7b 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mcg.c
+++ b/drivers/net/ethernet/mellanox/mlx4/mcg.c
@@ -48,14 +48,14 @@ static int mlx4_READ_ENTRY(struct mlx4_dev *dev, int index,
 			   struct mlx4_cmd_mailbox *mailbox)
 {
 	return mlx4_cmd_box(dev, 0, mailbox->dma, index, 0, MLX4_CMD_READ_MCG,
-			    MLX4_CMD_TIME_CLASS_A);
+			    MLX4_CMD_TIME_CLASS_A, MLX4_CMD_NATIVE);
 }
 
 static int mlx4_WRITE_ENTRY(struct mlx4_dev *dev, int index,
 			    struct mlx4_cmd_mailbox *mailbox)
 {
 	return mlx4_cmd(dev, mailbox->dma, index, 0, MLX4_CMD_WRITE_MCG,
-			MLX4_CMD_TIME_CLASS_A);
+			MLX4_CMD_TIME_CLASS_A, MLX4_CMD_NATIVE);
 }
 
 static int mlx4_WRITE_PROMISC(struct mlx4_dev *dev, u8 vep_num, u8 port, u8 steer,
@@ -65,7 +65,8 @@ static int mlx4_WRITE_PROMISC(struct mlx4_dev *dev, u8 vep_num, u8 port, u8 stee
 
 	in_mod = (u32) vep_num << 24 | (u32) port << 16 | steer << 1;
 	return mlx4_cmd(dev, mailbox->dma, in_mod, 0x1,
-			MLX4_CMD_WRITE_MCG, MLX4_CMD_TIME_CLASS_A);
+			MLX4_CMD_WRITE_MCG, MLX4_CMD_TIME_CLASS_A,
+			MLX4_CMD_NATIVE);
 }
 
 static int mlx4_GID_HASH(struct mlx4_dev *dev, struct mlx4_cmd_mailbox *mailbox,
@@ -75,7 +76,8 @@ static int mlx4_GID_HASH(struct mlx4_dev *dev, struct mlx4_cmd_mailbox *mailbox,
 	int err;
 
 	err = mlx4_cmd_imm(dev, mailbox->dma, &imm, 0, op_mod,
-			   MLX4_CMD_MGID_HASH, MLX4_CMD_TIME_CLASS_A);
+			   MLX4_CMD_MGID_HASH, MLX4_CMD_TIME_CLASS_A,
+			   MLX4_CMD_NATIVE);
 
 	if (!err)
 		*hash = imm;
diff --git a/drivers/net/ethernet/mellanox/mlx4/mr.c b/drivers/net/ethernet/mellanox/mlx4/mr.c
index efa3e77..057b22d 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mr.c
+++ b/drivers/net/ethernet/mellanox/mlx4/mr.c
@@ -254,14 +254,15 @@ static int mlx4_SW2HW_MPT(struct mlx4_dev *dev, struct mlx4_cmd_mailbox *mailbox
 			  int mpt_index)
 {
 	return mlx4_cmd(dev, mailbox->dma, mpt_index, 0, MLX4_CMD_SW2HW_MPT,
-			MLX4_CMD_TIME_CLASS_B);
+			MLX4_CMD_TIME_CLASS_B, MLX4_CMD_WRAPPED);
 }
 
 static int mlx4_HW2SW_MPT(struct mlx4_dev *dev, struct mlx4_cmd_mailbox *mailbox,
 			  int mpt_index)
 {
 	return mlx4_cmd_box(dev, 0, mailbox ? mailbox->dma : 0, mpt_index,
-			    !mailbox, MLX4_CMD_HW2SW_MPT, MLX4_CMD_TIME_CLASS_B);
+			    !mailbox, MLX4_CMD_HW2SW_MPT,
+			    MLX4_CMD_TIME_CLASS_B, MLX4_CMD_WRAPPED);
 }
 
 int mlx4_mr_alloc(struct mlx4_dev *dev, u32 pd, u64 iova, u64 size, u32 access,
@@ -663,6 +664,7 @@ EXPORT_SYMBOL_GPL(mlx4_fmr_free);
 
 int mlx4_SYNC_TPT(struct mlx4_dev *dev)
 {
-	return mlx4_cmd(dev, 0, 0, 0, MLX4_CMD_SYNC_TPT, 1000);
+	return mlx4_cmd(dev, 0, 0, 0, MLX4_CMD_SYNC_TPT, 1000,
+			MLX4_CMD_WRAPPED);
 }
 EXPORT_SYMBOL_GPL(mlx4_SYNC_TPT);
diff --git a/drivers/net/ethernet/mellanox/mlx4/port.c b/drivers/net/ethernet/mellanox/mlx4/port.c
index d942aea..da9f85c6 100644
--- a/drivers/net/ethernet/mellanox/mlx4/port.c
+++ b/drivers/net/ethernet/mellanox/mlx4/port.c
@@ -85,7 +85,7 @@ static int mlx4_set_port_mac_table(struct mlx4_dev *dev, u8 port,
 
 	in_mod = MLX4_SET_PORT_MAC_TABLE << 8 | port;
 	err = mlx4_cmd(dev, mailbox->dma, in_mod, 1, MLX4_CMD_SET_PORT,
-		       MLX4_CMD_TIME_CLASS_B);
+		       MLX4_CMD_TIME_CLASS_B, MLX4_CMD_NATIVE);
 
 	mlx4_free_cmd_mailbox(dev, mailbox);
 	return err;
@@ -326,7 +326,7 @@ static int mlx4_set_port_vlan_table(struct mlx4_dev *dev, u8 port,
 	memcpy(mailbox->buf, entries, MLX4_VLAN_TABLE_SIZE);
 	in_mod = MLX4_SET_PORT_VLAN_TABLE << 8 | port;
 	err = mlx4_cmd(dev, mailbox->dma, in_mod, 1, MLX4_CMD_SET_PORT,
-		       MLX4_CMD_TIME_CLASS_B);
+		       MLX4_CMD_TIME_CLASS_B, MLX4_CMD_WRAPPED);
 
 	mlx4_free_cmd_mailbox(dev, mailbox);
 
@@ -462,7 +462,8 @@ int mlx4_get_port_ib_caps(struct mlx4_dev *dev, u8 port, __be32 *caps)
 	*(__be32 *) (&inbuf[20]) = cpu_to_be32(port);
 
 	err = mlx4_cmd_box(dev, inmailbox->dma, outmailbox->dma, port, 3,
-			   MLX4_CMD_MAD_IFC, MLX4_CMD_TIME_CLASS_C);
+			   MLX4_CMD_MAD_IFC, MLX4_CMD_TIME_CLASS_C,
+			   MLX4_CMD_NATIVE);
 	if (!err)
 		*caps = *(__be32 *) (outbuf + 84);
 	mlx4_free_cmd_mailbox(dev, inmailbox);
@@ -499,7 +500,8 @@ int mlx4_check_ext_port_caps(struct mlx4_dev *dev, u8 port)
 	*(__be32 *) (&inbuf[20]) = cpu_to_be32(port);
 
 	err = mlx4_cmd_box(dev, inmailbox->dma, outmailbox->dma, port, 3,
-			   MLX4_CMD_MAD_IFC, MLX4_CMD_TIME_CLASS_C);
+			   MLX4_CMD_MAD_IFC, MLX4_CMD_TIME_CLASS_C,
+			   MLX4_CMD_NATIVE);
 
 	packet_error = be16_to_cpu(*(__be16 *) (outbuf + 4));
 
@@ -528,7 +530,7 @@ int mlx4_SET_PORT(struct mlx4_dev *dev, u8 port)
 
 	((__be32 *) mailbox->buf)[1] = dev->caps.ib_port_def_cap[port];
 	err = mlx4_cmd(dev, mailbox->dma, port, 0, MLX4_CMD_SET_PORT,
-		       MLX4_CMD_TIME_CLASS_B);
+		       MLX4_CMD_TIME_CLASS_B, MLX4_CMD_WRAPPED);
 
 	mlx4_free_cmd_mailbox(dev, mailbox);
 	return err;
diff --git a/drivers/net/ethernet/mellanox/mlx4/qp.c b/drivers/net/ethernet/mellanox/mlx4/qp.c
index 15f870c..e721f4c 100644
--- a/drivers/net/ethernet/mellanox/mlx4/qp.c
+++ b/drivers/net/ethernet/mellanox/mlx4/qp.c
@@ -119,7 +119,8 @@ int mlx4_qp_modify(struct mlx4_dev *dev, struct mlx4_mtt *mtt,
 
 	if (op[cur_state][new_state] == MLX4_CMD_2RST_QP)
 		return mlx4_cmd(dev, 0, qp->qpn, 2,
-				MLX4_CMD_2RST_QP, MLX4_CMD_TIME_CLASS_A);
+				MLX4_CMD_2RST_QP, MLX4_CMD_TIME_CLASS_A,
+				MLX4_CMD_WRAPPED);
 
 	mailbox = mlx4_alloc_cmd_mailbox(dev);
 	if (IS_ERR(mailbox))
@@ -140,7 +141,8 @@ int mlx4_qp_modify(struct mlx4_dev *dev, struct mlx4_mtt *mtt,
 
 	ret = mlx4_cmd(dev, mailbox->dma, qp->qpn | (!!sqd_event << 31),
 		       new_state == MLX4_QP_STATE_RST ? 2 : 0,
-		       op[cur_state][new_state], MLX4_CMD_TIME_CLASS_C);
+		       op[cur_state][new_state], MLX4_CMD_TIME_CLASS_C,
+		       MLX4_CMD_WRAPPED);
 
 	mlx4_free_cmd_mailbox(dev, mailbox);
 	return ret;
@@ -265,7 +267,7 @@ EXPORT_SYMBOL_GPL(mlx4_qp_free);
 static int mlx4_CONF_SPECIAL_QP(struct mlx4_dev *dev, u32 base_qpn)
 {
 	return mlx4_cmd(dev, 0, base_qpn, 0, MLX4_CMD_CONF_SPECIAL_QP,
-			MLX4_CMD_TIME_CLASS_B);
+			MLX4_CMD_TIME_CLASS_B, MLX4_CMD_NATIVE);
 }
 
 int mlx4_init_qp_table(struct mlx4_dev *dev)
@@ -342,7 +344,8 @@ int mlx4_qp_query(struct mlx4_dev *dev, struct mlx4_qp *qp,
 		return PTR_ERR(mailbox);
 
 	err = mlx4_cmd_box(dev, 0, mailbox->dma, qp->qpn, 0,
-			   MLX4_CMD_QUERY_QP, MLX4_CMD_TIME_CLASS_A);
+			   MLX4_CMD_QUERY_QP, MLX4_CMD_TIME_CLASS_A,
+			   MLX4_CMD_WRAPPED);
 	if (!err)
 		memcpy(context, mailbox->buf + 8, sizeof *context);
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/sense.c b/drivers/net/ethernet/mellanox/mlx4/sense.c
index e2337a7..8024982 100644
--- a/drivers/net/ethernet/mellanox/mlx4/sense.c
+++ b/drivers/net/ethernet/mellanox/mlx4/sense.c
@@ -45,7 +45,8 @@ int mlx4_SENSE_PORT(struct mlx4_dev *dev, int port,
 	int err = 0;
 
 	err = mlx4_cmd_imm(dev, 0, &out_param, port, 0,
-			   MLX4_CMD_SENSE_PORT, MLX4_CMD_TIME_CLASS_B);
+			   MLX4_CMD_SENSE_PORT, MLX4_CMD_TIME_CLASS_B,
+			   MLX4_CMD_WRAPPED);
 	if (err) {
 		mlx4_err(dev, "Sense command failed for port: %d\n", port);
 		return err;
diff --git a/drivers/net/ethernet/mellanox/mlx4/srq.c b/drivers/net/ethernet/mellanox/mlx4/srq.c
index 9cbf3fc..f4ca096 100644
--- a/drivers/net/ethernet/mellanox/mlx4/srq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/srq.c
@@ -86,7 +86,7 @@ static int mlx4_SW2HW_SRQ(struct mlx4_dev *dev, struct mlx4_cmd_mailbox *mailbox
 			  int srq_num)
 {
 	return mlx4_cmd(dev, mailbox->dma, srq_num, 0, MLX4_CMD_SW2HW_SRQ,
-			MLX4_CMD_TIME_CLASS_A);
+			MLX4_CMD_TIME_CLASS_A, MLX4_CMD_WRAPPED);
 }
 
 static int mlx4_HW2SW_SRQ(struct mlx4_dev *dev, struct mlx4_cmd_mailbox *mailbox,
@@ -94,20 +94,20 @@ static int mlx4_HW2SW_SRQ(struct mlx4_dev *dev, struct mlx4_cmd_mailbox *mailbox
 {
 	return mlx4_cmd_box(dev, 0, mailbox ? mailbox->dma : 0, srq_num,
 			    mailbox ? 0 : 1, MLX4_CMD_HW2SW_SRQ,
-			    MLX4_CMD_TIME_CLASS_A);
+			    MLX4_CMD_TIME_CLASS_A, MLX4_CMD_WRAPPED);
 }
 
 static int mlx4_ARM_SRQ(struct mlx4_dev *dev, int srq_num, int limit_watermark)
 {
 	return mlx4_cmd(dev, limit_watermark, srq_num, 0, MLX4_CMD_ARM_SRQ,
-			MLX4_CMD_TIME_CLASS_B);
+			MLX4_CMD_TIME_CLASS_B, MLX4_CMD_WRAPPED);
 }
 
 static int mlx4_QUERY_SRQ(struct mlx4_dev *dev, struct mlx4_cmd_mailbox *mailbox,
 			  int srq_num)
 {
 	return mlx4_cmd_box(dev, 0, mailbox->dma, srq_num, 0, MLX4_CMD_QUERY_SRQ,
-			    MLX4_CMD_TIME_CLASS_A);
+			    MLX4_CMD_TIME_CLASS_A, MLX4_CMD_WRAPPED);
 }
 
 int mlx4_srq_alloc(struct mlx4_dev *dev, u32 pdn, u32 cqn, u16 xrcd,
diff --git a/include/linux/mlx4/cmd.h b/include/linux/mlx4/cmd.h
index e8e9281..ae62630 100644
--- a/include/linux/mlx4/cmd.h
+++ b/include/linux/mlx4/cmd.h
@@ -173,6 +173,11 @@ enum {
 	MLX4_SET_PORT_GID_TABLE = 0x5,
 };
 
+enum {
+	MLX4_CMD_WRAPPED,
+	MLX4_CMD_NATIVE
+};
+
 struct mlx4_dev;
 
 struct mlx4_cmd_mailbox {
@@ -182,23 +187,24 @@ struct mlx4_cmd_mailbox {
 
 int __mlx4_cmd(struct mlx4_dev *dev, u64 in_param, u64 *out_param,
 	       int out_is_imm, u32 in_modifier, u8 op_modifier,
-	       u16 op, unsigned long timeout);
+	       u16 op, unsigned long timeout, int native);
 
 /* Invoke a command with no output parameter */
 static inline int mlx4_cmd(struct mlx4_dev *dev, u64 in_param, u32 in_modifier,
-			   u8 op_modifier, u16 op, unsigned long timeout)
+			   u8 op_modifier, u16 op, unsigned long timeout,
+			   int native)
 {
 	return __mlx4_cmd(dev, in_param, NULL, 0, in_modifier,
-			  op_modifier, op, timeout);
+			  op_modifier, op, timeout, native);
 }
 
 /* Invoke a command with an output mailbox */
 static inline int mlx4_cmd_box(struct mlx4_dev *dev, u64 in_param, u64 out_param,
 			       u32 in_modifier, u8 op_modifier, u16 op,
-			       unsigned long timeout)
+			       unsigned long timeout, int native)
 {
 	return __mlx4_cmd(dev, in_param, &out_param, 0, in_modifier,
-			  op_modifier, op, timeout);
+			  op_modifier, op, timeout, native);
 }
 
 /*
@@ -208,10 +214,10 @@ static inline int mlx4_cmd_box(struct mlx4_dev *dev, u64 in_param, u64 out_param
  */
 static inline int mlx4_cmd_imm(struct mlx4_dev *dev, u64 in_param, u64 *out_param,
 			       u32 in_modifier, u8 op_modifier, u16 op,
-			       unsigned long timeout)
+			       unsigned long timeout, int native)
 {
 	return __mlx4_cmd(dev, in_param, out_param, 1, in_modifier,
-			  op_modifier, op, timeout);
+			  op_modifier, op, timeout, native);
 }
 
 struct mlx4_cmd_mailbox *mlx4_alloc_cmd_mailbox(struct mlx4_dev *dev);
-- 
1.7.7






--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
