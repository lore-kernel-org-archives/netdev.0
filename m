From: Scott Wood <scottwood@freescale.com>
Subject: [PATCH] gianfar: Fix warnings when built on 64-bit
Date: Wed, 29 Jul 2015 00:24:37 -0500
Message-ID: <1438147477-393-1-git-send-email-scottwood@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Scott Wood <scottwood@freescale.com>
To: <linuxppc-dev@lists.ozlabs.org>, <netdev@vger.kernel.org>,
	Claudiu Manoil <claudiu.manoil@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0123.outbound.protection.outlook.com ([65.55.169.123]:16992
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750957AbbG2FYu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Jul 2015 01:24:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As part of defconfig consolidation using fragments, we'd like to be
able to have the same drivers enabled on 32-bit and 64-bit.  Gianfar
happens to only exist on 32-bit systems, and when building the
resulting 64-bit kernel warnings were produced.

A couple of the warnings are trivial, but the rfbptr code has deeper
issues.  It uses the virtual address as the DMA address, which again,
happens to work in the environments where this driver is currently
used, but is not the right thing to do.

Signed-off-by: Scott Wood <scottwood@freescale.com>
---
Alternatively, if there's a desire to not mess with this code (I don't
know how to trigger this code path to test it), this driver should be
given dependencies that ensure that it only builds on 32-bit.
---
 drivers/net/ethernet/freescale/gianfar.c | 22 ++++++++++++++++++----
 1 file changed, 18 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index ff87502..7c682ac 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -565,6 +565,7 @@ static void gfar_ints_enable(struct gfar_private *priv)
 	}
 }
 
+#ifdef CONFIG_PM
 static void lock_tx_qs(struct gfar_private *priv)
 {
 	int i;
@@ -580,6 +581,7 @@ static void unlock_tx_qs(struct gfar_private *priv)
 	for (i = 0; i < priv->num_tx_queues; i++)
 		spin_unlock(&priv->tx_queue[i]->txlock);
 }
+#endif
 
 static int gfar_alloc_tx_queues(struct gfar_private *priv)
 {
@@ -2655,7 +2657,8 @@ static void gfar_clean_tx_ring(struct gfar_priv_tx_q *tx_queue)
 
 		if (unlikely(skb_shinfo(skb)->tx_flags & SKBTX_IN_PROGRESS)) {
 			struct skb_shared_hwtstamps shhwtstamps;
-			u64 *ns = (u64*) (((u32)skb->data + 0x10) & ~0x7);
+			u64 *ns = (u64 *)(((uintptr_t)skb->data + 0x10) &
+					  ~0x7UL);
 
 			memset(&shhwtstamps, 0, sizeof(shhwtstamps));
 			shhwtstamps.hwtstamp = ns_to_ktime(*ns);
@@ -2964,8 +2967,13 @@ int gfar_clean_rx_ring(struct gfar_priv_rx_q *rx_queue, int rx_work_limit)
 		gfar_init_rxbdp(rx_queue, bdp, bufaddr);
 
 		/* Update Last Free RxBD pointer for LFC */
-		if (unlikely(rx_queue->rfbptr && priv->tx_actual_en))
-			gfar_write(rx_queue->rfbptr, (u32)bdp);
+		if (unlikely(rx_queue->rfbptr && priv->tx_actual_en)) {
+			u32 bdp_dma;
+
+			bdp_dma = lower_32_bits(rx_queue->rx_bd_dma_base);
+			bdp_dma += (uintptr_t)bdp - (uintptr_t)base;
+			gfar_write(rx_queue->rfbptr, bdp_dma);
+		}
 
 		/* Update to the next pointer */
 		bdp = next_bd(bdp, base, rx_queue->rx_ring_size);
@@ -3551,6 +3559,8 @@ static noinline void gfar_update_link_state(struct gfar_private *priv)
 		/* Turn last free buffer recording on */
 		if ((tempval1 & MACCFG1_TX_FLOW) && !tx_flow_oldval) {
 			for (i = 0; i < priv->num_rx_queues; i++) {
+				u32 bdp_dma;
+
 				rx_queue = priv->rx_queue[i];
 				bdp = rx_queue->cur_rx;
 				/* skip to previous bd */
@@ -3558,8 +3568,12 @@ static noinline void gfar_update_link_state(struct gfar_private *priv)
 					      rx_queue->rx_bd_base,
 					      rx_queue->rx_ring_size);
 
+				bdp_dma = lower_32_bits(rx_queue->rx_bd_dma_base);
+				bdp_dma += (uintptr_t)bdp -
+					   (uintptr_t)rx_queue->rx_bd_base;
+
 				if (rx_queue->rfbptr)
-					gfar_write(rx_queue->rfbptr, (u32)bdp);
+					gfar_write(rx_queue->rfbptr, bdp_dma);
 			}
 
 			priv->tx_actual_en = 1;
-- 
2.1.4
