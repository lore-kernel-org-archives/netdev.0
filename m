From: Sean Wang <sean.wang@mediatek.com>
Subject: [RESEND PATCH net 01/10] net: ethernet: mediatek: fix fails from TX housekeeping due to incorrect port setup
Date: Thu, 25 Aug 2016 18:44:52 +0800
Message-ID: <1472121901-15629-2-git-send-email-sean.wang@mediatek.com>
References: <1472121901-15629-1-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nbd@openwrt.org>, <netdev@vger.kernel.org>,
        <linux-mediatek@lists.infradead.org>, <keyhaede@gmail.com>,
        Sean Wang <sean.wang@mediatek.com>
To: <john@phrozen.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw01.mediatek.com ([210.61.82.183]:2967 "EHLO
        mailgw01.mediatek.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
        with ESMTP id S932911AbcHYKpK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2016 06:45:10 -0400
In-Reply-To: <1472121901-15629-1-git-send-email-sean.wang@mediatek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

which net device the SKB is complete for depends on the forward port
on txd4 on the corresponding TX descriptor, but the information isn't
set up well in case of  SKB fragments that would lead to watchdog timeout
from the upper layer, so fix it up.

Signed-off-by: Sean Wang <sean.wang@mediatek.com>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index 1801fd8..6e4a6ca 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -587,14 +587,15 @@ static int mtk_tx_map(struct sk_buff *skb, struct net_device *dev,
 	dma_addr_t mapped_addr;
 	unsigned int nr_frags;
 	int i, n_desc = 1;
-	u32 txd4 = 0;
+	u32 txd4 = 0, fport;
 
 	itxd = ring->next_free;
 	if (itxd == ring->last_free)
 		return -ENOMEM;
 
 	/* set the forward port */
-	txd4 |= (mac->id + 1) << TX_DMA_FPORT_SHIFT;
+	fport = (mac->id + 1) << TX_DMA_FPORT_SHIFT;
+	txd4 |= fport;
 
 	tx_buf = mtk_desc_to_tx_buf(ring, itxd);
 	memset(tx_buf, 0, sizeof(*tx_buf));
@@ -652,7 +653,7 @@ static int mtk_tx_map(struct sk_buff *skb, struct net_device *dev,
 			WRITE_ONCE(txd->txd3, (TX_DMA_SWC |
 					       TX_DMA_PLEN0(frag_map_size) |
 					       last_frag * TX_DMA_LS0));
-			WRITE_ONCE(txd->txd4, 0);
+			WRITE_ONCE(txd->txd4, fport);
 
 			tx_buf->skb = (struct sk_buff *)MTK_DMA_DUMMY_DESC;
 			tx_buf = mtk_desc_to_tx_buf(ring, txd);
-- 
1.9.1
