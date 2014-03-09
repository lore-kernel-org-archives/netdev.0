From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 2/7] mlx4_core: For RoCE, allow slaves to set the GID entry at that slave's index
Date: Sun,  9 Mar 2014 16:53:59 +0200
Message-ID: <1394376844-12812-3-git-send-email-ogerlitz@mellanox.com>
References: <1394376844-12812-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, roland@kernel.org,
	jackm@dev.mellanox.co.il, amirv@mellanox.com,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:41581 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752494AbaCIOyW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Mar 2014 10:54:22 -0400
In-Reply-To: <1394376844-12812-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jack Morgenstein <jackm@dev.mellanox.co.il>

For IB transport, the host determines the slave GIDs. For ETH (RoCE),
however, the slave's GID is determined by the IP address that the slave
itself assigns to the ETH device used by RoCE.

In this case, the slave must be able to write its GIDs to the HCA gid table
(at the GID indices that slave "owns").

This commit adds processing for the SET_PORT_GID_TABLE opcode modifier
for the SET_PORT command wrapper (so that slaves may modify their GIDS
for RoCE).

Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/port.c |   27 ++++++++++++++++++++++++++-
 1 files changed, 26 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/port.c b/drivers/net/ethernet/mellanox/mlx4/port.c
index 9c063d6..095f74d 100644
--- a/drivers/net/ethernet/mellanox/mlx4/port.c
+++ b/drivers/net/ethernet/mellanox/mlx4/port.c
@@ -505,6 +505,7 @@ int mlx4_get_port_ib_caps(struct mlx4_dev *dev, u8 port, __be32 *caps)
 	mlx4_free_cmd_mailbox(dev, outmailbox);
 	return err;
 }
+static struct mlx4_roce_gid_entry zgid_entry;
 
 static int mlx4_common_set_port(struct mlx4_dev *dev, int slave, u32 in_mod,
 				u8 op_mod, struct mlx4_cmd_mailbox *inbox)
@@ -515,6 +516,7 @@ static int mlx4_common_set_port(struct mlx4_dev *dev, int slave, u32 in_mod,
 	struct mlx4_slave_state *slave_st = &master->slave_state[slave];
 	struct mlx4_set_port_rqp_calc_context *qpn_context;
 	struct mlx4_set_port_general_context *gen_context;
+	struct mlx4_roce_gid_entry *gid_entry;
 	int reset_qkey_viols;
 	int port;
 	int is_eth;
@@ -535,7 +537,8 @@ static int mlx4_common_set_port(struct mlx4_dev *dev, int slave, u32 in_mod,
 	/* Slaves cannot perform SET_PORT operations except changing MTU */
 	if (is_eth) {
 		if (slave != dev->caps.function &&
-		    in_modifier != MLX4_SET_PORT_GENERAL) {
+		    in_modifier != MLX4_SET_PORT_GENERAL &&
+		    in_modifier != MLX4_SET_PORT_GID_TABLE) {
 			mlx4_warn(dev, "denying SET_PORT for slave:%d\n",
 					slave);
 			return -EINVAL;
@@ -581,6 +584,28 @@ static int mlx4_common_set_port(struct mlx4_dev *dev, int slave, u32 in_mod,
 
 			gen_context->mtu = cpu_to_be16(master->max_mtu[port]);
 			break;
+		case MLX4_SET_PORT_GID_TABLE:
+			gid_entry = (struct mlx4_roce_gid_entry *)(inbox->buf);
+			/* check that do not have duplicates */
+			if (memcmp(gid_entry->raw, zgid_entry.raw, 16)) {
+				for (i = 0; i < MLX4_ROCE_MAX_GIDS; i++) {
+					if (slave != i &&
+					    !memcmp(gid_entry->raw, priv->roce_gids[port - 1][i].raw, 16)) {
+						mlx4_warn(dev, "requested gid entry for slave:%d "
+							  "is a duplicate of slave %d\n",
+							  slave, i);
+						return -EEXIST;
+					}
+				}
+			}
+			/* insert slave GID at proper index */
+			memcpy(priv->roce_gids[port - 1][slave].raw, gid_entry->raw, 16);
+			/* rewrite roce port gids table to FW */
+			for (i = 0; i < MLX4_ROCE_MAX_GIDS; i++) {
+				memcpy(gid_entry->raw, priv->roce_gids[port - 1][i].raw, 16);
+				gid_entry++;
+			}
+			break;
 		}
 		return mlx4_cmd(dev, inbox->dma, in_mod, op_mod,
 				MLX4_CMD_SET_PORT, MLX4_CMD_TIME_CLASS_B,
-- 
1.7.1
