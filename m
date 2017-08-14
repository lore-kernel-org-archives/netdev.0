From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH V2 net-next 2/8] liquidio: moved update_txq_status to
 lio_core.c
Date: Mon, 14 Aug 2017 12:01:37 -0700
Message-ID: <20170814190137.GA1253@felix-thinkpad.cavium.com>
References: <20170814190034.GA1219@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        intiyaz.basha@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0043.outbound.protection.outlook.com ([104.47.34.43]:61076
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752048AbdHNTBn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 14 Aug 2017 15:01:43 -0400
Content-Disposition: inline
In-Reply-To: <20170814190034.GA1219@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Intiyaz Basha <intiyaz.basha@cavium.com>

Moving common update_txq_status to lio_core.c

Signed-off-by: Intiyaz Basha <intiyaz.basha@cavium.com>
Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_core.c    | 33 ++++++++++++++++++++
 drivers/net/ethernet/cavium/liquidio/lio_main.c    | 35 +---------------------
 drivers/net/ethernet/cavium/liquidio/lio_vf_main.c | 26 +---------------
 .../net/ethernet/cavium/liquidio/octeon_network.h  |  1 +
 4 files changed, 36 insertions(+), 59 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_core.c b/drivers/net/ethernet/cavium/liquidio/lio_core.c
index adde774..b55ab75 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_core.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_core.c
@@ -364,3 +364,36 @@ void cleanup_rx_oom_poll_fn(struct net_device *netdev)
 		destroy_workqueue(lio->rxq_status_wq.wq);
 	}
 }
+
+/* Runs in interrupt context. */
+void lio_update_txq_status(struct octeon_device *oct, int iq_num)
+{
+	struct octeon_instr_queue *iq = oct->instr_queue[iq_num];
+	struct net_device *netdev;
+	struct lio *lio;
+
+	netdev = oct->props[iq->ifidx].netdev;
+
+	/* This is needed because the first IQ does not have
+	 * a netdev associated with it.
+	 */
+	if (!netdev)
+		return;
+
+	lio = GET_LIO(netdev);
+	if (netif_is_multiqueue(netdev)) {
+		if (__netif_subqueue_stopped(netdev, iq->q_index) &&
+		    lio->linfo.link.s.link_up &&
+		    (!octnet_iq_is_full(oct, iq_num))) {
+			netif_wake_subqueue(netdev, iq->q_index);
+			INCR_INSTRQUEUE_PKT_COUNT(lio->oct_dev, iq_num,
+						  tx_restart, 1);
+		}
+	} else if (netif_queue_stopped(netdev) &&
+		   lio->linfo.link.s.link_up &&
+		   (!octnet_iq_is_full(oct, lio->txq))) {
+		INCR_INSTRQUEUE_PKT_COUNT(lio->oct_dev, lio->txq,
+					  tx_restart, 1);
+		netif_wake_queue(netdev);
+	}
+}
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index b20d13f..ba1b493 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -903,39 +903,6 @@ static inline void update_link_status(struct net_device *netdev,
 	}
 }
 
-/* Runs in interrupt context. */
-static void update_txq_status(struct octeon_device *oct, int iq_num)
-{
-	struct net_device *netdev;
-	struct lio *lio;
-	struct octeon_instr_queue *iq = oct->instr_queue[iq_num];
-
-	netdev = oct->props[iq->ifidx].netdev;
-
-	/* This is needed because the first IQ does not have
-	 * a netdev associated with it.
-	 */
-	if (!netdev)
-		return;
-
-	lio = GET_LIO(netdev);
-	if (netif_is_multiqueue(netdev)) {
-		if (__netif_subqueue_stopped(netdev, iq->q_index) &&
-		    lio->linfo.link.s.link_up &&
-		    (!octnet_iq_is_full(oct, iq_num))) {
-			INCR_INSTRQUEUE_PKT_COUNT(lio->oct_dev, iq_num,
-						  tx_restart, 1);
-			netif_wake_subqueue(netdev, iq->q_index);
-		}
-	} else if (netif_queue_stopped(netdev) &&
-		   lio->linfo.link.s.link_up &&
-		   (!octnet_iq_is_full(oct, lio->txq))) {
-		INCR_INSTRQUEUE_PKT_COUNT(lio->oct_dev,
-					  lio->txq, tx_restart, 1);
-		netif_wake_queue(netdev);
-	}
-}
-
 static
 int liquidio_schedule_msix_droq_pkt_handler(struct octeon_droq *droq, u64 ret)
 {
@@ -2515,7 +2482,7 @@ static int liquidio_napi_poll(struct napi_struct *napi, int budget)
 		/* Update iq read-index rather than waiting for next interrupt.
 		 * Return back if tx_done is false.
 		 */
-		update_txq_status(oct, iq_no);
+		lio_update_txq_status(oct, iq_no);
 	} else {
 		dev_err(&oct->pci_dev->dev, "%s:  iq (%d) num invalid\n",
 			__func__, iq_no);
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
index 17623ed..dd0265a 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
@@ -647,30 +647,6 @@ static void update_link_status(struct net_device *netdev,
 	}
 }
 
-static void update_txq_status(struct octeon_device *oct, int iq_num)
-{
-	struct octeon_instr_queue *iq = oct->instr_queue[iq_num];
-	struct net_device *netdev;
-	struct lio *lio;
-
-	netdev = oct->props[iq->ifidx].netdev;
-	lio = GET_LIO(netdev);
-	if (netif_is_multiqueue(netdev)) {
-		if (__netif_subqueue_stopped(netdev, iq->q_index) &&
-		    lio->linfo.link.s.link_up &&
-		    (!octnet_iq_is_full(oct, iq_num))) {
-			netif_wake_subqueue(netdev, iq->q_index);
-			INCR_INSTRQUEUE_PKT_COUNT(lio->oct_dev, iq_num,
-						  tx_restart, 1);
-		}
-	} else if (netif_queue_stopped(netdev) && lio->linfo.link.s.link_up &&
-		   (!octnet_iq_is_full(oct, lio->txq))) {
-		INCR_INSTRQUEUE_PKT_COUNT(lio->oct_dev,
-					  lio->txq, tx_restart, 1);
-		netif_wake_queue(netdev);
-	}
-}
-
 static
 int liquidio_schedule_msix_droq_pkt_handler(struct octeon_droq *droq, u64 ret)
 {
@@ -1608,7 +1584,7 @@ static int liquidio_napi_poll(struct napi_struct *napi, int budget)
 		/* Update iq read-index rather than waiting for next interrupt.
 		 * Return back if tx_done is false.
 		 */
-		update_txq_status(oct, iq_no);
+		lio_update_txq_status(oct, iq_no);
 	} else {
 		dev_err(&oct->pci_dev->dev, "%s: iq (%d) num invalid\n",
 			__func__, iq_no);
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_network.h b/drivers/net/ethernet/cavium/liquidio/octeon_network.h
index 043f6e6..0e44ee1 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_network.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_network.h
@@ -474,4 +474,5 @@ static inline int wait_for_pending_requests(struct octeon_device *oct)
 	return 0;
 }
 
+void lio_update_txq_status(struct octeon_device *oct, int iq_num);
 #endif
-- 
2.9.0
