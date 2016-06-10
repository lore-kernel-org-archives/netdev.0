From: John Crispin <john@phrozen.org>
Subject: [PATCH V2 10/11] net: mediatek: only wake the queue if it is stopped
Date: Fri, 10 Jun 2016 13:28:07 +0200
Message-ID: <1465558088-15265-11-git-send-email-john@phrozen.org>
References: <1465558088-15265-1-git-send-email-john@phrozen.org>
Cc: Felix Fietkau <nbd@nbd.name>, Sean Wang <keyhaede@gmail.com>,
	netdev@vger.kernel.org, linux-mediatek@lists.infradead.org,
	linux-kernel@vger.kernel.org, John Crispin <john@phrozen.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1465558088-15265-1-git-send-email-john@phrozen.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The current code unconditionally wakes up the queue at the end of each
tx_poll action. Change the code to only wake up the queues if any of
them have actually been stopped before.

Signed-off-by: John Crispin <john@phrozen.org>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c |   17 ++++++++++++++++-
 1 file changed, 16 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index 6daf48b..40d3cfd 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -685,6 +685,20 @@ static inline int mtk_cal_txd_req(struct sk_buff *skb)
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
@@ -929,7 +943,8 @@ static int mtk_poll_tx(struct mtk_eth *eth, int budget, bool *tx_again)
 	if (!total)
 		return 0;
 
-	if (atomic_read(&ring->free_count) > ring->thresh)
+	if (mtk_queue_stopped(eth) &&
+	    (atomic_read(&ring->free_count) > ring->thresh))
 		mtk_wake_queue(eth);
 
 	return total;
-- 
1.7.10.4
