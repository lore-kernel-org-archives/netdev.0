From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net-next V2 7/8] net/mlx4_en: Check the enabling mtu flag in SET_PORT wrapper flow
Date: Sun, 29 Jan 2017 13:22:29 +0200
Message-ID: <1485688950-32443-8-git-send-email-tariqt@mellanox.com>
References: <1485688950-32443-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Shaker Daibes <shakerd@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:51272 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751060AbdA2La2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 29 Jan 2017 06:30:28 -0500
In-Reply-To: <1485688950-32443-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shaker Daibes <shakerd@mellanox.com>

Make sure MTU mask flag is set using new field upon set port
request. In addition, move this code into a helper function for better
code readability.

Signed-off-by: Shaker Daibes <shakerd@mellanox.com>
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/port.c | 59 +++++++++++++++++++------------
 1 file changed, 37 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/port.c b/drivers/net/ethernet/mellanox/mlx4/port.c
index a7b0cdcb358a..57a10575a7aa 100644
--- a/drivers/net/ethernet/mellanox/mlx4/port.c
+++ b/drivers/net/ethernet/mellanox/mlx4/port.c
@@ -52,6 +52,7 @@
 
 #define MLX4_FLAG2_V_IGNORE_FCS_MASK		BIT(1)
 #define MLX4_FLAG2_V_USER_MTU_MASK		BIT(5)
+#define MLX4_FLAG_V_MTU_MASK			BIT(0)
 #define MLX4_IGNORE_FCS_MASK			0x1
 #define MLX4_TC_MAX_NUMBER			8
 
@@ -1241,6 +1242,38 @@ void mlx4_reset_roce_gids(struct mlx4_dev *dev, int slave)
 }
 
 static void
+mlx4_en_set_port_mtu(struct mlx4_dev *dev, int slave, int port,
+		     struct mlx4_set_port_general_context *gen_context)
+{
+	struct mlx4_priv *priv = mlx4_priv(dev);
+	struct mlx4_mfunc_master_ctx *master = &priv->mfunc.master;
+	struct mlx4_slave_state *slave_st = &master->slave_state[slave];
+	u16 mtu, prev_mtu;
+
+	/* Mtu is configured as the max USER_MTU among all
+	 * the functions on the port.
+	 */
+	mtu = be16_to_cpu(gen_context->mtu);
+	mtu = min_t(int, mtu, dev->caps.eth_mtu_cap[port] +
+		    ETH_HLEN + VLAN_HLEN + ETH_FCS_LEN);
+	prev_mtu = slave_st->mtu[port];
+	slave_st->mtu[port] = mtu;
+	if (mtu > master->max_mtu[port])
+		master->max_mtu[port] = mtu;
+	if (mtu < prev_mtu && prev_mtu == master->max_mtu[port]) {
+		int i;
+
+		slave_st->mtu[port] = mtu;
+		master->max_mtu[port] = mtu;
+		for (i = 0; i < dev->num_slaves; i++)
+			master->max_mtu[port] =
+				max_t(u16, master->max_mtu[port],
+				      master->slave_state[i].mtu[port]);
+	}
+	gen_context->mtu = cpu_to_be16(master->max_mtu[port]);
+}
+
+static void
 mlx4_en_set_port_user_mtu(struct mlx4_dev *dev, int slave, int port,
 			  struct mlx4_set_port_general_context *gen_context)
 {
@@ -1278,7 +1311,6 @@ static int mlx4_common_set_port(struct mlx4_dev *dev, int slave, u32 in_mod,
 	struct mlx4_priv *priv = mlx4_priv(dev);
 	struct mlx4_port_info *port_info;
 	struct mlx4_mfunc_master_ctx *master = &priv->mfunc.master;
-	struct mlx4_slave_state *slave_st = &master->slave_state[slave];
 	struct mlx4_set_port_rqp_calc_context *qpn_context;
 	struct mlx4_set_port_general_context *gen_context;
 	struct mlx4_roce_gid_entry *gid_entry_tbl, *gid_entry_mbox, *gid_entry_mb1;
@@ -1289,7 +1321,6 @@ static int mlx4_common_set_port(struct mlx4_dev *dev, int slave, u32 in_mod,
 	int base;
 	u32 in_modifier;
 	u32 promisc;
-	u16 mtu, prev_mtu;
 	int err;
 	int i, j;
 	int offset;
@@ -1332,26 +1363,10 @@ static int mlx4_common_set_port(struct mlx4_dev *dev, int slave, u32 in_mod,
 			break;
 		case MLX4_SET_PORT_GENERAL:
 			gen_context = inbox->buf;
-			/* Mtu is configured as the max MTU among all the
-			 * the functions on the port. */
-			mtu = be16_to_cpu(gen_context->mtu);
-			mtu = min_t(int, mtu, dev->caps.eth_mtu_cap[port] +
-				    ETH_HLEN + VLAN_HLEN + ETH_FCS_LEN);
-			prev_mtu = slave_st->mtu[port];
-			slave_st->mtu[port] = mtu;
-			if (mtu > master->max_mtu[port])
-				master->max_mtu[port] = mtu;
-			if (mtu < prev_mtu && prev_mtu ==
-						master->max_mtu[port]) {
-				slave_st->mtu[port] = mtu;
-				master->max_mtu[port] = mtu;
-				for (i = 0; i < dev->num_slaves; i++) {
-					master->max_mtu[port] =
-					max(master->max_mtu[port],
-					    master->slave_state[i].mtu[port]);
-				}
-			}
-			gen_context->mtu = cpu_to_be16(master->max_mtu[port]);
+
+			if (gen_context->flags & MLX4_FLAG_V_MTU_MASK)
+				mlx4_en_set_port_mtu(dev, slave, port,
+						     gen_context);
 
 			if (gen_context->flags2 & MLX4_FLAG2_V_USER_MTU_MASK)
 				mlx4_en_set_port_user_mtu(dev, slave, port,
-- 
1.8.3.1
