From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 09/14] cassini: convert to SKB paged frag API.
Date: Tue, 30 Aug 2011 10:18:25 +0100
Message-ID: <1314695910-22344-9-git-send-email-ian.campbell@citrix.com>
References: <1314695847.10283.102.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ian Campbell <ian.campbell@citrix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:34590 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752829Ab1H3JSp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2011 05:18:45 -0400
In-Reply-To: <1314695847.10283.102.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: netdev@vger.kernel.org
---
 drivers/net/ethernet/sun/cassini.c |   15 +++++++--------
 1 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/sun/cassini.c b/drivers/net/ethernet/sun/cassini.c
index 1776a37..f07a721 100644
--- a/drivers/net/ethernet/sun/cassini.c
+++ b/drivers/net/ethernet/sun/cassini.c
@@ -2048,8 +2048,8 @@ static int cas_rx_process_pkt(struct cas *cp, struct cas_rx_comp *rxc,
 		skb->truesize += hlen - swivel;
 		skb->len      += hlen - swivel;
 
-		get_page(page->buffer);
-		frag->page = page->buffer;
+		__skb_frag_set_page(frag, page->buffer);
+		__skb_frag_ref(frag);
 		frag->page_offset = off;
 		frag->size = hlen - swivel;
 
@@ -2072,8 +2072,8 @@ static int cas_rx_process_pkt(struct cas *cp, struct cas_rx_comp *rxc,
 			skb->len      += hlen;
 			frag++;
 
-			get_page(page->buffer);
-			frag->page = page->buffer;
+			__skb_frag_set_page(frag, page->buffer);
+			__skb_frag_ref(frag);
 			frag->page_offset = 0;
 			frag->size = hlen;
 			RX_USED_ADD(page, hlen + cp->crc_size);
@@ -2830,9 +2830,8 @@ static inline int cas_xmit_tx_ringN(struct cas *cp, int ring,
 		skb_frag_t *fragp = &skb_shinfo(skb)->frags[frag];
 
 		len = fragp->size;
-		mapping = pci_map_page(cp->pdev, fragp->page,
-				       fragp->page_offset, len,
-				       PCI_DMA_TODEVICE);
+		mapping = skb_frag_dma_map(&cp->pdev->dev, fragp, 0, len,
+					   PCI_DMA_TODEVICE);
 
 		tabort = cas_calc_tabort(cp, fragp->page_offset, len);
 		if (unlikely(tabort)) {
@@ -2843,7 +2842,7 @@ static inline int cas_xmit_tx_ringN(struct cas *cp, int ring,
 				      ctrl, 0);
 			entry = TX_DESC_NEXT(ring, entry);
 
-			addr = cas_page_map(fragp->page);
+			addr = cas_page_map(skb_frag_page(fragp));
 			memcpy(tx_tiny_buf(cp, ring, entry),
 			       addr + fragp->page_offset + len - tabort,
 			       tabort);
-- 
1.7.2.5
