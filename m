From: Hauke Mehrtens <hauke@hauke-m.de>
Subject: [PATCH] bgmac: add support for Byte Queue Limits
Date: Sat, 28 Sep 2013 23:23:13 +0200
Message-ID: <1380403393-12113-1-git-send-email-hauke@hauke-m.de>
Cc: zajec5@gmail.com, netdev@vger.kernel.org,
	Hauke Mehrtens <hauke@hauke-m.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from server19320154104.serverpool.info ([193.201.54.104]:45288 "EHLO
	hauke-m.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755096Ab3I1VXU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Sep 2013 17:23:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This makes it possible to use some more advanced queuing
techniques with this driver.

When multi queue support will be added some changes to Byte Queue
handling is needed.

Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
---
 drivers/net/ethernet/broadcom/bgmac.c |   10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethernet/broadcom/bgmac.c
index 249468f..80d4f52 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -178,6 +178,7 @@ static void bgmac_dma_tx_free(struct bgmac *bgmac, struct bgmac_dma_ring *ring)
 	struct device *dma_dev = bgmac->core->dma_dev;
 	int empty_slot;
 	bool freed = false;
+	unsigned bytes_compl = 0, pkts_compl = 0;
 
 	/* The last slot that hardware didn't consume yet */
 	empty_slot = bgmac_read(bgmac, ring->mmio_base + BGMAC_DMA_TX_STATUS);
@@ -195,6 +196,9 @@ static void bgmac_dma_tx_free(struct bgmac *bgmac, struct bgmac_dma_ring *ring)
 					 slot->skb->len, DMA_TO_DEVICE);
 			slot->dma_addr = 0;
 
+			bytes_compl += slot->skb->len;
+			pkts_compl++;
+
 			/* Free memory! :) */
 			dev_kfree_skb(slot->skb);
 			slot->skb = NULL;
@@ -208,6 +212,8 @@ static void bgmac_dma_tx_free(struct bgmac *bgmac, struct bgmac_dma_ring *ring)
 		freed = true;
 	}
 
+	netdev_completed_queue(bgmac->net_dev, pkts_compl, bytes_compl);
+
 	if (freed && netif_queue_stopped(bgmac->net_dev))
 		netif_wake_queue(bgmac->net_dev);
 }
@@ -988,6 +994,8 @@ static void bgmac_chip_reset(struct bgmac *bgmac)
 	bgmac_miiconfig(bgmac);
 	bgmac_phy_init(bgmac);
 
+	netdev_reset_queue(bgmac->net_dev);
+
 	bgmac->int_status = 0;
 }
 
@@ -1198,6 +1206,8 @@ static netdev_tx_t bgmac_start_xmit(struct sk_buff *skb,
 	struct bgmac *bgmac = netdev_priv(net_dev);
 	struct bgmac_dma_ring *ring;
 
+	netdev_sent_queue(net_dev, skb->len);
+
 	/* No QOS support yet */
 	ring = &bgmac->tx_ring[0];
 	return bgmac_dma_tx_add(bgmac, ring, skb);
-- 
1.7.10.4
