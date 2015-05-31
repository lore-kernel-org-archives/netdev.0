From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V1 4/4] net/mlx4_core: Make sure there are no pending async events when freeing CQ
Date: Sun, 31 May 2015 09:30:18 +0300
Message-ID: <1433053818-30251-5-git-send-email-ogerlitz@mellanox.com>
References: <1433053818-30251-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Matan Barak <matanb@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Ido Shamay <idos@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:35220 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757898AbbEaGbL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 31 May 2015 02:31:11 -0400
In-Reply-To: <1433053818-30251-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matan Barak <matanb@mellanox.com>

When freeing a CQ, we need to make sure there are no
asynchronous events (on the ASYNC EQ) that could
relate to this CQ before freeing it.

This is done by introducing synchronize_irq.

Signed-off-by: Matan Barak <matanb@mellanox.com>
Signed-off-by: Ido Shamay <idos@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/cq.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/cq.c b/drivers/net/ethernet/mellanox/mlx4/cq.c
index 7431cd4..3348e64 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cq.c
@@ -369,6 +369,9 @@ void mlx4_cq_free(struct mlx4_dev *dev, struct mlx4_cq *cq)
 		mlx4_warn(dev, "HW2SW_CQ failed (%d) for CQN %06x\n", err, cq->cqn);
 
 	synchronize_irq(priv->eq_table.eq[MLX4_CQ_TO_EQ_VECTOR(cq->vector)].irq);
+	if (priv->eq_table.eq[MLX4_CQ_TO_EQ_VECTOR(cq->vector)].irq !=
+	    priv->eq_table.eq[MLX4_EQ_ASYNC].irq)
+		synchronize_irq(priv->eq_table.eq[MLX4_EQ_ASYNC].irq);
 
 	spin_lock_irq(&cq_table->lock);
 	radix_tree_delete(&cq_table->tree, cq->cqn);
-- 
1.7.1
