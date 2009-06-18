From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH 2/2] netxen: fix tx ring accounting
Date: Wed, 17 Jun 2009 20:27:25 -0700
Message-ID: <1245295645-22573-2-git-send-email-dhananjay@netxen.com>
References: <1245295645-22573-1-git-send-email-dhananjay@netxen.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:36932 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755083AbZFRD1Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Jun 2009 23:27:24 -0400
In-Reply-To: <1245295645-22573-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This forces every update of tx ring producer to check for
availability of space for next full TSO command. Earlier
firmware control commands didn't care to pause tx queue.

Stop the tx queue if there's not enough space to transmit one full
LSO command left on the tx ring after current transmit. This avoids
returning NETDEV_TX_BUSY after checking distance between producer
and consumer on every cpu.

Restart the tx queue only if we have cleaned up enough tx
descriptors.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h      |   11 ++++++++++-
 drivers/net/netxen/netxen_nic_hw.c   |    2 +-
 drivers/net/netxen/netxen_nic_init.c |   11 +++++------
 drivers/net/netxen/netxen_nic_main.c |   32 +++++++++++++++++++-------------
 4 files changed, 35 insertions(+), 21 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index ab11c2b..970cede 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -169,6 +169,7 @@
 #define	MAX_NUM_CARDS		4
 
 #define MAX_BUFFERS_PER_CMD	32
+#define TX_STOP_THRESH		((MAX_SKB_FRAGS >> 2) + 4)
 
 /*
  * Following are the states of the Phantom. Phantom will set them and
@@ -1436,7 +1437,7 @@ int netxen_nic_set_mac(struct net_device *netdev, void *p);
 struct net_device_stats *netxen_nic_get_stats(struct net_device *netdev);
 
 void netxen_nic_update_cmd_producer(struct netxen_adapter *adapter,
-		struct nx_host_tx_ring *tx_ring, uint32_t crb_producer);
+		struct nx_host_tx_ring *tx_ring);
 
 /*
  * NetXen Board information
@@ -1538,6 +1539,14 @@ dma_watchdog_wakeup(struct netxen_adapter *adapter)
 }
 
 
+static inline u32 netxen_tx_avail(struct nx_host_tx_ring *tx_ring)
+{
+	smp_mb();
+	return find_diff_among(tx_ring->producer,
+			tx_ring->sw_consumer, tx_ring->num_desc);
+
+}
+
 int netxen_get_flash_mac_addr(struct netxen_adapter *adapter, __le64 *mac);
 int netxen_p3_get_mac_addr(struct netxen_adapter *adapter, __le64 *mac);
 extern void netxen_change_ringparam(struct netxen_adapter *adapter);
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index 9702509..ce3b89d 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -488,7 +488,7 @@ netxen_send_cmd_descs(struct netxen_adapter *adapter,
 
 	tx_ring->producer = producer;
 
-	netxen_nic_update_cmd_producer(adapter, tx_ring, producer);
+	netxen_nic_update_cmd_producer(adapter, tx_ring);
 
 	netif_tx_unlock_bh(adapter->netdev);
 
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index 6f77ad5..bdb143d 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -1292,7 +1292,6 @@ int netxen_process_cmd_ring(struct netxen_adapter *adapter)
 		return 1;
 
 	sw_consumer = tx_ring->sw_consumer;
-	barrier(); /* hw_consumer can change underneath */
 	hw_consumer = le32_to_cpu(*(tx_ring->hw_consumer));
 
 	while (sw_consumer != hw_consumer) {
@@ -1319,14 +1318,15 @@ int netxen_process_cmd_ring(struct netxen_adapter *adapter)
 			break;
 	}
 
-	tx_ring->sw_consumer = sw_consumer;
-
 	if (count && netif_running(netdev)) {
+		tx_ring->sw_consumer = sw_consumer;
+
 		smp_mb();
+
 		if (netif_queue_stopped(netdev) && netif_carrier_ok(netdev)) {
 			netif_tx_lock(netdev);
-			netif_wake_queue(netdev);
-			smp_mb();
+			if (netxen_tx_avail(tx_ring) > TX_STOP_THRESH)
+				netif_wake_queue(netdev);
 			netif_tx_unlock(netdev);
 		}
 	}
