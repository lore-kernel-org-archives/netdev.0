From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V1 2/9] net/mlx4_core: Fix reg/unreg vlan/mac to conform to the firmware spec
Date: Sun,  3 Nov 2013 10:03:18 +0200
Message-ID: <1383465805-28640-3-git-send-email-ogerlitz@mellanox.com>
References: <1383465805-28640-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com, roland@kernel.org,
	jackm@dev.mellanox.co.il, Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:37896 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752014Ab3KCIDg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Nov 2013 03:03:36 -0500
In-Reply-To: <1383465805-28640-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jack Morgenstein <jackm@dev.mellanox.co.il>

The functions mlx4_register_vlan, mlx4_unregister_vlan, mlx4_register_mac,
mlx4_unregister_mac all made illegal use of the out_param in multifunc mode
to pass the port number. The firmware spec specifies that the port number
should be passed in bits 8..15 of the input-modifier field for ALLOC_RES and
FREE_RES (sections 20.15.1 and 20.15.2).

For MAC register/unregister, this patch contains workarounds so that guests
running previous kernels continue to work on a new Hypervisor, and guests
running the new kernel will continue to work on old hypervisors.

Vlan registeration capability is still not operational in multifunction mode,
since the vlan wrapper functions are not implemented in this patch.

Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/port.c          |   45 ++++++++++++++------
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |   28 +++++++-----
 include/linux/mlx4/device.h                        |    1 +
 3 files changed, 49 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/port.c b/drivers/net/ethernet/mellanox/mlx4/port.c
