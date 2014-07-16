From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 2/5] net/mlx4_core: Make sure that negative array index isn't used
Date: Wed, 16 Jul 2014 11:57:48 +0300
Message-ID: <1405501071-9340-3-git-send-email-amirv@mellanox.com>
References: <1405501071-9340-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Dotan Barak <dotanb@dev.mellanox.co.il>,
	Eugenia Emantayev <eugenia@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:35192 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1759907AbaGPI6M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jul 2014 04:58:12 -0400
In-Reply-To: <1405501071-9340-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dotan Barak <dotanb@dev.mellanox.co.il>

To make sure that the array index isn't used in the code with
negative value, we stop using the for loop integer iterator
outside of it.
>From now on use members count to swap the last QP with removed one.
Fix also the second occurrence of this flow in mlx4_qp_detach_common().
In mlx4_qp_detach_common() use members_count instead of
loop iterator outside of the for loop.


Signed-off-by: Dotan Barak <dotanb@dev.mellanox.co.il>
Reviewed-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/mcg.c | 38 ++++++++++++++++++++++----------
 1 file changed, 26 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/mcg.c b/drivers/net/ethernet/mellanox/mlx4/mcg.c
index 14a4071..04a8636 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mcg.c
+++ b/drivers/net/ethernet/mellanox/mlx4/mcg.c
@@ -513,7 +513,7 @@ static int remove_promisc_qp(struct mlx4_dev *dev, u8 port,
 	u32 members_count;
 	bool found;
 	bool back_to_list = false;
-	int loc, i;
+	int i;
 	int err;
 
 	if (port < 1 || port > dev->caps.num_ports)
@@ -565,18 +565,30 @@ static int remove_promisc_qp(struct mlx4_dev *dev, u8 port,
 			list_del(&dqp->list);
 			kfree(dqp);
 		} else {
+			int loc = -1;
 			err = mlx4_READ_ENTRY(dev, entry->index, mailbox);
 				if (err)
 					goto out_mailbox;
 			members_count = be32_to_cpu(mgm->members_count) & 0xffffff;
-			for (loc = -1, i = 0; i < members_count; ++i)
-				if ((be32_to_cpu(mgm->qp[i]) & MGM_QPN_MASK) == qpn)
+			for (i = 0; i < members_count; ++i)
+				if ((be32_to_cpu(mgm->qp[i]) &
+				     MGM_QPN_MASK) == qpn) {
 					loc = i;
+					break;
+				}
+
+			if (loc < 0) {
+				mlx4_err(dev, "QP %06x wasn't found in entry %d\n",
+					 qpn, entry->index);
+				err = -EINVAL;
+				goto out_mailbox;
+			}
 
+			/* copy the last QP in this MGM over removed QP */
+			mgm->qp[loc] = mgm->qp[members_count - 1];
+			mgm->qp[members_count - 1] = 0;
 			mgm->members_count = cpu_to_be32(--members_count |
 							 (MLX4_PROT_ETH << 30));
-			mgm->qp[loc] = mgm->qp[i - 1];
-			mgm->qp[i - 1] = 0;
 
 			err = mlx4_WRITE_ENTRY(dev, entry->index, mailbox);
 				if (err)
@@ -1074,7 +1086,7 @@ int mlx4_qp_detach_common(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
 	struct mlx4_mgm *mgm;
 	u32 members_count;
 	int prev, index;
-	int i, loc;
+	int i, loc = -1;
 	int err;
 	u8 port = gid[5];
 	bool removed_entry = false;
@@ -1103,9 +1115,11 @@ int mlx4_qp_detach_common(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
 		goto out;
 
 	members_count = be32_to_cpu(mgm->members_count) & 0xffffff;
-	for (loc = -1, i = 0; i < members_count; ++i)
-		if ((be32_to_cpu(mgm->qp[i]) & MGM_QPN_MASK) == qp->qpn)
+	for (i = 0; i < members_count; ++i)
+		if ((be32_to_cpu(mgm->qp[i]) & MGM_QPN_MASK) == qp->qpn) {
 			loc = i;
+			break;
+		}
 
 	if (loc == -1) {
 		mlx4_err(dev, "QP %06x not found in MGM\n", qp->qpn);
@@ -1113,15 +1127,15 @@ int mlx4_qp_detach_common(struct mlx4_dev *dev, struct mlx4_qp *qp, u8 gid[16],
 		goto out;
 	}
 
-
+	/* copy the last QP in this MGM over removed QP */
+	mgm->qp[loc] = mgm->qp[members_count - 1];
+	mgm->qp[members_count - 1] = 0;
 	mgm->members_count = cpu_to_be32(--members_count | (u32) prot << 30);
-	mgm->qp[loc]       = mgm->qp[i - 1];
-	mgm->qp[i - 1]     = 0;
 
 	if (prot == MLX4_PROT_ETH)
 		removed_entry = can_remove_steering_entry(dev, port, steer,
 								index, qp->qpn);
-	if (i != 1 && (prot != MLX4_PROT_ETH || !removed_entry)) {
+	if (members_count && (prot != MLX4_PROT_ETH || !removed_entry)) {
 		err = mlx4_WRITE_ENTRY(dev, index, mailbox);
 		goto out;
 	}
-- 
1.8.3.4
