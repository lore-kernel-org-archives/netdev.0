From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 11/12] r8169: align the IP header when there is no DMA constraint
Date: Thu, 26 Apr 2007 23:49:29 +0200
Message-ID: <20070426214929.GL7344@electric-eye.fr.zoreil.com>
References: <20070426205714.GA12701@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Philip Craig <philipc@snapgear.com>,
	Mike Isely <isely@pobox.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:50848 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755182AbXDZVuE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Apr 2007 17:50:04 -0400
Content-Disposition: inline
In-Reply-To: <20070426205714.GA12701@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Align the IP header when the chipset can DMA at any location (plain 0x8169).
Otherwise (0x8136/0x8168) obey the constraint imposed by the hardware.

This patch complements the previous alignment rework done for copybreak.

Original idea from Philip Craig <philipc@snapgear.com>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Philip Craig <philipc@snapgear.com>
Cc: Mike Isely <isely@pobox.com>
---
 drivers/net/r8169.c |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 2cbb63b..2667862 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1500,7 +1500,7 @@ static const struct rtl_cfg_info {
 	[RTL_CFG_0] = {
 		.hw_start	= rtl_hw_start_8169,
 		.region		= 1,
-		.align		= 2,
+		.align		= 0,
 		.intr_event	= SYSErr | LinkChg | RxOverflow |
 				  RxFIFOOver | TxErr | TxOK | RxOK | RxErr,
 		.napi_event	= RxFIFOOver | TxErr | TxOK | RxOK | RxOverflow,
@@ -2189,13 +2189,17 @@ static int rtl8169_alloc_rx_skb(struct pci_dev *pdev, struct sk_buff **sk_buff,
 {
 	struct sk_buff *skb;
 	dma_addr_t mapping;
+	unsigned int pad;
 	int ret = 0;
 
-	skb = dev_alloc_skb(rx_buf_sz + align);
+	pad = align ? align : NET_IP_ALIGN;
+
+	skb = dev_alloc_skb(rx_buf_sz + pad);
 	if (!skb)
 		goto err_out;
 
-	skb_reserve(skb, (align - 1) & (unsigned long)skb->data);
+
+	skb_reserve(skb, align ? ((pad - 1) & (unsigned long)skb->data) : pad);
 	*sk_buff = skb;
 
 	mapping = pci_map_single(pdev, skb->data, rx_buf_sz,
-- 
1.4.4.2
