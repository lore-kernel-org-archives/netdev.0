From: Kleber Sacilotto de Souza <klebers@linux.vnet.ibm.com>
Subject: [PATCH] mlx4_en: fix allocation of CPU affinity reverse-map
Date: Sat, 23 Feb 2013 02:14:52 -0300
Message-ID: <1361596492-10565-1-git-send-email-klebers@linux.vnet.ibm.com>
Cc: Amir Vadai <amirv@mellanox.com>, netdev@vger.kernel.org,
	Kleber Sacilotto de Souza <klebers@linux.vnet.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from bb40dc42.virtua.com.br ([187.64.220.66]:43152 "EHLO
	oc3234564620.ibm.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750957Ab3BWFPG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Feb 2013 00:15:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mlx4_en driver allocates the number of objects for the CPU affinity
reverse-map based on the number of rx rings of the device. However,
mlx4_assign_eq() calls irq_cpu_rmap_add() as many times as IRQ's are
assigned to EQ's, which can be as large as mlx4_dev->caps.comp_pool. If
caps.comp_pool is larger than rx_ring_num we will eventually hit the
BUG_ON() in cpu_rmap_add().

Fix this problem by allocating space for the maximum number of CPU
affinity reverse-map objects we might want to add.

Signed-off-by: Kleber Sacilotto de Souza <klebers@linux.vnet.ibm.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 5944dd6..5385474 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -1829,7 +1829,7 @@ int mlx4_en_alloc_resources(struct mlx4_en_priv *priv)
 	}
 
 #ifdef CONFIG_RFS_ACCEL
-	priv->dev->rx_cpu_rmap = alloc_irq_cpu_rmap(priv->rx_ring_num);
+	priv->dev->rx_cpu_rmap = alloc_irq_cpu_rmap(priv->mdev->dev->caps.comp_pool);
 	if (!priv->dev->rx_cpu_rmap)
 		goto err;
 #endif
-- 
1.7.1
