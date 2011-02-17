From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 2/4] e1000e: flush all writebacks before unload
Date: Thu, 17 Feb 2011 01:35:08 -0800
Message-ID: <1297935310-23510-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1297935310-23510-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:45687 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754273Ab1BQJfR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Feb 2011 04:35:17 -0500
In-Reply-To: <1297935310-23510-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

The driver was not flushing all writebacks before unloading, possibly
causing memory to be written by the hardware after the driver had
reinitialized the rings.

This adds missing functionality to flush any pending writebacks and is
called in all spots where descriptors should be completed before the driver
begins processing.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Reviewed-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/e1000e/netdev.c |   31 +++++++++++++++++++++----------
 1 files changed, 21 insertions(+), 10 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 174633c..3fa110d 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -3344,6 +3344,21 @@ int e1000e_up(struct e1000_adapter *adapter)
 	return 0;
 }
 
+static void e1000e_flush_descriptors(struct e1000_adapter *adapter)
+{
+	struct e1000_hw *hw = &adapter->hw;
+
+	if (!(adapter->flags2 & FLAG2_DMA_BURST))
+		return;
+
+	/* flush pending descriptor writebacks to memory */
+	ew32(TIDV, adapter->tx_int_delay | E1000_TIDV_FPD);
+	ew32(RDTR, adapter->rx_int_delay | E1000_RDTR_FPD);
+
+	/* execute the writes immediately */
+	e1e_flush();
+}
+
 void e1000e_down(struct e1000_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
@@ -3383,6 +3398,9 @@ void e1000e_down(struct e1000_adapter *adapter)
 
 	if (!pci_channel_offline(adapter->pdev))
 		e1000e_reset(adapter);
+
+	e1000e_flush_descriptors(adapter);
+
 	e1000_clean_tx_ring(adapter);
 	e1000_clean_rx_ring(adapter);
 
@@ -4354,19 +4372,12 @@ link_up:
 	else
 		ew32(ICS, E1000_ICS_RXDMT0);
 
+	/* flush pending descriptors to memory before detecting Tx hang */
+	e1000e_flush_descriptors(adapter);
+
 	/* Force detection of hung controller every watchdog period */
 	adapter->detect_tx_hung = 1;
 
-	/* flush partial descriptors to memory before detecting Tx hang */
-	if (adapter->flags2 & FLAG2_DMA_BURST) {
-		ew32(TIDV, adapter->tx_int_delay | E1000_TIDV_FPD);
-		ew32(RDTR, adapter->rx_int_delay | E1000_RDTR_FPD);
-		/*
-		 * no need to flush the writes because the timeout code does
-		 * an er32 first thing
-		 */
-	}
-
 	/*
 	 * With 82571 controllers, LAA may be overwritten due to controller
 	 * reset from the other port. Set the appropriate LAA in RAR[0]
-- 
1.7.4

