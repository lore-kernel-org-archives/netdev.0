From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 4/6] mlx4_en: Cancel port_up check in transmit function
Date: Sun, 21 Jun 2009 11:15:52 +0300
Message-ID: <4A3DEC38.9080008@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Tziporet Koren <tziporet@mellanox.co.il>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:51518 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753627AbZFUH0A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 21 Jun 2009 03:26:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When closing the port, we stop all transmit queues under the transmit
lock. It ensures that we will not attempt to transmit new packets after
the physical port was closed.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/en_netdev.c |    4 ++--
 drivers/net/mlx4/en_tx.c     |    7 -------
 2 files changed, 2 insertions(+), 9 deletions(-)

diff --git a/drivers/net/mlx4/en_netdev.c b/drivers/net/mlx4/en_netdev.c
index 20a34cb..03a557c 100644
--- a/drivers/net/mlx4/en_netdev.c
+++ b/drivers/net/mlx4/en_netdev.c
@@ -700,14 +700,14 @@ void mlx4_en_stop_port(struct net_device *dev)
 		en_dbg(DRV, priv, "stop port called while port already down\n");
 		return;
 	}
-	netif_tx_stop_all_queues(dev);
 
 	/* Synchronize with tx routine */
 	netif_tx_lock_bh(dev);
-	priv->port_up = false;
+	netif_tx_stop_all_queues(dev);
 	netif_tx_unlock_bh(dev);
 
 	/* close port*/
+	priv->port_up = false;
 	mlx4_CLOSE_PORT(mdev->dev, priv->port);
 
 	/* Unregister Mac address for the port */
diff --git a/drivers/net/mlx4/en_tx.c b/drivers/net/mlx4/en_tx.c
index e631323..99a6a36 100644
--- a/drivers/net/mlx4/en_tx.c
+++ b/drivers/net/mlx4/en_tx.c
@@ -646,13 +646,6 @@ int mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 		return NETDEV_TX_BUSY;
 	}
 
-	/* Now that we know what Tx ring to use */
-	if (unlikely(!priv->port_up)) {
-		if (netif_msg_tx_err(priv))
-			en_warn(priv, "xmit: port down!\n");
-		goto tx_drop;
-	}
-
 	/* Track current inflight packets for performance analysis */
 	AVG_PERF_COUNTER(priv->pstats.inflight_avg,
 			 (u32) (ring->prod - ring->cons - 1));
-- 
1.6.0

