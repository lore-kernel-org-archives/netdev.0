From: Jonas Jensen <jonas.jensen@gmail.com>
Subject: [PATCH v4 2/2] net: moxa: replace build_skb() with netdev_alloc_skb_ip_align() / memcpy()
Date: Tue, 19 Aug 2014 16:49:44 +0200
Message-ID: <1408459784-9385-2-git-send-email-jonas.jensen@gmail.com>
References: <1408459784-9385-1-git-send-email-jonas.jensen@gmail.com>
Cc: davem@davemloft.net, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org, f.fainelli@gmail.com,
	bhutchings@solarflare.com, Jonas Jensen <jonas.jensen@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1408459784-9385-1-git-send-email-jonas.jensen@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

build_skb() is used to make skbs out of existing RX ring memory
which is bad because the RX ring is allocated only once, on probe.
Memory corruption occur because said memory is reclaimed, i.e.
__kfree_skb() (and eventually put_page()).

Replace build_skb() with netdev_alloc_skb_ip_align() and use memcpy().
Also, synchronize DMA memory before passing skb to napi_gro_receive().

Addresses https://bugzilla.kernel.org/show_bug.cgi?id=69041

Signed-off-by: Jonas Jensen <jonas.jensen@gmail.com>
---

Notes:
    The original motivation was to avoid memcpy(), since the memory is
    already allocated, why make a copy.
    
    Maybe the copy can be avoided updating RX ring descriptor addresses;
    new memory must be allocated just the same, the only difference that
    the controller could write directly to it.
    
    This fixes errors due to memory corruption, such as the following,
    seen on wget download (or ncftp):
    
    "read error: Bad address"
    
    On receiving error, wget exits without resuming (busybox default).
    
    Changes since v3:
    
    1. commit message reworded
    
    Applies to next-20140818

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
