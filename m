From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 14/18] tg3: Assign rx ret producer indexes by vector
Date: Tue, 1 Sep 2009 16:19:05 -0700
Message-ID: <1251867313.5953@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4093 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932146AbZIBEz0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Sep 2009 00:55:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When RSS is enabled, the status block format changes slightly.  The
"rx_jumbo_consumer", "reserved", and "rx_mini_consumer" members get
mapped to the other three rx return ring producer indexes.  This patch
introduces a new per-interrupt member which identifies which location
in the status block a particular vector should look for return ring
updates.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/tg3.c |   31 +++++++++++++++++++++++++++----
 drivers/net/tg3.h |    1 +
 2 files changed, 28 insertions(+), 4 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 930229b..a2ff202 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -667,7 +667,7 @@ static inline unsigned int tg3_has_work(struct tg3_napi *tnapi)
 	}
 	/* check for RX/TX work to do */
 	if (sblk->idx[0].tx_consumer != tnapi->tx_cons ||
-	    sblk->idx[0].rx_producer != tnapi->rx_rcb_ptr)
+	    *(tnapi->rx_rcb_prod_idx) != tnapi->rx_rcb_ptr)
 		work_exists = 1;
 
 	return work_exists;
@@ -4518,7 +4518,7 @@ static int tg3_rx(struct tg3_napi *tnapi, int budget)
 	int received;
 	struct tg3_rx_prodring_set *tpr = &tp->prodring[0];
 
-	hw_idx = tnapi->hw_status->idx[0].rx_producer;
+	hw_idx = *(tnapi->rx_rcb_prod_idx);
 	/*
 	 * We need to order the read of hw_idx and the read of
 	 * the opaque cookie.
@@ -4649,7 +4649,7 @@ next_pkt_nopost:
 
 		/* Refresh hw_idx to see if there is new work */
 		if (sw_idx == hw_idx) {
-			hw_idx = tnapi->hw_status->idx[0].rx_producer;
+			hw_idx = *(tnapi->rx_rcb_prod_idx);
 			rmb();
 		}
 	}
@@ -4711,7 +4711,7 @@ static int tg3_poll_work(struct tg3_napi *tnapi, int work_done, int budget)
 	 * All RX "locking" is done by ensuring outside
 	 * code synchronizes with tg3->napi.poll()
 	 */
-	if (sblk->idx[0].rx_producer != tnapi->rx_rcb_ptr)
+	if (*(tnapi->rx_rcb_prod_idx) != tnapi->rx_rcb_ptr)
 		work_done += tg3_rx(tnapi, budget - work_done);
 
 	return work_done;
@@ -5896,6 +5896,7 @@ static int tg3_alloc_consistent(struct tg3 *tp)
 
 	for (i = 0; i < tp->irq_cnt; i++) {
 		struct tg3_napi *tnapi = &tp->napi[i];
+		struct tg3_hw_status *sblk;
 
 		tnapi->hw_status = pci_alloc_consistent(tp->pdev,
 							TG3_HW_STATUS_SIZE,
@@ -5904,6 +5905,28 @@ static int tg3_alloc_consistent(struct tg3 *tp)
 			goto err_out;
 
 		memset(tnapi->hw_status, 0, TG3_HW_STATUS_SIZE);
+		sblk = tnapi->hw_status;
+
+		/*
+		 * When RSS is enabled, the status block format changes
+		 * slightly.  The "rx_jumbo_consumer", "reserved",
+		 * and "rx_mini_consumer" members get mapped to the
+		 * other three rx return ring producer indexes.
+		 */
+		switch (i) {
+		default:
+			tnapi->rx_rcb_prod_idx = &sblk->idx[0].rx_producer;
+			break;
+		case 2:
+			tnapi->rx_rcb_prod_idx = &sblk->rx_jumbo_consumer;
+			break;
+		case 3:
+			tnapi->rx_rcb_prod_idx = &sblk->reserved;
+			break;
+		case 4:
+			tnapi->rx_rcb_prod_idx = &sblk->rx_mini_consumer;
+			break;
+		}
 
 		/*
 		 * If multivector RSS is enabled, vector 0 does not handle
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 348add2..685d971 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2538,6 +2538,7 @@ struct tg3_napi {
 
 	u32				consmbox;
 	u32				rx_rcb_ptr;
+	u16				*rx_rcb_prod_idx;
 
 	struct tg3_rx_buffer_desc	*rx_rcb;
 	struct tg3_tx_buffer_desc	*tx_ring;
-- 
1.6.3.3


