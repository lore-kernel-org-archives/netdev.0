From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 2/3] net/mlx4_core: Check the correct limitation on VFs for HA mode
Date: Wed,  2 Mar 2016 17:47:45 +0200
Message-ID: <1456933666-28949-3-git-send-email-ogerlitz@mellanox.com>
References: <1456933666-28949-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Majd Dibbiny <majd@mellanox.com>,
	Yishai Hadas <yishaih@mellanox.com>,
	Moni Shoua <monis@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:48317 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752178AbcCBPsS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Mar 2016 10:48:18 -0500
In-Reply-To: <1456933666-28949-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Moni Shoua <monis@mellanox.com>

The limit of 63 is only for virtual functions while the actual enforcement
was for VFs plus physical functions, fix that.

Fixes: e57968a10bc1 ('net/mlx4_core: Support the HA mode for SRIOV VFs too')
Signed-off-by: Moni Shoua <monis@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/main.c | 14 +++++++++++---
 1 file changed, 11 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 2cc3c62..f8674ae 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -1256,6 +1256,7 @@ err_set_port:
 static int mlx4_mf_bond(struct mlx4_dev *dev)
 {
 	int err = 0;
+	int nvfs;
 	struct mlx4_slaves_pport slaves_port1;
 	struct mlx4_slaves_pport slaves_port2;
 	DECLARE_BITMAP(slaves_port_1_2, MLX4_MFUNC_MAX);
@@ -1272,11 +1273,18 @@ static int mlx4_mf_bond(struct mlx4_dev *dev)
 		return -EINVAL;
 	}
 
+	/* number of virtual functions is number of total functions minus one
+	 * physical function for each port.
+	 */
+	nvfs = bitmap_weight(slaves_port1.slaves, dev->persist->num_vfs + 1) +
+		bitmap_weight(slaves_port2.slaves, dev->persist->num_vfs + 1) - 2;
+
 	/* limit on maximum allowed VFs */
-	if ((bitmap_weight(slaves_port1.slaves, dev->persist->num_vfs + 1) +
-	    bitmap_weight(slaves_port2.slaves, dev->persist->num_vfs + 1)) >
-	    MAX_MF_BOND_ALLOWED_SLAVES)
+	if (nvfs > MAX_MF_BOND_ALLOWED_SLAVES) {
+		mlx4_warn(dev, "HA mode is not supported for %d VFs (max %d are allowed)\n",
+			  nvfs, MAX_MF_BOND_ALLOWED_SLAVES);
 		return -EINVAL;
+	}
 
 	if (dev->caps.steering_mode != MLX4_STEERING_MODE_DEVICE_MANAGED) {
 		mlx4_warn(dev, "HA mode unsupported for NON DMFS steering\n");
-- 
2.3.7
