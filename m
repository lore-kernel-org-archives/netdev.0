From: Sean Wang <sean.wang@mediatek.com>
Subject: [PATCH 4/5] net: ethernet: mediatek: enable rx path by reducing memory barrier
Date: Mon, 15 Aug 2016 23:03:49 +0800
Message-ID: <1471273430-19942-4-git-send-email-sean.wang@mediatek.com>
References: <1471273430-19942-1-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nbd@openwrt.org>, <netdev@vger.kernel.org>,
	<linux-mediatek@lists.infradead.org>, <keyhaede@gmail.com>,
	Sean Wang <sean.wang@mediatek.com>
To: <john@phrozen.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw02.mediatek.com ([210.61.82.184]:18578 "EHLO
	mailgw02.mediatek.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753083AbcHOPD7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Aug 2016 11:03:59 -0400
In-Reply-To: <1471273430-19942-1-git-send-email-sean.wang@mediatek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch makes moving wmb() to outside the loop that could help
rx path handling more faster although that rx descriptors aren't
freed for DMA to use as soon as possible, but based on my experiment
and the result show it still can reach about 943Mbpis tested on the
setup with one port using gigaphy and 256 rx descriptors for
DMA to move.

Signed-off-by: Sean Wang <sean.wang@mediatek.com>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c |   11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index b782330..53e24c1 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -893,14 +893,15 @@ release_desc:
 		rxd->rxd2 = RX_DMA_PLEN0(ring->buf_size);
 
 		ring->calc_idx = idx;
-		/* make sure that all changes to the dma ring are flushed before
-		 * we continue
-		 */
-		wmb();
-		mtk_w32(eth, ring->calc_idx, MTK_QRX_CRX_IDX0);
 		done++;
 	}
 
+    /* make sure that all changes to the dma ring are flushed before
+     * we continue
+     */
+	wmb();
+	mtk_w32(eth, ring->calc_idx, MTK_QRX_CRX_IDX0);
+
 	if (done < budget)
 		mtk_w32(eth, MTK_RX_DONE_INT, MTK_QMTK_INT_STATUS);
 
-- 
1.7.9.5
