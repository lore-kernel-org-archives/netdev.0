From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 2/2] net/mlx5e: Add ethtool get/set reg support
Date: Wed,  7 Dec 2016 00:33:10 +0200
Message-ID: <1481063590-7727-3-git-send-email-saeedm@mellanox.com>
References: <1481063590-7727-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org,
        "John W . Linville" <linville@tuxdriver.com>,
        Gal Pressman <galp@mellanox.com>,
        Dmitry Teif <dimat@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:54082 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751327AbcLFWdv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2016 17:33:51 -0500
In-Reply-To: <1481063590-7727-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gal Pressman <galp@mellanox.com>

Add ethtool -[dD] callbacks support for get and set registers.
This interface allows users to query and change device registers.

Add the support for set/get DIAGNOSTIC_PARAMS/COUNTERS registers.

Signed-off-by: Gal Pressman <galp@mellanox.com>
Signed-off-by: Dmitry Teif <dimat@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/Makefile   |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/cmd.c      |  19 ----
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |  12 +++
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |  21 ++++
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |   8 ++
 drivers/net/ethernet/mellanox/mlx5/core/en_regs.c  | 116 +++++++++++++++++++++
 include/linux/mlx5/mlx5_ifc.h                      |  22 ++++
 7 files changed, 180 insertions(+), 20 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/en_regs.c

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/Makefile b/drivers/net/ethernet/mellanox/mlx5/core/Makefile
index 9f43beb..b24564c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/Makefile
+++ b/drivers/net/ethernet/mellanox/mlx5/core/Makefile
@@ -8,6 +8,6 @@ mlx5_core-y :=	main.o cmd.o debugfs.o fw.o eq.o uar.o pagealloc.o \
 mlx5_core-$(CONFIG_MLX5_CORE_EN) += wq.o eswitch.o eswitch_offloads.o \
 		en_main.o en_common.o en_fs.o en_ethtool.o en_tx.o \
 		en_rx.o en_rx_am.o en_txrx.o en_clock.o vxlan.o \
-		en_tc.o en_arfs.o en_rep.o en_fs_ethtool.o en_selftest.o
+		en_tc.o en_arfs.o en_rep.o en_fs_ethtool.o en_selftest.o en_regs.o
 
 mlx5_core-$(CONFIG_MLX5_CORE_EN_DCB) +=  en_dcbnl.o
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
index b0448b5..f8b6c83 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
@@ -650,25 +650,6 @@ static int cmd_status_to_err(u8 status)
 	}
 }
 
