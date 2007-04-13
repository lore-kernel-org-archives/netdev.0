From: Kim Phillips <kim.phillips@freescale.com>
Subject: [PATCH v2 3/7] ucc_geth: NAPI-related bug fixes
Date: Fri, 13 Apr 2007 01:26:11 -0500
Message-ID: <20070413012611.2afa88c0.kim.phillips@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw02.freescale.net ([192.88.165.103]:37265 "EHLO
	de01egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752030AbXDMG1M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Apr 2007 02:27:12 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michael Reiss <michael.f.reiss@freescale.com>

Based partly on the gianfar driver, this patch fixes several
bugs which were causing NAPI to be completely unusable.
* An IRQ is still needed in NAPI, to kick off NAPI task,
  and for Tx processing.  Request the IRQ.
* If rx_work_limit = 0 we are not complete.
* While running Rx NAPI processing we must mask Rx events,
  including Rx busy.
* ucc_geth_rx function does not need a lock.
  Could lead to deadlock in NAPI case.
* There's no need to loop reading ucce multiple times in the ISR,
  so while adding the call to schedule NAPI which was not there,
  simplify the event processing into if-else format.
* Rx Busy now kicks off NAPI processing, while still
  being counted as an error.

Signed-off-by: Michael Reiss <michael.f.reiss@freescale.com>
Signed-off-by: Michael Barkowski <michael.barkowski@freescale.com>
Signed-off-by: Kim Phillips <kim.phillips@freescale.com>
---
 drivers/net/ucc_geth.c |   98 ++++++++++++++++++++++++++++-------------------
 drivers/net/ucc_geth.h |    3 +
 2 files changed, 61 insertions(+), 40 deletions(-)

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index d93cfde..60be1e7 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -3416,7 +3416,6 @@ static int ucc_geth_rx(struct ucc_geth_private *ugeth, u8 rxQ, int rx_work_limit
 
 	ugeth_vdbg("%s: IN", __FUNCTION__);
 
-	spin_lock(&ugeth->lock);
 	/* collect received buffers */
 	bd = ugeth->rxBd[rxQ];
 
@@ -3464,7 +3463,6 @@ static int ucc_geth_rx(struct ucc_geth_private *ugeth, u8 rxQ, int rx_work_limit
 		skb = get_new_skb(ugeth, bd);
 		if (!skb) {
 			ugeth_warn("%s: No Rx Data Buffer", __FUNCTION__);
-			spin_unlock(&ugeth->lock);
 			ugeth->stats.rx_dropped++;
 			break;
 		}
@@ -3485,7 +3483,6 @@ static int ucc_geth_rx(struct ucc_geth_private *ugeth, u8 rxQ, int rx_work_limit
 	}
 
 	ugeth->rxBd[rxQ] = bd;
-	spin_unlock(&ugeth->lock);
 	return howmany;
 }
 
@@ -3537,23 +3534,38 @@ static int ucc_geth_tx(struct net_device *dev, u8 txQ)
 static int ucc_geth_poll(struct net_device *dev, int *budget)
 {
 	struct ucc_geth_private *ugeth = netdev_priv(dev);
+	struct ucc_geth_info *ug_info;
+	struct ucc_fast_private *uccf;
 	int howmany;
-	int rx_work_limit = *budget;
-	u8 rxQ = 0;
+	u8 i;
+	int rx_work_limit;
+	register u32 uccm;
 
+	ug_info = ugeth->ug_info;
+
+	rx_work_limit = *budget;
 	if (rx_work_limit > dev->quota)
 		rx_work_limit = dev->quota;
 
-	howmany = ucc_geth_rx(ugeth, rxQ, rx_work_limit);
+	howmany = 0;
+
+	for (i = 0; i < ug_info->numQueuesRx; i++) {
+		howmany += ucc_geth_rx(ugeth, i, rx_work_limit);
+	}
 
 	dev->quota -= howmany;
 	rx_work_limit -= howmany;
 	*budget -= howmany;
 
-	if (rx_work_limit >= 0)
+	if (rx_work_limit > 0) {
 		netif_rx_complete(dev);
+		uccf = ugeth->uccf;
+		uccm = in_be32(uccf->p_uccm);
+		uccm |= UCCE_RX_EVENTS;
+		out_be32(uccf->p_uccm, uccm);
+	}
 
-	return (rx_work_limit < 0) ? 1 : 0;
+	return (rx_work_limit > 0) ? 0 : 1;
 }
 #endif				/* CONFIG_UGETH_NAPI */
 
@@ -3563,10 +3575,13 @@ static irqreturn_t ucc_geth_irq_handler(int irq, void *info)
 	struct ucc_geth_private *ugeth = netdev_priv(dev);
 	struct ucc_fast_private *uccf;
 	struct ucc_geth_info *ug_info;
-	register u32 ucce = 0;
-	register u32 bit_mask = UCCE_RXBF_SINGLE_MASK;
-	register u32 tx_mask = UCCE_TXBF_SINGLE_MASK;
-	register u8 i;
+	register u32 ucce;
+	register u32 uccm;
+#ifndef CONFIG_UGETH_NAPI
+	register u32 rx_mask;
+#endif
+	register u32 tx_mask;
+	u8 i;
 
 	ugeth_vdbg("%s: IN", __FUNCTION__);
 
@@ -3576,48 +3591,53 @@ static irqreturn_t ucc_geth_irq_handler(int irq, void *info)
 	uccf = ugeth->uccf;
 	ug_info = ugeth->ug_info;
 
-	do {
-		ucce |= (u32) (in_be32(uccf->p_ucce) & in_be32(uccf->p_uccm));
-
-		/* clear event bits for next time */
-		/* Side effect here is to mask ucce variable
-		for future processing below. */
-		out_be32(uccf->p_ucce, ucce);	/* Clear with ones,
-						but only bits in UCCM */
-
-		/* We ignore Tx interrupts because Tx confirmation is
-		done inside Tx routine */
+	/* read and clear events */
+	ucce = (u32) in_be32(uccf->p_ucce);
+	uccm = (u32) in_be32(uccf->p_uccm);
+	ucce &= uccm;
+	out_be32(uccf->p_ucce, ucce);
 
+	/* check for receive events that require processing */
+	if (ucce & UCCE_RX_EVENTS) {
+#ifdef CONFIG_UGETH_NAPI
+		if (netif_rx_schedule_prep(dev)) {
+		uccm &= ~UCCE_RX_EVENTS;
+			out_be32(uccf->p_uccm, uccm);
+			__netif_rx_schedule(dev);
+		}
+#else
+		rx_mask = UCCE_RXBF_SINGLE_MASK;
 		for (i = 0; i < ug_info->numQueuesRx; i++) {
-			if (ucce & bit_mask)
-				ucc_geth_rx(ugeth, i,
-					    (int)ugeth->ug_info->
-					    bdRingLenRx[i]);
-			ucce &= ~bit_mask;
-			bit_mask <<= 1;
+			if (ucce & rx_mask)
+				ucc_geth_rx(ugeth, i, (int)ugeth->ug_info->bdRingLenRx[i]);
+			ucce &= ~rx_mask;
+			rx_mask <<= 1;
 		}
+#endif /* CONFIG_UGETH_NAPI */
+	}
 
+	/* Tx event processing */
+	if (ucce & UCCE_TX_EVENTS) {
+		spin_lock(&ugeth->lock);
+		tx_mask = UCCE_TXBF_SINGLE_MASK;
 		for (i = 0; i < ug_info->numQueuesTx; i++) {
 			if (ucce & tx_mask)
 				ucc_geth_tx(dev, i);
 			ucce &= ~tx_mask;
 			tx_mask <<= 1;
 		}
+		spin_unlock(&ugeth->lock);
+	}
 
-		/* Exceptions */
+	/* Errors and other events */
+	if (ucce & UCCE_OTHER) {
 		if (ucce & UCCE_BSY) {
-			ugeth_vdbg("Got BUSY irq!!!!");
 			ugeth->stats.rx_errors++;
-			ucce &= ~UCCE_BSY;
 		}
-		if (ucce & UCCE_OTHER) {
-			ugeth_vdbg("Got frame with error (ucce - 0x%08x)!!!!",
-				   ucce);
-			ugeth->stats.rx_errors++;
-			ucce &= ~ucce;
+		if (ucce & UCCE_TXE) {
+			ugeth->stats.tx_errors++;
 		}
 	}
-	while (ucce);
 
 	return IRQ_HANDLED;
 }
@@ -3677,7 +3697,6 @@ static int ucc_geth_open(struct net_device *dev)
 
 	phy_start(ugeth->phydev);
 
-#ifndef CONFIG_UGETH_NAPI
 	err =
 	    request_irq(ugeth->ug_info->uf_info.irq, ucc_geth_irq_handler, 0,
 			"UCC Geth", dev);
@@ -3687,7 +3706,6 @@ static int ucc_geth_open(struct net_device *dev)
 		ucc_geth_stop(ugeth);
 		return err;
 	}
-#endif				/* CONFIG_UGETH_NAPI */
 
 	err = ugeth_enable(ugeth, COMM_DIR_RX_AND_TX);
 	if (err) {
diff --git a/drivers/net/ucc_geth.h b/drivers/net/ucc_geth.h
index 6e97c20..7cf3dbc 100644
--- a/drivers/net/ucc_geth.h
+++ b/drivers/net/ucc_geth.h
@@ -205,6 +205,9 @@ struct ucc_geth {
 #define UCCE_OTHER       (UCCE_SCAR | UCCE_GRA  | UCCE_CBPR | UCCE_BSY  |\
 			UCCE_RXC  | UCCE_TXC  | UCCE_TXE)
 
+#define UCCE_RX_EVENTS							(UCCE_RXF | UCCE_BSY)
+#define UCCE_TX_EVENTS							(UCCE_TXB | UCCE_TXE)
+
 /* UCC GETH UPSMR (Protocol Specific Mode Register) */
 #define UPSMR_ECM                               0x04000000	/* Enable CAM
 								   Miss or
-- 
1.5.0.1

