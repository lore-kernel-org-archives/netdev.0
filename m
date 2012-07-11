From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: [PATCH net-next 2/9] qlge: Cleanup atomic queue threshold check.
Date: Tue, 10 Jul 2012 20:57:32 -0400
Message-ID: <1341968259-18931-3-git-send-email-jitendra.kalsaria@qlogic.com>
References: <1341968259-18931-1-git-send-email-jitendra.kalsaria@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com,
	Dept_NX_Linux_NIC_Driver@qlogic.com,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:25473 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1753482Ab2GKBOi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jul 2012 21:14:38 -0400
In-Reply-To: <1341968259-18931-1-git-send-email-jitendra.kalsaria@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>

Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlge/qlge.h      |    1 -
 drivers/net/ethernet/qlogic/qlge/qlge_main.c |    5 +----
 2 files changed, 1 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlge/qlge.h b/drivers/net/ethernet/qlogic/qlge/qlge.h
index 5a639df..6e7050c 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge.h
+++ b/drivers/net/ethernet/qlogic/qlge/qlge.h
@@ -1397,7 +1397,6 @@ struct tx_ring {
 	struct tx_ring_desc *q;	/* descriptor list for the queue */
 	spinlock_t lock;
 	atomic_t tx_count;	/* counts down for every outstanding IO */
-	atomic_t queue_stopped;	/* Turns queue off when full. */
 	struct delayed_work tx_work;
 	struct ql_adapter *qdev;
 	u64 tx_packets;
diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_main.c b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
index ce2d37f..ee3457e 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge_main.c
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
@@ -2173,8 +2173,7 @@ static int ql_clean_outbound_rx_ring(struct rx_ring *rx_ring)
 	ql_write_cq_idx(rx_ring);
 	tx_ring = &qdev->tx_ring[net_rsp->txq_idx];
 	if (__netif_subqueue_stopped(qdev->ndev, tx_ring->wq_id)) {
-		if (atomic_read(&tx_ring->queue_stopped) &&
-		    (atomic_read(&tx_ring->tx_count) > (tx_ring->wq_len / 4)))
+		if ((atomic_read(&tx_ring->tx_count) > (tx_ring->wq_len / 4)))
 			/*
 			 * The queue got stopped because the tx_ring was full.
 			 * Wake it up, because it's now at least 25% empty.
@@ -2561,7 +2560,6 @@ static netdev_tx_t qlge_send(struct sk_buff *skb, struct net_device *ndev)
 			   "%s: BUG! shutting down tx queue %d due to lack of resources.\n",
 			   __func__, tx_ring_idx);
 		netif_stop_subqueue(ndev, tx_ring->wq_id);
-		atomic_inc(&tx_ring->queue_stopped);
 		tx_ring->tx_errors++;
 		return NETDEV_TX_BUSY;
 	}
@@ -2690,7 +2688,6 @@ static void ql_init_tx_ring(struct ql_adapter *qdev, struct tx_ring *tx_ring)
 		tx_ring_desc++;
 	}
 	atomic_set(&tx_ring->tx_count, tx_ring->wq_len);
-	atomic_set(&tx_ring->queue_stopped, 0);
 }
 
 static void ql_free_tx_resources(struct ql_adapter *qdev,
-- 
1.7.1
