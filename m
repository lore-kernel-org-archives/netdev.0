From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 6/6] net/mlx4_en: Disable RFS when running in SRIOV mode
Date: Thu,  7 Mar 2013 15:46:57 +0200
Message-ID: <1362664017-30275-7-git-send-email-ogerlitz@mellanox.com>
References: <1362664017-30275-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com,
	Kleber Sacilotto de Souza <klebers@linux.vnet.ibm.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog112.obsmtp.com ([207.126.144.133]:51667 "EHLO
	eu1sys200aog112.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753014Ab3CGNsU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Mar 2013 08:48:20 -0500
In-Reply-To: <1362664017-30275-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>

Commit 37706996 "mlx4_en: fix allocation of CPU affinity reverse-map" fixed
a bug when mlx4_dev->caps.comp_pool is larger from the device rx rings, but
introduced a regression.

When the mlx4_core is activating its "legacy mode" (e.g when running in SRIOV
mode) w.r.t to EQs/IRQs usage, comp_pool becomes zero and we're crashing on
divide by zero alloc_cpu_rmap.

Fix that by enabling RFS only when running in non-legacy mode.

Reported-by: Yan Burman <yanb@mellanox.com>
Cc: Kleber Sacilotto de Souza <klebers@linux.vnet.ibm.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---

This regression was introduced in 3.9-rc1 but actually present also in the 
3.8 -stable series. It turns out that a slightly different fix is needed there and 
we will generate and submit it there.

 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 7fd0936..995d4b6 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -1833,9 +1833,11 @@ int mlx4_en_alloc_resources(struct mlx4_en_priv *priv)
 	}
 
 #ifdef CONFIG_RFS_ACCEL
-	priv->dev->rx_cpu_rmap = alloc_irq_cpu_rmap(priv->mdev->dev->caps.comp_pool);
-	if (!priv->dev->rx_cpu_rmap)
-		goto err;
+	if (priv->mdev->dev->caps.comp_pool) {
+		priv->dev->rx_cpu_rmap = alloc_irq_cpu_rmap(priv->mdev->dev->caps.comp_pool);
+		if (!priv->dev->rx_cpu_rmap)
+			goto err;
+	}
 #endif
 
 	return 0;
-- 
1.7.1
