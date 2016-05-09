From: John Crispin <john@phrozen.org>
Subject: [PATCH V2 15/22] net-next: mediatek: only wake the queue if it is stopped
Date: Mon,  9 May 2016 12:04:07 +0200
Message-ID: <1462788254-40572-16-git-send-email-john@phrozen.org>
References: <1462788254-40572-1-git-send-email-john@phrozen.org>
Cc: nbd@nbd.name, netdev@vger.kernel.org,
	linux-mediatek@lists.infradead.org, John Crispin <john@phrozen.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:50472 "EHLO nbd.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752224AbcEIK2D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 May 2016 06:28:03 -0400
In-Reply-To: <1462788254-40572-1-git-send-email-john@phrozen.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current code unconditionally wakes up the queue at the end of each
tx_poll action. Change the code to only wake up the queues if any of
them have actually been stopped before.

Signed-off-by: John Crispin <john@phrozen.org>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c |   17 ++++++++++++++++-
 1 file changed, 16 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index 9f4b533..7f42178 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -703,6 +703,20 @@ static inline int mtk_cal_txd_req(struct sk_buff *skb)
 	return nfrags;
 }
 
+static int mtk_queue_stopped(struct mtk_eth *eth)
+{
+	int i;
+
+	for (i = 0; i < MTK_MAC_COUNT; i++) {
+		if (!eth->netdev[i])
+			continue;
+		if (netif_queue_stopped(eth->netdev[i]))
+			return 1;
+	}
+
+	return 0;
+}
+
 static void mtk_wake_queue(struct mtk_eth *eth)
 {
 	int i;
@@ -947,7 +961,8 @@ static int mtk_poll_tx(struct mtk_eth *eth, int budget, bool *tx_again)
 	if (!total)
 		return 0;
 
-	if (atomic_read(&ring->free_count) > ring->thresh)
+	if (mtk_queue_stopped(eth) &&
+	    (atomic_read(&ring->free_count) > ring->thresh))
 		mtk_wake_queue(eth);
 
 	return total;
-- 
1.7.10.4
