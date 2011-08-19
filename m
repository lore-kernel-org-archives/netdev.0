From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 36/75] myri10ge: convert to SKB paged frag API.
Date: Fri, 19 Aug 2011 14:27:08 +0100
Message-ID: <1313760467-8598-36-git-send-email-ian.campbell@citrix.com>
References: <1313760393.5010.356.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org,
	Ian Campbell <ian.campbell@citrix.com>,
	Jon Mason <mason@myri.com>, Andrew Gallatin <gallatin@myri.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:37564 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754848Ab1HSN3E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Aug 2011 09:29:04 -0400
In-Reply-To: <1313760393.5010.356.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: Jon Mason <mason@myri.com>
Cc: Andrew Gallatin <gallatin@myri.com>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
---
 drivers/net/myri10ge/myri10ge.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index 1d22475..8db4334 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -1342,7 +1342,7 @@ myri10ge_rx_done(struct myri10ge_slice_state *ss, int len, __wsum csum,
 	/* Fill skb_frag_struct(s) with data from our receive */
 	for (i = 0, remainder = len; remainder > 0; i++) {
 		myri10ge_unmap_rx_page(pdev, &rx->info[idx], bytes);
-		rx_frags[i].page = rx->info[idx].page;
+		__skb_frag_set_page(&rx_frags[i], rx->info[idx].page); /* XXX */
 		rx_frags[i].page_offset = rx->info[idx].page_offset;
 		if (remainder < MYRI10GE_ALLOC_SIZE)
 			rx_frags[i].size = remainder;
@@ -1375,7 +1375,7 @@ myri10ge_rx_done(struct myri10ge_slice_state *ss, int len, __wsum csum,
 		ss->stats.rx_dropped++;
 		do {
 			i--;
-			put_page(rx_frags[i].page);
+			__skb_frag_unref(&rx_frags[i]); /* XXX */
 		} while (i != 0);
 		return 0;
 	}
@@ -1383,7 +1383,7 @@ myri10ge_rx_done(struct myri10ge_slice_state *ss, int len, __wsum csum,
 	/* Attach the pages to the skb, and trim off any padding */
 	myri10ge_rx_skb_build(skb, va, rx_frags, len, hlen);
 	if (skb_shinfo(skb)->frags[0].size <= 0) {
-		put_page(skb_shinfo(skb)->frags[0].page);
+		skb_frag_unref(skb, 0);
 		skb_shinfo(skb)->nr_frags = 0;
 	}
 	skb->protocol = eth_type_trans(skb, dev);
@@ -2284,7 +2284,7 @@ myri10ge_get_frag_header(struct skb_frag_struct *frag, void **mac_hdr,
 	struct ethhdr *eh;
 	struct vlan_ethhdr *veh;
 	struct iphdr *iph;
-	u8 *va = page_address(frag->page) + frag->page_offset;
+	u8 *va = skb_frag_address(frag);
 	unsigned long ll_hlen;
 	/* passed opaque through lro_receive_frags() */
 	__wsum csum = (__force __wsum) (unsigned long)priv;
@@ -2927,8 +2927,8 @@ again:
 		frag = &skb_shinfo(skb)->frags[frag_idx];
 		frag_idx++;
 		len = frag->size;
-		bus = pci_map_page(mgp->pdev, frag->page, frag->page_offset,
-				   len, PCI_DMA_TODEVICE);
+		bus = skb_frag_dma_map(&mgp->pdev->dev, frag, 0, len,
+				       PCI_DMA_TODEVICE);
 		dma_unmap_addr_set(&tx->info[idx], bus, bus);
 		dma_unmap_len_set(&tx->info[idx], len, len);
 	}
-- 
1.7.2.5

