From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 1/6] net/mlx4_core: Enhance the MAD_IFC wrapper to convert VF port to physical
Date: Thu, 21 May 2015 15:14:05 +0300
Message-ID: <1432210450-23408-2-git-send-email-ogerlitz@mellanox.com>
References: <1432210450-23408-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Matan Barak <matanb@mellanox.com>,
	Doug Ledford <dledford@redhat.com>,
	Amir Vadai <amirv@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1327.ztomy.com ([193.47.165.129]:56547 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753794AbbEUMOg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 May 2015 08:14:36 -0400
In-Reply-To: <1432210450-23408-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Single port VFs always provide port = 1 (even if the actual physical
port used is port 2). As such, we need to convert the port provided
by the VF to the physical port before calling into the firmware.

It turns out that the Linux mlx4 VF RoCE driver maintains a copy of
the GID table and hence this change became critical only for single
ported IB VFs, but it could be needed for other RoCE VF drivers too.

Fixes: 449fc48866f7 ('net/mlx4: Adapt code for N-Port VF')
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
---
 drivers/net/ethernet/mellanox/mlx4/cmd.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/ethernet/mellanox/mlx4/cmd.c
index 4f7dc04..153fb15 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
@@ -877,7 +877,7 @@ static int mlx4_MAD_IFC_wrapper(struct mlx4_dev *dev, int slave,
 {
 	struct ib_smp *smp = inbox->buf;
 	u32 index;
-	u8 port;
+	u8 port, slave_port;
 	u8 opcode_modifier;
 	u16 *table;
 	int err;
@@ -889,7 +889,8 @@ static int mlx4_MAD_IFC_wrapper(struct mlx4_dev *dev, int slave,
 	__be32 slave_cap_mask;
 	__be64 slave_node_guid;
 
-	port = vhcr->in_modifier;
+	slave_port = vhcr->in_modifier;
+	port = mlx4_slave_convert_port(dev, slave, slave_port);
 
 	/* network-view bit is for driver use only, and should not be passed to FW */
 	opcode_modifier = vhcr->op_modifier & ~0x8; /* clear netw view bit */
@@ -925,8 +926,9 @@ static int mlx4_MAD_IFC_wrapper(struct mlx4_dev *dev, int slave,
 			if (smp->attr_id == IB_SMP_ATTR_PORT_INFO) {
 				/*get the slave specific caps:*/
 				/*do the command */
+				smp->attr_mod = cpu_to_be32(port);
 				err = mlx4_cmd_box(dev, inbox->dma, outbox->dma,
-					    vhcr->in_modifier, opcode_modifier,
+					    port, opcode_modifier,
 					    vhcr->op, MLX4_CMD_TIME_CLASS_C, MLX4_CMD_NATIVE);
 				/* modify the response for slaves */
 				if (!err && slave != mlx4_master_func_num(dev)) {
@@ -970,7 +972,7 @@ static int mlx4_MAD_IFC_wrapper(struct mlx4_dev *dev, int slave,
 			}
 			if (smp->attr_id == IB_SMP_ATTR_NODE_INFO) {
 				err = mlx4_cmd_box(dev, inbox->dma, outbox->dma,
-					     vhcr->in_modifier, opcode_modifier,
+					     port, opcode_modifier,
 					     vhcr->op, MLX4_CMD_TIME_CLASS_C, MLX4_CMD_NATIVE);
 				if (!err) {
 					slave_node_guid =  mlx4_get_slave_node_guid(dev, slave);
-- 
1.7.1
