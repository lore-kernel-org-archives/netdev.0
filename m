From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 13/18] tg3: Adjust RSS ring allocation strategies
Date: Tue, 1 Sep 2009 16:16:33 -0700
Message-ID: <1251867312.5950@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4086 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932137AbZIBEz0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Sep 2009 00:55:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When multivector RSS is enabled, the first interrupt vector is only used
to report link interrupts and error conditions.  This patch changes the
code so that rx and tx ring resources are not allocated for this vector.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/tg3.c |   31 +++++++++++++++++++++++++------
 1 files changed, 25 insertions(+), 6 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 39a8ead..930229b 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -4804,7 +4804,8 @@ static irqreturn_t tg3_msi_1shot(int irq, void *dev_id)
 	struct tg3 *tp = tnapi->tp;
 
 	prefetch(tnapi->hw_status);
-	prefetch(&tnapi->rx_rcb[tnapi->rx_rcb_ptr]);
+	if (tnapi->rx_rcb)
+		prefetch(&tnapi->rx_rcb[tnapi->rx_rcb_ptr]);
 
 	if (likely(!tg3_irq_sync(tp)))
 		napi_schedule(&tnapi->napi);
@@ -4822,7 +4823,8 @@ static irqreturn_t tg3_msi(int irq, void *dev_id)
 	struct tg3 *tp = tnapi->tp;
 
 	prefetch(tnapi->hw_status);
-	prefetch(&tnapi->rx_rcb[tnapi->rx_rcb_ptr]);
+	if (tnapi->rx_rcb)
+		prefetch(&tnapi->rx_rcb[tnapi->rx_rcb_ptr]);
 	/*
 	 * Writing any value to intr-mbox-0 clears PCI INTA# and
 	 * chip-internal interrupt pending events.
@@ -5765,6 +5767,9 @@ static void tg3_free_rings(struct tg3 *tp)
 	for (j = 0; j < tp->irq_cnt; j++) {
 		struct tg3_napi *tnapi = &tp->napi[j];
 
+		if (!tnapi->tx_buffers)
+			continue;
+
 		for (i = 0; i < TG3_TX_RING_SIZE; ) {
 			struct tx_ring_info *txp;
 			struct sk_buff *skb;
@@ -5815,10 +5820,12 @@ static int tg3_init_rings(struct tg3 *tp)
 
 		tnapi->tx_prod = 0;
 		tnapi->tx_cons = 0;
-		memset(tnapi->tx_ring, 0, TG3_TX_RING_BYTES);
+		if (tnapi->tx_ring)
+			memset(tnapi->tx_ring, 0, TG3_TX_RING_BYTES);
 
 		tnapi->rx_rcb_ptr = 0;
-		memset(tnapi->rx_rcb, 0, TG3_RX_RCB_RING_BYTES(tp));
+		if (tnapi->rx_rcb)
+			memset(tnapi->rx_rcb, 0, TG3_RX_RCB_RING_BYTES(tp));
 	}
 
 	return tg3_rx_prodring_alloc(tp, &tp->prodring[0]);
@@ -5898,6 +5905,13 @@ static int tg3_alloc_consistent(struct tg3 *tp)
 
 		memset(tnapi->hw_status, 0, TG3_HW_STATUS_SIZE);
 
+		/*
+		 * If multivector RSS is enabled, vector 0 does not handle
+		 * rx or tx interrupts.  Don't allocate any resources for it.
+		 */
+		if (!i && (tp->tg3_flags3 & TG3_FLG3_ENABLE_RSS))
+			continue;
+
 		tnapi->rx_rcb = pci_alloc_consistent(tp->pdev,
 						     TG3_RX_RCB_RING_BYTES(tp),
 						     &tnapi->rx_rcb_mapping);
@@ -10166,8 +10180,13 @@ static int tg3_run_loopback(struct tg3 *tp, int loopback_mode)
 	struct tg3_napi *tnapi, *rnapi;
 	struct tg3_rx_prodring_set *tpr = &tp->prodring[0];
 
-	tnapi = &tp->napi[0];
-	rnapi = &tp->napi[0];
+	if (tp->irq_cnt > 1) {
+		tnapi = &tp->napi[1];
+		rnapi = &tp->napi[1];
+	} else {
+		tnapi = &tp->napi[0];
+		rnapi = &tp->napi[0];
+	}
 	coal_now = tnapi->coal_now | rnapi->coal_now;
 
 	if (loopback_mode == TG3_MAC_LOOPBACK) {
-- 
1.6.3.3


