From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V2 5/6] net/mlx4_en: Fix a race when closing TX queue
Date: Thu, 24 Jan 2013 13:54:18 +0200
Message-ID: <1359028459-30961-6-git-send-email-amirv@mellanox.com>
References: <1359028459-30961-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Eric Dumazet <edumazet@google.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog117.obsmtp.com ([207.126.144.143]:58287 "HELO
	eu1sys200aog117.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753440Ab3AXLyj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2013 06:54:39 -0500
In-Reply-To: <1359028459-30961-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is a possible race where the TX completion handler can clean the
entire TX queue between the decision that the queue is full and actually
closing it. To avoid this situation, check again if the queue is really
full, if not, reopen the transmit and continue with sending the packet.

CC: Eric Dumazet <edumazet@google.com>

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.com>
Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_tx.c |   16 +++++++++++++++-
 1 files changed, 15 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index 16af338..1e793e3 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -588,7 +588,21 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 		netif_tx_stop_queue(ring->tx_queue);
 		priv->port_stats.queue_stopped++;
 
-		return NETDEV_TX_BUSY;
+		/* If queue was emptied after the if, and before the
+		 * stop_queue - need to wake the queue, or else it will remain
+		 * stopped forever.
+		 * Need a memory barrier to make sure ring->cons was not
+		 * updated before queue was stopped. 
+		 */
+		wmb();
+
+		if (unlikely(((int)(ring->prod - ring->cons)) <=
+			     ring->size - HEADROOM - MAX_DESC_TXBBS)) {
+			netif_tx_wake_queue(ring->tx_queue);
+			priv->port_stats.wake_queue++;
+		} else {
+			return NETDEV_TX_BUSY;
+		}
 	}
 
 	/* Track current inflight packets for performance analysis */
-- 
1.7.8.2
