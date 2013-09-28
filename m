From: Hauke Mehrtens <hauke@hauke-m.de>
Subject: [PATCH v2] bgmac: add support for Byte Queue Limits
Date: Sun, 29 Sep 2013 00:35:26 +0200
Message-ID: <1380407726-20691-1-git-send-email-hauke@hauke-m.de>
Cc: zajec5@gmail.com, eric.dumazet@gmail.com, netdev@vger.kernel.org,
	Hauke Mehrtens <hauke@hauke-m.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from server19320154104.serverpool.info ([193.201.54.104]:45430 "EHLO
	hauke-m.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755152Ab3I1Wfh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Sep 2013 18:35:37 -0400
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
index 249468f..e5519f1 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -164,6 +164,8 @@ static netdev_tx_t bgmac_dma_tx_add(struct bgmac *bgmac,
 	if (--free_slots == 1)
 		netif_stop_queue(net_dev);
 
+	netdev_sent_queue(net_dev, skb->len);
+
 	return NETDEV_TX_OK;
 
 err_stop_drop:
@@ -178,6 +180,7 @@ static void bgmac_dma_tx_free(struct bgmac *bgmac, struct bgmac_dma_ring *ring)
 	struct device *dma_dev = bgmac->core->dma_dev;
 	int empty_slot;
 	bool freed = false;
+	unsigned bytes_compl = 0, pkts_compl = 0;
 
 	/* The last slot that hardware didn't consume yet */
 	empty_slot = bgmac_read(bgmac, ring->mmio_base + BGMAC_DMA_TX_STATUS);
@@ -195,6 +198,9 @@ static void bgmac_dma_tx_free(struct bgmac *bgmac, struct bgmac_dma_ring *ring)
 					 slot->skb->len, DMA_TO_DEVICE);
 			slot->dma_addr = 0;
 
+			bytes_compl += slot->skb->len;
+			pkts_compl++;
+
 			/* Free memory! :) */
 			dev_kfree_skb(slot->skb);
 			slot->skb = NULL;
@@ -208,6 +214,8 @@ static void bgmac_dma_tx_free(struct bgmac *bgmac, struct bgmac_dma_ring *ring)
 		freed = true;
 	}
 
+	netdev_completed_queue(bgmac->net_dev, pkts_compl, bytes_compl);
+
 	if (freed && netif_queue_stopped(bgmac->net_dev))
 		netif_wake_queue(bgmac->net_dev);
 }
@@ -988,6 +996,8 @@ static void bgmac_chip_reset(struct bgmac *bgmac)
 	bgmac_miiconfig(bgmac);
 	bgmac_phy_init(bgmac);
 
+	netdev_reset_queue(bgmac->net_dev);
+
 	bgmac->int_status = 0;
 }
 
-- 
1.7.10.4
