From: <sean.wang@mediatek.com>
Subject: [PATCH net-next v5 1/2] net: ethernet: mediatek: enhance RX path by reducing the frequency of the memory barrier used
Date: Sat, 3 Sep 2016 17:59:26 +0800
Message-ID: <1472896767-18352-2-git-send-email-sean.wang@mediatek.com>
References: <1472896767-18352-1-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nbd@openwrt.org>, <netdev@vger.kernel.org>,
        <linux-mediatek@lists.infradead.org>, <keyhaede@gmail.com>,
        <objelf@gmail.com>, Sean Wang <sean.wang@mediatek.com>
To: <john@phrozen.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw01.mediatek.com ([210.61.82.183]:34294 "EHLO
        mailgw01.mediatek.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753202AbcICJ7j (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 3 Sep 2016 05:59:39 -0400
In-Reply-To: <1472896767-18352-1-git-send-email-sean.wang@mediatek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sean Wang <sean.wang@mediatek.com>

The patch makes move wmb() to outside the loop that could help
RX path handling more faster although that RX descriptors aren't
freed for DMA to use as soon as possible, but based on my experiment
and the result shows it still can reach about 943Mbpis without
performance drop that is tested based on the setup with one port
using Giga PHY and 256 RX descriptors for DMA to move.

Signed-off-by: Sean Wang <sean.wang@mediatek.com>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index 431b851..a1bdb53 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -890,13 +890,14 @@ release_desc:
 		rxd->rxd2 = RX_DMA_PLEN0(ring->buf_size);
 
 		ring->calc_idx = idx;
-		/* make sure that all changes to the dma ring are flushed before
-		 * we continue
-		 */
-		wmb();
-		mtk_w32(eth, ring->calc_idx, MTK_PRX_CRX_IDX0);
+
 		done++;
 	}
+	/* make sure that all changes to the dma ring are flushed before
+	 * we continue
+	 */
+	wmb();
+	mtk_w32(eth, ring->calc_idx, MTK_PRX_CRX_IDX0);
 
 	if (done < budget)
 		mtk_w32(eth, MTK_RX_DONE_INT, MTK_PDMA_INT_STATUS);
-- 
1.9.1
