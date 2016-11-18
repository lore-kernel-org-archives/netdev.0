From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Subject: [PATCH] net: macb: add check for dma mapping error in start_xmit()
Date: Sat, 19 Nov 2016 01:40:10 +0300
Message-ID: <1479508810-30476-1-git-send-email-khoroshilov@ispras.ru>
Cc: Alexey Khoroshilov <khoroshilov@ispras.ru>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: Nicolas Ferre <nicolas.ferre@atmel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

at91ether_start_xmit() does not check for dma mapping errors.

Found by Linux Driver Verification project (linuxtesting.org).

Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>
---
 drivers/net/ethernet/cadence/macb.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index b32444a3ed79..533653bd7aec 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -2673,6 +2673,12 @@ static int at91ether_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		lp->skb_length = skb->len;
 		lp->skb_physaddr = dma_map_single(NULL, skb->data, skb->len,
 							DMA_TO_DEVICE);
+		if (dma_mapping_error(NULL, lp->skb_physaddr)) {
+			dev_kfree_skb_any(skb);
+			dev->stats.tx_dropped++;
+			netdev_err(dev, "%s: DMA mapping error\n", __func__);
+			return NETDEV_TX_OK;
+		}
 
 		/* Set address of the data in the Transmit Address register */
 		macb_writel(lp, TAR, lp->skb_physaddr);
-- 
2.7.4
