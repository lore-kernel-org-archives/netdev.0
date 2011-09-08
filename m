From: Daniel Hellstrom <daniel@gaisler.com>
Subject: [PATCH 1/2] GRETH: RX/TX bytes were never increased
Date: Thu,  8 Sep 2011 15:14:35 +0200
Message-ID: <1315487676-16733-1-git-send-email-daniel@gaisler.com>
Cc: netdev@vger.kernel.org, kristoffer@gaisler.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail201c2.megamailservers.com ([69.49.111.102]:48623 "EHLO
	mail201c2.megamailservers.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754359Ab1IHXCg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2011 19:02:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Daniel Hellstrom <daniel@gaisler.com>
---
 drivers/net/greth.c |    5 +++++
 drivers/net/greth.h |    1 +
 2 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/net/greth.c b/drivers/net/greth.c
index 672f096..9d39fb9 100644
--- a/drivers/net/greth.c
+++ b/drivers/net/greth.c
@@ -426,6 +426,7 @@ greth_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	dma_sync_single_for_device(greth->dev, dma_addr, skb->len, DMA_TO_DEVICE);
 
 	status = GRETH_BD_EN | GRETH_BD_IE | (skb->len & GRETH_BD_LEN);
+	greth->tx_bufs_length[greth->tx_next] = skb->len & GRETH_BD_LEN;
 
 	/* Wrap around descriptor ring */
 	if (greth->tx_next == GRETH_TXBD_NUM_MASK) {
@@ -639,6 +640,7 @@ static void greth_clean_tx(struct net_device *dev)
 				dev->stats.tx_fifo_errors++;
 		}
 		dev->stats.tx_packets++;
+		dev->stats.tx_bytes += greth->tx_bufs_length[greth->tx_last];
 		greth->tx_last = NEXT_TX(greth->tx_last);
 		greth->tx_free++;
 	}
@@ -693,6 +695,7 @@ static void greth_clean_tx_gbit(struct net_device *dev)
 		greth->tx_skbuff[greth->tx_last] = NULL;
 
 		greth_update_tx_stats(dev, stat);
+		dev->stats.tx_bytes += skb->len;
 
 		bdp = greth->tx_bd_base + greth->tx_last;
 
@@ -794,6 +797,7 @@ static int greth_rx(struct net_device *dev, int limit)
 				memcpy(skb_put(skb, pkt_len), phys_to_virt(dma_addr), pkt_len);
 
 				skb->protocol = eth_type_trans(skb, dev);
+				dev->stats.rx_bytes += pkt_len;
 				dev->stats.rx_packets++;
 				netif_receive_skb(skb);
 			}
@@ -908,6 +912,7 @@ static int greth_rx_gbit(struct net_device *dev, int limit)
 
 				skb->protocol = eth_type_trans(skb, dev);
 				dev->stats.rx_packets++;
+				dev->stats.rx_bytes += pkt_len;
 				netif_receive_skb(skb);
 
 				greth->rx_skbuff[greth->rx_cur] = newskb;
diff --git a/drivers/net/greth.h b/drivers/net/greth.h
index 9a0040d..232a622 100644
--- a/drivers/net/greth.h
+++ b/drivers/net/greth.h
@@ -103,6 +103,7 @@ struct greth_private {
 
 	unsigned char *tx_bufs[GRETH_TXBD_NUM];
 	unsigned char *rx_bufs[GRETH_RXBD_NUM];
+	u16 tx_bufs_length[GRETH_TXBD_NUM];
 
 	u16 tx_next;
 	u16 tx_last;
-- 
1.5.4
