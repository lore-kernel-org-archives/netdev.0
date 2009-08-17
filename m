From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [RFC net-next PATCH 2/4] qlge: Move TX completion processing to send path.
Date: Mon, 17 Aug 2009 14:08:47 -0700
Message-ID: <1250543329-15123-3-git-send-email-ron.mercer@qlogic.com>
References: <1250543329-15123-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:39434 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757967AbZHQVO2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Aug 2009 17:14:28 -0400
In-Reply-To: <1250543329-15123-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge.h      |    5 ++-
 drivers/net/qlge/qlge_main.c |   59 +++++++++++++++++++++++++++++++++++++-----
 2 files changed, 55 insertions(+), 9 deletions(-)

diff --git a/drivers/net/qlge/qlge.h b/drivers/net/qlge/qlge.h
index e0b9330..975590c 100644
--- a/drivers/net/qlge/qlge.h
+++ b/drivers/net/qlge/qlge.h
@@ -1205,6 +1205,7 @@ struct bq_desc {
 };
 
 #define QL_TXQ_IDX(qdev, skb) (smp_processor_id()%(qdev->tx_ring_count))
+#define TXQ_CLEAN_TIME (HZ/4)
 
 struct tx_ring {
 	/*
@@ -1224,11 +1225,11 @@ struct tx_ring {
 	u8 wq_id;		/* queue id for this entry */
 	u8 reserved1[3];
 	struct tx_ring_desc *q;	/* descriptor list for the queue */
-	spinlock_t lock;
 	atomic_t tx_count;	/* counts down for every outstanding IO */
 	atomic_t queue_stopped;	/* Turns queue off when full. */
-	struct delayed_work tx_work;
+	struct netdev_queue *txq;
 	struct ql_adapter *qdev;
+	struct timer_list txq_clean_timer;
 };
 
 /*
diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index c551ac3..d9b22da 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -1682,7 +1682,7 @@ static void ql_process_mac_tx_intr(struct ql_adapter *qdev,
 	ql_unmap_send(qdev, tx_ring_desc, tx_ring_desc->map_cnt);
 	qdev->stats.tx_bytes += (tx_ring_desc->skb)->len;
 	qdev->stats.tx_packets++;
-	dev_kfree_skb_any(tx_ring_desc->skb);
+	dev_kfree_skb(tx_ring_desc->skb);
 	tx_ring_desc->skb = NULL;
 
 	if (unlikely(mac_rsp->flags1 & (OB_MAC_IOCB_RSP_E |
@@ -1797,22 +1797,40 @@ static int ql_clean_outbound_rx_ring(struct rx_ring *rx_ring)
 		ql_update_cq(rx_ring);
 		prod = ql_read_sh_reg(rx_ring->prod_idx_sh_reg);
 	}
+	if (!count)
+		return count;
 	ql_write_cq_idx(rx_ring);
 	tx_ring = &qdev->tx_ring[net_rsp->txq_idx];
-	if (__netif_subqueue_stopped(qdev->ndev, tx_ring->wq_id) &&
-					net_rsp != NULL) {
+	if (netif_tx_queue_stopped(tx_ring->txq)) {
 		if (atomic_read(&tx_ring->queue_stopped) &&
 		    (atomic_read(&tx_ring->tx_count) > (tx_ring->wq_len / 4)))
 			/*
 			 * The queue got stopped because the tx_ring was full.
 			 * Wake it up, because it's now at least 25% empty.
 			 */
-			netif_wake_subqueue(qdev->ndev, tx_ring->wq_id);
+			if (netif_running(qdev->ndev)) {
+				netif_tx_wake_queue(tx_ring->txq);
+				atomic_dec(&tx_ring->queue_stopped);
+			}
 	}
 
 	return count;
 }
 
