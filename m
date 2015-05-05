From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 2/2] net/mlx4_core: Work properly with EQ numbers > 256 in SRIOV
Date: Tue,  5 May 2015 17:07:12 +0300
Message-ID: <1430834832-13559-3-git-send-email-ogerlitz@mellanox.com>
References: <1430834832-13559-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Yishai Hadas <yishaih@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1327.ztomy.com ([193.47.165.129]:54740 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751840AbbEEOHs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 May 2015 10:07:48 -0400
In-Reply-To: <1430834832-13559-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yishai Hadas <yishaih@mellanox.com>

The Firmware uses dynamic EQs allocation based on number of VFs and
max EQs that can be allocated. As a result, VF can have EQ numbers
that are larger than 256.

According to the firmware spec, the max value is limited to be 1024
(10 bits), adapt the relevant code accordingly. This bug was impossible
to hit prior to commit 7ae0e400cd93 ("net/mlx4_core: Flexible (asymmetric)
allocation of EQs and MSI-X vectors for PF/VFs") which actually enables
large number of EQs for VFs.

Signed-off-by: Yishai Hadas <yishaih@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
index c7f28bf..92fce1b 100644
--- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
+++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
@@ -2845,7 +2845,7 @@ int mlx4_SW2HW_EQ_wrapper(struct mlx4_dev *dev, int slave,
 {
 	int err;
 	int eqn = vhcr->in_modifier;
-	int res_id = (slave << 8) | eqn;
+	int res_id = (slave << 10) | eqn;
 	struct mlx4_eq_context *eqc = inbox->buf;
 	int mtt_base = eq_get_mtt_addr(eqc) / dev->caps.mtt_entry_sz;
 	int mtt_size = eq_get_mtt_size(eqc);
@@ -3051,7 +3051,7 @@ int mlx4_HW2SW_EQ_wrapper(struct mlx4_dev *dev, int slave,
 			  struct mlx4_cmd_info *cmd)
 {
 	int eqn = vhcr->in_modifier;
-	int res_id = eqn | (slave << 8);
+	int res_id = eqn | (slave << 10);
 	struct res_eq *eq;
 	int err;
 
@@ -3108,7 +3108,7 @@ int mlx4_GEN_EQE(struct mlx4_dev *dev, int slave, struct mlx4_eqe *eqe)
 		return 0;
 
 	mutex_lock(&priv->mfunc.master.gen_eqe_mutex[slave]);
-	res_id = (slave << 8) | event_eq->eqn;
+	res_id = (slave << 10) | event_eq->eqn;
 	err = get_res(dev, slave, res_id, RES_EQ, &req);
 	if (err)
 		goto unlock;
@@ -3131,7 +3131,7 @@ int mlx4_GEN_EQE(struct mlx4_dev *dev, int slave, struct mlx4_eqe *eqe)
 
 	memcpy(mailbox->buf, (u8 *) eqe, 28);
 
-	in_modifier = (slave & 0xff) | ((event_eq->eqn & 0xff) << 16);
+	in_modifier = (slave & 0xff) | ((event_eq->eqn & 0x3ff) << 16);
 
 	err = mlx4_cmd(dev, mailbox->dma, in_modifier, 0,
 		       MLX4_CMD_GEN_EQE, MLX4_CMD_TIME_CLASS_B,
@@ -3157,7 +3157,7 @@ int mlx4_QUERY_EQ_wrapper(struct mlx4_dev *dev, int slave,
 			  struct mlx4_cmd_info *cmd)
 {
 	int eqn = vhcr->in_modifier;
-	int res_id = eqn | (slave << 8);
+	int res_id = eqn | (slave << 10);
 	struct res_eq *eq;
 	int err;
 
@@ -4714,13 +4714,13 @@ static void rem_slave_eqs(struct mlx4_dev *dev, int slave)
 					break;
 
 				case RES_EQ_HW:
-					err = mlx4_cmd(dev, slave, eqn & 0xff,
+					err = mlx4_cmd(dev, slave, eqn & 0x3ff,
 						       1, MLX4_CMD_HW2SW_EQ,
 						       MLX4_CMD_TIME_CLASS_A,
 						       MLX4_CMD_NATIVE);
 					if (err)
 						mlx4_dbg(dev, "rem_slave_eqs: failed to move slave %d eqs %d to SW ownership\n",
-							 slave, eqn);
+							 slave, eqn & 0x3ff);
 					atomic_dec(&eq->mtt->ref_count);
 					state = RES_EQ_RESERVED;
 					break;
-- 
1.7.1
