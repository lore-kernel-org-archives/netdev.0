From: Jonas Jensen <jonas.jensen@gmail.com>
Subject: [PATCH v3 2/7] net: moxa: fix build_skb() memory corruption
Date: Mon, 20 Jan 2014 12:13:14 +0100
Message-ID: <1390216399-27028-2-git-send-email-jonas.jensen@gmail.com>
References: <1390216399-27028-1-git-send-email-jonas.jensen@gmail.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, f.fainelli@gmail.com,
	bhutchings@solarflare.com, Jonas Jensen <jonas.jensen@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1390216399-27028-1-git-send-email-jonas.jensen@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

DMA buffer memory must be synchronized and copied before passing skb to
napi_gro_receive(). The use of build_skb() can lead to memory corruption,
replace it with netdev_alloc_skb_ip_align() and memcpy().

Addresses https://bugzilla.kernel.org/show_bug.cgi?id=69041

Signed-off-by: Jonas Jensen <jonas.jensen@gmail.com>
---

Notes:
    This fixes the following error on wget download (or ncftp),
    usually after only a few seconds:
    
    "read error: Bad address"
    
    On receiving this error, wget exits. The download is not resumed (busybox default).
    
    Applies to next-20140120

 drivers/net/ethernet/moxa/moxart_ether.c | 13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/moxa/moxart_ether.c b/drivers/net/ethernet/moxa/moxart_ether.c
index aa45607..17c9f0e 100644
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
-- 
1.8.2.1
