From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 20/25 v2] mlx4: Managing SET_PORT for En port for multi-func
Date: Fri, 06 Nov 2009 05:10:06 +0200
Message-ID: <4AF3938E.5070400@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
	liranl@mellanox.co.il, tziporet@mellanox.co.il,
	yevgenyp@mellanox.co.il
To: rdreier@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:43251 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1759214AbZKFAMb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Nov 2009 19:12:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

MTU is set as max among all active functions.
The base QP number is the base QP number of the port.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/mlx4.h  |    2 +
 drivers/net/mlx4/port.c  |   56 ++++++++++++++++++++++++++++++++++++++++++---
 include/linux/mlx4/cmd.h |    1 +
 3 files changed, 55 insertions(+), 4 deletions(-)

diff --git a/drivers/net/mlx4/mlx4.h b/drivers/net/mlx4/mlx4.h
index 19c87e7..2c87cc5 100644
--- a/drivers/net/mlx4/mlx4.h
+++ b/drivers/net/mlx4/mlx4.h
@@ -225,6 +225,7 @@ struct mlx4_slave_state {
 	u8 last_cmd;
 	u8 init_port_mask;
 	dma_addr_t vhcr_dma;
+	u16 mtu[MLX4_MAX_PORTS + 1];
 	__be32 ib_cap_mask[MLX4_MAX_PORTS + 1];
 	struct mlx4_slave_eqe eq[MLX4_MFUNC_MAX_EQES];
 	u16 eq_pi;
@@ -236,6 +237,7 @@ struct mlx4_slave_state {
 struct mlx4_mfunc_master_ctx {
 	struct mlx4_slave_state *slave_state;
 	int			init_port_ref[MLX4_MAX_PORTS + 1];
+	u16			max_mtu[MLX4_MAX_PORTS + 1];
 };
 
 struct mlx4_vhcr {
diff --git a/drivers/net/mlx4/port.c b/drivers/net/mlx4/port.c
index 6e729dd..02b56ba 100644
--- a/drivers/net/mlx4/port.c
+++ b/drivers/net/mlx4/port.c
@@ -36,6 +36,7 @@
 #include <linux/mlx4/cmd.h>
 
 #include "mlx4.h"
+#include "en_port.h"
 
 #define MLX4_MAC_VALID		(1ull << 63)
 #define MLX4_MAC_MASK		0xffffffffffffULL
@@ -351,9 +352,17 @@ int mlx4_SET_PORT_wrapper(struct mlx4_dev *dev, int slave, struct mlx4_vhcr *vhc
 							struct mlx4_cmd_mailbox *outbox)
 {
 	struct mlx4_priv *priv = mlx4_priv(dev);
+	struct mlx4_port_info *port_info;
+	struct mlx4_mfunc_master_ctx *master = &priv->mfunc.master;
+	struct mlx4_slave_state *slave_st = &master->slave_state[slave];
+	struct mlx4_set_port_rqp_calc_context *qpn_context;
+	struct mlx4_set_port_general_context *gen_context;
 	int reset_qkey_viols;
 	int port;
 	int is_eth;
+	u32 in_modifier;
+	u32 promisc;
+	u16 mtu, prev_mtu;
 	int err;
 	int i;
 	__be32 agg_cap_mask;
@@ -361,13 +370,52 @@ int mlx4_SET_PORT_wrapper(struct mlx4_dev *dev, int slave, struct mlx4_vhcr *vhc
 	__be32 new_cap_mask;
 
 	port = vhcr->in_modifier & 0xff;
+	in_modifier = vhcr->in_modifier >> 8;
 	is_eth = vhcr->op_modifier;
+	port_info = &priv->port[port];
 
-	/* For Ethernet, we currently support only slave0.
-	 * TODO: add multi-vf support */
+	/* All slaves can perform SET_PORT operations, just need to verify
+	 * we keep the mutual resources unchanged */
 	if (is_eth) {
-		if (slave)
-			return -EINVAL;
+		switch (in_modifier) {
+		case MLX4_SET_PORT_RQP_CALC:
+			qpn_context = inbox->buf;
+			qpn_context->base_qpn = cpu_to_be32(port_info->base_qpn);
+			qpn_context->n_mac = 0x7;
+			promisc = be32_to_cpu(qpn_context->promisc) >>
+				SET_PORT_PROMISC_SHIFT;
+			qpn_context->promisc = cpu_to_be32(
+				promisc << SET_PORT_PROMISC_SHIFT |
+				port_info->base_qpn);
+			promisc = be32_to_cpu(qpn_context->mcast) >>
+				SET_PORT_PROMISC_SHIFT;
+			qpn_context->mcast = cpu_to_be32(
+				promisc << SET_PORT_PROMISC_SHIFT |
+				port_info->base_qpn);
+			break;
+		case MLX4_SET_PORT_GENERAL:
+			gen_context = inbox->buf;
+			/* Mtu is configured as the max MTU among all the
+			 * the functions on the port. */
+			mtu = be16_to_cpu(gen_context->mtu);
+			mtu = max_t(int, mtu, dev->caps.eth_mtu_cap[port]);
+			prev_mtu = slave_st->mtu[port];
+			slave_st->mtu[port] = mtu;
+			if (mtu > master->max_mtu[port])
+				master->max_mtu[port] = mtu;
+			if (mtu < prev_mtu && prev_mtu == master->max_mtu[port]) {
+				slave_st->mtu[port] = mtu;
+				master->max_mtu[port] = mtu;
+				for (i = 0; i < dev->num_slaves; i++) {
+					master->max_mtu[port] =
+						max(master->max_mtu[port],
+						    master->slave_state[i].mtu[port]);
+				}
+			}
+
+			gen_context->mtu = cpu_to_be16(master->max_mtu[port]);
+			break;
+		}
 		return mlx4_cmd(dev, inbox->dma, vhcr->in_modifier,
 						 vhcr->op_modifier,
 						 MLX4_CMD_SET_PORT,
diff --git a/include/linux/mlx4/cmd.h b/include/linux/mlx4/cmd.h
index c163d5e..e680ff1 100644
--- a/include/linux/mlx4/cmd.h
+++ b/include/linux/mlx4/cmd.h
@@ -156,6 +156,7 @@ enum {
 	MLX4_SET_PORT_MAC_TABLE = 0x2,
 	MLX4_SET_PORT_VLAN_TABLE = 0x3,
 	MLX4_SET_PORT_PRIO_MAP  = 0x4,
+	MLX4_SET_PORT_MODIFIERS
 };
 
 struct mlx4_dev;
-- 
1.5.3.7

From: Liran Liss <liranl@mellanox.co.il>





