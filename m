From: Roman Yeryomin <roman@advem.lv>
Subject: [PATCH net-next 06/10] net: korina: optimize tx descriptor flags processing
Date: Sun, 15 Oct 2017 19:23:41 +0300
Message-ID: <20171015162341.986-1-roman@advem.lv>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1l1v.rtu.lv ([213.175.92.62]:52619 "EHLO mail.pbx.lv"
        rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
        id S1751682AbdJOQ2K (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 15 Oct 2017 12:28:10 -0400
Received: from ubrain.corp.ubnt.com (unknown [213.175.92.61])
        by mail.pbx.lv (MailSystem) with ESMTPSA id AC4B01918A7
        for <netdev@vger.kernel.org>; Sun, 15 Oct 2017 19:23:02 +0300 (EEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Roman Yeryomin <roman@advem.lv>
---
 drivers/net/ethernet/korina.c | 23 ++++++-----------------
 1 file changed, 6 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/korina.c b/drivers/net/ethernet/korina.c
index 59d4554c43c9..a076b0c49e6e 100644
--- a/drivers/net/ethernet/korina.c
+++ b/drivers/net/ethernet/korina.c
@@ -342,43 +342,33 @@ static void korina_tx(struct net_device *dev)
 		}
 
 		devcs = lp->td_ring[lp->tx_next_done].devcs;
-		if ((devcs & (ETH_TX_FD | ETH_TX_LD)) !=
-				(ETH_TX_FD | ETH_TX_LD)) {
-			dev->stats.tx_errors++;
-			dev->stats.tx_dropped++;
 
-			/* Should never happen */
-			printk(KERN_ERR "%s: split tx ignored\n",
-							dev->name);
-		} else if (devcs & ETH_TX_TOK) {
-			dev->stats.tx_packets++;
-			dev->stats.tx_bytes +=
-					lp->tx_skb[lp->tx_next_done]->len;
-		} else {
+		if (!(devcs & ETH_TX_TOK)) {
 			dev->stats.tx_errors++;
 			dev->stats.tx_dropped++;
 
 			/* Underflow */
 			if (devcs & ETH_TX_UND)
 				dev->stats.tx_fifo_errors++;
-
 			/* Oversized frame */
 			if (devcs & ETH_TX_OF)
 				dev->stats.tx_aborted_errors++;
-
 			/* Excessive deferrals */
 			if (devcs & ETH_TX_ED)
 				dev->stats.tx_carrier_errors++;
-
 			/* Collisions: medium busy */
 			if (devcs & ETH_TX_EC)
 				dev->stats.collisions++;
-
 			/* Late collision */
 			if (devcs & ETH_TX_LC)
 				dev->stats.tx_window_errors++;
+
+			goto next;
 		}
 
+		dev->stats.tx_packets++;
+		dev->stats.tx_bytes += lp->tx_skb[lp->tx_next_done]->len;
+next:
 		/* We must always free the original skb */
 		if (lp->tx_skb[lp->tx_next_done]) {
 			dev_kfree_skb_any(lp->tx_skb[lp->tx_next_done]);
@@ -394,7 +384,6 @@ static void korina_tx(struct net_device *dev)
 		/* Go on to next transmission */
 		lp->tx_next_done = (lp->tx_next_done + 1) & KORINA_TDS_MASK;
 		td = &lp->td_ring[lp->tx_next_done];
-
 	}
 
 	/* Clear the DMA status register */
-- 
2.11.0
