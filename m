From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH net V1 6/6]  mlx4_core: map async events to arbitrary slave
 eqs
Date: Thu, 19 Jan 2012 21:45:46 +0200
Message-ID: <4F1872EA.8060606@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>,
	<marcela@dev.mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog119.obsmtp.com ([207.126.144.147]:55463 "HELO
	eu1sys200aog119.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S932675Ab2ASTpv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2012 14:45:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcel Apfelbaum <marcela@dev.mellanox.co.il>

Slave async events were mapped to single eq. This patch fixes this issue, so
the slaves can map the async events to any eq.

Signed-off-by: Marcel Apfelbaum <marcela@dev.mellanox.co.il>
Reviewed-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
---
 drivers/net/ethernet/mellanox/mlx4/cmd.c           |    9 ++++++++-
 drivers/net/ethernet/mellanox/mlx4/eq.c            |   17 +++++++----------
 drivers/net/ethernet/mellanox/mlx4/mlx4.h          |    8 +++++---
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |    4 ++--
 4 files changed, 22 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/ethernet/mellanox/mlx4/cmd.c
index 978f593..405e6ac 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
@@ -1247,6 +1247,7 @@ static void mlx4_master_do_cmd(struct mlx4_dev *dev, int slave, u8 cmd,
 	u32 reply;
 	u32 slave_status = 0;
 	u8 is_going_down = 0;
+	int i;
 
 	slave_state[slave].comm_toggle ^= 1;
 	reply = (u32) slave_state[slave].comm_toggle << 31;
@@ -1258,6 +1259,10 @@ static void mlx4_master_do_cmd(struct mlx4_dev *dev, int slave, u8 cmd,
 	if (cmd == MLX4_COMM_CMD_RESET) {
 		mlx4_warn(dev, "Received reset from slave:%d\n", slave);
 		slave_state[slave].active = false;
+		for (i = 0; i < MLX4_EVENT_TYPES_NUM; ++i) {
+				slave_state[slave].event_eq[i].eqn = -1;
+				slave_state[slave].event_eq[i].token = 0;
+		}
 		/*check if we are in the middle of FLR process,
 		if so return "retry" status to the slave*/
 		if (MLX4_COMM_CMD_FLR == slave_state[slave].last_cmd) {
@@ -1452,7 +1457,7 @@ int mlx4_multi_func_init(struct mlx4_dev *dev)
 {
 	struct mlx4_priv *priv = mlx4_priv(dev);
 	struct mlx4_slave_state *s_state;
-	int i, err, port;
+	int i, j, err, port;
 
 	priv->mfunc.vhcr = dma_alloc_coherent(&(dev->pdev->dev), PAGE_SIZE,
 					    &priv->mfunc.vhcr_dma,
@@ -1485,6 +1490,8 @@ int mlx4_multi_func_init(struct mlx4_dev *dev)
 		for (i = 0; i < dev->num_slaves; ++i) {
 			s_state = &priv->mfunc.master.slave_state[i];
 			s_state->last_cmd = MLX4_COMM_CMD_RESET;
+			for (j = 0; j < MLX4_EVENT_TYPES_NUM; ++j)
+				s_state->event_eq[j].eqn = -1;
 			__raw_writel((__force u32) 0,
 				     &priv->mfunc.comm[i].slave_write);
 			__raw_writel((__force u32) 0,
diff --git a/drivers/net/ethernet/mellanox/mlx4/eq.c b/drivers/net/ethernet/mellanox/mlx4/eq.c
index e163de6..55d7bd4 100644
--- a/drivers/net/ethernet/mellanox/mlx4/eq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/eq.c
@@ -513,25 +513,22 @@ int mlx4_MAP_EQ_wrapper(struct mlx4_dev *dev, int slave,
 {
 	struct mlx4_priv *priv = mlx4_priv(dev);
 	struct mlx4_slave_event_eq_info *event_eq =
-		&priv->mfunc.master.slave_state[slave].event_eq;
+		priv->mfunc.master.slave_state[slave].event_eq;
 	u32 in_modifier = vhcr->in_modifier;
 	u32 eqn = in_modifier & 0x1FF;
 	u64 in_param =  vhcr->in_param;
 	int err = 0;
+	int i;
 
 	if (slave == dev->caps.function)
 		err = mlx4_cmd(dev, in_param, (in_modifier & 0x80000000) | eqn,
 			       0, MLX4_CMD_MAP_EQ, MLX4_CMD_TIME_CLASS_B,
 			       MLX4_CMD_NATIVE);
-	if (!err) {
-		if (in_modifier >> 31) {
-			/* unmap */
-			event_eq->event_type &= ~in_param;
-		} else {
-			event_eq->eqn = eqn;
-			event_eq->event_type = in_param;
-		}
-	}
+	if (!err)
+		for (i = 0; i < MLX4_EVENT_TYPES_NUM; ++i)
+			if (in_param & (1LL << i))
+				event_eq[i].eqn = in_modifier >> 31 ? -1 : eqn;
+
 	return err;
 }
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4.h b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
index a80121a..c92269f 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
@@ -388,9 +388,8 @@ struct mlx4_slave_eqe {
 };
 
 struct mlx4_slave_event_eq_info {
-	u32 eqn;
+	int eqn;
 	u16 token;
-	u64 event_type;
 };
 
 struct mlx4_profile {
@@ -449,6 +448,8 @@ struct mlx4_steer_index {
 	struct list_head duplicates;
 };
 
+#define MLX4_EVENT_TYPES_NUM 64
+
 struct mlx4_slave_state {
 	u8 comm_toggle;
 	u8 last_cmd;
@@ -461,7 +462,8 @@ struct mlx4_slave_state {
 	struct mlx4_slave_eqe eq[MLX4_MFUNC_MAX_EQES];
 	struct list_head mcast_filters[MLX4_MAX_PORTS + 1];
 	struct mlx4_vlan_fltr *vlan_filter[MLX4_MAX_PORTS + 1];
-	struct mlx4_slave_event_eq_info event_eq;
+	/* event type to eq number lookup */
+	struct mlx4_slave_event_eq_info event_eq[MLX4_EVENT_TYPES_NUM];
 	u16 eq_pi;
 	u16 eq_ci;
 	spinlock_t lock;
diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
index a30cf19..dcd819b 100644
--- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
+++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
@@ -2023,10 +2023,10 @@ int mlx4_GEN_EQE(struct mlx4_dev *dev, int slave, struct mlx4_eqe *eqe)
 	if (!priv->mfunc.master.slave_state)
 		return -EINVAL;
 
-	event_eq = &priv->mfunc.master.slave_state[slave].event_eq;
+	event_eq = &priv->mfunc.master.slave_state[slave].event_eq[eqe->type];
 
 	/* Create the event only if the slave is registered */
-	if ((event_eq->event_type & (1 << eqe->type)) == 0)
+	if (event_eq->eqn < 0)
 		return 0;
 
 	mutex_lock(&priv->mfunc.master.gen_eqe_mutex[slave]);
-- 
1.5.4.3
