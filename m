From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 3/4] net/mlx4: Avoid dealing with MAC index in UPDATE_QP wrapper if not needed
Date: Wed, 10 Sep 2014 16:41:55 +0300
Message-ID: <1410356516-23594-4-git-send-email-ogerlitz@mellanox.com>
References: <1410356516-23594-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Amir Vadai <amirv@mellanox.com>,
	Matan Barak <matanb@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:46275 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750956AbaIJNmK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Sep 2014 09:42:10 -0400
In-Reply-To: <1410356516-23594-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matan Barak <matanb@mellanox.com>

The current wrapper implementation of the UPDATE_QP command tries to get
the MAC index, even if MAC wasn't set by the VF. Fix it up to only handle
the MAC field if it's valid.

Fixes: ce8d9e0 ('net/mlx4_core: Add UPDATE_QP SRIOV wrapper support')
Signed-off-by: Matan Barak <matanb@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |   18 +++++++++++-------
 1 files changed, 11 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
index f87a4a3..2fe61b6 100644
--- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
+++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
@@ -3998,13 +3998,17 @@ int mlx4_UPDATE_QP_wrapper(struct mlx4_dev *dev, int slave,
 	}
 
 	port = (rqp->sched_queue >> 6 & 1) + 1;
-	smac_index = cmd->qp_context.pri_path.grh_mylmc;
-	err = mac_find_smac_ix_in_slave(dev, slave, port,
-					smac_index, &mac);
-	if (err) {
-		mlx4_err(dev, "Failed to update qpn 0x%x, MAC is invalid. smac_ix: %d\n",
-			 qpn, smac_index);
-		goto err_mac;
+
+	if (pri_addr_path_mask & (1ULL << MLX4_UPD_QP_PATH_MASK_MAC_INDEX)) {
+		smac_index = cmd->qp_context.pri_path.grh_mylmc;
+		err = mac_find_smac_ix_in_slave(dev, slave, port,
+						smac_index, &mac);
+
+		if (err) {
+			mlx4_err(dev, "Failed to update qpn 0x%x, MAC is invalid. smac_ix: %d\n",
+				 qpn, smac_index);
+			goto err_mac;
+		}
 	}
 
 	err = mlx4_cmd(dev, inbox->dma,
-- 
1.7.1
