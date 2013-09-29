From: Hauke Mehrtens <hauke@hauke-m.de>
Subject: [PATCH v3] bgmac: add support for Byte Queue Limits
Date: Sun, 29 Sep 2013 13:54:58 +0200
Message-ID: <1380455698-5897-1-git-send-email-hauke@hauke-m.de>
Cc: zajec5@gmail.com, eric.dumazet@gmail.com, netdev@vger.kernel.org,
	Hauke Mehrtens <hauke@hauke-m.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from server19320154104.serverpool.info ([193.201.54.104]:46842 "EHLO
	hauke-m.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753209Ab3I2LzG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 29 Sep 2013 07:55:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This makes it possible to use some more advanced queuing
techniques with this driver.

When multi queue support will be added some changes to Byte Queue
handling is needed.

Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
---

v3: now netdev_sent_queue() is called after the descriptor is written 
to the memory, but before the hardware is told that there is a new 
descriptor, the package can not be dropped by the driver any more and 
netdev_completed_queue() have not been called for this skb, because the 
driver haven't told the hardware about this package yet.

 drivers/net/ethernet/broadcom/bgmac.c |   10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethernet/broadcom/bgmac.c
index 249468f..7eca5a1 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -149,6 +149,8 @@ static netdev_tx_t bgmac_dma_tx_add(struct bgmac *bgmac,
 	dma_desc->ctl0 = cpu_to_le32(ctl0);
 	dma_desc->ctl1 = cpu_to_le32(ctl1);
 
+	netdev_sent_queue(net_dev, skb->len);
+
 	wmb();
 
 	/* Increase ring->end to point empty slot. We tell hardware the first
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
