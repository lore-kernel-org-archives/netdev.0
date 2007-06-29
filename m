From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 12/21] r8169: confusion between hardware and IP header alignment
Date: Fri, 29 Jun 2007 22:25:55 +0200
Message-ID: <20070629202555.GN3240@electric-eye.fr.zoreil.com>
References: <20070629201212.GA3240@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Edward Hsu <edward_hsu@realtek.com.tw>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:46081 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753681AbXF2U2Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jun 2007 16:28:24 -0400
Content-Disposition: inline
In-Reply-To: <20070629201212.GA3240@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The rx copybreak part is straightforward.

The align field in struct rtl_cfg_info is related to the alignment
requirements of the DMA operation. Its value is set at 2 to limit the
scale of possible regression but my old v1.21 8169 datasheet claims a
8 bytes requirements (which never appeared in the driver, of course)
and the 8101/8168 go with a plain 8 bytes alignment.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Edward Hsu <edward_hsu@realtek.com.tw>
---
 drivers/net/r8169.c |   12 +++++-------
 1 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 9c49d91..a6fea19 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1490,7 +1490,7 @@ static const struct rtl_cfg_info {
 	[RTL_CFG_0] = {
 		.hw_start	= rtl_hw_start_8169,
 		.region		= 1,
-		.align		= NET_IP_ALIGN,
+		.align		= 2,
 		.intr_event	= SYSErr | LinkChg | RxOverflow |
 				  RxFIFOOver | TxErr | TxOK | RxOK | RxErr,
 		.napi_event	= RxFIFOOver | TxErr | TxOK | RxOK | RxOverflow
@@ -2649,8 +2649,7 @@ static inline void rtl8169_rx_csum(struct sk_buff *skb, struct RxDesc *desc)
 }
 
 static inline bool rtl8169_try_rx_copy(struct sk_buff **sk_buff, int pkt_size,
-				       struct pci_dev *pdev, dma_addr_t addr,
-				       unsigned int align)
+				       struct pci_dev *pdev, dma_addr_t addr)
 {
 	struct sk_buff *skb;
 	bool done = false;
@@ -2658,12 +2657,12 @@ static inline bool rtl8169_try_rx_copy(struct sk_buff **sk_buff, int pkt_size,
 	if (pkt_size >= rx_copybreak)
 		goto out;
 
-	skb = dev_alloc_skb(pkt_size + align);
+	skb = dev_alloc_skb(pkt_size + NET_IP_ALIGN);
 	if (!skb)
 		goto out;
 
 	pci_dma_sync_single_for_cpu(pdev, addr, pkt_size, PCI_DMA_FROMDEVICE);
-	skb_reserve(skb, (align - 1) & (unsigned long)skb->data);
+	skb_reserve(skb, NET_IP_ALIGN);
 	skb_copy_from_linear_data(*sk_buff, skb->data, pkt_size);
 	*sk_buff = skb;
 	done = true;
@@ -2732,8 +2731,7 @@ rtl8169_rx_interrupt(struct net_device *dev, struct rtl8169_private *tp,
 
 			rtl8169_rx_csum(skb, desc);
 
-			if (rtl8169_try_rx_copy(&skb, pkt_size, pdev, addr,
-						tp->align)) {
+			if (rtl8169_try_rx_copy(&skb, pkt_size, pdev, addr)) {
 				pci_dma_sync_single_for_device(pdev, addr,
 					pkt_size, PCI_DMA_FROMDEVICE);
 				rtl8169_mark_to_asic(desc, tp->rx_buf_sz);
-- 
1.4.4.2

