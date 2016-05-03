From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next V1 03/12] net/mlx5: E-Switch, Replace vport spin lock with synchronize_irq()
Date: Tue,  3 May 2016 17:13:55 +0300
Message-ID: <1462284844-16926-4-git-send-email-saeedm@mellanox.com>
References: <1462284844-16926-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Mohamad Haj Yahia <mohamad@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:48720 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755452AbcECOO7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 May 2016 10:14:59 -0400
In-Reply-To: <1462284844-16926-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mohamad Haj Yahia <mohamad@mellanox.com>

Vport spin lock can be replaced with synchronize_irq() in the right
place, this will remove the need of locking inside irq context.
Locking in esw_enable_vport is not required since vport events are yet
to be enabled, and at esw_disable_vport it is sufficient to
synchronize_irq() to guarantee no further vport events handlers will be
scheduled.

Signed-off-by: Mohamad Haj Yahia <mohamad@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c | 11 ++---------
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.h |  5 -----
 2 files changed, 2 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
index dd06619..f01903a 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
@@ -713,7 +713,6 @@ static void esw_enable_vport(struct mlx5_eswitch *esw, int vport_num,
 			     int enable_events)
 {
 	struct mlx5_vport *vport = &esw->vports[vport_num];
-	unsigned long flags;
 
 	WARN_ON(vport->enabled);
 
@@ -727,9 +726,7 @@ static void esw_enable_vport(struct mlx5_eswitch *esw, int vport_num,
 	vport->enabled_events = enable_events;
 	esw_vport_change_handler(&vport->vport_change_handler);
 
-	spin_lock_irqsave(&vport->lock, flags);
 	vport->enabled = true;
-	spin_unlock_irqrestore(&vport->lock, flags);
 
 	arm_vport_context_events_cmd(esw->dev, vport_num, enable_events);
 
@@ -761,17 +758,16 @@ static void esw_cleanup_vport(struct mlx5_eswitch *esw, u16 vport_num)
 static void esw_disable_vport(struct mlx5_eswitch *esw, int vport_num)
 {
 	struct mlx5_vport *vport = &esw->vports[vport_num];
-	unsigned long flags;
 
 	if (!vport->enabled)
 		return;
 
 	esw_debug(esw->dev, "Disabling vport(%d)\n", vport_num);
 	/* Mark this vport as disabled to discard new events */
-	spin_lock_irqsave(&vport->lock, flags);
 	vport->enabled = false;
 	vport->enabled_events = 0;
-	spin_unlock_irqrestore(&vport->lock, flags);
+
+	synchronize_irq(mlx5_get_msix_vec(esw->dev, MLX5_EQ_VEC_ASYNC));
 
 	mlx5_modify_vport_admin_state(esw->dev,
 				      MLX5_QUERY_VPORT_STATE_IN_OP_MOD_ESW_VPORT,
@@ -894,7 +890,6 @@ int mlx5_eswitch_init(struct mlx5_core_dev *dev)
 		vport->dev = dev;
 		INIT_WORK(&vport->vport_change_handler,
 			  esw_vport_change_handler);
-		spin_lock_init(&vport->lock);
 	}
 
 	esw->total_vports = total_vports;
@@ -942,10 +937,8 @@ void mlx5_eswitch_vport_event(struct mlx5_eswitch *esw, struct mlx5_eqe *eqe)
 	}
 
 	vport = &esw->vports[vport_num];
-	spin_lock(&vport->lock);
 	if (vport->enabled)
 		queue_work(esw->work_queue, &vport->vport_change_handler);
-	spin_unlock(&vport->lock);
 }
 
 /* Vport Administration */
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
index 3416a42..ba43451 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
@@ -95,11 +95,6 @@ struct mlx5_vport {
 	struct hlist_head       mc_list[MLX5_L2_ADDR_HASH_SIZE];
 	struct work_struct      vport_change_handler;
 
-	/* This spinlock protects access to vport data, between
-	 * "esw_vport_disable" and ongoing interrupt "mlx5_eswitch_vport_event"
-	 * once vport marked as disabled new interrupts are discarded.
-	 */
-	spinlock_t              lock; /* vport events sync */
 	bool                    enabled;
 	u16                     enabled_events;
 };
-- 
2.8.0
