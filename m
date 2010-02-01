From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 2/2] sky2: hand receive DMA mapping failures
Date: Mon, 1 Feb 2010 15:45:41 -0800
Message-ID: <20100201154541.6e3b9a17@nehalam>
References: <20100201154147.5bb0b2c7@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Jarek Poplawski <jarkao2@gmail.com>,
	Michael Breuer <mbreuer@majjas.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:48830 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753283Ab0BAXpx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Feb 2010 18:45:53 -0500
In-Reply-To: <20100201154147.5bb0b2c7@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If receive buffer mapping failed, then it was possible to get
stuck with unmapped receive buffer in DMA ring. 

This would be an extremely rare condition because the driver had just
released the map for the last receive so it should be able to get
another map again (in soft-irq).

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
Patch is against net-next. Not worth the risk for 2.6.33 or stable


--- a/drivers/net/sky2.c	2010-02-01 10:18:12.575044064 -0800
+++ b/drivers/net/sky2.c	2010-02-01 10:18:16.975356378 -0800
@@ -1103,18 +1103,39 @@ static int sky2_rx_map_skb(struct pci_de
 	int i;
 
 	re->data_addr = pci_map_single(pdev, skb->data, size, PCI_DMA_FROMDEVICE);
-	if (unlikely(pci_dma_mapping_error(pdev, re->data_addr)))
-		return -EIO;
+	if (pci_dma_mapping_error(pdev, re->data_addr))
+		goto mapping_error;
 
 	pci_unmap_len_set(re, data_size, size);
 
-	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++)
-		re->frag_addr[i] = pci_map_page(pdev,
-						skb_shinfo(skb)->frags[i].page,
-						skb_shinfo(skb)->frags[i].page_offset,
-						skb_shinfo(skb)->frags[i].size,
+	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
+		skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
+
+		re->frag_addr[i] = pci_map_page(pdev, frag->page,
+						frag->page_offset,
+						frag->size,
 						PCI_DMA_FROMDEVICE);
+
+		if (pci_dma_mapping_error(pdev, re->frag_addr[i]))
+			goto map_page_error;
+	}
 	return 0;
+
+map_page_error:
+	while (--i >= 0) {
+		pci_unmap_page(pdev, re->frag_addr[i],
+			       skb_shinfo(skb)->frags[i].size,
+			       PCI_DMA_FROMDEVICE);
+	}
+
+	pci_unmap_single(pdev, re->data_addr, pci_unmap_len(re, data_size),
+			 PCI_DMA_FROMDEVICE);
+
+mapping_error:
+	if (net_ratelimit())
+		dev_warn(&pdev->dev, "%s: rx mapping error\n",
+			 skb->dev->name);
+	return -EIO;
 }
 
 static void sky2_rx_unmap_skb(struct pci_dev *pdev, struct rx_ring_info *re)
@@ -2306,30 +2327,32 @@ static struct sk_buff *receive_new(struc
 				   struct rx_ring_info *re,
 				   unsigned int length)
 {
-	struct sk_buff *skb, *nskb;
+	struct sk_buff *skb;
+	struct rx_ring_info nre;
 	unsigned hdr_space = sky2->rx_data_size;
 
-	/* Don't be tricky about reusing pages (yet) */
-	nskb = sky2_rx_alloc(sky2);
-	if (unlikely(!nskb))
-		return NULL;
+	nre.skb = sky2_rx_alloc(sky2);
+	if (unlikely(!nre.skb))
+		goto nobuf;
+
+	if (sky2_rx_map_skb(sky2->hw->pdev, &nre, hdr_space))
+		goto nomap;
 
 	skb = re->skb;
 	sky2_rx_unmap_skb(sky2->hw->pdev, re);
-
 	prefetch(skb->data);
-	re->skb = nskb;
-	if (sky2_rx_map_skb(sky2->hw->pdev, re, hdr_space)) {
-		dev_kfree_skb(nskb);
-		re->skb = skb;
-		return NULL;
-	}
+	*re = nre;
 
 	if (skb_shinfo(skb)->nr_frags)
 		skb_put_frags(skb, hdr_space, length);
 	else
 		skb_put(skb, length);
 	return skb;
+
+nomap:
+	dev_kfree_skb(nre.skb);
+nobuf:
+	return NULL;
 }
 
 /*
