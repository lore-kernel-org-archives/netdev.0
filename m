From: Jonas Jensen <jonas.jensen@gmail.com>
Subject: [PATCH v5 2/2] net: moxa: replace build_skb() with netdev_alloc_skb_ip_align() / memcpy()
Date: Wed, 20 Aug 2014 16:19:02 +0200
Message-ID: <1408544342-32058-1-git-send-email-jonas.jensen@gmail.com>
References: <1408459784-9385-2-git-send-email-jonas.jensen@gmail.com>
Cc: davem@davemloft.net, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org, f.fainelli@gmail.com,
	eric.dumazet@gmail.com, Jonas Jensen <jonas.jensen@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1408459784-9385-2-git-send-email-jonas.jensen@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

build_skb() is used to make skbs out of existing RX ring memory
which is bad because the RX ring is allocated only once, on probe.
Memory corruption occur because said memory is reclaimed, i.e.
__kfree_skb() (and eventually put_page()).

Replace build_skb() with netdev_alloc_skb_ip_align(), use memcpy(),
and synchronize DMA memory before passing skb to napi_gro_receive().

Remove SKB_DATA_ALIGN() from RX buffer size while we're at it.

Addresses https://bugzilla.kernel.org/show_bug.cgi?id=69041

Signed-off-by: Jonas Jensen <jonas.jensen@gmail.com>
---

Notes:
    Changes since v4:
    
    1. remove SKB_DATA_ALIGN() from RX buffer size
    
    Applies to next-20140820

 drivers/net/ethernet/moxa/moxart_ether.c | 16 +++++++++++-----
 1 file changed, 11 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/moxa/moxart_ether.c b/drivers/net/ethernet/moxa/moxart_ether.c
index aa45607..06a6fce 100644
--- a/drivers/net/ethernet/moxa/moxart_ether.c
+++ b/drivers/net/ethernet/moxa/moxart_ether.c
@@ -226,14 +226,21 @@ static int moxart_rx_poll(struct napi_struct *napi, int budget)
 		if (len > RX_BUF_SIZE)
 			len = RX_BUF_SIZE;
 
-		skb = build_skb(priv->rx_buf[rx_head], priv->rx_buf_size);
+		dma_sync_single_for_cpu(&ndev->dev,
+					priv->rx_mapping[rx_head],
+					priv->rx_buf_size, DMA_FROM_DEVICE);
+		skb = netdev_alloc_skb_ip_align(ndev, len);
 		if (unlikely(!skb)) {
-			net_dbg_ratelimited("build_skb failed\n");
+			net_dbg_ratelimited("netdev_alloc_skb_ip_align failed\n");
 			priv->stats.rx_dropped++;
 			priv->stats.rx_errors++;
 		}
-
+		memcpy(skb->data, priv->rx_buf[rx_head], len);
 		skb_put(skb, len);
+		dma_sync_single_for_device(&ndev->dev,
+					   priv->rx_mapping[rx_head],
+					   priv->rx_buf_size, DMA_FROM_DEVICE);
+
 		skb->protocol = eth_type_trans(skb, ndev);
 		napi_gro_receive(&priv->napi, skb);
 		rx++;
@@ -466,8 +473,7 @@ static int moxart_mac_probe(struct platform_device *pdev)
 	spin_lock_init(&priv->txlock);
 
 	priv->tx_buf_size = TX_BUF_SIZE;
-	priv->rx_buf_size = RX_BUF_SIZE +
-			    SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
+	priv->rx_buf_size = RX_BUF_SIZE;
 
 	priv->tx_desc_base = dma_alloc_coherent(NULL, TX_REG_DESC_SIZE *
 						TX_DESC_NUM, &priv->tx_base,
-- 
1.8.2.1
