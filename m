From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 12/13] qla3xxx: Kernic Panic on pSeries under stress conditions
Date: Mon, 26 Feb 2007 11:06:42 -0800
Message-ID: <11725168043574-git-send-email-ron.mercer@qlogic.com>
References: <20070226190450.GA7325@linux-7mw0.qlogic.org>
Cc: ron.mercer@qlogic.com, romieu@fr.zoreil.com,
	benjamin.li@qlogic.com, netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:15768 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030472AbXBZTHs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Feb 2007 14:07:48 -0500
In-Reply-To: <20070226190450.GA7325@linux-7mw0.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Benjamin Li <benjamin.li@qlogic.com>

To reproduce this panic consistently, we run an intensive network
application like 'netperf'. After waiting for a couple of seconds,
you will see a stack trace and a kernel panic where we are calling
pci_unmap_single() in ql_poll().

Changes:
1)  Check the flags on the Response MAC IO Control block to check for
errors
2)  Ensure that if we are on the 4022 we only use one segment
3)  Before, we were reading the memory mapped producer index register
everytime we iterated in the loop when clearing the queue.  We should
only be iterating to a known point, not as the producer index
is being updated.

Signed-off-by: Benjamin Li <benjamin.li@qlogic.com>
Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qla3xxx.c |   64 +++++++++++++++++++++++++++++++++++-------------
 drivers/net/qla3xxx.h |    2 +-
 2 files changed, 47 insertions(+), 19 deletions(-)

diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index 524a9a6..f446232 100755
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -1765,8 +1765,31 @@ static void ql_process_mac_tx_intr(struct ql3_adapter *qdev,
 {
 	struct ql_tx_buf_cb *tx_cb;
 	int i;
+	int retval = 0;
 
+	if(mac_rsp->flags & OB_MAC_IOCB_RSP_S) {
+		printk(KERN_WARNING "Frame short but, frame was padded and sent.\n");
+	}
+	
 	tx_cb = &qdev->tx_buf[mac_rsp->transaction_id];
+
+	/*  Check the transmit response flags for any errors */
+	if(mac_rsp->flags & OB_MAC_IOCB_RSP_S) {
+		printk(KERN_ERR "Frame too short to be legal, frame not sent.\n");
+
+		qdev->stats.tx_errors++;
+		retval = -EIO;
+		goto frame_not_sent;
+	}
+
+	if(tx_cb->seg_count == 0) {
+		printk(KERN_ERR "tx_cb->seg_count == 0: %d\n", mac_rsp->transaction_id);
+
+		qdev->stats.tx_errors++;
+		retval = -EIO;
+		goto invalid_seg_count;
+	}
+
 	pci_unmap_single(qdev->pdev,
 			 pci_unmap_addr(&tx_cb->map[0], mapaddr),
 			 pci_unmap_len(&tx_cb->map[0], maplen),
@@ -1783,8 +1806,12 @@ static void ql_process_mac_tx_intr(struct ql3_adapter *qdev,
 	}
 	qdev->stats.tx_packets++;
 	qdev->stats.tx_bytes += tx_cb->skb->len;
+
+frame_not_sent:
 	dev_kfree_skb_irq(tx_cb->skb);
 	tx_cb->skb = NULL;
+
+invalid_seg_count:
 	atomic_inc(&qdev->tx_count);
 }
 
@@ -1941,8 +1968,10 @@ static int ql_tx_rx_clean(struct ql3_adapter *qdev,
 	unsigned long hw_flags;
 	int work_done = 0;
 
+	u32 rsp_producer_index = le32_to_cpu(*(qdev->prsp_producer_index));
+
 	/* While there are entries in the completion queue. */
-	while ((cpu_to_le32(*(qdev->prsp_producer_index)) !=
+	while ((rsp_producer_index !=
 		qdev->rsp_consumer_index) && (work_done < work_to_do)) {
 
 		net_rsp = qdev->rsp_current;
@@ -2022,13 +2051,6 @@ static int ql_tx_rx_clean(struct ql3_adapter *qdev,
 		}
 
 		spin_unlock_irqrestore(&qdev->hw_lock, hw_flags);
-
-		if (unlikely(netif_queue_stopped(qdev->ndev))) {
-			if (netif_queue_stopped(qdev->ndev) &&
-			    (atomic_read(&qdev->tx_count) > 
-			     (NUM_REQ_Q_ENTRIES / 4)))
-				netif_wake_queue(qdev->ndev);
-		}
 	}
 
 	return *tx_cleaned + *rx_cleaned;
@@ -2049,7 +2071,8 @@ static int ql_poll(struct net_device *ndev, int *budget)
 	*budget -= rx_cleaned;
 	ndev->quota -= rx_cleaned;
 
-	if ((!tx_cleaned && !rx_cleaned) || !netif_running(ndev)) {
+	if( tx_cleaned + rx_cleaned != work_to_do ||
+	    !netif_running(ndev)) {
 quit_polling:
 		netif_rx_complete(ndev);
 
@@ -2111,8 +2134,8 @@ static irqreturn_t ql3xxx_isr(int irq, void *dev_id)
 		queue_delayed_work(qdev->workqueue, &qdev->reset_work, 0);
 		spin_unlock(&qdev->adapter_lock);
 	} else if (value & ISP_IMR_DISABLE_CMPL_INT) {
+		ql_disable_interrupts(qdev);
 		if (likely(netif_rx_schedule_prep(ndev))) {
-			ql_disable_interrupts(qdev);
 			__netif_rx_schedule(ndev);
 		}
 	} else {
@@ -2131,8 +2154,12 @@ static irqreturn_t ql3xxx_isr(int irq, void *dev_id)
  * the next AOL if more frags are coming.  
  * That is why the frags:segment count  ratio is not linear.
  */
-static int ql_get_seg_count(unsigned short frags)
+static int ql_get_seg_count(struct ql3_adapter *qdev,
+			    unsigned short frags)
 {
+	if (qdev->device_id == QL3022_DEVICE_ID)
+		return 1;
+
 	switch(frags) {
 	case 0:	return 1;	/* just the skb->data seg */
 	case 1:	return 2;	/* skb->data + 1 frag */
@@ -2201,14 +2228,15 @@ static int ql_send_map(struct ql3_adapter *qdev,
 {
 	struct oal *oal;
 	struct oal_entry *oal_entry;
-	int len = skb_headlen(skb);
+	int len = skb->len;
 	dma_addr_t map;
 	int err;
 	int completed_segs, i;
 	int seg_cnt, seg = 0;
 	int frag_cnt = (int)skb_shinfo(skb)->nr_frags;
 
-	seg_cnt = tx_cb->seg_count = ql_get_seg_count((skb_shinfo(skb)->nr_frags));
+	seg_cnt = tx_cb->seg_count = ql_get_seg_count(qdev,
+						      (skb_shinfo(skb)->nr_frags));
 	if(seg_cnt == -1) {
 		printk(KERN_ERR PFX"%s: invalid segment count!\n",__func__);
 		return NETDEV_TX_BUSY;
@@ -2234,7 +2262,7 @@ static int ql_send_map(struct ql3_adapter *qdev,
 	pci_unmap_len_set(&tx_cb->map[seg], maplen, len);
 	seg++;
 
-	if (!skb_shinfo(skb)->nr_frags) {
+	if (seg_cnt == 1) {
 		/* Terminate the last segment. */
 		oal_entry->len =
 		    cpu_to_le32(le32_to_cpu(oal_entry->len) | OAL_LAST_ENTRY);
@@ -2359,13 +2387,12 @@ static int ql3xxx_send(struct sk_buff *skb, struct net_device *ndev)
 	struct ob_mac_iocb_req *mac_iocb_ptr;
 
 	if (unlikely(atomic_read(&qdev->tx_count) < 2)) {
-		if (!netif_queue_stopped(ndev))
-			netif_stop_queue(ndev);
 		return NETDEV_TX_BUSY;
 	}
 	
 	tx_cb = &qdev->tx_buf[qdev->req_producer_index] ;
-	if((tx_cb->seg_count = ql_get_seg_count((skb_shinfo(skb)->nr_frags))) == -1) {
+	if((tx_cb->seg_count = ql_get_seg_count(qdev,
+						(skb_shinfo(skb)->nr_frags))) == -1) {
 		printk(KERN_ERR PFX"%s: invalid segment count!\n",__func__);
 		return NETDEV_TX_OK;
 	}
@@ -2377,7 +2404,8 @@ static int ql3xxx_send(struct sk_buff *skb, struct net_device *ndev)
 	mac_iocb_ptr->transaction_id = qdev->req_producer_index;
 	mac_iocb_ptr->data_len = cpu_to_le16((u16) tot_len);
 	tx_cb->skb = skb;
-	if (skb->ip_summed == CHECKSUM_PARTIAL)
+	if (qdev->device_id == QL3032_DEVICE_ID &&
+	    skb->ip_summed == CHECKSUM_PARTIAL)
 		ql_hw_csum_setup(skb, mac_iocb_ptr);
 	
 	if(ql_send_map(qdev,mac_iocb_ptr,tx_cb,skb) != NETDEV_TX_OK) {
diff --git a/drivers/net/qla3xxx.h b/drivers/net/qla3xxx.h
index 40913d2..34cd658 100755
--- a/drivers/net/qla3xxx.h
+++ b/drivers/net/qla3xxx.h
@@ -1194,7 +1194,7 @@ struct ql3_adapter {
 	struct net_rsp_iocb *rsp_current;
 	u16 rsp_consumer_index;
 	u16 reserved_06;
-	u32 *prsp_producer_index;
+	volatile u32 *prsp_producer_index;
 	u32 rsp_producer_index_phy_addr_high;
 	u32 rsp_producer_index_phy_addr_low;
 
-- 
1.5.0.rc4.16.g9e258

