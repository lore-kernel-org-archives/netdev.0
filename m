From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 05/12] r8169: confusion between hardware and IP header alignment
Date: Thu, 26 Apr 2007 23:48:28 +0200
Message-ID: <20070426214828.GF7344@electric-eye.fr.zoreil.com>
References: <20070426205714.GA12701@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Edward Hsu <edward_hsu@realtek.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:58560 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755152AbXDZVvv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Apr 2007 17:51:51 -0400
Content-Disposition: inline
In-Reply-To: <20070426205714.GA12701@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The rx copybreak part is straightforward.

The align field in struct rtl_cfg_info is related to the alignment
requirements of the DMA operation. Its value is set at 2 to limit the
scale of possible regression but my old v1.21 8169 datasheet claims a
8 bytes requirements (that was never followed by the driver of course)
and the 8101/8168 go with a plain 8 bytes alignments. Yuck, yuck...

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Edward Hsu <edward_hsu@realtek.com>
---
 drivers/net/r8169.c |   11 +++++------
 1 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 241e204..1111ca4 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1500,7 +1500,7 @@ static const struct rtl_cfg_info {
 	[RTL_CFG_0] = {
 		.hw_start	= rtl_hw_start_8169,
 		.region		= 1,
-		.align		= NET_IP_ALIGN,
+		.align		= 2,
 		.intr_event	= SYSErr | LinkChg | RxOverflow |
 				  RxFIFOOver | TxErr | TxOK | RxOK | RxErr,
 		.napi_event	= RxFIFOOver | TxErr | TxOK | RxOK | RxOverflow
@@ -2657,17 +2657,16 @@ static inline void rtl8169_rx_csum(struct sk_buff *skb, struct RxDesc *desc)
 }
 
 static inline int rtl8169_try_rx_copy(struct sk_buff **sk_buff, int pkt_size,
-				      struct RxDesc *desc, int rx_buf_sz,
-				      unsigned int align)
+				      struct RxDesc *desc, int rx_buf_sz)
 {
 	int ret = -1;
 
 	if (pkt_size < rx_copybreak) {
 		struct sk_buff *skb;
 
-		skb = dev_alloc_skb(pkt_size + align);
+		skb = dev_alloc_skb(pkt_size + NET_IP_ALIGN);
 		if (skb) {
-			skb_reserve(skb, (align - 1) & (unsigned long)skb->data);
+			skb_reserve(skb, NET_IP_ALIGN);
 			eth_copy_and_sum(skb, sk_buff[0]->data, pkt_size, 0);
 			*sk_buff = skb;
 			rtl8169_mark_to_asic(desc, rx_buf_sz);
@@ -2743,7 +2742,7 @@ rtl8169_rx_interrupt(struct net_device *dev, struct rtl8169_private *tp,
 				PCI_DMA_FROMDEVICE);
 
 			if (rtl8169_try_rx_copy(&skb, pkt_size, desc,
-						tp->rx_buf_sz, tp->align)) {
+						tp->rx_buf_sz)) {
 				pci_action = pci_unmap_single;
 				tp->Rx_skbuff[entry] = NULL;
 			}
-- 
1.4.4.2
