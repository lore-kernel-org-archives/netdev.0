From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V1 5/9] net/mlx4_core: Don't fail reg/unreg vlan for older guests
Date: Sun,  3 Nov 2013 10:03:21 +0200
Message-ID: <1383465805-28640-6-git-send-email-ogerlitz@mellanox.com>
References: <1383465805-28640-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com, roland@kernel.org,
	jackm@dev.mellanox.co.il, Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:51776 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752558Ab3KCIDg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Nov 2013 03:03:36 -0500
In-Reply-To: <1383465805-28640-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jack Morgenstein <jackm@dev.mellanox.co.il>

In upstream kernels under SRIOV, the vlan register/unregister calls
were NOPs (doing nothing and returning OK). We detect these old
calls from guests (via the comm channel), since previously the
port number in mlx4_register_vlan was passed (improperly) in the
out_param. This has been corrected so that the port number is now
passed in bits 8..15 of the in_modifier field.

For old calls, these bits will be zero, so if the passed port
number is zero, we can still look at the out_param field to see
if it contains a valid port number. If yes, the VM is running
an old driver.

Since for old drivers, the register/unregister_vlan wrappers were
NOPs, we continue this policy -- the reason being that upstream
had an additional bug in eth driver running on guests (where
procedure mlx4_en_vlan_rx_kill_vid() had the following code:

if (!mlx4_find_cached_vlan(mdev->dev, priv->port, vid, &idx))
        mlx4_unregister_vlan(mdev->dev, priv->port, idx);
else
        en_err(priv, "could not find vid %d in cache\n", vid);

On a VM, mlx4_find_cached_vlan() will always fail, since the
vlan cache is located on the Hypervisor; on guests it is empty.

Therefore, if we allow upstream guests to register vlans, we will
have vlan leakage since the unregister will never be performed.
Leaving vlan reg/unreg for old guest drivers as a NOP is not a
feature regression, since in upstream the register/unregister
vlan wrapper is a NOP.

Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/cmd.c           |    1 +
 drivers/net/ethernet/mellanox/mlx4/mlx4.h          |    1 +
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |   17 ++++++++++++++++-
 3 files changed, 18 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/ethernet/mellanox/mlx4/cmd.c
index f0a23cc..7e07013 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
@@ -1718,6 +1718,7 @@ static void mlx4_master_do_cmd(struct mlx4_dev *dev, int slave, u8 cmd,
 	if (cmd == MLX4_COMM_CMD_RESET) {
 		mlx4_warn(dev, "Received reset from slave:%d\n", slave);
 		slave_state[slave].active = false;
+		slave_state[slave].old_vlan_api = false;
 		mlx4_master_deactivate_admin_state(priv, slave);
 		for (i = 0; i < MLX4_EVENT_TYPES_NUM; ++i) {
 				slave_state[slave].event_eq[i].eqn = -1;
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4.h b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
index f2ad4f6..9794126 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
@@ -455,6 +455,7 @@ struct mlx4_slave_state {
 	u8 last_cmd;
 	u8 init_port_mask;
 	bool active;
+	bool old_vlan_api;
 	u8 function;
 	dma_addr_t vhcr_dma;
 	u16 mtu[MLX4_MAX_PORTS + 1];
diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
index e18bfff..3586388 100644
--- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
+++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
@@ -1555,15 +1555,26 @@ static void rem_slave_vlans(struct mlx4_dev *dev, int slave)
 }
 
 static int vlan_alloc_res(struct mlx4_dev *dev, int slave, int op, int cmd,
-			  u64 in_param, u64 *out_param, int port)
+			  u64 in_param, u64 *out_param, int in_port)
 {
+	struct mlx4_priv *priv = mlx4_priv(dev);
+	struct mlx4_slave_state *slave_state = priv->mfunc.master.slave_state;
 	int err;
 	u16 vlan;
 	int vlan_index;
+	int port;
+
+	port = !in_port ? get_param_l(out_param) : in_port;
 
 	if (!port || op != RES_OP_RESERVE_AND_MAP)
 		return -EINVAL;
 
+	/* upstream kernels had NOP for reg/unreg vlan. Continue this. */
+	if (!in_port && port > 0 && port <= dev->caps.num_ports) {
+		slave_state[slave].old_vlan_api = true;
+		return 0;
+	}
+
 	vlan = (u16) in_param;
 
 	err = __mlx4_register_vlan(dev, port, vlan, &vlan_index);
@@ -1856,10 +1867,14 @@ static int mac_free_res(struct mlx4_dev *dev, int slave, int op, int cmd,
 static int vlan_free_res(struct mlx4_dev *dev, int slave, int op, int cmd,
 			    u64 in_param, u64 *out_param, int port)
 {
+	struct mlx4_priv *priv = mlx4_priv(dev);
+	struct mlx4_slave_state *slave_state = priv->mfunc.master.slave_state;
 	int err = 0;
 
 	switch (op) {
 	case RES_OP_RESERVE_AND_MAP:
+		if (slave_state[slave].old_vlan_api)
+			return 0;
 		if (!port)
 			return -EINVAL;
 		vlan_del_from_slave(dev, slave, in_param, port);
-- 
1.7.1
