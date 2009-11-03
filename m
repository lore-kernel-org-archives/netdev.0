From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 06/20] tg3: Add more PCI DMA map error checking
Date: Mon, 2 Nov 2009 16:25:31 -0800
Message-ID: <1257211995.21998@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3429 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756401AbZKCBdT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Nov 2009 20:33:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds code to check the status of pci_map_single() before
allowing rx buffers to be used.  It also converts the pci_map_single()
call in tg3_run_loopback() to use skb_dma_map() instead.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/tg3.c |   14 +++++++++++---
 1 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 53a193e..54dbe98 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -4426,6 +4426,10 @@ static int tg3_alloc_rx_skb(struct tg3_napi *tnapi, u32 opaque_key,
 
 	mapping = pci_map_single(tp->pdev, skb->data, skb_size,
 				 PCI_DMA_FROMDEVICE);
+	if (pci_dma_mapping_error(tp->pdev, mapping)) {
+		dev_kfree_skb(skb);
+		return -EIO;
+	}
 
 	map->skb = skb;
 	pci_unmap_addr_set(map, mapping, mapping);
@@ -10369,7 +10373,10 @@ static int tg3_run_loopback(struct tg3 *tp, int loopback_mode)
 	for (i = 14; i < tx_len; i++)
 		tx_data[i] = (u8) (i & 0xff);
 
-	map = pci_map_single(tp->pdev, skb->data, tx_len, PCI_DMA_TODEVICE);
+	if (skb_dma_map(&tp->pdev->dev, skb, DMA_TO_DEVICE)) {
+		dev_kfree_skb(skb);
+		return -EIO;
+	}
 
 	tw32_f(HOSTCC_MODE, tp->coalesce_mode | HOSTCC_MODE_ENABLE |
 	       rnapi->coal_now);
@@ -10380,7 +10387,8 @@ static int tg3_run_loopback(struct tg3 *tp, int loopback_mode)
 
 	num_pkts = 0;
 
-	tg3_set_txd(tnapi, tnapi->tx_prod, map, tx_len, 0, 1);
+	tg3_set_txd(tnapi, tnapi->tx_prod,
+		    skb_shinfo(skb)->dma_head, tx_len, 0, 1);
 
 	tnapi->tx_prod++;
 	num_pkts++;
@@ -10404,7 +10412,7 @@ static int tg3_run_loopback(struct tg3 *tp, int loopback_mode)
 			break;
 	}
 
-	pci_unmap_single(tp->pdev, map, tx_len, PCI_DMA_TODEVICE);
+	skb_dma_unmap(&tp->pdev->dev, skb, DMA_TO_DEVICE);
 	dev_kfree_skb(skb);
 
 	if (tx_idx != tnapi->tx_prod)
-- 
1.6.4.4


