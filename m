From: Nathan Hintz <nlhintz@hotmail.com>
Subject: [PATCH] bgmac: don't update slot on skb alloc/dma mapping error
Date: Mon, 28 Oct 2013 23:44:28 -0700
Message-ID: <BLU0-SMTP119F7A71B34291D1CC2486BAC090@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: zajec5@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from blu0-omc1-s21.blu0.hotmail.com ([65.55.116.32]:37236 "EHLO
	blu0-omc1-s21.blu0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751261Ab3J2Guk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Oct 2013 02:50:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Don't update the slot in "bgmac_dma_rx_skb_for_slot" unless both the
skb alloc and dma mapping are successful; and free the newly allocated
skb if a dma mapping error occurs.  This will prevent an skb leak upon
returning when an error occurs.

Signed-off-by: Nathan Hintz <nlhintz@hotmail.com>
---
 drivers/net/ethernet/broadcom/bgmac.c | 20 ++++++++++++++------
 1 file changed, 14 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethernet/broadcom/bgmac.c
index 7eca5a1..11e5d8d 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -252,25 +252,33 @@ static int bgmac_dma_rx_skb_for_slot(struct bgmac *bgmac,
 				     struct bgmac_slot_info *slot)
 {
 	struct device *dma_dev = bgmac->core->dma_dev;
+	struct sk_buff *skb;
+	dma_addr_t dma_addr;
 	struct bgmac_rx_header *rx;
 
 	/* Alloc skb */
-	slot->skb = netdev_alloc_skb(bgmac->net_dev, BGMAC_RX_BUF_SIZE);
-	if (!slot->skb)
+	skb = netdev_alloc_skb(bgmac->net_dev, BGMAC_RX_BUF_SIZE);
+	if (!skb)
 		return -ENOMEM;
 
 	/* Poison - if everything goes fine, hardware will overwrite it */
-	rx = (struct bgmac_rx_header *)slot->skb->data;
+	rx = (struct bgmac_rx_header *)skb->data;
 	rx->len = cpu_to_le16(0xdead);
 	rx->flags = cpu_to_le16(0xbeef);
 
 	/* Map skb for the DMA */
-	slot->dma_addr = dma_map_single(dma_dev, slot->skb->data,
-					BGMAC_RX_BUF_SIZE, DMA_FROM_DEVICE);
-	if (dma_mapping_error(dma_dev, slot->dma_addr)) {
+	dma_addr = dma_map_single(dma_dev, skb->data,
+				  BGMAC_RX_BUF_SIZE, DMA_FROM_DEVICE);
+	if (dma_mapping_error(dma_dev, dma_addr)) {
 		bgmac_err(bgmac, "DMA mapping error\n");
+		dev_kfree_skb(skb);
 		return -ENOMEM;
 	}
+
+	/* Update the slot */
+	slot->skb = skb;
+	slot->dma_addr = dma_addr;
+
 	if (slot->dma_addr & 0xC0000000)
 		bgmac_warn(bgmac, "DMA address using 0xC0000000 bit(s), it may need translation trick\n");
 
-- 
1.8.3.1
