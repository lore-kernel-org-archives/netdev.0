From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 11/14] mlx4_en: reconfiguring mac address.
Date: Tue, 24 Aug 2010 16:46:38 +0300
Message-ID: <4C73CD3E.9040503@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>,
	<eugenia@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:50170 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755250Ab0HXNql (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Aug 2010 09:46:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When Mac address is removed from one port of the CX2 device, the other device
should reconfigure its Mac.
This fixes an issue with failover, when both ports have the same Mac address,
and one of the ports, is closed, the second one stops receiving traffic.
(bugzilla #1965 at bugs.openfabrics.org)

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/en_netdev.c |    6 ++++++
 drivers/net/mlx4/mlx4_en.h   |    1 +
 2 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/net/mlx4/en_netdev.c b/drivers/net/mlx4/en_netdev.c
index 7a1e697..2f8d705 100644
--- a/drivers/net/mlx4/en_netdev.c
+++ b/drivers/net/mlx4/en_netdev.c
@@ -513,6 +513,10 @@ static void mlx4_en_do_get_stats(struct work_struct *work)
 
 		queue_delayed_work(mdev->workqueue, &priv->stats_task, STATS_DELAY);
 	}
+	if (mdev->mac_removed[MLX4_MAX_PORTS + 1 - priv->port]) {
+		queue_work(mdev->workqueue, &priv->mac_task);
+		mdev->mac_removed[MLX4_MAX_PORTS + 1 - priv->port] = 0;
+	}
 	mutex_unlock(&mdev->state_lock);
 }
 
@@ -653,6 +657,7 @@ int mlx4_en_start_port(struct net_device *dev)
 		en_err(priv, "Failed setting port mac\n");
 		goto tx_err;
 	}
+	mdev->mac_removed[priv->port] = 0;
 
 	/* Init port */
 	en_dbg(HW, priv, "Initializing port\n");
@@ -709,6 +714,7 @@ void mlx4_en_stop_port(struct net_device *dev)
 
 	/* Unregister Mac address for the port */
 	mlx4_unregister_mac(mdev->dev, priv->port, priv->mac_index);
+	mdev->mac_removed[priv->port] = 1;
 
 	/* Free TX Rings */
 	for (i = 0; i < priv->tx_ring_num; i++) {
diff --git a/drivers/net/mlx4/mlx4_en.h b/drivers/net/mlx4/mlx4_en.h
index bd39d81..97c30ff 100644
--- a/drivers/net/mlx4/mlx4_en.h
+++ b/drivers/net/mlx4/mlx4_en.h
@@ -342,6 +342,7 @@ struct mlx4_en_dev {
 	struct mlx4_mr		mr;
 	u32                     priv_pdn;
 	spinlock_t              uar_lock;
+	u8			mac_removed[MLX4_MAX_PORTS + 1];
 };
 
 
-- 
1.6.1.3


