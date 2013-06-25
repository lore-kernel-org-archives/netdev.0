From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH V1 net-next 05/10] net/mlx4_en: Fix a race between napi poll function and RX ring cleanup
Date: Tue, 25 Jun 2013 12:09:33 +0300
Message-ID: <1372151378-21468-6-git-send-email-ogerlitz@mellanox.com>
References: <1372151378-21468-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Eugenia Emantayev <eugenia@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:40735 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751911Ab3FYJKZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Jun 2013 05:10:25 -0400
In-Reply-To: <1372151378-21468-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugenia Emantayev <eugenia@mellanox.com>

The RX rings were cleaned while there was still possible RX traffic completion
handling.
Change the sequance of events so that the port is closed and the QPs are being
stopped before RX cleanup.

Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index f256a73..f1dcddc 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -1635,6 +1635,9 @@ void mlx4_en_stop_port(struct net_device *dev, int detach)
 		return;
 	}
 
+	/* close port*/
+	mlx4_CLOSE_PORT(mdev->dev, priv->port);
+
 	/* Synchronize with tx routine */
 	netif_tx_lock_bh(dev);
 	if (detach)
@@ -1735,14 +1738,11 @@ void mlx4_en_stop_port(struct net_device *dev, int detach)
 		}
 		local_bh_enable();
 
-		mlx4_en_deactivate_rx_ring(priv, &priv->rx_ring[i]);
 		while (test_bit(NAPI_STATE_SCHED, &cq->napi.state))
 			msleep(1);
+		mlx4_en_deactivate_rx_ring(priv, &priv->rx_ring[i]);
 		mlx4_en_deactivate_cq(priv, cq);
 	}
-
-	/* close port*/
-	mlx4_CLOSE_PORT(mdev->dev, priv->port);
 }
 
 static void mlx4_en_restart(struct work_struct *work)
-- 
1.7.1