index d3d3106..9433c1f 100644
--- a/drivers/net/ethernet/mellanox/mlx4/port.c
+++ b/drivers/net/ethernet/mellanox/mlx4/port.c
@@ -178,13 +178,24 @@ EXPORT_SYMBOL_GPL(__mlx4_register_mac);
 int mlx4_register_mac(struct mlx4_dev *dev, u8 port, u64 mac)
 {
 	u64 out_param = 0;
-	int err;
+	int err = -EINVAL;
 
 	if (mlx4_is_mfunc(dev)) {
-		set_param_l(&out_param, port);
-		err = mlx4_cmd_imm(dev, mac, &out_param, RES_MAC,
-				   RES_OP_RESERVE_AND_MAP, MLX4_CMD_ALLOC_RES,
-				   MLX4_CMD_TIME_CLASS_A, MLX4_CMD_WRAPPED);
+		if (!(dev->flags & MLX4_FLAG_OLD_REG_MAC)) {
+			err = mlx4_cmd_imm(dev, mac, &out_param,
+					   ((u32) port) << 8 | (u32) RES_MAC,
+					   RES_OP_RESERVE_AND_MAP, MLX4_CMD_ALLOC_RES,
+					   MLX4_CMD_TIME_CLASS_A, MLX4_CMD_WRAPPED);
+		}
+		if (err && err == -EINVAL && mlx4_is_slave(dev)) {
+			/* retry using old REG_MAC format */
+			set_param_l(&out_param, port);
+			err = mlx4_cmd_imm(dev, mac, &out_param, RES_MAC,
+					   RES_OP_RESERVE_AND_MAP, MLX4_CMD_ALLOC_RES,
+					   MLX4_CMD_TIME_CLASS_A, MLX4_CMD_WRAPPED);
+			if (!err)
+				dev->flags |= MLX4_FLAG_OLD_REG_MAC;
+		}
 		if (err)
 			return err;
 
@@ -231,10 +242,18 @@ void mlx4_unregister_mac(struct mlx4_dev *dev, u8 port, u64 mac)
 	u64 out_param = 0;
 
 	if (mlx4_is_mfunc(dev)) {
-		set_param_l(&out_param, port);
-		(void) mlx4_cmd_imm(dev, mac, &out_param, RES_MAC,
-				    RES_OP_RESERVE_AND_MAP, MLX4_CMD_FREE_RES,
-				    MLX4_CMD_TIME_CLASS_A, MLX4_CMD_WRAPPED);
+		if (!(dev->flags & MLX4_FLAG_OLD_REG_MAC)) {
+			(void) mlx4_cmd_imm(dev, mac, &out_param,
+					    ((u32) port) << 8 | (u32) RES_MAC,
+					    RES_OP_RESERVE_AND_MAP, MLX4_CMD_FREE_RES,
+					    MLX4_CMD_TIME_CLASS_A, MLX4_CMD_WRAPPED);
+		} else {
+			/* use old unregister mac format */
+			set_param_l(&out_param, port);
+			(void) mlx4_cmd_imm(dev, mac, &out_param, RES_MAC,
+					    RES_OP_RESERVE_AND_MAP, MLX4_CMD_FREE_RES,
+					    MLX4_CMD_TIME_CLASS_A, MLX4_CMD_WRAPPED);
+		}
 		return;
 	}
 	__mlx4_unregister_mac(dev, port, mac);
@@ -374,8 +393,8 @@ int mlx4_register_vlan(struct mlx4_dev *dev, u8 port, u16 vlan, int *index)
 		return -EINVAL;
 
 	if (mlx4_is_mfunc(dev)) {
-		set_param_l(&out_param, port);
-		err = mlx4_cmd_imm(dev, vlan, &out_param, RES_VLAN,
+		err = mlx4_cmd_imm(dev, vlan, &out_param,
+				   ((u32) port) << 8 | (u32) RES_VLAN,
 				   RES_OP_RESERVE_AND_MAP, MLX4_CMD_ALLOC_RES,
 				   MLX4_CMD_TIME_CLASS_A, MLX4_CMD_WRAPPED);
 		if (!err)
@@ -418,8 +437,8 @@ void mlx4_unregister_vlan(struct mlx4_dev *dev, u8 port, int index)
 	u64 out_param = 0;
 
 	if (mlx4_is_mfunc(dev)) {
-		set_param_l(&out_param, port);
-		(void) mlx4_cmd_imm(dev, index, &out_param, RES_VLAN,
+		(void) mlx4_cmd_imm(dev, index, &out_param,
+				    ((u32) port) << 8 | (u32) RES_VLAN,
 				    RES_OP_RESERVE_AND_MAP,
 				    MLX4_CMD_FREE_RES, MLX4_CMD_TIME_CLASS_A,
 				    MLX4_CMD_WRAPPED);
diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
index dd68763..a5aa3be 100644
--- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
+++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
@@ -1443,7 +1443,7 @@ static void rem_slave_macs(struct mlx4_dev *dev, int slave)
 }
 
 static int mac_alloc_res(struct mlx4_dev *dev, int slave, int op, int cmd,
-			 u64 in_param, u64 *out_param)
+			 u64 in_param, u64 *out_param, int in_port)
 {
 	int err = -EINVAL;
 	int port;
@@ -1452,7 +1452,7 @@ static int mac_alloc_res(struct mlx4_dev *dev, int slave, int op, int cmd,
 	if (op != RES_OP_RESERVE_AND_MAP)
 		return err;
 
-	port = get_param_l(out_param);
+	port = !in_port ? get_param_l(out_param) : in_port;
 	mac = in_param;
 
 	err = __mlx4_register_mac(dev, port, mac);
@@ -1470,7 +1470,7 @@ static int mac_alloc_res(struct mlx4_dev *dev, int slave, int op, int cmd,
 }
 
 static int vlan_alloc_res(struct mlx4_dev *dev, int slave, int op, int cmd,
-			 u64 in_param, u64 *out_param)
+			 u64 in_param, u64 *out_param, int port)
 {
 	return 0;
 }
@@ -1528,7 +1528,7 @@ int mlx4_ALLOC_RES_wrapper(struct mlx4_dev *dev, int slave,
 	int err;
 	int alop = vhcr->op_modifier;
 
-	switch (vhcr->in_modifier) {
+	switch (vhcr->in_modifier & 0xFF) {
 	case RES_QP:
 		err = qp_alloc_res(dev, slave, vhcr->op_modifier, alop,
 				   vhcr->in_param, &vhcr->out_param);
@@ -1556,12 +1556,14 @@ int mlx4_ALLOC_RES_wrapper(struct mlx4_dev *dev, int slave,
 
 	case RES_MAC:
 		err = mac_alloc_res(dev, slave, vhcr->op_modifier, alop,
-				    vhcr->in_param, &vhcr->out_param);
+				    vhcr->in_param, &vhcr->out_param,
+				    (vhcr->in_modifier >> 8) & 0xFF);
 		break;
 
 	case RES_VLAN:
 		err = vlan_alloc_res(dev, slave, vhcr->op_modifier, alop,
-				    vhcr->in_param, &vhcr->out_param);
+				     vhcr->in_param, &vhcr->out_param,
+				     (vhcr->in_modifier >> 8) & 0xFF);
 		break;
 
 	case RES_COUNTER:
@@ -1730,14 +1732,14 @@ static int srq_free_res(struct mlx4_dev *dev, int slave, int op, int cmd,
 }
 
 static int mac_free_res(struct mlx4_dev *dev, int slave, int op, int cmd,
-			    u64 in_param, u64 *out_param)
+			    u64 in_param, u64 *out_param, int in_port)
 {
 	int port;
 	int err = 0;
 
 	switch (op) {
 	case RES_OP_RESERVE_AND_MAP:
-		port = get_param_l(out_param);
+		port = !in_port ? get_param_l(out_param) : in_port;
 		mac_del_from_slave(dev, slave, in_param, port);
 		__mlx4_unregister_mac(dev, port, in_param);
 		break;
@@ -1751,7 +1753,7 @@ static int mac_free_res(struct mlx4_dev *dev, int slave, int op, int cmd,
 }
 
 static int vlan_free_res(struct mlx4_dev *dev, int slave, int op, int cmd,
-			    u64 in_param, u64 *out_param)
+			    u64 in_param, u64 *out_param, int port)
 {
 	return 0;
 }
@@ -1803,7 +1805,7 @@ int mlx4_FREE_RES_wrapper(struct mlx4_dev *dev, int slave,
 	int err = -EINVAL;
 	int alop = vhcr->op_modifier;
 
-	switch (vhcr->in_modifier) {
+	switch (vhcr->in_modifier & 0xFF) {
 	case RES_QP:
 		err = qp_free_res(dev, slave, vhcr->op_modifier, alop,
 				  vhcr->in_param);
@@ -1831,12 +1833,14 @@ int mlx4_FREE_RES_wrapper(struct mlx4_dev *dev, int slave,
 
 	case RES_MAC:
 		err = mac_free_res(dev, slave, vhcr->op_modifier, alop,
-				   vhcr->in_param, &vhcr->out_param);
+				   vhcr->in_param, &vhcr->out_param,
+				   (vhcr->in_modifier >> 8) & 0xFF);
 		break;
 
 	case RES_VLAN:
 		err = vlan_free_res(dev, slave, vhcr->op_modifier, alop,
-				   vhcr->in_param, &vhcr->out_param);
+				    vhcr->in_param, &vhcr->out_param,
+				    (vhcr->in_modifier >> 8) & 0xFF);
 		break;
 
 	case RES_COUNTER:
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index 9ad0c18..297a163 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -54,6 +54,7 @@ enum {
 	MLX4_FLAG_MASTER	= 1 << 2,
 	MLX4_FLAG_SLAVE		= 1 << 3,
 	MLX4_FLAG_SRIOV		= 1 << 4,
+	MLX4_FLAG_OLD_REG_MAC	= 1 << 6,
 };
 
 enum {
-- 
1.7.1
