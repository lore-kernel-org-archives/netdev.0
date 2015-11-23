From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 06/18] net/mlx5: Introduce access functions to modify/query vport state
Date: Mon, 23 Nov 2015 13:11:39 +0200
Message-ID: <1448277111-16474-7-git-send-email-ogerlitz@mellanox.com>
References: <1448277111-16474-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Don Dutile <ddutile@redhat.com>,
	Doug Ledford <dledford@redhat.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Rony Efraim <ronye@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:37343 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752746AbbKWLOA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Nov 2015 06:14:00 -0500
In-Reply-To: <1448277111-16474-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>

In preparation for SR-IOV we add here an API to enable each e-switch
manager (PF) to configure its VFs link states in e-switch

preparation for ethernet sriov.

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/vport.c   | 61 ++++++++++++++++++++---
 include/linux/mlx5/mlx5_ifc.h                     |  1 +
 include/linux/mlx5/vport.h                        |  6 ++-
 4 files changed, 62 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 2ef717f..007e464 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -63,7 +63,7 @@ static void mlx5e_update_carrier(struct mlx5e_priv *priv)
 	u8 port_state;
 
 	port_state = mlx5_query_vport_state(mdev,
-		MLX5_QUERY_VPORT_STATE_IN_OP_MOD_VNIC_VPORT);
+		MLX5_QUERY_VPORT_STATE_IN_OP_MOD_VNIC_VPORT, 0);
 
 	if (port_state == VPORT_STATE_UP)
 		netif_carrier_on(priv->netdev);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/vport.c b/drivers/net/ethernet/mellanox/mlx5/core/vport.c
index 986d0d3..b017a7e 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/vport.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/vport.c
@@ -36,26 +36,75 @@
 #include <linux/mlx5/vport.h>
 #include "mlx5_core.h"
 
-u8 mlx5_query_vport_state(struct mlx5_core_dev *mdev, u8 opmod)
+static int _mlx5_query_vport_state(struct mlx5_core_dev *mdev, u8 opmod,
+				   u16 vport, u32 *out, int outlen)
 {
-	u32 in[MLX5_ST_SZ_DW(query_vport_state_in)];
-	u32 out[MLX5_ST_SZ_DW(query_vport_state_out)];
 	int err;
+	u32 in[MLX5_ST_SZ_DW(query_vport_state_in)];
 
 	memset(in, 0, sizeof(in));
 
 	MLX5_SET(query_vport_state_in, in, opcode,
 		 MLX5_CMD_OP_QUERY_VPORT_STATE);
 	MLX5_SET(query_vport_state_in, in, op_mod, opmod);
+	MLX5_SET(query_vport_state_in, in, vport_number, vport);
+	if (vport)
+		MLX5_SET(query_vport_state_in, in, other_vport, 1);
 
-	err = mlx5_cmd_exec_check_status(mdev, in, sizeof(in), out,
-					 sizeof(out));
+	err = mlx5_cmd_exec_check_status(mdev, in, sizeof(in), out, outlen);
 	if (err)
 		mlx5_core_warn(mdev, "MLX5_CMD_OP_QUERY_VPORT_STATE failed\n");
 
+	return err;
+}
+
+u8 mlx5_query_vport_state(struct mlx5_core_dev *mdev, u8 opmod, u16 vport)
+{
+	u32 out[MLX5_ST_SZ_DW(query_vport_state_out)] = {0};
+
+	_mlx5_query_vport_state(mdev, opmod, vport, out, sizeof(out));
+
 	return MLX5_GET(query_vport_state_out, out, state);
 }
-EXPORT_SYMBOL(mlx5_query_vport_state);
+EXPORT_SYMBOL_GPL(mlx5_query_vport_state);
+
+u8 mlx5_query_vport_admin_state(struct mlx5_core_dev *mdev, u8 opmod, u16 vport)
+{
+	u32 out[MLX5_ST_SZ_DW(query_vport_state_out)] = {0};
+
+	_mlx5_query_vport_state(mdev, opmod, vport, out, sizeof(out));
+
+	return MLX5_GET(query_vport_state_out, out, admin_state);
+}
+EXPORT_SYMBOL(mlx5_query_vport_admin_state);
+
+int mlx5_modify_vport_admin_state(struct mlx5_core_dev *mdev, u8 opmod,
+				  u16 vport, u8 state)
+{
+	u32 in[MLX5_ST_SZ_DW(modify_vport_state_in)];
+	u32 out[MLX5_ST_SZ_DW(modify_vport_state_out)];
+	int err;
+
+	memset(in, 0, sizeof(in));
+
+	MLX5_SET(modify_vport_state_in, in, opcode,
+		 MLX5_CMD_OP_MODIFY_VPORT_STATE);
+	MLX5_SET(modify_vport_state_in, in, op_mod, opmod);
+	MLX5_SET(modify_vport_state_in, in, vport_number, vport);
+
+	if (vport)
+		MLX5_SET(modify_vport_state_in, in, other_vport, 1);
+
+	MLX5_SET(modify_vport_state_in, in, admin_state, state);
+
+	err = mlx5_cmd_exec_check_status(mdev, in, sizeof(in), out,
+					 sizeof(out));
+	if (err)
+		mlx5_core_warn(mdev, "MLX5_CMD_OP_MODIFY_VPORT_STATE failed\n");
+
+	return err;
+}
+EXPORT_SYMBOL(mlx5_modify_vport_admin_state);
 
 static int mlx5_query_nic_vport_context(struct mlx5_core_dev *mdev, u16 vport,
 					u32 *out, int outlen)
diff --git a/include/linux/mlx5/mlx5_ifc.h b/include/linux/mlx5/mlx5_ifc.h
index 836cf0e..6551847 100644
--- a/include/linux/mlx5/mlx5_ifc.h
+++ b/include/linux/mlx5/mlx5_ifc.h
@@ -2946,6 +2946,7 @@ struct mlx5_ifc_query_vport_state_out_bits {
 
 enum {
 	MLX5_QUERY_VPORT_STATE_IN_OP_MOD_VNIC_VPORT  = 0x0,
+	MLX5_QUERY_VPORT_STATE_IN_OP_MOD_ESW_VPORT   = 0x1,
 };
 
 struct mlx5_ifc_query_vport_state_in_bits {
diff --git a/include/linux/mlx5/vport.h b/include/linux/mlx5/vport.h
index 00bbec8..c1bba59 100644
--- a/include/linux/mlx5/vport.h
+++ b/include/linux/mlx5/vport.h
@@ -36,7 +36,11 @@
 #include <linux/mlx5/driver.h>
 #include <linux/mlx5/device.h>
 
-u8 mlx5_query_vport_state(struct mlx5_core_dev *mdev, u8 opmod);
+u8 mlx5_query_vport_state(struct mlx5_core_dev *mdev, u8 opmod, u16 vport);
+u8 mlx5_query_vport_admin_state(struct mlx5_core_dev *mdev, u8 opmod,
+				u16 vport);
+int mlx5_modify_vport_admin_state(struct mlx5_core_dev *mdev, u8 opmod,
+				  u16 vport, u8 state);
 int mlx5_query_nic_vport_mac_address(struct mlx5_core_dev *mdev,
 				     u16 vport, u8 *addr);
 int mlx5_modify_nic_vport_mac_address(struct mlx5_core_dev *dev,
-- 
2.3.7
