From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Subject: [PATCH 1/2] ucc_geth: Move freeing of TX packets to NAPI context.
Date: Thu, 26 Mar 2009 13:54:36 +0100
Message-ID: <1238072077-27044-1-git-send-email-Joakim.Tjernlund@transmode.se>
Cc: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
To: avorontsov@ru.mvista.com, leoli@freescale.com,
	linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([213.115.205.20]:51646 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752509AbZCZMyp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Mar 2009 08:54:45 -0400
Received: from tmnt04.transmode.se (tmnt04.transmode.se [192.168.46.15])
	by gw1.transmode.se (Postfix) with ESMTP id CEFF84B077
	for <netdev@vger.kernel.org>; Thu, 26 Mar 2009 13:54:40 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Also set NAPI weight to 64 as this is a common value.
This will make the system alot more responsive while
ping flooding the ucc_geth ethernet interaface.

Signed-off-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
---
 drivers/net/ucc_geth.c |   32 ++++++++++++--------------------
 drivers/net/ucc_geth.h |    1 -
 2 files changed, 12 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 097aed8..7fc91aa 100644
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
@@ -3733,7 +3725,7 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 	dev->netdev_ops = &ucc_geth_netdev_ops;
 	dev->watchdog_timeo = TX_TIMEOUT;
 	INIT_WORK(&ugeth->timeout_work, ucc_geth_timeout_work);
-	netif_napi_add(dev, &ugeth->napi, ucc_geth_poll, UCC_GETH_DEV_WEIGHT);
+	netif_napi_add(dev, &ugeth->napi, ucc_geth_poll, 64);
 	dev->mtu = 1500;
 
 	ugeth->msg_enable = netif_msg_init(debug.msg_enable, UGETH_MSG_DEFAULT);
diff --git a/drivers/net/ucc_geth.h b/drivers/net/ucc_geth.h
index 44218b8..50bad53 100644
--- a/drivers/net/ucc_geth.h
+++ b/drivers/net/ucc_geth.h
@@ -843,7 +843,6 @@ struct ucc_geth_hardware_statistics {
 /* Driver definitions */
 #define TX_BD_RING_LEN                          0x10
 #define RX_BD_RING_LEN                          0x10
-#define UCC_GETH_DEV_WEIGHT                     TX_BD_RING_LEN
 
 #define TX_RING_MOD_MASK(size)                  (size-1)
 #define RX_RING_MOD_MASK(size)                  (size-1)
-- 
1.6.1.3

