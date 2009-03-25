From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: [PATCH] ucc_geth: Move freeing of TX packets to NAPI context.
Date: Wed, 25 Mar 2009 14:30:49 +0100
Message-ID: <1237987849.2194.9.camel@gentoo-jocke.transmode.se>
Reply-To: joakim.tjernlund@transmode.se
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: avorontsov@ru.mvista.com, leoli@freescale.com,
	'linuxppc-dev Development' <linuxppc-dev@ozlabs.org>
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([213.115.205.20]:47074 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756157AbZCYNax (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Mar 2009 09:30:53 -0400
Received: from tmnt04.transmode.se (tmnt04.transmode.se [192.168.46.15])
	by gw1.transmode.se (Postfix) with ESMTP id A6490C6293
	for <netdev@vger.kernel.org>; Wed, 25 Mar 2009 14:30:49 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From 1c2f23b1f37f4818c0fd0217b93eb38ab6564840 Mon Sep 17 00:00:00 2001
From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Date: Tue, 24 Mar 2009 10:19:27 +0100
Subject: [PATCH] ucc_geth: Move freeing of TX packets to NAPI context.
 Also increase NAPI weight somewhat.
 This will make the system alot more responsive while
 ping flooding the ucc_geth ethernet interaface.


Signed-off-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
---
 drivers/net/ucc_geth.c |   30 +++++++++++-------------------
 drivers/net/ucc_geth.h |    2 +-
 2 files changed, 12 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 097aed8..7d5d110 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -3214,7 +3214,7 @@ static int ucc_geth_tx(struct net_device *dev, u8 txQ)
 		dev->stats.tx_packets++;
 
 		/* Free the sk buffer associated with this TxBD */
-		dev_kfree_skb_irq(ugeth->
+		dev_kfree_skb(ugeth->
 				  tx_skbuff[txQ][ugeth->skb_dirtytx[txQ]]);
 		ugeth->tx_skbuff[txQ][ugeth->skb_dirtytx[txQ]] = NULL;
 		ugeth->skb_dirtytx[txQ] =
@@ -3248,9 +3248,16 @@ static int ucc_geth_poll(struct napi_struct *napi, int budget)
 	for (i = 0; i < ug_info->numQueuesRx; i++)
 		howmany += ucc_geth_rx(ugeth, i, budget - howmany);
 
+	/* Tx event processing */
+	spin_lock(&ugeth->lock);
+	for (i = 0; i < ug_info->numQueuesTx; i++) {
+		ucc_geth_tx(ugeth->dev, i);
+	}
+	spin_unlock(&ugeth->lock);
+
 	if (howmany < budget) {
 		netif_rx_complete(napi);
-		setbits32(ugeth->uccf->p_uccm, UCCE_RX_EVENTS);
+		setbits32(ugeth->uccf->p_uccm, UCCE_RX_EVENTS | UCCE_TX_EVENTS);
 	}
 
 	return howmany;
@@ -3264,8 +3271,6 @@ static irqreturn_t ucc_geth_irq_handler(int irq, void *info)
 	struct ucc_geth_info *ug_info;
 	register u32 ucce;
 	register u32 uccm;
-	register u32 tx_mask;
-	u8 i;
 
 	ugeth_vdbg("%s: IN", __func__);
 
@@ -3279,27 +3284,14 @@ static irqreturn_t ucc_geth_irq_handler(int irq, void *info)
 	out_be32(uccf->p_ucce, ucce);
 
 	/* check for receive events that require processing */
-	if (ucce & UCCE_RX_EVENTS) {
+	if (ucce & (UCCE_RX_EVENTS | UCCE_TX_EVENTS)) {
 		if (netif_rx_schedule_prep(&ugeth->napi)) {
-			uccm &= ~UCCE_RX_EVENTS;
+			uccm &= ~(UCCE_RX_EVENTS | UCCE_TX_EVENTS);
 			out_be32(uccf->p_uccm, uccm);
 			__netif_rx_schedule(&ugeth->napi);
 		}
 	}
 
-	/* Tx event processing */
-	if (ucce & UCCE_TX_EVENTS) {
-		spin_lock(&ugeth->lock);
-		tx_mask = UCC_GETH_UCCE_TXB0;
-		for (i = 0; i < ug_info->numQueuesTx; i++) {
-			if (ucce & tx_mask)
-				ucc_geth_tx(dev, i);
-			ucce &= ~tx_mask;
-			tx_mask <<= 1;
-		}
-		spin_unlock(&ugeth->lock);
-	}
-
 	/* Errors and other events */
 	if (ucce & UCCE_OTHER) {
 		if (ucce & UCC_GETH_UCCE_BSY)
diff --git a/drivers/net/ucc_geth.h b/drivers/net/ucc_geth.h
index 44218b8..ea30aa7 100644
--- a/drivers/net/ucc_geth.h
+++ b/drivers/net/ucc_geth.h
@@ -843,7 +843,7 @@ struct ucc_geth_hardware_statistics {
 /* Driver definitions */
 #define TX_BD_RING_LEN                          0x10
 #define RX_BD_RING_LEN                          0x10
-#define UCC_GETH_DEV_WEIGHT                     TX_BD_RING_LEN
+#define UCC_GETH_DEV_WEIGHT                     (RX_BD_RING_LEN+TX_BD_RING_LEN/2)
 
 #define TX_RING_MOD_MASK(size)                  (size-1)
 #define RX_RING_MOD_MASK(size)                  (size-1)
-- 
1.6.1.3


