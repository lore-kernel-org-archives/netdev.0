From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 05/12] qlge: Add tx multiqueue support.
Date: Mon,  9 Mar 2009 13:59:21 -0700
Message-ID: <1236632368-22079-6-git-send-email-ron.mercer@qlogic.com>
References: <1236632368-22079-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:18643 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753500AbZCIVDO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2009 17:03:14 -0400
In-Reply-To: <1236632368-22079-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |   31 ++++++++++++++-----------------
 1 files changed, 14 insertions(+), 17 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 339e1da..6da8901 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -1627,14 +1627,12 @@ static void ql_process_mac_tx_intr(struct ql_adapter *qdev,
 /* Fire up a handler to reset the MPI processor. */
 void ql_queue_fw_error(struct ql_adapter *qdev)
 {
-	netif_stop_queue(qdev->ndev);
 	netif_carrier_off(qdev->ndev);
 	queue_delayed_work(qdev->workqueue, &qdev->mpi_reset_work, 0);
 }
 
 void ql_queue_asic_error(struct ql_adapter *qdev)
 {
-	netif_stop_queue(qdev->ndev);
 	netif_carrier_off(qdev->ndev);
 	ql_disable_interrupts(qdev);
 	/* Clear adapter up bit to signal the recovery
@@ -1689,6 +1687,7 @@ static int ql_clean_outbound_rx_ring(struct rx_ring *rx_ring)
 	struct ob_mac_iocb_rsp *net_rsp = NULL;
 	int count = 0;
 
+	struct tx_ring *tx_ring;
 	/* While there are entries in the completion queue. */
 	while (prod != rx_ring->cnsmr_idx) {
 
@@ -1714,15 +1713,16 @@ static int ql_clean_outbound_rx_ring(struct rx_ring *rx_ring)
 		prod = ql_read_sh_reg(rx_ring->prod_idx_sh_reg);
 	}
 	ql_write_cq_idx(rx_ring);
-	if (netif_queue_stopped(qdev->ndev) && net_rsp != NULL) {
-		struct tx_ring *tx_ring = &qdev->tx_ring[net_rsp->txq_idx];
+	tx_ring = &qdev->tx_ring[net_rsp->txq_idx];
+	if (__netif_subqueue_stopped(qdev->ndev, tx_ring->wq_id) &&
+					net_rsp != NULL) {
 		if (atomic_read(&tx_ring->queue_stopped) &&
 		    (atomic_read(&tx_ring->tx_count) > (tx_ring->wq_len / 4)))
 			/*
 			 * The queue got stopped because the tx_ring was full.
 			 * Wake it up, because it's now at least 25% empty.
 			 */
-			netif_wake_queue(qdev->ndev);
+			netif_wake_subqueue(qdev->ndev, tx_ring->wq_id);
 	}
 
 	return count;
@@ -2054,7 +2054,7 @@ static int qlge_send(struct sk_buff *skb, struct net_device *ndev)
 	struct ql_adapter *qdev = netdev_priv(ndev);
 	int tso;
 	struct tx_ring *tx_ring;
-	u32 tx_ring_idx = (u32) QL_TXQ_IDX(qdev, skb);
+	u32 tx_ring_idx = (u32) skb->queue_mapping;
 
 	tx_ring = &qdev->tx_ring[tx_ring_idx];
 
@@ -2062,7 +2062,7 @@ static int qlge_send(struct sk_buff *skb, struct net_device *ndev)
 		QPRINTK(qdev, TX_QUEUED, INFO,
 			"%s: shutting down tx queue %d du to lack of resources.\n",
 			__func__, tx_ring_idx);
-		netif_stop_queue(ndev);
+		netif_stop_subqueue(ndev, tx_ring->wq_id);
 		atomic_inc(&tx_ring->queue_stopped);
 		return NETDEV_TX_BUSY;
 	}
@@ -3192,12 +3192,10 @@ static void ql_display_dev_info(struct net_device *ndev)
 
 static int ql_adapter_down(struct ql_adapter *qdev)
 {
-	struct net_device *ndev = qdev->ndev;
 	int i, status = 0;
 	struct rx_ring *rx_ring;
 
-	netif_stop_queue(ndev);
-	netif_carrier_off(ndev);
+	netif_carrier_off(qdev->ndev);
 
 	/* Don't kill the reset worker thread if we
 	 * are in the process of recovery.
@@ -3261,12 +3259,11 @@ static int ql_adapter_up(struct ql_adapter *qdev)
 	spin_unlock(&qdev->hw_lock);
 	set_bit(QL_ADAPTER_UP, &qdev->flags);
 	ql_alloc_rx_buffers(qdev);
+	if ((ql_read32(qdev, STS) & qdev->port_init))
+		netif_carrier_on(qdev->ndev);
 	ql_enable_interrupts(qdev);
 	ql_enable_all_completion_interrupts(qdev);
-	if ((ql_read32(qdev, STS) & qdev->port_init)) {
-		netif_carrier_on(qdev->ndev);
-		netif_start_queue(qdev->ndev);
-	}
+	netif_tx_start_all_queues(qdev->ndev);
 
 	return 0;
 err_init:
@@ -3354,6 +3351,7 @@ static int ql_configure_rings(struct ql_adapter *qdev)
 	 * completion handler rx_rings.
 	 */
 	qdev->rx_ring_count = qdev->tx_ring_count + qdev->rss_ring_count + 1;
+	netif_set_gso_max_size(qdev->ndev, 65536);
 
 	for (i = 0; i < qdev->tx_ring_count; i++) {
 		tx_ring = &qdev->tx_ring[i];
@@ -3829,7 +3827,8 @@ static int __devinit qlge_probe(struct pci_dev *pdev,
 	static int cards_found = 0;
 	int err = 0;
 
-	ndev = alloc_etherdev(sizeof(struct ql_adapter));
+	ndev = alloc_etherdev_mq(sizeof(struct ql_adapter),
+			min(MAX_CPUS, (int)num_online_cpus()));
 	if (!ndev)
 		return -ENOMEM;
 
@@ -3872,7 +3871,6 @@ static int __devinit qlge_probe(struct pci_dev *pdev,
 		return err;
 	}
 	netif_carrier_off(ndev);
-	netif_stop_queue(ndev);
 	ql_display_dev_info(ndev);
 	cards_found++;
 	return 0;
@@ -3926,7 +3924,6 @@ static pci_ers_result_t qlge_io_slot_reset(struct pci_dev *pdev)
 	pci_set_master(pdev);
 
 	netif_carrier_off(ndev);
-	netif_stop_queue(ndev);
 	ql_adapter_reset(qdev);
 
 	/* Make sure the EEPROM is good */
-- 
1.6.0.2

