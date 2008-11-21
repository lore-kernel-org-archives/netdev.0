From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 01/10] tg3: Use NET_IP_ALIGN
Date: Fri, 21 Nov 2008 10:59:42 -0800
Message-ID: <1227295575.5612@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4256 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754017AbYKUT01 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Nov 2008 14:26:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch replaces hardcoded 2's with the NET_IP_ALIGN constant or
TG3_RAW_IP_ALIGN where appropriate.  Some platforms can redefine the
NET_IP_ALIGN definition to zero if unaligned DMA transfers cost more
than the IP header alignment gains.  This patch represents a
performance improvement when using the 5701 on these platforms.
The copy path can be avoided.

TG3_RAW_IP_ALIGN is used in cases where we always want to align the
IP header on dword boundaries.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   20 +++++++++++++-------
 1 files changed, 13 insertions(+), 7 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 9ba18e1..0a82ea8 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -132,6 +132,8 @@
 /* minimum number of free TX descriptors required to wake up TX process */
 #define TG3_TX_WAKEUP_THRESH(tp)		((tp)->tx_pending / 4)
 
+#define TG3_RAW_IP_ALIGN 2
+
 /* number of ETHTOOL_GSTATS u64's */
 #define TG3_NUM_STATS		(sizeof(struct tg3_ethtool_stats)/sizeof(u64))
 
@@ -4231,12 +4233,15 @@ static int tg3_rx(struct tg3 *tp, int budget)
 			goto next_pkt;
 		}
 
-		len = ((desc->idx_len & RXD_LEN_MASK) >> RXD_LEN_SHIFT) - 4; /* omit crc */
+		len = ((desc->idx_len & RXD_LEN_MASK) >> RXD_LEN_SHIFT) -
+		      ETH_FCS_LEN;
 
 		if (len > RX_COPY_THRESHOLD
-			&& tp->rx_offset == 2
-			/* rx_offset != 2 iff this is a 5701 card running
-			 * in PCI-X mode [see tg3_get_invariants()] */
+			&& tp->rx_offset == NET_IP_ALIGN
+			/* rx_offset will likely not equal NET_IP_ALIGN
+			 * if this is a 5701 card running in PCI-X mode
+			 * [see tg3_get_invariants()]
+			 */
 		) {
 			int skb_size;
 
@@ -4256,11 +4261,12 @@ static int tg3_rx(struct tg3 *tp, int budget)
 			tg3_recycle_rx(tp, opaque_key,
 				       desc_idx, *post_ptr);
 
-			copy_skb = netdev_alloc_skb(tp->dev, len + 2);
+			copy_skb = netdev_alloc_skb(tp->dev,
+						    len + TG3_RAW_IP_ALIGN);
 			if (copy_skb == NULL)
 				goto drop_it_no_recycle;
 
-			skb_reserve(copy_skb, 2);
+			skb_reserve(copy_skb, TG3_RAW_IP_ALIGN);
 			skb_put(copy_skb, len);
 			pci_dma_sync_single_for_cpu(tp->pdev, dma_addr, len, PCI_DMA_FROMDEVICE);
 			skb_copy_from_linear_data(skb, copy_skb->data, len);
@@ -12614,7 +12620,7 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	else
 		tp->tg3_flags &= ~TG3_FLAG_POLL_SERDES;
 
-	tp->rx_offset = 2;
+	tp->rx_offset = NET_IP_ALIGN;
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5701 &&
 	    (tp->tg3_flags & TG3_FLAG_PCIX_MODE) != 0)
 		tp->rx_offset = 0;
-- 
1.5.6.4