-struct mlx5_ifc_mbox_out_bits {
-	u8         status[0x8];
-	u8         reserved_at_8[0x18];
-
-	u8         syndrome[0x20];
-
-	u8         reserved_at_40[0x40];
-};
-
-struct mlx5_ifc_mbox_in_bits {
-	u8         opcode[0x10];
-	u8         reserved_at_10[0x10];
-
-	u8         reserved_at_20[0x10];
-	u8         op_mod[0x10];
-
-	u8         reserved_at_40[0x40];
-};
-
 void mlx5_cmd_mbox_status(void *out, u8 *status, u32 *syndrome)
 {
 	*status = MLX5_GET(mbox_out, out, status);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 63dd639..fcc296b 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -659,6 +659,11 @@ struct mlx5e_tir {
 	struct list_head  list;
 };
 
+struct mlx5e_reg {
+	u8  data_in[MLX5_ST_SZ_BYTES(mbox_in)];
+	u8 *data_out;
+};
+
 enum {
 	MLX5E_TC_PRIO = 0,
 	MLX5E_NIC_PRIO
@@ -713,6 +718,7 @@ struct mlx5e_priv {
 	struct mlx5e_stats         stats;
 	struct mlx5e_tstamp        tstamp;
 	u16 q_counter;
+	struct mlx5e_reg          *reg;
 #ifdef CONFIG_MLX5_CORE_EN_DCB
 	struct mlx5e_dcbx          dcbx;
 #endif
@@ -803,6 +809,12 @@ int mlx5e_get_max_linkspeed(struct mlx5_core_dev *mdev, u32 *speed);
 void mlx5e_set_rx_cq_mode_params(struct mlx5e_params *params,
 				 u8 cq_period_mode);
 
+struct mlx5e_reg *mlx5e_regs_init(void);
+int mlx5e_regs_set(struct net_device *dev, void *buff, int inlen);
+void mlx5e_regs_get(struct net_device *dev, void *buff);
+int mlx5e_regs_get_len(void);
+void mlx5e_regs_destroy(struct mlx5e_reg *reg);
+
 static inline void mlx5e_tx_notify_hw(struct mlx5e_sq *sq,
 				      struct mlx5_wqe_ctrl_seg *ctrl, int bf_sz)
 {
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index 352462a..6adc9ea 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -1552,6 +1552,23 @@ static u32 mlx5e_get_priv_flags(struct net_device *netdev)
 	return priv->params.pflags;
 }
 
+static int mlx5e_get_regs_len(struct net_device *dev)
+{
+	return mlx5e_regs_get_len();
+}
+
+static void mlx5e_get_regs(struct net_device *dev, struct ethtool_regs *regs,
+			   void *buff)
+{
+	mlx5e_regs_get(dev, buff);
+}
+
+static int mlx5e_set_regs(struct net_device *dev, struct ethtool_regs *regs,
+			  u8 *data)
+{
+	return mlx5e_regs_set(dev, data, regs->len);
+}
+
 static int mlx5e_set_rxnfc(struct net_device *dev, struct ethtool_rxnfc *cmd)
 {
 	int err = 0;
@@ -1605,4 +1622,8 @@ const struct ethtool_ops mlx5e_ethtool_ops = {
 	.get_priv_flags    = mlx5e_get_priv_flags,
 	.set_priv_flags    = mlx5e_set_priv_flags,
 	.self_test         = mlx5e_self_test,
+	.get_regs_len      = mlx5e_get_regs_len,
+	.get_regs          = mlx5e_get_regs,
+	.set_regs          = mlx5e_set_regs,
+
 };
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 9def5cc..e1905ba 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -3686,6 +3686,11 @@ static void mlx5e_nic_init(struct mlx5_core_dev *mdev,
 
 	mlx5e_build_nic_netdev_priv(mdev, netdev, profile, ppriv);
 	mlx5e_build_nic_netdev(netdev);
+
+	priv->reg = mlx5e_regs_init();
+	if (!priv->reg)
+		mlx5_core_warn(mdev, "Failed to allocate mlx5e_reg\n");
+
 	mlx5e_vxlan_init(priv);
 }
 
@@ -3696,6 +3701,9 @@ static void mlx5e_nic_cleanup(struct mlx5e_priv *priv)
 
 	mlx5e_vxlan_cleanup(priv);
 
+	if (priv->reg)
+		mlx5e_regs_destroy(priv->reg);
+
 	if (MLX5_CAP_GEN(mdev, vport_group_manager))
 		mlx5_eswitch_unregister_vport_rep(esw, 0);
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_regs.c b/drivers/net/ethernet/mellanox/mlx5/core/en_regs.c
new file mode 100644
index 0000000..a83df1f
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_regs.c
@@ -0,0 +1,116 @@
+/*
+ * Copyright (c) 2016, Mellanox Technologies, Ltd.  All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+
+#include <linux/mlx5/driver.h>
+#include "mlx5_core.h"
+#include "en.h"
+
+#define MLX5E_MAX_REG_LEN             4096
+#define MLX5E_MAX_CMD_OUT_LEN (MLX5E_MAX_REG_LEN - MLX5_ST_SZ_BYTES(mbox_in))
+
+static void reg_out_alloc(struct mlx5e_reg *reg)
+{
+	if (reg->data_out) {
+		memset(reg->data_out, 0, MLX5E_MAX_CMD_OUT_LEN);
+		return;
+	}
+
+	reg->data_out = mlx5_vzalloc(MLX5E_MAX_CMD_OUT_LEN);
+}
+
+struct mlx5e_reg *mlx5e_regs_init(void)
+{
+	return kzalloc(sizeof(struct mlx5e_reg), GFP_KERNEL);
+}
+
+void mlx5e_regs_destroy(struct mlx5e_reg *reg)
+{
+	kvfree(reg->data_out);
+	kfree(reg);
+}
+
+static bool opcode_valid(u16 opcode)
+{
+	switch (opcode) {
+	case MLX5_CMD_OP_QUERY_HCA_CAP:
+	case MLX5_CMD_OP_QUERY_DIAGNOSTIC_PARAMS:
+	case MLX5_CMD_OP_SET_DIAGNOSTIC_PARAMS:
+	case MLX5_CMD_OP_QUERY_DIAGNOSTICS_COUNTERS:
+		return true;
+	}
+
+	return false;
+}
+
+int mlx5e_regs_set(struct net_device *dev, void *buff, int inlen)
+{
+	struct mlx5e_priv *priv = netdev_priv(dev);
+	struct mlx5_core_dev *mdev = priv->mdev;
+	struct mlx5e_reg *reg = priv->reg;
+	u16 opcode;
+
+	if (!reg)
+		return -ENOMEM;
+
+	opcode = MLX5_GET(mbox_in, buff, opcode);
+	if (!opcode_valid(opcode))
+		return -EINVAL;
+
+	reg_out_alloc(reg);
+	if (!reg->data_out)
+		return -ENOMEM;
+
+	memcpy(reg->data_in, buff, sizeof(reg->data_in));
+
+	return mlx5_cmd_exec(mdev, buff, inlen, reg->data_out,
+			     MLX5E_MAX_CMD_OUT_LEN);
+}
+
+void mlx5e_regs_get(struct net_device *dev, void *buff)
+{
+	struct mlx5e_priv *priv = netdev_priv(dev);
+	struct mlx5e_reg *reg = priv->reg;
+
+	if (!reg)
+		return;
+
+	if (reg->data_out) {
+		memcpy(buff, reg->data_in, sizeof(reg->data_in));
+		memcpy(buff + sizeof(reg->data_in), reg->data_out,
+		       MLX5E_MAX_CMD_OUT_LEN);
+	}
+}
+
+int mlx5e_regs_get_len(void)
+{
+	return MLX5E_MAX_REG_LEN;
+}
diff --git a/include/linux/mlx5/mlx5_ifc.h b/include/linux/mlx5/mlx5_ifc.h
index a5f0fbe..9738b70 100644
--- a/include/linux/mlx5/mlx5_ifc.h
+++ b/include/linux/mlx5/mlx5_ifc.h
@@ -169,6 +169,9 @@ enum {
 	MLX5_CMD_OP_DEALLOC_XRCD                  = 0x80f,
 	MLX5_CMD_OP_ALLOC_TRANSPORT_DOMAIN        = 0x816,
 	MLX5_CMD_OP_DEALLOC_TRANSPORT_DOMAIN      = 0x817,
+	MLX5_CMD_OP_QUERY_DIAGNOSTIC_PARAMS       = 0x819,
+	MLX5_CMD_OP_SET_DIAGNOSTIC_PARAMS         = 0x820,
+	MLX5_CMD_OP_QUERY_DIAGNOSTICS_COUNTERS    = 0x821,
 	MLX5_CMD_OP_QUERY_CONG_STATUS             = 0x822,
 	MLX5_CMD_OP_MODIFY_CONG_STATUS            = 0x823,
 	MLX5_CMD_OP_QUERY_CONG_PARAMS             = 0x824,
@@ -230,6 +233,25 @@ enum {
 	MLX5_CMD_OP_MAX
 };
 
+struct mlx5_ifc_mbox_out_bits {
+	u8         status[0x8];
+	u8         reserved_at_8[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_at_40[0x40];
+};
+
+struct mlx5_ifc_mbox_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_at_10[0x10];
+
+	u8         reserved_at_20[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_at_40[0x40];
+};
+
 struct mlx5_ifc_flow_table_fields_supported_bits {
 	u8         outer_dmac[0x1];
 	u8         outer_smac[0x1];
-- 
2.7.4
