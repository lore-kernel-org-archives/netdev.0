From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 1/8] net/mlx4: Address build warnings on set but not used variables
Date: Mon, 14 May 2012 23:04:06 +0300
Message-ID: <1337025853-26685-2-git-send-email-ogerlitz@mellanox.com>
References: <1337025853-26685-1-git-send-email-ogerlitz@mellanox.com>
Cc: roland@kernel.org, netdev@vger.kernel.org,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog106.obsmtp.com ([207.126.144.121]:35906 "HELO
	eu1sys200aog106.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1757660Ab2ENUEZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 May 2012 16:04:25 -0400
In-Reply-To: <1337025853-26685-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Handle the compiler warnings on variables which are set but not used
by removing the relevant variable or casting a return value which is
ignored on purpose to void.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/cmd.c           |    5 +----
 drivers/net/ethernet/mellanox/mlx4/mcg.c           |    2 --
 drivers/net/ethernet/mellanox/mlx4/mr.c            |    3 ---
 drivers/net/ethernet/mellanox/mlx4/port.c          |    3 +--
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |    7 +++----
 5 files changed, 5 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/ethernet/mellanox/mlx4/cmd.c
index 773c70e..53b738b 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
@@ -1254,7 +1254,6 @@ static void mlx4_master_do_cmd(struct mlx4_dev *dev, int slave, u8 cmd,
 	struct mlx4_priv *priv = mlx4_priv(dev);
 	struct mlx4_slave_state *slave_state = priv->mfunc.master.slave_state;
 	u32 reply;
-	u32 slave_status = 0;
 	u8 is_going_down = 0;
 	int i;
 
@@ -1274,10 +1273,8 @@ static void mlx4_master_do_cmd(struct mlx4_dev *dev, int slave, u8 cmd,
 		}
 		/*check if we are in the middle of FLR process,
 		if so return "retry" status to the slave*/
-		if (MLX4_COMM_CMD_FLR == slave_state[slave].last_cmd) {
-			slave_status = MLX4_DELAY_RESET_SLAVE;
+		if (MLX4_COMM_CMD_FLR == slave_state[slave].last_cmd)
 			goto inform_slave_state;
-		}
 
 		/* write the version in the event field */
 		reply |= mlx4_comm_get_version();
diff --git a/drivers/net/ethernet/mellanox/mlx4/mcg.c b/drivers/net/ethernet/mellanox/mlx4/mcg.c
index 4799e82..f4a8f98 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mcg.c
+++ b/drivers/net/ethernet/mellanox/mlx4/mcg.c
@@ -357,7 +357,6 @@ static int add_promisc_qp(struct mlx4_dev *dev, u8 port,
 	u32 prot;
 	int i;
 	bool found;
-	int last_index;
 	int err;
 	struct mlx4_priv *priv = mlx4_priv(dev);
 
@@ -419,7 +418,6 @@ static int add_promisc_qp(struct mlx4_dev *dev, u8 port,
 			if (err)
 				goto out_mailbox;
 		}
-		last_index = entry->index;
 	}
 
 	/* add the new qpn to list of promisc qps */
diff --git a/drivers/net/ethernet/mellanox/mlx4/mr.c b/drivers/net/ethernet/mellanox/mlx4/mr.c
index fe2ac84..cefa76f 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mr.c
+++ b/drivers/net/ethernet/mellanox/mlx4/mr.c
@@ -788,7 +788,6 @@ int mlx4_fmr_alloc(struct mlx4_dev *dev, u32 pd, u32 access, int max_pages,
 		   int max_maps, u8 page_shift, struct mlx4_fmr *fmr)
 {
 	struct mlx4_priv *priv = mlx4_priv(dev);
-	u64 mtt_offset;
 	int err = -ENOMEM;
 
 	if (max_maps > dev->caps.max_fmr_maps)
@@ -811,8 +810,6 @@ int mlx4_fmr_alloc(struct mlx4_dev *dev, u32 pd, u32 access, int max_pages,
 	if (err)
 		return err;
 
-	mtt_offset = fmr->mr.mtt.offset * dev->caps.mtt_entry_sz;
-
 	fmr->mtts = mlx4_table_find(&priv->mr_table.mtt_table,
 				    fmr->mr.mtt.offset,
 				    &fmr->dma_handle);
diff --git a/drivers/net/ethernet/mellanox/mlx4/port.c b/drivers/net/ethernet/mellanox/mlx4/port.c
index 55b12e6..70ef4f1 100644
--- a/drivers/net/ethernet/mellanox/mlx4/port.c
+++ b/drivers/net/ethernet/mellanox/mlx4/port.c
@@ -338,11 +338,10 @@ EXPORT_SYMBOL_GPL(__mlx4_unregister_mac);
 void mlx4_unregister_mac(struct mlx4_dev *dev, u8 port, u64 mac)
 {
 	u64 out_param;
-	int err;
 
 	if (mlx4_is_mfunc(dev)) {
 		set_param_l(&out_param, port);
-		err = mlx4_cmd_imm(dev, mac, &out_param, RES_MAC,
+		(void) mlx4_cmd_imm(dev, mac, &out_param, RES_MAC,
 				   RES_OP_RESERVE_AND_MAP, MLX4_CMD_FREE_RES,
 				   MLX4_CMD_TIME_CLASS_A, MLX4_CMD_WRAPPED);
 		return;
diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
index 8752e6e..d8970cc 100644
--- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
+++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
@@ -2536,7 +2536,7 @@ int mlx4_QP_ATTACH_wrapper(struct mlx4_dev *dev, int slave,
 	struct mlx4_qp qp; /* dummy for calling attach/detach */
 	u8 *gid = inbox->buf;
 	enum mlx4_protocol prot = (vhcr->in_modifier >> 28) & 0x7;
-	int err, err1;
+	int err;
 	int qpn;
 	struct res_qp *rqp;
 	int attach = vhcr->op_modifier;
@@ -2571,7 +2571,7 @@ int mlx4_QP_ATTACH_wrapper(struct mlx4_dev *dev, int slave,
 
 ex_rem:
 	/* ignore error return below, already in error */
-	err1 = rem_mcg_res(dev, slave, rqp, gid, prot, type);
+	(void) rem_mcg_res(dev, slave, rqp, gid, prot, type);
 ex_put:
 	put_res(dev, slave, qpn, RES_QP);
 
@@ -2604,12 +2604,11 @@ static void detach_qp(struct mlx4_dev *dev, int slave, struct res_qp *rqp)
 {
 	struct res_gid *rgid;
 	struct res_gid *tmp;
-	int err;
 	struct mlx4_qp qp; /* dummy for calling attach/detach */
 
 	list_for_each_entry_safe(rgid, tmp, &rqp->mcg_list, list) {
 		qp.qpn = rqp->local_qpn;
-		err = mlx4_qp_detach_common(dev, &qp, rgid->gid, rgid->prot,
+		(void) mlx4_qp_detach_common(dev, &qp, rgid->gid, rgid->prot,
 					    rgid->steer);
 		list_del(&rgid->list);
 		kfree(rgid);
-- 
1.7.1
