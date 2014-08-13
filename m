From: Eli Cohen <eli@dev.mellanox.co.il>
Subject: [PATCH net-next 04/10] IB/mlx5: Remove duplicate code from mlx5_set_path
Date: Wed, 13 Aug 2014 14:39:05 +0300
Message-ID: <1407929951-16362-5-git-send-email-eli@mellanox.com>
References: <1407929951-16362-1-git-send-email-eli@mellanox.com>
Cc: netdev@vger.kernel.org, rdma@vger.kernel.org, amirv@mellanox.com,
	yevgenyp@mellanox.com, Eli Cohen <eli@mellanox.com>
To: roland@kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f50.google.com ([74.125.82.50]:35880 "EHLO
	mail-wg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752088AbaHMLjm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2014 07:39:42 -0400
Received: by mail-wg0-f50.google.com with SMTP id n12so11066140wgh.33
        for <netdev@vger.kernel.org>; Wed, 13 Aug 2014 04:39:41 -0700 (PDT)
In-Reply-To: <1407929951-16362-1-git-send-email-eli@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some of the fields where set twice. Re-organize to avoid that.

Signed-off-by: Eli Cohen <eli@mellanox.com>
---
 drivers/infiniband/hw/mlx5/qp.c | 21 +++++----------------
 1 file changed, 5 insertions(+), 16 deletions(-)

diff --git a/drivers/infiniband/hw/mlx5/qp.c b/drivers/infiniband/hw/mlx5/qp.c
index 9c1c76b0b7f5..a5192336efd7 100644
--- a/drivers/infiniband/hw/mlx5/qp.c
+++ b/drivers/infiniband/hw/mlx5/qp.c
@@ -1317,6 +1317,11 @@ static int mlx5_set_path(struct mlx5_ib_dev *dev, const struct ib_ah_attr *ah,
 	path->rlid	= cpu_to_be16(ah->dlid);
 
 	if (ah->ah_flags & IB_AH_GRH) {
+		if (ah->grh.sgid_index >= gen->port[port - 1].gid_table_len) {
+			pr_err(KERN_ERR "sgid_index (%u) too large. max is %d\n",
+			       ah->grh.sgid_index, gen->port[port - 1].gid_table_len);
+			return -EINVAL;
+		}
 		path->grh_mlid |= 1 << 7;
 		path->mgid_index = ah->grh.sgid_index;
 		path->hop_limit  = ah->grh.hop_limit;
@@ -1332,22 +1337,6 @@ static int mlx5_set_path(struct mlx5_ib_dev *dev, const struct ib_ah_attr *ah,
 	path->static_rate = err;
 	path->port = port;
 
-	if (ah->ah_flags & IB_AH_GRH) {
-		if (ah->grh.sgid_index >= gen->port[port - 1].gid_table_len) {
-			pr_err(KERN_ERR "sgid_index (%u) too large. max is %d\n",
-			       ah->grh.sgid_index, gen->port[port - 1].gid_table_len);
-			return -EINVAL;
-		}
-
-		path->grh_mlid |= 1 << 7;
-		path->mgid_index = ah->grh.sgid_index;
-		path->hop_limit  = ah->grh.hop_limit;
-		path->tclass_flowlabel =
-			cpu_to_be32((ah->grh.traffic_class << 20) |
-				    (ah->grh.flow_label));
-		memcpy(path->rgid, ah->grh.dgid.raw, 16);
-	}
-
 	if (attr_mask & IB_QP_TIMEOUT)
 		path->ackto_lt = attr->timeout << 3;
 
-- 
1.9.3
