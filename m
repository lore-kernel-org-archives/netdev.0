From: John Crispin <john@phrozen.org>
Subject: [RFC 2/2] net-next: mediatek: populate the shared
Date: Fri, 21 Jul 2017 17:20:35 +0200
Message-ID: <20170721152035.6645-3-john@phrozen.org>
References: <20170721152035.6645-1-john@phrozen.org>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        John Crispin <john@phrozen.org>
To: "David S . Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170721152035.6645-1-john@phrozen.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When enabling HW flow offloading, the traffic coming in on either of the
GMACs is first sent to the PPE for processing. Any traffic not offloaded
at this point will then be forwarded to the normal RX DMA ring for SW path
processing. In this case the PPE will send additional data inside RXD4
that is later required by the upper layers to populate the flow offloading
engines HW tables properly. This patch sets the skb_shared_info's dma_desc
field so that we can use the value later on.

Signed-off-by: John Crispin <john@phrozen.org>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index a455d1b4f1d8..42d162cd6363 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -918,6 +918,7 @@ static void mtk_update_rx_cpu_idx(struct mtk_eth *eth)
 static int mtk_poll_rx(struct napi_struct *napi, int budget,
 		       struct mtk_eth *eth)
 {
+	struct skb_shared_info *sh;
 	struct mtk_rx_ring *ring;
 	int idx;
 	struct sk_buff *skb;
@@ -1000,6 +1001,9 @@ static int mtk_poll_rx(struct napi_struct *napi, int budget,
 		else
 			skb_checksum_none_assert(skb);
 		skb->protocol = eth_type_trans(skb, netdev);
+		sh = skb_shinfo(skb);
+
+		sh->dma_desc = trxd.rxd4;
 
 		if (netdev->features & NETIF_F_HW_VLAN_CTAG_RX &&
 		    RX_DMA_VID(trxd.rxd3))
-- 
2.11.0
