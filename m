From: Jonas Jensen <jonas.jensen@gmail.com>
Subject: [PATCH v6 3/4] net: moxa: synchronize DMA memory
Date: Mon, 25 Aug 2014 16:22:32 +0200
Message-ID: <1408976552-15659-1-git-send-email-jonas.jensen@gmail.com>
Cc: davem@davemloft.net, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org, f.fainelli@gmail.com,
	eric.dumazet@gmail.com, mirqus@gmail.com,
	Jonas Jensen <jonas.jensen@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

DMA memory should be synchronized before data is passed
to/from controller.

Add dma_sync_single_for_cpu(.., DMA_FROM_DEVICE) to RX path
and dma_sync_single_for_device(.., DMA_TO_DEVICE) to TX path.

Signed-off-by: Jonas Jensen <jonas.jensen@gmail.com>
---

Notes:
    Applies to next-20140825

 drivers/net/ethernet/moxa/moxart_ether.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/moxa/moxart_ether.c b/drivers/net/ethernet/moxa/moxart_ether.c
index d66058d..983d019 100644
--- a/drivers/net/ethernet/moxa/moxart_ether.c
+++ b/drivers/net/ethernet/moxa/moxart_ether.c
@@ -226,6 +226,9 @@ static int moxart_rx_poll(struct napi_struct *napi, int budget)
 		if (len > RX_BUF_SIZE)
 			len = RX_BUF_SIZE;
 
+		dma_sync_single_for_cpu(&ndev->dev,
+					priv->rx_mapping[rx_head],
+					priv->rx_buf_size, DMA_FROM_DEVICE);
 		skb = netdev_alloc_skb_ip_align(ndev, len);
 
 		if (unlikely(!skb)) {
@@ -348,6 +351,9 @@ static int moxart_mac_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 		len = ETH_ZLEN;
 	}
 
+	dma_sync_single_for_device(&ndev->dev, priv->tx_mapping[tx_head],
+				   priv->tx_buf_size, DMA_TO_DEVICE);
+
 	txdes1 = TX_DESC1_LTS | TX_DESC1_FTS | (len & TX_DESC1_BUF_SIZE_MASK);
 	if (tx_head == TX_DESC_NUM_MASK)
 		txdes1 |= TX_DESC1_END;
-- 
1.8.2.1
