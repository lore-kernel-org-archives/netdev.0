From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net V2 13/14] net/mlx5e: Schedule overflow check work to mlx5e workqueue
Date: Thu, 27 Jul 2017 16:56:16 +0300
Message-ID: <20170727135617.18559-14-saeedm@mellanox.com>
References: <20170727135617.18559-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Eugenia Emantayev <eugenia@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:40250 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751767AbdG0N5S (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Jul 2017 09:57:18 -0400
In-Reply-To: <20170727135617.18559-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugenia Emantayev <eugenia@mellanox.com>

This is done in order to ensure that work will not run after the cleanup.

Fixes: ef9814deafd0 ('net/mlx5e: Add HW timestamping (TS) support')
Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_clock.c | 11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_clock.c b/drivers/net/ethernet/mellanox/mlx5/core/en_clock.c
index cde8e8e772ec..84dd63e74041 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_clock.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_clock.c
@@ -114,13 +114,14 @@ static void mlx5e_timestamp_overflow(struct work_struct *work)
 	struct delayed_work *dwork = to_delayed_work(work);
 	struct mlx5e_tstamp *tstamp = container_of(dwork, struct mlx5e_tstamp,
 						   overflow_work);
+	struct mlx5e_priv *priv = container_of(tstamp, struct mlx5e_priv, tstamp);
 	unsigned long flags;
 
 	write_lock_irqsave(&tstamp->lock, flags);
 	timecounter_read(&tstamp->clock);
 	write_unlock_irqrestore(&tstamp->lock, flags);
-	schedule_delayed_work(&tstamp->overflow_work,
-			      msecs_to_jiffies(tstamp->overflow_period * 1000));
+	queue_delayed_work(priv->wq, &tstamp->overflow_work,
+			   msecs_to_jiffies(tstamp->overflow_period * 1000));
 }
 
 int mlx5e_hwstamp_set(struct mlx5e_priv *priv, struct ifreq *ifr)
@@ -577,7 +578,7 @@ void mlx5e_timestamp_init(struct mlx5e_priv *priv)
 	INIT_WORK(&tstamp->pps_info.out_work, mlx5e_pps_out);
 	INIT_DELAYED_WORK(&tstamp->overflow_work, mlx5e_timestamp_overflow);
 	if (tstamp->overflow_period)
-		schedule_delayed_work(&tstamp->overflow_work, 0);
+		queue_delayed_work(priv->wq, &tstamp->overflow_work, 0);
 	else
 		mlx5_core_warn(priv->mdev, "invalid overflow period, overflow_work is not scheduled\n");
 
@@ -613,8 +614,6 @@ void mlx5e_timestamp_cleanup(struct mlx5e_priv *priv)
 	}
 
 	cancel_work_sync(&tstamp->pps_info.out_work);
-
-	kfree(tstamp->ptp_info.pin_config);
-
 	cancel_delayed_work_sync(&tstamp->overflow_work);
+	kfree(tstamp->ptp_info.pin_config);
 }
-- 
2.13.0
