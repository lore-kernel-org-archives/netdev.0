From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 04/11] r8169: fix DMA sync_single length error
Date: Wed, 20 Jan 2010 12:45:03 -0800
Message-ID: <20100120204559.039197464@vyatta.com>
References: <20100120204459.820265084@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Jarek Poplawski <jarkao2@gmail.com>,
	Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:53912 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754702Ab0ATVXH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jan 2010 16:23:07 -0500
Content-Disposition: inline; filename=r8169-dmar-error.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The DMA api requires that the full mapping be sync'd when
copying frame. First found by Jarek on sky2.

Get rid of unnecessary flag variable and move sync for
device to logical place next to sync_for_cpu

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/r8169.c	2010-01-20 10:12:22.488138228 -0800
+++ b/drivers/net/r8169.c	2010-01-20 10:15:21.199555458 -0800
@@ -4437,22 +4437,21 @@ static inline bool rtl8169_try_rx_copy(s
 				       dma_addr_t addr)
 {
 	struct sk_buff *skb;
-	bool done = false;
 
 	if (pkt_size >= rx_copybreak)
-		goto out;
+		return false;
 
 	skb = netdev_alloc_skb_ip_align(tp->dev, pkt_size);
 	if (!skb)
-		goto out;
+		return false;
 
-	pci_dma_sync_single_for_cpu(tp->pci_dev, addr, pkt_size,
+	pci_dma_sync_single_for_cpu(tp->pci_dev, addr, tp->rx_buf_sz,
 				    PCI_DMA_FROMDEVICE);
 	skb_copy_from_linear_data(*sk_buff, skb->data, pkt_size);
 	*sk_buff = skb;
-	done = true;
-out:
-	return done;
+	pci_dma_sync_single_for_device(tp->pci_dev, addr, tp->rx_buf_sz,
+				       PCI_DMA_FROMDEVICE);
+	return true;
 }
 
 static int rtl8169_rx_interrupt(struct net_device *dev,
@@ -4512,11 +4511,9 @@ static int rtl8169_rx_interrupt(struct n
 
 			rtl8169_rx_csum(skb, desc);
 
-			if (rtl8169_try_rx_copy(&skb, tp, pkt_size, addr)) {
-				pci_dma_sync_single_for_device(pdev, addr,
-					pkt_size, PCI_DMA_FROMDEVICE);
+			if (rtl8169_try_rx_copy(&skb, tp, pkt_size, addr))
 				rtl8169_mark_to_asic(desc, tp->rx_buf_sz);
-			} else {
+			else {
 				pci_unmap_single(pdev, addr, tp->rx_buf_sz,
 						 PCI_DMA_FROMDEVICE);
 				tp->Rx_skbuff[entry] = NULL;

-- 

