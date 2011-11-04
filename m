From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 2/8] tg3: Fix 4k tx bd segmentation code
Date: Fri, 4 Nov 2011 12:14:59 -0700
Message-ID: <1320434105-12898-3-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1773 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756100Ab1KDTOD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Nov 2011 15:14:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The new 4k tx bd segmentation code had a bug in the error cleanup path.
If the driver did not map all the physical fragments, the abort path
would wind up advancing the producer index beyond the point where the
setup code stopped.  This would ultimately turn into a tx recovery error
where the driver would expect the skb pointer to be set when it isn't.
This patch fixes the problem, and then makes the code a little easier to
understand.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |   47 ++++++++++++++++++-----------------
 1 files changed, 24 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 3590163..507b73b 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -6444,31 +6444,26 @@ static bool tg3_tx_frag_set(struct tg3_napi *tnapi, u32 *entry, u32 *budget,
 		hwbug = 1;
 
 	if (tg3_flag(tp, 4K_FIFO_LIMIT)) {
+		u32 prvidx = *entry;
 		u32 tmp_flag = flags & ~TXD_FLAG_END;
-		while (len > TG3_TX_BD_DMA_MAX) {
+		while (len > TG3_TX_BD_DMA_MAX && *budget) {
 			u32 frag_len = TG3_TX_BD_DMA_MAX;
 			len -= TG3_TX_BD_DMA_MAX;
 
-			if (len) {
-				tnapi->tx_buffers[*entry].fragmented = true;
-				/* Avoid the 8byte DMA problem */
-				if (len <= 8) {
-					len += TG3_TX_BD_DMA_MAX / 2;
-					frag_len = TG3_TX_BD_DMA_MAX / 2;
-				}
-			} else
-				tmp_flag = flags;
-
-			if (*budget) {
-				tg3_tx_set_bd(&tnapi->tx_ring[*entry], map,
-					      frag_len, tmp_flag, mss, vlan);
-				(*budget)--;
-				*entry = NEXT_TX(*entry);
-			} else {
-				hwbug = 1;
-				break;
+			/* Avoid the 8byte DMA problem */
+			if (len <= 8) {
+				len += TG3_TX_BD_DMA_MAX / 2;
+				frag_len = TG3_TX_BD_DMA_MAX / 2;
 			}
 
+			tnapi->tx_buffers[*entry].fragmented = true;
+
+			tg3_tx_set_bd(&tnapi->tx_ring[*entry], map,
+				      frag_len, tmp_flag, mss, vlan);
+			*budget -= 1;
+			prvidx = *entry;
+			*entry = NEXT_TX(*entry);
+
 			map += frag_len;
 		}
 
@@ -6476,10 +6471,11 @@ static bool tg3_tx_frag_set(struct tg3_napi *tnapi, u32 *entry, u32 *budget,
 			if (*budget) {
 				tg3_tx_set_bd(&tnapi->tx_ring[*entry], map,
 					      len, flags, mss, vlan);
-				(*budget)--;
+				*budget -= 1;
 				*entry = NEXT_TX(*entry);
 			} else {
 				hwbug = 1;
+				tnapi->tx_buffers[prvidx].fragmented = false;
 			}
 		}
 	} else {
@@ -6561,6 +6557,8 @@ static int tigon3_dma_hwbug_workaround(struct tg3_napi *tnapi,
 			dev_kfree_skb(new_skb);
 			ret = -1;
 		} else {
+			u32 save_entry = *entry;
+
 			base_flags |= TXD_FLAG_END;
 
 			tnapi->tx_buffers[*entry].skb = new_skb;
@@ -6570,7 +6568,7 @@ static int tigon3_dma_hwbug_workaround(struct tg3_napi *tnapi,
 			if (tg3_tx_frag_set(tnapi, entry, budget, new_addr,
 					    new_skb->len, base_flags,
 					    mss, vlan)) {
-				tg3_tx_skb_unmap(tnapi, *entry, 0);
+				tg3_tx_skb_unmap(tnapi, save_entry, 0);
 				dev_kfree_skb(new_skb);
 				ret = -1;
 			}
@@ -6786,11 +6784,14 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			if (dma_mapping_error(&tp->pdev->dev, mapping))
 				goto dma_error;
 
-			if (tg3_tx_frag_set(tnapi, &entry, &budget, mapping,
+			if (!budget ||
+			    tg3_tx_frag_set(tnapi, &entry, &budget, mapping,
 					    len, base_flags |
 					    ((i == last) ? TXD_FLAG_END : 0),
-					    tmp_mss, vlan))
+					    tmp_mss, vlan)) {
 				would_hit_hwbug = 1;
+				break;
+			}
 		}
 	}
 
-- 
1.7.3.4
