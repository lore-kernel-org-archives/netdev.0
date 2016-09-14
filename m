From: <sean.wang@mediatek.com>
Subject: [PATCH net-next 7/7] net: ethernet: mediatek: avoid race condition during the reset process
Date: Wed, 14 Sep 2016 11:50:41 +0800
Message-ID: <1473825041-21072-8-git-send-email-sean.wang@mediatek.com>
References: <1473825041-21072-1-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nbd@openwrt.org>, <netdev@vger.kernel.org>,
        <linux-mediatek@lists.infradead.org>, <keyhaede@gmail.com>,
        <objelf@gmail.com>, Sean Wang <sean.wang@mediatek.com>
To: <john@phrozen.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw02.mediatek.com ([210.61.82.184]:25995 "EHLO
        mailgw02.mediatek.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
        with ESMTP id S1755204AbcINDuw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Sep 2016 23:50:52 -0400
In-Reply-To: <1473825041-21072-1-git-send-email-sean.wang@mediatek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sean Wang <sean.wang@mediatek.com>

add the protection of the race condition between
the reset process and hardware access happening
on the related callbacks.

Signed-off-by: Sean Wang <sean.wang@mediatek.com>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c | 36 +++++++++++++++++++++++++++++
 drivers/net/ethernet/mediatek/mtk_eth_soc.h |  3 ++-
 2 files changed, 38 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index 48cddf9..a6a9a2f 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -145,6 +145,9 @@ static void mtk_phy_link_adjust(struct net_device *dev)
 		  MAC_MCR_RX_EN | MAC_MCR_BACKOFF_EN |
 		  MAC_MCR_BACKPR_EN;
 
+	if (unlikely(test_bit(MTK_RESETTING, &mac->hw->state)))
+		return;
+
 	switch (mac->phy_dev->speed) {
 	case SPEED_1000:
 		mcr |= MAC_MCR_SPEED_1000;
@@ -370,6 +373,9 @@ static int mtk_set_mac_address(struct net_device *dev, void *p)
 	if (ret)
 		return ret;
 
+	if (unlikely(test_bit(MTK_RESETTING, &mac->hw->state)))
+		return -EBUSY;
+
 	spin_lock_bh(&mac->hw->page_lock);
 	mtk_w32(mac->hw, (macaddr[0] << 8) | macaddr[1],
 		MTK_GDMA_MAC_ADRH(mac->id));
@@ -770,6 +776,9 @@ static int mtk_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	 */
 	spin_lock(&eth->page_lock);
 
+	if (unlikely(test_bit(MTK_RESETTING, &eth->state)))
+		goto drop;
+
 	tx_num = mtk_cal_txd_req(skb);
 	if (unlikely(atomic_read(&ring->free_count) <= tx_num)) {
 		mtk_stop_queue(eth);
@@ -842,6 +851,9 @@ static int mtk_poll_rx(struct napi_struct *napi, int budget,
 
 		netdev = eth->netdev[mac];
 
+		if (unlikely(test_bit(MTK_RESETTING, &eth->state)))
+			goto release_desc;
+
 		/* alloc new buffer */
 		new_data = napi_alloc_frag(ring->frag_size);
 		if (unlikely(!new_data)) {
@@ -1573,6 +1585,12 @@ static void mtk_pending_work(struct work_struct *work)
 
 	rtnl_lock();
 
+	dev_dbg(eth->dev, "[%s][%d] reset\n", __func__, __LINE__);
+
+	while (test_and_set_bit_lock(MTK_RESETTING, &eth->state))
+		cpu_relax();
+
+	dev_dbg(eth->dev, "[%s][%d] mtk_stop starts\n", __func__, __LINE__);
 	/* stop all devices to make sure that dma is properly shut down */
 	for (i = 0; i < MTK_MAC_COUNT; i++) {
 		if (!eth->netdev[i])
@@ -1580,6 +1598,7 @@ static void mtk_pending_work(struct work_struct *work)
 		mtk_stop(eth->netdev[i]);
 		__set_bit(i, &restart);
 	}
+	dev_dbg(eth->dev, "[%s][%d] mtk_stop ends\n", __func__, __LINE__);
 
 	/* restart underlying hardware such as power, clock, pin mux
 	 * and the connected phy
@@ -1613,6 +1632,11 @@ static void mtk_pending_work(struct work_struct *work)
 			dev_close(eth->netdev[i]);
 		}
 	}
+
+	dev_dbg(eth->dev, "[%s][%d] reset done\n", __func__, __LINE__);
+
+	clear_bit_unlock(MTK_RESETTING, &eth->state);
+
 	rtnl_unlock();
 }
 
@@ -1657,6 +1681,9 @@ static int mtk_get_settings(struct net_device *dev,
 	struct mtk_mac *mac = netdev_priv(dev);
 	int err;
 
+	if (unlikely(test_bit(MTK_RESETTING, &mac->hw->state)))
+		return -EBUSY;
+
 	err = phy_read_status(mac->phy_dev);
 	if (err)
 		return -ENODEV;
@@ -1707,6 +1734,9 @@ static int mtk_nway_reset(struct net_device *dev)
 {
 	struct mtk_mac *mac = netdev_priv(dev);
 
+	if (unlikely(test_bit(MTK_RESETTING, &mac->hw->state)))
+		return -EBUSY;
+
 	return genphy_restart_aneg(mac->phy_dev);
 }
 
@@ -1715,6 +1745,9 @@ static u32 mtk_get_link(struct net_device *dev)
 	struct mtk_mac *mac = netdev_priv(dev);
 	int err;
 
+	if (unlikely(test_bit(MTK_RESETTING, &mac->hw->state)))
+		return -EBUSY;
+
 	err = genphy_update_link(mac->phy_dev);
 	if (err)
 		return ethtool_op_get_link(dev);
@@ -1755,6 +1788,9 @@ static void mtk_get_ethtool_stats(struct net_device *dev,
 	unsigned int start;
 	int i;
 
+	if (unlikely(test_bit(MTK_RESETTING, &mac->hw->state)))
+		return;
+
 	if (netif_running(dev) && netif_device_present(dev)) {
 		if (spin_trylock(&hwstats->stats_lock)) {
 			mtk_stats_update_mac(mac);
diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.h b/drivers/net/ethernet/mediatek/mtk_eth_soc.h
index 7efa00f..79954b4 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.h
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.h
@@ -336,7 +336,8 @@ enum mtk_clks_map {
 };
 
 enum mtk_dev_state {
-	MTK_HW_INIT
+	MTK_HW_INIT,
+	MTK_RESETTING
 };
 
 /* struct mtk_tx_buf -	This struct holds the pointers to the memory pointed at
-- 
1.9.1
