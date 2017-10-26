From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net 1/4] net/mlx5: Fix health work queue spin lock to IRQ safe
Date: Thu, 26 Oct 2017 00:59:34 -0700
Message-ID: <20171026075937.26477-2-saeedm@mellanox.com>
References: <20171026075937.26477-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Moshe Shemesh <moshe@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:48934 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751973AbdJZIAu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 04:00:50 -0400
In-Reply-To: <20171026075937.26477-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Moshe Shemesh <moshe@mellanox.com>

spin_lock/unlock of health->wq_lock should be IRQ safe.
It was changed to spin_lock_irqsave since adding commit 0179720d6be2
("net/mlx5: Introduce trigger_health_work function") which uses
spin_lock from asynchronous event (IRQ) context.
Thus, all spin_lock/unlock of health->wq_lock should have been moved
to IRQ safe mode.
However, one occurrence on new code using this lock missed that
change, resulting in possible deadlock:
  kernel: Possible unsafe locking scenario:
  kernel:       CPU0
  kernel:       ----
  kernel:  lock(&(&health->wq_lock)->rlock);
  kernel:  <Interrupt>
  kernel:    lock(&(&health->wq_lock)->rlock);
  kernel: #012 *** DEADLOCK ***

Fixes: 2a0165a034ac ("net/mlx5: Cancel delayed recovery work when unloading the driver")
Signed-off-by: Moshe Shemesh <moshe@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/health.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/health.c b/drivers/net/ethernet/mellanox/mlx5/core/health.c
index 8aea0a065e56..db86e1506c8b 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/health.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/health.c
@@ -356,10 +356,11 @@ void mlx5_drain_health_wq(struct mlx5_core_dev *dev)
 void mlx5_drain_health_recovery(struct mlx5_core_dev *dev)
 {
 	struct mlx5_core_health *health = &dev->priv.health;
+	unsigned long flags;
 
-	spin_lock(&health->wq_lock);
+	spin_lock_irqsave(&health->wq_lock, flags);
 	set_bit(MLX5_DROP_NEW_RECOVERY_WORK, &health->flags);
-	spin_unlock(&health->wq_lock);
+	spin_unlock_irqrestore(&health->wq_lock, flags);
 	cancel_delayed_work_sync(&dev->priv.health.recover_work);
 }
 
-- 
2.14.2
