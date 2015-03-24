From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 2/2] net/mlx4_core: Fix GEN_EQE accessing uninitialixed mutex
Date: Tue, 24 Mar 2015 15:18:39 +0200
Message-ID: <1427203119-27149-3-git-send-email-ogerlitz@mellanox.com>
References: <1427203119-27149-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:49690 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752648AbbCXNSv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Mar 2015 09:18:51 -0400
In-Reply-To: <1427203119-27149-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jack Morgenstein <jackm@dev.mellanox.co.il>

We occasionally see in procedure mlx4_GEN_EQE that the driver tries
to grab an uninitialized mutex.

This can occur in only one of two ways:
1. We are trying to generate an async event on an uninitialized slave.
2. We are trying to generate an async event on an illegal slave number
   ( < 0 or > persist->num_vfs) or an inactive slave.

To deal with #1: move the mutex initialization from specific slave init
sequence in procedure mlx_master_do_cmd to mlx4_multi_func_init() (so that
the mutex is always initialized for all slaves).

To deal with #2: check in procedure mlx4_GEN_EQE that the slave number
provided is in the proper range and that the slave is active.

Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/cmd.c           |    2 +-
 drivers/net/ethernet/mellanox/mlx4/eq.c            |   18 +++++++-----------
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |    6 ++++++
 3 files changed, 14 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/ethernet/mellanox/mlx4/cmd.c
index a681d7c..3350721 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
@@ -1993,7 +1993,6 @@ static void mlx4_master_do_cmd(struct mlx4_dev *dev, int slave, u8 cmd,
 			goto reset_slave;
 		slave_state[slave].vhcr_dma = ((u64) param) << 48;
 		priv->mfunc.master.slave_state[slave].cookie = 0;
-		mutex_init(&priv->mfunc.master.gen_eqe_mutex[slave]);
 		break;
 	case MLX4_COMM_CMD_VHCR1:
 		if (slave_state[slave].last_cmd != MLX4_COMM_CMD_VHCR0)
@@ -2225,6 +2224,7 @@ int mlx4_multi_func_init(struct mlx4_dev *dev)
 		for (i = 0; i < dev->num_slaves; ++i) {
 			s_state = &priv->mfunc.master.slave_state[i];
 			s_state->last_cmd = MLX4_COMM_CMD_RESET;
+			mutex_init(&priv->mfunc.master.gen_eqe_mutex[i]);
 			for (j = 0; j < MLX4_EVENT_TYPES_NUM; ++j)
 				s_state->event_eq[j].eqn = -1;
 			__raw_writel((__force u32) 0,
diff --git a/drivers/net/ethernet/mellanox/mlx4/eq.c b/drivers/net/ethernet/mellanox/mlx4/eq.c
index 264bc15..6e70ffe 100644
--- a/drivers/net/ethernet/mellanox/mlx4/eq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/eq.c
@@ -153,12 +153,10 @@ void mlx4_gen_slave_eqe(struct work_struct *work)
 
 		/* All active slaves need to receive the event */
 		if (slave == ALL_SLAVES) {
-			for (i = 0; i < dev->num_slaves; i++) {
-				if (i != dev->caps.function &&
-				    master->slave_state[i].active)
-					if (mlx4_GEN_EQE(dev, i, eqe))
-						mlx4_warn(dev, "Failed to generate event for slave %d\n",
-							  i);
+			for (i = 0; i <= dev->persist->num_vfs; i++) {
+				if (mlx4_GEN_EQE(dev, i, eqe))
+					mlx4_warn(dev, "Failed to generate event for slave %d\n",
+						  i);
 			}
 		} else {
 			if (mlx4_GEN_EQE(dev, slave, eqe))
@@ -203,13 +201,11 @@ static void mlx4_slave_event(struct mlx4_dev *dev, int slave,
 			     struct mlx4_eqe *eqe)
 {
 	struct mlx4_priv *priv = mlx4_priv(dev);
-	struct mlx4_slave_state *s_slave =
-		&priv->mfunc.master.slave_state[slave];
 
-	if (!s_slave->active) {
-		/*mlx4_warn(dev, "Trying to pass event to inactive slave\n");*/
+	if (slave < 0 || slave > dev->persist->num_vfs ||
+	    slave == dev->caps.function ||
+	    !priv->mfunc.master.slave_state[slave].active)
 		return;
-	}
 
 	slave_event(dev, slave, eqe);
 }
diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
index d97ca88..6e413ac 100644
--- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
+++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
@@ -3095,6 +3095,12 @@ int mlx4_GEN_EQE(struct mlx4_dev *dev, int slave, struct mlx4_eqe *eqe)
 	if (!priv->mfunc.master.slave_state)
 		return -EINVAL;
 
+	/* check for slave valid, slave not PF, and slave active */
+	if (slave < 0 || slave > dev->persist->num_vfs ||
+	    slave == dev->caps.function ||
+	    !priv->mfunc.master.slave_state[slave].active)
+		return 0;
+
 	event_eq = &priv->mfunc.master.slave_state[slave].event_eq[eqe->type];
 
 	/* Create the event only if the slave is registered */
-- 
1.7.1
