From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 4/5] qlcnic: fix race in tx stop queue
Date: Thu, 17 Jun 2010 05:56:41 -0700
Message-ID: <1276779402-496-5-git-send-email-amit.salecha@qlogic.com>
References: <1276779402-496-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	Rajesh K Borundia <rajesh.borundia@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:21734 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1750705Ab0FQM4n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jun 2010 08:56:43 -0400
In-Reply-To: <1276779402-496-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rajesh K Borundia <rajesh.borundia@qlogic.com>

There is a race between netif_stop_queue and netif_stopped_queue
check. So check once again if buffers are available to avoid race.
With above logic we can also get rid of tx lock in process_cmd_ring.

Signed-off-by: Rajesh K Borundia <rajesh.borundia@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h      |    8 +++++---
 drivers/net/qlcnic/qlcnic_hw.c   |   12 +++++++++---
 drivers/net/qlcnic/qlcnic_init.c |    2 ++
 drivers/net/qlcnic/qlcnic_main.c |   23 ++++++++++-------------
 4 files changed, 26 insertions(+), 19 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index 9970cff..99ccdd8 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -113,8 +113,10 @@
 #define TX_UDPV6_PKT	0x0c
 
 /* Tx defines */
-#define MAX_BUFFERS_PER_CMD	32
-#define TX_STOP_THRESH		((MAX_SKB_FRAGS >> 2) + 4)
+#define MAX_TSO_HEADER_DESC	2
+#define MGMT_CMD_DESC_RESV	4
+#define TX_STOP_THRESH		((MAX_SKB_FRAGS >> 2) + MAX_TSO_HEADER_DESC \
+							+ MGMT_CMD_DESC_RESV)
 #define QLCNIC_MAX_TX_TIMEOUTS	2
 
 /*
@@ -369,7 +371,7 @@ struct qlcnic_recv_crb {
  */
 struct qlcnic_cmd_buffer {
 	struct sk_buff *skb;
-	struct qlcnic_skb_frag frag_array[MAX_BUFFERS_PER_CMD + 1];
+	struct qlcnic_skb_frag frag_array[MAX_SKB_FRAGS + 1];
 	u32 frag_count;
 };
 
diff --git a/drivers/net/qlcnic/qlcnic_hw.c b/drivers/net/qlcnic/qlcnic_hw.c
index f776956..d9becb9 100644
--- a/drivers/net/qlcnic/qlcnic_hw.c
+++ b/drivers/net/qlcnic/qlcnic_hw.c
@@ -338,9 +338,15 @@ qlcnic_send_cmd_descs(struct qlcnic_adapter *adapter,
 
 	if (nr_desc >= qlcnic_tx_avail(tx_ring)) {
 		netif_tx_stop_queue(tx_ring->txq);
-		__netif_tx_unlock_bh(tx_ring->txq);
-		adapter->stats.xmit_off++;
-		return -EBUSY;
+		smp_mb();
+		if (qlcnic_tx_avail(tx_ring) > nr_desc) {
+			if (qlcnic_tx_avail(tx_ring) > TX_STOP_THRESH)
+				netif_tx_wake_queue(tx_ring->txq);
+		} else {
+			adapter->stats.xmit_off++;
+			__netif_tx_unlock_bh(tx_ring->txq);
+			return -EBUSY;
+		}
 	}
 
 	do {
diff --git a/drivers/net/qlcnic/qlcnic_init.c b/drivers/net/qlcnic/qlcnic_init.c
index 2bd00d5..058ce61 100644
--- a/drivers/net/qlcnic/qlcnic_init.c
+++ b/drivers/net/qlcnic/qlcnic_init.c
@@ -181,7 +181,9 @@ skip_rds:
 
 	tx_ring = adapter->tx_ring;
 	vfree(tx_ring->cmd_buf_arr);
+	tx_ring->cmd_buf_arr = NULL;
 	kfree(adapter->tx_ring);
+	adapter->tx_ring = NULL;
 }
 
 int qlcnic_alloc_sw_resources(struct qlcnic_adapter *adapter)
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index 06d2dfd..655bccd 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -132,12 +132,6 @@ qlcnic_update_cmd_producer(struct qlcnic_adapter *adapter,
 		struct qlcnic_host_tx_ring *tx_ring)
 {
 	writel(tx_ring->producer, tx_ring->crb_cmd_producer);
-
-	if (qlcnic_tx_avail(tx_ring) <= TX_STOP_THRESH) {
-		netif_stop_queue(adapter->netdev);
-		smp_mb();
-		adapter->stats.xmit_off++;
-	}
 }
 
 static const u32 msi_tgt_status[8] = {
@@ -1137,7 +1131,7 @@ qlcnic_setup_netdev(struct qlcnic_adapter *adapter,
 	adapter->max_mc_count = 38;
 
 	netdev->netdev_ops	   = &qlcnic_netdev_ops;
-	netdev->watchdog_timeo     = 2*HZ;
+	netdev->watchdog_timeo     = 5*HZ;
 
 	qlcnic_change_mtu(netdev, netdev->mtu);
 
@@ -1709,10 +1703,15 @@ qlcnic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	/* 4 fragments per cmd des */
 	no_of_desc = (frag_count + 3) >> 2;
 
-	if (unlikely(no_of_desc + 2 > qlcnic_tx_avail(tx_ring))) {
+	if (unlikely(qlcnic_tx_avail(tx_ring) <= TX_STOP_THRESH)) {
 		netif_stop_queue(netdev);
-		adapter->stats.xmit_off++;
-		return NETDEV_TX_BUSY;
+		smp_mb();
+		if (qlcnic_tx_avail(tx_ring) > TX_STOP_THRESH)
+			netif_start_queue(netdev);
+		else {
+			adapter->stats.xmit_off++;
+			return NETDEV_TX_BUSY;
+		}
 	}
 
 	producer = tx_ring->producer;
@@ -2018,14 +2017,12 @@ static int qlcnic_process_cmd_ring(struct qlcnic_adapter *adapter)
 		smp_mb();
 
 		if (netif_queue_stopped(netdev) && netif_carrier_ok(netdev)) {
-			__netif_tx_lock(tx_ring->txq, smp_processor_id());
 			if (qlcnic_tx_avail(tx_ring) > TX_STOP_THRESH) {
 				netif_wake_queue(netdev);
-				adapter->tx_timeo_cnt = 0;
 				adapter->stats.xmit_on++;
 			}
-			__netif_tx_unlock(tx_ring->txq);
 		}
+		adapter->tx_timeo_cnt = 0;
 	}
 	/*
 	 * If everything is freed up to consumer then check if the ring is full
-- 
1.6.0.2

