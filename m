From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 17/21] r8169: align the IP header when there is no DMA constraint
Date: Fri, 29 Jun 2007 22:27:48 +0200
Message-ID: <20070629202748.GS3240@electric-eye.fr.zoreil.com>
References: <20070629201212.GA3240@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Edward Hsu <edward_hsu@realtek.com.tw>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:46096 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754346AbXF2U2b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jun 2007 16:28:31 -0400
Content-Disposition: inline
In-Reply-To: <20070629201212.GA3240@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Align the IP header when the chipset can DMA at any location (plain 0x8169).
Otherwise (0x8136/0x8168) obey the constraint imposed by the hardware.

This patch complements the previous alignment rework done for copybreak.

Original idea from Philip Craig <philipc@snapgear.com>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Philip Craig <philipc@snapgear.com>
Cc: Mike Isely <isely@pobox.com>
Cc: Edward Hsu <edward_hsu@realtek.com.tw>
---
 drivers/net/r8169.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index d8862cd..1942bf7 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1415,7 +1415,7 @@ static const struct rtl_cfg_info {
 	[RTL_CFG_0] = {
 		.hw_start	= rtl_hw_start_8169,
 		.region		= 1,
-		.align		= 2,
+		.align		= 0,
 		.intr_event	= SYSErr | LinkChg | RxOverflow |
 				  RxFIFOOver | TxErr | TxOK | RxOK | RxErr,
 		.napi_event	= RxFIFOOver | TxErr | TxOK | RxOK | RxOverflow
@@ -2076,12 +2076,15 @@ static struct sk_buff *rtl8169_alloc_rx_skb(struct pci_dev *pdev,
 {
 	struct sk_buff *skb;
 	dma_addr_t mapping;
+	unsigned int pad;
 
-	skb = netdev_alloc_skb(dev, rx_buf_sz + align);
+	pad = align ? align : NET_IP_ALIGN;
+
+	skb = netdev_alloc_skb(dev, rx_buf_sz + pad);
 	if (!skb)
 		goto err_out;
 
-	skb_reserve(skb, (align - 1) & (unsigned long)skb->data);
+	skb_reserve(skb, align ? ((pad - 1) & (unsigned long)skb->data) : pad);
 
 	mapping = pci_map_single(pdev, skb->data, rx_buf_sz,
 				 PCI_DMA_FROMDEVICE);
-- 
1.4.4.2

