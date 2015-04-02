From: Eli Cohen <eli@dev.mellanox.co.il>
Subject: [PATCH net-next 15/16] net/mlx5_core: Modify arm CQ in preparation for upcoming Ethernet driver
Date: Thu,  2 Apr 2015 17:07:33 +0300
Message-ID: <1427983654-971-16-git-send-email-eli@mellanox.com>
References: <1427983654-971-1-git-send-email-eli@mellanox.com>
Cc: netdev@vger.kernel.org, idos@mellaox.com, amirv@mellanox.com,
	Saeed Mahameed <saeedm@mellanox.com>,
	Eli Cohen <eli@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:34843 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753361AbbDBOIQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2015 10:08:16 -0400
Received: by wgdm6 with SMTP id m6so86632065wgd.2
        for <netdev@vger.kernel.org>; Thu, 02 Apr 2015 07:08:15 -0700 (PDT)
In-Reply-To: <1427983654-971-1-git-send-email-eli@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>

Pass consumer index as a parameter to arm CQ

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Eli Cohen <eli@mellanox.com>
---
 drivers/infiniband/hw/mlx5/cq.c | 8 ++++++--
 include/linux/mlx5/cq.h         | 5 +++--
 2 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/drivers/infiniband/hw/mlx5/cq.c b/drivers/infiniband/hw/mlx5/cq.c
index c94e2651820d..2ee6b1051975 100644
--- a/drivers/infiniband/hw/mlx5/cq.c
+++ b/drivers/infiniband/hw/mlx5/cq.c
@@ -572,11 +572,15 @@ int mlx5_ib_poll_cq(struct ib_cq *ibcq, int num_entries, struct ib_wc *wc)
 
 int mlx5_ib_arm_cq(struct ib_cq *ibcq, enum ib_cq_notify_flags flags)
 {
+	struct mlx5_core_dev *mdev = to_mdev(ibcq->device)->mdev;
+	void __iomem *uar_page = mdev->priv.uuari.uars[0].map;
+
 	mlx5_cq_arm(&to_mcq(ibcq)->mcq,
 		    (flags & IB_CQ_SOLICITED_MASK) == IB_CQ_SOLICITED ?
 		    MLX5_CQ_DB_REQ_NOT_SOL : MLX5_CQ_DB_REQ_NOT,
-		    to_mdev(ibcq->device)->mdev->priv.uuari.uars[0].map,
-		    MLX5_GET_DOORBELL_LOCK(&to_mdev(ibcq->device)->mdev->priv.cq_uar_lock));
+		    uar_page,
+		    MLX5_GET_DOORBELL_LOCK(&mdev->priv.cq_uar_lock),
+		    to_mcq(ibcq)->mcq.cons_index);
 
 	return 0;
 }
diff --git a/include/linux/mlx5/cq.h b/include/linux/mlx5/cq.h
index 72ee0d732a26..2695ced222df 100644
--- a/include/linux/mlx5/cq.h
+++ b/include/linux/mlx5/cq.h
@@ -137,14 +137,15 @@ enum {
 
 static inline void mlx5_cq_arm(struct mlx5_core_cq *cq, u32 cmd,
 			       void __iomem *uar_page,
-			       spinlock_t *doorbell_lock)
+			       spinlock_t *doorbell_lock,
+			       u32 cons_index)
 {
 	__be32 doorbell[2];
 	u32 sn;
 	u32 ci;
 
 	sn = cq->arm_sn & 3;
-	ci = cq->cons_index & 0xffffff;
+	ci = cons_index & 0xffffff;
 
 	*cq->arm_db = cpu_to_be32(sn << 28 | cmd | ci);
 
-- 
2.3.1
