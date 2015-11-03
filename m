From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V1 3/7] net/mlx5_core: Use the the real irqn in eq->irqn
Date: Tue,  3 Nov 2015 08:07:20 +0200
Message-ID: <1446530844-14077-4-git-send-email-ogerlitz@mellanox.com>
References: <1446530844-14077-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:38574 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752980AbbKCGIJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Nov 2015 01:08:09 -0500
In-Reply-To: <1446530844-14077-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Achiad Shochat <achiad@mellanox.com>

Instead of storing the msix array index in eq->irqn (vecidx),
store the real irq number.

Signed-off-by: Achiad Shochat <achiad@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/eq.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eq.c b/drivers/net/ethernet/mellanox/mlx5/core/eq.c
index 1f01fe8..713ead5 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eq.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eq.c
@@ -382,10 +382,10 @@ int mlx5_create_map_eq(struct mlx5_core_dev *dev, struct mlx5_eq *eq, u8 vecidx,
 		 name, pci_name(dev->pdev));
 
 	eq->eqn = out.eq_number;
-	eq->irqn = vecidx;
+	eq->irqn = priv->msix_arr[vecidx].vector;
 	eq->dev = dev;
 	eq->doorbell = uar->map + MLX5_EQ_DOORBEL_OFFSET;
-	err = request_irq(priv->msix_arr[vecidx].vector, mlx5_msix_handler, 0,
+	err = request_irq(eq->irqn, mlx5_msix_handler, 0,
 			  priv->irq_info[vecidx].name, eq);
 	if (err)
 		goto err_eq;
@@ -421,12 +421,12 @@ int mlx5_destroy_unmap_eq(struct mlx5_core_dev *dev, struct mlx5_eq *eq)
 	int err;
 
 	mlx5_debug_eq_remove(dev, eq);
-	free_irq(dev->priv.msix_arr[eq->irqn].vector, eq);
+	free_irq(eq->irqn, eq);
 	err = mlx5_cmd_destroy_eq(dev, eq->eqn);
 	if (err)
 		mlx5_core_warn(dev, "failed to destroy a previously created eq: eqn %d\n",
 			       eq->eqn);
-	synchronize_irq(dev->priv.msix_arr[eq->irqn].vector);
+	synchronize_irq(eq->irqn);
 	mlx5_buf_free(dev, &eq->buf);
 
 	return err;
-- 
2.3.7
