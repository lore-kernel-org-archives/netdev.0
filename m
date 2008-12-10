From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Subject: [PATCH] tc35815: Enable StripCRC feature
Date: Thu, 11 Dec 2008 00:22:59 +0900 (JST)
Message-ID: <20081211.002259.07456931.anemo@mba.ocn.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mba.ocn.ne.jp ([122.1.235.107]:61217 "EHLO smtp.mba.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753485AbYLJPWu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Dec 2008 10:22:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The chip can strip CRC automatically on receiving.  Enable it.

Also fix potential RX_BUF_SIZE calculation bug which was obscured by
alignment.  And use proper symbols (NET_IP_ALIGN, ETH_FCS_LEN, etc.)
instead of magic numbers.

Signed-off-by: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
---
This is a revised patch.  Fixed missing backslash.

 drivers/net/tc35815.c |   20 ++++++++++++--------
 1 files changed, 12 insertions(+), 8 deletions(-)

diff --git a/drivers/net/tc35815.c b/drivers/net/tc35815.c
index 385b174..4f4301b 100644
--- a/drivers/net/tc35815.c
+++ b/drivers/net/tc35815.c
@@ -37,6 +37,7 @@ static const char *version = "tc35815.c:v" DRV_VERSION "\n";
 #include <linux/interrupt.h>
 #include <linux/ioport.h>
 #include <linux/in.h>
+#include <linux/if_vlan.h>
 #include <linux/slab.h>
 #include <linux/string.h>
 #include <linux/spinlock.h>
@@ -341,7 +342,7 @@ struct BDesc {
 	Tx_En)	/* maybe  0x7b01 */
 #endif
 #define RX_CTL_CMD	(Rx_EnGood | Rx_EnRxPar | Rx_EnLongErr | Rx_EnOver \
-	| Rx_EnCRCErr | Rx_EnAlign | Rx_RxEn)	/* maybe 0x6f01 */
+	| Rx_EnCRCErr | Rx_EnAlign | Rx_StripCRC | Rx_RxEn) /* maybe 0x6f11 */
 #define INT_EN_CMD  (Int_NRAbtEn | \
 	Int_DmParErrEn | Int_DParDEn | Int_DParErrEn | \
 	Int_SSysErrEn  | Int_RMasAbtEn | Int_RTargAbtEn | \
@@ -373,9 +374,11 @@ struct BDesc {
 #if RX_CTL_CMD & Rx_LongEn
 #define RX_BUF_SIZE	PAGE_SIZE
 #elif RX_CTL_CMD & Rx_StripCRC
-#define RX_BUF_SIZE	ALIGN(ETH_FRAME_LEN + 4 + 2, 32) /* +2: reserve */
+#define RX_BUF_SIZE	\
+	L1_CACHE_ALIGN(ETH_FRAME_LEN + VLAN_HLEN + NET_IP_ALIGN)
 #else
-#define RX_BUF_SIZE	ALIGN(ETH_FRAME_LEN + 2, 32) /* +2: reserve */
+#define RX_BUF_SIZE	\
+	L1_CACHE_ALIGN(ETH_FRAME_LEN + VLAN_HLEN + ETH_FCS_LEN + NET_IP_ALIGN)
 #endif
 #endif /* TC35815_USE_PACKEDBUFFER */
 #define RX_FD_RESERVE	(2 / 2)	/* max 2 BD per RxFD */
@@ -1670,7 +1673,7 @@ tc35815_rx(struct net_device *dev)
 		struct RxFD *next_rfd;
 #endif
 #if (RX_CTL_CMD & Rx_StripCRC) == 0
-		pkt_len -= 4;
+		pkt_len -= ETH_FCS_LEN;
 #endif
 
 		if (netif_msg_rx_status(lp))
@@ -1689,14 +1692,14 @@ tc35815_rx(struct net_device *dev)
 #endif
 #ifdef TC35815_USE_PACKEDBUFFER
 			BUG_ON(bd_count > 2);
-			skb = dev_alloc_skb(pkt_len + 2); /* +2: for reserve */
+			skb = dev_alloc_skb(pkt_len + NET_IP_ALIGN);
 			if (skb == NULL) {
 				printk(KERN_NOTICE "%s: Memory squeeze, dropping packet.\n",
 				       dev->name);
 				dev->stats.rx_dropped++;
 				break;
 			}
-			skb_reserve(skb, 2);   /* 16 bit alignment */
+			skb_reserve(skb, NET_IP_ALIGN);
 
 			data = skb_put(skb, pkt_len);
 
@@ -1748,8 +1751,9 @@ tc35815_rx(struct net_device *dev)
 			pci_unmap_single(lp->pci_dev,
 					 lp->rx_skbs[cur_bd].skb_dma,
 					 RX_BUF_SIZE, PCI_DMA_FROMDEVICE);
-			if (!HAVE_DMA_RXALIGN(lp))
-				memmove(skb->data, skb->data - 2, pkt_len);
+			if (!HAVE_DMA_RXALIGN(lp) && NET_IP_ALIGN)
+				memmove(skb->data, skb->data - NET_IP_ALIGN,
+					pkt_len);
 			data = skb_put(skb, pkt_len);
 #endif /* TC35815_USE_PACKEDBUFFER */
 			if (netif_msg_pktdata(lp))
-- 
1.5.6.3

