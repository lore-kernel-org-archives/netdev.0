From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 11/20] tg3: Make tg3_alloc_rx_skb() a dst-only operation
Date: Fri, 13 Nov 2009 15:03:43 -0800
Message-ID: <1258153432-7036-12-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net,
	"Matt Carlson" <mcarlson@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4225 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932465AbZKMXEW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Nov 2009 18:04:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes the source index parameter of tg3_alloc_rx_skb().  A
later patch will make it possible for the source and destination
producer rings to be different.  This patch opts to make
tg3_alloc_rx_skb() a destination-only implementation and move the code
sensitive to the difference elsewhere.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   22 +++++++++-------------
 1 files changed, 9 insertions(+), 13 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index f0360f8..ef64080 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -4409,7 +4409,7 @@ static void tg3_tx(struct tg3_napi *tnapi)
  * (to fetch the error flags, vlan tag, checksum, and opaque cookie).
  */
 static int tg3_alloc_rx_skb(struct tg3_napi *tnapi, u32 opaque_key,
-			    int src_idx, u32 dest_idx_unmasked)
+			    u32 dest_idx_unmasked)
 {
 	struct tg3 *tp = tnapi->tp;
 	struct tg3_rx_buffer_desc *desc;
@@ -4425,8 +4425,6 @@ static int tg3_alloc_rx_skb(struct tg3_napi *tnapi, u32 opaque_key,
 		dest_idx = dest_idx_unmasked % TG3_RX_RING_SIZE;
 		desc = &tpr->rx_std[dest_idx];
 		map = &tpr->rx_std_buffers[dest_idx];
-		if (src_idx >= 0)
-			src_map = &tpr->rx_std_buffers[src_idx];
 		skb_size = tp->rx_pkt_map_sz;
 		break;
 
@@ -4434,8 +4432,6 @@ static int tg3_alloc_rx_skb(struct tg3_napi *tnapi, u32 opaque_key,
 		dest_idx = dest_idx_unmasked % TG3_RX_JUMBO_RING_SIZE;
 		desc = &tpr->rx_jmb[dest_idx].std;
 		map = &tpr->rx_jmb_buffers[dest_idx];
-		if (src_idx >= 0)
-			src_map = &tpr->rx_jmb_buffers[src_idx];
 		skb_size = TG3_RX_JMB_MAP_SZ;
 		break;
 
@@ -4465,9 +4461,6 @@ static int tg3_alloc_rx_skb(struct tg3_napi *tnapi, u32 opaque_key,
 	map->skb = skb;
 	pci_unmap_addr_set(map, mapping, mapping);
 
-	if (src_map != NULL)
-		src_map->skb = NULL;
-
 	desc->addr_hi = ((u64)mapping >> 32);
 	desc->addr_lo = ((u64)mapping & 0xffffffff);
 
@@ -4559,6 +4552,7 @@ static int tg3_rx(struct tg3_napi *tnapi, int budget)
 	work_mask = 0;
 	received = 0;
 	while (sw_idx != hw_idx && budget > 0) {
+		struct ring_info *ri;
 		struct tg3_rx_buffer_desc *desc = &tnapi->rx_rcb[sw_idx];
 		unsigned int len;
 		struct sk_buff *skb;
@@ -4568,13 +4562,13 @@ static int tg3_rx(struct tg3_napi *tnapi, int budget)
 		desc_idx = desc->opaque & RXD_OPAQUE_INDEX_MASK;
 		opaque_key = desc->opaque & RXD_OPAQUE_RING_MASK;
 		if (opaque_key == RXD_OPAQUE_RING_STD) {
-			struct ring_info *ri = &tpr->rx_std_buffers[desc_idx];
+			ri = &tpr->rx_std_buffers[desc_idx];
 			dma_addr = pci_unmap_addr(ri, mapping);
 			skb = ri->skb;
 			post_ptr = &tpr->rx_std_ptr;
 			rx_std_posted++;
 		} else if (opaque_key == RXD_OPAQUE_RING_JUMBO) {
-			struct ring_info *ri = &tpr->rx_jmb_buffers[desc_idx];
+			ri = &tpr->rx_jmb_buffers[desc_idx];
 			dma_addr = pci_unmap_addr(ri, mapping);
 			skb = ri->skb;
 			post_ptr = &tpr->rx_jmb_ptr;
@@ -4607,10 +4601,12 @@ static int tg3_rx(struct tg3_napi *tnapi, int budget)
 			int skb_size;
 
 			skb_size = tg3_alloc_rx_skb(tnapi, opaque_key,
-						    desc_idx, *post_ptr);
+						    *post_ptr);
 			if (skb_size < 0)
 				goto drop_it;
 
+			ri->skb = NULL;
+
 			pci_unmap_single(tp->pdev, dma_addr, skb_size,
 					 PCI_DMA_FROMDEVICE);
 
@@ -5774,7 +5770,7 @@ static int tg3_rx_prodring_alloc(struct tg3 *tp,
 
 	/* Now allocate fresh SKBs for each rx ring. */
 	for (i = 0; i < tp->rx_pending; i++) {
-		if (tg3_alloc_rx_skb(tnapi, RXD_OPAQUE_RING_STD, -1, i) < 0) {
+		if (tg3_alloc_rx_skb(tnapi, RXD_OPAQUE_RING_STD, i) < 0) {
 			printk(KERN_WARNING PFX
 			       "%s: Using a smaller RX standard ring, "
 			       "only %d out of %d buffers were allocated "
@@ -5806,7 +5802,7 @@ static int tg3_rx_prodring_alloc(struct tg3 *tp,
 
 		for (i = 0; i < tp->rx_jumbo_pending; i++) {
 			if (tg3_alloc_rx_skb(tnapi, RXD_OPAQUE_RING_JUMBO,
-					     -1, i) < 0) {
+					     i) < 0) {
 				printk(KERN_WARNING PFX
 				       "%s: Using a smaller RX jumbo ring, "
 				       "only %d out of %d buffers were "
-- 
1.6.4.4


