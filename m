From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 04/21] r8169: Rx path update
Date: Fri, 29 Jun 2007 22:18:29 +0200
Message-ID: <20070629201829.GF3240@electric-eye.fr.zoreil.com>
References: <20070629201212.GA3240@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Edward Hsu <edward_hsu@realtek.com.tw>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:35052 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753219AbXF2UUi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jun 2007 16:20:38 -0400
Content-Disposition: inline
In-Reply-To: <20070629201212.GA3240@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

- pci_dma_sync_single_for_cpu is not needed for a single large packet
- remove the function pointer to help gcc optimizing the inline
  pci_dma functions.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Edward Hsu <edward_hsu@realtek.com.tw>
---
 drivers/net/r8169.c |   56 +++++++++++++++++++++++++-------------------------
 1 files changed, 28 insertions(+), 28 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index e4827a4..4d0cdba 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -2483,25 +2483,27 @@ static inline void rtl8169_rx_csum(struct sk_buff *skb, struct RxDesc *desc)
 		skb->ip_summed = CHECKSUM_NONE;
 }
 
-static inline int rtl8169_try_rx_copy(struct sk_buff **sk_buff, int pkt_size,
-				      struct RxDesc *desc, int rx_buf_sz,
-				      unsigned int align)
+static inline bool rtl8169_try_rx_copy(struct sk_buff **sk_buff, int pkt_size,
+				       struct pci_dev *pdev, dma_addr_t addr,
+				       unsigned int align)
 {
-	int ret = -1;
+	struct sk_buff *skb;
+	bool done = false;
 
-	if (pkt_size < rx_copybreak) {
-		struct sk_buff *skb;
+	if (pkt_size >= rx_copybreak)
+		goto out;
 
-		skb = dev_alloc_skb(pkt_size + align);
-		if (skb) {
-			skb_reserve(skb, (align - 1) & (unsigned long)skb->data);
-			skb_copy_from_linear_data(*sk_buff, skb->data, pkt_size);
-			*sk_buff = skb;
-			rtl8169_mark_to_asic(desc, rx_buf_sz);
-			ret = 0;
-		}
-	}
-	return ret;
+	skb = dev_alloc_skb(pkt_size + align);
+	if (!skb)
+		goto out;
+
+	pci_dma_sync_single_for_cpu(pdev, addr, pkt_size, PCI_DMA_FROMDEVICE);
+	skb_reserve(skb, (align - 1) & (unsigned long)skb->data);
+	skb_copy_from_linear_data(*sk_buff, skb->data, pkt_size);
+	*sk_buff = skb;
+	done = true;
+out:
+	return done;
 }
 
 static int
@@ -2547,9 +2549,9 @@ rtl8169_rx_interrupt(struct net_device *dev, struct rtl8169_private *tp,
 			rtl8169_mark_to_asic(desc, tp->rx_buf_sz);
 		} else {
 			struct sk_buff *skb = tp->Rx_skbuff[entry];
+			dma_addr_t addr = le64_to_cpu(desc->addr);
 			int pkt_size = (status & 0x00001FFF) - 4;
-			void (*pci_action)(struct pci_dev *, dma_addr_t,
-				size_t, int) = pci_dma_sync_single_for_device;
+			struct pci_dev *pdev = tp->pci_dev;
 
 			/*
 			 * The driver does not support incoming fragmented
@@ -2565,19 +2567,17 @@ rtl8169_rx_interrupt(struct net_device *dev, struct rtl8169_private *tp,
 
 			rtl8169_rx_csum(skb, desc);
 
-			pci_dma_sync_single_for_cpu(tp->pci_dev,
-				le64_to_cpu(desc->addr), tp->rx_buf_sz,
-				PCI_DMA_FROMDEVICE);
-
-			if (rtl8169_try_rx_copy(&skb, pkt_size, desc,
-						tp->rx_buf_sz, tp->align)) {
-				pci_action = pci_unmap_single;
+			if (rtl8169_try_rx_copy(&skb, pkt_size, pdev, addr,
+						tp->align)) {
+				pci_dma_sync_single_for_device(pdev, addr,
+					pkt_size, PCI_DMA_FROMDEVICE);
+				rtl8169_mark_to_asic(desc, tp->rx_buf_sz);
+			} else {
+				pci_unmap_single(pdev, addr, pkt_size,
+						 PCI_DMA_FROMDEVICE);
 				tp->Rx_skbuff[entry] = NULL;
 			}
 
-			pci_action(tp->pci_dev, le64_to_cpu(desc->addr),
-				   tp->rx_buf_sz, PCI_DMA_FROMDEVICE);
-
 			skb_put(skb, pkt_size);
 			skb->protocol = eth_type_trans(skb, dev);
 
-- 
1.4.4.2

