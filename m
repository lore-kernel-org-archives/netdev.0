From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 3/3] bgmac: Maintain some netdev statistics
Date: Tue,  7 Jun 2016 15:06:15 -0700
Message-ID: <1465337175-22368-4-git-send-email-f.fainelli@gmail.com>
References: <1465337175-22368-1-git-send-email-f.fainelli@gmail.com>
Cc: ben@decadent.org.uk, zajec5@gmail.com, hauke@hauke-m.de,
	jon.mason@broadcom.com, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34783 "EHLO
	mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754645AbcFGWG2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2016 18:06:28 -0400
Received: by mail-pf0-f194.google.com with SMTP id l188so4608132pfl.1
        for <netdev@vger.kernel.org>; Tue, 07 Jun 2016 15:06:28 -0700 (PDT)
In-Reply-To: <1465337175-22368-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a few netdev statistics to report transmitted and received bytes and
packets and a few obvious errors.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/bgmac.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethernet/broadcom/bgmac.c
index 133bf64c7a8b..0ee34cc96bc9 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -246,6 +246,8 @@ err_dma_head:
 
 err_drop:
 	dev_kfree_skb(skb);
+	net_dev->stats.tx_dropped++;
+	net_dev->stats.tx_errors++;
 	return NETDEV_TX_OK;
 }
 
@@ -284,6 +286,8 @@ static void bgmac_dma_tx_free(struct bgmac *bgmac, struct bgmac_dma_ring *ring)
 				       DMA_TO_DEVICE);
 
 		if (slot->skb) {
+			bgmac->net_dev->stats.tx_bytes += slot->skb->len;
+			bgmac->net_dev->stats.tx_packets++;
 			bytes_compl += slot->skb->len;
 			pkts_compl++;
 
@@ -464,6 +468,7 @@ static int bgmac_dma_rx_read(struct bgmac *bgmac, struct bgmac_dma_ring *ring,
 				bgmac_err(bgmac, "Found poisoned packet at slot %d, DMA issue!\n",
 					  ring->start);
 				put_page(virt_to_head_page(buf));
+				bgmac->net_dev->stats.rx_errors++;
 				break;
 			}
 
@@ -471,6 +476,8 @@ static int bgmac_dma_rx_read(struct bgmac *bgmac, struct bgmac_dma_ring *ring,
 				bgmac_err(bgmac, "Found oversized packet at slot %d, DMA issue!\n",
 					  ring->start);
 				put_page(virt_to_head_page(buf));
+				bgmac->net_dev->stats.rx_length_errors++;
+				bgmac->net_dev->stats.rx_errors++;
 				break;
 			}
 
@@ -481,6 +488,7 @@ static int bgmac_dma_rx_read(struct bgmac *bgmac, struct bgmac_dma_ring *ring,
 			if (unlikely(!skb)) {
 				bgmac_err(bgmac, "build_skb failed\n");
 				put_page(virt_to_head_page(buf));
+				bgmac->net_dev->stats.rx_errors++;
 				break;
 			}
 			skb_put(skb, BGMAC_RX_FRAME_OFFSET +
@@ -490,6 +498,8 @@ static int bgmac_dma_rx_read(struct bgmac *bgmac, struct bgmac_dma_ring *ring,
 
 			skb_checksum_none_assert(skb);
 			skb->protocol = eth_type_trans(skb, bgmac->net_dev);
+			bgmac->net_dev->stats.rx_bytes += len;
+			bgmac->net_dev->stats.rx_packets++;
 			napi_gro_receive(&bgmac->napi, skb);
 			handled++;
 		} while (0);
-- 
2.7.4
