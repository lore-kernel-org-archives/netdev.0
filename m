From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 6/7] net/mlx4_en: Fix a race when closing TX queue
Date: Wed, 16 Jan 2013 17:42:14 +0200
Message-ID: <1358350935-3281-7-git-send-email-amirv@mellanox.com>
References: <1358350935-3281-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog105.obsmtp.com ([207.126.144.119]:43597 "HELO
	eu1sys200aog105.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754064Ab3APPmp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2013 10:42:45 -0500
In-Reply-To: <1358350935-3281-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is a possible race where the TX completion handler can clean the
entire TX queue between the decision that the queue is full and actually
closing it. To avoid this situation, check again if the queue is really
full, if not, reopen the transmit and continue with sending the packet.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.com>
Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_tx.c |    9 ++++++++-
 1 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index 2b799f4..1d17f5f 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -592,7 +592,14 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 		netif_tx_stop_queue(ring->tx_queue);
 		priv->port_stats.queue_stopped++;
 
-		return NETDEV_TX_BUSY;
+		/* Check again whether the queue was cleaned */
+		if (unlikely(((int)(ring->prod - ring->cons)) <=
+				ring->size - HEADROOM - MAX_DESC_TXBBS)) {
+			netif_tx_wake_queue(ring->tx_queue);
+			priv->port_stats.wake_queue++;
+		} else {
+			return NETDEV_TX_BUSY;
+		}
 	}
 
 	/* Track current inflight packets for performance analysis */
-- 
1.7.8.2
