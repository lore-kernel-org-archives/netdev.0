From: <sean.wang@mediatek.com>
Subject: [PATCH] net: ethernet: mediatek: enhance the locking using the lightweight ones
Date: Thu, 11 Aug 2016 17:51:00 +0800
Message-ID: <1470909060-27976-1-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <nbd@openwrt.org>, <netdev@vger.kernel.org>,
	<linux-mediatek@lists.infradead.org>, <keyhaede@gmail.com>,
	Sean Wang <sean.wang@mediatek.com>
To: <john@phrozen.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw01.mediatek.com ([210.61.82.183]:23809 "EHLO
	mailgw01.mediatek.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752654AbcHKJvM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Aug 2016 05:51:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sean Wang <sean.wang@mediatek.com>

Since these critical sections protected by page_lock are all entered
from the user context or bottom half context, they can be replaced
with the spin_lock() or spin_lock_bh instead of spin_lock_irqsave().

Signed-off-by: Sean Wang <sean.wang@mediatek.com>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c |   19 ++++++++-----------
 1 file changed, 8 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index b57ae3a..3a4726e 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -353,18 +353,17 @@ static int mtk_set_mac_address(struct net_device *dev, void *p)
 	int ret = eth_mac_addr(dev, p);
 	struct mtk_mac *mac = netdev_priv(dev);
 	const char *macaddr = dev->dev_addr;
-	unsigned long flags;
 
 	if (ret)
 		return ret;
 
-	spin_lock_irqsave(&mac->hw->page_lock, flags);
+	spin_lock_bh(&mac->hw->page_lock);
 	mtk_w32(mac->hw, (macaddr[0] << 8) | macaddr[1],
 		MTK_GDMA_MAC_ADRH(mac->id));
 	mtk_w32(mac->hw, (macaddr[2] << 24) | (macaddr[3] << 16) |
 		(macaddr[4] << 8) | macaddr[5],
 		MTK_GDMA_MAC_ADRL(mac->id));
-	spin_unlock_irqrestore(&mac->hw->page_lock, flags);
+	spin_unlock_bh(&mac->hw->page_lock);
 
 	return 0;
 }
@@ -748,7 +747,6 @@ static int mtk_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct mtk_eth *eth = mac->hw;
 	struct mtk_tx_ring *ring = &eth->tx_ring;
 	struct net_device_stats *stats = &dev->stats;
-	unsigned long flags;
 	bool gso = false;
 	int tx_num;
 
@@ -756,14 +754,14 @@ static int mtk_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	 * however we have 2 queues running on the same ring so we need to lock
 	 * the ring access
 	 */
-	spin_lock_irqsave(&eth->page_lock, flags);
+	spin_lock(&eth->page_lock);
 
 	tx_num = mtk_cal_txd_req(skb);
 	if (unlikely(atomic_read(&ring->free_count) <= tx_num)) {
 		mtk_stop_queue(eth);
 		netif_err(eth, tx_queued, dev,
 			  "Tx Ring full when queue awake!\n");
-		spin_unlock_irqrestore(&eth->page_lock, flags);
+		spin_unlock(&eth->page_lock);
 		return NETDEV_TX_BUSY;
 	}
 
@@ -788,12 +786,12 @@ static int mtk_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (unlikely(atomic_read(&ring->free_count) <= ring->thresh))
 		mtk_stop_queue(eth);
 
-	spin_unlock_irqrestore(&eth->page_lock, flags);
+	spin_unlock(&eth->page_lock);
 
 	return NETDEV_TX_OK;
 
 drop:
-	spin_unlock_irqrestore(&eth->page_lock, flags);
+	spin_unlock(&eth->page_lock);
 	stats->tx_dropped++;
 	dev_kfree_skb(skb);
 	return NETDEV_TX_OK;
@@ -1347,16 +1345,15 @@ static int mtk_open(struct net_device *dev)
 
 static void mtk_stop_dma(struct mtk_eth *eth, u32 glo_cfg)
 {
-	unsigned long flags;
 	u32 val;
 	int i;
 
 	/* stop the dma engine */
-	spin_lock_irqsave(&eth->page_lock, flags);
+	spin_lock_bh(&eth->page_lock);
 	val = mtk_r32(eth, glo_cfg);
 	mtk_w32(eth, val & ~(MTK_TX_WB_DDONE | MTK_RX_DMA_EN | MTK_TX_DMA_EN),
 		glo_cfg);
-	spin_unlock_irqrestore(&eth->page_lock, flags);
+	spin_unlock_bh(&eth->page_lock);
 
 	/* wait for dma stop */
 	for (i = 0; i < 10; i++) {
-- 
1.7.9.5
