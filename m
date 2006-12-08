From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 20/22] e1000: Fix poor quad port performance with NAPI
Date: Fri, 08 Dec 2006 15:03:29 -0800
Message-ID: <20061208230329.30109.85896.stgit@gitlost.site>
References: <20061208230209.30109.49157.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:4396 "EHLO gitlost.site"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1947468AbWLHWyB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Dec 2006 17:54:01 -0500
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20061208230209.30109.49157.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This fix attempts to solve a customer reported issue with NAPI enabled
e1000 having bad performance when transmitting simultaneously on
four ports.  The issue comes down to an interaction between NAPI
hardware interrupt balancing, and the driver rescheduling poll on
the same processor.

We try to fix by allowing the driver to re-enable interrupts sooner
instead of polling one more time, when there was recently all the
work completed in cleanup.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_main.c |   25 ++++++++++++++++---------
 1 files changed, 16 insertions(+), 9 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 1a2b052..458aa38 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -3826,7 +3826,7 @@ e1000_intr_msi(int irq, void *data)
 
 	for (i = 0; i < E1000_MAX_INTR; i++)
 		if (unlikely(!adapter->clean_rx(adapter, adapter->rx_ring) &
-		   !e1000_clean_tx_irq(adapter, adapter->tx_ring)))
+		   e1000_clean_tx_irq(adapter, adapter->tx_ring)))
 			break;
 
 	if (likely(adapter->itr_setting & 3))
@@ -3979,7 +3979,7 @@ e1000_clean(struct net_device *poll_dev,
 	poll_dev->quota -= work_done;
 
 	/* If no Tx and not enough Rx work done, exit the polling mode */
-	if ((!tx_cleaned && (work_done == 0)) ||
+	if ((tx_cleaned && (work_done < work_to_do)) ||
 	   !netif_running(poll_dev)) {
 quit_polling:
 		if (likely(adapter->itr_setting & 3))
@@ -4009,7 +4009,7 @@ e1000_clean_tx_irq(struct e1000_adapter 
 #ifdef CONFIG_E1000_NAPI
 	unsigned int count = 0;
 #endif
-	boolean_t cleaned = FALSE;
+	boolean_t cleaned = TRUE;
 	unsigned int total_tx_bytes=0, total_tx_packets=0;
 
 	i = tx_ring->next_to_clean;
@@ -4025,13 +4025,17 @@ e1000_clean_tx_irq(struct e1000_adapter 
 			if (cleaned) {
 				struct sk_buff *skb = buffer_info->skb;
 #ifdef NETIF_F_TSO
-				unsigned int segs = skb_shinfo(skb)->gso_segs;
-				if (segs)
-					total_tx_packets += segs;
-#endif
-
+				unsigned int segs, bytecount;
+				segs = skb_shinfo(skb)->gso_segs ?: 1;
+				/* multiply data chunks by size of headers */
+				bytecount = ((segs - 1) * skb_headlen(skb)) +
+				            skb->len;
+				total_tx_packets += segs;
+				total_tx_bytes += bytecount;
+#else
 				total_tx_packets++;
 				total_tx_bytes += skb->len;
+#endif
 			}
 			e1000_unmap_and_free_tx_resource(adapter, buffer_info);
 			tx_desc->upper.data = 0;
@@ -4044,7 +4048,10 @@ e1000_clean_tx_irq(struct e1000_adapter 
 #ifdef CONFIG_E1000_NAPI
 #define E1000_TX_WEIGHT 64
 		/* weight of a sort for tx, to avoid endless transmit cleanup */
-		if (count++ == E1000_TX_WEIGHT) break;
+		if (count++ == E1000_TX_WEIGHT) {
+			cleaned = FALSE;
+			break;
+		}
 #endif
 	}
 



---
Auke Kok <auke-jan.h.kok@intel.com>
