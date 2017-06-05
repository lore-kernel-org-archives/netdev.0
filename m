From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net] net/mlx4: Check if Granular QoS per VF has been enabled before updating QP qos_vport
Date: Mon,  5 Jun 2017 10:44:56 +0300
Message-ID: <1496648696-5457-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Ido Shamay <idos@mellanox.com>,
        Jack Morgenstein <jackm@dev.mellanox.co.il>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:42141 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751321AbdFEHpm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2017 03:45:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Shamay <idos@mellanox.com>

The Granular QoS per VF feature must be enabled in FW before it can be
used.

Thus, the driver cannot modify a QP's qos_vport value (via the UPDATE_QP FW
command) if the feature has not been enabled -- the FW returns an error if
this is attempted.

Fixes: 08068cd5683f ("net/mlx4: Added qos_vport QP configuration in VST mode")
Signed-off-by: Ido Shamay <idos@mellanox.com>
Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/qp.c               |  6 ++++++
 drivers/net/ethernet/mellanox/mlx4/resource_tracker.c | 16 +++++++++++-----
 2 files changed, 17 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/qp.c b/drivers/net/ethernet/mellanox/mlx4/qp.c
index ad92d2311478..5a310d313e94 100644
--- a/drivers/net/ethernet/mellanox/mlx4/qp.c
+++ b/drivers/net/ethernet/mellanox/mlx4/qp.c
@@ -484,6 +484,12 @@ int mlx4_update_qp(struct mlx4_dev *dev, u32 qpn,
 	}
 
 	if (attr & MLX4_UPDATE_QP_QOS_VPORT) {
+		if (!(dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_QOS_VPP)) {
+			mlx4_warn(dev, "Granular QoS per VF is not enabled\n");
+			err = -EOPNOTSUPP;
+			goto out;
+		}
+
 		qp_mask |= 1ULL << MLX4_UPD_QP_MASK_QOS_VPP;
 		cmd->qp_context.qos_vport = params->qos_vport;
 	}
diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
index 07516545474f..812783865205 100644
--- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
+++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
@@ -5255,6 +5255,13 @@ void mlx4_delete_all_resources_for_slave(struct mlx4_dev *dev, int slave)
 	mutex_unlock(&priv->mfunc.master.res_tracker.slave_list[slave].mutex);
 }
 
+static void update_qos_vpp(struct mlx4_update_qp_context *ctx,
+			   struct mlx4_vf_immed_vlan_work *work)
+{
+	ctx->qp_mask |= cpu_to_be64(1ULL << MLX4_UPD_QP_MASK_QOS_VPP);
+	ctx->qp_context.qos_vport = work->qos_vport;
+}
+
 void mlx4_vf_immed_vlan_work_handler(struct work_struct *_work)
 {
 	struct mlx4_vf_immed_vlan_work *work =
@@ -5369,11 +5376,10 @@ void mlx4_vf_immed_vlan_work_handler(struct work_struct *_work)
 					qp->sched_queue & 0xC7;
 				upd_context->qp_context.pri_path.sched_queue |=
 					((work->qos & 0x7) << 3);
-				upd_context->qp_mask |=
-					cpu_to_be64(1ULL <<
-						    MLX4_UPD_QP_MASK_QOS_VPP);
-				upd_context->qp_context.qos_vport =
-					work->qos_vport;
+
+				if (dev->caps.flags2 &
+				    MLX4_DEV_CAP_FLAG2_QOS_VPP)
+					update_qos_vpp(upd_context, work);
 			}
 
 			err = mlx4_cmd(dev, mailbox->dma,
-- 
1.8.3.1
