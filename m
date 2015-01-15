From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net] net/mlx4: Don't disable vxlan offloads under DMFS-A0 optimized steering
Date: Thu, 15 Jan 2015 15:28:54 +0200
Message-ID: <1421328534-14216-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Matan Barak <matanb@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:48589 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751470AbbAON26 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jan 2015 08:28:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Except for VXLAN steering rules, all offloads should work as they were
under plain DMFS mode. Fix that by enabling all the offloads under
DMFS-A0 mode, except for VXLAN steering rules.

Fixes: d57febe1a478 "net/mlx4: Add A0 hybrid steering"
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/infiniband/hw/mlx4/main.c              |    3 ++-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |    3 ++-
 drivers/net/ethernet/mellanox/mlx4/main.c      |    3 +--
 3 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/infiniband/hw/mlx4/main.c b/drivers/infiniband/hw/mlx4/main.c
index 57ecc5b..9117b7a 100644
--- a/drivers/infiniband/hw/mlx4/main.c
+++ b/drivers/infiniband/hw/mlx4/main.c
@@ -1114,7 +1114,8 @@ static int mlx4_ib_tunnel_steer_add(struct ib_qp *qp, struct ib_flow_attr *flow_
 	struct mlx4_dev	*dev = to_mdev(qp->device)->dev;
 	int err = 0;
 
-	if (dev->caps.tunnel_offload_mode != MLX4_TUNNEL_OFFLOAD_MODE_VXLAN)
+	if (dev->caps.tunnel_offload_mode != MLX4_TUNNEL_OFFLOAD_MODE_VXLAN ||
+	    dev->caps.dmfs_high_steer_mode == MLX4_STEERING_DMFS_A0_STATIC)
 		return 0; /* do nothing */
 
 	ib_flow = flow_attr + 1;
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index d0d6dc1..ac6a8f1 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -475,7 +475,8 @@ static int mlx4_en_tunnel_steer_add(struct mlx4_en_priv *priv, unsigned char *ad
 {
 	int err;
 
-	if (priv->mdev->dev->caps.tunnel_offload_mode != MLX4_TUNNEL_OFFLOAD_MODE_VXLAN)
+	if (priv->mdev->dev->caps.tunnel_offload_mode != MLX4_TUNNEL_OFFLOAD_MODE_VXLAN ||
+	    priv->mdev->dev->caps.dmfs_high_steer_mode == MLX4_STEERING_DMFS_A0_STATIC)
 		return 0; /* do nothing */
 
 	err = mlx4_tunnel_steer_add(priv->mdev->dev, addr, priv->port, qpn,
diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 5798355..37a1235 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -1745,8 +1745,7 @@ static void choose_tunnel_offload_mode(struct mlx4_dev *dev,
 				       struct mlx4_dev_cap *dev_cap)
 {
 	if (dev->caps.steering_mode == MLX4_STEERING_MODE_DEVICE_MANAGED &&
-	    dev_cap->flags2 & MLX4_DEV_CAP_FLAG2_VXLAN_OFFLOADS &&
-	    dev->caps.dmfs_high_steer_mode != MLX4_STEERING_DMFS_A0_STATIC)
+	    dev_cap->flags2 & MLX4_DEV_CAP_FLAG2_VXLAN_OFFLOADS)
 		dev->caps.tunnel_offload_mode = MLX4_TUNNEL_OFFLOAD_MODE_VXLAN;
 	else
 		dev->caps.tunnel_offload_mode = MLX4_TUNNEL_OFFLOAD_MODE_NONE;
-- 
1.7.1
