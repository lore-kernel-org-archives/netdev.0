From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net-next V2 3/4] net/mlx4_core: Use RCU to perform radix tree lookup for SRQ
Date: Tue, 20 Sep 2016 14:39:41 +0300
Message-ID: <1474371582-998-4-git-send-email-tariqt@mellanox.com>
References: <1474371582-998-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Leon Romanovsky <leonro@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:36798 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1754336AbcITLl0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 07:41:26 -0400
In-Reply-To: <1474371582-998-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Leon Romanovsky <leonro@mellanox.com>

Radix tree lookup can be performed without locking.

Fixes: 225c7b1feef1 ("IB/mlx4: Add a driver Mellanox ConnectX InfiniBand adapters")
Signed-off-by: Leon Romanovsky <leonro@mellanox.com>
Suggested-by: Sagi Grimberg <sagi@grimberg.me>
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/srq.c | 14 +++++---------
 1 file changed, 5 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/srq.c b/drivers/net/ethernet/mellanox/mlx4/srq.c
index 67146624eb58..f44d089e2ca6 100644
--- a/drivers/net/ethernet/mellanox/mlx4/srq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/srq.c
@@ -45,15 +45,12 @@ void mlx4_srq_event(struct mlx4_dev *dev, u32 srqn, int event_type)
 	struct mlx4_srq_table *srq_table = &mlx4_priv(dev)->srq_table;
 	struct mlx4_srq *srq;
 
-	spin_lock(&srq_table->lock);
-
+	rcu_read_lock();
 	srq = radix_tree_lookup(&srq_table->tree, srqn & (dev->caps.num_srqs - 1));
+	rcu_read_unlock();
 	if (srq)
 		atomic_inc(&srq->refcount);
-
-	spin_unlock(&srq_table->lock);
-
-	if (!srq) {
+	else {
 		mlx4_warn(dev, "Async event for bogus SRQ %08x\n", srqn);
 		return;
 	}
@@ -301,12 +298,11 @@ struct mlx4_srq *mlx4_srq_lookup(struct mlx4_dev *dev, u32 srqn)
 {
 	struct mlx4_srq_table *srq_table = &mlx4_priv(dev)->srq_table;
 	struct mlx4_srq *srq;
-	unsigned long flags;
 
-	spin_lock_irqsave(&srq_table->lock, flags);
+	rcu_read_lock();
 	srq = radix_tree_lookup(&srq_table->tree,
 				srqn & (dev->caps.num_srqs - 1));
-	spin_unlock_irqrestore(&srq_table->lock, flags);
+	rcu_read_unlock();
 
 	return srq;
 }
-- 
1.8.3.1
