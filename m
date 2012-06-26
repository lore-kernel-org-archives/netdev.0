From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net-next] bnx2x: organize BDs calculation for
 stop/resume
Date: Tue, 26 Jun 2012 11:32:50 +0300
Message-ID: <1340699570-17735-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Dmitry Kravkov" <dmitry@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>,
	"Eric Dumazet" <edumazet@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1914 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758476Ab2FZIdB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jun 2012 04:33:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Put the numbers used for stop/resume queue in a single place and
fix the condition for sanity check.

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
Cc: Eric Dumazet <edumazet@google.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h     |   16 ++++++++++++++++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c |   10 ++++++----
 2 files changed, 22 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index 7211cb0..392fffe 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -612,6 +612,22 @@ struct bnx2x_fastpath {
 #define TX_BD(x)		((x) & MAX_TX_BD)
 #define TX_BD_POFF(x)		((x) & MAX_TX_DESC_CNT)
 
+/* number of NEXT_PAGE descriptors may be required during placement */
+#define NEXT_CNT_PER_TX_PKT(bds)	\
+				(((bds) + MAX_TX_DESC_CNT - 1) / \
+				 MAX_TX_DESC_CNT * NEXT_PAGE_TX_DESC_CNT)
+/* max BDs per tx packet w/o next_pages:
+ * START_BD		- describes packed
+ * START_BD(splitted)	- includes unpaged data segment for GSO
+ * PARSING_BD		- for TSO and CSUM data
+ * Frag BDs		- decribes pages for frags
+ */
+#define BDS_PER_TX_PKT		3
+#define MAX_BDS_PER_TX_PKT	(MAX_SKB_FRAGS + BDS_PER_TX_PKT)
+/* max BDs per tx packet including next pages */
+#define MAX_DESC_PER_TX_PKT	(MAX_BDS_PER_TX_PKT + \
+				 NEXT_CNT_PER_TX_PKT(MAX_BDS_PER_TX_PKT))
+
 /* The RX BD ring is special, each bd is 8 bytes but the last one is 16 */
 #define NUM_RX_RINGS		8
 #define RX_DESC_CNT		(BCM_PAGE_SIZE / sizeof(struct eth_rx_bd))
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 00951b3..e357a5d 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -221,7 +221,7 @@ int bnx2x_tx_int(struct bnx2x *bp, struct bnx2x_fp_txdata *txdata)
 
 		if ((netif_tx_queue_stopped(txq)) &&
 		    (bp->state == BNX2X_STATE_OPEN) &&
-		    (bnx2x_tx_avail(bp, txdata) >= MAX_SKB_FRAGS + 4))
+		    (bnx2x_tx_avail(bp, txdata) >= MAX_DESC_PER_TX_PKT))
 			netif_tx_wake_queue(txq);
 
 		__netif_tx_unlock(txq);
@@ -2937,7 +2937,9 @@ netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	   txdata->cid, fp_index, txdata_index, txdata, fp); */
 
 	if (unlikely(bnx2x_tx_avail(bp, txdata) <
-		     (skb_shinfo(skb)->nr_frags + 3))) {
+			skb_shinfo(skb)->nr_frags +
+			BDS_PER_TX_PKT +
+			NEXT_CNT_PER_TX_PKT(MAX_BDS_PER_TX_PKT))) {
 		bnx2x_fp_qstats(bp, txdata->parent_fp)->driver_xoff++;
 		netif_tx_stop_queue(txq);
 		BNX2X_ERR("BUG! Tx ring full when queue awake!\n");
@@ -3212,7 +3214,7 @@ netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	txdata->tx_bd_prod += nbd;
 
-	if (unlikely(bnx2x_tx_avail(bp, txdata) < MAX_SKB_FRAGS + 4)) {
+	if (unlikely(bnx2x_tx_avail(bp, txdata) < MAX_DESC_PER_TX_PKT)) {
 		netif_tx_stop_queue(txq);
 
 		/* paired memory barrier is in bnx2x_tx_int(), we have to keep
@@ -3221,7 +3223,7 @@ netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		smp_mb();
 
 		bnx2x_fp_qstats(bp, txdata->parent_fp)->driver_xoff++;
-		if (bnx2x_tx_avail(bp, txdata) >= MAX_SKB_FRAGS + 4)
+		if (bnx2x_tx_avail(bp, txdata) >= MAX_DESC_PER_TX_PKT)
 			netif_tx_wake_queue(txq);
 	}
 	txdata->tx_pkt++;
-- 
1.7.1
