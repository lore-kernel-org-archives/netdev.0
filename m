From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 4/6] sis190: Rx path update
Date: Sun, 27 Apr 2008 19:04:13 +0200
Message-ID: <20080427170413.GE26953@electric-eye.fr.zoreil.com>
References: <20080427170023.GA26953@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:60996 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1762386AbYD0RX1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Apr 2008 13:23:27 -0400
Content-Disposition: inline
In-Reply-To: <20080427170023.GA26953@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- remove the function pointer to help gcc optimizing the
  inline pci_dma functions
- pci_dma_sync_single_for_cpu is not needed for a single
  large packet
- convert rtl8169_try_rx_copy to bool

b449655ff52ff8a29c66c5fc3fc03617e61182ee did the same
for the r8169 driver.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/sis190.c |   54 +++++++++++++++++++++++++------------------------
 1 files changed, 28 insertions(+), 26 deletions(-)

diff --git a/drivers/net/sis190.c b/drivers/net/sis190.c
index 97aa18d..0b22e75 100644
--- a/drivers/net/sis190.c
+++ b/drivers/net/sis190.c
@@ -518,25 +518,28 @@ static u32 sis190_rx_fill(struct sis190_private *tp, struct net_device *dev,
 	return cur - start;
 }
 
-static int sis190_try_rx_copy(struct sis190_private *tp,
-			      struct sk_buff **sk_buff, int pkt_size,
-			      struct RxDesc *desc)
+static bool sis190_try_rx_copy(struct sis190_private *tp,
+			       struct sk_buff **sk_buff, int pkt_size,
+			       dma_addr_t addr)
 {
-	int ret = -1;
+	struct sk_buff *skb;
+	bool done = false;
 
-	if (pkt_size < rx_copybreak) {
-		struct sk_buff *skb;
+	if (pkt_size >= rx_copybreak)
+		goto out;
 
-		skb = netdev_alloc_skb(tp->dev, pkt_size + 2);
-		if (skb) {
-			skb_reserve(skb, 2);
-			skb_copy_to_linear_data(skb, sk_buff[0]->data, pkt_size);
-			*sk_buff = skb;
-			sis190_give_to_asic(desc, tp->rx_buf_sz);
-			ret = 0;
-		}
-	}
-	return ret;
+	skb = netdev_alloc_skb(tp->dev, pkt_size + 2);
+	if (!skb)
+		goto out;
+
+	pci_dma_sync_single_for_device(tp->pci_dev, addr, pkt_size,
+				       PCI_DMA_FROMDEVICE);
+	skb_reserve(skb, 2);
+	skb_copy_to_linear_data(skb, sk_buff[0]->data, pkt_size);
+	*sk_buff = skb;
+	done = true;
+out:
+	return done;
 }
 
 static inline int sis190_rx_pkt_err(u32 status, struct net_device_stats *stats)
@@ -586,9 +589,9 @@ static int sis190_rx_interrupt(struct net_device *dev,
 			sis190_give_to_asic(desc, tp->rx_buf_sz);
 		else {
 			struct sk_buff *skb = tp->Rx_skbuff[entry];
+			dma_addr_t addr = le32_to_cpu(desc->addr);
 			int pkt_size = (status & RxSizeMask) - 4;
-			void (*pci_action)(struct pci_dev *, dma_addr_t,
-				size_t, int) = pci_dma_sync_single_for_device;
+			struct pci_dev *pdev = tp->pci_dev;
 
 			if (unlikely(pkt_size > tp->rx_buf_sz)) {
 				net_intr(tp, KERN_INFO
@@ -600,19 +603,18 @@ static int sis190_rx_interrupt(struct net_device *dev,
 				continue;
 			}
 
-			pci_dma_sync_single_for_cpu(tp->pci_dev,
-				le32_to_cpu(desc->addr), tp->rx_buf_sz,
-				PCI_DMA_FROMDEVICE);
 
-			if (sis190_try_rx_copy(tp, &skb, pkt_size, desc)) {
-				pci_action = pci_unmap_single;
+			if (sis190_try_rx_copy(tp, &skb, pkt_size, addr)) {
+				pci_dma_sync_single_for_device(pdev, addr,
+					tp->rx_buf_sz, PCI_DMA_FROMDEVICE);
+				sis190_give_to_asic(desc, tp->rx_buf_sz);
+			} else {
+				pci_unmap_single(pdev, addr, tp->rx_buf_sz,
+						 PCI_DMA_FROMDEVICE);
 				tp->Rx_skbuff[entry] = NULL;
 				sis190_make_unusable_by_asic(desc);
 			}
 
-			pci_action(tp->pci_dev, le32_to_cpu(desc->addr),
-				   tp->rx_buf_sz, PCI_DMA_FROMDEVICE);
-
 			skb_put(skb, pkt_size);
 			skb->protocol = eth_type_trans(skb, dev);
 
-- 
1.5.3.3

