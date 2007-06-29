From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 01/21] r8169: use netdev_alloc_skb
Date: Fri, 29 Jun 2007 22:13:14 +0200
Message-ID: <20070629201314.GB3240@electric-eye.fr.zoreil.com>
References: <20070629201212.GA3240@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Edward Hsu <edward_hsu@realtek.com.tw>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:55597 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753042AbXF2UOE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jun 2007 16:14:04 -0400
Content-Disposition: inline
In-Reply-To: <20070629201212.GA3240@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use netdev_alloc_skb and remove the useless sk_buff * argument of
rtl8169_alloc_rx_skb.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Edward Hsu <edward_hsu@realtek.com.tw>
---
 drivers/net/r8169.c |   27 ++++++++++++++-------------
 1 files changed, 14 insertions(+), 13 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 5ec7752..4586446 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1997,31 +1997,28 @@ static inline void rtl8169_map_to_asic(struct RxDesc *desc, dma_addr_t mapping,
 	rtl8169_mark_to_asic(desc, rx_buf_sz);
 }
 
-static int rtl8169_alloc_rx_skb(struct pci_dev *pdev, struct sk_buff **sk_buff,
-				struct RxDesc *desc, int rx_buf_sz,
-				unsigned int align)
+static struct sk_buff *rtl8169_alloc_rx_skb(struct pci_dev *pdev,
+					    struct net_device *dev,
+					    struct RxDesc *desc, int rx_buf_sz,
+					    unsigned int align)
 {
 	struct sk_buff *skb;
 	dma_addr_t mapping;
-	int ret = 0;
 
-	skb = dev_alloc_skb(rx_buf_sz + align);
+	skb = netdev_alloc_skb(dev, rx_buf_sz + align);
 	if (!skb)
 		goto err_out;
 
 	skb_reserve(skb, (align - 1) & (unsigned long)skb->data);
-	*sk_buff = skb;
 
 	mapping = pci_map_single(pdev, skb->data, rx_buf_sz,
 				 PCI_DMA_FROMDEVICE);
 
 	rtl8169_map_to_asic(desc, mapping, rx_buf_sz);
-
 out:
-	return ret;
+	return skb;
 
 err_out:
-	ret = -ENOMEM;
 	rtl8169_make_unusable_by_asic(desc);
 	goto out;
 }
@@ -2044,15 +2041,19 @@ static u32 rtl8169_rx_fill(struct rtl8169_private *tp, struct net_device *dev,
 	u32 cur;
 
 	for (cur = start; end - cur > 0; cur++) {
-		int ret, i = cur % NUM_RX_DESC;
+		struct sk_buff *skb;
+		unsigned int i = cur % NUM_RX_DESC;
 
 		if (tp->Rx_skbuff[i])
 			continue;
 
-		ret = rtl8169_alloc_rx_skb(tp->pci_dev, tp->Rx_skbuff + i,
-			tp->RxDescArray + i, tp->rx_buf_sz, tp->align);
-		if (ret < 0)
+		skb = rtl8169_alloc_rx_skb(tp->pci_dev, dev,
+					   tp->RxDescArray + i,
+					   tp->rx_buf_sz, tp->align);
+		if (!skb)
 			break;
+
+		tp->Rx_skbuff[i] = skb;
 	}
 	return cur - start;
 }
-- 
1.4.4.2

