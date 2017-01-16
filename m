From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net-next 9/9] net/mlx4_en: Check the enabling pptx/pprx flags in SET_PORT wrapper flow
Date: Mon, 16 Jan 2017 19:30:05 +0200
Message-ID: <1484587805-12666-10-git-send-email-tariqt@mellanox.com>
References: <1484587805-12666-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Shaker Daibes <shakerd@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:43780 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751083AbdAPRam (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2017 12:30:42 -0500
In-Reply-To: <1484587805-12666-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shaker Daibes <shakerd@mellanox.com>

Make sure pptx/pprx mask flag is set using new fields upon set port
request. In addition, move this code into a helper function for better
code readability.

Signed-off-by: Shaker Daibes <shakerd@mellanox.com>
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_port.h |  1 -
 drivers/net/ethernet/mellanox/mlx4/mlx4.h    |  4 ++-
 drivers/net/ethernet/mellanox/mlx4/port.c    | 42 ++++++++++++++++++----------
 3 files changed, 31 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_port.h b/drivers/net/ethernet/mellanox/mlx4/en_port.h
index 040da4b16b1c..930f961fee42 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_port.h
+++ b/drivers/net/ethernet/mellanox/mlx4/en_port.h
@@ -35,7 +35,6 @@
 #define _MLX4_EN_PORT_H_
 
 
-#define SET_PORT_GEN_ALL_VALID	0x7
 #define SET_PORT_PROMISC_SHIFT	31
 #define SET_PORT_MC_PROMISC_SHIFT	30
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4.h b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
index 1132d76ddfdf..7a495090b0bc 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
@@ -776,7 +776,9 @@ struct mlx4_vlan_table {
 	int			max;
 };
 
-#define SET_PORT_GEN_ALL_VALID		0x7
+#define SET_PORT_GEN_ALL_VALID	(MLX4_FLAG_V_MTU_MASK	| \
+				 MLX4_FLAG_V_PPRX_MASK	| \
+				 MLX4_FLAG_V_PPTX_MASK)
 #define SET_PORT_PROMISC_SHIFT		31
 #define SET_PORT_MC_PROMISC_SHIFT	30
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/port.c b/drivers/net/ethernet/mellanox/mlx4/port.c
index 57a10575a7aa..5053c949148f 100644
--- a/drivers/net/ethernet/mellanox/mlx4/port.c
+++ b/drivers/net/ethernet/mellanox/mlx4/port.c
@@ -53,6 +53,8 @@
 #define MLX4_FLAG2_V_IGNORE_FCS_MASK		BIT(1)
 #define MLX4_FLAG2_V_USER_MTU_MASK		BIT(5)
 #define MLX4_FLAG_V_MTU_MASK			BIT(0)
+#define MLX4_FLAG_V_PPRX_MASK			BIT(1)
+#define MLX4_FLAG_V_PPTX_MASK			BIT(2)
 #define MLX4_IGNORE_FCS_MASK			0x1
 #define MLX4_TC_MAX_NUMBER			8
 
@@ -1305,12 +1307,32 @@ void mlx4_reset_roce_gids(struct mlx4_dev *dev, int slave)
 	gen_context->user_mtu = cpu_to_be16(master->max_user_mtu[port]);
 }
 
+static void
+mlx4_en_set_port_global_pause(struct mlx4_dev *dev, int slave,
+			      struct mlx4_set_port_general_context *gen_context)
+{
+	struct mlx4_priv *priv = mlx4_priv(dev);
+	struct mlx4_mfunc_master_ctx *master = &priv->mfunc.master;
+
+	/* Slave cannot change Global Pause configuration */
+	if (slave != mlx4_master_func_num(dev) &&
+	    (gen_context->pptx != master->pptx ||
+	     gen_context->pprx != master->pprx)) {
+		gen_context->pptx = master->pptx;
+		gen_context->pprx = master->pprx;
+		mlx4_warn(dev, "denying Global Pause change for slave:%d\n",
+			  slave);
+	} else {
+		master->pptx = gen_context->pptx;
+		master->pprx = gen_context->pprx;
+	}
+}
+
 static int mlx4_common_set_port(struct mlx4_dev *dev, int slave, u32 in_mod,
 				u8 op_mod, struct mlx4_cmd_mailbox *inbox)
 {
 	struct mlx4_priv *priv = mlx4_priv(dev);
 	struct mlx4_port_info *port_info;
-	struct mlx4_mfunc_master_ctx *master = &priv->mfunc.master;
 	struct mlx4_set_port_rqp_calc_context *qpn_context;
 	struct mlx4_set_port_general_context *gen_context;
 	struct mlx4_roce_gid_entry *gid_entry_tbl, *gid_entry_mbox, *gid_entry_mb1;
@@ -1372,19 +1394,11 @@ static int mlx4_common_set_port(struct mlx4_dev *dev, int slave, u32 in_mod,
 				mlx4_en_set_port_user_mtu(dev, slave, port,
 							  gen_context);
 
-			/* Slave cannot change Global Pause configuration */
-			if (slave != mlx4_master_func_num(dev) &&
-			    ((gen_context->pptx != master->pptx) ||
-			     (gen_context->pprx != master->pprx))) {
-				gen_context->pptx = master->pptx;
-				gen_context->pprx = master->pprx;
-				mlx4_warn(dev,
-					  "denying Global Pause change for slave:%d\n",
-					  slave);
-			} else {
-				master->pptx = gen_context->pptx;
-				master->pprx = gen_context->pprx;
-			}
+			if (gen_context->flags &
+			    (MLX4_FLAG_V_PPRX_MASK || MLX4_FLAG_V_PPTX_MASK))
+				mlx4_en_set_port_global_pause(dev, slave,
+							      gen_context);
+
 			break;
 		case MLX4_SET_PORT_GID_TABLE:
 			/* change to MULTIPLE entries: number of guest's gids
-- 
1.8.3.1
