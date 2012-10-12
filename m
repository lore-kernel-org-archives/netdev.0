From: Rob Herring <robherring2@gmail.com>
Subject: [PATCH 6/6] net: calxedaxgmac: ip align receive buffers
Date: Fri, 12 Oct 2012 10:15:08 -0500
Message-ID: <1350054908-30646-7-git-send-email-robherring2@gmail.com>
References: <1350054908-30646-1-git-send-email-robherring2@gmail.com>
Cc: jonathan@jonmasters.org, eric.dumazet@gmail.com,
	Mark Langsdorf <mark.langsdorf@calxeda.com>,
	Rob Herring <rob.herring@calxeda.com>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1350054908-30646-1-git-send-email-robherring2@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rob Herring <rob.herring@calxeda.com>

On gcc 4.7, we will get alignment traps in the ip stack if we don't align
the ip headers on receive. The h/w can support this, so use ip aligned
allocations.

Cut down the unnecessary padding on the allocation. The buffer can start on
any byte alignment, but the size including the begining offset must be 8
byte aligned. So the h/w buffer size must include the NET_IP_ALIGN offset.

Thanks to Eric Dumazet for the initial patch highlighting the padding issues.

Signed-off-by: Rob Herring <rob.herring@calxeda.com>
---
 drivers/net/ethernet/calxeda/xgmac.c |   11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/calxeda/xgmac.c b/drivers/net/ethernet/calxeda/xgmac.c
index 5cb10b6..3cc19c9 100644
--- a/drivers/net/ethernet/calxeda/xgmac.c
+++ b/drivers/net/ethernet/calxeda/xgmac.c
@@ -665,6 +665,7 @@ static void xgmac_rx_refill(struct xgmac_priv *priv)
 {
 	struct xgmac_dma_desc *p;
 	dma_addr_t paddr;
+	int bufsz = priv->dev->mtu + ETH_HLEN + ETH_FCS_LEN;
 
 	while (dma_ring_space(priv->rx_head, priv->rx_tail, DMA_RX_RING_SZ) > 1) {
 		int entry = priv->rx_head;
@@ -673,13 +674,13 @@ static void xgmac_rx_refill(struct xgmac_priv *priv)
 		p = priv->dma_rx + entry;
 
 		if (priv->rx_skbuff[entry] == NULL) {
-			skb = netdev_alloc_skb(priv->dev, priv->dma_buf_sz);
+			skb = netdev_alloc_skb_ip_align(priv->dev, bufsz);
 			if (unlikely(skb == NULL))
 				break;
 
 			priv->rx_skbuff[entry] = skb;
 			paddr = dma_map_single(priv->device, skb->data,
-					       priv->dma_buf_sz, DMA_FROM_DEVICE);
+					       bufsz, DMA_FROM_DEVICE);
 			desc_set_buf_addr(p, paddr, priv->dma_buf_sz);
 		}
 
@@ -703,10 +704,10 @@ static int xgmac_dma_desc_rings_init(struct net_device *dev)
 	unsigned int bfsize;
 
 	/* Set the Buffer size according to the MTU;
-	 * indeed, in case of jumbo we need to bump-up the buffer sizes.
+	 * The total buffer size including any IP offset must be a multiple
+	 * of 8 bytes.
 	 */
-	bfsize = ALIGN(dev->mtu + ETH_HLEN + ETH_FCS_LEN + NET_IP_ALIGN + 64,
-		       64);
+	bfsize = ALIGN(dev->mtu + ETH_HLEN + ETH_FCS_LEN + NET_IP_ALIGN, 8);
 
 	netdev_dbg(priv->dev, "mtu [%d] bfsize [%d]\n", dev->mtu, bfsize);
 
-- 
1.7.9.5
