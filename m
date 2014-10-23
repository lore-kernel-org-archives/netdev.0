From: Eli Cohen <eli@dev.mellanox.co.il>
Subject: [PATCH for-net 1/2] net/mlx5_core: Call synchronize_irq() before freeing EQ buffer
Date: Thu, 23 Oct 2014 15:57:26 +0300
Message-ID: <1414069047-30865-2-git-send-email-eli@mellanox.com>
References: <1414069047-30865-1-git-send-email-eli@mellanox.com>
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com,
	Eli Cohen <eli@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:38053 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755751AbaJWM5g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Oct 2014 08:57:36 -0400
Received: by mail-wg0-f42.google.com with SMTP id z12so1304805wgg.1
        for <netdev@vger.kernel.org>; Thu, 23 Oct 2014 05:57:34 -0700 (PDT)
In-Reply-To: <1414069047-30865-1-git-send-email-eli@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After destroying the EQ, the object responsible for generating interrupts, call
synchronize_irq() to ensure that any handler routines running on other CPU
cores finish execution. Only then free the EQ buffer. This patch solves a very
rare case when we get panic on driver unload.
The same thing is done when we destroy a CQ which is one of the sources
generating interrupts. In the case of CQ we want to avoid completion handlers
on a CQ that was destroyed. In the case we do the same to avoid receiving
asynchronous events after the EQ has been destroyed and its buffers freed.

Signed-off-by: Eli Cohen <eli@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/eq.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eq.c b/drivers/net/ethernet/mellanox/mlx5/core/eq.c
index ed53291468f3..a278238a2db6 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eq.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eq.c
@@ -420,6 +420,7 @@ int mlx5_destroy_unmap_eq(struct mlx5_core_dev *dev, struct mlx5_eq *eq)
 	if (err)
 		mlx5_core_warn(dev, "failed to destroy a previously created eq: eqn %d\n",
 			       eq->eqn);
+	synchronize_irq(table->msix_arr[eq->irqn].vector);
 	mlx5_buf_free(dev, &eq->buf);
 
 	return err;
-- 
2.1.2
