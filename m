From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 1/5] igb: update napi polling to consolidate function
	and return correct values
Date: Thu, 19 Feb 2009 20:39:04 -0800
Message-ID: <20090220043902.29650.35055.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta08.emeryville.ca.mail.comcast.net ([76.96.30.80]:53236 "EHLO
	QMTA08.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751379AbZBTEjX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Feb 2009 23:39:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

igb is currently not returning the correct values for napi.  In addition it
is doing more work than necessary since it will not exit polling until
work_done is equal to zero.

This patch makes the following changes:
1.  Consolidates msi-x and non-msi polling routines.
2.  Corrects return values for polling routines.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |   77 +++++++++++++++++---------------------------
 1 files changed, 30 insertions(+), 47 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 457f12e..d2cd58b 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -106,7 +106,6 @@ static irqreturn_t igb_intr_msi(int irq, void *);
 static irqreturn_t igb_msix_other(int irq, void *);
 static irqreturn_t igb_msix_rx(int irq, void *);
 static irqreturn_t igb_msix_tx(int irq, void *);
-static int igb_clean_rx_ring_msix(struct napi_struct *, int);
 #ifdef CONFIG_IGB_DCA
 static void igb_update_rx_dca(struct igb_ring *);
 static void igb_update_tx_dca(struct igb_ring *);
@@ -3688,50 +3687,35 @@ static irqreturn_t igb_intr(int irq, void *data)
 	return IRQ_HANDLED;
 }
 
-/**
- * igb_poll - NAPI Rx polling callback
- * @napi: napi polling structure
- * @budget: count of how many packets we should handle
- **/
-static int igb_poll(struct napi_struct *napi, int budget)
+static inline void igb_rx_irq_enable(struct igb_ring *rx_ring)
 {
-	struct igb_ring *rx_ring = container_of(napi, struct igb_ring, napi);
 	struct igb_adapter *adapter = rx_ring->adapter;
-	struct net_device *netdev = adapter->netdev;
-	int tx_clean_complete, work_done = 0;
-
-	/* this poll routine only supports one tx and one rx queue */
-#ifdef CONFIG_IGB_DCA
-	if (adapter->flags & IGB_FLAG_DCA_ENABLED)
-		igb_update_tx_dca(&adapter->tx_ring[0]);
-#endif
-	tx_clean_complete = igb_clean_tx_irq(&adapter->tx_ring[0]);
-
-#ifdef CONFIG_IGB_DCA
-	if (adapter->flags & IGB_FLAG_DCA_ENABLED)
-		igb_update_rx_dca(&adapter->rx_ring[0]);
-#endif
-	igb_clean_rx_irq_adv(&adapter->rx_ring[0], &work_done, budget);
+	struct e1000_hw *hw = &adapter->hw;
 
-	/* If no Tx and not enough Rx work done, exit the polling mode */
-	if ((tx_clean_complete && (work_done < budget)) ||
-	    !netif_running(netdev)) {
-		if (adapter->itr_setting & 3)
+	if (adapter->itr_setting & 3) {
+		if (adapter->num_rx_queues == 1)
 			igb_set_itr(adapter);
-		napi_complete(napi);
-		if (!test_bit(__IGB_DOWN, &adapter->state))
-			igb_irq_enable(adapter);
-		return 0;
+		else
+			igb_update_ring_itr(rx_ring);
 	}
 
-	return 1;
+	if (!test_bit(__IGB_DOWN, &adapter->state)) {
+		if (adapter->msix_entries)
+			wr32(E1000_EIMS, rx_ring->eims_value);
+		else
+			igb_irq_enable(adapter);
+	}
 }
 
-static int igb_clean_rx_ring_msix(struct napi_struct *napi, int budget)
+/**
+ * igb_poll - NAPI Rx polling callback
+ * @napi: napi polling structure
+ * @budget: count of how many packets we should handle
+ **/
+static int igb_poll(struct napi_struct *napi, int budget)
 {
 	struct igb_ring *rx_ring = container_of(napi, struct igb_ring, napi);
 	struct igb_adapter *adapter = rx_ring->adapter;
-	struct e1000_hw *hw = &adapter->hw;
 	struct net_device *netdev = adapter->netdev;
 	int work_done = 0;
 
@@ -3741,23 +3725,22 @@ static int igb_clean_rx_ring_msix(struct napi_struct *napi, int budget)
 #endif
 	igb_clean_rx_irq_adv(rx_ring, &work_done, budget);
 
+	if (rx_ring->buddy) {
+#ifdef CONFIG_IGB_DCA
+		if (adapter->flags & IGB_FLAG_DCA_ENABLED)
+			igb_update_tx_dca(rx_ring->buddy);
+#endif
+		if (!igb_clean_tx_irq(rx_ring->buddy))
+			work_done = budget;
+	}
+
 	/* If not enough Rx work done, exit the polling mode */
-	if ((work_done == 0) || !netif_running(netdev)) {
+	if ((work_done < budget) || !netif_running(netdev)) {
 		napi_complete(napi);
-
-		if (adapter->itr_setting & 3) {
-			if (adapter->num_rx_queues == 1)
-				igb_set_itr(adapter);
-			else
-				igb_update_ring_itr(rx_ring);
-		}
-		if (!test_bit(__IGB_DOWN, &adapter->state))
-			wr32(E1000_EIMS, rx_ring->eims_value);
-
-		return 0;
+		igb_rx_irq_enable(rx_ring);
 	}
 
-	return 1;
+	return work_done;
 }
 
 /**

