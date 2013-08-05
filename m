From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net] skge: fix build on 32 bit
Date: Sun, 4 Aug 2013 20:40:34 -0700
Message-ID: <20130804204034.0f96cb80@nehalam.linuxnetplumber.net>
References: <20130804172234.345913ae@nehalam.linuxnetplumber.net>
	<20130804.183553.514470399074672614.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:43006 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754582Ab3HEDkj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Aug 2013 23:40:39 -0400
Received: by mail-pa0-f42.google.com with SMTP id lj1so2768110pab.29
        for <netdev@vger.kernel.org>; Sun, 04 Aug 2013 20:40:39 -0700 (PDT)
In-Reply-To: <20130804.183553.514470399074672614.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following is needed as well to fix warning/error about shifting a 32 bit
value 32 bits which occurs if building on 32 bit platform caused by conversion
to using dma_addr_t

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

--- a/drivers/net/ethernet/marvell/skge.c	2013-08-04 20:30:57.003636568 -0700
+++ b/drivers/net/ethernet/marvell/skge.c	2013-08-04 20:34:43.104589097 -0700
@@ -943,8 +943,8 @@ static int skge_rx_setup(struct skge_por
 	if (pci_dma_mapping_error(skge->hw->pdev, map))
 		return -1;
 
-	rd->dma_lo = map;
-	rd->dma_hi = map >> 32;
+	rd->dma_lo = lower_32_bits(map);
+	rd->dma_hi = upper_32_bits(map);
 	e->skb = skb;
 	rd->csum1_start = ETH_HLEN;
 	rd->csum2_start = ETH_HLEN;
@@ -2551,7 +2551,7 @@ static int skge_up(struct net_device *de
 
 	BUG_ON(skge->dma & 7);
 
-	if ((u64)skge->dma >> 32 != ((u64) skge->dma + skge->mem_size) >> 32) {
+	if (upper_32_bits(skge->dma) != upper_32_bits(skge->dma + skge->mem_size)) {
 		dev_err(&hw->pdev->dev, "pci_alloc_consistent region crosses 4G boundary\n");
 		err = -EINVAL;
 		goto free_pci_mem;
@@ -2756,8 +2756,8 @@ static netdev_tx_t skge_xmit_frame(struc
 	dma_unmap_addr_set(e, mapaddr, map);
 	dma_unmap_len_set(e, maplen, len);
 
-	td->dma_lo = map;
-	td->dma_hi = map >> 32;
+	td->dma_lo = lower_32_bits(map);
+	td->dma_hi = upper_32_bits(map);
 
 	if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		const int offset = skb_checksum_start_offset(skb);
@@ -2796,8 +2796,8 @@ static netdev_tx_t skge_xmit_frame(struc
 			tf = e->desc;
 			BUG_ON(tf->control & BMU_OWN);
 
-			tf->dma_lo = map;
-			tf->dma_hi = (u64) map >> 32;
+			tf->dma_lo = lower_32_bits(map);
+			tf->dma_hi = upper_32_bits(map);
 			dma_unmap_addr_set(e, mapaddr, map);
 			dma_unmap_len_set(e, maplen, skb_frag_size(frag));
 