+static void ql_txq_clean_timer(unsigned long data)
+{
+	struct tx_ring *tx_ring = (struct tx_ring *)data;
+	struct ql_adapter *qdev = tx_ring->qdev;
+	struct rx_ring *rx_ring = &qdev->rx_ring[tx_ring->cq_id];
+
+	if (__netif_tx_trylock(tx_ring->txq)) {
+		ql_clean_outbound_rx_ring(rx_ring);
+		__netif_tx_unlock(tx_ring->txq);
+	}
+	mod_timer(&tx_ring->txq_clean_timer, jiffies + TXQ_CLEAN_TIME);
+
+}
+
 static int ql_clean_inbound_rx_ring(struct rx_ring *rx_ring, int budget)
 {
 	struct ql_adapter *qdev = rx_ring->qdev;
@@ -2005,7 +2023,7 @@ static irqreturn_t qlge_isr(int irq, void *dev_id)
 			QPRINTK(qdev, INTR, INFO,
 				"Waking handler for rx_ring[%d].\n", i);
 			if (rx_ring->type == TX_Q)
-				ql_clean_outbound_rx_ring(rx_ring);
+				continue;
 			else {
 				ql_disable_completion_interrupt(qdev,
 							intr_context->
@@ -2107,11 +2125,17 @@ static int qlge_send(struct sk_buff *skb, struct net_device *ndev)
 	if (skb_padto(skb, ETH_ZLEN))
 		return NETDEV_TX_OK;
 
+	/* If there is at least 16 entries to clean then
+	 * go do it.
+	 */
+	if (tx_ring->wq_len - atomic_read(&tx_ring->tx_count) > 16)
+		ql_clean_outbound_rx_ring(&qdev->rx_ring[tx_ring->cq_id]);
+
 	if (unlikely(atomic_read(&tx_ring->tx_count) < 2)) {
 		QPRINTK(qdev, TX_QUEUED, INFO,
 			"%s: shutting down tx queue %d du to lack of resources.\n",
 			__func__, tx_ring_idx);
-		netif_stop_subqueue(ndev, tx_ring->wq_id);
+		netif_tx_stop_queue(tx_ring->txq);
 		atomic_inc(&tx_ring->queue_stopped);
 		return NETDEV_TX_BUSY;
 	}
@@ -2128,6 +2152,8 @@ static int qlge_send(struct sk_buff *skb, struct net_device *ndev)
 	tx_ring_desc->skb = skb;
 
 	mac_iocb_ptr->frame_len = cpu_to_le16((u16) skb->len);
+	/* Disable completion interrupt for this packet. */
+	mac_iocb_ptr->flags1 |= OB_MAC_IOCB_REQ_I;
 
 	if (qdev->vlgrp && vlan_tx_tag_present(skb)) {
 		QPRINTK(qdev, TX_QUEUED, DEBUG, "Adding a vlan tag %d.\n",
@@ -2153,13 +2179,20 @@ static int qlge_send(struct sk_buff *skb, struct net_device *ndev)
 	tx_ring->prod_idx++;
 	if (tx_ring->prod_idx == tx_ring->wq_len)
 		tx_ring->prod_idx = 0;
+	atomic_dec(&tx_ring->tx_count);
 	wmb();
 
+	/* Run the destructor before telling the DMA engine about
+	 * the packet to make sure it doesn't complete and get
+	 * freed prematurely.
+	 */
+	if (likely(!skb_shared(skb)))
+		skb_orphan(skb);
+
 	ql_write_db_reg(tx_ring->prod_idx, tx_ring->prod_idx_db_reg);
 	QPRINTK(qdev, TX_QUEUED, DEBUG, "tx queued, slot %d, len %d\n",
 		tx_ring->prod_idx, skb->len);
 
-	atomic_dec(&tx_ring->tx_count);
 	return NETDEV_TX_OK;
 }
 
@@ -2727,6 +2760,8 @@ static int ql_start_tx_ring(struct ql_adapter *qdev, struct tx_ring *tx_ring)
 	 */
 	tx_ring->cnsmr_idx_sh_reg = shadow_reg;
 	tx_ring->cnsmr_idx_sh_reg_dma = shadow_reg_dma;
+	*tx_ring->cnsmr_idx_sh_reg = 0;
+	tx_ring->txq = netdev_get_tx_queue(qdev->ndev, tx_ring->wq_id);
 
 	wqicb->len = cpu_to_le16(tx_ring->wq_len | Q_LEN_V | Q_LEN_CPP_CONT);
 	wqicb->flags = cpu_to_le16(Q_FLAGS_LC |
@@ -2746,6 +2781,7 @@ static int ql_start_tx_ring(struct ql_adapter *qdev, struct tx_ring *tx_ring)
 		return err;
 	}
 	QPRINTK(qdev, IFUP, DEBUG, "Successfully loaded WQICB.\n");
+	mod_timer(&tx_ring->txq_clean_timer, jiffies + TXQ_CLEAN_TIME);
 	return err;
 }
 
@@ -3299,6 +3335,12 @@ static int ql_adapter_down(struct ql_adapter *qdev)
 		}
 	}
 
+	/* Delete the timers used for cleaning up
+	 * TX completions.
+	 */
+	for (i = 0; i < qdev->tx_ring_count; i++)
+		del_timer_sync(&qdev->tx_ring[i].txq_clean_timer);
+
 	clear_bit(QL_ADAPTER_UP, &qdev->flags);
 
 	ql_disable_interrupts(qdev);
@@ -3438,6 +3480,9 @@ static int ql_configure_rings(struct ql_adapter *qdev)
 		 * immediately after the default Q ID, which is zero.
 		 */
 		tx_ring->cq_id = i + 1;
+		init_timer(&tx_ring->txq_clean_timer);
+		tx_ring->txq_clean_timer.data = (unsigned long)tx_ring;
+		tx_ring->txq_clean_timer.function = ql_txq_clean_timer;
 	}
 
 	for (i = 0; i < qdev->rx_ring_count; i++) {
-- 
1.6.0.2

