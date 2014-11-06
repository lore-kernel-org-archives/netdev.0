From: Eli Cohen <eli@dev.mellanox.co.il>
Subject: [PATCH net 1/2] net/mlx5_core: Fix race in create EQ
Date: Thu,  6 Nov 2014 12:51:21 +0200
Message-ID: <1415271082-7644-2-git-send-email-eli@mellanox.com>
References: <1415271082-7644-1-git-send-email-eli@mellanox.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
	ogerlitz@mellanox.com, Eli Cohen <eli@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:33460 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751328AbaKFKve (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2014 05:51:34 -0500
Received: by mail-wi0-f173.google.com with SMTP id n3so1074193wiv.0
        for <netdev@vger.kernel.org>; Thu, 06 Nov 2014 02:51:32 -0800 (PST)
In-Reply-To: <1415271082-7644-1-git-send-email-eli@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After the EQ is created, it can possibly generate interrupts and the interrupt
handler is referencing eq->dev. It is therefore required to set eq->dev before
calling request_irq() so if an event is generated before request_irq() returns,
we will have a valid eq->dev field.

Signed-off-by: Eli Cohen <eli@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/eq.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eq.c b/drivers/net/ethernet/mellanox/mlx5/core/eq.c
index a278238a2db6..ad2c96a02a53 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eq.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eq.c
@@ -374,15 +374,14 @@ int mlx5_create_map_eq(struct mlx5_core_dev *dev, struct mlx5_eq *eq, u8 vecidx,
 	snprintf(eq->name, MLX5_MAX_EQ_NAME, "%s@pci:%s",
 		 name, pci_name(dev->pdev));
 	eq->eqn = out.eq_number;
+	eq->irqn = vecidx;
+	eq->dev = dev;
+	eq->doorbell = uar->map + MLX5_EQ_DOORBEL_OFFSET;
 	err = request_irq(table->msix_arr[vecidx].vector, mlx5_msix_handler, 0,
 			  eq->name, eq);
 	if (err)
 		goto err_eq;
 
-	eq->irqn = vecidx;
-	eq->dev = dev;
-	eq->doorbell = uar->map + MLX5_EQ_DOORBEL_OFFSET;
-
 	err = mlx5_debug_eq_add(dev, eq);
 	if (err)
 		goto err_irq;
-- 
2.1.2
