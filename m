From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 5/5] qlge: Remove dynamic alloc of rx ring control blocks.
Date: Fri,  9 Jan 2009 13:31:53 -0800
Message-ID: <1231536713-24538-5-git-send-email-ron.mercer@qlogic.com>
References: <20090109213045.GD10803@susedev.qlogic.org>
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:58231 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757921AbZAIVcH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2009 16:32:07 -0500
In-Reply-To: <20090109213045.GD10803@susedev.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge.h      |   12 ++++++++----
 drivers/net/qlge/qlge_main.c |   31 ++-----------------------------
 2 files changed, 10 insertions(+), 33 deletions(-)

diff --git a/drivers/net/qlge/qlge.h b/drivers/net/qlge/qlge.h
index a509534..c1dadad 100644
--- a/drivers/net/qlge/qlge.h
+++ b/drivers/net/qlge/qlge.h
@@ -30,8 +30,9 @@
 #define QLGE_VENDOR_ID    0x1077
 #define QLGE_DEVICE_ID    0x8012
 
-#define MAX_RX_RINGS 128
-#define MAX_TX_RINGS 128
+#define MAX_CPUS 8
+#define MAX_TX_RINGS MAX_CPUS
+#define MAX_RX_RINGS ((MAX_CPUS * 2) + 1)
 
 #define NUM_TX_RING_ENTRIES	256
 #define NUM_RX_RING_ENTRIES	256
@@ -44,6 +45,7 @@
 #define MAX_SPLIT_SIZE 1023
 #define QLGE_SB_PAD 32
 
+#define MAX_CQ 128
 #define DFLT_COALESCE_WAIT 100	/* 100 usec wait for coalescing */
 #define MAX_INTER_FRAME_WAIT 10	/* 10 usec max interframe-wait for coalescing */
 #define DFLT_INTER_FRAME_WAIT (MAX_INTER_FRAME_WAIT/2)
@@ -1393,9 +1395,11 @@ struct ql_adapter {
 	int rx_ring_count;
 	int ring_mem_size;
 	void *ring_mem;
-	struct rx_ring *rx_ring;
+
+	struct rx_ring rx_ring[MAX_RX_RINGS];
+	struct tx_ring tx_ring[MAX_TX_RINGS];
+
 	int rx_csum;
-	struct tx_ring *tx_ring;
 	u32 default_rx_queue;
 
 	u16 rx_coalesce_usecs;	/* cqicb->int_delay */
diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index e289423..96830e4 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -2355,28 +2355,6 @@ static void ql_tx_ring_clean(struct ql_adapter *qdev)
 	}
 }
 
-static void ql_free_ring_cb(struct ql_adapter *qdev)
-{
-	kfree(qdev->ring_mem);
-}
-
-static int ql_alloc_ring_cb(struct ql_adapter *qdev)
-{
-	/* Allocate space for tx/rx ring control blocks. */
-	qdev->ring_mem_size =
-	    (qdev->tx_ring_count * sizeof(struct tx_ring)) +
-	    (qdev->rx_ring_count * sizeof(struct rx_ring));
-	qdev->ring_mem = kmalloc(qdev->ring_mem_size, GFP_KERNEL);
-	if (qdev->ring_mem == NULL) {
-		return -ENOMEM;
-	} else {
-		qdev->rx_ring = qdev->ring_mem;
-		qdev->tx_ring = qdev->ring_mem +
-		    (qdev->rx_ring_count * sizeof(struct rx_ring));
-	}
-	return 0;
-}
-
 static void ql_free_mem_resources(struct ql_adapter *qdev)
 {
 	int i;
@@ -3236,7 +3214,6 @@ static int qlge_close(struct net_device *ndev)
 		msleep(1);
 	ql_adapter_down(qdev);
 	ql_release_adapter_resources(qdev);
-	ql_free_ring_cb(qdev);
 	return 0;
 }
 
@@ -3262,8 +3239,8 @@ static int ql_configure_rings(struct ql_adapter *qdev)
 	 * This limitation can be removed when requested.
 	 */
 
-	if (cpu_cnt > 8)
-		cpu_cnt = 8;
+	if (cpu_cnt > MAX_CPUS)
+		cpu_cnt = MAX_CPUS;
 
 	/*
 	 * rx_ring[0] is always the default queue.
@@ -3283,9 +3260,6 @@ static int ql_configure_rings(struct ql_adapter *qdev)
 	 */
 	qdev->rx_ring_count = qdev->tx_ring_count + qdev->rss_ring_count + 1;
 
-	if (ql_alloc_ring_cb(qdev))
-		return -ENOMEM;
-
 	for (i = 0; i < qdev->tx_ring_count; i++) {
 		tx_ring = &qdev->tx_ring[i];
 		memset((void *)tx_ring, 0, sizeof(tx_ring));
@@ -3382,7 +3356,6 @@ static int qlge_open(struct net_device *ndev)
 
 error_up:
 	ql_release_adapter_resources(qdev);
-	ql_free_ring_cb(qdev);
 	return err;
 }
 
-- 
1.6.0

