From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH V2 net-next 7/7] mlx4: Activate RoCE/SRIOV
Date: Wed, 12 Mar 2014 12:00:43 +0200
Message-ID: <1394618443-20337-8-git-send-email-ogerlitz@mellanox.com>
References: <1394618443-20337-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, roland@kernel.org,
	jackm@dev.mellanox.co.il, amirv@mellanox.com,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:59189 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753180AbaCLKBD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Mar 2014 06:01:03 -0400
In-Reply-To: <1394618443-20337-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jack Morgenstein <jackm@dev.mellanox.co.il>

To activate RoCE/SRIOV, need to remove the following:
1. In mlx4_ib_add, need to remove the error return preventing
   initialization of a RoCE port under SRIOV.
2. In update_vport_qp_params (in resource_tracker.c) need to remove
   the error return when a RoCE RC or UD qp is detected.
   This error return causes the INIT-to-RTR qp transition to fail
   in the wrapper function under RoCE/SRIOV.

Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/infiniband/hw/mlx4/main.c                  |    8 --------
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |    7 -------
 2 files changed, 0 insertions(+), 15 deletions(-)

diff --git a/drivers/infiniband/hw/mlx4/main.c b/drivers/infiniband/hw/mlx4/main.c
index f9c12e9..1d1750e 100644
--- a/drivers/infiniband/hw/mlx4/main.c
+++ b/drivers/infiniband/hw/mlx4/main.c
@@ -1888,14 +1888,6 @@ static void *mlx4_ib_add(struct mlx4_dev *dev)
 
 	pr_info_once("%s", mlx4_ib_version);
 
-	mlx4_foreach_non_ib_transport_port(i, dev)
-		num_ports++;
-
-	if (mlx4_is_mfunc(dev) && num_ports) {
-		dev_err(&dev->pdev->dev, "RoCE is not supported over SRIOV as yet\n");
-		return NULL;
-	}
-
 	num_ports = 0;
 	mlx4_foreach_ib_transport_port(i, dev)
 		num_ports++;
diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
index 706a6d2..74e490d 100644
--- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
+++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
@@ -645,7 +645,6 @@ static int update_vport_qp_param(struct mlx4_dev *dev,
 	struct mlx4_qp_context	*qpc = inbox->buf + 8;
 	struct mlx4_vport_oper_state *vp_oper;
 	struct mlx4_priv *priv;
-	u32 qp_type;
 	int port;
 
 	port = (qpc->pri_path.sched_queue & 0x40) ? 2 : 1;
@@ -653,12 +652,6 @@ static int update_vport_qp_param(struct mlx4_dev *dev,
 	vp_oper = &priv->mfunc.master.vf_oper[slave].vport[port];
 
 	if (MLX4_VGT != vp_oper->state.default_vlan) {
-		qp_type	= (be32_to_cpu(qpc->flags) >> 16) & 0xff;
-		if (MLX4_QP_ST_RC == qp_type ||
-		    (MLX4_QP_ST_UD == qp_type &&
-		     !mlx4_is_qp_reserved(dev, qpn)))
-			return -EINVAL;
-
 		/* the reserved QPs (special, proxy, tunnel)
 		 * do not operate over vlans
 		 */
-- 
1.7.1
