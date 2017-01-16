From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net 3/3] net/mlx4_core: Eliminate warning messages for SRQ_LIMIT under SRIOV
Date: Mon, 16 Jan 2017 18:31:39 +0200
Message-ID: <1484584299-3950-4-git-send-email-tariqt@mellanox.com>
References: <1484584299-3950-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Jack Morgenstein <jackm@dev.mellanox.co.il>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:36311 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751421AbdAPQcA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2017 11:32:00 -0500
In-Reply-To: <1484584299-3950-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jack Morgenstein <jackm@dev.mellanox.co.il>

When running SRIOV, warnings for SRQ LIMIT events flood the Hypervisor's
message log when (correct, normally operating) apps use SRQ LIMIT events
as a trigger to post WQEs to SRQs.

Add more information to the existing debug printout for SRQ_LIMIT, and
output the warning messages only for the SRQ CATAS ERROR event.

Fixes: acba2420f9d2 ("mlx4_core: Add wrapper functions and comm channel and slave event support to EQs")
Fixes: e0debf9cb50d ("mlx4_core: Reduce warning message for SRQ_LIMIT event to debug level")
Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/eq.c | 23 ++++++++++++++---------
 1 file changed, 14 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/eq.c b/drivers/net/ethernet/mellanox/mlx4/eq.c
index cd3638e6fe25..0509996957d9 100644
--- a/drivers/net/ethernet/mellanox/mlx4/eq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/eq.c
@@ -554,8 +554,9 @@ static int mlx4_eq_int(struct mlx4_dev *dev, struct mlx4_eq *eq)
 			break;
 
 		case MLX4_EVENT_TYPE_SRQ_LIMIT:
-			mlx4_dbg(dev, "%s: MLX4_EVENT_TYPE_SRQ_LIMIT\n",
-				 __func__);
+			mlx4_dbg(dev, "%s: MLX4_EVENT_TYPE_SRQ_LIMIT. srq_no=0x%x, eq 0x%x\n",
+				 __func__, be32_to_cpu(eqe->event.srq.srqn),
+				 eq->eqn);
 		case MLX4_EVENT_TYPE_SRQ_CATAS_ERROR:
 			if (mlx4_is_master(dev)) {
 				/* forward only to slave owning the SRQ */
@@ -570,15 +571,19 @@ static int mlx4_eq_int(struct mlx4_dev *dev, struct mlx4_eq *eq)
 						  eq->eqn, eq->cons_index, ret);
 					break;
 				}
-				mlx4_warn(dev, "%s: slave:%d, srq_no:0x%x, event: %02x(%02x)\n",
-					  __func__, slave,
-					  be32_to_cpu(eqe->event.srq.srqn),
-					  eqe->type, eqe->subtype);
+				if (eqe->type ==
+				    MLX4_EVENT_TYPE_SRQ_CATAS_ERROR)
+					mlx4_warn(dev, "%s: slave:%d, srq_no:0x%x, event: %02x(%02x)\n",
+						  __func__, slave,
+						  be32_to_cpu(eqe->event.srq.srqn),
+						  eqe->type, eqe->subtype);
 
 				if (!ret && slave != dev->caps.function) {
-					mlx4_warn(dev, "%s: sending event %02x(%02x) to slave:%d\n",
-						  __func__, eqe->type,
-						  eqe->subtype, slave);
+					if (eqe->type ==
+					    MLX4_EVENT_TYPE_SRQ_CATAS_ERROR)
+						mlx4_warn(dev, "%s: sending event %02x(%02x) to slave:%d\n",
+							  __func__, eqe->type,
+							  eqe->subtype, slave);
 					mlx4_slave_event(dev, slave, eqe);
 					break;
 				}
-- 
1.8.3.1
