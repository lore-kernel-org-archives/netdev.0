From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net/mlx4_en: remove NETDEV_TX_BUSY
Date: Mon, 06 Oct 2014 09:30:35 -0700
Message-ID: <1412613035.11091.72.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1412576163-7224-1-git-send-email-amirv@mellanox.com>
	 <1412599904.11091.66.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Ido Shamay <idos@mellanox.com>
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:36201 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751289AbaJFQah (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 12:30:37 -0400
Received: by mail-pa0-f50.google.com with SMTP id kx10so5523540pab.37
        for <netdev@vger.kernel.org>; Mon, 06 Oct 2014 09:30:37 -0700 (PDT)
In-Reply-To: <1412599904.11091.66.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Drivers should avoid NETDEV_TX_BUSY as much as possible.

They should stop the tx queue before qdisc even tries to push another
packet, to avoid requeues.

For a driver supporting skb->xmit_more, this is likely to be a prereq
anyway, otherwise we could have a tx deadlock : We need to force a
doorbell if TX ring is full.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_tx.c |   48 +++++++++----------
 1 file changed, 24 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index 92a7cf46d9af9260d601a0d65ec5bba4..44004e331e4e760f18cfa69ef99a2b2b 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -706,6 +706,7 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 	void *fragptr = NULL;
 	bool bounce = false;
 	bool send_doorbell;
+	bool stop_queue;
 	bool inline_ok;
 	u32 ring_cons;
 
@@ -735,30 +736,6 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (vlan_tx_tag_present(skb))
 		vlan_tag = vlan_tx_tag_get(skb);
 
-	/* Check available TXBBs And 2K spare for prefetch */
-	if (unlikely(((int)(ring->prod - ring_cons)) >
-		     ring->size - HEADROOM - MAX_DESC_TXBBS)) {
-		/* every full Tx ring stops queue */
-		netif_tx_stop_queue(ring->tx_queue);
-		ring->queue_stopped++;
-
-		/* If queue was emptied after the if, and before the
-		 * stop_queue - need to wake the queue, or else it will remain
-		 * stopped forever.
-		 * Need a memory barrier to make sure ring->cons was not
-		 * updated before queue was stopped.
-		 */
-		wmb();
-
-		ring_cons = ACCESS_ONCE(ring->cons);
-		if (unlikely(((int)(ring->prod - ring_cons)) <=
-			     ring->size - HEADROOM - MAX_DESC_TXBBS)) {
-			netif_tx_wake_queue(ring->tx_queue);
-			ring->wake_queue++;
-		} else {
-			return NETDEV_TX_BUSY;
-		}
-	}
 
 	prefetchw(&ring->tx_queue->dql);
 
@@ -929,6 +906,13 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	skb_tx_timestamp(skb);
 
+	/* Check available TXBBs And 2K spare for prefetch */
+	stop_queue = (int)(ring->prod - ring_cons) >
+		      ring->size - HEADROOM - MAX_DESC_TXBBS;
+	if (unlikely(stop_queue)) {
+		netif_tx_stop_queue(ring->tx_queue);
+		ring->queue_stopped++;
+	}
 	send_doorbell = !skb->xmit_more || netif_xmit_stopped(ring->tx_queue);
 
 	real_size = (real_size / 16) & 0x3f;
@@ -973,6 +957,22 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 		}
 	}
 
+	if (unlikely(stop_queue)) {
+		/* If queue was emptied after the if (stop_queue) , and before
+		 * the netif_tx_stop_queue() - need to wake the queue,
+		 * or else it will remain stopped forever.
+		 * Need a memory barrier to make sure ring->cons was not
+		 * updated before queue was stopped.
+		 */
+		smp_rmb();
+
+		ring_cons = ACCESS_ONCE(ring->cons);
+		if (unlikely(((int)(ring->prod - ring_cons)) <=
+			     ring->size - HEADROOM - MAX_DESC_TXBBS)) {
+			netif_tx_wake_queue(ring->tx_queue);
+			ring->wake_queue++;
+		}
+	}
 	return NETDEV_TX_OK;
 
 tx_drop_unmap:
