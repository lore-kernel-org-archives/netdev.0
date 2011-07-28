From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 5/9] tg3: Add partial fragment unmapping code
Date: Wed, 27 Jul 2011 17:20:50 -0700
Message-ID: <1311812454-18197-6-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4051 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753282Ab1G1AR7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jul 2011 20:17:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following patches are going to break skb fragments into smaller
sizes.  This patch attempts to make the change easier to digest by only
addressing the skb teardown portion.

The patch modifies the driver to skip over any BDs that have a flag set
that indicates the BD isn't the beginning of an skb fragment.  Such BDs
were a result of segmentation and do not need a pci_unmap_page() call.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   26 ++++++++++++++++++++++++++
 drivers/net/tg3.h |    1 +
 2 files changed, 27 insertions(+), 0 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 3f69f1a..90b68a2 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -4840,6 +4840,12 @@ static void tg3_tx(struct tg3_napi *tnapi)
 
 		ri->skb = NULL;
 
+		while (ri->fragmented) {
+			ri->fragmented = false;
+			sw_idx = NEXT_TX(sw_idx);
+			ri = &tnapi->tx_buffers[sw_idx];
+		}
+
 		sw_idx = NEXT_TX(sw_idx);
 
 		for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
@@ -4851,6 +4857,13 @@ static void tg3_tx(struct tg3_napi *tnapi)
 				       dma_unmap_addr(ri, mapping),
 				       skb_shinfo(skb)->frags[i].size,
 				       PCI_DMA_TODEVICE);
+
+			while (ri->fragmented) {
+				ri->fragmented = false;
+				sw_idx = NEXT_TX(sw_idx);
+				ri = &tnapi->tx_buffers[sw_idx];
+			}
+
 			sw_idx = NEXT_TX(sw_idx);
 		}
 
@@ -5926,6 +5939,13 @@ static void tg3_tx_skb_unmap(struct tg3_napi *tnapi, u32 entry, int last)
 			 dma_unmap_addr(txb, mapping),
 			 skb_headlen(skb),
 			 PCI_DMA_TODEVICE);
+
+	while (txb->fragmented) {
+		txb->fragmented = false;
+		entry = NEXT_TX(entry);
+		txb = &tnapi->tx_buffers[entry];
+	}
+
 	for (i = 0; i < last; i++) {
 		skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 
@@ -5935,6 +5955,12 @@ static void tg3_tx_skb_unmap(struct tg3_napi *tnapi, u32 entry, int last)
 		pci_unmap_page(tnapi->tp->pdev,
 			       dma_unmap_addr(txb, mapping),
 			       frag->size, PCI_DMA_TODEVICE);
+
+		while (txb->fragmented) {
+			txb->fragmented = false;
+			entry = NEXT_TX(entry);
+			txb = &tnapi->tx_buffers[entry];
+		}
 	}
 }
 
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index f6986ca..466dd7a 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2655,6 +2655,7 @@ struct ring_info {
 struct tg3_tx_ring_info {
 	struct sk_buff			*skb;
 	DEFINE_DMA_UNMAP_ADDR(mapping);
+	bool				fragmented;
 };
 
 struct tg3_link_config {
-- 
1.7.3.4


