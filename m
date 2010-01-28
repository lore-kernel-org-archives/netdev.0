From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH] sky2:  receive dma mapping error handling
Date: Thu, 28 Jan 2010 15:36:43 -0800
Message-ID: <20100128153643.0fca3c51@nehalam>
References: <4B60707F.1000608@majjas.com>
	<20100127095614.14313677@nehalam>
	<4B608128.7090607@majjas.com>
	<4B6089C7.4010803@majjas.com>
	<4B61ADF1.7060705@majjas.com>
	<4B61BEA4.1030905@majjas.com>
	<20100128090835.0d93e53a@nehalam>
	<4B61DB79.4080703@majjas.com>
	<20100128223447.GC3109@del.dom.local>
	<4B621316.8070308@majjas.com>
	<20100128225621.GD3109@del.dom.local>
	<4B6216B9.1010802@majjas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	flyboy@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Michael Chan <mchan@broadcom.com>,
	Don Fry <pcnet32@verizon.net>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Matt Carlson <mcarlson@broadcom.com>
To: Michael Breuer <mbreuer@majjas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:39038 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756499Ab0A1XiE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2010 18:38:04 -0500
In-Reply-To: <4B6216B9.1010802@majjas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please try this patch (and only this patch), on 2.6.33-rc5[*];
none of the other patches that did not make it upstream because that
confuses things too much.

The code that checks for DMA mapping errors on receive buffers would
not handle errors correctly.  I doubt you have these errors, but if you
did then it would explain the problems.  The code has to be a little
tricky and build mapping for new rx buffer before releasing old one,
that way if new mapping fails, the old one can be reused.

If it works for you, I will resubmit with signed-off.

---
* If you want to use DMA debugging, then you will also need the match patch.


--- a/drivers/net/sky2.c	2010-01-28 15:09:11.387649670 -0800
+++ b/drivers/net/sky2.c	2010-01-28 15:31:26.969181566 -0800
@@ -1106,18 +1106,39 @@ static int sky2_rx_map_skb(struct pci_de
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
@@ -2308,30 +2329,32 @@ static struct sk_buff *receive_new(struc
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