@@ -1343,7 +1343,6 @@ int netxen_process_cmd_ring(struct netxen_adapter *adapter)
 	 * There is still a possible race condition and the host could miss an
 	 * interrupt. The card has to take care of this.
 	 */
-	barrier(); /* hw_consumer can change underneath */
 	hw_consumer = le32_to_cpu(*(tx_ring->hw_consumer));
 	done = (sw_consumer == hw_consumer);
 	spin_unlock(&adapter->tx_clean_lock);
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 98737ef..71daa3d 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -107,9 +107,14 @@ static uint32_t crb_cmd_producer[4] = {
 
 void
 netxen_nic_update_cmd_producer(struct netxen_adapter *adapter,
-		struct nx_host_tx_ring *tx_ring, u32 producer)
+		struct nx_host_tx_ring *tx_ring)
 {
-	NXWR32(adapter, tx_ring->crb_cmd_producer, producer);
+	NXWR32(adapter, tx_ring->crb_cmd_producer, tx_ring->producer);
+
+	if (netxen_tx_avail(tx_ring) <= TX_STOP_THRESH) {
+		netif_stop_queue(adapter->netdev);
+		smp_mb();
+	}
 }
 
 static uint32_t crb_cmd_consumer[4] = {
@@ -119,9 +124,9 @@ static uint32_t crb_cmd_consumer[4] = {
 
 static inline void
 netxen_nic_update_cmd_consumer(struct netxen_adapter *adapter,
-		struct nx_host_tx_ring *tx_ring, u32 consumer)
+		struct nx_host_tx_ring *tx_ring)
 {
-	NXWR32(adapter, tx_ring->crb_cmd_consumer, consumer);
+	NXWR32(adapter, tx_ring->crb_cmd_consumer, tx_ring->sw_consumer);
 }
 
 static uint32_t msi_tgt_status[8] = {
@@ -900,8 +905,11 @@ netxen_nic_attach(struct netxen_adapter *adapter)
 		tx_ring->crb_cmd_producer = crb_cmd_producer[adapter->portnum];
 		tx_ring->crb_cmd_consumer = crb_cmd_consumer[adapter->portnum];
 
-		netxen_nic_update_cmd_producer(adapter, tx_ring, 0);
-		netxen_nic_update_cmd_consumer(adapter, tx_ring, 0);
+		tx_ring->producer = 0;
+		tx_ring->sw_consumer = 0;
+
+		netxen_nic_update_cmd_producer(adapter, tx_ring);
+		netxen_nic_update_cmd_consumer(adapter, tx_ring);
 	}
 
 	for (ring = 0; ring < adapter->max_rds_rings; ring++) {
@@ -1362,7 +1370,7 @@ netxen_nic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	dma_addr_t temp_dma;
 	int i, k;
 
-	u32 producer, consumer;
+	u32 producer;
 	int frag_count, no_of_desc;
 	u32 num_txd = tx_ring->num_desc;
 	bool is_tso = false;
@@ -1372,15 +1380,13 @@ netxen_nic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	/* 4 fragments per cmd des */
 	no_of_desc = (frag_count + 3) >> 2;
 
-	producer = tx_ring->producer;
-	smp_mb();
-	consumer = tx_ring->sw_consumer;
-	if ((no_of_desc+2) >= find_diff_among(producer, consumer, num_txd)) {
+	if (unlikely(no_of_desc + 2) > netxen_tx_avail(tx_ring)) {
 		netif_stop_queue(netdev);
-		smp_mb();
 		return NETDEV_TX_BUSY;
 	}
 
+	producer = tx_ring->producer;
+
 	hwdesc = &tx_ring->desc_head[producer];
 	netxen_clear_cmddesc((u64 *)hwdesc);
 	pbuf = &tx_ring->cmd_buf_arr[producer];
@@ -1493,7 +1499,7 @@ netxen_nic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	tx_ring->producer = producer;
 	adapter->stats.txbytes += skb->len;
 
-	netxen_nic_update_cmd_producer(adapter, tx_ring, producer);
+	netxen_nic_update_cmd_producer(adapter, tx_ring);
 
 	adapter->stats.xmitcalled++;
 
-- 
1.6.0.2

