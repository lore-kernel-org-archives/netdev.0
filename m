From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net 3/3] net/mlx4_core: Reduce harmless SRIOV error message to debug level
Date: Tue,  9 May 2017 14:45:24 +0300
Message-ID: <1494330324-11752-4-git-send-email-tariqt@mellanox.com>
References: <1494330324-11752-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Jack Morgenstein <jackm@dev.mellanox.co.il>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:49007 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752788AbdEILpu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 9 May 2017 07:45:50 -0400
In-Reply-To: <1494330324-11752-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jack Morgenstein <jackm@dev.mellanox.co.il>

Under SRIOV resource management, extra counters are allocated to VFs
from a free pool. If that pool is empty, the ALLOC_RES command for
a counter resource fails -- and this generates a misleading error
message in the message log.

Under SRIOV, each VF is allocated (i.e., guaranteed) 2 counters --
one counter per port. For ETH ports, the RoCE driver requests an
additional counter (above the guaranteed counters). If that request
fails, the VF RoCE driver simply uses the default (i.e., guaranteed)
counter for that port.

Thus, failing to allocate an additional counter does not constitute
a  problem, and the error message on the PF when this occurs should
be reduced to debug level.

Finally, to identify the situation that the reason for the failure is
that no resources are available to grant to the VF, we modified the
error returned by mlx4_grant_resource to -EDQUOT (Quota exceeded),
which more accurately describes the error.

Fixes: c3abb51bdb0e ("IB/mlx4: Add RoCE/IB dedicated counters")
Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/cmd.c              | 14 +++++++++++---
 drivers/net/ethernet/mellanox/mlx4/resource_tracker.c |  2 +-
 2 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/ethernet/mellanox/mlx4/cmd.c
index 0e0fa7030565..c1af47e45d3f 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
@@ -1789,9 +1789,17 @@ static int mlx4_master_process_vhcr(struct mlx4_dev *dev, int slave,
 	}
 
 	if (err) {
-		if (!(dev->persist->state & MLX4_DEVICE_STATE_INTERNAL_ERROR))
-			mlx4_warn(dev, "vhcr command:0x%x slave:%d failed with error:%d, status %d\n",
-				  vhcr->op, slave, vhcr->errno, err);
+		if (!(dev->persist->state & MLX4_DEVICE_STATE_INTERNAL_ERROR)) {
+			if (vhcr->op == MLX4_CMD_ALLOC_RES &&
+			    (vhcr->in_modifier & 0xff) == RES_COUNTER &&
+			    err == -EDQUOT)
+				mlx4_dbg(dev,
+					 "Unable to allocate counter for slave %d (%d)\n",
+					 slave, err);
+			else
+				mlx4_warn(dev, "vhcr command:0x%x slave:%d failed with error:%d, status %d\n",
+					  vhcr->op, slave, vhcr->errno, err);
+		}
 		vhcr_cmd->status = mlx4_errno_to_status(err);
 		goto out_status;
 	}
diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
index 4aa29ee93013..07516545474f 100644
--- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
+++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
@@ -311,7 +311,7 @@ static inline int mlx4_grant_resource(struct mlx4_dev *dev, int slave,
 	struct mlx4_priv *priv = mlx4_priv(dev);
 	struct resource_allocator *res_alloc =
 		&priv->mfunc.master.res_tracker.res_alloc[res_type];
-	int err = -EINVAL;
+	int err = -EDQUOT;
 	int allocated, free, reserved, guaranteed, from_free;
 	int from_rsvd;
 
-- 
1.8.3.1
