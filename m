From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V1 1/9] net/mlx4_core: Fix register/unreg vlan flow
Date: Sun,  3 Nov 2013 10:03:17 +0200
Message-ID: <1383465805-28640-2-git-send-email-ogerlitz@mellanox.com>
References: <1383465805-28640-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com, roland@kernel.org,
	jackm@dev.mellanox.co.il, Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:51750 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752089Ab3KCIDc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Nov 2013 03:03:32 -0500
In-Reply-To: <1383465805-28640-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jack Morgenstein <jackm@dev.mellanox.co.il>

The reg/unreg vlan code was broken:

1. a wrapped function called another wrapped function, causing a deadlock.

2. unregister_vlan called cmd_box instead of cmd_box_imm, leading to
   incorrectly passed parameters.

Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/port.c |   21 ++++++++++-----------
 1 files changed, 10 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/port.c b/drivers/net/ethernet/mellanox/mlx4/port.c
index 946e0af..d3d3106 100644
--- a/drivers/net/ethernet/mellanox/mlx4/port.c
+++ b/drivers/net/ethernet/mellanox/mlx4/port.c
@@ -284,7 +284,7 @@ static int mlx4_set_port_vlan_table(struct mlx4_dev *dev, u8 port,
 	memcpy(mailbox->buf, entries, MLX4_VLAN_TABLE_SIZE);
 	in_mod = MLX4_SET_PORT_VLAN_TABLE << 8 | port;
 	err = mlx4_cmd(dev, mailbox->dma, in_mod, 1, MLX4_CMD_SET_PORT,
-		       MLX4_CMD_TIME_CLASS_B, MLX4_CMD_WRAPPED);
+		       MLX4_CMD_TIME_CLASS_B, MLX4_CMD_NATIVE);
 
 	mlx4_free_cmd_mailbox(dev, mailbox);
 
@@ -370,6 +370,9 @@ int mlx4_register_vlan(struct mlx4_dev *dev, u8 port, u16 vlan, int *index)
 	u64 out_param = 0;
 	int err;
 
+	if (vlan > 4095)
+		return -EINVAL;
+
 	if (mlx4_is_mfunc(dev)) {
 		set_param_l(&out_param, port);
 		err = mlx4_cmd_imm(dev, vlan, &out_param, RES_VLAN,
@@ -412,18 +415,14 @@ out:
 
 void mlx4_unregister_vlan(struct mlx4_dev *dev, u8 port, int index)
 {
-	u64 in_param = 0;
-	int err;
+	u64 out_param = 0;
 
 	if (mlx4_is_mfunc(dev)) {
-		set_param_l(&in_param, port);
-		err = mlx4_cmd(dev, in_param, RES_VLAN, RES_OP_RESERVE_AND_MAP,
-			       MLX4_CMD_FREE_RES, MLX4_CMD_TIME_CLASS_A,
-			       MLX4_CMD_WRAPPED);
-		if (!err)
-			mlx4_warn(dev, "Failed freeing vlan at index:%d\n",
-					index);
-
+		set_param_l(&out_param, port);
+		(void) mlx4_cmd_imm(dev, index, &out_param, RES_VLAN,
+				    RES_OP_RESERVE_AND_MAP,
+				    MLX4_CMD_FREE_RES, MLX4_CMD_TIME_CLASS_A,
+				    MLX4_CMD_WRAPPED);
 		return;
 	}
 	__mlx4_unregister_vlan(dev, port, index);
-- 
1.7.1
