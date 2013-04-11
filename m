From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 1/3] net/mlx4_core: Add helper function to translate B0 steering rules to DMFS
Date: Thu, 11 Apr 2013 14:56:40 +0300
Message-ID: <1365681402-19445-2-git-send-email-amirv@mellanox.com>
References: <1365681402-19445-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Hadar Hen Zion <hadarh@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog104.obsmtp.com ([207.126.144.117]:36417 "EHLO
	eu1sys200aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753411Ab3DKMOE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Apr 2013 08:14:04 -0400
In-Reply-To: <1365681402-19445-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hadar Hen Zion <hadarh@mellanox.com>

A pre-step for supporting guests that use B0 steering over a hypervisor
that runs in DMFS (device managed flow steering mode). Add helper function
which allows to translate L2 attachments / detachments provided in B0 mode
to DMFS rules.

Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/mcg.c  |   51 ++++++++++++++++------------
 drivers/net/ethernet/mellanox/mlx4/mlx4.h |    4 ++
 2 files changed, 33 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/mcg.c b/drivers/net/ethernet/mellanox/mlx4/mcg.c
index 5268552..ffc78d2 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mcg.c
+++ b/drivers/net/ethernet/mellanox/mlx4/mcg.c
@@ -1125,28 +1125,11 @@ static int mlx4_QP_ATTACH(struct mlx4_dev *dev, struct mlx4_qp *qp,
 	return err;
 }
 
-int mlx4_multicast_attach(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
-			  u8 port, int block_mcast_loopback,
-			  enum mlx4_protocol prot, u64 *reg_id)
+int mlx4_trans_to_dmfs_attach(struct mlx4_dev *dev, struct mlx4_qp *qp,
+			      u8 gid[16], u8 port,
+			      int block_mcast_loopback,
+			      enum mlx4_protocol prot, u64 *reg_id)
 {
-
-	switch (dev->caps.steering_mode) {
-	case MLX4_STEERING_MODE_A0:
-		if (prot == MLX4_PROT_ETH)
-			return 0;
-
-	case MLX4_STEERING_MODE_B0:
-		if (prot == MLX4_PROT_ETH)
-			gid[7] |= (MLX4_MC_STEER << 1);
-
-		if (mlx4_is_mfunc(dev))
-			return mlx4_QP_ATTACH(dev, qp, gid, 1,
-					      block_mcast_loopback, prot);
-		return mlx4_qp_attach_common(dev, qp, gid,
-					     block_mcast_loopback, prot,
-					     MLX4_MC_STEER);
-
-	case MLX4_STEERING_MODE_DEVICE_MANAGED: {
 		struct mlx4_spec_list spec = { {NULL} };
 		__be64 mac_mask = cpu_to_be64(MLX4_MAC_MASK << 16);
 
@@ -1180,8 +1163,32 @@ int mlx4_multicast_attach(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
 		list_add_tail(&spec.list, &rule.list);
 
 		return mlx4_flow_attach(dev, &rule, reg_id);
-	}
+}
 
+int mlx4_multicast_attach(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
+			  u8 port, int block_mcast_loopback,
+			  enum mlx4_protocol prot, u64 *reg_id)
+{
+	switch (dev->caps.steering_mode) {
+	case MLX4_STEERING_MODE_A0:
+		if (prot == MLX4_PROT_ETH)
+			return 0;
+
+	case MLX4_STEERING_MODE_B0:
+		if (prot == MLX4_PROT_ETH)
+			gid[7] |= (MLX4_MC_STEER << 1);
+
+		if (mlx4_is_mfunc(dev))
+			return mlx4_QP_ATTACH(dev, qp, gid, 1,
+					      block_mcast_loopback, prot);
+		return mlx4_qp_attach_common(dev, qp, gid,
+					     block_mcast_loopback, prot,
+					     MLX4_MC_STEER);
+
+	case MLX4_STEERING_MODE_DEVICE_MANAGED:
+		return mlx4_trans_to_dmfs_attach(dev, qp, gid, port,
+						 block_mcast_loopback,
+						 prot, reg_id);
 	default:
 		return -EINVAL;
 	}
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4.h b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
index d738454..252f4ba 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
@@ -1190,6 +1190,10 @@ int mlx4_qp_detach_common(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
 int mlx4_qp_attach_common(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
 			  int block_mcast_loopback, enum mlx4_protocol prot,
 			  enum mlx4_steer_type steer);
+int mlx4_trans_to_dmfs_attach(struct mlx4_dev *dev, struct mlx4_qp *qp,
+			      u8 gid[16], u8 port,
+			      int block_mcast_loopback,
+			      enum mlx4_protocol prot, u64 *reg_id);
 int mlx4_SET_MCAST_FLTR_wrapper(struct mlx4_dev *dev, int slave,
 				struct mlx4_vhcr *vhcr,
 				struct mlx4_cmd_mailbox *inbox,
-- 
1.7.8.2
