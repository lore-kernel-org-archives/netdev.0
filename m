From: Roman Yeryomin <roman@advem.lv>
Subject: [PATCH net-next 08/10] net: korina: optimize tx_full condition
Date: Sun, 15 Oct 2017 19:24:06 +0300
Message-ID: <20171015162406.1118-1-roman@advem.lv>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1l1v.rtu.lv ([213.175.92.62]:52643 "EHLO mail.pbx.lv"
        rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
        id S1751386AbdJOQdK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 15 Oct 2017 12:33:10 -0400
Received: from ubrain.corp.ubnt.com (unknown [213.175.92.61])
        by mail.pbx.lv (MailSystem) with ESMTPSA id 176FE19194B
        for <netdev@vger.kernel.org>; Sun, 15 Oct 2017 19:23:27 +0300 (EEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Roman Yeryomin <roman@advem.lv>
---
 drivers/net/ethernet/korina.c | 20 ++++----------------
 1 file changed, 4 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/korina.c b/drivers/net/ethernet/korina.c
index f606f1e01af1..9520fa1e35a2 100644
--- a/drivers/net/ethernet/korina.c
+++ b/drivers/net/ethernet/korina.c
@@ -124,7 +124,6 @@ struct korina_private {
 	int tx_chain_tail;
 	enum chain_status tx_chain_status;
 	int tx_count;
-	int tx_full;
 
 	int rx_irq;
 	int tx_irq;
@@ -261,19 +260,10 @@ static int korina_send_packet(struct sk_buff *skb, struct net_device *dev)
 
 	td = &lp->td_ring[lp->tx_chain_tail];
 
-	/* stop queue when full, drop pkts if queue already full */
-	if (lp->tx_count >= (KORINA_NUM_TDS - 2)) {
-		lp->tx_full = 1;
+	/* stop queue when full */
+	if (unlikely(lp->tx_count > (KORINA_NUM_TDS - 3)))
 		netif_stop_queue(dev);
 
-		if (lp->tx_count > (KORINA_NUM_TDS - 2)) {
-			dev->stats.tx_dropped++;
-			dev_kfree_skb_any(skb);
-
-			return NETDEV_TX_BUSY;
-		}
-	}
-
 	lp->tx_count++;
 	lp->tx_skb[lp->tx_chain_tail] = skb;
 
@@ -323,10 +313,8 @@ static void korina_tx(struct net_device *dev)
 
 	/* Process all desc that are done */
 	while (IS_DMA_FINISHED(td->control)) {
-		if (lp->tx_full == 1) {
+		if (unlikely(lp->tx_count > (KORINA_NUM_TDS - 2)))
 			netif_wake_queue(dev);
-			lp->tx_full = 0;
-		}
 
 		devcs = lp->td_ring[lp->tx_next_done].devcs;
 
@@ -696,7 +684,7 @@ static int korina_alloc_ring(struct net_device *dev)
 		lp->td_ring[i].link = 0;
 	}
 	lp->tx_next_done = lp->tx_chain_head = lp->tx_chain_tail =
-			lp->tx_full = lp->tx_count = 0;
+			lp->tx_count = 0;
 	lp->tx_chain_status = desc_empty;
 
 	/* Initialize the receive descriptors */
-- 
2.11.0
