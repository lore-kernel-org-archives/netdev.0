From: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
Subject: [RFC][PATCH 2/2] bgmac: pass received packet to the netif instead of copying it
Date: Sun, 11 Aug 2013 19:49:15 +0200
Message-ID: <1376243355-5740-2-git-send-email-zajec5@gmail.com>
References: <1376243355-5740-1-git-send-email-zajec5@gmail.com>
Cc: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
To: netdev@vger.kernel.org, openwrt-devel@lists.openwrt.org,
	Hauke Mehrtens <hauke@hauke-m.de>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Jonas Gorski <jogo@openwrt.org>,
	Robert Bradley <robert.bradley1@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f53.google.com ([74.125.83.53]:35665 "EHLO
	mail-ee0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754357Ab3HKRtd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Aug 2013 13:49:33 -0400
Received: by mail-ee0-f53.google.com with SMTP id b15so3106160eek.12
        for <netdev@vger.kernel.org>; Sun, 11 Aug 2013 10:49:31 -0700 (PDT)
In-Reply-To: <1376243355-5740-1-git-send-email-zajec5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It makes more sense to allocate new (empty) skb and pass it to the
hardware. That way we avoid copying whole packet into new skb which
should result in better performance.
---
 drivers/net/ethernet/broadcom/bgmac.c |   74 ++++++++++++++++++++++++---------
 1 file changed, 54 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethernet/broadcom/bgmac.c
index e70ee43..425fe81 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -304,9 +304,9 @@ static int bgmac_dma_rx_read(struct bgmac *bgmac, struct bgmac_dma_ring *ring,
 		struct device *dma_dev = bgmac->core->dma_dev;
 		struct bgmac_slot_info *slot = &ring->slots[ring->start];
 		struct sk_buff *skb = slot->skb;
-		struct sk_buff *new_skb;
 		struct bgmac_rx_header *rx;
 		u16 len, flags;
+		bool resync_skb = true;
 
 		/* Unmap buffer to make it accessible to the CPU */
 		dma_sync_single_for_cpu(dma_dev, slot->dma_addr,
@@ -317,36 +317,70 @@ static int bgmac_dma_rx_read(struct bgmac *bgmac, struct bgmac_dma_ring *ring,
 		len = le16_to_cpu(rx->len);
 		flags = le16_to_cpu(rx->flags);
 
-		/* Check for poison and drop or pass the packet */
-		if (len == 0xdead && flags == 0xbeef) {
-			bgmac_err(bgmac, "Found poisoned packet at slot %d, DMA issue!\n",
-				  ring->start);
-		} else {
+		do {
+			/* Check for poisoned packet */
+			if (len == 0xdead && flags == 0xbeef) {
+				bgmac_err(bgmac, "Found poisoned packet at slot %d, DMA issue!\n",
+					  ring->start);
+				break;
+			}
+
 			/* Omit CRC. */
 			len -= ETH_FCS_LEN;
 
-			new_skb = netdev_alloc_skb_ip_align(bgmac->net_dev, len);
-			if (new_skb) {
+			/* Use skb_copy for small packets only */
+			if (len > 1) {
+				dma_addr_t old_dma_addr = slot->dma_addr;
+				int err;
+
+				/* Prepare new skb for further packets */
+				err = bgmac_dma_rx_skb_for_slot(bgmac, slot);
+				if (err) {
+					bgmac_err(bgmac, "Couldn't allocate new skb for slot %d!\n",
+						  ring->start);
+					bgmac->net_dev->stats.rx_dropped++;
+					break;
+				}
+				bgmac_dma_rx_setup_desc(bgmac, ring,
+							ring->start);
+
+				/* Unmap old skb, we'll pass it to the netfif */
+				dma_unmap_single(dma_dev, old_dma_addr,
+						 BGMAC_RX_BUF_SIZE,
+						 DMA_FROM_DEVICE);
+				resync_skb = false;
+
+				skb_put(skb, BGMAC_RX_FRAME_OFFSET + len);
+				skb_pull(skb, BGMAC_RX_FRAME_OFFSET);
+			} else {
+				struct sk_buff *new_skb;
+
+				/* Poison the old skb */
+				rx->len = cpu_to_le16(0xdead);
+				rx->flags = cpu_to_le16(0xbeef);
+
+				new_skb = netdev_alloc_skb_ip_align(bgmac->net_dev, len);
+				if (!new_skb) {
+					bgmac_err(bgmac, "Allocation of skb for copying packet failed!\n");
+					bgmac->net_dev->stats.rx_dropped++;
+					break;
+				}
+
 				skb_put(new_skb, len);
 				skb_copy_from_linear_data_offset(skb, BGMAC_RX_FRAME_OFFSET,
 								 new_skb->data,
 								 len);
-				skb_checksum_none_assert(skb);
-				new_skb->protocol =
-					eth_type_trans(new_skb, bgmac->net_dev);
-				netif_receive_skb(new_skb);
-				handled++;
-			} else {
-				bgmac->net_dev->stats.rx_dropped++;
-				bgmac_err(bgmac, "Allocation of skb for copying packet failed!\n");
+				skb = new_skb;
 			}
 
-			/* Poison the old skb */
-			rx->len = cpu_to_le16(0xdead);
-			rx->flags = cpu_to_le16(0xbeef);
-		}
+			skb_checksum_none_assert(skb);
+			skb->protocol = eth_type_trans(skb, bgmac->net_dev);
+			netif_receive_skb(skb);
+			handled++;
+		} while (0);
 
 		/* Make it back accessible to the hardware */
+		if (resync_skb)
 		dma_sync_single_for_device(dma_dev, slot->dma_addr,
 					   BGMAC_RX_BUF_SIZE, DMA_FROM_DEVICE);
 
-- 
1.7.10.4
