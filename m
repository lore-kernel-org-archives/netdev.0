From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 4/8] e1000: fix NAPI performance on 4-port adapters
Date: Fri, 12 Jan 2007 16:37:47 -0800
Message-ID: <20070113003747.16816.45007.stgit@gitlost.site>
References: <20070113003650.16816.34076.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:1199 "EHLO gitlost.site"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1161182AbXAMAyL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Jan 2007 19:54:11 -0500
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20070113003650.16816.34076.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This fix attempts to solve a customer (IBM) reported issue with NAPI
enabled e1000 having bad performance when transmitting simultaneously
on four ports.  The issue comes down to an interaction between NAPI,
hardware interrupt balancing, and the driver rescheduling poll on
the same processor.  Try to fix by allowing the driver to re-enable
interrupts sooner instead of polling one more time, when there was
recently all the work completed in cleanup.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_main.c |   13 ++++++++-----
 1 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index d408949..ab1b40f 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -3814,7 +3814,7 @@ e1000_intr_msi(int irq, void *data)
 
 	for (i = 0; i < E1000_MAX_INTR; i++)
 		if (unlikely(!adapter->clean_rx(adapter, adapter->rx_ring) &
-		   !e1000_clean_tx_irq(adapter, adapter->tx_ring)))
+		   e1000_clean_tx_irq(adapter, adapter->tx_ring)))
 			break;
 
 	if (likely(adapter->itr_setting & 3))
@@ -3917,7 +3917,7 @@ e1000_intr(int irq, void *data)
 
 	for (i = 0; i < E1000_MAX_INTR; i++)
 		if (unlikely(!adapter->clean_rx(adapter, adapter->rx_ring) &
-		   !e1000_clean_tx_irq(adapter, adapter->tx_ring)))
+		   e1000_clean_tx_irq(adapter, adapter->tx_ring)))
 			break;
 
 	if (likely(adapter->itr_setting & 3))
@@ -3967,7 +3967,7 @@ e1000_clean(struct net_device *poll_dev, int *budget)
 	poll_dev->quota -= work_done;
 
 	/* If no Tx and not enough Rx work done, exit the polling mode */
-	if ((!tx_cleaned && (work_done == 0)) ||
+	if ((tx_cleaned && (work_done < work_to_do)) ||
 	   !netif_running(poll_dev)) {
 quit_polling:
 		if (likely(adapter->itr_setting & 3))
@@ -3997,7 +3997,7 @@ e1000_clean_tx_irq(struct e1000_adapter *adapter,
 #ifdef CONFIG_E1000_NAPI
 	unsigned int count = 0;
 #endif
-	boolean_t cleaned = FALSE;
+	boolean_t cleaned = TRUE;
 	unsigned int total_tx_bytes=0, total_tx_packets=0;
 
 	i = tx_ring->next_to_clean;
@@ -4028,7 +4028,10 @@ e1000_clean_tx_irq(struct e1000_adapter *adapter,
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
