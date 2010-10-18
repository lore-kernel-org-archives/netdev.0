From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 1/2] netxen: fix race in tx stop queue
Date: Mon, 18 Oct 2010 05:03:41 -0700
Message-ID: <1287403422-10431-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com,
	Rajesh Borundia <rajesh.borundia@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:3297 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1750876Ab0JRMDn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Oct 2010 08:03:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rajesh Borundia <rajesh.borundia@qlogic.com>

There is race between netif_stop_queue and netif_stopped_queue
check.So check once again if buffers are available to avoid race.
With above logic we can also get rid of tx lock in process_cmd_ring.

Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/netxen/netxen_nic.h      |    5 ++++-
 drivers/net/netxen/netxen_nic_hw.c   |   10 ++++++++--
 drivers/net/netxen/netxen_nic_init.c |   10 +++-------
 drivers/net/netxen/netxen_nic_main.c |   15 +++++++--------
 4 files changed, 22 insertions(+), 18 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 6dca357..92f89af 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -175,7 +175,10 @@
 #define	MAX_NUM_CARDS		4
 
 #define MAX_BUFFERS_PER_CMD	32
-#define TX_STOP_THRESH		((MAX_SKB_FRAGS >> 2) + 4)
+#define MAX_TSO_HEADER_DESC	2
+#define MGMT_CMD_DESC_RESV	4
+#define TX_STOP_THRESH		((MAX_SKB_FRAGS >> 2) + MAX_TSO_HEADER_DESC \
+							+ MGMT_CMD_DESC_RESV)
 #define NX_MAX_TX_TIMEOUTS	2
 
 /*
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index 29d7b93..10e2f13 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -598,8 +598,14 @@ netxen_send_cmd_descs(struct netxen_adapter *adapter,
 
 	if (nr_desc >= netxen_tx_avail(tx_ring)) {
 		netif_tx_stop_queue(tx_ring->txq);
-		__netif_tx_unlock_bh(tx_ring->txq);
-		return -EBUSY;
+		smp_mb();
+		if (netxen_tx_avail(tx_ring) > nr_desc) {
+			if (netxen_tx_avail(tx_ring) > TX_STOP_THRESH)
+				netif_tx_wake_queue(tx_ring->txq);
+		} else {
+			__netif_tx_unlock_bh(tx_ring->txq);
+			return -EBUSY;
+		}
 	}
 
 	do {
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index a2d805a..95fe552 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -1763,14 +1763,10 @@ int netxen_process_cmd_ring(struct netxen_adapter *adapter)
 
 		smp_mb();
 
-		if (netif_queue_stopped(netdev) && netif_carrier_ok(netdev)) {
-			__netif_tx_lock(tx_ring->txq, smp_processor_id());
-			if (netxen_tx_avail(tx_ring) > TX_STOP_THRESH) {
+		if (netif_queue_stopped(netdev) && netif_carrier_ok(netdev))
+			if (netxen_tx_avail(tx_ring) > TX_STOP_THRESH)
 				netif_wake_queue(netdev);
-				adapter->tx_timeo_cnt = 0;
-			}
-			__netif_tx_unlock(tx_ring->txq);
-		}
+		adapter->tx_timeo_cnt = 0;
 	}
 	/*
 	 * If everything is freed up to consumer then check if the ring is full
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 2c6ceeb..83ee554 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -125,11 +125,6 @@ netxen_nic_update_cmd_producer(struct netxen_adapter *adapter,
 		struct nx_host_tx_ring *tx_ring)
 {
 	NXWRIO(adapter, tx_ring->crb_cmd_producer, tx_ring->producer);
-
-	if (netxen_tx_avail(tx_ring) <= TX_STOP_THRESH) {
-		netif_stop_queue(adapter->netdev);
-		smp_mb();
-	}
 }
 
 static uint32_t crb_cmd_consumer[4] = {
@@ -1209,7 +1204,7 @@ netxen_setup_netdev(struct netxen_adapter *adapter,
 		adapter->max_mc_count = 16;
 
 	netdev->netdev_ops	   = &netxen_netdev_ops;
-	netdev->watchdog_timeo     = 2*HZ;
+	netdev->watchdog_timeo     = 5*HZ;
 
 	netxen_nic_change_mtu(netdev, netdev->mtu);
 
@@ -1825,9 +1820,13 @@ netxen_nic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	/* 4 fragments per cmd des */
 	no_of_desc = (frag_count + 3) >> 2;
 
-	if (unlikely(no_of_desc + 2 > netxen_tx_avail(tx_ring))) {
+	if (unlikely(netxen_tx_avail(tx_ring) <= TX_STOP_THRESH)) {
 		netif_stop_queue(netdev);
-		return NETDEV_TX_BUSY;
+		smp_mb();
+		if (netxen_tx_avail(tx_ring) > TX_STOP_THRESH)
+			netif_start_queue(netdev);
+		else
+			return NETDEV_TX_BUSY;
 	}
 
 	producer = tx_ring->producer;
-- 
1.6.0.2

