From: <sean.wang@mediatek.com>
Subject: [PATCH net] net: ethernet: mediatek: avoid potential invalid memory access
Date: Thu, 20 Jul 2017 14:52:02 +0800
Message-ID: <3a9d3ee4bcfd47487c5dbac4c658f10e0233b723.1500532842.git.sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nbd@openwrt.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>,
        <linux-mediatek@lists.infradead.org>,
        Sean Wang <sean.wang@mediatek.com>
To: <john@phrozen.org>, <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sean Wang <sean.wang@mediatek.com>

Potential dangerous invalid memory might be accessed if invalid mac value
reflected from the forward port field in rxd4 caused by possible potential
hardware defects. So added a simple sanity checker to avoid the kind of
situation happening.

Signed-off-by: Sean Wang <sean.wang@mediatek.com>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index c1dc08c..8175433 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -999,6 +999,12 @@ static int mtk_poll_rx(struct napi_struct *napi, int budget,
 		      RX_DMA_FPORT_MASK;
 		mac--;
 
+		if (unlikely(mac < 0 || mac >= MTK_MAC_COUNT ||
+			     !eth->netdev[mac])) {
+			netdev->stats.rx_dropped++;
+			goto release_desc;
+		}
+
 		netdev = eth->netdev[mac];
 
 		if (unlikely(test_bit(MTK_RESETTING, &eth->state)))
-- 
2.7.4
