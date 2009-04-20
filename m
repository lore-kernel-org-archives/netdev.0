From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: Re: [PATCH 2/5]mlx4_en: Fix a race at restart task
Date: Mon, 20 Apr 2009 17:26:05 +0300
Message-ID: <49EC85FD.2080009@mellanox.co.il>
References: <49EC859C.700@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tziporet@mellanox.co.il
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:38129 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755294AbZDTO1I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Apr 2009 10:27:08 -0400
In-Reply-To: <49EC859C.700@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The query whether the port is up or not should be done at
the execution of the restart task and not when it is queued.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/en_netdev.c |   19 +++++++++++--------
 1 files changed, 11 insertions(+), 8 deletions(-)

diff --git a/drivers/net/mlx4/en_netdev.c b/drivers/net/mlx4/en_netdev.c
index 303c23d..09fb7cf 100644
--- a/drivers/net/mlx4/en_netdev.c
+++ b/drivers/net/mlx4/en_netdev.c
@@ -348,11 +348,9 @@ static void mlx4_en_tx_timeout(struct net_device *dev)
 	if (netif_msg_timer(priv))
 		mlx4_warn(mdev, "Tx timeout called on port:%d\n", priv->port);

-	if (netif_carrier_ok(dev)) {
-		priv->port_stats.tx_timeout++;
-		mlx4_dbg(DRV, priv, "Scheduling watchdog\n");
-		queue_work(mdev->workqueue, &priv->watchdog_task);
-	}
+	priv->port_stats.tx_timeout++;
+	mlx4_dbg(DRV, priv, "Scheduling watchdog\n");
+	queue_work(mdev->workqueue, &priv->watchdog_task);
 }


@@ -761,9 +759,14 @@ static void mlx4_en_restart(struct work_struct *work)
 	struct net_device *dev = priv->dev;

 	mlx4_dbg(DRV, priv, "Watchdog task called for port %d\n", priv->port);
-	mlx4_en_stop_port(dev);
-	if (mlx4_en_start_port(dev))
-	    mlx4_err(mdev, "Failed restarting port %d\n", priv->port);
+
+	mutex_lock(&mdev->state_lock);
+	if (priv->port_up) {
+		mlx4_en_stop_port(dev);
+		if (mlx4_en_start_port(dev))
+			mlx4_err(mdev, "Failed restarting port %d\n", priv->port);
+	}
+	mutex_unlock(&mdev->state_lock);
 }


-- 
1.5.4


