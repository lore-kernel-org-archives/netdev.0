From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: [PATCH net-next 1/9] qlge: Fix TX queue stoppage due to full condition.
Date: Tue, 10 Jul 2012 20:57:31 -0400
Message-ID: <1341968259-18931-2-git-send-email-jitendra.kalsaria@qlogic.com>
References: <1341968259-18931-1-git-send-email-jitendra.kalsaria@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com,
	Dept_NX_Linux_NIC_Driver@qlogic.com,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:16177 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1753451Ab2GKBOh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jul 2012 21:14:37 -0400
In-Reply-To: <1341968259-18931-1-git-send-email-jitendra.kalsaria@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>

TX queue was being stopped at beginning of send path instead
of at the end when last descriptor is used.

Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlge/qlge_main.c |   12 +++++++++++-
 1 files changed, 11 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_main.c b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
index 09d8d33..ce2d37f 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge_main.c
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
@@ -2558,7 +2558,7 @@ static netdev_tx_t qlge_send(struct sk_buff *skb, struct net_device *ndev)
 
 	if (unlikely(atomic_read(&tx_ring->tx_count) < 2)) {
 		netif_info(qdev, tx_queued, qdev->ndev,
-			   "%s: shutting down tx queue %d du to lack of resources.\n",
+			   "%s: BUG! shutting down tx queue %d due to lack of resources.\n",
 			   __func__, tx_ring_idx);
 		netif_stop_subqueue(ndev, tx_ring->wq_id);
 		atomic_inc(&tx_ring->queue_stopped);
@@ -2612,6 +2612,16 @@ static netdev_tx_t qlge_send(struct sk_buff *skb, struct net_device *ndev)
 		     tx_ring->prod_idx, skb->len);
 
 	atomic_dec(&tx_ring->tx_count);
+
+	if (unlikely(atomic_read(&tx_ring->tx_count) < 2)) {
+		netif_stop_subqueue(ndev, tx_ring->wq_id);
+		if ((atomic_read(&tx_ring->tx_count) > (tx_ring->wq_len / 4)))
+			/*
+			 * The queue got stopped because the tx_ring was full.
+			 * Wake it up, because it's now at least 25% empty.
+			 */
+			netif_wake_subqueue(qdev->ndev, tx_ring->wq_id);
+	}
 	return NETDEV_TX_OK;
 }
 
-- 
1.7.1
